num_inferences: int = 1


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
    "total_energy": 14 * 10**-9,
    "total_latency": 774 * 10**-9,
}

param_dict_cnn_1: dict = {
    "start_times": [0 for i in range(28 ** 2 * num_inferences)],
    "fpga_clk_freq": 100 * 10 ** 6,
    "layer_list": [
        # (Layer type, image size, kernel size, input channels, output_channels, stride)
        ("conv", 28, 5, 1, 5, 1),
        # image size = (prev_image_size - kernel_size + 2*padding) / stride + 1
        ("pool", 24, 2, 5, 5, 2),
        # (Layer type, input neurons, output neurons, input channels)
        ("fc", 12**2, 720, 5), # 12**2 * 5 = 720
        ("fc", 720, 70, 1),
        ("fc", 70, 10, 1),
    ],
    "datatype_size": [8, 1, 1, 1, 8],
    "bus_width": [8, 1, 1, 1, 8],
    "bus_latency": 0,
    "crossbar_size": 256,
    "ibuf_ports": 1,
    "ibuf_read_latency": 1,
    "func_ports": 2**32, # Number of input operands for functional unit
    "operation_latency": 0,
    "ibuf_write_latency": 0,
    "fpga_power": 0.114,
    "cim_param_dict": cim_param_dict,
}

param_dict_cnn_2: dict = {
    "start_times": [0 for i in range(28**2 * num_inferences)],
    "fpga_clk_freq": 100 * 10**6,
    "layer_list": [
        # (Layer type, image size, kernel size, input channels, output_channels, stride)
        ("conv", 28, 7, 1, 10, 1),
        # image size = (prev_image_size - kernel_size + 2*padding) / stride + 1
        # (Layer type, image size, kernel size, input channels, output_channels, stride)
        ("pool", 22, 2, 10, 10, 2), # padding = 0
        # (Layer type, input neurons, output neurons, input channels)
        ("fc", 11**2, 1210, 10),  # 11**2 * 121 = 121
        ("fc", 1210, 1210, 1),
        ("fc", 1210, 10, 1),
    ],
    "datatype_size": [8, 1, 1, 1, 8],
    "bus_width": [8, 1, 1, 1, 8],
    "bus_latency": 0,
    "crossbar_size": 256,
    "ibuf_ports": 1,
    "ibuf_read_latency": 1,
    "func_ports": 2**32,  # Number of input operands for functional unit
    "operation_latency": 0,
    "ibuf_write_latency": 0,
    "fpga_power": 0.114,
    "cim_param_dict": cim_param_dict,
}

param_dict_mlp_s: dict = {
    "start_times": [0 for i in range(28**2 * num_inferences)],
    "fpga_clk_freq": 100 * 10**6,
    "layer_list": [
        # (Layer type, input size, output_size, input channels)
        ("fc", 784, 784, 1),
        ("fc", 784, 500, 1),
        ("fc", 500, 250, 1),
        ("fc", 250, 10, 1),
    ],
    "datatype_size": [8, 1, 1, 1, 8],
    "bus_width": [8, 1, 1, 1, 8],
    "bus_latency": 0,
    "crossbar_size": 256,
    "ibuf_ports": 1,
    "ibuf_read_latency": 1,
    "func_ports": 2**32,  # Number of input operands for functional unit
    "operation_latency": 0,
    "ibuf_write_latency": 0,
    "fpga_power": 0.114,
    "cim_param_dict": cim_param_dict,
}

param_dict_mlp_m: dict = {
    "start_times": [0 for i in range(28**2 * num_inferences)],
    "fpga_clk_freq": 100 * 10**6,
    "layer_list": [
        # (Layer type, input size, output_size, input channels)
        ("fc", 784, 784, 1),
        ("fc", 784, 1000, 1),
        ("fc", 1000, 250, 1),
        ("fc", 250, 10, 1),
    ],
    "datatype_size": [8, 1, 1, 1, 8],
    "bus_width": [8, 1, 1, 1, 8],
    "bus_latency": 0,
    "crossbar_size": 256,
    "ibuf_ports": 1,
    "ibuf_read_latency": 1,
    "func_ports": 2**32,  # Number of input operands for functional unit
    "operation_latency": 0,
    "ibuf_write_latency": 0,
    "fpga_power": 0.114,
    "cim_param_dict": cim_param_dict,
}

param_dict_mlp_l: dict = {
    "start_times": [0 for i in range(28**2 * num_inferences)],
    "fpga_clk_freq": 100 * 10**6,
    "layer_list": [
        # (Layer type, input size, output_size, input channels)
        ("fc", 784, 784, 1),
        ("fc", 784, 1500, 1),
        ("fc", 1000, 500, 1),
        ("fc", 500, 10, 1),
    ],
    "datatype_size": [8, 1, 1, 1, 8],
    "bus_width": [8, 1, 1, 1, 8],
    "bus_latency": 0,
    "crossbar_size": 256,
    "ibuf_ports": 1,
    "ibuf_read_latency": 1,
    "func_ports": 2**32,  # Number of input operands for functional unit
    "operation_latency": 0,
    "ibuf_write_latency": 0,
    "fpga_power": 0.114,
    "cim_param_dict": cim_param_dict,
}

param_dict = param_dict_mlp_s
