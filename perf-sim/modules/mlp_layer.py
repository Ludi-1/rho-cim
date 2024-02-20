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
    def __init__(self, name: str, next_module: Module, param_dict: dict, f, f_r):
        super().__init__(f, name, next_module)

        param_dict["cim_param_dict"]["v_tiles"] = ceil(
            param_dict["input_neurons"] * param_dict["input_channels"] / param_dict["crossbar_size"]
        )
        param_dict["cim_param_dict"]["h_tiles"] = ceil(
            param_dict["output_neurons"]
            * param_dict["datatype_size"]
            / param_dict["crossbar_size"]
        )

        param_dict["cim_param_dict"]["num_tiles"] = param_dict["cim_param_dict"]["v_tiles"] * param_dict["cim_param_dict"]["h_tiles"]

        self.func = MLP_Func(
            f=f,
            name=f"({self.name}, func)",
            next_module=self.next_module,
            param_dict=param_dict,
            f_r = f_r,
        )

        self.cim = CIM(
            f=f,
            name=f"({self.name}, cim)",
            next_module=self.func,
            param_dict=param_dict["cim_param_dict"],
            f_r = f_r,
        )

        self.ctrl = MLP_Control(
            name=f"({self.name}, ctrl)",
            next_module=self.cim,
            param_dict=param_dict,
            f=f,
        )

    def start(self, time):
        self.ctrl.start(time)
        self.current_time = self.ctrl.current_time
