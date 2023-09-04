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
	SIM_ARGS+= -gimage_size=28
	SIM_ARGS+= --wave=wave/cnn_ibuf_tb.ghw
	SIM_ARGS+= --vcd=vcd/cnn_ibuf_tb.vcd
    MODULE = test_cnn_ibuf
else ifeq ($(TOPLEVEL),cnn_func)
	SIM_ARGS+= -ginput_channels=5
	SIM_ARGS+= -goutput_channels=15
	SIM_ARGS+= -gdatatype_size=8
	SIM_ARGS+= -gcrossbar_size=512
	SIM_ARGS+= -gobuf_datatype_size=25
	SIM_ARGS+= -gfunc_datatype_size=1
	SIM_ARGS+= --wave=wave/cnn_func_tb.ghw
	SIM_ARGS+= --vcd=vcd/cnn_func_tb.vcd
    MODULE = test_cnn_func
else ifeq ($(TOPLEVEL),cnn_layer)
	SIM_ARGS+= -gkernel_size=3
	SIM_ARGS+= -gimage_size=28
	SIM_ARGS+= -ginput_channels=5
	SIM_ARGS+= -goutput_channels=10
	SIM_ARGS+= -gdatatype_size=8
	SIM_ARGS+= -gcrossbar_size=512
	SIM_ARGS+= -gobuf_datatype_size=25
	SIM_ARGS+= -gfunc_datatype_size=1
	SIM_ARGS+= --wave=wave/cnn_layer_tb.ghw
	SIM_ARGS+= --vcd=vcd/cnn_layer_tb.vcd
    MODULE = test_cnn_layer
else ifeq ($(TOPLEVEL),pooling_layer)
	SIM_ARGS+= -gchannels=5
	SIM_ARGS+= -gkernel_size=3
	SIM_ARGS+= -gimage_size=28
	SIM_ARGS+= -gdatatype_size=8
	SIM_ARGS+= --wave=wave/pooling_layer_tb.ghw
	SIM_ARGS+= --vcd=vcd/pooling_layer_tb.vcd
    MODULE = test_pooling_layer
else ifeq ($(TOPLEVEL),p2fc_layer)
	SIM_ARGS+= -gimage_size=28
	SIM_ARGS+= -ginput_channels=5
	SIM_ARGS+= -gneurons=10
	SIM_ARGS+= -gdatatype_size=8
	SIM_ARGS+= -gcrossbar_size=512
	SIM_ARGS+= -gobuf_datatype_size=25
	SIM_ARGS+= --wave=wave/p2fc_layer_tb.ghw
	SIM_ARGS+= --vcd=vcd/p2fc_layer_tb.vcd
    MODULE = test_p2fc_layer
else ifeq ($(TOPLEVEL),fc_layer)
	SIM_ARGS+= -ginputs=720
	SIM_ARGS+= -gneurons=1000
	SIM_ARGS+= -gdatatype_size=8
	SIM_ARGS+= -gcrossbar_size=512
	SIM_ARGS+= -gobuf_datatype_size=25
	SIM_ARGS+= -gfunc_datatype_size=1
	SIM_ARGS+= --wave=wave/fc_layer_tb.ghw
	SIM_ARGS+= --vcd=vcd/fc_layer_tb.vcd
    MODULE = test_fc_layer
else
    $(error Given TOPLEVEL '$(TOPLEVEL)' not supported)
endif

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim