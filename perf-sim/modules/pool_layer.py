"""Pooling Layer class
Bundles a set of modules together that make up a pooling layer
This layer should be connected to another layer or None if it is the last layer
"""

from modules.module import Module
from math import ceil


class Pool_Layer(Module):
    def __init__(self, name: str, next_module: Module, param_dict: dict):
        super().__init__(name, next_module)

        self.fpga_clk_freq: float = param_dict["fpga_clk_freq"]  # Clock frequency
        self.image_size: int = param_dict["image_size"]
        self.kernel_size: int = param_dict["kernel_size"]

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
        self.skip_count: int = 0
        self.fifo_size: int = (
            self.image_size * (self.kernel_size - 1) + self.kernel_size
        )

    def start(self, time):
        # print(f"{self.name}: Started at {time}")
        if time < self.current_time:
            raise Exception(
                f"Module {self.name} at time {self.current_time} started in the past: {time}"
            )

        self.entry_count += 1
        # self.col_count += 1
        if self.entry_count < self.fifo_size - 1:
            print(f"init: {self.name} {self.entry_count}, {self.col_count}")
            if self.col_count >= self.image_size - 1:
                self.col_count = 0
            else:
                self.col_count += 1
            self.current_time = time + 1 / self.fpga_clk_freq
        elif self.entry_count >= self.image_size**2 - 1:
            print(f"complete: {self.name} {self.entry_count}, {self.col_count}")
            self.entry_count = 0
            if self.col_count >= self.image_size - 1:
                self.col_count = 0
            else:
                self.col_count += 1
            self.current_time = time + 1 / self.fpga_clk_freq
        else: # FIFO is full
            if self.col_count >= self.image_size - 1:
                if self.skip_count >= self.kernel_size - 2:
                    self.skip_count = 0
                    self.col_count = self.kernel_size - 2
                else:
                    self.skip_count += 1
                print(f"skip: {self.name} {self.entry_count}, {self.col_count}")
                self.current_time = time + 1 / self.fpga_clk_freq
            else:
                # print(f"{self.name}: {self.full_count}")
                self.col_count += 1
                print(f"act: {self.name} {self.entry_count}, {self.col_count}")
                self.current_time = time + self.total_latency
                self.start_next()
