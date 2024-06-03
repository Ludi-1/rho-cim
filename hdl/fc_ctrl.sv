typedef enum {
  S0, // Idle
  S1, // Consume
  S2, // Start CIM
  S3 // W8 CIM
} state;

module fc_ctrl #(
    parameter DATA_SIZE = 8,
    parameter INPUT_NEURONS = 201,
    parameter XBAR_SIZE = 256,
    parameter BUS_WIDTH = 16,
    parameter OBUF_BUS_WIDTH = 46,
    parameter OBUF_DATA_SIZE = (DATA_SIZE == 1) ? $clog2(XBAR_SIZE) : 2*DATA_SIZE+$clog2(XBAR_SIZE),
    parameter NUM_CHANNELS = $rtoi($floor(OBUF_BUS_WIDTH / OBUF_DATA_SIZE)),
    parameter V_CIM_TILES = (INPUT_NEURONS+XBAR_SIZE-1) / XBAR_SIZE, // THIS layer V cim tiles
    parameter FIFO_LENGTH = $rtoi($ceil($floor(XBAR_SIZE / DATA_SIZE) / NUM_CHANNELS)), // output elements per CIM tile
    parameter H_CIM_TILES_IN = $rtoi($ceil(INPUT_NEURONS / FIFO_LENGTH)), // PREV Layer H cim tiles
    parameter NUM_ADDR = $rtoi($ceil(FIFO_LENGTH*H_CIM_TILES_IN / (BUS_WIDTH * V_CIM_TILES)))
) (
    input clk,
    input rst,

    output reg o_shift_enable, // shift enable ibuf

    // Control signals prev. layer
    input i_start,
    output reg o_ready, // this ctrl unit busy

    // CIM interface
    input i_cim_ready,
    output reg o_cim_we, // RD write enable CIM tile
    output reg o_cim_start,
    output reg [$clog2(NUM_ADDR)-1:0] o_addr, // addr to CIM and ibuf

    // Control signals func unit
    input i_func_ready, // this func unit ready
    output reg o_func_start
);

int unsigned addr, next_addr;
int unsigned count, next_count;
state ctrl_state, next_ctrl_state;

assign o_addr = addr[$clog2(NUM_ADDR)-1:0];

always_ff @(posedge clk) begin
    if (rst) begin
        ctrl_state <= S0;
        count <= 0;
        addr <= 0;
    end else begin
        ctrl_state <= next_ctrl_state;
        count <= next_count;
        addr <= next_addr;
    end
end

always_comb begin
    case (ctrl_state)
        S0: begin // Idle state
            next_count = 0;
            next_addr = 0;
            o_cim_we = 0;
            o_ready = 1;
            o_func_start = 0;
            o_cim_start = 0;
            o_shift_enable = 0;
            if (i_start) begin // Start signal comes in
                if (i_cim_ready) begin // If CIM ready
                    next_ctrl_state = S1; // Start consuming ibuf
                end else begin // If not ready
                    next_ctrl_state = S0; // Stay Idle
                end
            end else begin // Stay in idle state
                next_ctrl_state = S0;
            end
        end
        S1: begin // Consume IBUF, write RD BUF
            next_count = count;
            o_cim_we = 1;
            o_ready = 0;
            o_func_start = 0;
            o_cim_start = 0;
            o_shift_enable = 0;
            if (addr >= NUM_ADDR - 1) begin // max addr, done consume
                next_ctrl_state = S2; // start CIM
                next_addr = addr;
            end else begin
                next_ctrl_state = S1; // wait
                next_addr = addr + 1;
            end
        end
        S2: begin // Start CIM
            next_count = count;
            next_addr = 0;
            o_cim_we = 0;
            o_ready = 0;
            o_func_start = 0;
            o_shift_enable = 0;
            if (!i_cim_ready) begin
                next_ctrl_state = S3; // CIM is now busy
                o_cim_start = 0;
            end else begin
                next_ctrl_state = S2; // CIM not yet started
                o_cim_start = 1;
            end
        end
        S3: begin
            next_addr = 0;
            o_cim_we = 0;
            o_ready = 0;
            o_cim_start = 0;
            o_func_start = 0;
            if (i_cim_ready) begin // CIM finished activating
                if (count >= DATA_SIZE - 1) begin
                    o_shift_enable = 0;
                    next_count = count;
                    if (i_func_ready) begin // func ready to consume obuf
                        next_ctrl_state = S0; // go back to idle
                        o_func_start = 1; // start func
                    end else begin // func still busy
                        next_ctrl_state = S3; // wait
                    end
                end else begin
                    next_count = count + 1;
                    o_func_start = 0;
                    o_shift_enable = 1;
                    next_ctrl_state = S1; // consume next iteration
                end
            end else begin // CIM still busy
                next_count = count;
                o_func_start = 0;
                o_shift_enable = 0;
                next_ctrl_state = S3; // wait
            end
        end
        default: begin
            next_count = 0;
            next_addr = 0;
            o_cim_we = 0;
            o_ready = 0;
            o_func_start = 0;
            o_cim_start = 0;
            o_shift_enable = 0;
            next_ctrl_state = S0;
        end
    endcase
end

endmodule
