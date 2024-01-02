module ctrl #(
    parameter datatype_size = 8,
    parameter input_size = 5,
    parameter xbar_size = 256,
    parameter vertical_tiles = $floor(input_size / xbar_size)
) (
    input clk,
    input rst,
    input i_start_ctrl,
    input [datatype_size-1:0] i_data [input_size-1:0],
    output o_busy,
    output o_start_cim,
    output reg [datatype_size-1:0] o_data [vertical_tiles-1:0]
);

integer count, next_count, address, next_address;
parameter s_idle = 2'b00;
parameter s_transfer = 2'b01;
parameter s_activate = 2'b10;

reg [1:0] state, next_state;

always @(posedge clk) begin
    if (rst) begin
        state <= s_idle;
        count <= 0;
        address <= 0;
    end else begin
        state <= next_state;
        count <= next_count;
        address <= next_address;
    end

    case (state)
        s_idle: begin
            next_count <= 0;
            next_address <= 0;
            if (i_start_ctrl) begin
                next_state <= s_transfer;
            end else begin
                next_state <= s_idle;
            end
        end
        s_transfer: begin
            next_count <= count + 1;
            if (address == xbar_size) begin
                next_address <= 0;
            end else begin
                next_address <= address + 1;
            end
            if (count == input_size) begin
                next_state <= s_activate;
            end else begin
                next_state <= s_idle;
            end
        end
        s_activate: begin
            next_count <= 0;
            next_address <= 0;
            next_state <= s_idle;
        end
        default: begin
            next_state <= s_idle;
        end
    endcase

end

always @(*) begin
    for (integer output_idx = 0; output_idx < vertical_tiles; output_idx++) begin
        o_data[output_idx] <= i_data[output_idx*count];
    end
end

// `ifdef COCOTB_SIM
// initial begin
//     $dumpfile ("output/ctrl.fst");
//     for(integer output_idx = 0; output_idx < vertical_tiles; output_idx++) begin
//         $dumpvars (0, o_data[output_idx]);
//     end
//   #1;
// end
// `endif

endmodule
