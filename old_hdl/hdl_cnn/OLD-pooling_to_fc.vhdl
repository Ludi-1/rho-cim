-- OLD: DONT USE
library ieee;
use ieee.std_logic_1164.all;
use IEEE.math_real.all;
use ieee.numeric_std.all;

use work.cnn_package.all;

entity pooling_to_fc is
    generic(
        channels: integer := 5;

        kernel_size: integer := 3; -- 5x5 kernel size of pooling
        image_size: integer := 28; -- 28x28 image
        datatype_size: integer := 8 -- datatype size input
    );
    port (
        i_clk : in std_logic;
        i_rst: in std_logic;

        i_write_enable: in std_logic_vector(channels - 1 downto 0);
        o_ibuf_full: out std_logic_vector(channels - 1 downto 0);
        i_ibuf_data: in std_logic_vector(datatype_size * channels - 1 downto 0); -- Input data for input buffers

        i_next_ibuf_full: in std_logic_vector(channels - 1 downto 0); -- Next layer FIFO ibuf full
        i_start: in std_logic; -- Start consuming input buffer
        i_next_layer_busy: in std_logic; -- Next layer busy signal
        o_layer_busy: out std_logic; -- This Layer busy
        o_write_enable: out std_logic_vector(channels - 1 downto 0); -- Write data to next layer
        o_data: out std_logic_vector(datatype_size * channels - 1 downto 0); -- Data to the next layer
        o_start: out std_logic
    );
end pooling_to_fc;

architecture behavioral of pooling_to_fc is

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
        o_data: out std_logic_vector(datatype_size * kernel_size**2 - 1 downto 0)
    );
end component;

component p2fc_fifo is
    generic(
        datatype_size: integer := 8;
        image_size: integer := 28 -- mnist 28x28 image
    );
    port (
        i_clk : in std_logic;
        i_rst: in std_logic;

        i_write_enable: in std_logic;
        o_ibuf_full: out std_logic;
        i_data: in std_logic_vector(datatype_size - 1 downto 0);
        o_data: out std_logic_vector(datatype_size * image_size**2 - 1 downto 0)
    );
end component;

    signal s_layer_busy: std_logic;
    signal s_write_enable: std_logic_vector(channels - 1 downto 0);
    signal s_ibuf_data: data_array(channels - 1 downto 0)(datatype_size*kernel_size**2 - 1 downto 0);
    signal s_pooled_data: data_array(channels - 1 downto 0)(datatype_size - 1 downto 0);
    signal s_fifo_mem: data_array(channels - 1 downto 0)(datatype_size*image_size**2 - 1 downto 0);

begin

    o_layer_busy <= i_next_layer_busy or s_layer_busy;
    o_write_enable <= s_write_enable;

    g_ibuf: for input_channel in 0 to channels - 1 generate
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
                o_data => s_ibuf_data(input_channel)
            );
    end generate;

    pooling_proc: process(all) is
        variable v_max_value: data_array(channels - 1 downto 0)(datatype_size - 1 downto 0);
    begin
        for input_channel in 0 to channels - 1 loop

            -- Perform max pooling on ibuf of this layer
            v_max_value(input_channel) := (others => '0');
            for kernel_idx in 0 to kernel_size**2 - 1 loop
                if signed(s_ibuf_data(input_channel)((kernel_idx+1)*datatype_size - 1 downto kernel_idx*datatype_size)) > signed(v_max_value(input_channel)) then
                    v_max_value(input_channel) :=
                        s_ibuf_data(input_channel)((kernel_idx+1)*datatype_size - 1 downto kernel_idx*datatype_size);
                end if;
            end loop;

            -- Route max pooling value to ibuf of next layer
            o_data((input_channel + 1)*datatype_size - 1 downto input_channel*datatype_size)
                <= v_max_value(input_channel);
        end loop;
    end process;

    g_p2fc_fifo: for input_channel in 0 to channels - 1 generate
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
                o_data => s_ibuf_data(input_channel)
            );
    end generate;

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

                        if s_ctrl_count = kernel_size**2 * input_channels - 1 then -- Consumed all ibufs
                            s_ctrl_state <= t_ctrl_start;
                        else
                            s_ctrl_count <= s_ctrl_count + 1;
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