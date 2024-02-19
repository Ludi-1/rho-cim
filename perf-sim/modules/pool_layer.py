"""Pooling Layer class
Bundles a set of modules together that make up a pooling layer
This layer should be connected to another layer or None if it is the last layer
"""

from modules.module import Module
from math import ceil


class Pool_Layer(Module):
    def __init__(self, name: str, next_module: Module, param_dict: dict, f):
        super().__init__(f, name, next_module)

        self.fpga_clk_freq: float = param_dict["fpga_clk_freq"]  # Clock frequency
        self.image_size: int = param_dict["image_size"]
        self.kernel_size: int = param_dict["kernel_size"]
        self.stride: int = param_dict["stride"]
        # self.ibuf_read_latency: int = param_dict[
        #     "ibuf_read_latency"
        # ]  # Latency for reading from ibuf, incorporated in operation freq
        # self.operation_latency: int = param_dict[
        #     "operation_latency"
        # ]  # Latency for post-processing
        # self.ibuf_write_latency: int = param_dict[
        #     "ibuf_write_latency"
        # ]  # Latency for writing to ibuf, incorporated in operation freq

        self.total_latency: float = (
            1
            / self.fpga_clk_freq
            # * (self.operation_latency + self.ibuf_write_latency)
        )  # Time this module is busy

        self.entry_count: int = 0
        self.col_count: int = 0
        self.row_count: int = 0
        self.skip: bool = False
        self.fifo_size: int = (
            self.image_size * (self.kernel_size - 1) + self.kernel_size
        )

    def start(self, time):
        # print(f"{self.name}: Started at {time}")
        self.fd.write(f"({self.name}): Started at {time}\n")
        if time < self.current_time:
            raise Exception(
                f"Module {self.name} at time {self.current_time} started in the past: {time}"
            )

        if self.entry_count < self.fifo_size - 1:
            # print(f"init: {self.name} {self.entry_count}, {self.col_count}")
            self.current_time = time + 1 / self.fpga_clk_freq
        else:  # FIFO is full
            if self.skip:
                if self.col_count == self.kernel_size - 2:
                    self.skip = False
                # print(f"skip: {self.name} {self.entry_count}, {self.col_count}")
                self.current_time = time + 1 / self.fpga_clk_freq
            else:
                if self.col_count == self.image_size - 1:
                    # print(f"init skip: {self.name} {self.entry_count}, {self.col_count}")
                    self.skip = True
                # print(f"act: {self.name} {self.entry_count}, {self.col_count}")
                if (self.col_count % self.stride) == 0 and (self.row_count % self.stride) == 0:
                    # self.current_time = time + self.total_latency
                    super().start(time)

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