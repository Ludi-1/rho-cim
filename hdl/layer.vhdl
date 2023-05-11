library ieee;
use ieee.std_logic_1164.all;
use IEEE.math_real.all;
use ieee.numeric_std.all;

entity layer is
    generic(
        neuron_size: integer := 1500; -- Number of neurons
        input_size: integer := 784;
        max_datatype_size: integer := 8; -- (d+d) + log2(R)
        out_buf_datatype_size: integer := 25; -- (d+d) + log2(R)
        tile_rows: integer := 512; -- Row length per tile
        tile_columns: integer := 512; -- Column length per tile
        row_split_tiles: integer := integer(ceil(real(input_size)/real(tile_rows))); -- Row (inputs) split up in i tiles
        col_split_tiles: integer := integer(ceil(real(neuron_size)*real(max_datatype_size)/real(tile_columns))); -- Column (neurons) split up in j tiles
        n_tiles: integer := integer(real(row_split_tiles*col_split_tiles)); -- Amount (n) of tiles
        addr_out_buf_size: integer := integer(ceil(log2(real(tile_columns)/real(max_datatype_size)))); -- Bit length output buf addr
        ibuf_addr_size: integer := integer(ceil(log2(real(input_size)))); -- addr size input buffer
        addr_in_buf_size: integer := integer(ceil(log2(real(neuron_size)))); -- addr size ibuf of next layer
        addr_rd_size: integer := integer(ceil(log2(real(tile_rows))))
    );
    port(
        i_clk: in std_logic;
        i_rst: in std_logic;

        -- Input
        i_write_enable: in std_logic; -- Write enable
        i_write_addr: in std_logic_vector(ibuf_addr_size - 1 downto 0); -- Write addr of ibuf
        i_data: in std_logic_vector(max_datatype_size - 1 downto 0); -- Data from func unit of layer before

        -- -- Control
        -- -- Ctrl: Control signals
        i_ctrl_start: in std_logic; -- Start consuming input buffer
        o_ctrl_busy: out std_logic; -- Busy consuming input buffer
        o_tiles_start: out std_logic_vector(n_tiles - 1 downto 0); -- Start signal to CIM Tiles
        i_tiles_ready: in std_logic_vector(n_tiles - 1 downto 0); -- Busy signal from CIM Tiles

        -- -- Ctrl: Data signals
        o_addr_rd_buf: out std_logic_vector(addr_rd_size * n_tiles - 1 downto 0); -- RD addr per tile
        o_rd_enable: out std_logic_vector(n_tiles - 1 downto 0); -- Enable rd buf addr
        o_data: out std_logic_vector(max_datatype_size * n_tiles - 1 downto 0); -- Data per tile

        -- -- Func: Control signals
        i_done: in std_logic_vector(n_tiles - 1 downto 0); -- Done signal from all tiles

        -- -- Func: Data signals
        i_tile_data: in std_logic_vector(out_buf_datatype_size * n_tiles - 1 downto 0);
        o_addr_out_buf: out std_logic_vector(addr_out_buf_size - 1 downto 0); -- Output buf addr per tile

        -- Next layer
        o_next_layer_start: out std_logic; -- Next layer control start || TODO: set on 1 after act. unit
        i_next_layer_busy: in std_logic; -- Next layer control busy if 1 || TODO: Don't write ibuf if 1

        o_data_next_layer: in std_logic_vector(max_datatype_size - 1 downto 0); -- Output data next layer
        o_addr_next_layer: out std_logic_vector(addr_in_buf_size - 1 downto 0);
        o_write_enable: out std_logic -- Write enable for inbuf of next layer
    );
end layer;

architecture behavioural of layer is

component control is
    generic(
        neuron_size: integer := 1500;
        input_size: integer := 784;
        max_datatype_size: integer := 8; -- Input & Weight datatype
        tile_rows: integer := 512; -- Row length per tile
        tile_columns: integer := 512; -- Column length per tile
        row_split_tiles: integer := integer(ceil(real(input_size)/real(tile_rows))); -- Row (inputs) split up in i tiles
        col_split_tiles: integer := integer(ceil(real(neuron_size)*real(max_datatype_size)/real(tile_columns))); -- Column (neurons) split up in j tiles
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
        i_tiles_ready: in std_logic_vector(n_tiles - 1 downto 0); -- CIM tiles: busy
        i_func_busy: in std_logic; -- Func: Busy

        -- Ctrl: Data signals
        i_data: in std_logic_vector(max_datatype_size - 1 downto 0); -- Input data
        o_data: out std_logic_vector(max_datatype_size * n_tiles - 1 downto 0); -- Data per tile
        o_addr_rd_buf: out std_logic_vector(addr_rd_size * n_tiles - 1 downto 0); -- RD addr per tile
        o_rd_enable: out std_logic_vector(n_tiles - 1 downto 0); -- Enable rd buf addr 
        o_inbuf_count: out std_logic_vector(count_vec_size - 1 downto 0)
    );
end component;

component func is
    generic(
        input_size: integer := 784;
        neuron_size: integer := 1500; -- Number of neurons
        max_datatype_size: integer := 8; -- (d+d) + log2(R)
        out_buf_datatype_size: integer := 25; -- (d+d) + log2(R)
        tile_rows: integer := 512; -- Row length per tile
        tile_columns: integer := 512; -- Column length per tile
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
        o_data: in std_logic_vector(max_datatype_size - 1 downto 0); -- Output data
        o_write_enable: out std_logic; -- Write enable for inbuf of next layer
        o_addr_inbuf: out std_logic_vector(addr_in_buf_size - 1 downto 0);

        i_done: in std_logic_vector(n_tiles - 1 downto 0); -- Done signal from all tiles + functional unit
        o_busy: out std_logic; -- Busy consuming obuf + act unit?
        o_next_layer_start: out std_logic; -- Next layer control start || TODO: set on 1 after act. unit
        i_next_layer_busy: in std_logic -- Next layer control busy if 1 || TODO: Don't write ibuf if 1
    );
end component;

component ibuf is
    generic(
        ibuf_size: integer := 784;
        addr_size: integer := integer(ceil(log2(real(ibuf_size))));
        max_datatype_size: integer := 8
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
    signal s_func_busy: std_logic;

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

        i_control => i_ctrl_start,
        o_control => o_ctrl_busy,
        o_start => o_tiles_start,
        i_tiles_ready => i_tiles_ready,
        i_func_busy => s_func_busy,

        i_data => s_ibuf_data,
        o_inbuf_count => s_ibuf_addr,
        o_data => o_data,
        o_addr_rd_buf => o_addr_rd_buf,
        o_rd_enable => o_rd_enable
    );

    func1: func generic map(
        input_size => input_size,
        neuron_size => neuron_size,
        max_datatype_size => max_datatype_size,
        out_buf_datatype_size => out_buf_datatype_size,
        tile_rows => tile_rows,
        tile_columns => tile_columns
    ) port map(
        i_clk => i_clk,
        i_rst => i_rst,

        i_data => i_tile_data,
        o_addr_out_buf => o_addr_out_buf,
        o_data => o_data_next_layer,
        o_write_enable => o_write_enable,
        o_addr_inbuf => o_addr_next_layer,

        i_done => i_done,
        o_busy => s_func_busy,
        o_next_layer_start => o_next_layer_start,
        i_next_layer_busy => i_next_layer_busy
    );

end behavioural;