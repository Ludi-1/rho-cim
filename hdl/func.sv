typedef enum {
  S0, // Reset
  S1, // Idle
  S2, // Busy
  S3 // Start next
} state;

module func #(
    parameter datatype_size = 8,
    parameter input_size = 201,
    parameter xbar_size = 256,
    parameter h_cim_tiles = (output_size + xbar_size - 1) / xbar_size, // ceiled division
    parameter output_datatype_size,
    parameter output_size = 512
) (
    input clk,
    input rst,
    input i_start,
    input i_cim_busy,
    output reg o_cim_we,
    input i_func_busy,
    output reg o_busy,
    input [datatype_size-1:0] i_data [input_size-1:0],
    output reg [$clog2(xbar_size)-1:0] o_cim_addr,
    output reg [output_datatype_size-1:0] o_data [v_cim_tiles-1:0]
);

localparam count_limit = h_cim_tiles > 1 ? xbar_size : input_size;
integer unsigned cim_addr, next_cim_addr;
integer unsigned input_count, next_input_count;
state ctrl_state, next_ctrl_state;

assign o_cim_addr = cim_addr[$clog2(xbar_size)-1:0];

genvar i;
generate
    for (i = 0; i < v_cim_tiles; i++) begin
        assign o_data[i] = i_data[cim_addr + i*xbar_size];
    end
endgenerate

always_ff @(posedge clk) begin
    if (rst) begin
        ctrl_state <= S0;
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
        S0: begin // Reset state
            next_input_count = 0;
            next_cim_addr = 0;
            if (i_start & !rst) begin // Start signal comes in
                o_busy = 1;
                if (i_cim_busy) begin // If next module busy
                    next_ctrl_state = S1; // Idle until not busy
                end else begin // If next module not busy
                    next_ctrl_state = S2; // Start transfer
                end
            end else begin // Stay in reset state
                o_cim_we = 0;
                o_busy = 0;
                next_ctrl_state = S0;
            end
        end
        S1: begin // Idle state
            o_busy = 1;
            next_input_count = 0;
            next_cim_addr = 0;
            if (!i_cim_busy) begin
                o_cim_we = 1;
                next_ctrl_state = S2;
            end else begin
                o_cim_we = 0;
                next_ctrl_state = S1;
            end
        end
        S2: begin // Busy state
            o_busy = 1;
            if (input_count >= count_limit - 1) begin
                o_cim_we = 0;
                if (!i_func_busy) begin
                    next_ctrl_state = S3; // Start
                    next_input_count = 0;
                    next_cim_addr = 0;
                end else begin
                    next_ctrl_state = S2;
                    next_input_count = input_count;
                    next_cim_addr = cim_addr;
                end
            end else begin
                o_cim_we = 1;
                next_ctrl_state = S2;
                next_input_count = input_count + 1;
                if (cim_addr >= xbar_size - 1) begin
                    next_cim_addr = 0;
                end else begin
                    next_cim_addr = cim_addr + 1;
                end
            end
        end
        S3: begin
            o_busy = 0;
            o_cim_we = 0;
            next_cim_addr = 0;
            next_input_count = 0;
            if (i_cim_busy) begin
                next_ctrl_state = S0;
            end else begin
                next_ctrl_state = S3;
            end
        end
        default: next_ctrl_state = S0;
    endcase
end

endmodule
