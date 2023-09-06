from modules.module import Module
from math import ceil


class Func(Module):
    def __init__(self, name: str, next_module: Module, param_dict: dict):
        super().__init__(name, next_module)

        self.clk_freq: float = param_dict["fpga_clk_freq"]  # Clock frequency
        self.input_size: int = param_dict["input_size"]
        self.output_size: int = param_dict["output_size"]
        self.crossbar_rows: int = param_dict["crossbar_size"]
        self.func_ports: int = param_dict["func_ports"]
        self.datatype_size: int = param_dict[
            "datatype_size"
        ]  # Datatype size of output buffers
        self.bus_width: int = param_dict["bus_width"]  # Bus width
        self.bus_latency: int = param_dict[
            "bus_latency"
        ]  # Latency to transfer data in cycles
        self.operation_latency: int = param_dict[
            "operation_latency"
        ]  # Latency for post-processing
        self.ibuf_write_latency: int = param_dict[
            "ibuf_write_latency"
        ]  # Latency for writing to ibuf, incorporated in operation freq

        self.num_operations: int = self.output_size * ceil(
            ceil(self.input_size / self.crossbar_rows) / self.func_ports
        )  # Operations required to consume output buffer
        self.transfer_latency: int = (
            ceil(self.datatype_size / self.bus_width) * self.bus_latency
        )  # Latency for readfing from outpt buffers
        self.total_latency: float = (
            (1 / self.clk_freq)
            * self.num_operations
            * (self.operation_latency + self.ibuf_write_latency)
            * self.transfer_latency
        )  # Time this module is busy

        self.fpga_power = param_dict["fpga_power"]

        self.start_count = 0

    def start(self, time):
        self.start_count += 1
        super().start(time)

    def __del__(self):
        if self.next_module is None:
            print(
                f"{self.name}: FPGA total power consumption = {self.total_latency * self.fpga_power}J"
            )
