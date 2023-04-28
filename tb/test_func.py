import cocotb
from cocotb.triggers import FallingEdge, Timer, Edge, RisingEdge
from cocotb.clock import Clock
from cocotb.types import LogicArray, Array, Range, Bit
import math

from random import seed
from random import randint

seed(1)

input_size: int = 1500  # Number of inputs for full layer
max_datatype_size: int = 32  # Max size of data (bits)
tile_rows: int = 512
tile_columns: int = 512
row_split_tiles: int = 2
col_split_tiles: int = 3
n_tiles: int = row_split_tiles * col_split_tiles
addr_out_buf_size: int = math.ceil(math.log2(tile_columns))
row_shift: int = math.ceil(math.log2(tile_rows))


class CIM_Tile:
    def __init__(self, row, col):
        self.outbuf = [LogicArray(0, Range(max_datatype_size - 1, "downto", 0))] * tile_columns
        for i in range(0, tile_columns):
            self.outbuf[i] = LogicArray(i, Range(max_datatype_size - 1, "downto", 0))
        self.col = col
        self.row = row

    async def startup(self, dut):
        await cocotb.start(self.output_buf_co(dut))

    async def output_buf_co(self, dut):
        """Present data from output buffer"""
        while True:
            await Edge(dut.o_addr_out_buf)
            o_obuf_addr = dut.o_addr_out_buf.value.integer # Output buffer address count
            self.output_data = LogicArray(self.outbuf[o_obuf_addr], Range(max_datatype_size - 1, "downto", 0)) # Data from output buffer

            #i_data_str = LogicArray(dut.i_data.value.binstr, Range(n_tiles * max_datatype_size - 1, "downto", 0)) # All tile data vectors -> F unit || Array of bits
            #row_shift = col_split_tiles * max_datatype_size * self.row # Address space of one row set
            #lower_index = self.col * max_datatype_size + row_shift # Lower index of tile column addr space
            #upper_index = (self.col + 1) * max_datatype_size + row_shift - 1 # Upper index
            #dut._log.info(f"Output {self.row}, {self.col}: {list(output_data)}")
            #dut._log.info(f"Output {self.row}, {self.col}: {lower_index}, {upper_index}")
            # dut._log.info(f"old {lower_index} {upper_index}", str(i_data_str.binstr))
            # i_data_str[upper_index:lower_index] = output_data
            # dut._log.info(f"new {lower_index} {upper_index}", str(i_data_str.binstr))
            #dut.i_data.value[5] = 1
            #dut.i_data.value[upper_index:lower_index] = LogicArray(output_data, Range(n_tiles * max_datatype_size - 1, "downto", 0))
            #dut.i_data.value = LogicArray(i_data_str, Range(n_tiles * max_datatype_size - 1, "downto", 0))
            #dut._log.info("old", output_data.binstr)
            #dut.i_data.value[lower_index:upper_index] = output_data.binstr
            #dut._log.info("new", dut.i_data.value.binstr)
            #dut._log.info("new", dut.i_data.value.binstr)

class All_Tiles:
    def __init__(self, row, col):
        self.col = col
        self.row = row
        self.tiles = [[0]* col for i in range(self.row)]
        for row in range(0, self.row):
            for col in range(0, self.col):
                self.tiles[row][col] = CIM_Tile(row, col)

    async def i_data_update(self, dut):
        while True:
            await Edge(dut.o_addr_out_buf)
            o_obuf_addr = dut.o_addr_out_buf.value.integer
            i_data_vector = ""
            for row in range(0, self.row):
                for col in range(0, self.col):
                    i_data_vector += self.tiles[row][col].outbuf[o_obuf_addr].binstr
            dut.i_data.value = LogicArray(i_data_vector)

@cocotb.test()
async def func_test_1(dut):
    """Try accessing the design."""

    print(dut.row_split_tiles.value.integer, dut.col_split_tiles.value.integer)
    cocotb.start_soon(Clock(dut.i_clk, 1, units="ns").start())

    tiles = All_Tiles(row_split_tiles, col_split_tiles)
    await cocotb.start(tiles.i_data_update(dut))

    dut.i_rst.value = 1
    await Timer(10, units="ns")  # wait a bit
    await FallingEdge(dut.i_clk)  # wait for falling edge/"negedge"
    dut.i_rst.value = 0
    dut.i_control.value = 1
    await Timer(20, units="ns")
    dut.i_control.value = 0
    await Timer(10**4, units="ns")  # wait a bit
