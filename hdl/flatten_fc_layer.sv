module flatten_fc_layer #(
    parameter DATA_SIZE = 8,
    parameter IMG_SIZE = 26,
    parameter INPUT_CHANNELS = 2,
    parameter OUTPUT_NEURONS = 4000,
    parameter XBAR_SIZE = 128,
    parameter BUS_WIDTH = 16,
    parameter OBUF_BUS_WIDTH = 48,
    parameter OBUF_DATA_SIZE = (DATA_SIZE == 1) ? $clog2(XBAR_SIZE) : 2*DATA_SIZE+$clog2(XBAR_SIZE),
    parameter V_CIM_TILES = (INPUT_CHANNELS*IMG_SIZE + XBAR_SIZE-1) / XBAR_SIZE,
    parameter H_CIM_TILES = $rtoi($ceil(OUTPUT_NEURONS * DATA_SIZE / XBAR_SIZE)), // THIS layer H cim tiles
    parameter NUM_ADDR = $rtoi($ceil(INPUT_CHANNELS*IMG_SIZE / (BUS_WIDTH * V_CIM_TILES))),
    parameter NUM_CHANNELS = $rtoi($floor(OBUF_BUS_WIDTH / OBUF_DATA_SIZE)), // elements read in parallel
    parameter ADDR_WIDTH = (NUM_ADDR <= 1) ? 1 : $clog2(NUM_ADDR),
    parameter ELEMENTS_PER_TILE = $rtoi($floor(XBAR_SIZE / DATA_SIZE)),
    parameter NUM_ADDR_OBUF = $rtoi($ceil(ELEMENTS_PER_TILE / NUM_CHANNELS)) // num addresses for obuf
) (
    input clk,
    input rst,

    input [INPUT_CHANNELS-1:0] i_ibuf_we, // Input buffer write enable
    input [DATA_SIZE-1:0] i_ibuf_data [INPUT_CHANNELS-1:0], // Input buffer data
    input i_start,
    output o_ready,

    input i_cim_ready,
    output o_cim_we,
    output o_cim_start,
    output [ADDR_WIDTH-1:0] o_cim_rd_addr,
    output [BUS_WIDTH*V_CIM_TILES-1:0] o_cim_data [DATA_SIZE-1:0], // CIM RD data
    input [OBUF_DATA_SIZE-1:0] i_cim_data [H_CIM_TILES-1:0][NUM_CHANNELS-1:0][V_CIM_TILES-1:0],
    output [$clog2(NUM_ADDR_OBUF)-1:0] o_cim_obuf_addr,

    output [DATA_SIZE-1:0] o_data [H_CIM_TILES-1:0][NUM_CHANNELS-1:0],
    output o_next_we,
    input o_next_ready,
    output o_next_start
);

localparam COUNT_WIDTH = (DATA_SIZE==1) ? 1 : $clog2(DATA_SIZE);
wire [ADDR_WIDTH-1:0] ibuf_addr;
wire [COUNT_WIDTH-1:0] bit_count;

wire func_start;

flatten_fc_ibuf #(
    .DATA_SIZE(DATA_SIZE),
    .IMG_SIZE(IMG_SIZE),
    .INPUT_CHANNELS(INPUT_CHANNELS),
    .XBAR_SIZE(XBAR_SIZE),
    .BUS_WIDTH(BUS_WIDTH)
) ibuf (
    .clk(clk),
    .i_write_enable(i_ibuf_we),
    .i_data(i_ibuf_data),
    .o_data(o_cim_data),
    .i_ibuf_addr(ibuf_addr),
    .i_count(bit_count)
);

// Instantiate ctrl module
flatten_fc_ctrl #(
    .DATA_SIZE(DATA_SIZE),
    .INPUT_CHANNELS(INPUT_CHANNELS),
    .IMG_SIZE(IMG_SIZE),
    .XBAR_SIZE(XBAR_SIZE),
    .BUS_WIDTH(BUS_WIDTH)
) ctrl (
    .clk(clk),
    .rst(rst),
    .o_count(bit_count),
    .i_start(i_start),
    .o_ready(o_ready),
    .i_cim_ready(i_cim_ready),
    .o_cim_we(o_cim_we),
    .o_cim_start(o_cim_start),
    .o_addr(o_cim_rd_addr),
    .i_func_ready(func_ready),
    .o_func_start(func_start)
);

fc_func #(
    .DATA_SIZE(DATA_SIZE),
    .INPUT_NEURONS(IMG_SIZE * INPUT_CHANNELS),
    .OUTPUT_NEURONS(OUTPUT_NEURONS)
    .XBAR_SIZE(XBAR_SIZE),
    .OBUF_BUS_WIDTH(OBUF_BUS_WIDTH)
) func (
    .clk(clk),
    .rst(rst),
    .i_start(func_start),
    .o_ready(func_ready),
    .i_cim_ready(i_cim_ready),
    .i_data(i_cim_data),
    .o_addr(o_cim_obuf_addr),
    .o_data(o_next_data),
    .o_write_enable(o_next_we),
    .i_next_ready(i_next_ready),
    .o_start(o_next_start)
);

endmodule