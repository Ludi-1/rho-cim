# rho-cim

## Prerequisites
Install gtkwave by
```
sudo apt-get install gtkwave
```
and ghdl by
```
sudo apt-get install ghdl
```

## Usage
Execute a testbench `<tb_name>_tb.vhdl` by running
```
make TESTBENCH=<tb_name>
```

I/O's can be rerouted internally in the FPGA, so each controller uses the exact amount of tiles you need per layer on demand

1. Bandwidth CPU -> Input buffer
2. Bandwidth Input buffer -> CIM Tiles
3. CIM Tiles activation latency

2 + 3 + (|1-3|) critical latency

Bandwidth_2 (bits/sec) = Datatype size input buffer (bits) * Clock frequency (Hz)

Determine latency CIM tile activation (3)

-
Finish functional unit
-
Design space exploration by varying number of CIM tiles, multiple functional units

-
Interface functional unit -> Next control unit / Layer