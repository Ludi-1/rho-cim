from modules.ctrl import Control
from modules.module import Module
import math


class MLP_Control(Control):
    def __init__(
        self,
        f,
        name: str,
        next_module: Module,  # Should always be a CIM module
        param_dict: dict,
    ):
        param_dict["input_size"] = param_dict["input_neurons"] * param_dict["input_channels"]
        super().__init__(f, name, next_module, param_dict)

        self.entry_count: int = 0
        self.fifo_size: int = param_dict["input_neurons"]
        self.resets = 0
    def start(self, time):
        self.fd.write(f"{self.name}: Started at {time}, {self.entry_count} - {self.fifo_size}\n")
        self.entry_count += 1
        # print(f"{self.name}: {self.entry_count}, {self.fifo_size}")
        if self.entry_count == self.fifo_size:
            self.entry_count = 0
            self.resets += 1
            # self.current_time = time + self.total_latency
            # print(f"{self.name}: {self.entry_count}, {self.fifo_size}")
            super().start(time)
        else:
            # print(f"{self.name}: Entry count {self.entry_count}")
            self.current_time = time + 1 / self.clk_freq
        # print(self.entry_count)

    def __del__(self):
        print(f"{self.name}: {self.resets}")
