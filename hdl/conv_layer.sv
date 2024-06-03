module conv_layer #(
    parameter DATA_SIZE = 8,
    parameter IMG_DIM = 28,
    parameter KERNEL_DIM = 3,
    parameter INPUT_CHANNELS = 2,
    parameter XBAR_SIZE = 128,
    parameter BUS_WIDTH = 16,
    parameter OUTPUT_CHANNELS = 4,
    parameter OBUF_BUS_WIDTH = 46,
    parameter COUNT_WIDTH = (DATA_SIZE==1) ? 1 : $clog2(DATA_SIZE),
    parameter V_CIM_TILES = (INPUT_CHANNELS*KERNEL_DIM**2+XBAR_SIZE-1) / XBAR_SIZE, // THIS layer V cim tiles
    parameter NUM_ADDR = $rtoi($ceil(INPUT_CHANNELS*KERNEL_DIM**2 / (BUS_WIDTH * V_CIM_TILES))),
    parameter ADDR_WIDTH = (NUM_ADDR <= 1) ? 1 : $clog2(NUM_ADDR),
    parameter OBUF_DATA_SIZE = (DATA_SIZE == 1) ? $clog2(XBAR_SIZE) : 2*DATA_SIZE+$clog2(XBAR_SIZE),
    parameter H_CIM_TILES = (OUTPUT_CHANNELS * DATA_SIZE + XBAR_SIZE - 1) / XBAR_SIZE, // THIS layer H cim tiles
    parameter ELEMENTS_PER_TILE = $rtoi($floor(XBAR_SIZE / DATA_SIZE)), // num elements in output buffer
    parameter NUM_CHANNELS = $rtoi($floor(OBUF_BUS_WIDTH / OBUF_DATA_SIZE)), // elements read in parallel
    parameter NUM_ADDR_OBUF = $rtoi($ceil(ELEMENTS_PER_TILE / NUM_CHANNELS)) // num addresses for obuf
) (
    input clk,
    input rst,

    input [INPUT_CHANNELS-1:0] i_ibuf_we,
    input [DATA_SIZE-1:0] i_ibuf_wr_data [INPUT_CHANNELS-1:0],
    output o_ready,
    input i_start,

    output [BUS_WIDTH*V_CIM_TILES-1:0] o_cim_rd_data,
    input i_cim_ready,
    output o_cim_we,
    output o_cim_start,
    output [ADDR_WIDTH-1:0] o_cim_rd_addr, // addr to CIM and ibuf
    input [OBUF_DATA_SIZE-1:0] i_cim_obuf_data [H_CIM_TILES-1:0][NUM_CHANNELS-1:0][V_CIM_TILES-1:0],
    output reg [$clog2(NUM_ADDR_OBUF)-1:0] o_cim_obuf_addr,

    // Next module interface
    input i_next_ready,
    output reg [DATA_SIZE-1:0] o_next_data [OUTPUT_CHANNELS-1:0],
    output reg [OUTPUT_CHANNELS-1:0] o_next_we,
    output o_next_start

);

wire func_ready;
wire func_start;
wire [COUNT_WIDTH-1:0] ibuf_count;

conv_ibuf #(
    .DATA_SIZE(DATA_SIZE),
    .IMG_DIM(IMG_DIM),
    .KERNEL_DIM(KERNEL_DIM),
    .INPUT_CHANNELS(INPUT_CHANNELS),
    .XBAR_SIZE(XBAR_SIZE),
    .BUS_WIDTH(BUS_WIDTH)
) ibuf (
    .clk(clk),
    .i_count(ibuf_count),
    .i_write_enable(i_ibuf_we),
    .i_data(i_ibuf_wr_data),
    .o_data(o_cim_rd_data),
    .i_ibuf_addr(o_cim_rd_addr)
);

// Instantiate ctrl module
conv_ctrl #(
    .DATA_SIZE(DATA_SIZE),
    .INPUT_CHANNELS(INPUT_CHANNELS),
    .KERNEL_DIM(KERNEL_DIM),
    .XBAR_SIZE(XBAR_SIZE),
    .BUS_WIDTH(BUS_WIDTH)
) ctrl (
    .clk(clk),
    .rst(rst),
    .o_count(ibuf_count),
    .i_start(i_start),
    .o_ready(o_ready),
    .i_cim_ready(i_cim_ready),
    .o_cim_we(o_cim_we),
    .o_cim_start(o_cim_start),
    .o_addr(o_cim_rd_addr),
    .i_func_ready(func_ready),
    .o_func_start(func_start)
);

conv_func #(
    .DATA_SIZE(DATA_SIZE),
    .INPUT_CHANNELS(INPUT_CHANNELS),
    .KERNEL_DIM(KERNEL_DIM),
    .OUTPUT_CHANNELS(OUTPUT_CHANNELS),
    .XBAR_SIZE(XBAR_SIZE),
    .OBUF_BUS_WIDTH(OBUF_BUS_WIDTH)
) func (
    .clk(clk),
    .rst(rst),
    .i_start(func_start),
    .o_ready(func_ready),
    .i_cim_ready(i_cim_ready),
    .i_data(i_cim_obuf_data),
    .o_addr(o_cim_obuf_addr),
    .o_data(o_next_data),
    .o_write_enable(o_next_we),
    .i_next_ready(i_next_ready),
    .o_start(o_next_start)
);

endmodule