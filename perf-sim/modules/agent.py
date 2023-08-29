from modules.module import Module

"""Agent class
Contains timestamps when to drive the inputs of a system
"""


class Agent(Module):
    def __init__(
        self, clk_freq: float, first_module: Module, start_times: list[float] = [0]
    ):
        self.clk_freq = clk_freq
        self.next_module: Module = first_module
        self.start_times = start_times
        self.name = "Agent"
        print(f"Agent first module:{self.next_module.name}")

    def start(self):
        for start_time in self.start_times:
            print(f"Agent started at time: {start_time}")
            self.current_time = start_time
            self.start_next()
