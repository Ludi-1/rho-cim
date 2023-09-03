from modules.module import Module
from math import ceil


class CNN_Control(Module):
    def __init__(
        self,
        name: str,
        next_module: Module,  # Should always be a CIM module
        param_dict: dict,
    ):
        self.next_module: Module = next_module
        self.current_time: float = 0
        self.name: str = name

        self.image_size: int = param_dict["image_size"]  # CNN input square image size
        self.kernel_size: int = param_dict[
            "kernel_size"
        ]  # CNN kernel size applied over image
        self.datatype_size: int = param_dict[
            "datatype_size"
        ]  # Datatype size of input buffer

        self.clk_freq: float = param_dict["fpga_clk_freq"]  # Clock frequency
        self.crossbar_rows: int = param_dict["crossbar_size"]

        self.bus_width: int = param_dict["bus_width"]  # Bus width
        self.bus_latency: int = param_dict[
            "bus_latency"
        ]  # Latency to transfer data in cycles

        self.ibuf_ports: int = param_dict["kernel_size"]
        self.ibuf_read_latency: int = param_dict[
            "ibuf_read_latency"
        ]  # Latency for reading from ibuf, incorporated in operation freq

        self.entry_count: int = 0
        self.fifo_size: int = self.image_size * (self.kernel_size - 1) + self.kernel_size
        self.total_latency = self.kernel_size**2 / self.clk_freq

    def start(self, time):
        print(f"{self.name}: Started at {time}")
        if time >= self.current_time:  # Should always be true
            if self.entry_count == self.fifo_size:
                self.current_time = time + self.total_latency
                self.start_next()
            else:
                self.entry_count += 1
                self.current_time = time + 1/self.clk_freq
        else:
            raise Exception(f"Module {self.name} started in the past: {time}")