"""MLP Layer class
Bundles a set of modules together that make up a fully connected layer
This layer should be connected to another layer or None if it is the last layer
"""

from modules.module import Module
from modules.mlp_ctrl import MLP_Control
from modules.mlp_func import MLP_Func
from modules.cim import CIM
from math import ceil


class MLP_Layer(Module):
    def __init__(self, name: str, next_module: Module, param_dict: dict):
        super().__init__(name, next_module)

        self.func = MLP_Func(
            f"({self.name}, func)", next_module=self.next_module, param_dict=param_dict
        )

        cim_dict = param_dict["cim_param_dict"]
        cim_dict["num_tiles"] = param_dict["input_size"] * ceil(
            param_dict["output_size"]
            * param_dict["datatype_size"]
            / param_dict["crossbar_size"]
        )
        self.cim = CIM(
            f"({self.name}, cim)",
            next_module=self.func,
            param_dict=param_dict["cim_param_dict"],
        )
        self.ctrl = MLP_Control(
            f"({self.name}, ctrl)", next_module=self.cim, param_dict=param_dict
        )

        self.current_time = self.ctrl.current_time

    def start(self, time):
        # print(f"{self.name}: Started at {time}")
        self.ctrl.start(time)
