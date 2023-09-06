"""
Main script to instantiate configurations
"""

from mlp_conf import MLP_conf


def main():

    cim_param_dict: dict = {
        "num_of_adc": 32,
        "adc_resolution": 8,
        "max_datatype_size": 8,
        "xbar_latency": 100 * 10**-9,
        "adc_latency": 1 * 10**-9,
        "LRS": 5000,
        "HRS": 10**6,
        "adc_energy": 2 * 10**-12,
        "technology_node": "15 nm",
        "total_energy": 10 * 10**-6,
        "total_latency": 774 * 10**-9,
    }

    param_dict: dict = {
        "start_times": [0, 1, 3],
        "fpga_clk_freq": 1,
        "input_count": 100,
        "neuron_count_list": [1, 2, 3, 4, 5],
        "datatype_size": 8,
        "bus_width": 8,
        "bus_latency": 1,
        "crossbar_size": 256,
        "ibuf_ports": 10,
        "ibuf_read_latency": 1,
        "func_ports": 10,
        "operation_latency": 1,
        "ibuf_write_latency": 0,
        "fpga_power": 0.114,
        "cim_param_dict": cim_param_dict,
    }
    mlp_conf = MLP_conf(param_dict=param_dict)
    mlp_conf.start()


if __name__ == "__main__":
    main()
