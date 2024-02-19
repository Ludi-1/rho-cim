num_inferences: int = 1

cim_param = {
    "reram": {
        "energy": {
            25: {1: 3.4+0.8, 2: 7.2+0.8, 4: 13.4+0.8, 8: 27+0.8},
            50: {1: 1.7+0.8, 2: 3.5+0.8, 4: 7.6+0.8, 8: 14+0.8},
            75: {1: 0.8+0.8, 2: 1.7+0.8, 4: 3.3+0.8, 8: 6.8+0.8}},
        "latency": {
            25: {1: 281, 2: 296, 4: 332, 8: 454},
            50: {1: 282, 2: 296, 4: 333, 8: 455},
            75: {1: 283, 2: 296, 4: 334, 8: 456}}},
    "pcm": {
        "energy": {
            25: {1: 1.2+0.8, 2: 2.5+0.8, 4: 4.9+0.8, 8: 10.2+0.8},
            50: {1: 0.8+0.8, 2: 1.7+0.8, 4: 3.4+0.8, 8: 6.7+0.8},
            75: {1: 0.6+0.8, 2: 1.1+0.8, 4: 2.3+0.8, 8: 4.8+0.8}},
        "latency": {
            25: {1: 281, 2: 296, 4: 332, 8: 454},
            50: {1: 282, 2: 296, 4: 333, 8: 455},
            75: {1: 283, 2: 296, 4: 334, 8: 456}}}
}

reram_energy = {
    25: {1: 3.4+0.8, 2: 7.2+0.8, 4: 13.4+0.8, 8: 27+0.8},
    50: {1: 1.7+0.8, 2: 3.5+0.8, 4: 7.6+0.8, 8: 14+0.8},
    75: {1: 0.8+0.8, 2: 1.7+0.8, 4: 3.3+0.8, 8: 6.8+0.8}}

reram_latency = {
    25: {1: 281, 2: 296, 4: 332, 8: 454},
    50: {1: 282, 2: 296, 4: 333, 8: 455},
    75: {1: 283, 2: 296, 4: 334, 8: 456}}

pcm_energy = {
    25: {1: 1.2+0.8, 2: 2.5+0.8, 4: 4.9+0.8, 8: 10.2+0.8},
    50: {1: 0.8+0.8, 2: 1.7+0.8, 4: 3.4+0.8, 8: 6.7+0.8},
    75: {1: 0.6+0.8, 2: 1.1+0.8, 4: 2.3+0.8, 8: 4.8+0.8}}

pcm_latency = {
    25: {1: 281, 2: 296, 4: 332, 8: 454},
    50: {1: 282, 2: 296, 4: 333, 8: 455},
    75: {1: 283, 2: 296, 4: 334, 8: 456}}

cim_param_dict_d2: dict = {
    "num_of_adc": 32,
    "adc_resolution": 8,
    "max_datatype_size": 8,
    "xbar_latency": 100 * 10**-9,
    "adc_latency": 1 * 10**-9,
    "LRS": 5000,
    "HRS": 10**6,
    "adc_energy": 2 * 10**-12,
    "technology_node": "15 nm",
    "total_energy": 3.3 * 10**-9,
    "total_latency": 296 * 10**-9,
}

cim_param_dict_d4: dict = {
    "num_of_adc": 32,
    "adc_resolution": 8,
    "max_datatype_size": 8,
    "xbar_latency": 100 * 10**-9,
    "adc_latency": 1 * 10**-9,
    "LRS": 5000,
    "HRS": 10**6,
    "adc_energy": 2 * 10**-12,
    "technology_node": "15 nm",
    "total_energy": 8.4 * 10**-9,
    "total_latency": 333 * 10**-9,
}

cim_param_dict_d8: dict = {
    "num_of_adc": 32,
    "adc_resolution": 8,
    "max_datatype_size": 8,
    "xbar_latency": 100 * 10**-9,
    "adc_latency": 1 * 10**-9,
    "LRS": 5000,
    "HRS": 10**6,
    "adc_energy": 2 * 10**-12,
    "technology_node": "15 nm",
    "total_energy": 14.8 * 10**-9,
    "total_latency": 455 * 10**-9,
}

cim_param_dict: dict = cim_param_dict_d8

param_dict_cnn_1: dict = {
    "start_times": [0 for i in range(28 ** 2 * num_inferences)],
    "fpga_clk_freq": 100 * 10 ** 6,
    "layer_list": [
        # (Layer type, image size, kernel size, input channels, output_channels, stride)
        ("conv", 28, 5, 1, 5, 1),
        # image size = (prev_image_size - kernel_size + 2*padding) / stride + 1
        ("pool", 24, 2, 5, 5, 1),
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
        ("fc", 784, 784, 1), # FC(784)
        ("fc", 784, 1500, 1), # FC(1500)
        ("fc", 1500, 1000, 1), # FC(1000)
        ("fc", 1000, 500, 1), # FC(500)
        ("fc", 500, 10, 1), # FC(10)
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

# param_dict_resnet50: dict = {
#     "start_times": [0 for i in range(28**2 * num_inferences)],
#     "fpga_clk_freq": 100 * 10**6,
#     "layer_list": [
#         # (Layer type, image size, kernel size, input channels, output_channels, stride)
#         ("conv", 28, 7, 1, 10, 1),
#         ("fc", 500, 10, 1),
#     ],
#     "datatype_size": [8, 1, 1, 1, 8],
#     "bus_width": [8, 1, 1, 1, 8],
#     "bus_latency": 0,
#     "crossbar_size": 256,
#     "ibuf_ports": 1,
#     "ibuf_read_latency": 1,
#     "func_ports": 2**32,  # Number of input operands for functional unit
#     "operation_latency": 0,
#     "ibuf_write_latency": 0,
#     "fpga_power": 0.114,
#     "cim_param_dict": cim_param_dict,
# }

param_dict = param_dict_cnn_1

technology = "reram"
datatype_size = 8 # 1,2,4,8
param_dict["crossbar_size"] = 256 # 128,256,512
sparsity = 50
param_dict["fpga_power"] = 0.024

param_dict["datatype_size"] = [datatype_size]*5
param_dict["bus_width"] = [datatype_size]*5
param_dict["cim_param_dict"] = {
    "total_energy": cim_param[technology]["energy"][sparsity][datatype_size],
    "total_latency": cim_param[technology]["latency"][sparsity][datatype_size]}
