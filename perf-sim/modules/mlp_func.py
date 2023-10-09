from modules.module import Module
from modules.func import Func


class MLP_Func(Func):
    def __init__(self, f, name: str, next_module: Module, param_dict: dict):
        param_dict["input_size"] = param_dict["input_neurons"]
        param_dict["output_size"] = param_dict["output_neurons"]
        super().__init__(f=f, name=name, next_module=next_module, param_dict=param_dict)

    def start(self, time):
        # print(f"{self.name}: Started at {time}")
        self.fd.write(f"{self.name}: Started at {time}\n")
        if time >= self.current_time:  # Should always be true
            for i in range(self.output_size):
                self.current_time = time + self.total_latency
                self.start_next()  # Write 1 element to ibuf of next layer
        else:
            print(f"Module {self.name} started in the past: {time}")
            raise Exception(f"Module {self.name} started in the past: {time}")
