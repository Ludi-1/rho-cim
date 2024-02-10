typedef enum {
  s_conv_ctrl_reset, // Reset
  s_conv_ctrl_idle, // Idle
  s_conv_ctrl_busy, // Busy
  s_conv_ctrl_start_next // Start next
} t_conv_ctrl_state;

module conv_ctrl #(
    parameter datatype_size = 8,
    parameter input_channels = 5,
    parameter kernel_dim = 3,
    parameter xbar_size = 256,
    parameter input_size = input_channels*(kernel_dim**2),
    parameter v_cim_tiles = (input_size + xbar_size - 1) / xbar_size // ceiled division
) (
    input clk,
    input rst,
    input i_start,
    input i_cim_busy,
    output reg o_cim_we,
    input i_func_busy,
    output reg o_busy,
    input [datatype_size-1:0] i_data [input_channels*(kernel_dim**2)-1:0],
    output reg [$clog2(xbar_size)-1:0] o_cim_addr,
    output reg [datatype_size-1:0] o_data [v_cim_tiles-1:0]
);

localparam count_limit = v_cim_tiles > 1 ? xbar_size : input_size;
int unsigned cim_addr, next_cim_addr;
int unsigned input_count, next_input_count;
t_conv_ctrl_state ctrl_state, next_ctrl_state;

assign o_cim_addr = cim_addr[$clog2(xbar_size)-1:0];

genvar i;
generate
    for (i = 0; i < v_cim_tiles; i++) begin
        assign o_data[i] = i_data[cim_addr + i*xbar_size];
    end
endgenerate

always_ff @(posedge clk) begin
    if (rst) begin
        ctrl_state <= s_conv_ctrl_reset;
        input_count <= 0;
        cim_addr <= 0;
    end else begin
        ctrl_state <= next_ctrl_state;
        input_count <= next_input_count;
        cim_addr <= next_cim_addr;
    end
end

always_comb begin
    case (ctrl_state)
        s_conv_ctrl_reset: begin // Reset state
            next_input_count = 0;
            next_cim_addr = 0;
            if (i_start & !rst) begin // Start signal comes in
                o_busy = 1;
                if (i_cim_busy) begin // If next module busy
                    next_ctrl_state = s_conv_ctrl_idle; // Idle until not busy
                end else begin // If next module not busy
                    next_ctrl_state = s_conv_ctrl_busy; // Start transfer
                end
            end else begin // Stay in reset state
                o_cim_we = 0;
                o_busy = 0;
                next_ctrl_state = s_conv_ctrl_reset;
            end
        end
        s_conv_ctrl_idle: begin // Idle state
            o_busy = 1;
            next_input_count = 0;
            next_cim_addr = 0;
            if (!i_cim_busy) begin
                o_cim_we = 1;
                next_ctrl_state = s_conv_ctrl_busy;
            end else begin
                o_cim_we = 0;
                next_ctrl_state = s_conv_ctrl_idle;
            end
        end
        s_conv_ctrl_busy: begin // Busy state
            o_busy = 1;
            if (input_count >= count_limit - 1) begin
                o_cim_we = 0;
                if (!i_func_busy) begin
                    next_ctrl_state = s_conv_ctrl_start_next; // Start
                    next_input_count = 0;
                    next_cim_addr = 0;
                end else begin
                    next_ctrl_state = s_conv_ctrl_busy;
                    next_input_count = input_count;
                    next_cim_addr = cim_addr;
                end
            end else begin
                o_cim_we = 1;
                next_ctrl_state = s_conv_ctrl_busy;
                next_input_count = input_count + 1;
                if (cim_addr >= xbar_size - 1) begin
                    next_cim_addr = 0;
                end else begin
                    next_cim_addr = cim_addr + 1;
                end
            end
        end
        s_conv_ctrl_start_next: begin
            o_busy = 0;
            o_cim_we = 0;
            next_cim_addr = 0;
            next_input_count = 0;
            if (i_cim_busy) begin
                next_ctrl_state = s_conv_ctrl_reset;
            end else begin
                next_ctrl_state = s_conv_ctrl_start_next;
            end
        end
        default: next_ctrl_state = s_conv_ctrl_reset;
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
