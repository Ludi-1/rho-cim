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
    input logic [DATA_SIZE-1:0] i_data [H_CIM_TILES_IN*NUM_CHANNELS-1:0],     // Data in (write)
    output reg [BUS_WIDTH*V_CIM_TILES_OUT-1:0] o_data     // Data out (read)
);

reg [DATA_SIZE-1:0] fifo_data [FIFO_LENGTH-1:0][H_CIM_TILES_IN*NUM_CHANNELS-1:0];

always_ff @(posedge clk) begin
    if (i_we) begin
        fifo_data[0] <= i_data;
        for (int fifo_idx = FIFO_LENGTH-1; fifo_idx > 0; fifo_idx--) begin
            fifo_data[fifo_idx] <= fifo_data[fifo_idx-1];
        end
    end else if (i_se) begin
        for (int fifo_idx = 0; fifo_idx < FIFO_LENGTH; fifo_idx++) begin
            for(int i = 0; i < H_CIM_TILES_IN*NUM_CHANNELS; i++) begin
                fifo_data[fifo_idx][i] <= fifo_data[fifo_idx][i] >> 1;
            end
        end
    end
end

localparam REORDER_WIDTH = BUS_WIDTH * V_CIM_TILES_OUT > FIFO_LENGTH*H_CIM_TILES_IN*NUM_CHANNELS ? BUS_WIDTH * V_CIM_TILES_OUT : FIFO_LENGTH*H_CIM_TILES_IN*NUM_CHANNELS + BUS_WIDTH * V_CIM_TILES_OUT;
wire [REORDER_WIDTH-1:0] reorder;
wire [BUS_WIDTH*V_CIM_TILES_OUT-1:0] reorder2 [NUM_ADDR-1:0];

genvar i, j, k;
generate
    for (i = 0; i < FIFO_LENGTH; i++) begin
        for (j = 0; j < H_CIM_TILES_IN*NUM_CHANNELS; j++) begin
            assign reorder[i*H_CIM_TILES_IN*NUM_CHANNELS+j] = fifo_data[i][j][0];
        end
    end
    for (k = 0; k < NUM_ADDR; k++) begin
        assign reorder2[k] = reorder[(k+1)*BUS_WIDTH*V_CIM_TILES_OUT-1:k*BUS_WIDTH*V_CIM_TILES_OUT];
    end
endgenerate

always_comb begin
    o_data <= reorder2[i_ibuf_addr];
end

endmodule