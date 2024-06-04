import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge
import random

@cocotb.test()
async def pool_test(dut):
    clock = Clock(dut.clk, 4, units="ns")  # Create a 4ns clock period
    cocotb.start_soon(clock.start())  # Start the clock
    INPUT_CHANNELS = dut.INPUT_CHANNELS.value
    IMG_DIM = dut.IMG_DIM.value
    KERNEL_DIM = dut.KERNEL_DIM.value
    FIFO_LENGTH = IMG_DIM * (KERNEL_DIM - 1) + KERNEL_DIM
    dut.i_ibuf_we.value = 0
    dut.i_start.value = 0
    dut.i_next_ready.value = 0
    await RisingEdge(dut.clk)
    dut.i_ibuf_we.value = 1
    for fifo_idx in range(FIFO_LENGTH):
        for input_channel in range(INPUT_CHANNELS):
            dut.i_ibuf_wr_data[input_channel].value = fifo_idx
        await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)