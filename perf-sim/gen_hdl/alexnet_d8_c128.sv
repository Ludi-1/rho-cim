module alexnet_d8_c128_top #(
	parameter datatype_size = 8,
	parameter xbar_size = 128,

	parameter input_channels_1 = 3,
	parameter img_width_1 = 227,
	parameter kernel_dim_1 = 11,
	parameter output_size_1 = 96,
	parameter input_size_1 = input_channels_1 * kernel_dim_1**2,
	parameter v_cim_tiles_1 = (input_size_1 + xbar_size - 1) / xbar_size,
	parameter h_cim_tiles_1 = (output_size_1*datatype_size + xbar_size - 1) / xbar_size,

	parameter input_channels_2 = 96,
	parameter img_width_2 = 55,
	parameter kernel_dim_2 = 3,
	parameter output_size_2 = input_channels_2,

	parameter input_channels_3 = 96,
	parameter img_width_3 = 27,
	parameter kernel_dim_3 = 5,
	parameter output_size_3 = 256,
	parameter input_size_3 = input_channels_3 * kernel_dim_3**2,
	parameter v_cim_tiles_3 = (input_size_3 + xbar_size - 1) / xbar_size,
	parameter h_cim_tiles_3 = (output_size_3*datatype_size + xbar_size - 1) / xbar_size,

	parameter input_channels_4 = 256,
	parameter img_width_4 = 27,
	parameter kernel_dim_4 = 3,
	parameter output_size_4 = input_channels_4,

	parameter input_channels_5 = 256,
	parameter img_width_5 = 13,
	parameter kernel_dim_5 = 3,
	parameter output_size_5 = 384,
	parameter input_size_5 = input_channels_5 * kernel_dim_5**2,
	parameter v_cim_tiles_5 = (input_size_5 + xbar_size - 1) / xbar_size,
	parameter h_cim_tiles_5 = (output_size_5*datatype_size + xbar_size - 1) / xbar_size,

	parameter input_channels_6 = 384,
	parameter img_width_6 = 13,
	parameter kernel_dim_6 = 3,
	parameter output_size_6 = 384,
	parameter input_size_6 = input_channels_6 * kernel_dim_6**2,
	parameter v_cim_tiles_6 = (input_size_6 + xbar_size - 1) / xbar_size,
	parameter h_cim_tiles_6 = (output_size_6*datatype_size + xbar_size - 1) / xbar_size,

	parameter input_channels_7 = 384,
	parameter img_width_7 = 13,
	parameter kernel_dim_7 = 3,
	parameter output_size_7 = 256,
	parameter input_size_7 = input_channels_7 * kernel_dim_7**2,
	parameter v_cim_tiles_7 = (input_size_7 + xbar_size - 1) / xbar_size,
	parameter h_cim_tiles_7 = (output_size_7*datatype_size + xbar_size - 1) / xbar_size,

	parameter input_channels_8 = 256,
	parameter img_width_8 = 13,
	parameter kernel_dim_8 = 3,
	parameter output_size_8 = input_channels_8,

	parameter input_size_9 = 9216,
	parameter output_size_9 = 4096,
	parameter v_cim_tiles_9 = (input_size_9 + xbar_size - 1) / xbar_size,
	parameter h_cim_tiles_9 = (output_size_9*datatype_size + xbar_size - 1) / xbar_size,

	parameter input_size_10 = 4096,
	parameter output_size_10 = 4096,
	parameter v_cim_tiles_10 = (input_size_10 + xbar_size - 1) / xbar_size,
	parameter h_cim_tiles_10 = (output_size_10*datatype_size + xbar_size - 1) / xbar_size,

	parameter input_size_11 = 4096,
	parameter output_size_11 = 10,
	parameter v_cim_tiles_11 = (input_size_11 + xbar_size - 1) / xbar_size,
	parameter h_cim_tiles_11 = (output_size_11*datatype_size + xbar_size - 1) / xbar_size,

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

	input i_ibuf_we_5 [input_channels_5-1:0],
	input [datatype_size-1:0] i_ibuf_wr_data_5 [input_channels_5-1:0],
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

	input i_ibuf_we_6 [input_channels_6-1:0],
	input [datatype_size-1:0] i_ibuf_wr_data_6 [input_channels_6-1:0],
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

	input i_ibuf_we_7 [input_channels_7-1:0],
	input [datatype_size-1:0] i_ibuf_wr_data_7 [input_channels_7-1:0],
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

	input i_ibuf_we_8 [input_channels_8-1:0],
	input [datatype_size-1:0] i_ibuf_wr_data_8 [input_channels_8-1:0],
	input i_start_8,
	input i_func_start_8,
	input i_next_busy_8,
	output reg [output_datatype_size-1:0] o_func_data_8 [output_size_8-1:0],

	input i_ibuf_we_9,
	input [datatype_size-1:0] i_ibuf_wr_data_9,
	input reg [$clog2(input_size_9)-1:0] i_ibuf_addr_9,
	input i_start_9,
	input i_cim_busy_9,
	input i_func_start_9,
	output reg o_busy_9,
	output reg [$clog2(xbar_size)-1:0] o_cim_wr_addr_9,
	output reg [datatype_size-1:0] o_cim_data_9 [v_cim_tiles_9-1:0],
	input i_next_busy_9,
	input [datatype_size-1:0] i_data_9 [v_cim_tiles_9-1:0][h_cim_tiles_9-1:0],
	output reg [$clog2(xbar_size)-1:0] o_cim_rd_addr_9,
	output reg [output_datatype_size-1:0] o_func_data_9,

	input i_ibuf_we_10,
	input [datatype_size-1:0] i_ibuf_wr_data_10,
	input reg [$clog2(input_size_10)-1:0] i_ibuf_addr_10,
	input i_start_10,
	input i_cim_busy_10,
	input i_func_start_10,
	output reg o_busy_10,
	output reg [$clog2(xbar_size)-1:0] o_cim_wr_addr_10,
	output reg [datatype_size-1:0] o_cim_data_10 [v_cim_tiles_10-1:0],
	input i_next_busy_10,
	input [datatype_size-1:0] i_data_10 [v_cim_tiles_10-1:0][h_cim_tiles_10-1:0],
	output reg [$clog2(xbar_size)-1:0] o_cim_rd_addr_10,
	output reg [output_datatype_size-1:0] o_func_data_10,

	input i_ibuf_we_11,
	input [datatype_size-1:0] i_ibuf_wr_data_11,
	input reg [$clog2(input_size_11)-1:0] i_ibuf_addr_11,
	input i_start_11,
	input i_cim_busy_11,
	input i_func_start_11,
	output reg o_busy_11,
	output reg [$clog2(xbar_size)-1:0] o_cim_wr_addr_11,
	output reg [datatype_size-1:0] o_cim_data_11 [v_cim_tiles_11-1:0],
	input i_next_busy_11,
	input [datatype_size-1:0] i_data_11 [v_cim_tiles_11-1:0][h_cim_tiles_11-1:0],
	output reg [$clog2(xbar_size)-1:0] o_cim_rd_addr_11,
	output reg [output_datatype_size-1:0] o_func_data_11,

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
) conv_11x11_1 (
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
) pool_3x3_2 (
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
) pool_3x3_4 (
	.clk(clk),
	.rst(rst),
	.i_ibuf_we(i_ibuf_we_4),
	.i_ibuf_wr_data(i_ibuf_wr_data_4),
	.i_start(i_start_4),
	.i_func_start(i_func_start_4),
	.i_next_busy(i_next_busy_4),
	.o_func_data(o_func_data_4)
);

conv_layer #(
	.input_channels(input_channels_5),
	.img_width(img_width_5),
	.kernel_dim(kernel_dim_5),
	.output_size(output_size_5),
	.xbar_size(xbar_size),
	.datatype_size(datatype_size),
	.output_datatype_size(datatype_size)
) conv_3x3_5 (
	.clk(clk),
	.rst(rst),
	.i_ibuf_we(i_ibuf_we_5),
	.i_ibuf_wr_data(i_ibuf_wr_data_5),
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

conv_layer #(
	.input_channels(input_channels_6),
	.img_width(img_width_6),
	.kernel_dim(kernel_dim_6),
	.output_size(output_size_6),
	.xbar_size(xbar_size),
	.datatype_size(datatype_size),
	.output_datatype_size(datatype_size)
) conv_3x3_6 (
	.clk(clk),
	.rst(rst),
	.i_ibuf_we(i_ibuf_we_6),
	.i_ibuf_wr_data(i_ibuf_wr_data_6),
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

conv_layer #(
	.input_channels(input_channels_7),
	.img_width(img_width_7),
	.kernel_dim(kernel_dim_7),
	.output_size(output_size_7),
	.xbar_size(xbar_size),
	.datatype_size(datatype_size),
	.output_datatype_size(datatype_size)
) conv_3x3_7 (
	.clk(clk),
	.rst(rst),
	.i_ibuf_we(i_ibuf_we_7),
	.i_ibuf_wr_data(i_ibuf_wr_data_7),
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

pool_layer #(
	.input_channels(input_channels_8),
	.img_width(img_width_8),
	.kernel_dim(kernel_dim_8),
	.datatype_size(datatype_size),
	.output_datatype_size(datatype_size)
) pool_3x3_8 (
	.clk(clk),
	.rst(rst),
	.i_ibuf_we(i_ibuf_we_8),
	.i_ibuf_wr_data(i_ibuf_wr_data_8),
	.i_start(i_start_8),
	.i_func_start(i_func_start_8),
	.i_next_busy(i_next_busy_8),
	.o_func_data(o_func_data_8)
);

fc_layer #(
	.input_size(input_size_9),
	.output_size(output_size_9),
	.xbar_size(xbar_size),
	.datatype_size(datatype_size),
	.output_datatype_size(datatype_size)
) fc_4096_9 (
	.clk(clk),
	.rst(rst),
	.i_ibuf_we(i_ibuf_we_9),
	.i_ibuf_wr_data(i_ibuf_wr_data_9),
	.i_ibuf_addr(i_ibuf_addr_9),
	.i_start(i_start_9),
	.i_cim_busy(i_cim_busy_9),
	.i_func_start(i_func_start_9),
	.o_busy(o_busy_9),
	.o_cim_wr_addr(o_cim_wr_addr_9),
	.o_cim_data(o_cim_data_9),
	.i_next_busy(i_next_busy_9),
	.i_data(i_data_9),
	.o_cim_rd_addr(o_cim_rd_addr_9),
	.o_func_data(o_func_data_9)
);

fc_layer #(
	.input_size(input_size_10),
	.output_size(output_size_10),
	.xbar_size(xbar_size),
	.datatype_size(datatype_size),
	.output_datatype_size(datatype_size)
) fc_4096_10 (
	.clk(clk),
	.rst(rst),
	.i_ibuf_we(i_ibuf_we_10),
	.i_ibuf_wr_data(i_ibuf_wr_data_10),
	.i_ibuf_addr(i_ibuf_addr_10),
	.i_start(i_start_10),
	.i_cim_busy(i_cim_busy_10),
	.i_func_start(i_func_start_10),
	.o_busy(o_busy_10),
	.o_cim_wr_addr(o_cim_wr_addr_10),
	.o_cim_data(o_cim_data_10),
	.i_next_busy(i_next_busy_10),
	.i_data(i_data_10),
	.o_cim_rd_addr(o_cim_rd_addr_10),
	.o_func_data(o_func_data_10)
);

fc_layer #(
	.input_size(input_size_11),
	.output_size(output_size_11),
	.xbar_size(xbar_size),
	.datatype_size(datatype_size),
	.output_datatype_size(datatype_size)
) fc_10_11 (
	.clk(clk),
	.rst(rst),
	.i_ibuf_we(i_ibuf_we_11),
	.i_ibuf_wr_data(i_ibuf_wr_data_11),
	.i_ibuf_addr(i_ibuf_addr_11),
	.i_start(i_start_11),
	.i_cim_busy(i_cim_busy_11),
	.i_func_start(i_func_start_11),
	.o_busy(o_busy_11),
	.o_cim_wr_addr(o_cim_wr_addr_11),
	.o_cim_data(o_cim_data_11),
	.i_next_busy(i_next_busy_11),
	.i_data(i_data_11),
	.o_cim_rd_addr(o_cim_rd_addr_11),
	.o_func_data(o_func_data_11)
);

endmodule