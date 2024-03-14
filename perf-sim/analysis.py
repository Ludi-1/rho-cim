import csv
from math import ceil, log2

def analysis(conf_name, param_dict, technology, datatype_size, crossbar_size, conv_dt):
    f = open(f"./analysis/{conf_name}.txt", "w")
    fieldnames = ['Layer', 'xbar', "s&a", "func"]
    writer = csv.DictWriter(f, fieldnames=fieldnames)
    writer.writeheader()
    for layer in param_dict["layer_list"]:
        match layer[0]:
            case "conv":
                writer.writerow({'Layer': layer[0], 'I': 10})
            case "pool":
                writer.writerow({'Layer': layer[0], 'xbar': 0, 's&a': 0, 'func': 1})
            case "fc":
                inputs = layer[1] * layer[3] # input neurons * input channels
                outputs = layer[3]
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
                i_func = outputs * (datatype_size + log2(crossbar_size) + ceil(log2(n_v)))
                writer.writerow({'Layer': layer[0], 'xbar': i_xbar, 's&a': i_sna, 'func': i_func})
            case _:
                raise ValueError(f"Bad layer type {layer[0]}")