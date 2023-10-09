"""
Main script to instantiate configurations
"""

from mlp_conf import MLP_conf
from conf import Conf
import os

def main():

    cim_param_dict: dict = {
        "num_of_adc": 32,
        "adc_resolution": 8,
        "max_datatype_size": 8,
        "xbar_latency": 100 * 10 ** -9,
        "adc_latency": 1 * 10 ** -9,
        "LRS": 5000,
        "HRS": 10 ** 6,
        "adc_energy": 2 * 10 ** -12,
        "technology_node": "15 nm",
        "total_energy": 10 * 10 ** -6,
        "total_latency": 774 * 10 ** -9,
    }

    param_dict: dict = {
        "start_times": [i / (100 * 10 ** 6) for i in range(28 ** 2)],
        "fpga_clk_freq": 100 * 10 ** 6,
        "layer_list": [
            # (Layer type, image size, kernel size, input channels, output_channels, stride)
            ("conv", 28, 5, 1, 5),
            # image size = prev_image_size - kernel_size + 1
            ("pool", 24, 2, 5, 5, 2),
            # (Layer type, input neurons, output neurons)
            ("fc", 12**2 * 5, 70), # 12**2 * 5 = 720
            ("fc", 70, 10),
            ("fc", 10, 10),
        ],
        "datatype_size": [8, 1, 1, 1, 8],
        "bus_width": 8,
        "bus_latency": 1,
        "crossbar_size": 256,
        "ibuf_ports": 1,
        "ibuf_read_latency": 1,
        "func_ports": 1,
        "operation_latency": 1,
        "ibuf_write_latency": 0,
        "fpga_power": 0.114,
        "cim_param_dict": cim_param_dict,
    }
    if not os.path.exists("./output"):
        os.mkdir("./output")
    f = open("./output/log.txt", "w")
    conf = Conf(param_dict, f)
    conf.start()


if __name__ == "__main__":
    main()
