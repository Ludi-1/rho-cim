import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge
import random

@cocotb.test()
async def ibuf_test(dut):
    clock = Clock(dut.clk, 10, units="ns")  # Create a 10ns clock period
    cocotb.start_soon(clock.start())  # Start the clock

    # Reset signals
    dut.rst.value = 0
    dut.i_start_ctrl.value = 0

    for input_value_idx in range(dut.input_size.value):
        input_value: int = random.randint(0, 2**dut.datatype_size.value - 1)
        dut.i_data[input_value_idx].value = input_value

    # Wait for a rising edge on the clock
    await RisingEdge(dut.clk)
    dut.i_start_ctrl.value = 1
    for i in range(1000):
        await RisingEdge(dut.clk)

    # input_values: list[int] = []
    # # Write and read data after 10 clock cycles
    # for cycle in range(dut.fifo_length.value):
    #     dut.i_write_enable.value = 1
    #     input_value: int = random.randint(0, 2**len(dut.i_data) - 1)
    #     input_values.append(input_value)
    #     dut.i_data.value = input_value  # Random data
    #     await RisingEdge(dut.clk)
    # dut.i_write_enable.value = 0
    # print(input_values)
    # for i in range(100):
    #     await RisingEdge(dut.clk)
    # print("Reading data from o_data:")
    # for i in range(len(dut.o_data)):
    #     print(f"o_data[{i}]: {int(dut.o_data[i].value)}, {input_values[-1-i]}), {int(dut.o_data[i].value) == input_values[i]}")
    #     # assert int(dut.o_data[i].value) == input_values[-1-i], f"Output data mismatch! Expected: {input_values[-1-i]}, Got: {int(dut.o_data[i].value)}"
