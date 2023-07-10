library ieee;
use ieee.std_logic_1164.all;
use IEEE.math_real.all;
use ieee.numeric_std.all;

entity mlp_m is
    generic(
        tile_rows: integer := 512; -- Row length per tile
        tile_columns: integer := 512; -- Column length per tile
        addr_rd_size: integer := integer(ceil(log2(real(tile_rows))));

        -- Input layer
        input_size: integer := 784; -- Input layer
        ibuf_addr_size: integer := integer(ceil(log2(real(input_size)))); -- addr size input buffer
        max_datatype_size: integer := 16; -- (d+d) + log2(R)
        out_buf_datatype_size: integer := 41; -- (d+d) + log2(R)
        -- func_datatype_size: integer := 1;
        -- row_split_tiles: integer := integer(ceil(real(input_size)/real(tile_rows))); -- Row (inputs) split up in i tiles
        -- col_split_tiles: integer := integer(ceil(real(input_size)*real(max_datatype_size)/real(tile_columns))); -- Column (neurons) split up in j tiles
        -- n_tiles: integer := integer(real(row_split_tiles*col_split_tiles)); -- Tile count layer 1

        -- L1
        neuron_size1: integer := 1000; -- Number of neurons layer 1 (* 2 for BNN) -- 1500 -> 3000
        -- max_datatype_size_l1: integer := 1;
        -- out_buf_datatype_size_l1: integer := 10; -- (d) + log2(R)
        addr_out_buf_size: integer := integer(ceil(log2(real(tile_columns)/real(max_datatype_size)))); -- Bit length output buf addr
        func_datatype_size_l1: integer := 1;
        row_split_tiles: integer := integer(ceil(real(input_size)/real(tile_rows))); -- Row (inputs) split up in i tiles
        col_split_tiles: integer := integer(ceil(real(neuron_size1)*real(max_datatype_size)/real(tile_columns))); -- Column (neurons) split up in j tiles
        n_tiles1: integer := integer(real(row_split_tiles*col_split_tiles)); -- Tile count layer 1

        -- L2
        neuron_size2: integer := 1000; -- Layer 2 neuron count - 1000 -> 2000
        max_datatype_size_l2: integer := 1;
        func_datatype_size_l2: integer := 1;
        out_buf_datatype_size_l2: integer := 10; -- (d) + log2(R)
        addr_out_buf_size_l2: integer := integer(ceil(log2(real(tile_columns)/real(max_datatype_size_l2)))); 
        addr_in_buf_size_l2: integer := integer(ceil(log2(real(neuron_size1))));
        row_split_tiles2: integer := integer(ceil(real(neuron_size1)/real(tile_rows))); -- Row (inputs) split up in i tiles
        col_split_tiles2: integer := integer(ceil(real(neuron_size2)*real(max_datatype_size_l2)/real(tile_columns))); -- Column (neurons) split up in j tiles
        n_tiles2: integer := integer(real(row_split_tiles2*col_split_tiles2)); -- Tile count layer 2

        -- L3
        neuron_size3: integer := 500; -- Layer 3 neuron count - 500 -> 1000
        max_datatype_size_l3: integer := max_datatype_size_l2; -- 1
        out_buf_datatype_size_l3: integer := out_buf_datatype_size_l2; -- 10
        func_datatype_size_l3: integer := func_datatype_size_l2;
        addr_out_buf_size_l3: integer := integer(ceil(log2(real(tile_columns)/real(max_datatype_size_l3)))); 
        addr_in_buf_size_l3: integer := integer(ceil(log2(real(neuron_size2))));
        row_split_tiles3: integer := integer(ceil(real(neuron_size2)/real(tile_rows))); -- Row (inputs) split up in i tiles
        col_split_tiles3: integer := integer(ceil(real(neuron_size3)*real(max_datatype_size_l3)/real(tile_columns))); -- Column (neurons) split up in j tiles
        n_tiles3: integer := integer(real(row_split_tiles3*col_split_tiles3)); -- Tile count layer 2

        -- L4
        neuron_size4: integer := 20; -- Layer 4 neuron count - 10 -> 20
        max_datatype_size_l4: integer := max_datatype_size_l2; -- 1
        out_buf_datatype_size_l4: integer := out_buf_datatype_size_l2; -- 10
        func_datatype_size_l4: integer := func_datatype_size_l2;
        addr_out_buf_size_l4: integer := integer(ceil(log2(real(tile_columns)/real(max_datatype_size_l4)))); 
        addr_in_buf_size_l4: integer := integer(ceil(log2(real(neuron_size3))));
        row_split_tiles4: integer := integer(ceil(real(neuron_size3)/real(tile_rows))); -- Row (inputs) split up in i tiles
        col_split_tiles4: integer := integer(ceil(real(neuron_size4)*real(max_datatype_size_l3)/real(tile_columns))); -- Column (neurons) split up in j tiles
        n_tiles4: integer := integer(real(row_split_tiles4*col_split_tiles4)); -- Tile count layer 2

        -- Output
        addr_in_buf_size: integer := integer(ceil(log2(real(neuron_size4)))) -- addr size ibuf of last layer
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
        i_done: in std_logic_vector(n_tiles1 - 1 downto 0); -- Done signal from all tiles + functional unit

        -- -- Func: Data signals
        i_tile_data: in std_logic_vector(out_buf_datatype_size * n_tiles1 - 1 downto 0);
        o_addr_out_buf: out std_logic_vector(addr_out_buf_size - 1 downto 0); -- Output buf addr per tile

        ---
        -- LAYER 2
        ---

        -- Tiles
        -- -- Ctrl: Control signals
        o_tiles_start2: out std_logic_vector(n_tiles2 - 1 downto 0); -- Start signal to CIM Tiles
        i_tiles_ready2: in std_logic_vector(n_tiles2 - 1 downto 0); -- Busy signal from CIM Tiles

        -- -- Ctrl: Data signals
        o_addr_rd_buf2: out std_logic_vector(addr_rd_size * n_tiles2 - 1 downto 0); -- RD addr per tile
        o_rd_enable2: out std_logic_vector(n_tiles2 - 1 downto 0); -- Enable rd buf addr
        o_data2: out std_logic_vector(max_datatype_size_l2 * n_tiles2 - 1 downto 0); -- Data per tile

        -- -- Func: Control signals
        i_done2: in std_logic_vector(n_tiles2 - 1 downto 0); -- Done signal from all tiles + functional unit

        -- -- Func: Data signals
        i_tile_data2: in std_logic_vector(out_buf_datatype_size_l2 * n_tiles2 - 1 downto 0);
        o_addr_out_buf2: out std_logic_vector(addr_out_buf_size_l2 - 1 downto 0); -- Output buf addr per tile

        ---
        -- LAYER 3
        ---

        -- Tiles
        -- -- Ctrl: Control signals
        o_tiles_start3: out std_logic_vector(n_tiles3 - 1 downto 0); -- Start signal to CIM Tiles
        i_tiles_ready3: in std_logic_vector(n_tiles3 - 1 downto 0); -- Busy signal from CIM Tiles

        -- -- Ctrl: Data signals
        o_addr_rd_buf3: out std_logic_vector(addr_rd_size * n_tiles3 - 1 downto 0); -- RD addr per tile
        o_rd_enable3: out std_logic_vector(n_tiles3 - 1 downto 0); -- Enable rd buf addr
        o_data3: out std_logic_vector(max_datatype_size_l3 * n_tiles3 - 1 downto 0); -- Data per tile

        -- -- Func: Control signals
        i_done3: in std_logic_vector(n_tiles3 - 1 downto 0); -- Done signal from all tiles + functional unit

        -- -- Func: Data signals
        i_tile_data3: in std_logic_vector(out_buf_datatype_size_l3 * n_tiles3 - 1 downto 0);
        o_addr_out_buf3: out std_logic_vector(addr_out_buf_size_l3 - 1 downto 0); -- Output buf addr per tile

        ---
        -- LAYER 4
        ---

        -- Tiles
        -- -- Ctrl: Control signals
        o_tiles_start4: out std_logic_vector(n_tiles4 - 1 downto 0); -- Start signal to CIM Tiles
        i_tiles_ready4: in std_logic_vector(n_tiles4 - 1 downto 0); -- Busy signal from CIM Tiles

        -- -- Ctrl: Data signals
        o_addr_rd_buf4: out std_logic_vector(addr_rd_size * n_tiles4 - 1 downto 0); -- RD addr per tile
        o_rd_enable4: out std_logic_vector(n_tiles4 - 1 downto 0); -- Enable rd buf addr
        o_data4: out std_logic_vector(max_datatype_size_l4 * n_tiles4 - 1 downto 0); -- Data per tile

        -- -- Func: Control signals
        i_done4: in std_logic_vector(n_tiles4 - 1 downto 0); -- Done signal from all tiles + functional unit

        -- -- Func: Data signals
        i_tile_data4: in std_logic_vector(out_buf_datatype_size_l4 * n_tiles4 - 1 downto 0);
        o_addr_out_buf4: out std_logic_vector(addr_out_buf_size_l4 - 1 downto 0); -- Output buf addr per tile

        ---
        -- OUTPUT
        ---

        o_next_layer_start: out std_logic; -- Next layer control start || TODO: set on 1 after act. unit
        i_next_layer_busy: in std_logic; -- Next layer control busy if 1 || TODO: Don't write ibuf if 1

        o_data_next_layer: out std_logic_vector(func_datatype_size_l4 - 1 downto 0); -- Output data next layer
        o_addr_next_layer: out std_logic_vector(addr_in_buf_size - 1 downto 0);
        o_write_enable: out std_logic -- Write enable for inbuf of next layer
    );
end mlp_m;

architecture behavioural of mlp_m is

component layer is
    generic(
        neuron_size: integer := 1500; -- Number of neurons
        input_size: integer := 784;
        max_datatype_size: integer := 8; -- (d+d) + log2(R)
        out_buf_datatype_size: integer := 25; -- (d+d) + log2(R)
        func_datatype_size: integer := 25;
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

        o_data_next_layer: out std_logic_vector(func_datatype_size - 1 downto 0); -- Output data next layer
        o_addr_next_layer: out std_logic_vector(addr_in_buf_size - 1 downto 0);
        o_write_enable: out std_logic -- Write enable for inbuf of next layer
    );
end component;

    signal s_l1_start_l2, s_l2_start_l3, s_l3_start_l4: std_logic;
    signal s_l2_busy, s_l3_busy, s_l4_busy: std_logic;
    signal s_l1_data_l2: std_logic_vector(func_datatype_size_l1 - 1 downto 0);
    signal s_l1_addr_l2: std_logic_vector(addr_in_buf_size_l2 - 1 downto 0);
    signal s_l2_write_enable, s_l3_write_enable, s_l4_write_enable: std_logic;

    -- signal s_l3_write_enable: std_logic;
    signal s_l2_addr_l3: std_logic_vector(addr_in_buf_size_l3 - 1 downto 0);
    signal s_l2_data_l3: std_logic_vector(func_datatype_size_l3 - 1 downto 0);

    signal s_l3_addr_l4: std_logic_vector(addr_in_buf_size_l4 - 1 downto 0);
    signal s_l3_data_l4: std_logic_vector(func_datatype_size_l4 - 1 downto 0);

begin
    layer1: layer generic map(
        neuron_size => neuron_size1,
        input_size => input_size,
        max_datatype_size => max_datatype_size,
        out_buf_datatype_size => out_buf_datatype_size,
        func_datatype_size => func_datatype_size_l1,
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
        max_datatype_size => max_datatype_size_l2,
        out_buf_datatype_size => out_buf_datatype_size_l2,
        func_datatype_size => func_datatype_size_l2,
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
        o_tiles_start => o_tiles_start2,
        i_tiles_ready => i_tiles_ready2,
        o_addr_rd_buf => o_addr_rd_buf2,
        o_rd_enable => o_rd_enable2,
        o_data => o_data2,
        i_done => i_done2,
        i_tile_data => i_tile_data2,
        o_addr_out_buf => o_addr_out_buf2,

        o_next_layer_start => s_l2_start_l3,
        i_next_layer_busy => s_l3_busy,
        o_data_next_layer => s_l2_data_l3,
        o_addr_next_layer => s_l2_addr_l3,
        o_write_enable => s_l3_write_enable
    );

    layer3: layer generic map(
        neuron_size => neuron_size3,
        input_size => neuron_size2,
        max_datatype_size => max_datatype_size_l3,
        out_buf_datatype_size => out_buf_datatype_size_l3,
        func_datatype_size => func_datatype_size_l3,
        tile_rows => tile_rows,
        tile_columns => tile_columns
    ) port map(
        i_clk => i_clk,
        i_rst => i_rst,

        i_write_enable => s_l3_write_enable,
        i_write_addr => s_l2_addr_l3,
        i_data => s_l2_data_l3,

        i_ctrl_start => s_l2_start_l3,
        o_ctrl_busy => s_l3_busy,
        o_tiles_start => o_tiles_start3,
        i_tiles_ready => i_tiles_ready3,
        o_addr_rd_buf => o_addr_rd_buf3,
        o_rd_enable => o_rd_enable3,
        o_data => o_data3,
        i_done => i_done3,
        i_tile_data => i_tile_data3,
        o_addr_out_buf => o_addr_out_buf3,

        o_next_layer_start => s_l3_start_l4,
        i_next_layer_busy => s_l4_busy,
        o_data_next_layer => s_l3_data_l4,
        o_addr_next_layer => s_l3_addr_l4,
        o_write_enable => s_l4_write_enable
    );

    layer4: layer generic map(
        neuron_size => neuron_size4,
        input_size => neuron_size3,
        max_datatype_size => max_datatype_size_l4,
        out_buf_datatype_size => out_buf_datatype_size_l4,
        func_datatype_size => func_datatype_size_l4,
        tile_rows => tile_rows,
        tile_columns => tile_columns
    ) port map(
        i_clk => i_clk,
        i_rst => i_rst,

        i_write_enable => s_l4_write_enable,
        i_write_addr => s_l3_addr_l4,
        i_data => s_l3_data_l4,

        i_ctrl_start => s_l3_start_l4,
        o_ctrl_busy => s_l4_busy,
        o_tiles_start => o_tiles_start4,
        i_tiles_ready => i_tiles_ready4,
        o_addr_rd_buf => o_addr_rd_buf4,
        o_rd_enable => o_rd_enable4,
        o_data => o_data4,
        i_done => i_done4,
        i_tile_data => i_tile_data4,
        o_addr_out_buf => o_addr_out_buf4,

        o_next_layer_start => o_next_layer_start,
        i_next_layer_busy => i_next_layer_busy,
        o_data_next_layer => o_data_next_layer,
        o_addr_next_layer => o_addr_next_layer,
        o_write_enable => o_write_enable
    );

end behavioural;