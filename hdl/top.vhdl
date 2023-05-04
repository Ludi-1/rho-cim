entity top is
    generic(
        neuron_size: integer := 1500; -- Number of neurons
        input_size: integer := 784;
        max_datatype_size: integer := 32; -- (d+d) + log2(R)
        tile_rows: integer := 512; -- Row length per tile
        tile_columns: integer := 512; -- Column length per tile
    );
    port(
        i_clk: in std_logic;
        i_rst: in std_logic;

        -- Input
        i_write_enable: in std_logic; -- Write enable
        i_write_addr: in std_logic_vector(ibuf_addr_size - 1 downto 0); -- Write addr of ibuf
        i_data: in std_logic_vector(max_datatype_size - 1 downto 0); -- Data from func unit of layer before

        -- -- Control
        i_ctrl_start: in std_logic; -- Start consuming input buffer
        o_ctrl_busy: out std_logic; -- Busy consuming input buffer

        -- Tiles
        -- -- Ctrl: Control signals
        o_tiles_start: out std_logic_vector(n_tiles - 1 downto 0); -- Start signal to CIM Tiles
        i_tiles_ready: in std_logic_vector(n_tiles - 1 downto 0); -- Busy signal from CIM Tiles

        -- -- Ctrl: Data signals
        o_addr_rd_buf: out std_logic_vector(addr_rd_size * n_tiles - 1 downto 0); -- RD addr per tile
        o_rd_enable: out std_logic_vector(n_tiles - 1 downto 0); -- Enable rd buf addr
        o_data: out std_logic_vector(max_datatype_size * n_tiles - 1 downto 0); -- Data per tile

        -- -- Func: Control signals
        i_done: in std_logic_vector(n_tiles - 1 downto 0); -- Done signal from all tiles + functional unit

        -- -- Func: Data signals
        i_tile_data: in std_logic_vector(max_datatype_size * n_tiles - 1 downto 0);
        o_addr_out_buf: out std_logic_vector(addr_out_buf_size - 1 downto 0); -- Output buf addr per tile

        -- Next layer
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
        max_datatype_size: integer := 32; -- (d+d) + log2(R)
        tile_rows: integer := 512; -- Row length per tile
        tile_columns: integer := 512; -- Column length per tile
        row_split_tiles: integer := integer(ceil(real(input_size)/real(tile_rows))); -- Row (inputs) split up in i tiles
        col_split_tiles: integer := integer(ceil(real(neuron_size)/real(tile_columns))); -- Column (neurons) split up in j tiles
        n_tiles: integer := integer(real(row_split_tiles*col_split_tiles)); -- Amount (n) of tiles
        count_vec_size: integer := integer(ceil(log2(real(tile_columns))));
        addr_out_buf_size: integer := integer(ceil(log2(real(tile_columns)))); -- Bit length output buf addr
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
        i_ctrl_start: in std_logic; -- Start consuming input buffer
        o_ctrl_busy: out std_logic; -- Busy consuming input buffer

        -- Tiles
        -- -- Ctrl: Control signals
        o_tiles_start: out std_logic_vector(n_tiles - 1 downto 0); -- Start signal to CIM Tiles
        i_tiles_ready: in std_logic_vector(n_tiles - 1 downto 0); -- Busy signal from CIM Tiles

        -- -- Ctrl: Data signals
        o_addr_rd_buf: out std_logic_vector(addr_rd_size * n_tiles - 1 downto 0); -- RD addr per tile
        o_rd_enable: out std_logic_vector(n_tiles - 1 downto 0); -- Enable rd buf addr
        -- o_data: out std_logic_vector(max_datatype_size * n_tiles - 1 downto 0); -- Data per tile

        -- -- Func: Control signals
        i_done: in std_logic_vector(n_tiles - 1 downto 0); -- Done signal from all tiles + functional unit

        -- -- Func: Data signals
        -- i_tile_data: in std_logic_vector(max_datatype_size * n_tiles - 1 downto 0);
        o_addr_out_buf: out std_logic_vector(addr_out_buf_size - 1 downto 0); -- Output buf addr per tile

        -- Next layer
        o_next_layer_start: out std_logic; -- Next layer control start || TODO: set on 1 after act. unit
        i_next_layer_busy: in std_logic; -- Next layer control busy if 1 || TODO: Don't write ibuf if 1

        o_data_next_layer: in std_logic_vector(max_datatype_size - 1 downto 0); -- Output data next layer
        o_addr_next_layer: out std_logic_vector(addr_in_buf_size - 1 downto 0);
        o_write_enable: out std_logic -- Write enable for inbuf of next layer
    );
end component;

begin
    layer1: layer generic map(
        neuron_size => neuron_size,
        input_size => input_size,
        max_datatype_size => max_datatype_size,
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
        -- o_data => o_data,
        i_done => i_done.
        i_tile_data => (max_datatype_size * n_tiles - 1 downto 0 => '1'),
        o_addr_out_buf => o_addr_out_buf,
        o_next_layer_start => o_next_layer_start,
        i_next_layer_busy => i_next_layer_busy,
        o_data_next_layer => o_data_next_layer,
        o_addr_next_layer => o_addr_next_layer,
        o_write_enable => o_write_enable
    );
end behavioural;