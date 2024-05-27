import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge
import random

@cocotb.test()
async def conv_ctrl_test(dut):
    clock = Clock(dut.clk, 4, units="ns")  # Create a 4ns clock period
    cocotb.start_soon(clock.start())  # Start the clock

    # Reset signals
    # dut.i_we.value = 0

    await RisingEdge(dut.clk)