module fc_layer #(
    parameter INPUT_NEURONS = 4096,
    parameter OUTPUT_NEURONS = 10,
    parameter XBAR_SIZE = 512, // CIM tile xbar dimension
    parameter DATA_SIZE = 8, // datatype size of weights
    parameter BUS_WIDTH = 16, // CIM tile bus width
    parameter OBUF_DATA_SIZE = (DATA_SIZE == 1) ? $clog2(XBAR_SIZE) : 2*DATA_SIZE+$clog2(XBAR_SIZE),
    parameter FIFO_LENGTH = $rtoi($floor(XBAR_SIZE / DATA_WIDTH)), // output elements per CIM tile
    parameter H_CIM_TILES_IN = $rtoi($ceil(INPUT_NEURONS / FIFO_LENGTH)), // PREV Layer H cim tiles
    parameter V_CIM_TILES = $rtoi($ceil(INPUT_NEURONS / XBAR_SIZE)), // THIS layer V cim tiles
    parameter NUM_ADDR = $rtoi($ceil(FIFO_LENGTH*H_CIM_TILES_IN / (BUS_WIDTH * V_CIM_TILES))),

    parameter H_CIM_TILE = $rtoi($ceil(OUTPUT_NEURONS*DATA_SIZE/XBAR_SIZE)) // THIS LAYER H cim tiles
) (
    input clk,
    input rst,

    input i_ibuf_we,
    input [datatype_size-1:0] i_ibuf_wr_data,
    input i_start, // filling ibuf done -> start ctrl
    input i_cim_ready, // CIM tiles ready -> w8 until done
    output reg o_ready, // ctrl ready consuming -> dont write to ibuf
    output reg [$clog2(NUM_ADDR):0] o_cim_wr_addr, // addr to CIM tile
    output reg [BUS_WIDTH*v_cim_tiles-1:0] o_cim_data,

    input i_next_ready, // ctrl of next layer ready
    input [OBUF_DATA_SIZE-1:0] i_data [v_cim_tiles-1:0][h_cim_tiles-1:0], // CIM Output buffer data
    output reg [$clog2(xbar_size)-1:0] o_cim_rd_addr,
    output reg [output_datatype_size-1:0] o_func_data
);

logic [$clog2(input_size)-1:0] ibuf_rd_addr;
logic [datatype_size-1:0] ibuf_rd_data;
logic func_busy;

fc_ibuf #(
    .DATA_WIDTH(datatype_size),
    .INPUT_NEURONS(input_size),
    .OUTPUT_NEURONS(output_size),
    .XBAR_SIZE(xbar_size),
    .BUS_WIDTH(BUS_WIDTH),
) ibuf (
    .clk(clk),
    .i_we(i_ibuf_we),
    .i_se(s_se),
    .i_ibuf_addr(o_cim_wr_addr),
    .o_data(o_cim_data)
)

// Instantiate ctrl module
fc_ctrl #(
    .datatype_size(datatype_size),
    .input_size(input_size),
    .xbar_size(xbar_size)
) ctrl (
    .clk(clk),
    .rst(rst),
    .i_start(i_start),
    .i_cim_busy(i_cim_busy),
    .o_cim_we(o_cim_we),
    .i_func_busy(func_busy),
    .o_busy(o_busy),
    .o_ibuf_addr(ibuf_rd_addr),
    .i_data(ibuf_rd_data),
    .o_cim_addr(o_cim_wr_addr),
    .o_data(o_cim_data)
);

fc_func #(
    .input_size(input_size),
    .output_size(output_size),
    .xbar_size(xbar_size),
    .datatype_size(datatype_size),
    .output_datatype_size(output_datatype_size)
) func (
    .clk(clk),
    .rst(rst),
    .i_start(i_func_start),
    .i_cim_busy(i_cim_busy),
    .o_busy(func_busy),
    .i_next_busy(i_next_busy),
    .i_data(i_data),
    .o_cim_addr(o_cim_rd_addr),
    .o_data(o_func_data)
);

endmodule