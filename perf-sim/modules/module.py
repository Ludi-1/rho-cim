"""
Abstract class template for every module.
The abstract methods are overridden for their unique and predefined behaviour
"""

from abc import ABC, abstractmethod


class Module(ABC):

    """Add all user configurable parameters"""

    @abstractmethod
    def __init__(self, name: str, next_module=None, time: float = 0):
        self.current_time = time
        self.next_module: Module = next_module
        self.name: str = name
        pass

    """Start this module
    Add intended behaviour
    Call start_next() after a delay
    """

    @abstractmethod
    def start(self):
        pass

    def start_next(self):
        # print(f"{self.name}: start_next()")
        if self.next_module is not None:
            if self.next_module.current_time > self.current_time:  # Next module is busy
                self.current_time = (
                    self.next_module.current_time
                )  # Wait until next module is done
            self.next_module.start(self.current_time)
        else:
            pass
            # print(f"{self.name}: Next module is None")
