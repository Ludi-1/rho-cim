from modules.module import Module

class MLP_Control(Module):

    def __init__(self, name: str, next_module: Module, clk_freq: float, size: int):
        self.next_module: Module = next_module
        self.clk_freq: float = clk_freq
        self.size: int = size
        self.current_time: float = 0
        self.delay = (1/clk_freq) * self.size
        self.name: str = name

    def start(self, time):
        print(f"{self.name}: Started at {time}")
        if time >= self.current_time: # Should always be true
            self.current_time = time + self.delay
        else:
            raise Exception(f"Module {self.name} started in the past: {time}")

        self.start_next()