# Makefile
# $(shell . .venv/bin/activate)

SIM = verilator
PWD=$(shell pwd)
TOPLEVEL_LANG = verilog
WAVES=1
EXTRA_ARGS += --trace-fst --trace-structs
EXTRA_ARGS += --trace --trace-structs

TOPLEVEL ?= ibuf

ifeq ($(TOPLEVEL),ibuf)
    VERILOG_SOURCES = $(shell pwd)/hdl/ibuf.sv
    MODULE = tb.test_ibuf
    # SIM_ARGS += -gdatatype_size=8
    # SIM_ARGS += -gfifo_length=5
else ifeq ($(TOPLEVEL),ctrl)
    VERILOG_SOURCES = $(shell pwd)/hdl/ctrl.sv
    MODULE = tb.test_ctrl
else
    $(error Given TOPLEVEL '$(TOPLEVEL)' not supported)
endif

include $(shell cocotb-config --makefiles)/Makefile.sim

clean::
	@rm -rf sim_build
	@rm -rf dump.fst $(TOPLEVEL).fst