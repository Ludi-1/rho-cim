-- MLP functional unit
library ieee;
use ieee.std_logic_1164.all;
use IEEE.math_real.all;
use ieee.numeric_std.all;

entity func is
    generic(
        input_size: integer := 784;
        neuron_size: integer := 500; -- Number of neurons
        max_datatype_size: integer := 8; -- (d+d) + log2(R)
        out_buf_datatype_size: integer := 25; -- (d+d) + log2(R)
        func_datatype_size: integer := 8;
        tile_rows: integer := 128; -- Row length per tile
        tile_columns: integer := 128; -- Column length per tile
        row_split_tiles: integer := integer(ceil(real(input_size)/real(tile_rows))); -- Row (inputs) split up in i tiles
        col_split_tiles: integer := integer(ceil(real(neuron_size)*real(max_datatype_size)/real(tile_columns))); -- Column (neurons) split up in j tiles
        n_tiles: integer := integer(real(row_split_tiles*col_split_tiles)); -- Amount (n) of tiles
        addr_in_buf_size: integer := integer(ceil(log2(real(neuron_size)))); -- Addr size of inbuf from next layer
        obuf_addr_max: integer := integer(ceil(real(tile_columns)/real(max_datatype_size)));
        addr_out_buf_size: integer := integer(ceil(log2(real(obuf_addr_max)))) -- Bit length output buf addr
    );
    port(
        i_clk: in std_logic;
        i_rst: in std_logic;

        i_data: in std_logic_vector(out_buf_datatype_size * n_tiles - 1 downto 0); -- Input data
        o_addr_out_buf: out std_logic_vector(addr_out_buf_size - 1 downto 0); -- Output buf addr per tile
        o_data: out std_logic_vector(func_datatype_size - 1 downto 0); -- Output data
        o_write_enable: out std_logic; -- Write enable for inbuf of next layer
        o_addr_inbuf: out std_logic_vector(addr_in_buf_size - 1 downto 0);

        i_done: in std_logic_vector(n_tiles - 1 downto 0); -- Done signal from all tiles + functional unit
        o_busy: out std_logic; -- Busy consuming obuf + act unit?
        o_next_layer_start: out std_logic; -- Next layer control start || TODO: set on 1 after act. unit
        i_next_layer_busy: in std_logic -- Next layer control busy if 1 || TODO: Don't write ibuf if 1
    );
end func;

architecture behavioural of func is
    signal s_obuf_count: natural range neuron_size - 1 downto 0;
    signal s_obuf_addr: natural range obuf_addr_max - 1 downto 0;
    signal s_vert_tile_count : natural range col_split_tiles - 1 downto 0;
    signal sum_s: signed(out_buf_datatype_size - 1 downto 0);
    type obuf_enable_state is (s_obuf_rst, s_obuf_recv, s_obuf_cnt);
    signal s_obuf_enable: obuf_enable_state;

begin

    o_addr_out_buf <= std_logic_vector(to_unsigned(s_obuf_addr, addr_out_buf_size));
    o_addr_inbuf <= std_logic_vector(to_unsigned(s_obuf_count, addr_in_buf_size));

    o_data_sum: process(all) is
        variable sum_v	: signed(out_buf_datatype_size - 1 downto 0);
        variable data_v : std_logic_vector(out_buf_datatype_size - 1 downto 0);
    begin
        sum_v := to_signed(0, out_buf_datatype_size);
        for vertical_tile_set in 0 to row_split_tiles - 1 loop -- accumulate
            sum_v := sum_v + signed(
                i_data(out_buf_datatype_size * (vertical_tile_set + 1 + (s_vert_tile_count * row_split_tiles)) - 1 downto 
                    out_buf_datatype_size * (vertical_tile_set + s_vert_tile_count * row_split_tiles)) );
        end loop;
        sum_s <= shift_right(sum_v, 1) - input_size;
        if sum_s > 2**func_datatype_size - 1 then -- Sign function
            o_data <= (others => '1');
        elsif sum_s <= 0 then
            o_data <= (others => '0');
        else
            data_v := std_logic_vector(sum_s);
            o_data <= data_v(func_datatype_size - 1 downto 0);
        end if;
    end process;

    -- Output buffer consume process
    obuf_count_proc: process(all) is
    begin
        if rising_edge(i_clk) then
            if i_rst = '1' then
                s_obuf_count <= 0;
                s_obuf_addr <= 0;
                s_obuf_enable <= s_obuf_rst;
                o_busy <= '0';
                o_next_layer_start <= '0';
                o_write_enable <= '0';
                s_vert_tile_count <= 0;
            else
                case s_obuf_enable is
                    when s_obuf_rst => -- Idle
                        o_next_layer_start <= '0';
                        s_obuf_count <= 0;
                        s_obuf_addr <= 0;
                        o_write_enable <= '0';
                        o_busy <= '0';
                        s_vert_tile_count <= 0;
                        -- Done signal recv, next layer not busy
                        if i_done = (n_tiles - 1 downto 0 => '1') and i_next_layer_busy <= '0' then
                            s_obuf_enable <= s_obuf_cnt;
                        else
                            s_obuf_enable <= s_obuf_rst;
                        end if;
                    when s_obuf_cnt => -- Consuming output buffer
                        o_next_layer_start <= '0';
                        o_busy <= '1';
                        if s_obuf_addr = obuf_addr_max - 1 then
                            s_obuf_count <= s_obuf_count + 1;
                            s_obuf_addr <= 0;
                            o_write_enable <= '1';
                            if s_vert_tile_count < col_split_tiles - 1 then
                                s_vert_tile_count <= s_vert_tile_count + 1;
                            else
                                s_vert_tile_count <= 0;
                            end if;
                        elsif s_obuf_count = neuron_size - 1 then
                            s_obuf_count <= s_obuf_count;
                            s_obuf_addr <= 0;
                            o_write_enable <= '0';
                            s_vert_tile_count <= 0;
                            if i_next_layer_busy = '0' then
                                s_obuf_enable <= s_obuf_recv;
                            else
                                s_obuf_enable <= s_obuf_cnt;
                            end if;
                        else
                            s_vert_tile_count <= s_vert_tile_count;
                            o_write_enable <= '1';
                            s_obuf_count <= s_obuf_count + 1;
                            s_obuf_addr <= s_obuf_addr + 1;
                        end if;
                    when s_obuf_recv => -- Activate next layer
                        s_vert_tile_count <= 0;
                        s_obuf_count <= 0;
                        s_obuf_addr <= 0;
                        o_write_enable <= '0';
                        o_busy <= '0';
                        o_next_layer_start <= '1';
                        if i_next_layer_busy = '1' then
                            s_obuf_enable <= s_obuf_rst;
                        else
                            s_obuf_enable <= s_obuf_recv;
                        end if;
                end case;
            end if;
        end if;
    end process;
end behavioural;