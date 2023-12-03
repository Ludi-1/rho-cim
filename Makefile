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
else ifeq ($(TOPLEVEL),ctrl)
	MODULE = tb.test_ctrl
endif

ifeq ($(WAVES), 1)
	VERILOG_SOURCES += iverilog_dump.v
	COMPILE_ARGS += -s iverilog_dump
endif

include $(shell cocotb-config --makefiles)/Makefile.sim

iverilog_dump.v:
	echo 'module iverilog_dump();' > $@
	echo 'initial begin' >> $@
	echo '    $$dumpfile("$(TOPLEVEL).fst");' >> $@
	echo '    $$dumpvars(0, $(TOPLEVEL));' >> $@
	echo 'end' >> $@
	echo 'endmodule' >> $@

clean::
	@rm -rf iverilog_dump.v
	@rm -rf dump.fst $(TOPLEVEL).fst