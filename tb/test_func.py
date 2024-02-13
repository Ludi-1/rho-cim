import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer
import random

@cocotb.test()
async def func_test(dut):
    clock = Clock(dut.clk, 10, units="ns")  # Create a 10ns clock period
    cocotb.start_soon(clock.start())  # Start the clock
    dut.rst.value = 1
    dut.i_start.value = 0
    dut.i_cim_busy.value = 0
    dut.i_next_busy.value = 0
    # print(dut.__dict__)
    # for h_idx in range(dut.h_cim_tiles.value):
    #     for v_idx in range(dut.v_cim_tiles.value):
    #         dut.i_data[v_idx][h_idx].value = (h_idx + v_idx) % 256
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
