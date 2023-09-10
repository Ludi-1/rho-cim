from modules.module import Module
from modules.func import Func
from math import ceil


class CNN_Func(Func):
    def __init__(self, name: str, next_module: Module, param_dict: dict):
        param_dict["input_size"] = (
            param_dict["input_channels"] * param_dict["kernel_size"]
        )
        param_dict["output_size"] = param_dict["output_channels"]
        super().__init__(name, next_module, param_dict)
