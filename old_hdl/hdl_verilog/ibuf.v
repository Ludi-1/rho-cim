module ibuf #(
    parameter datatype_size = 8,
    parameter fifo_length = 5
) (
    input clk,
    input i_write_enable,
    input [datatype_size-1:0] i_data,
    output reg [datatype_size-1:0] o_data [fifo_length*2-1:0]
);

genvar i;
integer j;

reg r_we, r_we_next;

always @(posedge clk) begin
    r_we <= r_we_next;
    if (i_write_enable) begin
        r_we_next <= 1'b1;
    end else begin
        r_we_next <= 1'b0;
    end
end

bram_sp #(datatype_size, 1) fifo_mem (
    .rd_addr(1'b0),
    .wr_addr(1'b0),
    .d_in(i_data),
    .we(i_write_enable),
    .clk(clk),
    .d_out(o_data[0])
);

generate
    for (i = 1; i < fifo_length*2; i++) begin
        bram_sp #(datatype_size, 1) fifo_mem (
            .rd_addr(1'b0),
            .wr_addr(1'b0),
            .d_in(o_data[i - 1]),
            .we(i_write_enable),
            .clk(clk),
            .d_out(o_data[i])
        );
    end
endgenerate

`ifdef COCOTB_SIM
initial begin
    // $dumpfile ("output/ibuf.fst");
    for(int fifo_idx = 0; fifo_idx < fifo_length*2; fifo_idx ++) begin
        $dumpvars (0, o_data[fifo_idx]);
    end
  #1;
end
`endif

endmodule