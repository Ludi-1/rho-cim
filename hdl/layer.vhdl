library ieee;
use ieee.std_logic_1164.all;
use IEEE.math_real.all;
use ieee.numeric_std.all;

entity layer is
    generic(
        neuron_size: integer := 1500; -- Number of neurons
        input_size: integer := 784;
        max_datatype_size: integer := 32; -- (d+d) + log2(R)
        tile_rows: integer := 512; -- Row length per tile
        tile_columns: integer := 512; -- Column length per tile
        row_split_tiles: integer := integer(ceil(real(input_size)/real(tile_rows))); -- Row (inputs) split up in i tiles
        col_split_tiles: integer := integer(ceil(real(neuron_size)/real(tile_columns))); -- Column (neurons) split up in j tiles
        n_tiles: integer := integer(real(row_split_tiles*col_split_tiles)); -- Amount (n) of tiles
        count_vec_size: integer := integer(ceil(log2(real(tile_columns))));
        addr_out_buf_size: integer := integer(ceil(log2(real(tile_columns)))); -- Bit length output buf addr
        ibuf_addr_size: integer := integer(ceil(log2(real(input_size))));
        addr_rd_size: integer := integer(ceil(log2(real(tile_rows))))
    );
    port(
        i_clk: in std_logic;
        i_rst: in std_logic;

        -- Ibuf
        i_write_enable: in std_logic; -- Write enable
        i_write_addr: in std_logic_vector(ibuf_addr_size - 1 downto 0); -- Write addr of ibuf
        i_data: in std_logic_vector(max_datatype_size - 1 downto 0); -- Data from func unit of layer before

        -- Ctrl: Control signals
        i_ctrl_start: in std_logic; -- Control: Start consuming input buffer
        o_ctrl_busy: out std_logic; -- Control: Busy consuming input buffer
        o_tiles_start: out std_logic_vector(n_tiles - 1 downto 0); -- Start signal to CIM Tiles
        i_tiles_busy: in std_logic_vector(n_tiles - 1 downto 0); -- Busy signal from CIM Tiles

        -- Ctrl: Data signals
        o_addr_rd_buf: out std_logic_vector(addr_rd_size * n_tiles - 1 downto 0); -- RD addr per tile
        o_rd_enable: out std_logic_vector(n_tiles - 1 downto 0); -- Enable rd buf addr

        -- Func: Control Signals
        i_tiles_done: in std_logic_vector(n_tiles - 1 downto 0); -- Done signal from all tiles

        -- Func: Data signals
        o_data: out std_logic_vector(max_datatype_size * n_tiles - 1 downto 0) -- Data per tile
    );
end layer;

architecture behavioural of layer is

component control is
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

        i_data: in std_logic_vector(max_datatype_size - 1 downto 0); -- Input data
        o_data: out std_logic_vector(max_datatype_size * n_tiles - 1 downto 0); -- Data per tile
        i_control: in std_logic; -- Input control: Input buf full & RD buf ready -> ctrl consume data
        o_control: out std_logic; -- Output control: Input buffer empty, control ready
        
        o_addr_rd_buf: out std_logic_vector(addr_rd_size * n_tiles - 1 downto 0); -- RD addr per tile
        o_rd_enable: out std_logic_vector(n_tiles - 1 downto 0); -- Enable rd buf addr
        o_start: out std_logic_vector(n_tiles - 1 downto 0); -- Start signal to all tiles 
        i_done: in std_logic_vector(n_tiles - 1 downto 0); -- Done signal from all tiles + functional unit
        o_inbuf_count: out std_logic_vector(count_vec_size - 1 downto 0)
    );
end component;

component func is
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
        i_control: in std_logic; -- Input control: All tiles activated (DONE) = 1 -> Start consume data
        o_control: out std_logic; -- Output control: Ready to consume data (IDLE) = 0 | BUSY = 1

        o_addr_out_buf: out std_logic_vector(addr_out_buf_size - 1 downto 0); -- Output buf addr per tile
        o_out_buf_enable: out std_logic_vector(n_tiles - 1 downto 0) -- Enable output buf addr
    );
end component;

component ibuf is
    generic(
        ibuf_size: integer := 784;
        addr_size: integer := integer(ceil(log2(real(ibuf_size))));
        max_datatype_size: integer := 32
    );
    port (
        i_clk : in std_logic;
        i_write_enable : in std_logic;
        i_write_addr : in std_logic_vector(addr_size - 1 downto 0);
        i_read_addr: in std_logic_vector(addr_size - 1 downto 0);
        i_data : in std_logic_vector(max_datatype_size - 1 downto 0);
        o_data : out std_logic_vector(max_datatype_size - 1 downto 0)
    );
end component;

    signal s_ibuf_addr: std_logic_vector(ibuf_addr_size - 1 downto 0);
    signal s_ibuf_data: std_logic_vector(max_datatype_size - 1 downto 0);

begin
    ibuf1: ibuf generic map(
        ibuf_size => input_size,
        max_datatype_size => max_datatype_size
    ) port map(
        i_clk => i_clk,
        i_write_enable => i_write_enable,
        i_write_addr => i_write_addr,
        i_read_addr => s_ibuf_addr,
        i_data => i_data,
        o_data => s_ibuf_data
    );

    ctrl1: control generic map(
        input_size => input_size,
        neuron_size => neuron_size,
        max_datatype_size => max_datatype_size,
        tile_rows => tile_rows,
        tile_columns => tile_columns
    ) port map(
        i_clk => i_clk,
        i_rst => i_rst,
        i_data => s_ibuf_data,
        o_inbuf_count => s_ibuf_addr,
        i_control => i_ctrl_start,
        o_control => o_ctrl_busy,
        i_done => i_done,
        o_start => o_tiles_start
    );

    -- func1: func generic map(

    -- ) port map(

    -- )

end behavioural;