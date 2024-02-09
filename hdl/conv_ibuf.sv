module conv_ibuf #(
    parameter datatype_size = 8,
    parameter fifo_length = 720,
    parameter img_width = 28,
    parameter kernel_dim = 3
) (
    input clk,
    input i_write_enable,
    input [datatype_size-1:0] i_data,
    output reg [datatype_size-1:0] o_data [kernel_dim**2-1:0]
);

localparam fifo_length = img_width * (kernel_dim - 1) + kernel_dim;
reg [datatype_size-1:0] fifo_data [fifo_length-1:0];

always @(posedge clk) begin
    if (i_write_enable) begin
        fifo_data[0] <= i_data;
        for (int fifo_idx = 0; fifo_idx < fifo_length - 1; fifo_idx++) begin
            fifo_data[fifo_idx + 1] <= fifo_data[fifo_idx]; 
        end
    end
end

always @(*) begin
    for (int fifo_idx = 0; fifo_idx < fifo_length; fifo_idx++) begin
        o_data[fifo_idx] = fifo_data[fifo_idx]; 
    end
end

// `ifdef COCOTB_SIM
// initial begin
//     $dumpfile ("output/ibuf.fst");
//     for(int fifo_idx = 0; fifo_idx < fifo_length; fifo_idx ++) begin
//         $dumpvars (0, o_data[fifo_idx]);
//     end
//   #1;
// end
// `endif

endmodule