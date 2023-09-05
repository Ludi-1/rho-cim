import cocotb
from cocotb.triggers import FallingEdge, Timer, Edge, RisingEdge
from cocotb.clock import Clock
from cocotb.types import LogicArray, Array, Range, Bit
import math

from random import seed
from random import randint

seed(1)

ibuf_size: int = 1500  # Number of inputs for full layer
max_datatype_size: int = 32  # Max size of data (bits)
addr_out_buf_size: int = math.ceil(math.log2(ibuf_size))


@cocotb.test()
async def ibuf_test_1(dut):
    """Try accessing the design."""

    cocotb.start_soon(Clock(dut.i_clk, 1, units="ns").start())

    dut.i_write_enable.value = 1
    await RisingEdge(dut.i_clk)
    for i in range(0, ibuf_size):
        dut.i_data.value = i
        dut.i_write_addr.value = i
        await RisingEdge(dut.i_clk)
        dut.i_read_addr.value = i
        await Timer(1, units="fs")
        assert dut.o_data.value.integer == i
    await RisingEdge(dut.i_clk)
    dut.i_write_enable.value = 0
    await RisingEdge(dut.i_clk)
    for i in range(0, ibuf_size):
        dut.i_write_addr.value = randint(0, 1500 - 1)
        dut.i_data.value = randint(0, 2**32 - 1)
        await RisingEdge(dut.i_clk)
        dut.i_read_addr.value = i
        await Timer(1, units="fs")
        assert dut.o_data.value.integer == i
    await RisingEdge(dut.i_clk)
