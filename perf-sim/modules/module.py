"""
Abstract class template for every module.
The abstract methods are overridden for their unique and predefined behaviour
"""

from abc import ABC, abstractmethod


class Module(ABC):
    def __init__(self, f, name: str, next_module=None, f_r=None):
        """Add all user configurable parameters"""
        if f_r is not None:
            self.fr = f_r
        else:
            self.fr = None
        self.fd = f
        self.current_time = 0
        self.next_module: Module = next_module
        self.name: str = name
        self.total_latency: int = 0

    # def start(self, time):
    #     self.fd.write(f"{self.name}: Started at {time}, prev time = {self.current_time}\n")
    #     if time >= self.current_time:  # Should always be true
    #         self.current_time = time + self.total_latency
    #     else:
    #         print(f"Module {self.name} started in the past: {time}")
    #         raise Exception(
    #             f"Module {self.name} started in the past: {time}, {self.current_time}"
    #         )

    #     self.start_next()

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
            self.current_time = time
        if self.next_module is not None:
            # print(f"{self.name}->{self.next_module.name}, {self.current_time - self.next_module.current_time}")
            if self.next_module.current_time > self.current_time:  # Next module is busy
                self.current_time = (
                    self.next_module.current_time + self.total_latency
                )  # Wait until next module is done
            else:
                self.current_time = self.current_time + self.total_latency
            self.fd.write(f"{self.name}: Done at {self.current_time}\n")
            self.next_module.start(self.current_time)
        else:  # Next module is None, don't do anything
            pass
            # print(f"{self.name}: Next module is None")
    # def start_next(self):
    #     """Start the next module that it is connected to\n
    #     If the next module is busy, start the next module at the moment the next module is done
    #     """
    #     if self.next_module is not None:
    #         # print(f"{self.name}->{self.next_module.name}, {self.current_time - self.next_module.current_time}")
    #         if self.next_module.current_time > self.current_time:  # Next module is busy
    #             self.current_time = (
    #                 self.next_module.current_time
    #             )  # Wait until next module is done
    #         self.next_module.start(self.current_time)
    #     else:  # Next module is None, don't do anything
    #         pass
    #         # print(f"{self.name}: Next module is None")
