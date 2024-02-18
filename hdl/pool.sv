module pool_layer #(
    parameter input_channels = 10, // Number of input channels
    parameter img_width = 22, // Input image width
    parameter kernel_dim = 2, // kernel dim N, where kernel size is NxN
    parameter output_size = input_channels, // Number of output channels
    parameter xbar_size = 256,
    parameter datatype_size = 2,
    parameter output_datatype_size = 2
) (
    input clk,
    input rst,

    input i_ibuf_we [input_channels-1:0],
    input [datatype_size-1:0] i_ibuf_wr_data [input_channels-1:0],
    input i_start,
    input i_func_start,

    input i_next_busy,
    output reg [output_datatype_size-1:0] o_func_data [output_size-1:0] 
);

logic [datatype_size-1:0] ibuf_rd_data [input_channels-1:0][kernel_dim**2-1:0];
logic [datatype_size-1:0] ctrl_rd_data [input_channels*kernel_dim**2-1:0];
logic func_busy;

genvar i;
generate
  for (i = 0; i < input_channels; i++) begin
    conv_ibuf #(
      .datatype_size(datatype_size),
      .img_width(img_width),
      .kernel_dim(kernel_dim)
    ) ibuf (
      .clk(clk),
      .i_write_enable(i_ibuf_we[i]),
      .i_data(i_ibuf_wr_data[i]),
      .o_data(ibuf_rd_data[i])
    );
  end
endgenerate

always_comb begin
  integer i, j;
  for (i = 0; i < input_channels; i++) begin
    logic [datatype_size-1:0] max_value = '0;
    for (j = 0; j < kernel_dim**2; j++) begin
      if (ibuf_rd_data[i][j] > max_value) begin
        max_value = ibuf_rd_data[i][j];
      end
    end
    o_func_data[i] = max_value;
  end
end


endmodule