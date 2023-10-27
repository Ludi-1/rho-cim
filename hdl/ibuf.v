module ibuf #(
    parameter datatype_size = 8,
    parameter fifo_length = 5
) (
    input clk,
    input i_write_enable,
    input [datatype_size] i_data,
    output [datatype_size] o_data [fifo_length]
);

integer fifo_idx;
reg [fifo_length] fifo_data;

always @(posedge clk) begin
    if (i_write_enable) begin
        fifo_data[0] <= i_data;
        for (fifo_idx = 0; fifo < fifo_length; fifo_idx++) begin
            fifo_data[i + 1] <= fifo_data[i]; 
        end
    end
end

for (fifo_idx = 0; fifo < fifo_length; fifo_idx++) begin
    o_data[i] <= fifo_data[i]; 
end

endmodule