"""
Main script to instantiate configurations
"""

from mlp_conf import MLP_conf
from modules.cnn_ctrl import CNN_Control


def main():

    cim_param_dict: dict = {
        "cim_clk_freq": 1,
        "total_latency": 1,
    }

    param_dict: dict = {
        "start_times": [0, 1, 3],
        "fpga_clk_freq": 1,
        "input_count": 100,
        "neuron_count_list": [1, 2, 3, 4, 5],
        "datatype_size": 8,
        "bus_width": 8,
        "bus_latency": 1,
        "crossbar_size": 512,
        "ibuf_ports": 10,
        "ibuf_read_latency": 1,
        "func_ports": 10,
        "operation_latency": 1,
        "ibuf_write_latency": 0,
        "cim_param_dict": cim_param_dict,
    }
    # mlp_conf = MLP_conf(param_dict=param_dict)
    # mlp_conf.start()
    param_dict["image_size"] = 10
    param_dict["kernel_size"] = 10
    param_dict["input_channels"] = 10
    control_test = CNN_Control("control_test", None, param_dict)


if __name__ == "__main__":
    main()
