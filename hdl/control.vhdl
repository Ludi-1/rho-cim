library ieee;
use ieee.std_logic_1164.all;
use IEEE.math_real.all;
use ieee.numeric_std.all;

entity control is
    generic(
            input_size: integer;
            max_datatype_size: integer; -- Amount of bits datatype size
            tile_rows: integer; -- Row length per tile
            tile_columns: integer; -- Column length per tile
            row_split_tiles: integer; -- Row (inputs) split up in i tiles
            col_split_tiles: integer; -- Column (neurons) split up in j tiles
            n_tiles: integer := integer(real(row_split_tiles*col_split_tiles)); -- Amount (n) of tiles
            addr_rd_size: integer := integer(ceil(log2(real(n_tiles * tile_rows)))); -- Bit length of rd buf addr
            addr_out_buf_size: integer := integer(ceil(log2(real(n_tiles * tile_rows)))) -- Bit length output buf addr
    );
    port(
        i_clk: in std_logic;
        i_rst: in std_logic;

        i_data: in std_logic_vector(max_datatype_size - 1 downto 0); -- Input data
        i_control: in std_logic; -- Input control: Input buffer full, control consume data
        o_control: out std_logic; -- Output control: Input buffer empty, control ready
        
        o_data: out std_logic_vector(max_datatype_size * n_tiles - 1 downto 0); -- Data per tile
        o_addr_rd_buf: out std_logic_vector(addr_rd_size * n_tiles - 1 downto 0); -- RD addr per tile
        o_addr_out_buf: out std_logic_vector(addr_out_buf_size * n_tiles - 1 downto 0); -- Output buf addr per tile
        o_start: out std_logic_vector(n_tiles - 1 downto 0); -- Start signal to all tiles 
        i_done: in std_logic_vector(n_tiles - 1 downto 0); -- Done signal from all tiles
        o_rd_enable: out std_logic_vector(n_tiles - 1 downto 0); -- Enable rd buf addr
        o_out_buf_enable: out std_logic_vector(n_tiles - 1 downto 0) -- Enable output buf addr
    );
end control;

architecture behavioural of control is
    signal s_rd_count: natural range input_size - 1 downto 0;
    signal s_rd_addr: natural range tile_rows - 1 downto 0;
    type rd_enable_state is (s_rd_rst, s_rd_cnt);
    signal s_rd_enable: rd_enable_state;

begin

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
                o_control <= '1';
            else
                o_control <= '0';
                case s_rd_enable is
                    when s_rd_rst =>
                        s_rd_count <= 0;
                        s_rd_addr <= 0;
                        if i_control = '1' then
                            s_rd_enable <= s_rd_cnt;
                            o_rd_enable(col_split_tiles - 1 downto 0) <= (col_split_tiles - 1 downto 0 => '1');
                        else
                            s_rd_enable <= s_rd_rst;
                            o_rd_enable <= (n_tiles - 1 downto 0 => '0');
                        end if;
                        o_start <= (n_tiles - 1 downto 0 => '0');
                    when s_rd_cnt =>
                        if s_rd_count = tile_rows - 1 then
                            s_rd_count <= s_rd_count + 1;
                            s_rd_addr <= 0;
                            o_start <= (n_tiles - 1 downto 0 => '0');
                            if o_rd_enable(n_tiles - 1 downto n_tiles - col_split_tiles) = (col_split_tiles - 1 downto 0 => '1') then
                                s_rd_enable <= s_rd_rst;
                            else
                                o_rd_enable <= o_rd_enable sll col_split_tiles;
                            end if;
                        elsif s_rd_count = input_size - 1 then
                            s_rd_count <= 0;
                            s_rd_addr <= 0;
                            s_rd_enable <= s_rd_rst;
                            o_rd_enable <= (n_tiles - 1 downto 0 => '0');
                            o_start <= (n_tiles - 1 downto 0 => '1');
                        else
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