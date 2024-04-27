from modules.module import Module
from math import ceil


class Func(Module):
    def __init__(self, f, name: str, next_module: Module, param_dict: dict):
        super().__init__(f, name, next_module)

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
        ]  # Latency to transfer data from obuf->fpga in cycles
        self.operation_latency: int = param_dict[
            "operation_latency"
        ]  # Latency for post-processing
        self.ibuf_write_latency: int = param_dict[
            "ibuf_write_latency"
        ]  # Latency for writing to ibuf, incorporated in operation freq

        # self.transfer_latency: int = (
        #     ceil(self.datatype_size / self.bus_width) * self.bus_latency
        # )  # Latency for reading from output buffers
        # self.obuf_reads: int =  ceil(ceil(self.input_size / self.crossbar_rows) / self.func_ports) # Num of reads from obuf

        # self.total_latency: float = (
        #     (1 / self.clk_freq)
        #     * (((self.operation_latency + self.transfer_latency) * self.obuf_reads) + 1) * self.output_size
        # )   # Time to produce a single element of one output channel

        self.total_latency: float = (
            (1 / self.clk_freq)
            * self.crossbar_rows / self.datatype_size
        )   # Time to produce a single element of one output channel

        self.fpga_power = param_dict["fpga_power"]
        # print(
        #     f"{self.name} - Total: {self.total_latency}"
        # )
