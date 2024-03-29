module mlp_m_d4_c256_top #(
	parameter datatype_size = 4,
	parameter xbar_size = 256,

	parameter input_size_1 = 784,
	parameter output_size_1 = 784,
	parameter v_cim_tiles_1 = (input_size_1 + xbar_size - 1) / xbar_size,
	parameter h_cim_tiles_1 = (output_size_1*datatype_size + xbar_size - 1) / xbar_size,

	parameter input_size_2 = 784,
	parameter output_size_2 = 1000,
	parameter v_cim_tiles_2 = (input_size_2 + xbar_size - 1) / xbar_size,
	parameter h_cim_tiles_2 = (output_size_2*datatype_size + xbar_size - 1) / xbar_size,

	parameter input_size_3 = 1000,
	parameter output_size_3 = 500,
	parameter v_cim_tiles_3 = (input_size_3 + xbar_size - 1) / xbar_size,
	parameter h_cim_tiles_3 = (output_size_3*datatype_size + xbar_size - 1) / xbar_size,

	parameter input_size_4 = 500,
	parameter output_size_4 = 250,
	parameter v_cim_tiles_4 = (input_size_4 + xbar_size - 1) / xbar_size,
	parameter h_cim_tiles_4 = (output_size_4*datatype_size + xbar_size - 1) / xbar_size,

	parameter input_size_5 = 250,
	parameter output_size_5 = 10,
	parameter v_cim_tiles_5 = (input_size_5 + xbar_size - 1) / xbar_size,
	parameter h_cim_tiles_5 = (output_size_5*datatype_size + xbar_size - 1) / xbar_size,

	output_datatype_size = 4
) (
	input i_ibuf_we_1,
	input [datatype_size-1:0] i_ibuf_wr_data_1,
	input reg [$clog2(input_size_1)-1:0] i_ibuf_addr_1,
	input i_start_1,
	input i_cim_busy_1,
	input i_func_start_1,
	output reg o_busy_1,
	output reg [$clog2(xbar_size)-1:0] o_cim_wr_addr_1,
	output reg [datatype_size-1:0] o_cim_data_1 [v_cim_tiles_1-1:0],
	input i_next_busy_1,
	input [datatype_size-1:0] i_data_1 [v_cim_tiles_1-1:0][h_cim_tiles_1-1:0],
	output reg [$clog2(xbar_size)-1:0] o_cim_rd_addr_1,
	output reg [output_datatype_size-1:0] o_func_data_1,

	input i_ibuf_we_2,
	input [datatype_size-1:0] i_ibuf_wr_data_2,
	input reg [$clog2(input_size_2)-1:0] i_ibuf_addr_2,
	input i_start_2,
	input i_cim_busy_2,
	input i_func_start_2,
	output reg o_busy_2,
	output reg [$clog2(xbar_size)-1:0] o_cim_wr_addr_2,
	output reg [datatype_size-1:0] o_cim_data_2 [v_cim_tiles_2-1:0],
	input i_next_busy_2,
	input [datatype_size-1:0] i_data_2 [v_cim_tiles_2-1:0][h_cim_tiles_2-1:0],
	output reg [$clog2(xbar_size)-1:0] o_cim_rd_addr_2,
	output reg [output_datatype_size-1:0] o_func_data_2,

	input i_ibuf_we_3,
	input [datatype_size-1:0] i_ibuf_wr_data_3,
	input reg [$clog2(input_size_3)-1:0] i_ibuf_addr_3,
	input i_start_3,
	input i_cim_busy_3,
	input i_func_start_3,
	output reg o_busy_3,
	output reg [$clog2(xbar_size)-1:0] o_cim_wr_addr_3,
	output reg [datatype_size-1:0] o_cim_data_3 [v_cim_tiles_3-1:0],
	input i_next_busy_3,
	input [datatype_size-1:0] i_data_3 [v_cim_tiles_3-1:0][h_cim_tiles_3-1:0],
	output reg [$clog2(xbar_size)-1:0] o_cim_rd_addr_3,
	output reg [output_datatype_size-1:0] o_func_data_3,

	input i_ibuf_we_4,
	input [datatype_size-1:0] i_ibuf_wr_data_4,
	input reg [$clog2(input_size_4)-1:0] i_ibuf_addr_4,
	input i_start_4,
	input i_cim_busy_4,
	input i_func_start_4,
	output reg o_busy_4,
	output reg [$clog2(xbar_size)-1:0] o_cim_wr_addr_4,
	output reg [datatype_size-1:0] o_cim_data_4 [v_cim_tiles_4-1:0],
	input i_next_busy_4,
	input [datatype_size-1:0] i_data_4 [v_cim_tiles_4-1:0][h_cim_tiles_4-1:0],
	output reg [$clog2(xbar_size)-1:0] o_cim_rd_addr_4,
	output reg [output_datatype_size-1:0] o_func_data_4,

	input i_ibuf_we_5,
	input [datatype_size-1:0] i_ibuf_wr_data_5,
	input reg [$clog2(input_size_5)-1:0] i_ibuf_addr_5,
	input i_start_5,
	input i_cim_busy_5,
	input i_func_start_5,
	output reg o_busy_5,
	output reg [$clog2(xbar_size)-1:0] o_cim_wr_addr_5,
	output reg [datatype_size-1:0] o_cim_data_5 [v_cim_tiles_5-1:0],
	input i_next_busy_5,
	input [datatype_size-1:0] i_data_5 [v_cim_tiles_5-1:0][h_cim_tiles_5-1:0],
	output reg [$clog2(xbar_size)-1:0] o_cim_rd_addr_5,
	output reg [output_datatype_size-1:0] o_func_data_5,

	input clk,
	input rst
);

fc_layer #(
	.input_size(input_size_1),
	.output_size(output_size_1),
	.xbar_size(xbar_size),
	.datatype_size(datatype_size),
	.output_datatype_size(datatype_size)
) fc_784_1 (
	.clk(clk),
	.rst(rst),
	.i_ibuf_we(i_ibuf_we_1),
	.i_ibuf_wr_data(i_ibuf_wr_data_1),
	.i_ibuf_addr(i_ibuf_addr_1),
	.i_start(i_start_1),
	.i_cim_busy(i_cim_busy_1),
	.i_func_start(i_func_start_1),
	.o_busy(o_busy_1),
	.o_cim_wr_addr(o_cim_wr_addr_1),
	.o_cim_data(o_cim_data_1),
	.i_next_busy(i_next_busy_1),
	.i_data(i_data_1),
	.o_cim_rd_addr(o_cim_rd_addr_1),
	.o_func_data(o_func_data_1)
);

fc_layer #(
	.input_size(input_size_2),
	.output_size(output_size_2),
	.xbar_size(xbar_size),
	.datatype_size(datatype_size),
	.output_datatype_size(datatype_size)
) fc_1000_2 (
	.clk(clk),
	.rst(rst),
	.i_ibuf_we(i_ibuf_we_2),
	.i_ibuf_wr_data(i_ibuf_wr_data_2),
	.i_ibuf_addr(i_ibuf_addr_2),
	.i_start(i_start_2),
	.i_cim_busy(i_cim_busy_2),
	.i_func_start(i_func_start_2),
	.o_busy(o_busy_2),
	.o_cim_wr_addr(o_cim_wr_addr_2),
	.o_cim_data(o_cim_data_2),
	.i_next_busy(i_next_busy_2),
	.i_data(i_data_2),
	.o_cim_rd_addr(o_cim_rd_addr_2),
	.o_func_data(o_func_data_2)
);

fc_layer #(
	.input_size(input_size_3),
	.output_size(output_size_3),
	.xbar_size(xbar_size),
	.datatype_size(datatype_size),
	.output_datatype_size(datatype_size)
) fc_500_3 (
	.clk(clk),
	.rst(rst),
	.i_ibuf_we(i_ibuf_we_3),
	.i_ibuf_wr_data(i_ibuf_wr_data_3),
	.i_ibuf_addr(i_ibuf_addr_3),
	.i_start(i_start_3),
	.i_cim_busy(i_cim_busy_3),
	.i_func_start(i_func_start_3),
	.o_busy(o_busy_3),
	.o_cim_wr_addr(o_cim_wr_addr_3),
	.o_cim_data(o_cim_data_3),
	.i_next_busy(i_next_busy_3),
	.i_data(i_data_3),
	.o_cim_rd_addr(o_cim_rd_addr_3),
	.o_func_data(o_func_data_3)
);

fc_layer #(
	.input_size(input_size_4),
	.output_size(output_size_4),
	.xbar_size(xbar_size),
	.datatype_size(datatype_size),
	.output_datatype_size(datatype_size)
) fc_250_4 (
	.clk(clk),
	.rst(rst),
	.i_ibuf_we(i_ibuf_we_4),
	.i_ibuf_wr_data(i_ibuf_wr_data_4),
	.i_ibuf_addr(i_ibuf_addr_4),
	.i_start(i_start_4),
	.i_cim_busy(i_cim_busy_4),
	.i_func_start(i_func_start_4),
	.o_busy(o_busy_4),
	.o_cim_wr_addr(o_cim_wr_addr_4),
	.o_cim_data(o_cim_data_4),
	.i_next_busy(i_next_busy_4),
	.i_data(i_data_4),
	.o_cim_rd_addr(o_cim_rd_addr_4),
	.o_func_data(o_func_data_4)
);

fc_layer #(
	.input_size(input_size_5),
	.output_size(output_size_5),
	.xbar_size(xbar_size),
	.datatype_size(datatype_size),
	.output_datatype_size(datatype_size)
) fc_10_5 (
	.clk(clk),
	.rst(rst),
	.i_ibuf_we(i_ibuf_we_5),
	.i_ibuf_wr_data(i_ibuf_wr_data_5),
	.i_ibuf_addr(i_ibuf_addr_5),
	.i_start(i_start_5),
	.i_cim_busy(i_cim_busy_5),
	.i_func_start(i_func_start_5),
	.o_busy(o_busy_5),
	.o_cim_wr_addr(o_cim_wr_addr_5),
	.o_cim_data(o_cim_data_5),
	.i_next_busy(i_next_busy_5),
	.i_data(i_data_5),
	.o_cim_rd_addr(o_cim_rd_addr_5),
	.o_func_data(o_func_data_5)
);

endmodule