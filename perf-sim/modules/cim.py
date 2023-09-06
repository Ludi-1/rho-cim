"""CIM Module
This module should instantiate CIM Tile(s)

"""

from math import ceil
from modules.module import Module


class CIM(Module):
    def __init__(self, name: str, next_module: Module, param_dict: dict):
        super().__init__(name, next_module)
        self.total_latency = param_dict[
            "total_latency"
        ]  # CIM Tile delay should be filled in manually
        self.start_count = 0
        self.total_energy = param_dict["total_energy"]
        self.num_tiles = param_dict["num_tiles"]

    def start(self, time):
        self.start_count += 1
        super().start(time)

    def __del__(self):
        print(
            f"{self.name}, total energy consumption: {self.total_energy*self.start_count*self.num_tiles}J"
        )
