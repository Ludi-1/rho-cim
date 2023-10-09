"""Configuration class
This configuration class bundles multiple layers together
An Agent module is connected to the first module
"""

from modules.mlp_layer import MLP_Layer
from modules.cnn_layer import CNN_Layer
from modules.pool_layer import Pool_Layer
from modules.agent import Agent
import itertools


class Conf:
    def __init__(self, param_dict: dict, f):
        self.layer_list = []
        next_layer = None
        n = len(param_dict["layer_list"]) - 1
        for (layer, datatype_size) in reversed(
            list(zip(param_dict["layer_list"], param_dict["datatype_size"]))
        ):
            match layer[0]:
                case "conv":
                    layer_dict = param_dict.copy()
                    layer_dict["image_size"] = layer[1]
                    layer_dict["kernel_size"] = layer[2]
                    layer_dict["input_channels"] = layer[3]
                    layer_dict["output_channels"] = layer[4]
                    layer_dict["datatype_size"] = datatype_size
                    self.layer_list.append(
                        CNN_Layer(
                            name=f"Layer {n}: Conv",
                            next_module=next_layer,
                            param_dict=layer_dict,
                            f=f,
                        )
                    )
                    next_layer = self.layer_list[-1]
                case "pool":
                    layer_dict = param_dict.copy()
                    layer_dict["image_size"] = layer[1]
                    layer_dict["kernel_size"] = layer[2]
                    layer_dict["input_channels"] = layer[3]
                    layer_dict["output_channels"] = layer[4]
                    layer_dict["stride"] = layer[5]
                    layer_dict["datatype_size"] = datatype_size
                    self.layer_list.append(
                        Pool_Layer(
                            name=f"Layer {n}: Pool",
                            next_module=next_layer,
                            param_dict=layer_dict,
                            f=f,
                        )
                    )
                    next_layer = self.layer_list[-1]
                case "fc":
                    layer_dict: dict = param_dict.copy()
                    layer_dict["input_neurons"]: int = layer[1]
                    layer_dict["output_neurons"]: int = layer[2]
                    layer_dict["datatype_size"] = datatype_size
                    self.layer_list.append(
                        MLP_Layer(
                            name=f"Layer {n}: FC",
                            next_module=next_layer,
                            param_dict=layer_dict,
                            f=f,
                        ),
                    )
                    next_layer = self.layer_list[-1]
                case _:
                    raise ValueError(f"Bad layer type {layer[0]}")
            n -= 1

        # Connect agent to first module of configuration
        self.agent = Agent(
            clk_freq=param_dict["fpga_clk_freq"],
            first_module=self.layer_list[-1],
            start_times=param_dict["start_times"],
        )

        for layer in self.layer_list:
            if layer.next_module is not None:
                print(layer.name, layer.next_module.name)
            else:
                print(layer.name)

    def start(self):
        self.agent.start()
