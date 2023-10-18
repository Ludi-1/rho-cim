from modules.module import Module
from modules.func import Func


class MLP_Func(Func):
    def __init__(self, f, name: str, next_module: Module, param_dict: dict):
        param_dict["input_size"] = param_dict["input_neurons"] * param_dict["input_channels"]
        param_dict["output_size"] = param_dict["output_neurons"]
        super().__init__(f=f, name=name, next_module=next_module, param_dict=param_dict)

    def start(self, time):
        # print(f"{self.name}: Started at {time}")
        self.fd.write(f"{self.name}: Started at {time}\n")

        super().start(time)
        for i in range(self.output_size - 1):
            #self.current_time = time + self.total_latency
            super().start(self.current_time)  # Write 1 element to ibuf of next layer
