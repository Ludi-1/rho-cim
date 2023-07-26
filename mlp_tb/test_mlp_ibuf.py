import cocotb
from cocotb.triggers import FallingEdge, Timer, Edge, RisingEdge
from cocotb.clock import Clock
from cocotb.types import LogicArray

@cocotb.test()
async def mlp_ibuf_test_1(dut):
    cocotb.start_soon(Clock(dut.i_clk, 1, units='ns').start())
    dut.i_data.value = LogicArray("11110010")
    dut.i_write_enable.value = 1
    dut.i_rst.value = 1

    await RisingEdge(dut.i_clk)
    await RisingEdge(dut.i_clk)
    dut.i_rst.value = 0
    for i in range(0, 100):
        await RisingEdge(dut.i_clk)
        if dut.o_almost_full.value == 1:
            dut.i_write_enable.value = 0
            break
    await RisingEdge(dut.i_clk)
    await RisingEdge(dut.i_clk)
    dut.i_data.value = LogicArray("01010101")
    dut.i_write_enable.value = 1
    for i in range(0, 100):
        await RisingEdge(dut.i_clk)
        if dut.o_almost_full.value == 1:
            dut.i_write_enable.value = 0
    #await Timer(10**4, units="ns")  # wait a bit