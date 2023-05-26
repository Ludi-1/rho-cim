# Makefile

# defaults
SIM = ghdl
TOPLEVEL_LANG = vhdl
PWD=$(shell pwd)

$(shell mkdir -p vcd)
$(shell mkdir -p wave)

VHDL_SOURCES += $(PWD)/../hdl/*

GHDL_ARGS+= --std=08

# default:
# 	$(error No target specified)

TOPLEVEL ?= control

ifeq ($(TOPLEVEL),control)
	SIM_ARGS+= -ginput_size=1026
	SIM_ARGS+= -gneuron_size=1500
	SIM_ARGS+= -gmax_datatype_size=8
	SIM_ARGS+= -gtile_rows=512
	SIM_ARGS+= -gtile_columns=512
	SIM_ARGS+= --wave=wave/control_tb.ghw
    MODULE = test_control
else ifeq ($(TOPLEVEL),func)
	SIM_ARGS+= -ginput_size=784
	SIM_ARGS+= -gneuron_size=1500
	SIM_ARGS+= -gmax_datatype_size=8
	SIM_ARGS+= -gout_buf_datatype_size=25
	SIM_ARGS+= -gtile_rows=512
	SIM_ARGS+= -gtile_columns=512
	SIM_ARGS+= --wave=wave/func_tb.ghw
    MODULE = test_func
else ifeq ($(TOPLEVEL), ibuf)
	SIM_ARGS+= -gibuf_size=1500
	SIM_ARGS+= -gmax_datatype_size=32
	SIM_ARGS+= -gaddr_size=11
	SIM_ARGS+= --wave=wave/ibuf_tb.ghw
	MODULE = test_ibuf
else ifeq ($(TOPLEVEL), layer)
	SIM_ARGS+= -gneuron_size=1500
	SIM_ARGS+= -ginput_size=784
	SIM_ARGS+= -gmax_datatype_size=8
	SIM_ARGS+= -gout_buf_datatype_size=25
	SIM_ARGS+= -gtile_rows=512
	SIM_ARGS+= -gtile_columns=512
	SIM_ARGS+= --wave=wave/layer_tb.ghw
	MODULE = test_layer
else
    $(error Given TOPLEVEL '$(TOPLEVEL)' not supported)
endif

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim