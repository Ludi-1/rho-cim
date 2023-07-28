-- HDL model for a single convolutional layer
library ieee;
use ieee.std_logic_1164.all;
use IEEE.math_real.all;
use ieee.numeric_std.all;

use work.cnn_package.all;

entity cnn_layer is
    generic(
        input_channels: integer := 5;
        output_channels: integer := 65; -- num of output channels

        kernel_size: integer := 3; -- 5x5 kernel
        image_size: integer := 28; -- mnist 28x28 image
        datatype_size: integer := 8; -- datatype size input
        crossbar_size: integer := 512; -- RxR Crossbar size
        obuf_datatype_size: integer := 25; -- 2d + log2(R) = 2*8+9
        func_datatype_size: integer := 1;
        row_split_tiles: integer := integer(ceil(real(kernel_size**2*input_channels)/real(crossbar_size)));
        col_split_tiles: integer := integer(ceil(real(output_channels)*real(datatype_size)/real(crossbar_size)));
        n_tiles: integer := integer(real(row_split_tiles*col_split_tiles));
        obuf_addr_max: integer := integer(ceil(real(crossbar_size)/real(datatype_size))); -- Amount of entries output buffer
        addr_out_buf_size: integer := integer(ceil(log2(real(obuf_addr_max)))); -- Addr size output buffer
        addr_rd_size: integer := integer(ceil(log2(real(crossbar_size)))) -- Bit length of rd buf addr
    );
    port (
        i_clk : in std_logic;
        i_rst: in std_logic;

        i_write_enable: in std_logic_vector(input_channels - 1 downto 0);
        o_ibuf_full: out std_logic_vector(input_channels - 1 downto 0);
        i_ibuf_data: in std_logic_vector(datatype_size * input_channels - 1 downto 0); -- Input data for input buffers

        o_tile_rd_addr: out std_logic_vector(addr_rd_size - 1 downto 0); -- Addr for RD buffer
        o_tile_rd_data: out std_logic_vector(datatype_size - 1 downto 0); -- Data to RD buffer
        i_tiles_done: in std_logic_vector(n_tiles - 1 downto 0); -- Done/Ready signal from tiles
        i_tile_data: in std_logic_vector(obuf_datatype_size * n_tiles - 1 downto 0); -- Data from output buffer tiles
        o_tile_addr: out std_logic_vector(addr_out_buf_size - 1 downto 0); -- Address to output buffer
        o_rd_write_enable: out std_logic_vector(n_tiles - 1 downto 0);
        o_tile_start: out std_logic_vector(n_tiles - 1 downto 0);

        i_next_ibuf_full: in std_logic_vector(output_channels - 1 downto 0); -- Next layer FIFO ibuf full
        i_start: in std_logic; -- Start consuming input buffer
        i_next_layer_busy: in std_logic; -- Next layer busy signal
        o_layer_busy: out std_logic; -- This Layer busy
        o_write_enable : out std_logic_vector(output_channels - 1 downto 0); -- Write data to next layer
        o_data: out std_logic_vector(func_datatype_size - 1 downto 0); -- Data to the next layer
        o_start: out std_logic
    );
end cnn_layer;

architecture behavioral of cnn_layer is

component cnn_ibuf is
    generic(
        kernel_size: integer := 3; -- 5x5 kernel
        datatype_size: integer := 8;
        image_size: integer := 28 -- mnist 28x28 image
    );
    port (
        i_clk : in std_logic;
        i_rst: in std_logic;

        i_write_enable: in std_logic;
        o_ibuf_full: out std_logic;
        i_data: in std_logic_vector(datatype_size - 1 downto 0);
        -- o_data : out data_array(kernel_size**2 - 1 downto 0)(datatype_size - 1 downto 0)
        o_data: out std_logic_vector(datatype_size * kernel_size**2 - 1 downto 0)
    );
end component;

component cnn_func is
    generic(
        input_channels: integer := 5;
        output_channels: integer := 10; -- num of output channels
        datatype_size: integer := 8; -- datatype size input
        crossbar_size: integer := 512; -- RxR Crossbar size
        obuf_datatype_size: integer := 25; -- 2d + log2(R) = 2*8+9
        func_datatype_size: integer := 1;
        row_split_tiles: integer := integer(ceil(real(input_channels)/real(crossbar_size)));
        col_split_tiles: integer := integer(ceil(real(output_channels)*real(datatype_size)/real(crossbar_size)));
        n_tiles: integer := integer(real(row_split_tiles*col_split_tiles));
        obuf_addr_max: integer := integer(ceil(real(crossbar_size)/real(datatype_size))); -- Amount of entries output buffer
        addr_out_buf_size: integer := integer(ceil(log2(real(obuf_addr_max)))) -- Addr size output buffer
    );
    port (
        i_clk : in std_logic;
        i_rst: in std_logic;
        
        i_tiles_done: in std_logic_vector(n_tiles - 1 downto 0); -- Done signal from tiles
        i_data : in std_logic_vector(obuf_datatype_size * n_tiles - 1 downto 0); -- Data from output buffer tiles
        o_tile_addr: out std_logic_vector(addr_out_buf_size - 1 downto 0); -- Address for CIM tile output buffers

        i_next_ibuf_full: in std_logic_vector(output_channels - 1 downto 0);
        i_start: in std_logic; -- Start signal for CIM tiles of this layer
        i_next_layer_busy: in std_logic; -- Next layer busy signal
        o_func_busy: out std_logic; -- Functional unit busy
        o_write_enable : out std_logic_vector(output_channels - 1 downto 0); -- Write data to next layer
        o_data: out std_logic_vector(func_datatype_size - 1 downto 0); -- Data to the next layer
        o_start: out std_logic -- Start CIM tiles of next layer
    );
end component;

    signal s_func_start: std_logic;
    signal s_ctrl_busy, s_func_busy: std_logic;
    signal s_tile_rd_data: data_array(input_channels - 1 downto 0)(datatype_size*kernel_size**2 - 1 downto 0); -- All kernel data
    signal s_unrolled_rd_data: data_array(input_channels*kernel_size**2 - 1 downto 0)(datatype_size - 1 downto 0);
    signal s_ctrl_count: natural range kernel_size**2 * input_channels - 1 downto 0; -- Iterate over all kernel elements
    signal s_rd_addr: natural range crossbar_size - 1 downto 0; -- RD buf addr

    type t_ctrl_state is (t_ctrl_idle, t_ctrl_write, t_ctrl_start);
    signal s_ctrl_state: t_ctrl_state;

begin

    g_ibuf: for input_channel in 0 to input_channels - 1 generate
        ibuf: cnn_ibuf
            generic map(
                kernel_size => kernel_size,
                datatype_size => datatype_size,
                image_size => image_size
            )
            port map(
                i_clk => i_clk,
                i_rst => i_rst,
                o_ibuf_full => o_ibuf_full(input_channel),
                i_write_enable => i_write_enable(input_channel),
                i_data => i_ibuf_data(datatype_size*(input_channel + 1) - 1 downto datatype_size*input_channel),
                o_data => s_tile_rd_data(input_channel)
            );
    end generate;

    -- Unroll s_tile_rd_data for easier indexing
    g_unroll_data_input_channels: for input_channel in 0 to input_channels - 1 generate
        g_unroll_data_kernel: for kernel_element in 0 to kernel_size**2 - 1 generate
            s_unrolled_rd_data(input_channel*kernel_size**2 + kernel_element) <= s_tile_rd_data(input_channel)((kernel_element + 1)*datatype_size - 1 downto kernel_element*datatype_size);
        end generate;
    end generate;

    func: cnn_func
        generic map(
            input_channels => input_channels,
            output_channels => output_channels,
            datatype_size => datatype_size,
            crossbar_size => crossbar_size,
            obuf_datatype_size => obuf_datatype_size,
            func_datatype_size => func_datatype_size,
            row_split_tiles => row_split_tiles,
            col_split_tiles => col_split_tiles,
            n_tiles => n_tiles,
            obuf_addr_max => obuf_addr_max,
            addr_out_buf_size => addr_out_buf_size
        )
        port map(
            i_clk => i_clk,
            i_rst => i_rst,
            i_tiles_done => i_tiles_done,
            i_data => i_tile_data,
            o_tile_addr => o_tile_addr,
            i_next_ibuf_full => i_next_ibuf_full,
            i_start => s_func_start,
            i_next_layer_busy => i_next_layer_busy,
            o_func_busy => s_func_busy,
            o_write_enable => o_write_enable,
            o_data => o_data,
            o_start => o_start
        );

    o_layer_busy <= s_ctrl_busy or s_func_busy;
    o_tile_rd_data <= s_unrolled_rd_data(s_ctrl_count);
    o_tile_rd_addr <= std_logic_vector(to_unsigned(s_rd_addr, addr_rd_size));

    ctrl_proc: process(all) is
    begin
        if rising_edge(i_clk) then
            if i_rst = '1' then
                s_ctrl_busy <= '0';
                s_ctrl_count <= 0;
                s_rd_addr <= 0;
                o_rd_write_enable <= (others => '0');
                o_tile_start <= (others => '0');
                s_func_start <= '0';
            else
                case s_ctrl_state is
                    when t_ctrl_idle =>
                        s_ctrl_busy <= '0';
                        s_ctrl_count <= 0;
                        s_rd_addr <= 0;
                        o_rd_write_enable <= (others => '0');
                        o_tile_start <= (others => '0');
                        s_func_start <= '0';
                        if i_start = '1' then
                            o_rd_write_enable(col_split_tiles - 1 downto 0) <= (col_split_tiles - 1 downto 0 => '1');
                            s_ctrl_state <= t_ctrl_write;
                        end if;
                    when t_ctrl_write =>
                        s_ctrl_busy <= '1';
                        s_func_start <= '0';
                        o_tile_start <= (others => '0');
                        s_ctrl_count <= s_ctrl_count + 1;

                        -- Consumed all ibufs
                        if s_ctrl_count + 1 = kernel_size**2 * input_channels - 1 then -- + 1, because FSM goes to t_ctrl_start at NEXT cycle
                            s_ctrl_state <= t_ctrl_start;
                        end if;

                        if s_rd_addr = crossbar_size - 1 then -- Iterated over a complete RD buffer
                            s_rd_addr <= 0; -- Reset the addr
                            if o_rd_write_enable(n_tiles - 1) = '1' then -- Set write enable back to beginning (should never happen)
                                o_rd_write_enable <= (others => '0');
                                o_rd_write_enable(col_split_tiles - 1 downto 0) <= (col_split_tiles - 1 downto 0 => '1');
                            else -- Shift left the RD write enable signal
                                o_rd_write_enable <= o_rd_write_enable sll col_split_tiles;
                            end if;
                        else -- Count addr up
                            s_rd_addr <= s_rd_addr + 1;
                        end if;
                    when t_ctrl_start => -- Try to start tiles
                        s_func_start <= '1';
                        s_ctrl_busy <= '0';
                        s_ctrl_count <= 0;
                        s_rd_addr <= 0;
                        o_rd_write_enable <= (others => '0');
                        o_tile_start <= (others => '1');
                        if i_tiles_done = (n_tiles - 1 downto 0 => '0') then -- Poll 'busy' signal of tiles
                            s_ctrl_state <= t_ctrl_idle;
                        end if;
                end case;
            end if;
        end if;
    end process;
end behavioral;