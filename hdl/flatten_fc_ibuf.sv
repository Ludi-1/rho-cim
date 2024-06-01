module flatten_fc_ibuf #(
    parameter DATA_SIZE = 8,
    parameter IMG_DIM = 28,
    parameter INPUT_CHANNELS = 2,
    parameter XBAR_SIZE = 128,
    parameter BUS_WIDTH = 16,
    parameter V_CIM_TILES_OUT = (INPUT_CHANNELS*IMG_DIM**2 + XBAR_SIZE-1) / XBAR_SIZE,
    parameter NUM_ADDR = $rtoi($ceil(INPUT_CHANNELS*IMG_DIM**2 / (BUS_WIDTH * V_CIM_TILES_OUT))),
    parameter ADDR_WIDTH = (NUM_ADDR <= 1) ? 1 : $clog2(NUM_ADDR),
    parameter COUNT_WIDTH = (DATA_SIZE==1) ? 1 : $clog2(DATA_SIZE)
) (
    input clk,
    input [INPUT_CHANNELS-1:0] i_write_enable,
    input [DATA_SIZE-1:0] i_data [INPUT_CHANNELS-1:0],
    output [BUS_WIDTH*V_CIM_TILES_OUT-1:0] o_data,
    input [ADDR_WIDTH-1:0] i_ibuf_addr,
    input [COUNT_WIDTH-1:0] i_count
);

localparam FIFO_LENGTH = IMG_DIM**2;
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

wire [DATA_SIZE-1:0] img_elements [INPUT_CHANNELS-1:0][IMG_DIM**2-1:0];
localparam excess_elements = (INPUT_CHANNELS * IMG_DIM**2) % (BUS_WIDTH * V_CIM_TILES_OUT);
wire [INPUT_CHANNELS*IMG_DIM**2+excess_elements-1:0] reorder [DATA_SIZE-1:0];
wire [BUS_WIDTH*V_CIM_TILES_OUT-1:0] reorder2 [DATA_SIZE-1:0][NUM_ADDR-1:0];

genvar i, j, k;
generate
    // extract kernel elements from FIFO
    for (i = 0; i < INPUT_CHANNELS; i++) begin
        for (j = 0; j < IMG_DIM**2; j++) begin
            assign img_elements[i][j] = fifo_data[i][j];
        end
    end

    // map kernel elements to o_data
    for (i = 0; i < INPUT_CHANNELS; i++) begin // INPUT CHANNEL
        for (j = 0; j < IMG_DIM**2; j++) begin // IMG DIM 1
            for (k = 0; k < DATA_SIZE; k++) begin // IMG DIM 2
                assign reorder[k][i*IMG_DIM**2 + j] = img_elements[i][j][k];
            end
        end
    end

    for(i = 0; i < DATA_SIZE; i++) begin
        for (j = 0; j < NUM_ADDR; j++) begin
            assign reorder2[i][j] = reorder[i][(j+1)*BUS_WIDTH*V_CIM_TILES_OUT-1:j*BUS_WIDTH*V_CIM_TILES_OUT];
        end
    end
endgenerate

assign o_data = reorder2[i_count][i_ibuf_addr];

endmodule