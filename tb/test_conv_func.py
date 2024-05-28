import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge
import random

@cocotb.test()
async def conv_func_test(dut):
    clock = Clock(dut.clk, 4, units="ns")  # Create a 4ns clock period
    cocotb.start_soon(clock.start())  # Start the clock

    # Reset signals
    # dut.i_we.value = 0

    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    dut.i_start.value = 1
    dut.i_cim_ready = 1
    dut.i_next_ready = 1
    for i in range(400):
        await RisingEdge(dut.clk)