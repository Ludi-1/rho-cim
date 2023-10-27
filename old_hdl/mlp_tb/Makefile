# Makefile

# defaults
SIM = ghdl
TOPLEVEL_LANG = vhdl
PWD=$(shell pwd)

$(shell mkdir -p vcd)
$(shell mkdir -p wave)

VHDL_SOURCES += $(PWD)/../hdl_mlp/*

GHDL_ARGS+= --std=08

# default:
# 	$(error No target specified)

TOPLEVEL ?= mlp_ibuf

ifeq ($(TOPLEVEL),mlp_ibuf)
	SIM_ARGS+= -gdatatype_size=8
	SIM_ARGS+= -gfifo_size=28
	SIM_ARGS+= --wave=wave/mlp_ibuf_tb.ghw
	SIM_ARGS+= --vcd=vcd/mlp_ibuf_tb.vcd
    MODULE = test_mlp_ibuf
else
    $(error Given TOPLEVEL '$(TOPLEVEL)' not supported)
endif

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim