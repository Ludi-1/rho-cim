from modules.module import Module
from modules.func import Func
from math import ceil


class CNN_Func(Func):
    def __init__(self, f, name: str, next_module: Module, param_dict: dict):
        param_dict["input_size"] = (
            param_dict["input_channels"] * param_dict["kernel_size"]
        )
        param_dict["output_size"] = param_dict["output_channels"]
        super().__init__(f, name, next_module, param_dict)

    def start(self, time):
        if self.fd is not None:
            self.fd.write(f"{self.name}: Started at {time}\n")
        super().start(time)