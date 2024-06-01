typedef enum {
    s_conv_func_idle, // Idle
    s_conv_func_busy // Consume obuf
} t_conv_func_state;

module conv_func #(
    parameter DATA_SIZE = 8,
    parameter INPUT_CHANNELS = 2,
    parameter KERNEL_DIM = 3,
    parameter OUTPUT_CHANNELS = 4,
    parameter XBAR_SIZE = 128,
    parameter OBUF_BUS_WIDTH = 46,
    parameter OBUF_DATA_SIZE = (DATA_SIZE == 1) ? $clog2(XBAR_SIZE) : 2*DATA_SIZE+$clog2(XBAR_SIZE),
    parameter H_CIM_TILES = (OUTPUT_CHANNELS * DATA_SIZE + XBAR_SIZE - 1) / XBAR_SIZE, // THIS layer H cim tiles
    parameter V_CIM_TILES = (INPUT_CHANNELS*KERNEL_DIM**2+XBAR_SIZE-1) / XBAR_SIZE, // THIS layer V cim tiles
    parameter ELEMENTS_PER_TILE = $rtoi($floor(XBAR_SIZE / DATA_SIZE)), // num elements in output buffer
    parameter NUM_CHANNELS = $rtoi($floor(OBUF_BUS_WIDTH / OBUF_DATA_SIZE)), // elements read in parallel
    parameter NUM_ADDR = $rtoi($ceil(ELEMENTS_PER_TILE / NUM_CHANNELS)) // num addresses for obuf
) (
    input clk,
    input rst,

    // prev module interface
    input i_start,
    output reg o_ready,

    // CIM interface
    input i_cim_ready,
    input [OBUF_DATA_SIZE-1:0] i_data [H_CIM_TILES-1:0][NUM_CHANNELS-1:0][V_CIM_TILES-1:0],
    output reg [$clog2(NUM_ADDR)-1:0] o_addr,

    // Next module interface
    input i_next_ready,
    output reg [DATA_SIZE-1:0] o_data [OUTPUT_CHANNELS-1:0],
    output reg [OUTPUT_CHANNELS-1:0] o_write_enable,
    output reg o_start
);

integer unsigned addr, next_addr;
t_conv_func_state func_state, next_func_state;
reg [OUTPUT_CHANNELS-1:0] next_write_enable;

reg [OBUF_DATA_SIZE+$clog2(V_CIM_TILES)-1:0] acc_data [H_CIM_TILES-1:0][NUM_CHANNELS-1:0];
reg [DATA_SIZE-1:0] reorder [H_CIM_TILES-1:0][NUM_CHANNELS-1:0];
reg [DATA_SIZE-1:0] reorder2 [H_CIM_TILES*NUM_CHANNELS-1:0];

assign o_addr = addr[$clog2(NUM_ADDR)-1:0];

genvar i, j, k;
generate
    for (i = 0; i < OUTPUT_CHANNELS; i++) begin
        assign o_data[i] = reorder2[i % (H_CIM_TILES*NUM_CHANNELS)];
    end
endgenerate

// accumulate & relu func & batch norm(?)
always_comb begin
    for (int i = 0; i < H_CIM_TILES; i++) begin
        for(int j = 0; j < NUM_CHANNELS; j++) begin
            acc_data[i][j] = 0;
            for (int k = 0; k < V_CIM_TILES; k++) begin
                acc_data[i][j] += i_data[i][j][k];
            end
            if (acc_data[i][j][OBUF_DATA_SIZE+$clog2(V_CIM_TILES)-1]) begin // RELU & batchnorm
                reorder[i][j] = 0;
            end else begin
                reorder[i][j] = acc_data[i][j][DATA_SIZE-1:0];
            end
        end
    end
end

always_ff @(posedge clk) begin
    if (rst) begin
        func_state <= s_conv_func_idle;
        addr <= 0;
        o_write_enable <= 0;
    end else begin
        func_state <= next_func_state;
        addr <= next_addr;
        o_write_enable <= next_write_enable;
    end
end

always_comb begin
    case (func_state)
        s_conv_func_idle: begin // Reset state
            next_addr = 0;
            o_ready = 1;
            next_write_enable = 0;
            o_start = 0;
            if (i_start) begin // Start signal comes in
                if (i_cim_ready && i_next_ready) begin // If next module ready
                    next_write_enable = 0;
                    next_write_enable[H_CIM_TILES*NUM_CHANNELS-1:0] = '1;
                    next_func_state = s_conv_func_busy; // start consuming obuf
                end else begin // If next module not busy
                    next_func_state = s_conv_func_idle; // idle
                end
            end else begin // Stay in reset state
                next_func_state = s_conv_func_idle;
            end
        end
        s_conv_func_busy: begin // Idle state
            o_ready = 0;
            o_start = 0;
            if (addr >= NUM_ADDR - 1) begin
                next_func_state = s_conv_func_idle;
                next_addr = 0;
                o_start = 1;
                next_write_enable = 0;
            end else begin
                next_func_state = s_conv_func_busy;
                next_addr = addr + 1;
                next_write_enable = o_write_enable << (H_CIM_TILES * NUM_CHANNELS);
            end     
        end
        default: begin
            o_start = 0;
            next_write_enable = 0;
            o_ready = 0;
            next_addr = 0;
            next_func_state = s_conv_func_idle;
        end
    endcase
end

endmodule
