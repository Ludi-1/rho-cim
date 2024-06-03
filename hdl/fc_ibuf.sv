module fc_ibuf #(
    parameter DATA_SIZE = 8,
    parameter INPUT_NEURONS = 128,
    parameter OUTPUT_NEURONS = 128,
    parameter XBAR_SIZE = 128,
    parameter BUS_WIDTH = 16,
    parameter OBUF_BUS_WIDTH = 46,
    parameter OBUF_DATA_SIZE = (DATA_SIZE == 1) ? $clog2(XBAR_SIZE) : 2*DATA_SIZE+$clog2(XBAR_SIZE),
    parameter NUM_CHANNELS = $rtoi($floor(OBUF_BUS_WIDTH / OBUF_DATA_SIZE)),
    parameter FIFO_LENGTH = $rtoi($ceil($floor(XBAR_SIZE / DATA_SIZE) / NUM_CHANNELS)), // output elements per CIM tile
    parameter H_CIM_TILES_IN = $rtoi($ceil(INPUT_NEURONS / FIFO_LENGTH)), // PREV Layer H cim tiles
    parameter V_CIM_TILES_OUT = $rtoi($ceil(INPUT_NEURONS / XBAR_SIZE)), // THIS layer V cim tiles
    parameter NUM_ADDR = $rtoi($ceil(FIFO_LENGTH*H_CIM_TILES_IN*NUM_CHANNELS / (BUS_WIDTH * V_CIM_TILES_OUT)))
)
(
    input wire clk,
    input wire i_we, // Write enable -> fifo write enable
    input wire i_se, // Shift enable -> per-element binary shift
    input wire [$clog2(NUM_ADDR)-1:0] i_ibuf_addr,
    input wire [DATA_SIZE-1:0] i_data [H_CIM_TILES_IN-1:0][NUM_CHANNELS-1:0],     // Data in (write)
    output reg [BUS_WIDTH*V_CIM_TILES_OUT-1:0] o_data     // Data out (read)
);

reg [DATA_SIZE-1:0] fifo_data [H_CIM_TILES_IN-1:0][NUM_CHANNELS-1:0][FIFO_LENGTH-1:0];

always_ff @(posedge clk) begin
    if (i_we) begin // write enable -> shift down
        for (int i = 0; i < H_CIM_TILES_IN; i++) begin
            for(int j = 0; j < NUM_CHANNELS; j++) begin
                fifo_data[i][j][0] <= i_data[i][j];
                for (int fifo_idx = 0; fifo_idx < FIFO_LENGTH - 1; fifo_idx++) begin
                    fifo_data[i][j][fifo_idx + 1] <= fifo_data[i][j][fifo_idx]; 
                end
            end
        end
    end else if (i_se) begin // read enable -> shift right
        for (int i = 0; i < H_CIM_TILES_IN; i++) begin
            for(int j = 0; j < NUM_CHANNELS; j++) begin
                for (int fifo_idx = 0; fifo_idx < FIFO_LENGTH; fifo_idx++) begin
                    fifo_data[i][j][fifo_idx] <= fifo_data[i][j][fifo_idx] >> 1; 
                end
            end
        end
    end else begin
        fifo_data <= fifo_data;
    end
end

localparam REORDER_WIDTH = BUS_WIDTH * V_CIM_TILES_OUT > FIFO_LENGTH*H_CIM_TILES_IN*NUM_CHANNEL ? BUS_WIDTH * V_CIM_TILES_OUT : FIFO_LENGTH*H_CIM_TILES_IN*NUM_CHANNEL + BUS_WIDTH * V_CIM_TILES_OUT;
wire [REORDER_WIDTH-1:0] reorder;
wire [BUS_WIDTH*V_CIM_TILES_OUT-1:0] reorder2 [NUM_ADDR-1:0];

genvar i, j, k;
generate
    for (i = 0; i < H_CIM_TILES_IN; i++) begin
        for (j = 0; j < NUM_CHANNELS; j++) begin
            for (k = 0; k < FIFO_LENGTH; k++) begin
                assign reorder = '0;
                assign reorder[i+j*NUM_CHANNELS+k*FIFO_LENGTH*NUM_CHANNELS] = fifo_data[i][j][k][0];
            end
        end
    end
    for (k = 0; k < NUM_ADDR; k++) begin
        assign reorder2[k] = reorder[(k+1)*BUS_WIDTH*V_CIM_TILES_OUT-1:k*BUS_WIDTH*V_CIM_TILES_OUT];
    end
endgenerate

assign o_data = reorder2[i_ibuf_addr];

endmodule