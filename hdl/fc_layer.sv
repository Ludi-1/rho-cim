module fc_layer #(
    parameter input_size = 500,
    parameter output_size = 10,
    parameter xbar_size = 512,
    parameter datatype_size = 8,
    parameter output_datatype_size = 8,
    parameter v_cim_tiles = (input_size + xbar_size - 1) / xbar_size, // ceiled division
    parameter h_cim_tiles = (output_size*datatype_size + xbar_size - 1) / xbar_size // ceiled division
) (
    input clk,
    input rst,

    input i_ibuf_we,
    input [datatype_size-1:0] i_ibuf_wr_data,
    input reg [$clog2(input_size)-1:0] i_ibuf_addr,
    input i_start,
    input i_cim_busy,
    input i_func_start,
    output reg o_busy, // ctrl busy
    output reg [$clog2(xbar_size)-1:0] o_cim_wr_addr,
    output reg [datatype_size-1:0] o_cim_data [v_cim_tiles-1:0],

    input i_next_busy,
    input [datatype_size-1:0] i_data [v_cim_tiles-1:0][h_cim_tiles-1:0], // CIM Output buffer data
    output reg [$clog2(xbar_size)-1:0] o_cim_rd_addr,
    output reg [output_datatype_size-1:0] o_func_data
);

logic [$clog2(input_size)-1:0] ibuf_rd_addr;
logic [datatype_size-1:0] ibuf_rd_data;
logic func_busy;

fc_ibuf #(
    .DATA_WIDTH(datatype_size),
    .num_inputs(input_size)
) ibuf (
    .clk(clk),
    .we(i_ibuf_we),
    .rd_addr(ibuf_rd_addr),
    .wr_addr(i_ibuf_addr),
    .d_in(i_ibuf_wr_data), // From prev layer func to ibuf
    .d_out(ibuf_rd_data) // From ibuf to ctrl of this layer
);

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