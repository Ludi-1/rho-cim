-- Functional unit for fully connected layer of CNN implementation
library ieee;
use ieee.std_logic_1164.all;
use IEEE.math_real.all;
use ieee.numeric_std.all;

use work.cnn_package.all;

entity fc_func is
    generic(
        inputs: integer := 5; -- num of inputs (for RD buf)
        neurons: integer := 10; -- num of outputs (for output buf)
        datatype_size: integer := 8; -- datatype size input
        crossbar_size: integer := 512; -- RxR Crossbar size
        obuf_datatype_size: integer := 25; -- 2d + log2(R) = 2*8+9
        func_datatype_size: integer := 1;
        row_split_tiles: integer := integer(ceil(real(inputs)/real(crossbar_size)));
        col_split_tiles: integer := integer(ceil(real(neurons)*real(datatype_size)/real(crossbar_size)));
        n_tiles: integer := integer(real(row_split_tiles*col_split_tiles));
        obuf_addr_max: integer := integer(ceil(real(crossbar_size)/real(datatype_size))); -- Amount of entries output buffer
        addr_out_buf_size: integer := integer(ceil(log2(real(obuf_addr_max)))) -- Addr size output buffer
    );
    port (
        i_clk : in std_logic;
        i_rst: in std_logic;
        
        i_tiles_done: in std_logic_vector(n_tiles - 1 downto 0); -- Done signal from tiles
        i_data: in std_logic_vector(obuf_datatype_size * n_tiles - 1 downto 0); -- Data from output buffer tiles
        o_tile_addr: out std_logic_vector(addr_out_buf_size - 1 downto 0); -- Address for CIM tile output buffers

        i_next_ibuf_full: in std_logic;
        i_start: in std_logic; -- Start signal for CIM tiles of this layer
        i_next_layer_busy: in std_logic; -- Next layer busy signal
        o_func_busy: out std_logic; -- Functional unit busy
        o_write_enable: out std_logic; -- Write data to next layer
        o_data: out std_logic_vector(func_datatype_size - 1 downto 0); -- Data to the next layer
        o_start: out std_logic -- Start CIM tiles of next layer
    );
end fc_func;

architecture behavioral of fc_func is
    signal s_obuf_count: natural range neurons - 1 downto 0;
    signal s_obuf_addr: natural range obuf_addr_max - 1 downto 0;
    signal s_vert_tile_count: natural range col_split_tiles - 1 downto 0;
    signal sum_s: signed(obuf_datatype_size - 1 downto 0);

    type func_state is (s_func_idle, s_func_poll, s_func_write, s_func_start); 
    signal s_func_state: func_state;

begin

    o_tile_addr <= std_logic_vector(to_unsigned(s_obuf_addr, addr_out_buf_size));

    data_sum_proc: process(all) is
        variable sum_v	: signed(obuf_datatype_size - 1 downto 0);
        variable data_v : std_logic_vector(obuf_datatype_size - 1 downto 0);
    begin
        sum_v := to_signed(0, obuf_datatype_size);
        for vertical_tile_set in 0 to row_split_tiles - 1 loop -- accumulate
            sum_v := sum_v + signed(
                i_data(obuf_datatype_size * (vertical_tile_set + 1 + (s_vert_tile_count * row_split_tiles)) - 1 downto 
                    obuf_datatype_size * (vertical_tile_set + s_vert_tile_count * row_split_tiles)) );
        end loop;
        sum_s <= shift_right(sum_v, 1) - inputs;
        if sum_s > 2**func_datatype_size - 1 then -- Sign function
            o_data <= (others => '1');
        elsif sum_s <= 0 then
            o_data <= (others => '0');
        else
            data_v := std_logic_vector(sum_s);
            o_data <= data_v(func_datatype_size - 1 downto 0);
        end if;
    end process;

    data_proc: process(all)
    begin

        if rising_edge(i_clk) then
            if i_rst = '1' then
                s_func_state <= s_func_idle;
                o_write_enable <= '0';
                o_func_busy <= '0';
                s_obuf_count <= 0;
                s_obuf_addr <= 0;
                s_vert_tile_count <= 0;
                o_start <= '0';
            else
                case s_func_state is
                    when s_func_idle =>
                        o_write_enable <= '0';
                        o_func_busy <= '0';
                        s_obuf_count <= 0;
                        s_obuf_addr <= 0;
                        s_vert_tile_count <= 0;
                        o_start <= '0';

                        if i_start = '1' then
                            o_func_busy <= '1';
                            s_func_state <= s_func_poll;
                        end if;

                    when s_func_poll => -- Poll for done signals of tiles
                        o_write_enable <= '0';
                        o_func_busy <= '1';
                        s_obuf_count <= 0;
                        s_obuf_addr <= 0;
                        s_vert_tile_count <= 0;
                        o_start <= '0';

                        if i_tiles_done = (n_tiles - 1 downto 0 => '1') and i_next_layer_busy = '0' then
                            s_func_state <= s_func_write;
                        end if;

                    when s_func_write => -- Try to send data, iterate over all channels
                        o_write_enable <= '1';
                        o_func_busy <= '1';
                        o_start <= '0';

                        if s_obuf_count = neurons - 1 then -- Done consuming obuf once for all channels
                            if i_next_ibuf_full = '1' then -- All ibufs full
                                s_func_state <= s_func_start; -- Done writing all channels, activate next layer
                            else
                                s_func_state <= s_func_idle; -- Next layer ibufs not full, dont start
                            end if;
                        else -- Write data
                            s_obuf_count <= s_obuf_count + 1;
                            if s_obuf_addr = obuf_addr_max - 1 then
                                s_obuf_addr <= 0;
                                if s_vert_tile_count < col_split_tiles - 1 then
                                    s_vert_tile_count <= s_vert_tile_count + 1;
                                else
                                    s_vert_tile_count <= 0;
                                end if;
                            else
                                s_obuf_addr <= s_obuf_addr + 1;
                            end if;
                        end if;

                    when s_func_start => -- Increment address, and wait till not busy
                        o_write_enable <= '0';
                        o_func_busy <= '1';
                        s_obuf_count <= 0;
                        s_obuf_addr <= 0;
                        s_vert_tile_count <= 0;
                        o_start <= '1';

                        if i_next_layer_busy <= '1' then
                            s_func_state <= s_func_idle;
                        end if;
                end case;
            end if;
        end if;

    end process data_proc;

end behavioral;