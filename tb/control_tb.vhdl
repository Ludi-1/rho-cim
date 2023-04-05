-- FC(784) - FC(1500) - FC(1000) - FC(500) - FC(10)
-- 784 inputs into 1500 neurons
-- ceil(784/512) * ceil(1500/512) = 2*3 = 6 tiles

library ieee;
use ieee.std_logic_1164.all;
use IEEE.math_real.all;
use std.env.stop;

entity control_tb is
end control_tb;

architecture behavioural of control_tb is

    constant clk_period: time := 2 ns;
    constant input_size: integer := 784;
    constant layer_neurons: integer := 1500;
    constant max_datatype_size: integer := 32;
    constant tile_rows: integer := 512;
    constant tile_columns: integer := 512;
    constant row_split_tiles: integer := integer(ceil(real(input_size)/real(tile_rows)));
    constant col_split_tiles: integer := integer(ceil(real(layer_neurons)/real(tile_columns)));
    constant n_tiles: integer := integer(row_split_tiles*col_split_tiles);
    constant max_address_size: integer := 8;
    constant addr_rd_size: integer := integer(ceil(log2(real(n_tiles * tile_rows))));
    constant addr_out_buf_size: integer := integer(ceil(log2(real(n_tiles * tile_rows))));

    component control
        generic(
            input_size: integer;
            max_datatype_size: integer; -- Amount of bits datatype size
            tile_rows: integer; -- Row length per tile
            tile_columns: integer; -- Column length per tile
            row_split_tiles: integer; -- Row (inputs) split up in i tiles
            col_split_tiles: integer; -- Column (neurons) split up in j tiles
            n_tiles: integer := integer(real(row_split_tiles * col_split_tiles)); -- Amount (n) of tiles
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
    end component;

    signal i_clk: std_logic := '1';
    signal i_rst: std_logic;
    signal i_data: std_logic_vector(max_datatype_size - 1 downto 0);
    signal i_control: std_logic;
    signal o_control: std_logic;
    signal o_data: std_logic_vector(max_datatype_size * n_tiles - 1 downto 0);
    signal o_addr_rd_buf: std_logic_vector(addr_rd_size * n_tiles - 1 downto 0);
    signal o_addr_out_buf: std_logic_vector(addr_out_buf_size * n_tiles - 1 downto 0);
    signal o_start: std_logic_vector(n_tiles - 1 downto 0);
    signal i_done: std_logic_vector(n_tiles - 1 downto 0);
    signal o_rd_enable: std_logic_vector(n_tiles - 1 downto 0);
    signal o_out_buf_enable: std_logic_vector(n_tiles - 1 downto 0);

begin

    dut: control generic map(
        max_datatype_size => max_datatype_size,
        n_tiles => n_tiles,
        tile_rows => tile_rows,
        tile_columns => tile_columns,
        input_size => input_size,
        row_split_tiles => row_split_tiles,
        col_split_tiles => col_split_tiles
    ) port map (
        i_clk => i_clk,
        i_rst => i_rst,
        i_data => i_data,
        i_control => i_control,
        o_control => o_control,
        o_data => o_data,
        o_addr_rd_buf => o_addr_rd_buf,
        o_addr_out_buf => o_addr_out_buf,
        o_start => o_start,
        i_done => i_done,
        o_rd_enable => o_rd_enable,
        o_out_buf_enable => o_out_buf_enable
    );

    i_clk <= NOT i_clk after clk_period/2;
	i_rst <= '0',
	    '1' after 2 ns,
		'0' after 4 ns;
    i_control <= '1' after 4 ns;
    i_data <= x"A1B1C1D1";

    stop_process: process
    begin
        wait for 10000 ns;
        report "Calling 'finish'";
        stop;
        wait;
    end process;

end behavioural;