"""CIM Module
This module should instantiate CIM Tile(s)

"""

from math import ceil
from modules.module import Module


class CIM(Module):
    def __init__(self, f, name: str, next_module: Module, param_dict: dict, f_r):
        super().__init__(f, name, next_module, f_r)
        self.total_latency = param_dict[
            "total_latency"
        ]  # CIM Tile delay should be filled in manually
        self.start_count = 0
        self.total_energy = param_dict["total_energy"]
        self.num_tiles = param_dict["num_tiles"]

    def start(self, time):
        self.fd.write(f"{self.name}: Started at {time}\n")
        self.start_count += 1
        super().start(time)

    def __del__(self):
        energy = self.total_energy*self.start_count*self.num_tiles
        self.fr.write(f"{self.name}, #N Tiles: {self.num_tiles}, Energy: {energy}J\n")
        # print(
        #     f"{self.name}, Num of activations: {self.start_count}, #tiles: {self.num_tiles}"
        # )
        # print(
        #     f"{self.name}, total energy consumption: {self.total_energy*self.start_count*self.num_tiles}J"
        # )
