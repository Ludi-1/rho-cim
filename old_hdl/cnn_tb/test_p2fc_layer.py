import cocotb
from cocotb.triggers import FallingEdge, Timer, Edge, RisingEdge
from cocotb.clock import Clock
from cocotb.types import LogicArray


@cocotb.test()
async def p2fc_layer_test_1(dut):
    cocotb.start_soon(Clock(dut.i_clk, 1, units="ns").start())
    dut.i_rst.value = 1
    dut.i_next_layer_busy.value = 0
    await RisingEdge(dut.i_clk)
    dut.i_rst.value = 0
    dut.i_start.value = 1
    await RisingEdge(dut.i_clk)
    await RisingEdge(dut.i_clk)
    # if dut.o_layer_busy.value == 1:
    #     dut.i_start.value = 0
    # await RisingEdge(dut.i_clk)
    # await RisingEdge(dut.i_clk)
    # if dut.o_layer_busy.value == 0:
    #     dut.i_start.value = 1

    # await RisingEdge(dut.i_clk)
    # await RisingEdge(dut.i_clk)
    # if dut.o_layer_busy.value == 1:
    #     dut.i_start.value = 0

    await Timer(10**4, units="ns")  # wait a bit
