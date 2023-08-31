"""
Abstract class template for every module.
The abstract methods are overridden for their unique and predefined behaviour
"""

from abc import ABC, abstractmethod


class Module(ABC):
    @abstractmethod
    def __init__(self, name: str, next_module=None, time: float = 0):
        """Add all user configurable parameters"""
        self.current_time = time
        self.next_module: Module = next_module
        self.name: str = name
        pass

    @abstractmethod
    def start(self):
        """Start this module\n
        Add intended behaviour\n
        Call start_next() after a delay
        """
        pass

    def start_next(self):
        """Start the next module that it is connected to\n
        If the next module is busy, start the next module at the moment the next module is done
        """
        if self.next_module is not None:
            if self.next_module.current_time > self.current_time:  # Next module is busy
                self.current_time = (
                    self.next_module.current_time
                )  # Wait until next module is done
            self.next_module.start(self.current_time)
        else:  # Next module is None, don't do anything
            pass
            # print(f"{self.name}: Next module is None")
