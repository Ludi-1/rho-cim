from modules.module import Module
from math import ceil


class MLP_Func(Module):
    def __init__(
        self,
        name: str,
        next_module: Module,
        clk_freq: float,
        input_neurons: int,
        output_neurons: int,
        crossbar_rows: int,
        func_ports: int,
        datatype_size: int,  # Datatype size of output buffers
        bus_width: int,  # Bus width
        bus_latency: int,  # Latency to transfer data in cycles
        operation_latency: int = 1,  # Latency for post-processing
        ibuf_write_latency: int = 0,  # Latency for writing to ibuf, incorporated in operation freq
    ):
        self.next_module: Module = next_module  # Next module to start
        self.clk_freq: float = clk_freq  # Clock frequency
        self.num_operations: int = output_neurons * ceil(
            ceil(input_neurons / crossbar_rows) / func_ports
        )  # Operations required to consume output buffer
        self.transfer_latency: int = (
            ceil(datatype_size / bus_width) * bus_latency
        )  # Latency for readfing from outpt buffers
        self.current_time: float = 0  # The time this module can be started
        self.total_latency: float = (
            (1 / clk_freq)
            * self.num_operations
            * (operation_latency + ibuf_write_latency)
            * self.transfer_latency
        )  # Time this module is busy
        self.name: str = name

    def start(self, time):
        print(f"{self.name}: Started at {time}")
        if time >= self.current_time:  # Should always be true
            self.current_time = time + self.total_latency
        else:
            raise Exception(f"Module {self.name} started in the past: {time}")

        self.start_next()
