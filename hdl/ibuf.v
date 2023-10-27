module ibuf #(
    parameter datatype_size = 8,
    parameter fifo_length = 5
) (
    input clk,
    input [datatype_size:0] i_data,
    output [datatype_size:0] o_data
);

reg [fifo_length] fifo_data;

endmodule