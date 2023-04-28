import cocotb
from cocotb.triggers import FallingEdge, Timer, Edge, RisingEdge
from cocotb.clock import Clock
from cocotb.types import LogicArray, Array, Range, Bit
import math

from random import seed
from random import randint

seed(1)

@cocotb.test()
async def layer_test_1(dut):
    """Try accessing the design."""

    ibuf_size: int = dut.input_size.value.integer  # Number of inputs for full layer
    max_datatype_size: int = dut.max_datatype_size.value.integer  # Max size of data (bits)
    addr_out_buf_size: int = dut.addr_out_buf_size.value.integer

    cocotb.start_soon(Clock(dut.i_clk, 1, units="ns").start())

    dut.i_rst.value = 1
    dut.i_write_enable.value = 1
    dut.i_control.value = 0
    await RisingEdge(dut.i_clk)
    dut.i_rst.value = 0
    await RisingEdge(dut.i_clk)
    for i in range(0, ibuf_size):
        dut.i_data.value = i
        dut.i_write_addr.value = i
        await RisingEdge(dut.i_clk)
    dut.i_write_enable.value = 0
    dut.i_control.value = 1
    await FallingEdge(dut.o_control)
    dut.i_control.value = 0
    #await RisingEdge(dut.o_start)
    #await RisingEdge(dut.o_start)
    await Timer(10**4, units="ns")  # wait a bit


