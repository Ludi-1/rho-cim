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

### Testbenches
Execute a cocotb testbench `test_<module_name>.py` by running while inside the correct folder (`cnn_tb`/`tb`/`mlp_tb`):
```
make TOPLEVEL=<module_name>
```

For generating all the graphs of the synthesis results, go to the `data` folder and run `run_all.py`. Otherwise run the individual scripts inside this folder.

### Performance simulator
```
git clone git@github.com:Ludi-1/rho-cim.git # Setup repository
cd rho-cim/perf-sim
virtualenv --python=/usr/bin/python3.10 .venv # Setup virtual Python environment
echo 'export PYTHONPATH="$PWD:$PYTHONPATH"' >> .venv/bin/activate
source .venv/bin/activate
```

## Folder structure
```
- cnn_tb    # cocotb testbenches for hdl_cnn modules
- data      # All synthesis data and scripts for plotting
    - plots # All generated figures from scripts and data
    - synthesis_results # Excel spreadsheets of resource utilization
- doc       # Contains wavedrom script for generating waveform figures
- hdl       # HDL implementation of MLP neural network
- hdl_cnn   # HDL implementation of CNN neural network
- hdl_mlp   # Prototype HDL implementation of MLP with FIFO input buffers
- mlp_tb    # cocotb testbenches for hdl_mlp modules
- tb        # cocotb testbenches for hdl modules
- perf-sim  # Python performance simulator
```