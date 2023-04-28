import cocotb
from cocotb.triggers import FallingEdge, Timer, Edge, RisingEdge
from cocotb.clock import Clock
from cocotb.types import LogicArray

from random import seed
from random import randint
seed(1)


async def input_buffer(dut, in_buf):
    """Present data from input buffer"""
    while True:
        await Edge(dut.o_inbuf_count)
        o_inbuf_count = dut.o_inbuf_count.value
        dut.i_data.value = in_buf[int(o_inbuf_count)]

async def i_control(dut):
    while True:
        #dut._log.info("o_control is %s", dut.o_control.value)
        await Edge(dut.o_control)
        o_control = dut.o_control.value.integer
        #dut._log.info("o_control is %s", o_control)
        if o_control == 0:
            dut.i_control.value = 1
        elif o_control == 1:
            dut.i_control.value = 0
        else:
            dut.i_control.value = 0

@cocotb.test()
async def control_test_1(dut):
    input_size = dut.input_size.value.integer
    n_tiles = dut.n_tiles.value.integer
    in_buf = []
    for i in range(0, input_size):
        in_buf.append(i)
        #in_buf.append(randint(0, max_datatype_size**2 - 1))

    cocotb.start_soon(Clock(dut.i_clk, 1, units='ns').start())
    await cocotb.start(input_buffer(dut, in_buf))
    await cocotb.start(i_control(dut))
    dut.i_rst.value = 1
    dut.i_tiles_busy.value = LogicArray("1" * n_tiles)
    await RisingEdge(dut.i_clk)
    dut.i_rst.value = 0
    await Timer(15, units="ns")
    dut.i_tiles_busy.value = LogicArray("0" * n_tiles)
    await Edge(dut.o_start)
    await Timer(4.5, units="ns")
    dut.i_tiles_busy.value = LogicArray("1" * n_tiles)
    await Timer(125.3, units="ns")
    dut.i_tiles_busy.value = LogicArray("0" * n_tiles)
    #assert dut.my_signal_2.value[0] == 0, "my_signal_2[0] is not 0!"
    await Timer(10**4, units="ns")  # wait a bit