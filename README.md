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