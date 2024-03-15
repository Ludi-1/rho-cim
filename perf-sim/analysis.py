import csv
from math import ceil, log2

def analysis(conf_name, param_dict, datatype_size, crossbar_size, conv_dt):
    f = open(f"./analysis/{conf_name}.csv", "w")
    fieldnames = ['Layer', 'i_xbar', 'o_xbar', "i_s&a", "o_s&a", "i_func", "o_func", "inside_xbar", "outside_xbar"]
    writer = csv.DictWriter(f, fieldnames=fieldnames, delimiter=';')
    writer.writeheader()

    i_xbar_total = 0
    i_sna_total = 0
    i_func_total = 0
    o_func_total = 0
    for layer in param_dict["layer_list"]:
        match layer[0]:
            case "conv":
                # inputs_pixels = layer[1]**2
                output_pixels = ((layer[1] - layer[2])/layer[5] + 2*layer[6])**2
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
                if conv_dt == 1:
                    i_sna = output_pixels * n_v * datatype_size**2 * log2(crossbar_size)
                else:
                    i_sna = output_pixels * n_v * datatype_size**2 * (conv_dt + log2(crossbar_size)) / conv_dt
                i_func = output_pixels * (datatype_size + log2(crossbar_size)) * n_v
                o_func = output_pixels * output_channels * datatype_size
                writer.writerow({
                    'Layer': f"{layer[0]} {kernel_size}x{kernel_size}",
                    'i_xbar': i_xbar,
                    'o_xbar': i_sna,
                    'i_s&a': i_sna,
                    'o_s&a': i_func,
                    'i_func': i_func,
                    'o_func': o_func,
                    'inside_xbar': i_xbar/(i_xbar+i_sna+i_func)*100,
                    'outside_xbar': (i_sna+i_func)/(i_xbar+i_sna+i_func)*100,
                })
            case "pool":
                inputs = ((layer[1] - layer[2])/layer[5] + 1)**2 * layer[2]**2 * layer[3]
                outputs = ((layer[1] - layer[2])/layer[5] + 1)**2 * layer[4]
                i_xbar = 0
                i_sna = 0
                i_func = inputs * datatype_size
                o_func = outputs * datatype_size
                writer.writerow({
                    'Layer': f"{layer[0]} {layer[2]}x{layer[2]}",
                    'i_xbar': i_xbar,
                    'o_xbar': i_sna,
                    'i_s&a': i_sna,
                    'o_s&a': i_func,
                    'i_func': i_func,
                    'o_func': o_func,
                    'inside_xbar': i_xbar/(i_xbar+i_sna+i_func)*100,
                    'outside_xbar': (i_sna+i_func)/(i_xbar+i_sna+i_func)*100,
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
                if conv_dt == 1:
                    i_sna = outputs * n_v * datatype_size**2 * log2(crossbar_size)
                else:
                    i_sna = outputs * n_v * datatype_size**2 * (conv_dt + log2(crossbar_size)) / conv_dt
                i_func = outputs * (datatype_size + log2(crossbar_size)) * n_v
                o_func = outputs * datatype_size
                writer.writerow({
                    'Layer': f"{layer[0]} ({outputs})",
                    'i_xbar': i_xbar,
                    'o_xbar': i_sna,
                    'i_s&a': i_sna,
                    'o_s&a': i_func,
                    'i_func': i_func,
                    'o_func': o_func,
                    'inside_xbar': i_xbar/(i_xbar+i_sna+i_func)*100,
                    'outside_xbar': (i_sna+i_func)/(i_xbar+i_sna+i_func)*100,
                })
            case _:
                raise ValueError(f"Bad layer type {layer[0]}")
        i_xbar_total += i_xbar
        i_sna_total += i_sna
        i_func_total += i_func
        o_func_total += o_func
    writer.writerow({
        'Layer': f"Total",
        'i_xbar': i_xbar_total,
        'o_xbar': i_sna_total,
        'i_s&a': i_sna_total,
        'o_s&a': i_func_total,
        'i_func': i_func_total,
        'o_func': o_func_total,
        'inside_xbar': i_xbar_total/(i_xbar_total+i_sna_total+i_func_total)*100,
        'outside_xbar': (i_sna_total+i_func_total)/(i_xbar_total+i_sna_total+i_func_total)*100,
    })