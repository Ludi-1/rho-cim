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
    dut.i_data[0].value = 0
    dut.i_we.value = 0
    dut.i_re.value = 0

    # Wait for a rising edge on the clock
    await RisingEdge(dut.clk)

    input_values: list[int] = []
    # Write and read data after 10 clock cycles
    for cycle in range(dut.fifo_length.value):
        dut.i_we.value = 1
        input_value: int = random.randint(0, 2**len(dut.i_data) - 1)
        input_values.append(input_value)
        dut.i_data[0].value = input_value  # Random data
        await RisingEdge(dut.clk)
    dut.i_we.value = 0
    #print(input_values)
    dut.i_re.value = 1
    for i in range(dut.DATA_WIDTH.value):
        await RisingEdge(dut.clk)
    dut.i_re.value = 0