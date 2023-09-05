import cocotb
from cocotb.triggers import FallingEdge, Timer, Edge, RisingEdge
from cocotb.clock import Clock
from cocotb.types import LogicArray


@cocotb.test()
async def cnn_ibuf_test_1(dut):
    cocotb.start_soon(Clock(dut.i_clk, 1, units="ns").start())
    n_tiles = dut.n_tiles.value.integer
    output_channels = dut.output_channels.value.integer
    input_channels = dut.input_channels.value.integer
    datatype_size = dut.datatype_size.value.integer
    obuf_datatype_size = dut.obuf_datatype_size.value.integer

    dut.i_rst.value = 1
    dut.i_start.value = 0
    dut.i_tiles_done.value = LogicArray("0" * n_tiles)
    dut.i_next_layer_busy.value = 0
    dut.i_next_ibuf_full.value = LogicArray("0" * output_channels)
    dut.i_ibuf_data.value = LogicArray(("0" * datatype_size) * input_channels)
    dut.i_tile_data.value = LogicArray(("0" * obuf_datatype_size) * n_tiles)
    dut.i_write_enable.value = LogicArray("0" * input_channels)
    await RisingEdge(dut.i_clk)
    await RisingEdge(dut.i_clk)
    dut.i_rst.value = 0
    await RisingEdge(dut.i_clk)
    dut.i_write_enable.value = LogicArray("1" * input_channels)
    await RisingEdge(dut.i_clk)

    while True:
        if dut.o_ibuf_full.value.binstr == "1" * input_channels:
            dut.i_write_enable.value = LogicArray("0" * input_channels)
            dut.i_start.value = 1
            await RisingEdge(dut.i_clk)
            dut.i_start.value = 0
            while True:
                if dut.o_tile_start.value.binstr == "1" * n_tiles:
                    await RisingEdge(dut.i_clk)
                    await RisingEdge(dut.i_clk)
                    dut.i_tiles_done.value = LogicArray("1" * n_tiles)
                    break
                await RisingEdge(dut.i_clk)
            break
        await RisingEdge(dut.i_clk)
    await Timer(10**3, units="ns")  # wait a bit
