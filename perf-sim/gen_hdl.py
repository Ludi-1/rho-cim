def gen_hdl(param_dict_tuple, datatype_size, crossbar_size):
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
                    f') fc_{layer[2]}_{n} (\n'
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
                    f') conv_{layer[2]}x{layer[2]}_{n} (\n'
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
                    f') pool_{layer[2]}x{layer[2]}_{n} (\n'
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