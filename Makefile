# Makefile
# $(shell . .venv/bin/activate)

SIM = icarus
WAVES = 1

TOPLEVEL_LANG = verilog
VERILOG_SOURCES = $(shell pwd)/hdl/*
TOPLEVEL = ibuf
MODULE = tb.test_ibuf


TOPLEVEL ?= tracking

ifeq ($(TOPLEVEL),ibuf)
    MODULE = tb.test_ibuf
endif

include $(shell cocotb-config --makefiles)/Makefile.sim