library ieee;
use ieee.std_logic_1164.all;
use IEEE.math_real.all;

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
        i_control: in std_logic; -- Input control
        o_control: out std_logic; -- Output control
        
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
    signal s_count: integer range input_size - 1 downto 0;
    type rd_enable_state is (s_rd_rst, s_rd_cnt);
    signal s_rd_enable: rd_enable_state; 

begin

    clk_process: process(i_clk, i_rst) is
    begin
        data_loop: for tile_index in 1 to n_tiles loop
            o_data(tile_index * max_datatype_size - 1 downto (tile_index - 1) * max_datatype_size) <= i_data;
        end loop;

        if rising_edge(i_clk) then
            if i_rst = '1' then
                s_count <= 0;
                o_rd_enable <= (n_tiles - 1 downto 0 => '0');
                s_rd_enable <= s_rd_rst;
                o_start <= (n_tiles - 1 downto 0 => '0');
            else
                case s_rd_enable is
                    when s_rd_rst =>
                        s_count <= 0;
                        if i_control = '1' then
                            s_rd_enable <= s_rd_cnt;
                            o_rd_enable(col_split_tiles - 1 downto 0) <= (col_split_tiles - 1 downto 0 => '1');
                        else
                            s_rd_enable <= s_rd_rst;
                            o_rd_enable <= (n_tiles - 1 downto 0 => '0');
                        end if;
                        o_start <= (n_tiles - 1 downto 0 => '0');
                    when s_rd_cnt =>
                        if s_count = tile_rows - 1 then
                            s_count <= s_count + 1;
                            o_start <= (n_tiles - 1 downto 0 => '0');
                            if o_rd_enable(n_tiles - 1 downto n_tiles - col_split_tiles) = (col_split_tiles - 1 downto 0 => '1') then
                                s_rd_enable <= s_rd_rst;
                            else
                                o_rd_enable <= o_rd_enable sll col_split_tiles;
                            end if;
                        elsif s_count = input_size - 1 then
                            s_count <= 0;
                            s_rd_enable <= s_rd_rst;
                            o_rd_enable <= (n_tiles - 1 downto 0 => '0');
                            o_start <= (n_tiles - 1 downto 0 => '1');
                        else
                            o_rd_enable <= o_rd_enable;
                            s_count <= s_count + 1;
                            s_rd_enable <= s_rd_enable;
                            o_start <= (n_tiles - 1 downto 0 => '0');
                        end if;
                end case;                        
            end if;
        end if;

    end process;

end behavioural;