"""MLP configuration class
This MLP configuration class bundles multiple MLP layers together
An Agent module is connected to the first module (input buffer)
"""

from modules.mlp_layer import MLP_Layer
from modules.agent import Agent
from itertools import pairwise


class MLP_conf:
    def __init__(self, param_dict: dict):

        self.neuron_count_list: list[int] = param_dict["neuron_count_list"]
        self.neuron_count_list.insert(0, param_dict["input_count"])
        n = len(self.neuron_count_list) - 1
        neuron_pairs = pairwise(reversed(self.neuron_count_list))
        self.layer_list: list[MLP_Layer] = [None]
        for neuron_pair in neuron_pairs:
            layer_dict: dict = param_dict
            layer_dict["input_neurons"]: int = neuron_pair[1]
            layer_dict["output_neurons"]: int = neuron_pair[0]
            self.layer_list.insert(
                0,
                MLP_Layer(
                    name=f"Layer {n}", next_layer=self.layer_list[0], param_dict=layer_dict
                ),
            )
            n -= 1

        # Connect agent to first module of configuration
        self.agent = Agent(
            clk_freq=param_dict["fpga_clk_freq"],
            first_module=self.layer_list[0].ctrl,
            start_times=param_dict["start_times"],
        )

    def start(self):
        self.agent.start()
