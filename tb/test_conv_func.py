import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer
import random

@cocotb.test()
async def conv_func_test(dut):
    clock = Clock(dut.clk, 4, units="ns")  # Create a 4ns clock period
    cocotb.start_soon(clock.start())  # Start the clock

    dut.i_cim_ready.value = 0
    dut.i_next_ready.value = 0

    H_CIM_TILES = dut.H_CIM_TILES.value
    NUM_CHANNELS = dut.NUM_CHANNELS.value
    V_CIM_TILES = dut.V_CIM_TILES.value
    n = 10
    for h_idx in range(H_CIM_TILES):
        for channel in range(NUM_CHANNELS):
            for v_idx in range(V_CIM_TILES):
                #dut.i_data[h_idx * NUM_CHANNELS*V_CIM_TILES+channel*V_CIM_TILES+v_idx].value = n
                n += 5
    await RisingEdge(dut.clk)
    await Timer(10e3, units='ns')
    for i in range(400):
        await RisingEdge(dut.clk)