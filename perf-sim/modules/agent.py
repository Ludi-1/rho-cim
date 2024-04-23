from modules.module import Module

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
        for start_time in self.start_times:
            self.current_time = start_time / self.clk_freq
            super().start(start_time)
