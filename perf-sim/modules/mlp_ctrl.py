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
        param_dict["input_size"] = param_dict["input_neurons"]
        super().__init__(f, name, next_module, param_dict)

        self.entry_count: int = 0
        self.fifo_size: int = param_dict["input_neurons"]

    def start(self, time):
        self.fd.write(f"{self.name}: Started at {time}\n")
        if time < self.current_time:  # Should always be false
            raise Exception(
                f"Module {self.name} started in the past: {time}, {self.current_time}"
            )

        # print(f"{self.name}: {self.entry_count}, {self.fifo_size}")
        if self.entry_count == self.fifo_size - 1:
            self.entry_count = 0
            self.current_time = time + self.total_latency
            # print(f"{self.name}: {self.entry_count}, {self.fifo_size}")
            self.start_next()
        else:
            # print(f"{self.name}: Entry count {self.entry_count}")
            self.current_time = time + 1 / self.clk_freq
        self.entry_count += 1
