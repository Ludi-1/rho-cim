import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer
import random

@cocotb.test()
async def ctrl_test(dut):
    clock = Clock(dut.clk, 10, units="ns")  # Create a 10ns clock period
    cocotb.start_soon(clock.start())  # Start the clock
    dut.rst.value = 1
    dut.i_start.value = 0
    dut.i_cim_busy.value = 0
    dut.i_func_busy.value = 0
    dut.i_data.value = 3
    await RisingEdge(dut.clk)
    dut.rst.value = 0
    dut.i_start.value = 1
    await RisingEdge(dut.clk)
    dut.i_start.value = 0
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    dut.i_start.value = 1
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    dut.i_cim_busy.value = 1
    await Timer(10e4, units='ns')
