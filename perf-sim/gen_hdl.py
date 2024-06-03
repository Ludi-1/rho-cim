from itertools import zip_longest
from template import TEMPLATE

def gen_hdl(param_dict_tuple, datatype_size, crossbar_size, rd_bus_width, obuf_bus_width):
    conf_name = f"{param_dict_tuple[0]}_d{datatype_size}_c{crossbar_size}"
    parameters = ""
    signals = ""
    modules = ""
    ports = ""

    parameters += (
        f'\tparameter XBAR_SIZE = {crossbar_size},\n'
        f'\tparameter DATA_SIZE = {datatype_size},\n'
        f'\tparameter BUS_WIDTH = {rd_bus_width},\n'
        f'\tparameter OBUF_BUS_WIDTH = {obuf_bus_width},\n'
        f'\tparameter OBUF_DATA_SIZE = (DATA_SIZE == 1) ? $clog2(XBAR_SIZE) : 2*DATA_SIZE+$clog2(XBAR_SIZE),\n'
        f'\tparameter NUM_CHANNELS = $rtoi($floor(OBUF_BUS_WIDTH / OBUF_DATA_SIZE)),\n'
        f'\tparameter FIFO_LENGTH = $rtoi($ceil($floor(XBAR_SIZE / DATA_SIZE) / NUM_CHANNELS)),\n'
        f'\tparameter ELEMENTS_PER_TILE = $rtoi($floor(XBAR_SIZE / DATA_SIZE)),\n'
        f'\tparameter NUM_ADDR_OBUF = $rtoi($ceil(ELEMENTS_PER_TILE / NUM_CHANNELS)),\n'
    )

    ports += (
        f'\tinput clk,\n'
        f'\tinput rst,\n'
    )

    n = 0
    param_dict_tuple[1]["layer_list"].insert(0, [None])
    for prev_layer, current_layer in zip_longest(param_dict_tuple[1]["layer_list"], param_dict_tuple[1]["layer_list"][1:], fillvalue = [None]):
        match current_layer[0]:
            case "fc":
                parameters += (
                    f'\tparameter L{n}_OUTPUT_NEURONS = {current_layer[2]},\n'
                )
                match prev_layer[0]:
                    case None | "fc":
                        parameters += (
                            f'\tparameter L{n}_INPUT_NEURONS = {current_layer[1]},\n'
                            f'\tparameter L{n}_H_CIM_TILES_IN = $rtoi($ceil(L{n}_INPUT_NEURONS / FIFO_LENGTH)),\n'
                            f'\tparameter L{n}_V_CIM_TILES = $rtoi($ceil(L{n}_INPUT_NEURONS / XBAR_SIZE)),\n'
                            f'\tparameter L{n}_H_CIM_TILES = $rtoi($ceil(L{n}_OUTPUT_NEURONS / FIFO_LENGTH)),\n'
                            f'\tparameter L{n}_NUM_ADDR = $rtoi($ceil(FIFO_LENGTH*L{n}_H_CIM_TILES_IN / (BUS_WIDTH * L{n}_V_CIM_TILES))),'
                        )
                        ports += (
                            f'\tinput L{n}_i_cim_ready,\n'
                            f'\toutput [BUS_WIDTH*L{n}_V_CIM_TILES-1:0] L{n}_o_cim_data,\n'
                            f'\toutput L{n}_o_cim_we,\n'
                            f'\toutput [$clog2(L{n}_NUM_ADDR)-1:0] L{n}_o_cim_rd_addr,\n'
                            f'\tinput [OBUF_DATA_SIZE-1:0] L{n}_i_cim_data [L{n}_H_CIM_TILES-1:0][NUM_CHANNELS-1:0][L{n}_V_CIM_TILES-1:0],\n'
                            f'\toutput [$clog2(NUM_ADDR_OBUF)-1:0] L{n}_o_cim_obuf_addr,\n'
                            f'\toutput L{n}_o_cim_start,\n'
                        )
                        signals += (
                            f'wire L{n}_next_ready;\n'
                            f'wire [DATA_SIZE-1:0] L{n}_next_data [L{n}_H_CIM_TILES-1:0][NUM_CHANNELS-1:0];\n'
                            f'wire L{n}_next_we;\n'
                            f'wire L{n}_next_start;\n'           
                        )
                        if prev_layer[0] is None:
                            ports += (
                                f'\tinput L{n}_i_ibuf_we,\n'
                                f'\tinput [DATA_SIZE-1:0] L{n}_i_ibuf_wr_data [L{n}_H_CIM_TILES_IN-1:0][NUM_CHANNELS-1:0],\n'
                                f'\tinput L{n}_i_start,\n'
                                f'\toutput L{n}_o_ready,\n'
                            )
                            modules += (
                                f'fc_layer #(\n'
                                '\t.DATA_SIZE(DATA_SIZE),\n'
                                f'\t.INPUT_NEURONS(L{n}_INPUT_NEURONS),\n'
                                f'\t.OUTPUT_NEURONS(L{n}_OUTPUT_NEURONS),\n'
                                '\t.XBAR_SIZE(XBAR_SIZE),\n'
                                '\t.BUS_WIDTH(BUS_WIDTH),\n'
                                '\t.OBUF_BUS_WIDTH(OBUF_BUS_WIDTH)\n'
                                f') L{n}_fc_layer (\n'
                                '\t.clk(clk),\n'
                                '\t.rst(rst),\n'
                                f'\t.i_ibuf_we(L{n}_i_ibuf_we),\n'
                                f'\t.i_ibuf_wr_data(L{n}_i_ibuf_wr_data),\n'
                                f'\t.i_start(L{n}_i_start),\n'
                                f'\t.o_ready(L{n}_o_ready),\n'
                                f'\t.i_cim_ready(L{n}_i_cim_ready),\n'
                                f'\t.o_cim_data(L{n}_o_cim_data),\n'
                                f'\t.o_cim_we(L{n}_o_cim_we),\n'
                                f'\t.o_cim_rd_addr(L{n}_o_cim_rd_addr),\n'
                                f'\t.i_cim_data(L{n}_i_cim_data),\n'
                                f'\t.o_cim_obuf_addr(L{n}_o_cim_obuf_addr),\n'
                                f'\t.o_cim_start(L{n}_o_cim_start),\n'
                                f'\t.i_next_ready(L{n}_next_ready),\n'
                                f'\t.o_next_data(L{n}_next_data),\n'
                                f'\t.o_next_we(L{n}_next_we),\n'
                                f'\t.o_next_start(L{n}_next_start)\n);\n'
                            )
                        elif prev_layer[0] == "fc":
                            modules += (
                                f'fc_layer #(\n'
                                '\t.DATA_SIZE(DATA_SIZE),\n'
                                f'\t.INPUT_NEURONS(L{n}_INPUT_NEURONS),\n'
                                f'\t.OUTPUT_NEURONS(L{n}_OUTPUT_NEURONS),\n'
                                '\t.XBAR_SIZE(XBAR_SIZE),\n'
                                '\t.BUS_WIDTH(BUS_WIDTH),\n'
                                '\t.OBUF_BUS_WIDTH(OBUF_BUS_WIDTH)\n'
                                f') L{n}_fc_layer (\n'
                                '\t.clk(clk),\n'
                                '\t.rst(rst),\n'
                                f'\t.i_ibuf_we(L{n-1}_next_we),\n'
                                f'\t.i_ibuf_wr_data(L{n-1}_next_data),\n'
                                f'\t.i_start(L{n-1}_next_start),\n'
                                f'\t.o_ready(L{n-1}_next_ready),\n'
                                f'\t.i_cim_ready(L{n}_i_cim_ready),\n'
                                f'\t.o_cim_data(L{n}_o_cim_data),\n'
                                f'\t.o_cim_we(L{n}_o_cim_we),\n'
                                f'\t.o_cim_rd_addr(L{n}_o_cim_rd_addr),\n'
                                f'\t.i_cim_data(L{n}_i_cim_data),\n'
                                f'\t.o_cim_obuf_addr(L{n}_o_cim_obuf_addr),\n'
                                f'\t.o_cim_start(L{n}_o_cim_start),\n'
                                f'\t.i_next_ready(L{n}_next_ready),\n'
                                f'\t.o_next_data(L{n}_next_data),\n'
                                f'\t.o_next_we(L{n}_next_we),\n'
                                f'\t.o_next_start(L{n}_next_start)\n);\n'
                            )
                        else:
                            raise Exception(f"Bad layers {prev_layer[0]} - {current_layer[0]}")
                    case "conv" | "pool":
                        parameters += (
                            f'\tparameter L{n}_IMG_SIZE = {current_layer[1]},\n'
                            f'\tparameter L{n}_INPUT_CHANNELS = {current_layer[3]},\n'
                            f'\tparameter L{n}_V_CIM_TILES = (L{n}_INPUT_CHANNELS*L{n}_IMG_SIZE + XBAR_SIZE-1) / XBAR_SIZE,\n'
                            f'\tparameter L{n}_NUM_ADDR = $rtoi($ceil(L{n}_INPUT_CHANNELS*L{n}_IMG_SIZE / (BUS_WIDTH * L{n}_V_CIM_TILES))),\n'
                            f'\tparameter L{n}_ADDR_WIDTH = (L{n}_NUM_ADDR <= 1) ? 1 : $clog2(L{n}_NUM_ADDR),\n'
                            f'\tparameter L{n}_H_CIM_TILES = $rtoi($ceil(L{n}_OUTPUT_NEURONS / FIFO_LENGTH)),\n'
                        )
                        ports += (
                            f'\tinput L{n}_i_cim_ready,\n'
                            f'\toutput [L{n}_ADDR_WIDTH-1:0] L{n}_o_cim_rd_addr,\n'
                            f'\toutput [BUS_WIDTH*L{n}_V_CIM_TILES-1:0] L{n}_o_cim_data,\n'
                            f'\toutput L{n}_o_cim_we,\n'
                            f'\tinput [OBUF_DATA_SIZE-1:0] L{n}_i_cim_data [L{n}_H_CIM_TILES-1:0][NUM_CHANNELS-1:0][L{n}_V_CIM_TILES-1:0],\n'
                            f'\toutput [$clog2(NUM_ADDR_OBUF)-1:0] L{n}_o_cim_obuf_addr,\n'
                            f'\toutput L{n}_o_cim_start,\n'
                        )
                        signals += (
                            f'wire L{n}_next_ready;\n'
                            f'wire [DATA_SIZE-1:0] L{n}_next_data [L{n}_H_CIM_TILES-1:0][NUM_CHANNELS-1:0];\n'
                            f'wire L{n}_next_we;\n'
                            f'wire L{n}_next_start;\n'           
                        )
                        modules += (
                            f'flatten_fc_layer #(\n'
                            '\t.DATA_SIZE(DATA_SIZE),\n'
                            f'\t.IMG_SIZE(L{n}_IMG_SIZE),\n'
                            f'\t.INPUT_CHANNELS(L{n}_INPUT_CHANNELS),\n'
                            f'\t.OUTPUT_NEURONS(L{n}_OUTPUT_NEURONS),\n'
                            '\t.XBAR_SIZE(XBAR_SIZE),\n'
                            '\t.BUS_WIDTH(BUS_WIDTH),\n'
                            '\t.OBUF_BUS_WIDTH(OBUF_BUS_WIDTH)\n'
                            f') L{n}_fc_layer (\n'
                            '\t.clk(clk),\n'
                            '\t.rst(rst),\n'
                            f'\t.i_ibuf_we(L{n-1}_next_we),\n'
                            f'\t.i_ibuf_data(L{n-1}_next_data),\n'
                            f'\t.i_start(L{n-1}_next_start),\n'
                            f'\t.o_ready(L{n-1}_next_ready),\n'
                            f'\t.i_cim_ready(L{n}_i_cim_ready),\n'
                            f'\t.o_cim_data(L{n}_o_cim_data),\n'
                            f'\t.o_cim_we(L{n}_o_cim_we),\n'
                            f'\t.o_cim_rd_addr(L{n}_o_cim_rd_addr),\n'
                            f'\t.i_cim_data(L{n}_i_cim_data),\n'
                            f'\t.o_cim_obuf_addr(L{n}_o_cim_obuf_addr),\n'
                            f'\t.o_cim_start(L{n}_o_cim_start),\n'
                            f'\t.i_next_ready(L{n}_next_ready),\n'
                            f'\t.o_next_data(L{n}_next_data),\n'
                            f'\t.o_next_we(L{n}_next_we),\n'
                            f'\t.o_next_start(L{n}_next_start)\n);\n'
                        )
                    case _:
                        raise Exception(f"Bad layers {prev_layer[0]} - {current_layer[0]}")
            case "conv":
                parameters += (
                    f'\tparameter L{n}_IMG_DIM = {current_layer[1]},\n'
                    f'\tparameter L{n}_KERNEL_DIM = {current_layer[2]},\n'
                    f'\tparameter L{n}_INPUT_CHANNELS = {current_layer[3]},\n'
                    f'\tparameter L{n}_OUTPUT_CHANNELS = {current_layer[4]},\n'
                    f'\tparameter L{n}_V_CIM_TILES = (L{n}_INPUT_CHANNELS*L{n}_KERNEL_DIM**2 + XBAR_SIZE-1) / XBAR_SIZE,\n'
                    f'\tparameter L{n}_H_CIM_TILES = (L{n}_OUTPUT_CHANNELS * DATA_SIZE + XBAR_SIZE - 1) / XBAR_SIZE,\n'
                    f'\tparameter L{n}_NUM_ADDR = $rtoi($ceil(L{n}_INPUT_CHANNELS*L{n}_KERNEL_DIM**2 / (BUS_WIDTH * L{n}_V_CIM_TILES))),\n'
                    f'\tparameter L{n}_ADDR_WIDTH = (L{n}_NUM_ADDR <= 1) ? 1 : $clog2(L{n}_NUM_ADDR),\n'
                )
                ports += (
                    f'\toutput [BUS_WIDTH*L{n}_V_CIM_TILES-1:0] L{n}_o_cim_rd_data,\n'
                    f'\tinput L{n}_i_cim_ready,\n'
                    f'\toutput L{n}_o_cim_we,\n'
                    f'\toutput L{n}_o_cim_start,\n'
                    f'\toutput [L{n}_ADDR_WIDTH-1:0] L{n}_o_cim_rd_addr,\n'
                    f'\tinput [OBUF_DATA_SIZE-1:0] L{n}_i_cim_obuf_data [L{n}_H_CIM_TILES-1:0][NUM_CHANNELS-1:0][L{n}_V_CIM_TILES-1:0],\n'
                    f'\toutput reg [$clog2(NUM_ADDR_OBUF)-1:0] L{n}_o_cim_obuf_addr,\n'
                )
                match prev_layer[0]:
                    case "conv" | "pool" | None:
                        signals += (
                            f'wire L{n}_next_ready;\n'
                            f'wire [DATA_SIZE-1:0] L{n}_next_data [L{n}_OUTPUT_CHANNELS-1:0];\n'
                            f'wire L{n}_next_we;\n'
                            f'wire L{n}_next_start;\n'           
                        )
                        if prev_layer[0] is None:
                            ports += (
                                f'\tinput [L{n}_INPUT_CHANNELS-1:0] L{n}_i_ibuf_we,\n'
                                f'\tinput [DATA_SIZE-1:0] L{n}_i_ibuf_wr_data [L{n}_INPUT_CHANNELS-1:0],\n'
                                f'\toutput L{n}_o_ready,\n'
                                f'\tinput L{n}_i_start,\n'
                            )
                            modules += (
                                'conv_layer #(\n'
                                '\t.DATA_SIZE(DATA_SIZE),\n'
                                f'\t.IMG_DIM(L{n}_IMG_DIM),\n'
                                f'\t.KERNEL_DIM(L{n}_KERNEL_DIM),\n'
                                f'\t.INPUT_CHANNELS(L{n}_INPUT_CHANNELS),\n'
                                '\t.XBAR_SIZE(XBAR_SIZE),\n'
                                f'\t.BUS_WIDTH(BUS_WIDTH),\n'
                                f'\t.OUTPUT_CHANNELS(L{n}_OUTPUT_CHANNELS),\n'
                                '\t.OBUF_BUS_WIDTH(OBUF_BUS_WIDTH)\n'
                                f') L{n}_conv_layer (\n'
                                '\t.clk(clk),\n'
                                '\t.rst(rst),\n'
                                f'\t.i_ibuf_we(L{n}_i_ibuf_we),\n'
                                f'\t.i_ibuf_wr_data(L{n}_i_ibuf_wr_data),\n'
                                f'\t.i_start(L{n}_i_start),\n'
                                f'\t.o_ready(L{n}_o_ready),\n'
                                f'\t.i_cim_ready(L{n}_i_cim_ready),\n'
                                f'\t.o_cim_rd_data(L{n}_o_cim_rd_data),\n'
                                f'\t.o_cim_we(L{n}_o_cim_we),\n'
                                f'\t.o_cim_rd_addr(L{n}_o_cim_rd_addr),\n'
                                f'\t.i_cim_obuf_data(L{n}_i_cim_obuf_data),\n'
                                f'\t.o_cim_obuf_addr(L{n}_o_cim_obuf_addr),\n'
                                f'\t.o_cim_start(L{n}_o_cim_start),\n'
                                f'\t.i_next_ready(L{n}_next_ready),\n'
                                f'\t.o_next_data(L{n}_next_data),\n'
                                f'\t.o_next_we(L{n}_next_we),\n'
                                f'\t.o_next_start(L{n}_next_start)\n);\n'
                            )
                        else:
                            modules += (
                                'conv_layer #(\n'
                                '\t.DATA_SIZE(DATA_SIZE),\n'
                                f'\t.IMG_DIM(L{n}_IMG_DIM),\n'
                                f'\t.KERNEL_DIM(L{n}_KERNEL_DIM),\n'
                                f'\t.INPUT_CHANNELS(L{n}_INPUT_CHANNELS),\n'
                                '\t.XBAR_SIZE(XBAR_SIZE),\n'
                                f'\t.BUS_WIDTH(BUS_WIDTH),\n'
                                f'\t.OUTPUT_CHANNELS(L{n}_OUTPUT_CHANNELS),\n'
                                '\t.OBUF_BUS_WIDTH(OBUF_BUS_WIDTH)\n'
                                f') L{n}_conv_layer (\n'
                                '\t.clk(clk),\n'
                                '\t.rst(rst),\n'
                                f'\t.i_ibuf_we(L{n-1}_next_we),\n'
                                f'\t.i_ibuf_wr_data(L{n-1}_next_data),\n'
                                f'\t.i_start(L{n-1}_next_start),\n'
                                f'\t.o_ready(L{n-1}_next_ready),\n'
                                f'\t.i_cim_ready(L{n}_i_cim_ready),\n'
                                f'\t.o_cim_rd_data(L{n}_o_cim_rd_data),\n'
                                f'\t.o_cim_we(L{n}_o_cim_we),\n'
                                f'\t.o_cim_rd_addr(L{n}_o_cim_rd_addr),\n'
                                f'\t.i_cim_obuf_data(L{n}_i_cim_obuf_data),\n'
                                f'\t.o_cim_obuf_addr(L{n}_o_cim_obuf_addr),\n'
                                f'\t.o_cim_start(L{n}_o_cim_start),\n'
                                f'\t.i_next_ready(L{n}_next_ready),\n'
                                f'\t.o_next_data(L{n}_next_data),\n'
                                f'\t.o_next_we(L{n}_next_we),\n'
                                f'\t.o_next_start(L{n}_next_start)\n);\n'
                            )
                    case _:
                        raise Exception(f"{conf_name} Bad layer {n} {prev_layer[0]} - {current_layer[0]}")
            case "pool":
                match prev_layer[0]:
                    case "conv":
                        parameters += (
                            f'\tparameter L{n}_IMG_DIM = {current_layer[1]},\n'
                            f'\tparameter L{n}_INPUT_CHANNELS = {current_layer[3]},\n'
                            f'\tparameter L{n}_KERNEL_DIM = {current_layer[2]},\n'
                            f'\tparameter L{n}_OUTPUT_CHANNELS = L{n}_INPUT_CHANNELS,\n'
                        )
                        signals += (
                            f'wire L{n}_next_ready;\n'
                            f'wire [DATA_SIZE-1:0] L{n}_next_data [L{n}_OUTPUT_CHANNELS-1:0];\n'
                            f'wire L{n}_next_we;\n'
                            f'wire L{n}_next_start;\n'           
                        )
                        modules += (
                            'pool_layer #(\n'
                            '\t.DATA_SIZE(DATA_SIZE),\n'
                            f'\t.IMG_DIM(L{n}_IMG_DIM),\n'
                            f'\t.KERNEL_DIM(L{n}_KERNEL_DIM),\n'
                            f'\t.INPUT_CHANNELS(L{n}_INPUT_CHANNELS)\n'
                            f') L{n}_pool_layer (\n'
                            '\t.clk(clk),\n'
                            f'\t.i_ibuf_we(L{n-1}_next_we),\n'
                            f'\t.i_ibuf_wr_data(L{n-1}_next_data),\n'
                            f'\t.i_start(L{n-1}_next_start),\n'
                            f'\t.o_ready(L{n-1}_next_ready),\n'
                            f'\t.i_next_ready(L{n}_next_ready),\n'
                            f'\t.o_next_data(L{n}_next_data),\n'
                            f'\t.o_next_we(L{n}_next_we),\n'
                            f'\t.o_next_start(L{n}_next_start)\n);\n'
                        )
                    case _:
                        raise Exception(f"{conf_name} Bad layer {n} {prev_layer[0]} - {current_layer[0]}")
            case None:
                match prev_layer[0]:
                    case "fc":
                        ports += (
                            f'\tinput i_next_ready,\n'
                            f'\toutput [DATA_SIZE-1:0] o_next_data [L{n-1}_H_CIM_TILES-1:0][NUM_CHANNELS-1:0],\n'
                            f'\toutput o_next_we,\n'
                            f'\toutput o_next_start'  
                        )
                        modules += (
                            f'assign L{n-1}_next_ready = i_next_ready;\n'
                            f'assign o_next_data = L{n-1}_next_data;\n'
                            f'assign o_next_we = L{n-1}_next_we;\n'
                            f'assign o_next_start = L{n-1}_next_start;'
                        )
                    case _:
                        raise Exception(f"{conf_name} Bad layer {n} {prev_layer[0]} - {current_layer[0]}")
        n += 1

    output_hdl = TEMPLATE \
        .replace("%TOP_NAME%", conf_name) \
        .replace("%PARAMETERS%", parameters.rstrip(",")) \
        .replace("%PORTS%", ports) \
        .replace("%SIGNALS%", signals) \
        .replace("%MODULES%", modules)

    with open(f"./gen_hdl/{conf_name}.sv", "w") as f:
        f.write(output_hdl)