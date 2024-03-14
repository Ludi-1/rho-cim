"""
Main script to instantiate configurations
"""

from conf import Conf
from params import *
from analysis import analysis
import os


def main():
    if not os.path.exists("./output"):
        os.mkdir("./output")
    if not os.path.exists("./result"):
        os.mkdir("./result")
    if not os.path.exists("./analysis"):
        os.mkdir("./analysis")
    for param_dict_tuple in param_dicts:
        param_dict = param_dict_tuple[1]
        for technology in technology_list:
            for datatype_size in datatype_size_list:
                for crossbar_size in crossbar_size_list:
                    if crossbar_size != 256 and datatype_size != 8:
                        continue
                    for sparsity in sparsity_list:
                        conf_name = f"{technology}_{param_dict_tuple[0]}_d{datatype_size}_c{crossbar_size}_s{sparsity}"
                        # if sparsity != 50:
                        #     continue
                        # print(param_dict_tuple[0], datatype_size, crossbar_size, sparsity)
                        param_dict["crossbar_size"] = crossbar_size # 128,256,512
                        param_dict["fpga_power"] = fpga_param[param_dict_tuple[0]][datatype_size][crossbar_size]
                        param_dict["datatype_size"] = [datatype_size]*len(param_dict["layer_list"])
                        param_dict["bus_width"] = [datatype_size]*len(param_dict["layer_list"])
                        param_dict["cim_param_dict"] = {
                            "total_energy": cim_param[technology]["energy"][sparsity][datatype_size] * 10**(-9) * (crossbar_size**2 / 256**2),
                            "total_latency": cim_param[technology]["latency"][sparsity][datatype_size] * 10**(-9)}

                        f = open(f"./output/{conf_name}.txt", "w")
                        results_file = open(f"./result/{conf_name}.txt", "w")
                        conf = Conf(param_dict, f, results_file)
                        conf.start()

    for param_dict_tuple in param_dicts:
        param_dict = param_dict_tuple[1]
        for datatype_size in datatype_size_list:
            for crossbar_size in crossbar_size_list:
                for conv_dt in [2, 4, 8]:
                    conf_name = f"{param_dict_tuple[0]}_d{datatype_size}_c{crossbar_size}_a{conv_dt}"
                    analysis(conf_name, param_dict, datatype_size, crossbar_size, conv_dt)

if __name__ == "__main__":
    main()
