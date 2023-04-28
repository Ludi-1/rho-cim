library ieee;
use ieee.std_logic_1164.all;
use IEEE.math_real.all;
use ieee.numeric_std.all;

entity func is
    generic(
        input_size: integer := 784;
        neuron_size: integer := 1500; -- Number of neurons
        max_datatype_size: integer := 32; -- (d+d) + log2(R)
        tile_rows: integer := 512; -- Row length per tile
        tile_columns: integer := 512; -- Column length per tile
        row_split_tiles: integer := integer(ceil(real(input_size)/real(tile_rows))); -- Row (inputs) split up in i tiles
        col_split_tiles: integer := integer(ceil(real(neuron_size)/real(tile_columns))); -- Column (neurons) split up in j tiles
        n_tiles: integer := integer(real(row_split_tiles*col_split_tiles)); -- Amount (n) of tiles
        count_vec_size: integer := integer(ceil(log2(real(tile_columns))));

        addr_out_buf_size: integer := integer(ceil(log2(real(tile_columns)))) -- Bit length output buf addr
    );
    port(
        i_clk: in std_logic;
        i_rst: in std_logic;

        i_data: in std_logic_vector(max_datatype_size * n_tiles - 1 downto 0); -- Input data
        o_data: in std_logic_vector(max_datatype_size - 1 downto 0); -- Output data
        o_addr_out_buf: out std_logic_vector(addr_out_buf_size - 1 downto 0); -- Output buf addr per tile
        o_out_buf_enable: out std_logic_vector(n_tiles - 1 downto 0); -- Enable output buf addr

        i_control: in std_logic; -- Next layer control busy if 1 || TODO: Don't write ibuf if 1
        o_control: out std_logic; -- Next layer control start || TODO: set on 1 after act. unit
        i_done: in std_logic_vector(n_tiles - 1 downto 0); -- Done signal from all tiles + functional unit
        o_busy: out std_logic; -- Busy consuming obuf + act unit?
    );
end func;

architecture behavioural of func is
    signal s_obuf_count: natural range neuron_size - 1 downto 0;
    signal s_obuf_addr: natural range tile_columns - 1 downto 0;
    type obuf_enable_state is (s_obuf_rst, s_obuf_cnt);
    signal s_obuf_enable: obuf_enable_state;

begin

    o_addr_out_buf <= std_logic_vector(to_unsigned(s_obuf_addr, addr_out_buf_size));

    -- Output buffer consume process
    obuf_count_proc: process(all) is
    begin
        if rising_edge(i_clk) then
            if i_rst = '1' then
                s_obuf_count <= 0;
                s_obuf_addr <= 0;
                s_obuf_enable <= s_obuf_rst;
                o_out_buf_enable <= (n_tiles - 1 downto 0 => '0');
                o_busy <= 0;
            else
                case s_obuf_enable is
                    when s_obuf_rst =>
                        s_obuf_count <= 0;
                        s_obuf_addr <= 0;
                        if i_done = (n_tiles - 1 downto 0 => '1') then
                            o_busy <= '1';
                            s_obuf_enable <= s_obuf_cnt;
                            o_out_buf_enable(row_split_tiles - 1 downto 0) <= (row_split_tiles - 1 downto 0 => '1');
                        else
                            o_busy <= '0';
                            s_obuf_enable <= s_obuf_rst;
                            o_out_buf_enable <= (n_tiles - 1 downto 0 => '0');
                        end if;
                    when s_obuf_cnt =>
                        if s_obuf_addr = tile_columns - 1 then
                            o_busy <= '1';
                            s_obuf_count <= s_obuf_count + 1;
                            s_obuf_addr <= 0;
                            if o_out_buf_enable(n_tiles - 1 downto n_tiles - row_split_tiles) = (row_split_tiles - 1 downto 0 => '1') then
                                s_obuf_enable <= s_obuf_rst;
                            else
                                o_out_buf_enable <= o_out_buf_enable sll row_split_tiles;
                            end if;
                        elsif s_obuf_count = neuron_size - 1 then
                            s_obuf_count <= 0;
                            s_obuf_addr <= 0;
                            o_out_buf_enable <= (n_tiles - 1 downto 0 => '0');
                            -- TODO
                            -- if next layer control not busy
                            --     s_obuf_enable <= s_obuf_rst;
                            --     o_busy <= '1';
                            --     -- start write next ibuf
                            -- -- else
                            -- s_obuf_enable <= s_obuf_rst;
                            -- o_busy <= '1';
                        else
                            o_busy <= '1';
                            o_out_buf_enable <= o_out_buf_enable;
                            s_obuf_count <= s_obuf_count + 1;
                            s_obuf_addr <= s_obuf_addr + 1;
                        end if;
                end case;
            end if;
        end if;
    end process;
end behavioural;