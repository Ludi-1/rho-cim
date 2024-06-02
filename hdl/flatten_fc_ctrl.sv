typedef enum {
  s_conv_ctrl_idle, // Idle
  s_conv_ctrl_consume, // Consume
  s_conv_ctrl_start, // Start CIM
  s_conv_ctrl_wait // W8 CIM
} t_conv_ctrl_state;

module flatten_fc_ctrl #(
    parameter DATA_SIZE = 8,
    parameter INPUT_CHANNELS = 16,
    parameter IMG_SIZE = 28**2,
    parameter XBAR_SIZE = 128,
    parameter BUS_WIDTH = 16,
    parameter V_CIM_TILES_OUT = (INPUT_CHANNELS*IMG_SIZE + XBAR_SIZE-1) / XBAR_SIZE,
    parameter COUNT_WIDTH = (DATA_SIZE==1) ? 1 : $clog2(DATA_SIZE),
    parameter NUM_ADDR = $rtoi($ceil(INPUT_CHANNELS*IMG_SIZE / (BUS_WIDTH * V_CIM_TILES_OUT))),
    parameter ADDR_WIDTH = (NUM_ADDR <= 1) ? 1 : $clog2(NUM_ADDR)
) (
    input clk,
    input rst,

    output reg [COUNT_WIDTH-1:0] o_count, // data bit count ibuf

    // Control signals prev. layer
    input i_start,
    output reg o_ready,

    // CIM interface
    input i_cim_ready,
    output reg o_cim_we,
    output reg o_cim_start,
    output [ADDR_WIDTH-1:0] o_addr, // addr to CIM and ibuf

    // Control signals func unit
    input i_func_ready,
    output reg o_func_start
);

int unsigned addr, next_addr;
int unsigned count, next_count;
int unsigned start_count, next_start_count;
t_conv_ctrl_state ctrl_state, next_ctrl_state;

assign o_addr = addr[ADDR_WIDTH-1:0];
assign o_count = count[COUNT_WIDTH-1:0];

always_ff @(posedge clk) begin
    if (rst) begin
        ctrl_state <= s_conv_ctrl_idle;
        count <= 0;
        addr <= 0;
        start_count <= 0;
    end else begin
        ctrl_state <= next_ctrl_state;
        count <= next_count;
        addr <= next_addr;
        start_count <= next_start_count;
    end
end

always_comb begin
    case (ctrl_state)
        s_conv_ctrl_idle: begin // Idle state
            next_count = 0;
            next_addr = 0;
            o_cim_we = 0;
            o_ready = 1;
            o_func_start = 0;
            o_cim_start = 0;
            next_start_count = start_count;
            if (i_start) begin // Start signal comes in
                if (start_count == IMG_SIZE-1) begin
                    if (i_cim_ready) begin // If CIM ready
                        next_ctrl_state = s_conv_ctrl_consume; // Start consuming ibuf
                        next_start_count = 0;
                    end else begin // If CIM not ready
                        next_ctrl_state = s_conv_ctrl_idle; // Stay idle
                    end
                end else begin
                    next_start_count = count + 1;
                    next_ctrl_state = s_conv_ctrl_idle;
                end
            end else begin // Stay in idle state
                next_ctrl_state = s_conv_ctrl_idle;
            end
        end
        s_conv_ctrl_consume: begin // Consume IBUF, write RD BUF
            next_count = count;
            o_cim_we = 1;
            o_ready = 0;
            o_func_start = 0;
            o_cim_start = 0;
            if (addr >= NUM_ADDR - 1) begin
                next_ctrl_state = s_conv_ctrl_start;
                next_addr = addr;
            end else begin
                next_ctrl_state = s_conv_ctrl_consume;
                next_addr = addr + 1;
            end
        end
        s_conv_ctrl_start: begin // Start CIM
            next_count = count;
            next_addr = 0;
            o_cim_we = 0;
            o_ready = 0;
            o_func_start = 0;
            if (!i_cim_ready) begin // CIM is now busy
                next_ctrl_state = s_conv_ctrl_wait;
                o_cim_start = 0;
            end else begin // CIM not started yet
                next_ctrl_state = s_conv_ctrl_start;
                o_cim_start = 1;
            end
        end
        s_conv_ctrl_wait: begin
            next_addr = 0;
            o_cim_we = 0;
            o_ready = 0;
            o_cim_start = 0;
            o_func_start = 0;
            if (i_cim_ready) begin // CIM is finished
                if (count >= DATA_SIZE-1) begin
                    next_count = count;
                    if (i_func_ready) begin
                        next_ctrl_state = s_conv_ctrl_idle;
                        o_func_start = 1;
                    end else begin // func still busy
                        next_ctrl_state = s_conv_ctrl_wait; // wait
                    end
                end else begin
                    next_count = count + 1;
                    next_ctrl_state = s_conv_ctrl_consume;
                end
            end else begin // CIM still busy
                next_count = count;
                o_func_start = 0;
                next_ctrl_state = s_conv_ctrl_wait; // wait
            end
            
        end
        default: next_ctrl_state = s_conv_ctrl_idle;
    endcase
end

endmodule
