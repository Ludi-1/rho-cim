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
        f'\tparameter NUM_CHANNELS = $rtoi($floor(OBUF_BUS_WIDTH / OBUF_DATA_SIZE)),\n'
        f'\tparameter FIFO_LENGTH = $rtoi($ceil($floor(XBAR_SIZE / DATA_SIZE) / NUM_CHANNELS)),\n'
    )

    ports += (
        f'\tinput clk,\n'
        f'\tinput rst,\n'
    )

    n = 0
    param_dict_tuple[1]["layer_list"].insert(0, [None])
    for prev_layer, current_layer in zip_longest(param_dict_tuple[1]["layer_list"], param_dict_tuple[1]["layer_list"][1:], fillvalue = [None]):
        print(prev_layer, current_layer)
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
                            f'\tparameter L{n}_H_CIM_TILES = $rtoi($ceil(L{n}_OUTPUT_NEURONS*DATA_SIZE/XBAR_SIZE)),\n'
                        )
                        ports += (
                            f'\tinput L{n}_i_cim_ready,\n'
                            f'\toutput [BUS_WIDTH*L{n}_V_CIM_TILES-1:0] L{n}_o_cim_data\n'
                            f'\toutput L{n}_o_cim_we,\n'
                            f'\toutput [$clog2(L{n}_NUM_ADDR)-1:0] L{n}_o_cim_rd_addr,\n'
                            f'\tinput [OBUF_DATA_SIZE-1:0] L{n}_i_cim_data [L{n}_H_CIM_TILES-1:0][L{n}_NUM_CHANNELS-1:0][L{n}_V_CIM_TILES-1:0],\n'
                            f'\toutput [$clog2(L{n}_NUM_ADDR_OBUF)-1:0] L{n}_o_cim_obuf_addr,\n'
                        )
                        if prev_layer[0] is None:
                            ports += (
                                f'\tinput L{n}_i_ibuf_we,\n'
                                f'\tinput [DATA_SIZE-1:0] L{n}_i_ibuf_wr_data [L{n}_H_CIM_TILES_IN-1:0][L{n}_NUM_CHANNELS-1:0],\n'
                                f'\tinput L{n}_i_start,\n'
                                f'\toutput L{n}_o_ready,\n'
                            )
                            signals += (
                                f'wire L{n}_next_ready;\n'
                                f'wire [DATA_SIZE-1:0] L{n}_next_data [L{n}_H_CIM_TILES-1:0][L{n}_NUM_CHANNELS-1:0];\n'
                                f'wire L{n}_next_we;\n'
                                f'wire L{n}_next_start;\n'           
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
                                f'\t.i_next_ready(L{n}_next_ready),\n'
                                f'\t.o_next_data(L{n}_next_data),\n'
                                f'\t.o_next_we(L{n}_next_we),\n'
                                f'\t.o_next_start(L{n}_next_start)\n);\n'
                            )
                        elif prev_layer[0] == "fc":
                            signals += (
                            f'wire L{n}_next_ready;\n'
                            f'wire [DATA_SIZE-1:0] L{n}_next_data [L{n}_H_CIM_TILES-1:0][L{n}_NUM_CHANNELS-1:0];\n'
                            f'wire L{n}_next_we;\n'
                            f'wire L{n}_next_start;\n'           
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
                                f'\t.i_next_ready(L{n}_next_ready),\n'
                                f'\t.o_next_data(L{n}_next_data),\n'
                                f'\t.o_next_we(L{n}_next_we),\n'
                                f'\t.o_next_start(L{n}_next_start)\n);\n'
                            )
                        else:
                            raise Exception(f"Bad layers {prev_layer[0]} - {current_layer[0]}")
                    case "conv" | "pool":
                        parameters += (f"\tparameter L{n}_IMG_SIZE = {current_layer[1]},\n")
                        parameters += (f"\tparameter L{n}_INPUT_CHANNELS = {current_layer[3]},\n")
                        ports += (
                            f'\tinput L{n}_i_cim_ready,\n'
                            f'\toutput [ADDR_WIDTH-1:0] L{n}_o_cim_rd_addr,\n'
                            f'\toutput [BUS_WIDTH*L{n}_V_CIM_TILES-1:0] L{n}_o_cim_data\n'
                            f'\toutput L{n}_o_cim_we,\n'
                            f'\tinput [OBUF_DATA_SIZE-1:0] L{n}_i_cim_data [L{n}_H_CIM_TILES-1:0][L{n}_NUM_CHANNELS-1:0][L{n}_V_CIM_TILES-1:0],\n'
                            f'\toutput [$clog2(L{n}_NUM_ADDR_OBUF)-1:0] L{n}_o_cim_obuf_addr,\n'
                        )
                        signals += (
                            f'wire L{n}_next_ready;\n'
                            f'wire [DATA_SIZE-1:0] L{n}_next_data [L{n}_H_CIM_TILES-1:0][L{n}_NUM_CHANNELS-1:0];\n'
                            f'wire L{n}_next_we;\n'
                            f'wire L{n}_next_start;\n'           
                        )
                        modules += (
                            f'flatten_fc_layer #(\n'
                            '\t.DATA_SIZE(DATA_SIZE),\n'
                            f'\t.IMG_SIZE(L{n}_IMG_SIZE),\n'
                            f'\t.OUTPUT_NEURONS(L{n}_OUTPUT_NEURONS),\n'
                            '\t.XBAR_SIZE(XBAR_SIZE),\n'
                            '\t.BUS_WIDTH(BUS_WIDTH),\n'
                            '\t.OBUF_BUS_WIDTH(OBUF_BUS_WIDTH)\n'
                            f') L{n}_fc_layer (\n'
                            '\t.clk(clk),\n'
                            '\t.rst(rst),\n'
                            f'\t.i_ibuf_we(L{n}_ibuf_we),\n'
                            f'\t.i_ibuf_data(L{n}_ibuf_wr_data),\n'
                            f'\t.i_start(L{n}_start),\n'
                            f'\t.o_ready(L{n}_ready),\n'
                            f'\t.i_cim_ready(L{n}_i_cim_ready),\n'
                            f'\t.o_cim_wr_addr(L{n}_o_cim_wr_addr),\n'
                            f'\t.o_cim_data(L{n}_o_cim_data),\n'
                            f'\t.o_cim_we(L{n}_o_cim_we),\n'
                            f'\t.o_cim_rd_addr(L{n}_o_cim_rd_addr),\n'
                            f'\t.i_cim_data(L{n}_i_cim_data),\n'
                            f'\t.o_cim_obuf_addr(L{n}_o_cim_obuf_addr),\n'
                            f'\t.i_next_ready(L{n}_next_ready),\n'
                            f'\t.o_next_data(L{n}_next_data),\n'
                            f'\t.o_next_we(L{n}_next_we),\n'
                            f'\t.o_next_start(L{n}_next_start)\n);\n'
                        )
                    case _:
                        raise Exception(f"Bad layers {prev_layer[0]} - {current_layer[0]}")
            case "conv":
                match prev_layer[0]:
                    case "conv":
                        pass
                    case "pool":
                        pass
                    case None:
                        pass
                    case _:
                        raise Exception(f"{conf_name} Bad layer {n} {prev_layer[0]} - {current_layer[0]}")
            case "pool":
                match prev_layer[0]:
                    case "conv":
                        pass
                    case _:
                        raise Exception(f"{conf_name} Bad layer {n} {prev_layer[0]} - {current_layer[0]}")
            case None:
                match prev_layer[0]:
                    case "fc":
                        ports += (
                            f'\tinput o_next_ready,\n'
                            f'\toutput [DATA_SIZE-1:0] o_next_data [L{n-1}_H_CIM_TILES-1:0][L{n-1}_NUM_CHANNELS-1:0],\n'
                            f'\toutput o_next_we,\n'
                            f'\toutput o_next_start'  
                        )
                        modules += (
                            f'assign o_next_ready = L{n-1}_next_ready;\n'
                            f'assign o_next_data = L{n-1}_next_data\n'
                            f'assign o_next_we = L{n-1}_next_we;\n'
                            f'assign o_next_start = L{n-1}_next_start;'
                        )
                    case _:
                        raise Exception(f"{conf_name} Bad layer {n} {prev_layer[0]} - {current_layer[0]}")

        n += 1

    output_hdl = TEMPLATE \
        .replace("%TOP_NAME%", conf_name) \
        .replace("%PARAMETERS%", parameters) \
        .replace("%PORTS%", ports) \
        .replace("%SIGNALS%", signals) \
        .replace("%MODULES%", modules)

    with open(f"./gen_hdl/{conf_name}.sv", "w") as f:
        f.write(output_hdl)

def gen_hdl_old(param_dict_tuple, datatype_size, crossbar_size):
    conf_name = f"{param_dict_tuple[0]}_d{datatype_size}_c{crossbar_size}"
    f = open(f"./gen_hdl/{conf_name}.sv", "w")
    f.write(f"module {conf_name.replace('-', '_')}_top #(\n")
    f.write(f"\tparameter datatype_size = {datatype_size},\n")
    f.write(f"\tparameter xbar_size = {crossbar_size},\n\n")
    param_list = []
    signal_list = []
    module_list = []
    n = 0
    for layer in param_dict_tuple[1]["layer_list"]:
        n += 1
        match layer[0]:
            case "fc":
                param_list.append(
                    f'\tparameter input_size_{n} = {layer[1]*layer[3]},\n'
                    f'\tparameter output_size_{n} = {layer[2]},\n'
                    f'\tparameter v_cim_tiles_{n} = (input_size_{n} + xbar_size - 1) / xbar_size,\n'
                    f'\tparameter h_cim_tiles_{n} = (output_size_{n}*datatype_size + xbar_size - 1) / xbar_size,\n'
                )
                signal_list.append(
                    f'\tinput i_ibuf_we_{n},\n'
                    f'\tinput [datatype_size-1:0] i_ibuf_wr_data_{n},\n'
                    f'\tinput reg [$clog2(input_size_{n})-1:0] i_ibuf_addr_{n},\n'
                    f'\tinput i_start_{n},\n'
                    f'\tinput i_cim_busy_{n},\n'
                    f'\tinput i_func_start_{n},\n'
                    f'\toutput reg o_busy_{n},\n'
                    f'\toutput reg [$clog2(xbar_size)-1:0] o_cim_wr_addr_{n},\n'
                    f'\toutput reg [datatype_size-1:0] o_cim_data_{n} [v_cim_tiles_{n}-1:0],\n'
                    f'\tinput i_next_busy_{n},\n'
                    f'\tinput [datatype_size-1:0] i_data_{n} [v_cim_tiles_{n}-1:0][h_cim_tiles_{n}-1:0],\n'
                    f'\toutput reg [$clog2(xbar_size)-1:0] o_cim_rd_addr_{n},\n'
                    f'\toutput reg [output_datatype_size-1:0] o_func_data_{n},\n'
                )
                module_list.append(
                    'fc_layer #(\n'
                    f'\t.input_size(input_size_{n}),\n'
                    f'\t.output_size(output_size_{n}),\n'
                    '\t.xbar_size(xbar_size),\n'
                    '\t.datatype_size(datatype_size),\n'
                    '\t.output_datatype_size(datatype_size)\n'
                    f') l{n}_fc_{layer[2]} (\n'
                    '\t.clk(clk),\n'
                    '\t.rst(rst),\n'
                    f'\t.i_ibuf_we(i_ibuf_we_{n}),\n'
                    f'\t.i_ibuf_wr_data(i_ibuf_wr_data_{n}),\n'
                    f'\t.i_ibuf_addr(i_ibuf_addr_{n}),\n'
                    f'\t.i_start(i_start_{n}),\n'
                    f'\t.i_cim_busy(i_cim_busy_{n}),\n'
                    f'\t.i_func_start(i_func_start_{n}),\n'
                    f'\t.o_busy(o_busy_{n}),\n'
                    f'\t.o_cim_wr_addr(o_cim_wr_addr_{n}),\n'
                    f'\t.o_cim_data(o_cim_data_{n}),\n'
                    f'\t.i_next_busy(i_next_busy_{n}),\n'
                    f'\t.i_data(i_data_{n}),\n'
                    f'\t.o_cim_rd_addr(o_cim_rd_addr_{n}),\n'
                    f'\t.o_func_data(o_func_data_{n})\n'
                    ');\n'
                )
            case "conv":
                param_list.append(
                    f'\tparameter input_channels_{n} = {layer[3]},\n'
                    f'\tparameter img_width_{n} = {layer[1]},\n'
                    f'\tparameter kernel_dim_{n} = {layer[2]},\n'
                    f'\tparameter output_size_{n} = {layer[4]},\n'
                    f'\tparameter input_size_{n} = input_channels_{n} * kernel_dim_{n}**2,\n'
                    f'\tparameter v_cim_tiles_{n} = (input_size_{n} + xbar_size - 1) / xbar_size,\n'
                    f'\tparameter h_cim_tiles_{n} = (output_size_{n}*datatype_size + xbar_size - 1) / xbar_size,\n'
                )
                signal_list.append(
                    f'\tinput i_ibuf_we_{n} [input_channels_{n}-1:0],\n'
                    f'\tinput [datatype_size-1:0] i_ibuf_wr_data_{n} [input_channels_{n}-1:0],\n'
                    f'\tinput i_start_{n},\n'
                    f'\tinput i_cim_busy_{n},\n'
                    f'\tinput i_func_start_{n},\n'
                    f'\toutput reg o_busy_{n},\n'
                    f'\toutput reg [$clog2(xbar_size)-1:0] o_cim_wr_addr_{n},\n'
                    f'\toutput reg [datatype_size-1:0] o_cim_data_{n} [v_cim_tiles_{n}-1:0],\n'

                    f'\tinput i_next_busy_{n},\n'
                    f'\tinput [datatype_size-1:0] i_data_{n} [v_cim_tiles_{n}-1:0][h_cim_tiles_{n}-1:0],\n'
                    f'\toutput reg [$clog2(xbar_size)-1:0] o_cim_rd_addr_{n},\n'
                    f'\toutput reg [output_datatype_size-1:0] o_func_data_{n},\n'
                )
                module_list.append(
                    'conv_layer #(\n'
                    f'\t.input_channels(input_channels_{n}),\n'
                    f'\t.img_width(img_width_{n}),\n'
                    f'\t.kernel_dim(kernel_dim_{n}),\n'
                    f'\t.output_size(output_size_{n}),\n'
                    '\t.xbar_size(xbar_size),\n'
                    '\t.datatype_size(datatype_size),\n'
                    '\t.output_datatype_size(datatype_size)\n'
                    f') l{n}_conv_{layer[2]}x{layer[2]} (\n'
                    '\t.clk(clk),\n'
                    '\t.rst(rst),\n'
                    f'\t.i_ibuf_we(i_ibuf_we_{n}),\n'
                    f'\t.i_ibuf_wr_data(i_ibuf_wr_data_{n}),\n'
                    f'\t.i_start(i_start_{n}),\n'
                    f'\t.i_cim_busy(i_cim_busy_{n}),\n'
                    f'\t.i_func_start(i_func_start_{n}),\n'
                    f'\t.o_busy(o_busy_{n}),\n'
                    f'\t.o_cim_wr_addr(o_cim_wr_addr_{n}),\n'
                    f'\t.o_cim_data(o_cim_data_{n}),\n'
                    f'\t.i_next_busy(i_next_busy_{n}),\n'
                    f'\t.i_data(i_data_{n}),\n'
                    f'\t.o_cim_rd_addr(o_cim_rd_addr_{n}),\n'
                    f'\t.o_func_data(o_func_data_{n})\n'
                    ');\n'
                )
            case "pool":
                param_list.append(
                    f'\tparameter input_channels_{n} = {layer[3]},\n'
                    f'\tparameter img_width_{n} = {layer[1]},\n'
                    f'\tparameter kernel_dim_{n} = {layer[2]},\n'
                    f'\tparameter output_size_{n} = input_channels_{n},\n'
                )
                signal_list.append(
                    f'\tinput i_ibuf_we_{n} [input_channels_{n}-1:0],\n'
                    f'\tinput [datatype_size-1:0] i_ibuf_wr_data_{n} [input_channels_{n}-1:0],\n'
                    f'\tinput i_start_{n},\n'
                    f'\tinput i_func_start_{n},\n'
                    f'\tinput i_next_busy_{n},\n'
                    f'\toutput reg [output_datatype_size-1:0] o_func_data_{n} [output_size_{n}-1:0],\n'
                )
                module_list.append(
                    'pool_layer #(\n'
                    f'\t.input_channels(input_channels_{n}),\n'
                    f'\t.img_width(img_width_{n}),\n'
                    f'\t.kernel_dim(kernel_dim_{n}),\n'
                    '\t.datatype_size(datatype_size),\n'
                    '\t.output_datatype_size(datatype_size)\n'
                    f') l{n}_pool_{layer[2]}x{layer[2]} (\n'
                    '\t.clk(clk),\n'
                    '\t.rst(rst),\n'
                    f'\t.i_ibuf_we(i_ibuf_we_{n}),\n'
                    f'\t.i_ibuf_wr_data(i_ibuf_wr_data_{n}),\n'
                    f'\t.i_start(i_start_{n}),\n'
                    f'\t.i_func_start(i_func_start_{n}),\n'
                    f'\t.i_next_busy(i_next_busy_{n}),\n'
                    f'\t.o_func_data(o_func_data_{n})\n'
                    ');\n'
                )
    for param in param_list:
        f.write(param + "\n")
    f.write(f"\toutput_datatype_size = {datatype_size}\n")
    f.write(") (\n")
    for signal in signal_list:
        f.write(signal + "\n")
    f.write("\tinput clk,\n")
    f.write("\tinput rst\n")
    f.write(");\n\n")
    for module in module_list:
        f.write(module + "\n")
    f.write("endmodule")