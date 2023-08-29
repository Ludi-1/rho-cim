from modules.module import Module
from modules.mlp_ibuf import MLP_Input_Buffer
from modules.mlp_ctrl import MLP_Control
from modules.mlp_func import MLP_Func
from modules.cim import CIM


class Layer(Module):
    def __init__(
        self,
        name: str,
        next_layer: Module,
        fpga_clk_freq: float,
        cim_clk_freq: float,
        inputs: int,
        neurons: int,
    ):
        if next_layer is not None:
            self.next_module = next_layer.ibuf
        else:
            self.next_module = None

        self.fpga_clk_freq: float = fpga_clk_freq
        self.cim_clk_freq: float = cim_clk_freq
        self.inputs: int = inputs
        self.neurons: int = neurons
        self.name: str = name

        self.func = MLP_Func(
            f"({self.name}, func)",
            next_module=self.next_module,
            clk_freq=self.fpga_clk_freq,
            neurons=self.neurons,
        )
        self.cim = CIM(
            f"({self.name}, cim)", next_module=self.func, clk_freq=self.cim_clk_freq
        )
        self.ctrl = MLP_Control(
            f"({self.name}, ctrl)",
            next_module=self.cim,
            clk_freq=self.fpga_clk_freq,
            inputs=self.inputs,
        )
        self.ibuf = MLP_Input_Buffer(
            f"({self.name}, ibuf)",
            next_module=self.ctrl,
            clk_freq=self.fpga_clk_freq,
            size=self.inputs,
        )

        self.current_time = self.ibuf.current_time

    def start(self, time):
        self.ibuf.start(time)
