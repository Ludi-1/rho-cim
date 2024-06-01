module pool_layer #(
    DATA_SIZE = 8,
    parameter INPUT_CHANNELS = 256, // Number of input channels
    parameter IMG_DIM = 13, // Input image width
    parameter KERNEL_DIM = 3, // kernel dim N, where kernel size is NxN
    parameter OUTPUT_CHANNELS = INPUT_CHANNELS
) (
    input clk,
    input rst,

    input [INPUT_CHANNELS-1:0] i_ibuf_we,
    input [DATA_SIZE-1:0] i_ibuf_wr_data [INPUT_CHANNELS-1:0],
    output o_ready,
    input i_start,

    output [OUTPUT_CHANNELS-1:0] o_ibuf_we,
    output o_start,
    output reg [DATA_SIZE-1:0] o_data [OUTPUT_CHANNELS-1:0]
);

assign o_ready = 1;
assign o_ibuf_we = i_ibuf_we;
assign o_start = i_start;

localparam FIFO_LENGTH = IMG_DIM * (KERNEL_DIM - 1) + KERNEL_DIM;
reg [DATA_SIZE-1:0] fifo_data [INPUT_CHANNELS-1:0][FIFO_LENGTH-1:0];
wire [DATA_SIZE-1:0] kernel_elements [INPUT_CHANNELS-1:0][KERNEL_DIM**2-1:0];

// FIFO shift register
always_ff @(posedge clk) begin
    for (int input_channel = 0; input_channel < INPUT_CHANNELS; input_channel++) begin
        if (i_ibuf_we[input_channel]) begin
            fifo_data[input_channel][0] <= i_ibuf_wr_data[input_channel];
            for (int fifo_idx = 0; fifo_idx < FIFO_LENGTH - 1; fifo_idx++) begin
                fifo_data[input_channel][fifo_idx + 1] <= fifo_data[input_channel][fifo_idx]; 
            end
        end
    end
end

genvar i, j, k;
generate
    // extract kernel elements from FIFO
    for (i = 0; i < INPUT_CHANNELS; i++) begin
        for (j = 0; j < KERNEL_DIM; j++) begin
            for (k = 0; k < KERNEL_DIM; k++) begin
                assign kernel_elements[i][j + k*KERNEL_DIM] = fifo_data[i][j*IMG_DIM + k];
            end
        end
    end
endgenerate

always_comb begin
  integer i, j;
  for (i = 0; i < INPUT_CHANNELS; i++) begin
    logic [DATA_SIZE-1:0] max_value = -2**DATA_SIZE+1;
    for (j = 0; j < KERNEL_DIM**2; j++) begin
      if (kernel_elements[i][j] > max_value) begin
        max_value = kernel_elements[i][j];
      end
    end
    o_data[i] = max_value;
  end
end


endmodule