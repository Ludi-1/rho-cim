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

    def start(self, time):
        if time >= self.current_time:  # Should always be true
            for i in range(self.output_size):
                self.current_time = time + self.total_latency
                self.start_next()  # Write 1 element to ibuf of next layer
        else:
            print(f"Module {self.name} started in the past: {time}")
            raise Exception(f"Module {self.name} started in the past: {time}")
