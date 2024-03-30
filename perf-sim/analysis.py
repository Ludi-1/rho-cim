import csv
from math import ceil, log2

def write_entry(layer, i_xbar, o_xbar, i_sna, o_sna, i_func, o_func, inside_xbar, outside_xbar):
    i_xbar = str(i_xbar).replace('.', ',')
    o_xbar = str(o_xbar).replace('.', ',')
    i_sna = str(i_sna).replace('.', ',')
    o_sna = str(o_sna).replace('.', ',')
    i_func = str(i_func).replace('.', ',')
    o_func = str(o_func).replace('.', ',')
    inside_xbar = str(inside_xbar).replace('.', ',')
    outside_xbar = str(outside_xbar).replace('.', ',')
    return {
        'Layer': layer,
        'i_xbar': i_xbar,
        'o_xbar': o_xbar,
        'i_s&a': i_sna,
        'o_s&a': o_sna,
        'i_func': i_func,
        'o_func': o_func,
        'inside_xbar': inside_xbar,
        'outside_xbar': outside_xbar,
    }

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
                write_dict = write_entry(
                    layer = f"{layer[0]} {kernel_size}x{kernel_size}",
                    i_xbar = i_xbar,
                    o_xbar = i_sna,
                    i_sna = i_sna,
                    o_sna = i_func,
                    i_func = i_func,
                    o_func = o_func,
                    inside_xbar = i_xbar/(i_xbar+i_sna+i_func)*100,
                    outside_xbar = (i_sna+i_func)/(i_xbar+i_sna+i_func)*100
                )
                writer.writerow(write_dict)
            case "pool":
                inputs = ((layer[1] - layer[2])/layer[5] + 1)**2 * layer[2]**2 * layer[3]
                outputs = ((layer[1] - layer[2])/layer[5] + 1)**2 * layer[4]
                i_xbar = 0
                i_sna = 0
                i_func = inputs * datatype_size
                o_func = outputs * datatype_size
                write_dict = write_entry(
                    layer = f"{layer[0]} {layer[2]}x{layer[2]}",
                    i_xbar = i_xbar,
                    o_xbar = i_sna,
                    i_sna = i_sna,
                    o_sna = i_func,
                    i_func = i_func,
                    o_func = o_func,
                    inside_xbar = i_xbar/(i_xbar+i_sna+i_func)*100,
                    outside_xbar = (i_sna+i_func)/(i_xbar+i_sna+i_func)*100
                )
                writer.writerow(write_dict)
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
                write_dict = write_entry(
                    layer = f"{layer[0]} ({outputs})",
                    i_xbar = i_xbar,
                    o_xbar = i_sna,
                    i_sna = i_sna,
                    o_sna = i_func,
                    i_func = i_func,
                    o_func = o_func,
                    inside_xbar = i_xbar/(i_xbar+i_sna+i_func)*100,
                    outside_xbar = (i_sna+i_func)/(i_xbar+i_sna+i_func)*100
                )
                writer.writerow(write_dict)
            case _:
                raise ValueError(f"Bad layer type {layer[0]}")
        i_xbar_total += i_xbar
        i_sna_total += i_sna
        i_func_total += i_func
        o_func_total += o_func
    write_dict = write_entry(
        layer = "Total",
        i_xbar = i_xbar_total,
        o_xbar = i_sna_total,
        i_sna = i_sna_total,
        o_sna = i_func_total,
        i_func = i_func_total,
        o_func = o_func_total,
        inside_xbar = i_xbar_total/(i_xbar_total+i_sna_total+i_func_total)*100,
        outside_xbar = (i_sna_total+i_func_total)/(i_xbar_total+i_sna_total+i_func_total)*100
    )
    writer.writerow(write_dict)

def write_output_entry(layer, total_energy, fpga_energy, cim_energy, n_cim_tiles, latency):
    total_energy = str(total_energy).replace('.', ',')
    fpga_energy = str(fpga_energy).replace('.', ',')
    cim_energy = str(cim_energy).replace('.', ',')
    n_cim_tiles = str(n_cim_tiles).replace('.', ',')
    latency = str(latency).replace('.', ',')
    return {
        'Layer': layer,
        'Total energy': total_energy,
        'FPGA energy': fpga_energy,
        'CIM energy': cim_energy,
        'N CIM tiles': n_cim_tiles,
        'Latency': latency,
    }

def analysis_conf(conf, conf_name, fpga_power):
    f_test = open(f"./result/{conf_name}.csv", "w")
    fieldnames = ['Layer', 'Total energy', 'FPGA energy', "CIM energy", "N CIM tiles", "Latency"]
    writer = csv.DictWriter(f_test, fieldnames=fieldnames, delimiter=';')
    writer.writeheader()

    n = 0
    total_cim_energy = 0
    total_tiles = 0
    for layer in reversed(conf.layer_list):
        n += 1
        layer_latency = layer.get_latency()
        cim_energy = 0
        n_cim_tiles = 0
        if hasattr(layer, 'cim'):
            cim_energy = layer.cim.get_energy()
            n_cim_tiles = layer.cim.num_tiles
            total_cim_energy += cim_energy
            total_tiles += n_cim_tiles
   
        fpga_energy = layer_latency * fpga_power
        write_dict = write_output_entry(
            layer = layer.name,
            total_energy = fpga_energy + cim_energy,
            fpga_energy = fpga_energy,
            cim_energy = cim_energy,
            n_cim_tiles = n_cim_tiles,
            latency = layer_latency
        )

        fpga_energy = layer_latency * fpga_power
        write_dict = write_output_entry(
            layer = layer.name,
            total_energy = fpga_energy + cim_energy,
            fpga_energy = fpga_energy,
            cim_energy = cim_energy,
            n_cim_tiles = n_cim_tiles,
            latency = layer_latency
        )
        writer.writerow(write_dict)

        if n == len(conf.layer_list):
            total_latency = layer.func.current_time
            fpga_energy = total_latency * fpga_power
            write_dict = write_output_entry(
                layer = "Total",
                total_energy = fpga_energy + total_cim_energy,
                fpga_energy = fpga_energy,
                cim_energy = total_cim_energy,
                n_cim_tiles = total_tiles,
                latency = total_latency
            )
            writer.writerow(write_dict)