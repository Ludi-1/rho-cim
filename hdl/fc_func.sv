// Func unit when next layer is MLP

typedef enum {
  s_func_reset, // Reset
  s_func_idle, // Idle
  s_func_busy, // Busy
  s_func_start_next // Start next
} t_func_state;

module fc_func #(
    parameter input_size = 201,
    parameter output_size = 512,
    parameter xbar_size = 256,
    parameter h_cim_tiles = (output_size + xbar_size - 1) / xbar_size, // ceiled division
    parameter v_cim_tiles = (input_size + xbar_size - 1) / xbar_size, // ceiled division
    parameter datatype_size = 8,
    parameter output_datatype_size = 8
) (
    input clk,
    input rst,
    input i_start,
    input i_cim_busy,
    input i_next_busy,
    output reg o_busy,
    input [datatype_size-1:0] i_data [v_cim_tiles-1:0][h_cim_tiles-1:0],
    output reg [$clog2(xbar_size)-1:0] o_cim_addr,
    output reg [output_datatype_size-1:0] o_data
);

localparam count_limit = output_size;
integer unsigned cim_addr, next_cim_addr;
integer unsigned h_tile_count, next_h_tile_count;
integer unsigned output_count, next_output_count;
t_func_state func_state, next_func_state;

assign o_cim_addr = cim_addr[$clog2(xbar_size)-1:0];

always_comb begin
    o_data = 0;
    for (int i = 0; i < v_cim_tiles; i++) begin
        o_data += i_data[i][h_tile_count];
    end
end

always_ff @(posedge clk) begin
    if (rst) begin
        func_state <= s_func_reset;
        h_tile_count <= 0;
        cim_addr <= 0;
        output_count <= 0;
    end else begin
        func_state <= next_func_state;
        h_tile_count <= next_h_tile_count;
        cim_addr <= next_cim_addr;
        output_count <= next_output_count;
    end
end

always_comb begin
    case (func_state)
        s_func_reset: begin // Reset state
            next_output_count = 0;
            next_cim_addr = 0;
            next_h_tile_count = 0;
            if (i_start & !rst) begin // Start signal comes in
                o_busy = 1;
                if (i_cim_busy) begin // If next module busy
                    next_func_state = s_func_idle; // Idle until not busy
                end else begin // If next module not busy
                    next_func_state = s_func_busy; // Start transfer
                end
            end else begin // Stay in reset state
                o_busy = 0;
                next_func_state = s_func_reset;
            end
        end
        s_func_idle: begin // Idle state
            o_busy = 1;
            next_output_count = 0;
            next_cim_addr = 0;
            next_h_tile_count = 0;
            if (!i_cim_busy) begin
                next_func_state = s_func_busy;
            end else begin
                next_func_state = s_func_idle;
            end
        end
        s_func_busy: begin // Busy state
            o_busy = 1;
            if (output_count >= count_limit - 1) begin
                if (!i_next_busy) begin // If functional unit of next layer not busy
                    next_func_state = s_func_start_next; // Start
                    next_output_count = 0;
                    next_cim_addr = 0;
                    next_h_tile_count = 0;
                end else begin
                    next_func_state = s_func_busy;
                    next_cim_addr = cim_addr;
                    next_output_count = output_count;
                    next_h_tile_count = h_tile_count;
                end
            end else begin
                next_func_state = s_func_busy;
                next_output_count = output_count + 1;
                if (cim_addr >= xbar_size - 1) begin
                    next_cim_addr = 0;
                    next_h_tile_count = h_tile_count + 1;
                end else begin
                    next_cim_addr = cim_addr + 1;
                end
            end
        end
        s_func_start_next: begin
            o_busy = 0;
            next_cim_addr = 0;
            next_output_count = 0;
            next_h_tile_count = 0;
            if (i_cim_busy) begin
                next_func_state = s_func_reset;
            end else begin
                next_func_state = s_func_start_next;
            end
        end
        default: next_func_state = s_func_reset;
    endcase
end

endmodule
