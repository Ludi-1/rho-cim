from modules.ctrl import Control
from modules.module import Module


class MLP_Control(Control):
    def __init__(
        self,
        name: str,
        next_module: Module,  # Should always be a CIM module
        param_dict: dict,
    ):
        param_dict["input_size"] = param_dict["input_neurons"]
        super().__init__(name, next_module, param_dict)
