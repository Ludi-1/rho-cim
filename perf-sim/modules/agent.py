from modules.module import Module
from modules.mlp_layer import MLP_Layer
from modules.cnn_layer import CNN_Layer

"""Agent class
Contains timestamps when to drive the inputs of a system
"""


class Agent(Module):
    def __init__(self, f, name: str, next_module: Module, param_dict: dict):
        super().__init__(f, name, next_module)
        self.clk_freq = param_dict["fpga_clk_freq"]
        self.start_times = param_dict["start_times"]
        self.total_latency = 1 / self.clk_freq

    def start(self):
        if type(self.next_module) is CNN_Layer:
            for start_time in self.start_times:
                self.current_time = start_time / self.clk_freq
                super().start(start_time)
        elif type(self.next_module) is MLP_Layer:
            super().start(self.start_times[-1] / self.clk_freq)
