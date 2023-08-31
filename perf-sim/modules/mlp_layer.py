"""MLP Layer class
Bundles a set of modules together that make up a fully connected layer
This layer should be connected to another layer or None if it is the last layer
"""

from modules.module import Module
from modules.mlp_ibuf import MLP_Input_Buffer
from modules.mlp_ctrl import MLP_Control
from modules.mlp_func import MLP_Func
from modules.cim import CIM


class MLP_Layer(Module):
    def __init__(self, name: str, next_layer: Module, param_dict: dict):
        if next_layer is not None:
            self.next_module = next_layer.ctrl
        else:
            self.next_module = None
        self.name: str = name

        self.fpga_clk_freq: float = param_dict["fpga_clk_freq"]  # Clock frequency
        self.input_neurons: int = param_dict["input_neurons"]
        self.output_neurons: int = param_dict["output_neurons"]
        self.datatype_size: int = param_dict[
            "datatype_size"
        ]  # Datatype size of input buffer
        self.bus_width: int = param_dict["bus_width"]  # Bus width
        self.bus_latency: int = param_dict[
            "bus_latency"
        ]  # Latency to transfer data in cycles
        self.crossbar_size: int = param_dict["crossbar_size"]

        self.ibuf_ports: int = param_dict["ibuf_ports"]
        self.ibuf_read_latency: int = param_dict[
            "ibuf_read_latency"
        ]  # Latency for reading from ibuf, incorporated in operation freq

        self.func_ports: int = param_dict["func_ports"]
        self.operation_latency: int = param_dict[
            "operation_latency"
        ]  # Latency for post-processing
        self.ibuf_write_latency: int = param_dict[
            "ibuf_write_latency"
        ]  # Latency for writing to ibuf, incorporated in operation freq

        self.func = MLP_Func(
            f"({self.name}, func)",
            next_module=self.next_module,
            param_dict=param_dict
        )
        self.cim = CIM(
            f"({self.name}, cim)", next_module=self.func, param_dict=param_dict["cim_param_dict"]
        )
        self.ctrl = MLP_Control(
            f"({self.name}, ctrl)",
            next_module=self.cim,
            param_dict=param_dict
        )

        self.current_time = self.ctrl.current_time

    def start(self, time):
        self.ctrl.start(time)
