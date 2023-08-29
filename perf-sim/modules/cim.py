"""CIM Module
This module should instantiate CIM Tile(s)

"""

from math import ceil
from modules.module import Module


class CIM(Module):
    def __init__(
        self,
        name: str,
        next_module: Module,
        clk_freq: float,
        datatype_size: int = 8,
        inputs: int = 1,
        neurons: int = 1,
    ):
        self.next_module: Module = next_module
        self.clk_freq: float = clk_freq
        self.current_time: float = 0
        self.tile_count = ceil(neurons / datatype_size) * inputs
        self.delay = (1 / clk_freq) * 10  # CIM Tile delay should be filled in manually
        self.name: str = name

    def start(self, time):
        print(f"{self.name}: Started at {time}")
        if time >= self.current_time:  # Should always be true
            self.current_time = time + self.delay
        else:
            raise Exception(f"Module {self.name} started in the past: {time}")

        self.start_next()
