from modules.module import Module
from math import ceil


class MLP_Control(Module):
    def __init__(
        self,
        name: str,
        next_module: Module,  # Should always be a CIM module
        param_dict: dict
    ):
        self.next_module: Module = next_module
        self.current_time: float = 0
        self.name: str = name

        self.clk_freq: float = param_dict["fpga_clk_freq"]  # Clock frequency
        self.input_neurons: int = param_dict["input_neurons"]
        self.crossbar_rows: int = param_dict["crossbar_size"]
        self.ibuf_ports: int = param_dict["ibuf_ports"]
        self.datatype_size: int = param_dict[
            "datatype_size"
        ]  # Datatype size of input buffer
        self.bus_width: int = param_dict["bus_width"]  # Bus width
        self.bus_latency: int = param_dict[
            "bus_latency"
        ]  # Latency to transfer data in cycles
        self.ibuf_read_latency: int = param_dict[
            "ibuf_read_latency"
        ]  # Latency for reading from ibuf, incorporated in operation freq

        self.num_writes: int = ceil(
            ceil(self.input_neurons / self.crossbar_rows) / self.ibuf_ports
        )  # Amount of writes to the RD buffers
        self.transfer_latency: int = ceil(self.datatype_size / self.bus_width) * self.bus_latency
        self.total_latency = (
            (1 / self.clk_freq) * self.num_writes * self.transfer_latency * self.ibuf_read_latency
        )  # Time to consume input buffer

    def start(self, time):
        print(f"{self.name}: Started at {time}")
        if time >= self.current_time:  # Should always be true
            self.current_time = time + self.delay
        else:
            raise Exception(f"Module {self.name} started in the past: {time}")

        self.start_next()
