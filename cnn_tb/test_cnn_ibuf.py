import cocotb
from cocotb.triggers import FallingEdge, Timer, Edge, RisingEdge
from cocotb.clock import Clock
from cocotb.types import LogicArray

@cocotb.test()
async def cnn_ibuf_test_1(dut):
    cocotb.start_soon(Clock(dut.i_clk, 1, units='ns').start())
    dut.i_data <= "111111110000000010101010"
    await Timer(10**4, units="ns")  # wait a bit