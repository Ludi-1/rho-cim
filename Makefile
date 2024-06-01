# Makefile
# $(shell . .venv/bin/activate)

SIM = icarus
PWD=$(shell pwd)
TOPLEVEL_LANG = verilog
WAVES=1
# EXTRA_ARGS += --trace-fst --trace-structs
# EXTRA_ARGS += --trace --trace-structs

TOPLEVEL ?= fc_ibuf
$(shell rm -rf sim_build)

ifeq ($(TOPLEVEL),fc_ibuf)
    VERILOG_SOURCES = $(shell pwd)/hdl/fc_ibuf.sv
    MODULE = tb.test_fc_ibuf
    # SIM_ARGS += -gdatatype_size=8
    # SIM_ARGS += -gfifo_length=5
else ifeq ($(TOPLEVEL),fc_ctrl)
    VERILOG_SOURCES = $(shell pwd)/hdl/fc_ctrl.sv
    MODULE = tb.test_fc_ctrl
else ifeq ($(TOPLEVEL),fc_func)
    VERILOG_SOURCES = $(shell pwd)/hdl/fc_func.sv
    MODULE = tb.test_fc_func
else ifeq ($(TOPLEVEL),conv_ibuf)
    VERILOG_SOURCES = $(shell pwd)/hdl/conv_ibuf.sv
    MODULE = tb.test_conv_ibuf
else ifeq ($(TOPLEVEL),conv_ctrl)
    VERILOG_SOURCES = $(shell pwd)/hdl/conv_ctrl.sv
    MODULE = tb.test_conv_ctrl
else ifeq ($(TOPLEVEL),conv_func)
    VERILOG_SOURCES = $(shell pwd)/hdl/conv_func.sv
    MODULE = tb.test_conv_func
else ifeq ($(TOPLEVEL),flatten_fc_ctrl)
    VERILOG_SOURCES = $(shell pwd)/hdl/flatten_fc_ctrl.sv
    MODULE = tb.test_flatten_ctrl
else ifeq ($(TOPLEVEL),flatten_fc_ibuf)
    VERILOG_SOURCES = $(shell pwd)/hdl/flatten_fc_ibuf.sv
    MODULE = tb.test_flatten_ibuf
else ifeq ($(TOPLEVEL),flatten_fc_layer)
    VERILOG_SOURCES = $(shell pwd)/hdl/flatten_fc_layer.sv
    VERILOG_SOURCES += $(shell pwd)/hdl/flatten_fc_ctrl.sv
    VERILOG_SOURCES += $(shell pwd)/hdl/flatten_fc_ibuf.sv
    VERILOG_SOURCES += $(shell pwd)/hdl/fc_func.sv
    MODULE = tb.test_flatten
else ifeq ($(TOPLEVEL),fc_layer)
    VERILOG_SOURCES = $(shell pwd)/hdl/fc_layer.sv
    VERILOG_SOURCES += $(shell pwd)/hdl/fc_ctrl.sv
    VERILOG_SOURCES += $(shell pwd)/hdl/fc_ibuf.sv
    VERILOG_SOURCES += $(shell pwd)/hdl/fc_func.sv
    MODULE = tb.test_fc
else ifeq ($(TOPLEVEL),conv_layer)
    VERILOG_SOURCES = $(shell pwd)/hdl/conv_layer.sv
    VERILOG_SOURCES += $(shell pwd)/hdl/conv_ctrl.sv
    VERILOG_SOURCES += $(shell pwd)/hdl/conv_ibuf.sv
    VERILOG_SOURCES += $(shell pwd)/hdl/conv_func.sv
    MODULE = tb.test_conv
else
    $(error Given TOPLEVEL '$(TOPLEVEL)' not supported)
endif

include $(shell cocotb-config --makefiles)/Makefile.sim

clean::
	@rm -rf sim_build
	@rm -rf dump.fst $(TOPLEVEL).fst