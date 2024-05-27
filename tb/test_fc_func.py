import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge
import random

@cocotb.test()
async def fc_func_test(dut):
    clock = Clock(dut.clk, 4, units="ns")  # Create a 4ns clock period
    cocotb.start_soon(clock.start())  # Start the clock

    # Reset signals
    dut.rst.value = 0
    dut.i_start.value = 0
    dut.i_next_ready.value = 1
    dut.i_cim_ready.value = 1
    # dut.i_data[0][0][0].value = 0
    