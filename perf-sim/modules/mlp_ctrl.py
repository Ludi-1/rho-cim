from modules.module import Module
from math import ceil


class MLP_Control(Module):
    def __init__(
        self,
        name: str,
        next_module: Module,  # Should always be a CIM module
        clk_freq: float,  # FPGA clk freq
        input_neurons: int,  # Amount of input neurons (in ibuf)
        crossbar_rows: int,  # Crossbar rows of CIM tile
        ibuf_ports: int,  # Read ports available from input buffer
        datatype_size: int,  # Datatype size of input buffer data
        bus_width: int,  # Bus width available between FPGA -> CIM
        bus_latency: int,  # Bus latency for transferring data to RD buffers
        ibuf_read_latency: int = 1,  # Latency for reading from the input buffer
    ):
        self.next_module: Module = next_module
        self.clk_freq: float = clk_freq  # FPGA clock frequency
        self.num_writes: int = ceil(
            ceil(input_neurons / crossbar_rows) / ibuf_ports
        )  # Amount of writes to the RD buffers
        self.transfer_latency: int = ceil(datatype_size / bus_width) * bus_latency
        self.current_time: float = 0
        self.total_latency = (
            (1 / clk_freq) * self.num_writes * self.transfer_latency * ibuf_read_latency
        )  # Time to consume input buffer
        self.name: str = name

    def start(self, time):
        print(f"{self.name}: Started at {time}")
        if time >= self.current_time:  # Should always be true
            self.current_time = time + self.delay
        else:
            raise Exception(f"Module {self.name} started in the past: {time}")

        self.start_next()
