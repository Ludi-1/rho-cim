"""
Abstract class template for every module.
The abstract methods are overridden for their unique and predefined behaviour
"""

from abc import ABC, abstractmethod


class Module(ABC):
    def __init__(self, f, name: str, next_module=None):
        """Add all user configurable parameters"""
        self.fd = f
        self.current_time = 0
        self.next_module: Module = next_module
        self.name: str = name
        self.total_latency: int = 0

    def start(self, time):
        """Start the next module that it is connected to\n
        If the next module is busy, start the next module at the moment the next module is done
        """
        if not (time >= self.current_time):
            print(f"Module {self.name} started in the past: {time}")
            raise Exception(
                f"Module {self.name} started in the past: {time}, {self.current_time}"
            )
        else:
            self.current_time = time + self.total_latency
        if self.next_module is not None:
            if self.next_module.current_time > self.current_time:  # Next module is busy
                self.current_time = (
                    self.next_module.current_time
                )  # Wait until next module is done
            if self.fd is not None:
                self.fd.write(f"{self.name}: Done at {self.current_time}\n")
            self.next_module.start(self.current_time)