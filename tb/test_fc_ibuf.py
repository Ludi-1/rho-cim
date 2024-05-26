import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge
import random

@cocotb.test()
async def ibuf_test(dut):
    clock = Clock(dut.clk, 4, units="ns")  # Create a 4ns clock period
    cocotb.start_soon(clock.start())  # Start the clock

    # Reset signals
    dut.i_we.value = 0
    # dut.i_data[0].value = 0
    dut.i_we.value = 0
    dut.i_se.value = 0

    # Wait for a rising edge on the clock
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    # input_values: list[int] = []

    for cycle in range(dut.FIFO_LENGTH.value):
        dut.i_we.value = 1
        # input_value = []
        for h_tile in range(dut.H_CIM_TILES_IN.value):
            for channel in range(dut.NUM_CHANNELS.value):
                pass
            # input_value.append(random.randint(0, 2**len(dut.i_data) - 1))
                # dut.i_data[h_tile][channel].value = random.randint(0, 2**len(dut.i_data) - 1)  # Random data
        # input_values.append(input_value)
        await RisingEdge(dut.clk)
    dut.i_we.value = 0

    dut.i_se.value = 1
    for i in range(dut.DATA_SIZE.value):
        await RisingEdge(dut.clk)
    dut.i_se.value = 0
    await RisingEdge(dut.clk)