num_inferences: int = 2

cim_param = {
    "reram": {
        "energy": {
            25: {1: 3.4+0.8, 2: 7.2+0.8, 4: 13.4+0.8, 8: 27+0.8},
            50: {1: 1.7+0.8, 2: 3.5+0.8, 4: 7.6+0.8, 8: 14+0.8, 16: 28+0.8},
            75: {1: 0.8+0.8, 2: 1.7+0.8, 4: 3.3+0.8, 8: 6.8+0.8}},
        "latency": {
            25: {1: 274, 2: 296, 4: 332, 8: 454, 16: 538},
            50: {1: 274, 2: 296, 4: 333, 8: 455, 16: 539},
            75: {1: 274, 2: 296, 4: 334, 8: 456, 16: 540}}},
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

fpga_param = {
    "cnn-1": {
        2: {256: 0.036},
        4: {256: 0.065},
        8: {128: 0.119, 256: 0.117, 512: 0.116},
    },
    "cnn-2": {
        2: {256: 0.036},
        4: {256: 0.065},
        8: {128: 0.119, 256: 0.117, 512: 0.116},      
    },
    "mlp-l": {
        2: {256: 0.018},
        4: {256: 0.02},
        8: {128: 0.038, 256: 0.024, 512: 0.019},   
    },
    "mlp-m": {
        2: {256: 0.016},
        4: {256: 0.018},
        8: {128: 0.036, 256: 0.021, 512: 0.019},
    },
    "mlp-s": {
        2: {256: 0.012},
        4: {256: 0.014},
        8: {128: 0.024, 256: 0.016, 512: 0.015},
    },
    "lenet5": {
        2: {256: 0.033},
        4: {256: 0.055},
        8: {128: 0.084, 256: 0.082, 512: 0.082},
    },
    "alexnet": {
        2: {256: 1.426},
        4: {256: 3.310},
        8: {128: 9.537, 256: 6.251, 512: 4.727},
        16: {128: 9.467}, # TODO
    },
    "vgg16": {
        1: {128: 10}, # TODO
        16: {128: 62.810},
    }
}

param_dict_cnn_1: dict = {
    "start_times": [0 for i in range(28 ** 2 * num_inferences)],
    "layer_list": [
        # (Layer type, image size, kernel size, input channels, output_channels, stride)
        ("conv", 28, 5, 1, 5, 1, 0),
        # image size = (prev_image_size - kernel_size + 2*padding) / stride + 1
        ("pool", 24, 2, 5, 5, 2, 0),
        # (Layer type, input neurons, output neurons, input channels)
        ("fc", 12**2, 720, 5), # 12**2 * 5 = 720
        ("fc", 720, 70, 1),
        ("fc", 70, 10, 1),
    ],
}

param_dict_cnn_2: dict = {
    "start_times": [0 for i in range(28**2 * num_inferences)],
    "layer_list": [
        # (Layer type, image size, kernel size, input channels, output_channels, stride)
        ("conv", 28, 7, 1, 10, 1, 0),
        # image size = (prev_image_size - kernel_size + 2*padding) / stride + 1
        # (Layer type, image size, kernel size, input channels, output_channels, stride)
        ("pool", 22, 2, 10, 10, 2, 0), # padding = 0
        # (Layer type, input neurons, output neurons, input channels)
        ("fc", 11**2, 1210, 10),  # 11**2 * 121 = 121
        ("fc", 1210, 1210, 1),
        ("fc", 1210, 10, 1),
    ],
}

param_dict_mlp_s: dict = {
    "start_times": [0 for i in range(28**2 * num_inferences)],
    "layer_list": [
        # (Layer type, input size, output_size, input channels)
        ("fc", 784, 784, 1),
        ("fc", 784, 500, 1),
        ("fc", 500, 250, 1),
        ("fc", 250, 10, 1),
    ],
}

param_dict_mlp_m: dict = {
    "start_times": [0 for i in range(28**2 * num_inferences)],
    "layer_list": [
        # (Layer type, input size, output_size, input channels)
        ("fc", 784, 784, 1),
        ("fc", 784, 1000, 1),
        ("fc", 1000, 500, 1),
        ("fc", 500, 250, 1),
        ("fc", 250, 10, 1),
    ],
}

param_dict_mlp_l: dict = {
    "start_times": [0 for i in range(28**2 * num_inferences)],
    "layer_list": [
        # (Layer type, input size, output_size, input channels)
        ("fc", 784, 784, 1), # FC(784)
        ("fc", 784, 1500, 1), # FC(1500)
        ("fc", 1500, 1000, 1), # FC(1000)
        ("fc", 1000, 500, 1), # FC(500)
        ("fc", 500, 10, 1), # FC(10)
    ],
}

param_dict_lenet5: dict = {
    "start_times": [0 for i in range(28**2 * num_inferences)],
    "layer_list": [
        # (Layer type, image size, kernel size, input channels, output_channels, stride)
        ("conv", 28, 5, 1, 6, 1, 0),
        # image size = (prev_image_size - kernel_size + 2*padding) / stride + 1
        # (Layer type, image size, kernel size, input channels, output_channels, stride)
        ("pool", 24, 2, 6, 6, 2, 0), # padding = 0
        ("conv", 12, 5, 6, 16, 1, 0),
        ("pool", 8, 2, 16, 16, 2, 0), # padding = 0
        # (Layer type, input neurons, output neurons, input channels)
        ("fc", 4**2, 120, 16),  # (8-2)/2 = 4
        ("fc", 120, 84, 1),
        ("fc", 84, 10, 1),
    ],
}

param_dict_alexnet: dict = {
    "start_times": [0 for i in range(227**2 * num_inferences)],
    "layer_list": [
        # (Layer type, image size, kernel size, input channels, output_channels, stride, padding)
        ("conv", 227, 11, 3, 96, 4, 0), # L0 conv 1
        # image size = (prev_image_size - kernel_size + 2*padding) / stride + 1
        # (Layer type, image size, kernel size, input channels, output_channels, stride, padding)
        ("pool", 55, 3, 96, 96, 2), # L1
        ("conv", 27, 5, 96, 256, 1, 2), # L2 conv 2
        ("pool", 27, 3, 256, 256, 2), # L3
        ("conv", 13, 3, 256, 384, 1, 1), # L4 conv 3
        ("conv", 13, 3, 384, 384, 1, 1), # L5 conv 4
        ("conv", 13, 3, 384, 256, 1, 1), # L6 conv 5
        ("pool", 13, 3, 256, 256, 2), # L7
        # (Layer type, input neurons, output neurons, input channels)
        ("fc", 6**2, 4096, 256),  # (13-3)/2+1 = 6
        ("fc", 4096, 4096, 1),
        ("fc", 4096, 10, 1),
    ],
}

# imagenet
# param_dict_vgg16: dict = {
#     "start_times": [0 for i in range(224**2 * num_inferences)],
#     "layer_list": [
#         # conv/pool: (Layer type, image size, kernel size, input channels, output_channels, stride, padding)
#         # image size = (prev_image_size - kernel_size + 2*padding) / stride + 1
#         # FC: (Layer type, input neurons, output neurons, input channels)
#         ("conv", 224, 3, 3, 64, 1, 1), # 3x3,64 (2)
#         ("conv", 224, 3, 64, 64, 1, 1), # 3x3,64 (2)
#         ("pool", 224, 2, 64, 64, 2), # 2x2 Pool
#         ("conv", 112, 3, 64, 128, 1, 1), # 3x3,128 (2)
#         ("conv", 112, 3, 128, 128, 1, 1), # 3x3,128 (2)
#         ("pool", 112, 2, 128, 128, 2), # 2x2 Pool
#         ("conv", 56, 3, 128, 256, 1, 1), # 3x3,256 (3)
#         ("conv", 56, 3, 256, 256, 1, 1), # 3x3,256 (3)
#         ("conv", 56, 3, 256, 256, 1, 1), # 3x3,256 (3)
#         ("pool", 56, 2, 256, 256, 2), # 2x2 Pool
#         ("conv", 28, 3, 256, 512, 1, 1), # 3x3, 512 (3)
#         ("conv", 28, 3, 512, 512, 1, 1), # 3x3, 512 (3)
#         ("conv", 28, 3, 512, 512, 1, 1), # 3x3, 512 (3)
#         ("pool", 28, 2, 512, 512, 2), # 2x2 Pool
#         ("conv", 14, 3, 512, 512, 1, 1), # 3x3, 512 (3)
#         ("conv", 14, 3, 512, 512, 1, 1), # 3x3, 512 (3)
#         ("conv", 14, 3, 512, 512, 1, 1), # 3x3, 512 (3)
#         ("pool", 14, 2, 512, 512, 2), # 2x2 Pool
#         ("fc", 7**2, 4096, 512),
#         ("fc", 4096, 1000, 1),
#     ],
# }

# cifar100
param_dict_vgg16: dict = {
    "start_times": [0 for i in range(32**2 * num_inferences)],
    "layer_list": [
        # conv/pool: (Layer type, image size, kernel size, input channels, output_channels, stride, padding)
        # image size = (prev_image_size - kernel_size + 2*padding) / stride + 1
        # FC: (Layer type, input neurons, output neurons, input channels)
        ("conv", 32, 3, 3, 64, 1, 1), # 3x3,64 (2)
        ("conv", 32, 3, 64, 64, 1, 1), # 3x3,64 (2)
        ("pool", 32, 2, 64, 64, 2), # 2x2 Pool
        ("conv", 16, 3, 64, 128, 1, 1), # 3x3,128 (2)
        ("conv", 16, 3, 128, 128, 1, 1), # 3x3,128 (2)
        ("pool", 16, 2, 128, 128, 2), # 2x2 Pool
        ("conv", 8, 3, 128, 256, 1, 1), # 3x3,256 (3)
        ("conv", 8, 3, 256, 256, 1, 1), # 3x3,256 (3)
        ("conv", 8, 3, 256, 256, 1, 1), # 3x3,256 (3)
        ("pool", 8, 2, 256, 256, 2), # 2x2 Pool
        ("conv", 4, 3, 256, 512, 1, 1), # 3x3, 512 (3)
        ("conv", 4, 3, 512, 512, 1, 1), # 3x3, 512 (3)
        ("conv", 4, 3, 512, 512, 1, 1), # 3x3, 512 (3)
        ("pool", 4, 2, 512, 512, 2), # 2x2 Pool
        ("conv", 2, 3, 512, 512, 1, 1), # 3x3, 512 (3)
        ("conv", 2, 3, 512, 512, 1, 1), # 3x3, 512 (3)
        ("conv", 2, 3, 512, 512, 1, 1), # 3x3, 512 (3)
        ("pool", 2, 2, 512, 512, 2), # 2x2 Pool
        ("fc", 1**2, 4096, 512),
        ("fc", 4096, 100, 1),
    ],
}

technology_list = ["reram"] #, "pcm"]
datatype_size_list = [1, 16] #2, 4, 8, 16]
crossbar_size_list = [128] #, 256, 512]
sparsity_list = [50] # [25, 50, 75]

fpga_module_param = {
    "fpga_clk_freq": 1000 * 10**6,
    "bus_latency": 0,
    "bus_width": 16,
    "ibuf_ports": 2**10,
    "ibuf_read_latency": 1,
    "func_ports": 2**10,  # Number of input operands for functional unit
    "operation_latency": 0,
    "ibuf_write_latency": 0
}

param_dicts = [
    # ("cnn-1", param_dict_cnn_1),
    # ("cnn-2", param_dict_cnn_2),
    # ("mlp-s", param_dict_mlp_s),
    # ("mlp-m", param_dict_mlp_m),
    # ("mlp-l", param_dict_mlp_l),
    # ("lenet5", param_dict_lenet5),
    # ("alexnet", param_dict_alexnet),
    ("vgg16", param_dict_vgg16)
]
