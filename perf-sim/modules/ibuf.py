from abc import abstractmethod
from modules.module import Module
from math import ceil


class CNN_Ibuf(Module):
    def __init__(
        self,
        f,
        name: str,
        next_module: Module,  # Should always be a CIM module
        param_dict: dict,
    ):
        super().__init__(f, name, next_module)

        self.image_size: int = param_dict["image_size"]  # CNN input image size
        self.kernel_size: int = param_dict[
            "kernel_size"
        ]  # CNN kernel size applied over image
        self.stride: int = param_dict["stride"]

        self.clk_freq: float = param_dict["fpga_clk_freq"]  # Clock frequency

        self.total_latency = (
            1 / self.clk_freq
        )

        self.entry_count: int = 0
        self.col_count: int = 0
        self.row_count: int = 0
        self.skip: bool = False
        self.fifo_size: int = (
            self.image_size * (self.kernel_size - 1) + self.kernel_size
        )

    def start(self, time):
        # print(f"{self.name}: Started at {time}")
        self.fd.write(f"{self.name}: Started at {time}\n")
        if time < self.current_time:
            raise Exception(
                f"Module {self.name} at time {self.current_time} started in the past: {time}"
            )

        # print(f"{self.name} {self.entry_count}, {self.col_count}")
        if self.entry_count < self.fifo_size - 1:
            # print(f"init: {self.name} {self.entry_count}, {self.col_count}")
            self.current_time = time + 1 / self.clk_freq
        else:  # FIFO is full
            if self.skip:
                if self.col_count == self.kernel_size - 2:
                    self.skip = False
                # print(f"skip: {self.name} {self.entry_count}, {self.col_count}")
                self.current_time = time + 1 / self.clk_freq
            else:
                if self.col_count == self.image_size - 1:
                    self.skip = True
                # print(f"act: {self.name} {self.entry_count}, {self.col_count}")
                if ((self.col_count + 1) % self.stride) == 0 and ((self.row_count + 1) % self.stride) == 0:
                    self.stride_count = 0
                    self.current_time = time + self.total_latency
                    self.start_next()

        if self.entry_count == self.image_size ** 2 - 1:
            self.entry_count = 0
            self.skip = False
        else:
            self.entry_count += 1

        if self.col_count == self.image_size - 1:
            self.col_count = 0
            if self.row_count == self.image_size - 1:
                self.row_count = 0
            else:
                self.row_count += 1
        else:
            self.col_count += 1
