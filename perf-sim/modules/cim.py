"""CIM Module
This module should instantiate CIM Tile(s)

"""

from math import ceil
from modules.module import Module


class CIM(Module):
    def __init__(self, name: str, next_module: Module, param_dict: dict):
        self.next_module: Module = next_module
        self.clk_freq: float = param_dict["cim_clk_freq"]
        self.current_time: float = 0
        self.total_latency = (1 / self.clk_freq) * param_dict[
            "total_latency"
        ]  # CIM Tile delay should be filled in manually
        self.name: str = name
