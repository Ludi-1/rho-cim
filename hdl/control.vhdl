library ieee;
use ieee.std_logic_1164.all;
use IEEE.math_real.all;
use ieee.numeric_std.all;

entity control is
    generic(
        neuron_size: integer := 1500;
        input_size: integer := 784;
        max_datatype_size: integer := 32; -- Amount of bits datatype size
        tile_rows: integer := 512; -- Row length per tile
        tile_columns: integer := 512; -- Column length per tile
        row_split_tiles: integer := integer(ceil(real(input_size)/real(tile_rows))); -- Row (inputs) split up in i tiles
        col_split_tiles: integer := integer(ceil(real(neuron_size)/real(tile_columns))); -- Column (neurons) split up in j tiles
        n_tiles: integer := integer(real(row_split_tiles*col_split_tiles)); -- Amount (n) of tiles
        count_vec_size: integer := integer(ceil(log2(real(input_size))));
        addr_rd_size: integer := integer(ceil(log2(real(tile_rows)))) -- Bit length of rd buf addr
    );
    port(
        i_clk: in std_logic;
        i_rst: in std_logic;

        -- Ctrl: Control signals
        i_control: in std_logic; -- Control: Start consume
        o_control: out std_logic; -- Control: Busy if 1
        o_start: out std_logic_vector(n_tiles - 1 downto 0); -- Start CIM tiles
        i_tiles_busy: in std_logic_vector(n_tiles - 1 downto 0); -- CIM tiles: busy
        i_func_busy: in std_logic; -- Func: Busy

        -- Ctrl: Data signals
        i_data: in std_logic_vector(max_datatype_size - 1 downto 0); -- Input data
        o_data: out std_logic_vector(max_datatype_size * n_tiles - 1 downto 0); -- Data per tile
        o_addr_rd_buf: out std_logic_vector(addr_rd_size * n_tiles - 1 downto 0); -- RD addr per tile
        o_rd_enable: out std_logic_vector(n_tiles - 1 downto 0); -- Enable rd buf addr 
        o_inbuf_count: out std_logic_vector(count_vec_size - 1 downto 0)
    );
end control;

architecture behavioural of control is
    signal s_rd_count: natural range input_size - 1 downto 0;
    signal s_rd_addr: natural range tile_rows - 1 downto 0;
    type rd_enable_state is (s_rd_rst, s_rd_cnt);
    signal s_rd_enable: rd_enable_state;

begin
    o_inbuf_count <= std_logic_vector(to_unsigned(s_rd_count, count_vec_size));
    rd_data_copy_proc: process(i_data, s_rd_addr) is
    begin
        data_loop: for tile_index in 1 to n_tiles loop
            o_data(tile_index * max_datatype_size - 1 downto (tile_index - 1) * max_datatype_size) <= i_data;
            o_addr_rd_buf(tile_index * addr_rd_size - 1 downto (tile_index - 1) * addr_rd_size) <= std_logic_vector(to_unsigned(s_rd_addr, addr_rd_size));
        end loop;
    end process;

    rd_count_proc: process(all) is
    begin
        if rising_edge(i_clk) then
            if i_rst = '1' then
                s_rd_count <= 0;
                s_rd_addr <= 0;
                o_rd_enable <= (n_tiles - 1 downto 0 => '0');
                s_rd_enable <= s_rd_rst;
                o_start <= (n_tiles - 1 downto 0 => '0');
                o_control <= '0';
            else
                case s_rd_enable is
                    when s_rd_rst =>
                        s_rd_count <= 0;
                        s_rd_addr <= 0;
                        if i_control = '1' and i_tiles_busy = (n_tiles - 1 downto 0 => '0') then
                            s_rd_enable <= s_rd_cnt;
                            o_rd_enable(col_split_tiles - 1 downto 0) <= (col_split_tiles - 1 downto 0 => '1');
                            o_control <= '1';
                        else
                            o_control <= '0';
                            s_rd_enable <= s_rd_rst;
                            o_rd_enable <= (n_tiles - 1 downto 0 => '0');
                        end if;
                        o_start <= (n_tiles - 1 downto 0 => '0');
                    when s_rd_cnt =>
                        if s_rd_addr = tile_rows - 1 then
                            o_control <= '1';
                            s_rd_count <= s_rd_count + 1;
                            s_rd_addr <= 0;
                            if o_rd_enable(n_tiles - 1 downto n_tiles - col_split_tiles) = (col_split_tiles - 1 downto 0 => '1') then
                                s_rd_enable <= s_rd_rst;
                            else
                                o_rd_enable <= o_rd_enable sll col_split_tiles;
                            end if;
                        elsif s_rd_count = input_size - 1 then
                            o_control <= '1';
                            s_rd_count <= s_rd_count;
                            s_rd_addr <= 0;
                            o_rd_enable <= (n_tiles - 1 downto 0 => '0');
                            if i_func_busy = '0' then
                                o_start <= (n_tiles - 1 downto 0 => '1');
                            else 
                                o_start <= (n_tiles - 1 downto 0 => '0');
                            end if;
                            if i_tiles_busy = (n_tiles - 1 downto 0 => '1') then
                                s_rd_enable <= s_rd_rst;
                            else
                                s_rd_enable <= s_rd_cnt;
                            end if;
                        else
                            o_control <= '1';
                            o_rd_enable <= o_rd_enable;
                            s_rd_count <= s_rd_count + 1;
                            s_rd_addr <= s_rd_addr + 1;
                            s_rd_enable <= s_rd_enable;
                            o_start <= (n_tiles - 1 downto 0 => '0');
                        end if;
                end case;                        
            end if;
        end if;
    end process;

end behavioural;