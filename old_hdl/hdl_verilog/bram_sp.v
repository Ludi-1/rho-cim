// Language: Verilog 2001

/*
 * Single-port BRAM
 */

`timescale 1ns / 1ps

module bram_sp #(
    parameter DATA_WIDTH = 8,
    parameter ADDRESS_WIDTH = 8
)
(
    input wire clk,
    input wire we,           // Write enable
    input wire [ADDRESS_WIDTH-1:0] rd_addr, // Read address
    input wire [ADDRESS_WIDTH-1:0] wr_addr, // Write address
    input wire [DATA_WIDTH-1:0] d_in,     // Data in (write)d
    output reg [DATA_WIDTH-1:0] d_out      // Data out (read)
);

reg [DATA_WIDTH-1:0] mem [2**(ADDRESS_WIDTH)-1:0];

always @(posedge clk) begin
    if (we) begin
        mem[wr_addr] <= d_in;
    end
    d_out <= mem[rd_addr];
end

endmodule