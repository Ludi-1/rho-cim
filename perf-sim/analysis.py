import csv
from math import ceil, log2

def analysis(conf_name, param_dict, datatype_size, crossbar_size, conv_dt):
    f = open(f"./analysis/{conf_name}.csv", "w")
    fieldnames = ['Layer', 'i_xbar', 'o_xbar', "i_s&a", "o_s&a", "i_func", "o_func"]
    writer = csv.DictWriter(f, fieldnames=fieldnames, delimiter=';')
    writer.writeheader()
    for layer in param_dict["layer_list"]:
        match layer[0]:
            case "conv":
                # inputs_pixels = layer[1]**2
                output_pixels = ((layer[1] - layer[2])/layer[5] + 1)**2
                input_channels = layer[3]
                output_channels = layer[5]
                kernel_size = layer[2]
                n_v = ceil(
                    kernel_size**2 * input_channels / crossbar_size
                )
                n_h = ceil(
                    output_channels
                    * datatype_size
                    / crossbar_size
                )
                i_xbar = output_pixels * kernel_size**2 * datatype_size * (n_h * input_channels + output_channels)
                i_sna = output_pixels * n_v * datatype_size**2 * (conv_dt + log2(crossbar_size)) / conv_dt
                i_func = output_pixels * (datatype_size + log2(crossbar_size)) * n_v
                writer.writerow({
                    'Layer': f"{layer[0]} {kernel_size}x{kernel_size}",
                    'i_xbar': i_xbar,
                    'o_xbar': i_sna,
                    'i_s&a': i_sna,
                    'o_s&a': i_func,
                    'i_func': i_func,
                    'o_func': output_pixels * output_channels * datatype_size
                })
            case "pool":
                inputs = layer[1]**2 * layer[2]
                outputs = ((layer[1] - layer[2])/layer[5] + 1)**2 * layer[2]
                writer.writerow({
                    'Layer': f"{layer[0]} {layer[2]}x{layer[2]}",
                    'i_xbar': 0,
                    'o_xbar': 0,
                    'i_s&a': 0,
                    'o_s&a': 0,
                    'i_func': inputs * datatype_size,
                    'o_func': outputs * datatype_size 
                })
            case "fc":
                inputs = layer[1] * layer[3] # input neurons * input channels
                outputs = layer[2]
                n_v = ceil(
                    inputs / crossbar_size
                )
                n_h = ceil(
                    outputs # output neurons
                    * datatype_size
                    / crossbar_size
                )
                i_xbar = datatype_size * inputs * (n_h + outputs)
                i_sna = outputs * n_v * datatype_size**2 * (conv_dt + log2(crossbar_size)) / conv_dt
                i_func = outputs * (datatype_size + log2(crossbar_size)) * n_v
                writer.writerow({
                    'Layer': f"{layer[0]} ({outputs})",
                    'i_xbar': i_xbar,
                    'o_xbar': i_sna,
                    'i_s&a': i_sna,
                    'o_s&a': i_func,
                    'i_func': i_func,
                    'o_func': outputs * datatype_size
                })
            case _:
                raise ValueError(f"Bad layer type {layer[0]}")