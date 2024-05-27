import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge
import random

@cocotb.test()
async def fc_ctrl_test(dut):
    clock = Clock(dut.clk, 4, units="ns")  # Create a 4ns clock period
    cocotb.start_soon(clock.start())  # Start the clock

    # Reset signals
    dut.rst.value = 0
    dut.i_start.value = 0
    dut.i_cim_ready.value = 1
    dut.i_func_ready.value = 1

    await RisingEdge(dut.clk)
    # start CTRL unit
    dut.i_start.value = 1
    await RisingEdge(dut.clk)
    dut.i_start.value = 0
    for _ in range(dut.DATA_SIZE.value):
        while True:
            await RisingEdge(dut.clk)
            if dut.o_cim_start.value:
                dut.i_cim_ready.value = 0
                break

        await RisingEdge(dut.clk)
        dut.i_cim_ready.value = 1

    for _ in range(100):
        await RisingEdge(dut.clk)
    