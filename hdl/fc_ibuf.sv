module fc_ibuf #(
    parameter DATA_WIDTH = 8,
    parameter INPUT_NEURONS = 128,
    parameter OUTPUT_NEURONS = 128,
    parameter XBAR_SIZE = 128,
    parameter BUS_WIDTH = 16,
    parameter fifo_length = $rtoi($floor(XBAR_SIZE / DATA_WIDTH)), // output elements per CIM tile
    parameter h_cim_tiles_in = $rtoi($ceil(INPUT_NEURONS / fifo_length)), // PREV Layer H cim tiles
    parameter v_cim_tiles_out = $rtoi($ceil(INPUT_NEURONS / XBAR_SIZE)), // THIS layer V cim tiles
    parameter num_addr = $rtoi($ceil(fifo_length*h_cim_tiles_in / (BUS_WIDTH * v_cim_tiles_out)))
)
(
    input wire clk,
    input wire i_we, // Write enable -> fifo write enable
    input wire i_se, // Shift enable -> per-element binary shift
    input wire [$clog2(num_addr)-1:0] i_ibuf_addr,
    input wire [DATA_WIDTH-1:0] i_data [h_cim_tiles_in-1:0],     // Data in (write)
    output reg [BUS_WIDTH*v_cim_tiles_out-1:0] o_data     // Data out (read)
);

reg [DATA_WIDTH-1:0] fifo_data [fifo_length-1:0][h_cim_tiles_in-1:0];

always_ff @(posedge clk) begin
    if (i_we) begin // write enable -> shift down
        for (int i = 0; i < h_cim_tiles_in; i++) begin
            fifo_data[0][i] <= i_data[i];
            for (int fifo_idx = 0; fifo_idx < fifo_length - 1; fifo_idx++) begin
                fifo_data[fifo_idx + 1][i] <= fifo_data[fifo_idx][i]; 
            end
        end
    end else if (i_se) begin // read enable -> shift right
        for (int i = 0; i < h_cim_tiles_in; i++) begin
            for (int fifo_idx = 0; fifo_idx < fifo_length; fifo_idx++) begin
                fifo_data[fifo_idx][i] <= fifo_data[fifo_idx][i] >> 1; 
            end
        end
    end
end

localparam excess_elements = (fifo_length*h_cim_tiles_in) % (BUS_WIDTH * v_cim_tiles_out);
wire [fifo_length*h_cim_tiles_in+excess_elements-1:0] reorder;
wire [BUS_WIDTH*v_cim_tiles_out-1:0] reorder2 [num_addr-1:0];

assign reorder[fifo_length*h_cim_tiles_in+excess_elements-1:fifo_length*h_cim_tiles_in-1] = 0;

genvar i, j, k;
generate
    for (i = 0; i < fifo_length; i++) begin
        for (j = 0; j < h_cim_tiles_in; j++) begin
            assign reorder[i+j*h_cim_tiles_in] = fifo_data[i][j][0];
        end
    end
    for (k = 0; k < num_addr; k++) begin
        assign reorder2[k] = reorder[(k+1)*BUS_WIDTH*v_cim_tiles_out-1:k*BUS_WIDTH*v_cim_tiles_out];
    end
endgenerate

assign o_data = reorder2[i_ibuf_addr];

endmodule