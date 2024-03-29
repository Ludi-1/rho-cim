module lenet5_d8_c512_top #(
	parameter datatype_size = 8,
	parameter xbar_size = 512,

	parameter input_channels_1 = 1,
	parameter img_width_1 = 28,
	parameter kernel_dim_1 = 5,
	parameter output_size_1 = 6,
	parameter input_size_1 = input_channels_1 * kernel_dim_1**2,
	parameter v_cim_tiles_1 = (input_size_1 + xbar_size - 1) / xbar_size,
	parameter h_cim_tiles_1 = (output_size_1*datatype_size + xbar_size - 1) / xbar_size,

	parameter input_channels_2 = 6,
	parameter img_width_2 = 24,
	parameter kernel_dim_2 = 2,
	parameter output_size_2 = input_channels_2,

	parameter input_channels_3 = 6,
	parameter img_width_3 = 12,
	parameter kernel_dim_3 = 5,
	parameter output_size_3 = 16,
	parameter input_size_3 = input_channels_3 * kernel_dim_3**2,
	parameter v_cim_tiles_3 = (input_size_3 + xbar_size - 1) / xbar_size,
	parameter h_cim_tiles_3 = (output_size_3*datatype_size + xbar_size - 1) / xbar_size,

	parameter input_channels_4 = 16,
	parameter img_width_4 = 8,
	parameter kernel_dim_4 = 2,
	parameter output_size_4 = input_channels_4,

	parameter input_size_5 = 256,
	parameter output_size_5 = 120,
	parameter v_cim_tiles_5 = (input_size_5 + xbar_size - 1) / xbar_size,
	parameter h_cim_tiles_5 = (output_size_5*datatype_size + xbar_size - 1) / xbar_size,

	parameter input_size_6 = 120,
	parameter output_size_6 = 84,
	parameter v_cim_tiles_6 = (input_size_6 + xbar_size - 1) / xbar_size,
	parameter h_cim_tiles_6 = (output_size_6*datatype_size + xbar_size - 1) / xbar_size,

	parameter input_size_7 = 84,
	parameter output_size_7 = 10,
	parameter v_cim_tiles_7 = (input_size_7 + xbar_size - 1) / xbar_size,
	parameter h_cim_tiles_7 = (output_size_7*datatype_size + xbar_size - 1) / xbar_size,

	output_datatype_size = 8
) (
	input i_ibuf_we_1 [input_channels_1-1:0],
	input [datatype_size-1:0] i_ibuf_wr_data_1 [input_channels_1-1:0],
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

	input i_ibuf_we_2 [input_channels_2-1:0],
	input [datatype_size-1:0] i_ibuf_wr_data_2 [input_channels_2-1:0],
	input i_start_2,
	input i_func_start_2,
	input i_next_busy_2,
	output reg [output_datatype_size-1:0] o_func_data_2 [output_size_2-1:0],

	input i_ibuf_we_3 [input_channels_3-1:0],
	input [datatype_size-1:0] i_ibuf_wr_data_3 [input_channels_3-1:0],
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

	input i_ibuf_we_4 [input_channels_4-1:0],
	input [datatype_size-1:0] i_ibuf_wr_data_4 [input_channels_4-1:0],
	input i_start_4,
	input i_func_start_4,
	input i_next_busy_4,
	output reg [output_datatype_size-1:0] o_func_data_4 [output_size_4-1:0],

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

	input i_ibuf_we_6,
	input [datatype_size-1:0] i_ibuf_wr_data_6,
	input reg [$clog2(input_size_6)-1:0] i_ibuf_addr_6,
	input i_start_6,
	input i_cim_busy_6,
	input i_func_start_6,
	output reg o_busy_6,
	output reg [$clog2(xbar_size)-1:0] o_cim_wr_addr_6,
	output reg [datatype_size-1:0] o_cim_data_6 [v_cim_tiles_6-1:0],
	input i_next_busy_6,
	input [datatype_size-1:0] i_data_6 [v_cim_tiles_6-1:0][h_cim_tiles_6-1:0],
	output reg [$clog2(xbar_size)-1:0] o_cim_rd_addr_6,
	output reg [output_datatype_size-1:0] o_func_data_6,

	input i_ibuf_we_7,
	input [datatype_size-1:0] i_ibuf_wr_data_7,
	input reg [$clog2(input_size_7)-1:0] i_ibuf_addr_7,
	input i_start_7,
	input i_cim_busy_7,
	input i_func_start_7,
	output reg o_busy_7,
	output reg [$clog2(xbar_size)-1:0] o_cim_wr_addr_7,
	output reg [datatype_size-1:0] o_cim_data_7 [v_cim_tiles_7-1:0],
	input i_next_busy_7,
	input [datatype_size-1:0] i_data_7 [v_cim_tiles_7-1:0][h_cim_tiles_7-1:0],
	output reg [$clog2(xbar_size)-1:0] o_cim_rd_addr_7,
	output reg [output_datatype_size-1:0] o_func_data_7,

	input clk,
	input rst
);

conv_layer #(
	.input_channels(input_channels_1),
	.img_width(img_width_1),
	.kernel_dim(kernel_dim_1),
	.output_size(output_size_1),
	.xbar_size(xbar_size),
	.datatype_size(datatype_size),
	.output_datatype_size(datatype_size)
) conv_5x5_1 (
	.clk(clk),
	.rst(rst),
	.i_ibuf_we(i_ibuf_we_1),
	.i_ibuf_wr_data(i_ibuf_wr_data_1),
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

pool_layer #(
	.input_channels(input_channels_2),
	.img_width(img_width_2),
	.kernel_dim(kernel_dim_2),
	.datatype_size(datatype_size),
	.output_datatype_size(datatype_size)
) pool_2x2_2 (
	.clk(clk),
	.rst(rst),
	.i_ibuf_we(i_ibuf_we_2),
	.i_ibuf_wr_data(i_ibuf_wr_data_2),
	.i_start(i_start_2),
	.i_func_start(i_func_start_2),
	.i_next_busy(i_next_busy_2),
	.o_func_data(o_func_data_2)
);

conv_layer #(
	.input_channels(input_channels_3),
	.img_width(img_width_3),
	.kernel_dim(kernel_dim_3),
	.output_size(output_size_3),
	.xbar_size(xbar_size),
	.datatype_size(datatype_size),
	.output_datatype_size(datatype_size)
) conv_5x5_3 (
	.clk(clk),
	.rst(rst),
	.i_ibuf_we(i_ibuf_we_3),
	.i_ibuf_wr_data(i_ibuf_wr_data_3),
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

pool_layer #(
	.input_channels(input_channels_4),
	.img_width(img_width_4),
	.kernel_dim(kernel_dim_4),
	.datatype_size(datatype_size),
	.output_datatype_size(datatype_size)
) pool_2x2_4 (
	.clk(clk),
	.rst(rst),
	.i_ibuf_we(i_ibuf_we_4),
	.i_ibuf_wr_data(i_ibuf_wr_data_4),
	.i_start(i_start_4),
	.i_func_start(i_func_start_4),
	.i_next_busy(i_next_busy_4),
	.o_func_data(o_func_data_4)
);

fc_layer #(
	.input_size(input_size_5),
	.output_size(output_size_5),
	.xbar_size(xbar_size),
	.datatype_size(datatype_size),
	.output_datatype_size(datatype_size)
) fc_120_5 (
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

fc_layer #(
	.input_size(input_size_6),
	.output_size(output_size_6),
	.xbar_size(xbar_size),
	.datatype_size(datatype_size),
	.output_datatype_size(datatype_size)
) fc_84_6 (
	.clk(clk),
	.rst(rst),
	.i_ibuf_we(i_ibuf_we_6),
	.i_ibuf_wr_data(i_ibuf_wr_data_6),
	.i_ibuf_addr(i_ibuf_addr_6),
	.i_start(i_start_6),
	.i_cim_busy(i_cim_busy_6),
	.i_func_start(i_func_start_6),
	.o_busy(o_busy_6),
	.o_cim_wr_addr(o_cim_wr_addr_6),
	.o_cim_data(o_cim_data_6),
	.i_next_busy(i_next_busy_6),
	.i_data(i_data_6),
	.o_cim_rd_addr(o_cim_rd_addr_6),
	.o_func_data(o_func_data_6)
);

fc_layer #(
	.input_size(input_size_7),
	.output_size(output_size_7),
	.xbar_size(xbar_size),
	.datatype_size(datatype_size),
	.output_datatype_size(datatype_size)
) fc_10_7 (
	.clk(clk),
	.rst(rst),
	.i_ibuf_we(i_ibuf_we_7),
	.i_ibuf_wr_data(i_ibuf_wr_data_7),
	.i_ibuf_addr(i_ibuf_addr_7),
	.i_start(i_start_7),
	.i_cim_busy(i_cim_busy_7),
	.i_func_start(i_func_start_7),
	.o_busy(o_busy_7),
	.o_cim_wr_addr(o_cim_wr_addr_7),
	.o_cim_data(o_cim_data_7),
	.i_next_busy(i_next_busy_7),
	.i_data(i_data_7),
	.o_cim_rd_addr(o_cim_rd_addr_7),
	.o_func_data(o_func_data_7)
);

endmodule