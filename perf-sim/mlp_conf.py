from modules.mlp_layer import Layer
from modules.agent import Agent
from itertools import pairwise
from modules.module import Module


class MLP_conf:
    def __init__(
        self,
        fpga_clk_freq: float,
        cim_clk_freq: float,
        inputs: int,
        neurons: list[int],
        start_times: list[float] = [0],
    ):
        self.fpga_clk_freq: float = fpga_clk_freq
        self.cim_clk_freq = cim_clk_freq
        self.layers: list[Layer] = [None]

        neurons.insert(0, inputs)
        n = len(neurons) - 1
        neuron_pairs = pairwise(reversed(neurons))
        for neuron_pair in neuron_pairs:
            print(neuron_pair)
            self.layers.insert(
                0,
                Layer(
                    name=f"Layer {n}",
                    next_layer=self.layers[0],
                    fpga_clk_freq=self.fpga_clk_freq,
                    cim_clk_freq=cim_clk_freq,
                    inputs=neuron_pair[1],
                    neurons=neuron_pair[0],
                ),
            )
            n -= 1

        self.agent = Agent(
            clk_freq=self.fpga_clk_freq,
            first_module=self.layers[0].ibuf,
            start_times=start_times,
        )

    def start(self):
        self.agent.start()
