# Makefile

# defaults
SIM = ghdl
TOPLEVEL_LANG = vhdl
PWD=$(shell pwd)

$(shell mkdir -p vcd)
$(shell mkdir -p wave)

VHDL_SOURCES += $(PWD)/../hdl_cnn/*

GHDL_ARGS+= --std=08

# default:
# 	$(error No target specified)

TOPLEVEL ?= cnn_ibuf

ifeq ($(TOPLEVEL),cnn_ibuf)
	SIM_ARGS+= -gkernel_size=3
	SIM_ARGS+= -gdatatype_size=8
	SIM_ARGS+= -gkernels=3
	SIM_ARGS+= -gimage_size=28
	SIM_ARGS+= --wave=wave/cnn_ibuf_tb.ghw
    MODULE = test_cnn_ibuf
# else ifeq ($(TOPLEVEL),func)
# 	SIM_ARGS+= -ginput_size=784
# 	SIM_ARGS+= -gneuron_size=1500
# 	SIM_ARGS+= -gmax_datatype_size=8
# 	SIM_ARGS+= -gout_buf_datatype_size=25
# 	SIM_ARGS+= -gtile_rows=512
# 	SIM_ARGS+= -gtile_columns=512
# 	SIM_ARGS+= --wave=wave/func_tb.ghw
#     MODULE = test_func
else
    $(error Given TOPLEVEL '$(TOPLEVEL)' not supported)
endif

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim