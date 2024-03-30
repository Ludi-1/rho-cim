module test_top #(
    parameter input_size_1 = 784,
    parameter output_size_1 = 784,
    parameter input_size_2 = 784,
    parameter output_size_2 = 1500,
    parameter xbar_size = 512,
    parameter datatype_size = 8,
    parameter output_datatype_size = datatype_size,
    parameter v_cim_tiles_1 = (input_size_1 + xbar_size - 1) / xbar_size, // ceiled division
    parameter h_cim_tiles_1 = (output_size_1*datatype_size + xbar_size - 1) / xbar_size, // ceiled division
    parameter v_cim_tiles_2 = (input_size_2 + xbar_size - 1) / xbar_size, // ceiled division
    parameter h_cim_tiles_2 = (output_size_2*datatype_size + xbar_size - 1) / xbar_size // ceiled division
) (
    input clk,
    input rst,

    input i_ibuf_we_1,
    input [datatype_size-1:0] i_ibuf_wr_data_1,
    input reg [$clog2(input_size_1)-1:0] i_ibuf_addr_1,
    input i_start_1,
    input i_cim_busy_1,
    input i_func_start_1,
    output reg o_busy_1, // ctrl busy
    output reg [$clog2(xbar_size)-1:0] o_cim_wr_addr_1,
    output reg [datatype_size-1:0] o_cim_data_1 [v_cim_tiles_1-1:0],

    input i_next_busy_1,
    input [datatype_size-1:0] i_data_1 [v_cim_tiles_1-1:0][h_cim_tiles_1-1:0], // CIM Output buffer data
    output reg [$clog2(xbar_size)-1:0] o_cim_rd_addr_1,
    output reg [output_datatype_size-1:0] o_func_data_1,

    input i_ibuf_we_2,
    input [datatype_size-1:0] i_ibuf_wr_data_2,
    input reg [$clog2(input_size_2)-1:0] i_ibuf_addr_2,
    input i_start_2,
    input i_cim_busy_2,
    input i_func_start_2,
    output reg o_busy_2, // ctrl busy
    output reg [$clog2(xbar_size)-1:0] o_cim_wr_addr_2,
    output reg [datatype_size-1:0] o_cim_data_2 [v_cim_tiles_2-1:0],

    input i_next_busy_2,
    input [datatype_size-1:0] i_data_2 [v_cim_tiles_2-1:0][h_cim_tiles_2-1:0], // CIM Output buffer data
    output reg [$clog2(xbar_size)-1:0] o_cim_rd_addr_2,
    output reg [output_datatype_size-1:0] o_func_data_2
);

fc_layer #(
    .input_size(input_size_1),
    .output_size(output_size_1),
    .xbar_size(xbar_size),
    .datatype_size(datatype_size),
    .output_datatype_size(datatype_size)
) fc_784 (
    .clk(clk),
    .rst(rst),
    .i_ibuf_we(i_ibuf_we_1),
    .i_ibuf_wr_data(i_ibuf_wr_data_1),
    .i_ibuf_addr(i_ibuf_addr_1),
    .i_start(i_start_1),
    .i_cim_busy(i_cim_busy_1),
    .i_func_start(i_func_start_1),
    .o_busy(o_busy_1), // ctrl busy
    .o_cim_wr_addr(o_cim_wr_addr_1),
    .o_cim_data(o_cim_data_1),

    .i_next_busy(i_next_busy_1),
    .i_data(i_data_1), // CIM Output buffer data
    .o_cim_rd_addr(o_cim_rd_addr_1),
    .o_func_data(o_func_data_1)
);

fc_layer #(
    .input_size(input_size_2),
    .output_size(output_size_2),
    .xbar_size(xbar_size),
    .datatype_size(datatype_size),
    .output_datatype_size(datatype_size)
) fc_1500 (
    .clk(clk),
    .rst(rst),
    .i_ibuf_we(i_ibuf_we_2),
    .i_ibuf_wr_data(i_ibuf_wr_data_2),
    .i_ibuf_addr(i_ibuf_addr_2),
    .i_start(i_start_2),
    .i_cim_busy(i_cim_busy_2),
    .i_func_start(i_func_start_2),
    .o_busy(o_busy_2), // ctrl busy
    .o_cim_wr_addr(o_cim_wr_addr_2),
    .o_cim_data(o_cim_data_2),

    .i_next_busy(i_next_busy_2),
    .i_data(i_data_2), // CIM Output buffer data
    .o_cim_rd_addr(o_cim_rd_addr_2),
    .o_func_data(o_func_data_2)
);

endmodule