from modules.module import Module
from modules.ctrl import Control
from math import ceil


class CNN_Control(Control):
    def __init__(
        self,
        name: str,
        next_module: Module,  # Should always be a CIM module
        param_dict: dict,
    ):
        self.image_size: int = param_dict["image_size"]  # CNN input square image size
        self.kernel_size: int = param_dict[
            "kernel_size"
        ]  # CNN kernel size applied over image
        self.input_channels = param_dict["input_channels"]
        param_dict["input_size"] = self.kernel_size**2 * self.input_channels

        super().__init__(name, next_module, param_dict)

        self.entry_count: int = 0
        self.fifo_size: int = (
            self.image_size * (self.kernel_size - 1) + self.kernel_size
        )

    def start(self, time):
        print(f"{self.name}: Started at {time}")
        if time >= self.current_time:  # Should always be true
            if self.entry_count == self.fifo_size:
                self.current_time = time + self.total_latency
                self.start_next()
            else:
                self.entry_count += 1
                self.current_time = time + 1 / self.clk_freq
        else:
            raise Exception(f"Module {self.name} started in the past: {time}")
