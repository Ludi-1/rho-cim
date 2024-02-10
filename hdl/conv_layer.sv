module conv_layer #(
    parameter input_channels = 5, // Number of input channels
    parameter img_width = 28, // Input image width
    parameter kernel_dim = 3, // kernel dim N, where kernel size is NxN
    parameter output_size = 10, // Number of output channels
    parameter xbar_size = 256,
    parameter datatype_size = 8,
    parameter output_datatype_size = 8,
    parameter input_size = input_channels * kernel_dim**2, // Total CIM rows
    parameter v_cim_tiles = (input_size + xbar_size - 1) / xbar_size, // ceiled division
    parameter h_cim_tiles = (output_size + xbar_size - 1) / xbar_size // ceiled division
) (
    input clk,
    input rst,

    input i_ibuf_we [input_channels-1:0],
    input [datatype_size-1:0] i_ibuf_wr_data [input_channels-1:0],
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

logic [datatype_size-1:0] ibuf_rd_data [input_channels-1:0][kernel_dim**2-1:0];
logic [datatype_size-1:0] ctrl_rd_data [input_channels*kernel_dim**2-1:0];
logic func_busy;

generate
  genvar i, j;
  for (i = 0; i < input_channels; i++) begin
    conv_ibuf #(
      .datatype_size(datatype_size),
      .img_width(img_width),
      .kernel_dim(kernel_dim)
    ) ibuf (
      .clk(clk),
      .we(i_ibuf_we[i]),
      .d_in(i_ibuf_wr_data[i]), // From prev layer func to ibuf
      .d_out(ibuf_rd_data[i]) // From ibuf to ctrl of this layer
    );
    for (j = 0; j < kernel_dim**2; j++) begin
      assign ctrl_rd_data[i * kernel_dim**2 + j] = ibuf_rd_data[i][j];
    end
  end
endgenerate

// Instantiate ctrl module
conv_ctrl #(
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
    .i_data(ctrl_rd_data),
    .o_cim_addr(o_cim_wr_addr),
    .o_data(o_cim_data)
);

conv_func #(
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