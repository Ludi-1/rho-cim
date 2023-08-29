from modules.module import Module


class MLP_Func(Module):
    def __init__(self, name: str, next_module: Module, clk_freq: float, neurons: int):
        self.next_module: Module = next_module  # Next module to start
        self.clk_freq: float = clk_freq  # Clock frequency
        self.func_cycles: int = neurons  # Cycles required to consume output buffer
        self.current_time: float = 0  # The time this module can be started
        self.delay: float = (
            1 / clk_freq
        ) * self.func_cycles  # Time this module is busy
        self.name: str = name

    def start(self, time):
        print(f"{self.name}: Started at {time}")
        if time >= self.current_time:  # Should always be true
            self.current_time = time + self.delay
        else:
            raise Exception(f"Module {self.name} started in the past: {time}")

        self.start_next()
