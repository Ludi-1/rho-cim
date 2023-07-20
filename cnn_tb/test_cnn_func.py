import cocotb
from cocotb.triggers import FallingEdge, Timer, Edge, RisingEdge
from cocotb.clock import Clock
from cocotb.types import LogicArray

@cocotb.test()
async def cnn_ibuf_test_1(dut):
    cocotb.start_soon(Clock(dut.i_clk, 1, units='ns').start())
    obuf_datatype_size = dut.obuf_datatype_size.value.integer
    n_tiles = dut.n_tiles.value.integer
    row_split_tiles = dut.row_split_tiles.value.integer
    col_split_tiles = dut.col_split_tiles.value.integer
    output_channels = dut.output_channels.value.integer
    print(obuf_datatype_size, n_tiles)
    print(row_split_tiles, col_split_tiles)
    dut.i_rst.value = 1
    dut.i_start.value = 0
    dut.i_next_ibuf_full.value = LogicArray("0"*output_channels)
    dut.i_tiles_done.value = LogicArray("0"*n_tiles)
    dut.i_next_layer_busy.value = 0
    dut.i_data.value = LogicArray("1"*obuf_datatype_size*n_tiles)

    await RisingEdge(dut.i_clk)
    await RisingEdge(dut.i_clk)

    # s_func_poll
    dut.i_rst.value = 0
    dut.i_start.value = 1
    await RisingEdge(dut.i_clk)

    # s_func_write
    dut.i_tiles_done.value = LogicArray("1"*n_tiles)
    
    # s_func_start
    for i in range(20):
        await RisingEdge(dut.i_clk)
    dut.i_next_ibuf_full.value = LogicArray("1"*output_channels)
    await Timer(10**4, units="ns")  # wait a bit