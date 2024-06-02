module fc_layer #(
    parameter INPUT_NEURONS = 4096,
    parameter OUTPUT_NEURONS = 10,
    parameter XBAR_SIZE = 512, // CIM tile xbar dimension
    parameter DATA_SIZE = 8, // datatype size of weights
    parameter BUS_WIDTH = 16, // CIM tile bus width
    parameter OBUF_BUS_WIDTH = 46,
    parameter OBUF_DATA_SIZE = (DATA_SIZE == 1) ? $clog2(XBAR_SIZE) : 2*DATA_SIZE+$clog2(XBAR_SIZE),
    parameter NUM_CHANNELS = $rtoi($floor(OBUF_BUS_WIDTH / OBUF_DATA_SIZE)), // elements read in parallel
    parameter FIFO_LENGTH = $rtoi($ceil($floor(XBAR_SIZE / DATA_SIZE) / NUM_CHANNELS)), // output elements per CIM tile
    parameter H_CIM_TILES_IN = $rtoi($ceil(INPUT_NEURONS / FIFO_LENGTH)), // PREV Layer H cim tiles
    parameter V_CIM_TILES = $rtoi($ceil(INPUT_NEURONS / XBAR_SIZE)), // THIS layer V cim tiles
    parameter NUM_ADDR = $rtoi($ceil(FIFO_LENGTH*H_CIM_TILES_IN / (BUS_WIDTH * V_CIM_TILES))),
    parameter H_CIM_TILES = $rtoi($ceil(OUTPUT_NEURONS*DATA_SIZE/XBAR_SIZE)), // THIS LAYER H cim tiles
    parameter ELEMENTS_PER_TILE = $rtoi($floor(XBAR_SIZE / DATA_SIZE)), // num elements in output buffer
    parameter NUM_ADDR_OBUF = $rtoi($ceil(ELEMENTS_PER_TILE / NUM_CHANNELS)) // num addresses for obuf
) (
    input clk,
    input rst,

    // prev layer
    input i_ibuf_we,
    input [DATA_SIZE-1:0] i_ibuf_wr_data [H_CIM_TILES_IN-1:0][NUM_CHANNELS-1:0],
    input i_start, // filling ibuf done -> start ctrl
    output reg o_ready, // ctrl ready consuming -> dont write to ibuf

    // CIM interface
    input i_cim_ready, // CIM tiles ready -> w8 until done
    output reg [BUS_WIDTH*V_CIM_TILES-1:0] o_cim_data,
    output o_cim_we,
    output reg [$clog2(NUM_ADDR)-1:0] o_cim_rd_addr,
    input logic [OBUF_DATA_SIZE-1:0] i_cim_data [H_CIM_TILES-1:0][NUM_CHANNELS-1:0][V_CIM_TILES-1:0],
    output reg [$clog2(NUM_ADDR_OBUF)-1:0] o_cim_obuf_addr,

    // Next layer
    input i_next_ready, // ctrl of next layer ready
    output [DATA_SIZE-1:0] o_next_data [H_CIM_TILES-1:0][NUM_CHANNELS-1:0], // CIM Output buffer data
    output o_next_we,
    output o_next_start
);

wire func_ready;
wire func_start;
wire s_se;

fc_ibuf #(
    .DATA_SIZE(DATA_SIZE),
    .INPUT_NEURONS(INPUT_NEURONS),
    .OUTPUT_NEURONS(OUTPUT_NEURONS),
    .XBAR_SIZE(XBAR_SIZE),
    .BUS_WIDTH(BUS_WIDTH),
    .OBUF_BUS_WIDTH(OBUF_BUS_WIDTH)
) ibuf (
    .clk(clk),
    .i_we(i_ibuf_we),
    .i_se(s_se),
    .i_ibuf_addr(o_cim_wr_addr),
    .i_data(i_ibuf_wr_data),
    .o_data(o_cim_data)
);

// Instantiate ctrl module
fc_ctrl #(
    .DATA_SIZE(DATA_SIZE),
    .INPUT_NEURONS(INPUT_NEURONS),
    .XBAR_SIZE(XBAR_SIZE),
    .BUS_WIDTH(BUS_WIDTH),
    .OBUF_BUS_WIDTH(OBUF_BUS_WIDTH)
) ctrl (
    .clk(clk),
    .rst(rst),
    .o_shift_enable(s_se),
    .i_start(i_start),
    .o_ready(o_ready),
    .i_cim_ready(i_cim_ready),
    .o_cim_we(o_cim_we),
    .o_addr(o_cim_rd_addr),
    .i_func_ready(func_ready),
    .o_func_start(func_start)
);

fc_func #(
    .DATA_SIZE(DATA_SIZE),
    .INPUT_NEURONS(INPUT_NEURONS),
    .OUTPUT_NEURONS(OUTPUT_NEURONS),
    .XBAR_SIZE(XBAR_SIZE),
    .OBUF_BUS_WIDTH(OBUF_BUS_WIDTH)
) func (
    .clk(clk),
    .rst(rst),
    .i_start(func_start),
    .i_cim_ready(i_cim_ready),
    .i_data(i_cim_data),
    .o_addr(o_cim_obuf_addr),
    .o_data(o_next_data),
    .o_write_enable(o_next_we),
    .i_next_ready(i_next_ready),
    .o_start(o_next_start)
);

endmodule