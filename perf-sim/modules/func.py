from modules.module import Module
from math import ceil, log2


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
        self.obuf_bus_width: int = param_dict["obuf_bus_width"]  # Bus width
        self.bus_latency: int = param_dict[
            "bus_latency"
        ]  # Latency to transfer data from obuf->fpga in cycles
        self.operation_latency: int = param_dict[
            "operation_latency"
        ]  # Latency for post-processing
        self.ibuf_write_latency: int = param_dict[
            "ibuf_write_latency"
        ]  # Latency for writing to ibuf, incorporated in operation freq

        num_elements = min(self.crossbar_rows / self.datatype_size, self.output_size) # Output elements to read per tile
        obuf_data_size = 2*self.datatype_size + ceil(log2(self.crossbar_rows)) # Datatype size of obuf element
        total_obuf_data = num_elements * obuf_data_size # Total data to be read from obuf

        self.num_reads = ceil(total_obuf_data / self.obuf_bus_width)

        self.total_latency: float = (
            self.num_reads
            / self.clk_freq
        )

        self.fpga_power = param_dict["fpga_power"]
        # print(
        #     f"{self.name} - Total: {self.total_latency}"
        # )
