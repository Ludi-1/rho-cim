from modules.module import Module
from math import ceil


class MLP_Func(Module):
    def __init__(
        self,
        name: str,
        next_module: Module,
        param_dict: dict
    ):
        self.next_module: Module = next_module  # Next module to start

        self.clk_freq: float = param_dict["fpga_clk_freq"]  # Clock frequency
        self.input_neurons: int = param_dict["input_neurons"]
        self.output_neurons: int = param_dict["output_neurons"]
        self.crossbar_rows: int = param_dict["crossbar_rows"]
        self.func_ports: int = param_dict["func_ports"]
        self.datatype_size: int = param_dict["datatype_size"] # Datatype size of output buffers
        self.bus_width: int = param_dict["bus_width"] # Bus width
        self.bus_latency: int = param_dict["bus_latency"] # Latency to transfer data in cycles
        self.operation_latency: int = param_dict["operation_latency"]  # Latency for post-processing
        self.ibuf_write_latency: int = param_dict["ibuf_write_latency"] # Latency for writing to ibuf, incorporated in operation freq

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
