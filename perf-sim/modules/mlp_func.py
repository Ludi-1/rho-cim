from modules.module import Module
from modules.func import Func


class MLP_Func(Func):
    def __init__(self, name: str, next_module: Module, param_dict: dict):
        param_dict["input_size"] = param_dict["input_neurons"]
        param_dict["output_size"] = param_dict["output_neurons"]
        super().__init__(name, next_module, param_dict)
