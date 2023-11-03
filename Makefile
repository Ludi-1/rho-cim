# Makefile
# $(shell . .venv/bin/activate)

SIM = icarus
PWD=$(shell pwd)
TOPLEVEL_LANG = verilog
VERILOG_SOURCES = $(shell pwd)/hdl/*
WAVES=1
# WAVES_ARGS += --vcd

TOPLEVEL ?= ibuf

ifeq ($(TOPLEVEL),ibuf)
    MODULE = tb.test_ibuf
    # SIM_ARGS += -gdatatype_size=8
    # SIM_ARGS += -gfifo_length=5
endif

include $(shell cocotb-config --makefiles)/Makefile.sim