typedef enum {
  S0, // Reset
  S1, // Idle
  S2  // Busy
} state;

module ctrl #(
    parameter datatype_size = 8,
    parameter input_size = 5,
    parameter xbar_size = 256,
    parameter output_size = 512
) (
    input clk,
    input rst,
    input i_start,
    input i_busy,
    output reg o_busy,
    input [datatype_size-1:0] i_data [input_size-1:0],
    output reg [datatype_size-1:0] o_data [(output_size%xbar_size)-1:0]
);

integer cim_addr, next_cim_addr;
state ctrl_state, next_ctrl_state;

always_ff @(posedge clk) begin
    if (rst) begin
        ctrl_state <= S0;
    end else begin
        ctrl_state <= next_ctrl_state;
    end
end

always_comb begin
    case (ctrl_state)
        S0: begin // Reset state
            if (i_start) begin // Start signal come sin
                o_busy = 1;
                if (i_busy) begin // If next module busy
                    next_ctrl_state = S1; // Idle until not busy
                end else begin // If next module not busy
                    next_ctrl_state = S2; // Start transfer
                end
            end else begin // Stay in reset state
                o_busy = 0;
                next_ctrl_state = S0;
            end
        end
        S1: begin // Idle state
            o_busy = 1;
            if (!i_busy) begin
                next_ctrl_state = S2;
            end else begin
                next_ctrl_state = S1;
            end
        end
        S2: begin // Busy state
            // if ()
        end
        default: next_ctrl_state = S0;
    endcase
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
