module fc_ibuf #(
    parameter DATA_SIZE = 8,
    parameter INPUT_NEURONS = 128,
    parameter OUTPUT_NEURONS = 128,
    parameter XBAR_SIZE = 128,
    parameter BUS_WIDTH = 16,
    parameter FIFO_LENGTH = $rtoi($floor(XBAR_SIZE / DATA_SIZE)), // output elements per CIM tile
    parameter H_CIM_TILES_IN = $rtoi($ceil(INPUT_NEURONS / FIFO_LENGTH)), // PREV Layer H cim tiles
    parameter V_CIM_TILES_OUT = $rtoi($ceil(INPUT_NEURONS / XBAR_SIZE)), // THIS layer V cim tiles
    parameter NUM_ADDR = $rtoi($ceil(FIFO_LENGTH*H_CIM_TILES_IN / (BUS_WIDTH * V_CIM_TILES_OUT)))
)
(
    input wire clk,
    input wire i_we, // Write enable -> fifo write enable
    input wire i_se, // Shift enable -> per-element binary shift
    input wire [$clog2(NUM_ADDR):0] i_ibuf_addr,
    input wire [DATA_SIZE-1:0] i_data [H_CIM_TILES_IN-1:0],     // Data in (write)
    output reg [BUS_WIDTH*V_CIM_TILES_OUT-1:0] o_data     // Data out (read)
);

reg [DATA_SIZE-1:0] fifo_data [FIFO_LENGTH-1:0][H_CIM_TILES_IN-1:0];

always_ff @(posedge clk) begin
    if (i_we) begin // write enable -> shift down
        for (int i = 0; i < H_CIM_TILES_IN; i++) begin
            fifo_data[0][i] <= i_data[i];
            for (int fifo_idx = 0; fifo_idx < FIFO_LENGTH - 1; fifo_idx++) begin
                fifo_data[fifo_idx + 1][i] <= fifo_data[fifo_idx][i]; 
            end
        end
    end else if (i_se) begin // read enable -> shift right
        for (int i = 0; i < H_CIM_TILES_IN; i++) begin
            for (int fifo_idx = 0; fifo_idx < FIFO_LENGTH; fifo_idx++) begin
                fifo_data[fifo_idx][i] <= fifo_data[fifo_idx][i] >> 1; 
            end
        end
    end
end

localparam excess_elements = (FIFO_LENGTH*H_CIM_TILES_IN) % (BUS_WIDTH * V_CIM_TILES_OUT);
wire [FIFO_LENGTH*H_CIM_TILES_IN+excess_elements-1:0] reorder;
wire [BUS_WIDTH*V_CIM_TILES_OUT-1:0] reorder2 [NUM_ADDR:0];

assign reorder[FIFO_LENGTH*H_CIM_TILES_IN+excess_elements-1:FIFO_LENGTH*H_CIM_TILES_IN-1] = 0;

genvar i, j, k;
generate
    for (i = 0; i < FIFO_LENGTH; i++) begin
        for (j = 0; j < H_CIM_TILES_IN; j++) begin
            assign reorder[i+j*H_CIM_TILES_IN] = fifo_data[i][j][0];
        end
    end
    for (k = 0; k < NUM_ADDR; k++) begin
        assign reorder2[k] = reorder[(k+1)*BUS_WIDTH*V_CIM_TILES_OUT-1:k*BUS_WIDTH*V_CIM_TILES_OUT];
    end
endgenerate

assign o_data = reorder2[i_ibuf_addr];

endmodule