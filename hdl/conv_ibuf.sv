module conv_ibuf #(
    parameter DATA_SIZE = 8,
    parameter IMG_DIM = 28,
    parameter KERNEL_DIM = 3,
    parameter INPUT_CHANNELS = 2,
    parameter XBAR_SIZE = 128,
    parameter BUS_WIDTH = 16,
    parameter COUNT_WIDTH = (DATA_SIZE==1) ? 1 : $clog2(DATA_SIZE),
    parameter V_CIM_TILES_OUT = (INPUT_CHANNELS*KERNEL_DIM**2 + XBAR_SIZE-1) / XBAR_SIZE,
    parameter NUM_ADDR = $rtoi($ceil(INPUT_CHANNELS*KERNEL_DIM**2 / (BUS_WIDTH * V_CIM_TILES_OUT))),
    parameter ADDR_WIDTH = (NUM_ADDR <= 1) ? 1 : $clog2(NUM_ADDR)
) (
    input clk,
    input [COUNT_WIDTH-1:0] i_count,
    input [INPUT_CHANNELS-1:0] i_write_enable,
    input [DATA_SIZE-1:0] i_data [INPUT_CHANNELS-1:0],
    output reg [BUS_WIDTH*V_CIM_TILES_OUT-1:0] o_data,
    input [ADDR_WIDTH-1:0] i_ibuf_addr
);

localparam FIFO_LENGTH = IMG_DIM * (KERNEL_DIM - 1) + KERNEL_DIM;
reg [DATA_SIZE-1:0] fifo_data [FIFO_LENGTH-1:0][INPUT_CHANNELS-1:0];

// FIFO shift register
always_ff @(posedge clk) begin
    for (int input_channel = 0; input_channel < INPUT_CHANNELS; input_channel++) begin
        if (i_write_enable[input_channel]) begin
            fifo_data[0][input_channel] <= i_data[input_channel];
            for (int fifo_idx = 0; fifo_idx < FIFO_LENGTH - 1; fifo_idx++) begin
                fifo_data[fifo_idx + 1][input_channel] <= fifo_data[fifo_idx][input_channel]; 
            end
        end
    end
end

localparam REORDER_WIDTH = BUS_WIDTH * V_CIM_TILES_OUT > INPUT_CHANNELS*KERNEL_DIM**2 ? BUS_WIDTH * V_CIM_TILES_OUT : INPUT_CHANNELS*KERNEL_DIM**2 + BUS_WIDTH * V_CIM_TILES_OUT;
wire [DATA_SIZE-1:0] kernel_elements [INPUT_CHANNELS*KERNEL_DIM**2-1:0];
wire [REORDER_WIDTH-1:0] reorder [DATA_SIZE-1:0];
wire [BUS_WIDTH*V_CIM_TILES_OUT-1:0] reorder2 [DATA_SIZE-1:0][NUM_ADDR-1:0];

genvar i, j, k;
generate
    // extract kernel elements from FIFO
    for (i = 0; i < INPUT_CHANNELS; i++) begin
        for (j = 0; j < KERNEL_DIM; j++) begin
            for (k = 0; k < KERNEL_DIM; k++) begin
                assign kernel_elements[i*KERNEL_DIM**2+j*KERNEL_DIM+k] = fifo_data[j*IMG_DIM + k][i];
            end
        end
    end

    // map kernel elements to o_data
    for (i = 0; i < INPUT_CHANNELS; i++) begin // INPUT CHANNEL
        for (j = 0; j < KERNEL_DIM**2; j++) begin // KERNEL DIM 1
            for (k = 0; k < DATA_SIZE; k++) begin // KERNEL DIM 2
                assign reorder[k][i*KERNEL_DIM**2 + j] = kernel_elements[i*KERNEL_DIM**2+j][k];
            end
        end
    end
    for (i = 0; i < DATA_SIZE; i++) begin
        for (j = 0; j < NUM_ADDR; j++) begin
            assign reorder2[i][j] = reorder[i][(j+1)*BUS_WIDTH*V_CIM_TILES_OUT-1:j*BUS_WIDTH*V_CIM_TILES_OUT];
        end
    end
endgenerate

always_comb begin
    o_data <= reorder2[i_count][i_ibuf_addr];
end

endmodule