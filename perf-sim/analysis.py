import csv

def analysis(conf_name, param_dict, technology, datatype_size, crossbar_size, sparsity):
    f = open(f"./analysis/{conf_name}.txt", "w")
    fieldnames = ['Layer', 'I']
    writer = csv.DictWriter(f, fieldnames=fieldnames)
    writer.writeheader()
    for layer in param_dict["layer_list"]:
        match layer[0]:
            case "conv":
                writer.writerow({'Layer': layer[0], 'I': 10})
            case "pool":
                pass
            case "fc":
                pass
            case _:
                raise ValueError(f"Bad layer type {layer[0]}")