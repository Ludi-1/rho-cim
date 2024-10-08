from abc import abstractmethod
from modules.module import Module
from math import ceil


class Control(Module):
    def __init__(
        self,
        f,
        name: str,
        next_module: Module,  # Should always be a CIM module
        param_dict: dict,
    ):
        super().__init__(f, name, next_module)

        self.input_size: int = param_dict["input_size"]  # CNN input square image size

        self.datatype_size: int = param_dict[
            "datatype_size"
        ]  # Datatype size of input buffer

        self.clk_freq: float = param_dict["fpga_clk_freq"]  # Clock frequency
        self.crossbar_rows: int = param_dict["crossbar_size"]

        self.v_cim_tiles = param_dict["cim_param_dict"]["v_tiles"]

        self.bus_width: int = param_dict["bus_width"]  # Bus width
        self.bus_latency: int = param_dict[
            "bus_latency"
        ]  # Latency to transfer data in cycles

        self.ibuf_ports: int = param_dict["ibuf_ports"]
        self.ibuf_read_latency: int = param_dict[
            "ibuf_read_latency"
        ]  # Latency for reading from ibuf, incorporated in operation latency

        # self.num_writes: int = ceil(self.input_size / min(self.v_cim_tiles, self.ibuf_ports)) # Amount of writes to the RD buffers

        self.num_writes = self.datatype_size # min(self.input_size, self.crossbar_rows) / 16 * self.datatype_size

        self.transfer_cycles: int = (
            ceil(min(self.crossbar_rows, self.input_size) / self.bus_width)
        ) # Cycles needed for filling RD buffer

        self.total_latency = (
            self.num_writes
            * self.transfer_cycles
            / self.clk_freq
        )
        # print(
        #     f"{self.name} - Total: {self.total_latency}"
        # )
