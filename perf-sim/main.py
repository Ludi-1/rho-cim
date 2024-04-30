"""
Main script to instantiate configurations
"""

from conf import Conf
from params import *
from analysis import analysis, analysis_conf, analysis_operations
from gen_hdl import gen_hdl
import os
import csv
import sys

def main(ENABLE_OUTPUT):
    if not os.path.exists("./output"):
        os.mkdir("./output")
    if not os.path.exists("./result"):
        os.mkdir("./result")
    if not os.path.exists("./analysis"):
        os.mkdir("./analysis")
    if not os.path.exists("./analysis_operations"):
        os.mkdir("./analysis_operations")
    if not os.path.exists("./gen_hdl"):
        os.mkdir("./gen_hdl")
    for param_dict_tuple in param_dicts:
        param_dict = param_dict_tuple[1] | fpga_module_param
        for technology in technology_list:
            for datatype_size in datatype_size_list:
                for crossbar_size in crossbar_size_list:
                    # if crossbar_size != 256 and datatype_size != 8 and param_dict_tuple[0] != "alexnet" and param_dict_tuple[0] != "vgg16":
                    #     continue
                    # if param_dict_tuple[0] == "alexnet" and (datatype_size == 2 or datatype_size == 4) and crossbar_size != 256:
                    #     continue
                    # if param_dict_tuple[0] == "alexnet" and datatype_size == 16 and crossbar_size != 128:
                    #     continue
                    # if param_dict_tuple[0] == "vgg16" and (datatype_size != 16 or crossbar_size != 128):
                    #     continue
                    for sparsity in sparsity_list:
                        conf_name = f"{technology}_{param_dict_tuple[0]}_d{datatype_size}_c{crossbar_size}_s{sparsity}"
                        # if datatype_size == 16 and (sparsity != 50 or technology != "reram" or (param_dict_tuple[0] != "alexnet" and param_dict_tuple[0] != "vgg16")):
                        #     continue
                        print(param_dict_tuple[0], datatype_size, crossbar_size, sparsity, technology)
                        param_dict["crossbar_size"] = crossbar_size # 128,256,512
                        param_dict["fpga_power"] = fpga_param[param_dict_tuple[0]][datatype_size][crossbar_size]
                        param_dict["datatype_size"] = [datatype_size]*len(param_dict["layer_list"])
                        param_dict["bus_width"] = [datatype_size]*len(param_dict["layer_list"])
                        param_dict["cim_param_dict"] = {
                            "total_energy": cim_param[technology]["energy"][sparsity][datatype_size] * 10**(-9) * (crossbar_size**2 / 256**2),
                            "total_latency": (cim_param[technology]["latency"][sparsity][datatype_size]-256) / datatype_size * 10**(-9)
                            }

                        if ENABLE_OUTPUT:
                            f = open(f"./output/{conf_name}.txt", "w")
                        else:
                            f = None
                        conf = Conf(param_dict, f)
                        conf.start()
                        analysis_conf(conf, conf_name, param_dict["fpga_power"])

    #     for datatype_size in datatype_size_list:
    #         for crossbar_size in crossbar_size_list:
    #             for conv_dt in [1, 2, 4, 8]:
    #                 conf_name = f"{param_dict_tuple[0]}_d{datatype_size}_c{crossbar_size}_a{conv_dt}"
    #                 analysis(conf_name, param_dict, datatype_size, crossbar_size, conv_dt)

    for param_dict_tuple in param_dicts:
        for datatype_size in datatype_size_list:
            for crossbar_size in crossbar_size_list:
                gen_hdl(param_dict_tuple, datatype_size, crossbar_size)

    for param_dict_tuple in param_dicts:
        for datatype_size in datatype_size_list:
            for crossbar_size in crossbar_size_list:
                param_dict = param_dict_tuple[1]
                conf_name = conf_name = f"{param_dict_tuple[0]}_d{datatype_size}_c{crossbar_size}"
                analysis_operations(param_dict, conf_name, datatype_size, crossbar_size)
        
if __name__ == "__main__":
    ENABLE_OUTPUT = False
    for arg in sys.argv:
        match arg:
            case "o":
                print("Output enabled")
                ENABLE_OUTPUT = True
            case _:
                print(f"Arg {arg}")
        
    main(ENABLE_OUTPUT)
