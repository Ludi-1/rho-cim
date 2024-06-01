module conv_ibuf #(
    parameter DATA_SIZE = 8,
    parameter IMG_DIM = 28,
    parameter KERNEL_DIM = 3,
    parameter INPUT_CHANNELS = 2,
    parameter XBAR_SIZE = 128,
    parameter BUS_WIDTH = 16,
    parameter V_CIM_TILES_OUT = (INPUT_CHANNELS*KERNEL_DIM**2 + XBAR_SIZE-1) / XBAR_SIZE,
    parameter NUM_ADDR = $rtoi($ceil(INPUT_CHANNELS*KERNEL_DIM**2 / (BUS_WIDTH * V_CIM_TILES_OUT))),
    parameter ADDR_WIDTH = (NUM_ADDR <= 1) ? 1 : $clog2(NUM_ADDR)
) (
    input clk,
    input [INPUT_CHANNELS-1:0] i_write_enable,
    input [DATA_SIZE-1:0] i_data [INPUT_CHANNELS-1:0],
    output [BUS_WIDTH*V_CIM_TILES_OUT-1:0] o_data [DATA_SIZE-1:0],
    input [ADDR_WIDTH-1:0] i_ibuf_addr
);

localparam FIFO_LENGTH = IMG_DIM * (KERNEL_DIM - 1) + KERNEL_DIM;
reg [DATA_SIZE-1:0] fifo_data [INPUT_CHANNELS-1:0][FIFO_LENGTH-1:0];

// FIFO shift register
always_ff @(posedge clk) begin
    for (int input_channel = 0; input_channel < INPUT_CHANNELS; input_channel++) begin
        if (i_write_enable[input_channel]) begin
            fifo_data[input_channel][0] <= i_data[input_channel];
            for (int fifo_idx = 0; fifo_idx < FIFO_LENGTH - 1; fifo_idx++) begin
                fifo_data[input_channel][fifo_idx + 1] <= fifo_data[input_channel][fifo_idx]; 
            end
        end
    end
end

wire [KERNEL_DIM**2 * INPUT_CHANNELS-1:0] reorder [DATA_SIZE-1:0];
wire [DATA_SIZE-1:0] kernel_elements [INPUT_CHANNELS-1:0][KERNEL_DIM**2-1:0];

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

    // map kernel elements to o_data
    for (i = 0; i < INPUT_CHANNELS; i++) begin // INPUT CHANNEL
        for (j = 0; j < KERNEL_DIM**2; j++) begin // KERNEL DIM 1
            for (k = 0; k < DATA_SIZE; k++) begin // KERNEL DIM 2
                assign reorder[k][i*KERNEL_DIM**2 + j] = kernel_elements[i][j][k];
            end
        end
    end
endgenerate

endmodule