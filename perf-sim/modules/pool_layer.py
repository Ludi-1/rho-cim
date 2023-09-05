"""Pooling Layer class
Bundles a set of modules together that make up a pooling layer
This layer should be connected to another layer or None if it is the last layer
"""

from modules.module import Module


class CNN_Layer(Module):
    def __init__(self, name: str, next_layer: Module, param_dict: dict):
        if next_layer is not None:
            self.next_module = next_layer.ctrl
        else:
            self.next_module = None
        self.name: str = name

        self.fpga_clk_freq: float = param_dict["fpga_clk_freq"]  # Clock frequency

        self.image_size: int = param_dict["image_size"]
        self.kernel_size: int = param_dict["kernel_size"]

        self.input_channels: int = param_dict["input_channels"]
        self.output_channels: int = param_dict["output_channels"]

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

        self.ctrl = self

        self.current_time = self.ctrl.current_time

    def start(self, time):
        self.ctrl.start(time)
