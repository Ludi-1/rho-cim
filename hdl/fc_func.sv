// Func unit when next layer is MLP

typedef enum {
    s_func_idle, // Idle
    s_func_busy // Consume obuf
} t_func_state;

module fc_func #(
    parameter DATA_SIZE = 8,
    parameter INPUT_NEURONS = 128,
    parameter OUTPUT_NEURONS = 512,
    parameter XBAR_SIZE = 256,
    parameter OBUF_BUS_WIDTH = 46,
    parameter OBUF_DATA_SIZE = (DATA_SIZE == 1) ? $clog2(XBAR_SIZE) : 2*DATA_SIZE+$clog2(XBAR_SIZE),
    parameter H_CIM_TILES = $rtoi($ceil(OUTPUT_NEURONS * DATA_SIZE / XBAR_SIZE)), // THIS layer H cim tiles
    parameter V_CIM_TILES = (INPUT_NEURONS+XBAR_SIZE-1) / XBAR_SIZE, // THIS layer V cim tiles
    parameter ELEMENTS_PER_TILE = $rtoi($floor(XBAR_SIZE / DATA_SIZE)), // num elements in output buffer
    parameter NUM_CHANNELS = $rtoi($floor(OBUF_BUS_WIDTH / OBUF_DATA_SIZE)), // elements read in parallel
    parameter NUM_ADDR = $rtoi($ceil(ELEMENTS_PER_TILE / NUM_CHANNELS)) // num addresses for obuf
) (
    input clk,
    input rst,

    // Prev module interface
    input i_start,
    output reg o_ready,

    // CIM Interface
    input i_cim_ready,
    input logic [OBUF_DATA_SIZE-1:0] i_data [H_CIM_TILES-1:0][NUM_CHANNELS-1:0][V_CIM_TILES-1:0], // Data from CIM obuf to FPGA
    output reg [$clog2(NUM_ADDR)-1:0] o_addr,

    // Next module interface
    output logic [DATA_SIZE-1:0] o_data [H_CIM_TILES-1:0][NUM_CHANNELS-1:0], // Data from FPGA func to input buffer
    output reg o_write_enable,
    input i_next_ready,
    output o_start // start next module
);

// assert property (1 == 0);

int unsigned addr, next_addr;
t_func_state func_state, next_func_state;

logic [OBUF_DATA_SIZE+$clog2(V_CIM_TILES)-1:0] acc_data [H_CIM_TILES-1:0][NUM_CHANNELS-1:0];

assign o_addr = addr[$clog2(NUM_ADDR)-1:0];

// accumulate & relu & batch norm(?)
always_comb begin
    for (int i = 0; i < H_CIM_TILES; i++) begin
        for (int j = 0; j < NUM_CHANNELS; j++) begin
            acc_data[i][j] = 0;
            for (int k = 0; k < V_CIM_TILES; k++) begin
                acc_data[i][j] += i_data[i][j][k];
            end
            if (acc_data[i][j][OBUF_DATA_SIZE+$clog2(V_CIM_TILES)-1]) begin // RELU & batchnorm
                o_data[i][j] = 0;
            end else begin
                o_data[i][j] = acc_data[i][j][DATA_SIZE-1:0];
            end
        end
    end
end

always_ff @(posedge clk) begin
    if (rst) begin
        func_state <= s_func_idle;
        addr <= 0;
    end else begin
        func_state <= next_func_state;
        addr <= next_addr;
    end
end

always_comb begin
    case (func_state)
        s_func_idle: begin // Idle state
            next_addr = 0;
            o_ready = 1;
            o_write_enable = 0;
            o_start = 0;
            if (i_start) begin // Start signal comes in
                if (i_cim_ready && i_next_ready) begin // If next module ready
                    next_func_state = s_func_busy; // start consuming obuf
                end else begin // If next module not busy
                    next_func_state = s_func_idle; // idle
                end
            end else begin // Stay in reset state
                next_func_state = s_func_idle;
            end
        end
        s_func_busy: begin // Busy state
            o_ready = 0;
            o_write_enable = 1;
            o_start = 0;
            next_addr = addr + 1;
            next_func_state = s_func_busy;
            if (addr >= NUM_ADDR - 1) begin
                next_func_state = s_func_idle;
                next_addr = 0;
                o_start = 1;
            end
        end
        default: begin
            o_start = 0;
            next_addr = 0;
            o_ready = 0;
            o_write_enable = 0;
            next_func_state = s_func_idle;
        end
    endcase
end

endmodule
