from modules.ctrl import Control
from modules.module import Module


class MLP_Control(Control):
    def __init__(
        self,
        name: str,
        next_module: Module,  # Should always be a CIM module
        param_dict: dict,
    ):
        param_dict["input_size"] = param_dict["input_neurons"]
        super().__init__(name, next_module, param_dict)

        self.entry_count: int = 0
        self.fifo_size: int = param_dict["input_neurons"]

    def start(self, time):
        print(f"{self.name}: Started at {time}")
        if time >= self.current_time:  # Should always be true
            if self.entry_count == self.fifo_size:
                self.entry_count = 0
                self.current_time = time + self.total_latency
                self.start_next()
            else:
                self.entry_count += 1
                self.current_time = time + 1 / self.clk_freq
        else:
            raise Exception(f"Module {self.name} started in the past: {time}")