library ieee;
use ieee.std_logic_1164.all;
use IEEE.math_real.all;
use ieee.numeric_std.all;

entity top is
    generic(
        max_datatype_size: integer := 8; -- (d+d) + log2(R)
        out_buf_datatype_size: integer := 25; -- (d+d) + log2(R)
        tile_rows: integer := 512; -- Row length per tile
        tile_columns: integer := 512; -- Column length per tile

        addr_out_buf_size: integer := integer(ceil(log2(real(tile_columns)/real(max_datatype_size)))); -- Bit length output buf addr
        addr_rd_size: integer := integer(ceil(log2(real(tile_rows))));

        -- Input
        input_size: integer := 784; -- Input layer
        ibuf_addr_size: integer := integer(ceil(log2(real(input_size)))); -- addr size input buffer

        -- L1
        neuron_size1: integer := 1500; -- Number of neurons layer 1
        row_split_tiles: integer := integer(ceil(real(input_size)/real(tile_rows))); -- Row (inputs) split up in i tiles
        col_split_tiles: integer := integer(ceil(real(neuron_size1)/real(tile_columns))); -- Column (neurons) split up in j tiles
        n_tiles1: integer := integer(real(row_split_tiles1*col_split_tiles1)); -- Tile count layer 1

        -- L2
        neuron_size2: integer := 1000; -- Layer 2 neuron count
        addr_in_buf_size_l2: integer := integer(ceil(log2(real(neuron_size1))));
        row_split_tiles2: integer := integer(ceil(real(neuron_size1)/real(tile_rows))); -- Row (inputs) split up in i tiles
        col_split_tiles2: integer := integer(ceil(real(neuron_size2)/real(tile_columns))); -- Column (neurons) split up in j tiles
        n_tiles2: integer := integer(real(row_split_tiles2*col_split_tiles2)); -- Tile count layer 2

        neuron_size3: integer := 500; -- Layer 3 neuron count
        neuron_size4: integer := 10; -- Layer 4 neuron count

        -- Output
        addr_in_buf_size: integer := integer(ceil(log2(real(neuron_size2)))) -- addr size ibuf of last layer
    );
    port(
        i_clk: in std_logic;
        i_rst: in std_logic;

        ---
        -- LAYER 1
        ---

        -- Input
        i_write_enable: in std_logic; -- Write enable
        i_write_addr: in std_logic_vector(ibuf_addr_size - 1 downto 0); -- Write addr of ibuf
        i_data: in std_logic_vector(max_datatype_size - 1 downto 0); -- Data from func unit of layer before

        -- -- Control
        i_ctrl_start: in std_logic; -- Start consuming input buffer
        o_ctrl_busy: out std_logic; -- Busy consuming input buffer

        -- Tiles
        -- -- Ctrl: Control signals
        o_tiles_start: out std_logic_vector(n_tiles1 - 1 downto 0); -- Start signal to CIM Tiles
        i_tiles_ready: in std_logic_vector(n_tiles1 - 1 downto 0); -- Busy signal from CIM Tiles

        -- -- Ctrl: Data signals
        o_addr_rd_buf: out std_logic_vector(addr_rd_size * n_tiles1 - 1 downto 0); -- RD addr per tile
        o_rd_enable: out std_logic_vector(n_tiles1 - 1 downto 0); -- Enable rd buf addr
        o_data: out std_logic_vector(max_datatype_size * n_tiles1 - 1 downto 0); -- Data per tile

        -- -- Func: Control signals
        i_done: in std_logic_vector(n_tiles - 1 downto 0); -- Done signal from all tiles + functional unit

        -- -- Func: Data signals
        i_tile_data: in std_logic_vector(out_buf_datatype_size * n_tiles1 - 1 downto 0);
        o_addr_out_buf: out std_logic_vector(addr_out_buf_size - 1 downto 0); -- Output buf addr per tile

        ---
        -- LAYER 2
        ---

        -- Tiles
        -- -- Ctrl: Control signals
        o_tiles_start2: out std_logic_vector(n_tiles1 - 1 downto 0); -- Start signal to CIM Tiles
        i_tiles_ready2: in std_logic_vector(n_tiles1 - 1 downto 0); -- Busy signal from CIM Tiles

        -- -- Ctrl: Data signals
        o_addr_rd_buf2: out std_logic_vector(addr_rd_size * n_tiles1 - 1 downto 0); -- RD addr per tile
        o_rd_enable2: out std_logic_vector(n_tiles1 - 1 downto 0); -- Enable rd buf addr
        o_data2: out std_logic_vector(max_datatype_size * n_tiles1 - 1 downto 0); -- Data per tile

        -- -- Func: Control signals
        i_done2: in std_logic_vector(n_tiles - 1 downto 0); -- Done signal from all tiles + functional unit

        -- -- Func: Data signals
        i_tile_data2: in std_logic_vector(out_buf_datatype_size * n_tiles1 - 1 downto 0);
        o_addr_out_buf2: out std_logic_vector(addr_out_buf_size - 1 downto 0); -- Output buf addr per tile

        ---
        -- OUTPUT
        ---

        o_next_layer_start: out std_logic; -- Next layer control start || TODO: set on 1 after act. unit
        i_next_layer_busy: in std_logic; -- Next layer control busy if 1 || TODO: Don't write ibuf if 1

        o_data_next_layer: in std_logic_vector(max_datatype_size - 1 downto 0); -- Output data next layer
        o_addr_next_layer: out std_logic_vector(addr_in_buf_size - 1 downto 0);
        o_write_enable: out std_logic -- Write enable for inbuf of next layer
    );
end top;

architecture behavioural of top is

component layer is
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
end component;

    signal s_l1_start_l2: std_logic;
    signal s_l2_busy: std_logic;
    signal s_l1_data_l2: std_logic_vector(max_datatype_size - 1 downto 0);
    signal s_l1_addr_l2: std_logic_vector(addr_in_buf_size_l2 - 1 downto 0);
    signal s_l2_write_enable: std_logic;

begin
    layer1: layer generic map(
        neuron_size => neuron_size1,
        input_size => input_size,
        max_datatype_size => max_datatype_size,
        out_buf_datatype_size => out_buf_datatype_size,
        tile_rows => tile_rows,
        tile_columns => tile_columns
    ) port map(
        i_clk => i_clk,
        i_rst => i_rst,

        i_write_enable => i_write_enable,
        i_write_addr => i_write_addr,
        i_data => i_data,

        i_ctrl_start => i_ctrl_start,
        o_ctrl_busy => o_ctrl_busy,
        o_tiles_start => o_tiles_start,
        i_tiles_ready => i_tiles_ready,
        o_addr_rd_buf => o_addr_rd_buf,
        o_rd_enable => o_rd_enable,
        o_data => o_data,
        i_done => i_done,
        i_tile_data => i_tile_data,
        o_addr_out_buf => o_addr_out_buf,

        o_next_layer_start => s_l1_start_l2,
        i_next_layer_busy => s_l2_busy,
        o_data_next_layer => s_l1_data_l2,
        o_addr_next_layer => s_l1_addr_l2,
        o_write_enable => s_l2_write_enable
    );

    layer2: layer generic map(
        neuron_size => neuron_size2,
        input_size => neuron_size1,
        max_datatype_size => max_datatype_size,
        out_buf_datatype_size => out_buf_datatype_size,
        tile_rows => tile_rows,
        tile_columns => tile_columns
    ) port map(
        i_clk => i_clk,
        i_rst => i_rst,

        i_write_enable => s_l2_write_enable,
        i_write_addr => s_l1_addr_l2,
        i_data => s_l1_data_l2,

        i_ctrl_start => s_l1_start_l2,
        o_ctrl_busy => s_l2_busy,
        o_tiles_start => o_tiles_start,
        i_tiles_ready => i_tiles_ready,
        o_addr_rd_buf => o_addr_rd_buf,
        o_rd_enable => o_rd_enable,
        o_data => o_data,
        i_done => i_done,
        i_tile_data => i_tile_data,
        o_addr_out_buf => o_addr_out_buf,

        o_next_layer_start => o_next_layer_start,
        i_next_layer_busy => i_next_layer_busy,
        o_data_next_layer => o_data_next_layer,
        o_addr_next_layer => o_addr_next_layer,
        o_write_enable => o_write_enable
    );
end behavioural;