# vhdl files
FILES = hdl/*
VHDLEX = .vhdl

# testbench
TESTBENCHPATH = tb/${TESTBENCHFILE}$(VHDLEX)
TESTBENCHFILE = ${TESTBENCH}_tb

#GHDL CONFIG
GHDL_CMD = ghdl
GHDL_FLAGS  = --std=08 --workdir=simulation

SIMDIR = simulation
#STOP_TIME = 500ns

# Simulation break condition
#GHDL_SIM_OPT = --assert-level=error
#GHDL_SIM_OPT = --stop-time=$(STOP_TIME)

#@$(GHDL_CMD) -r $(GHDL_FLAGS) $(TESTBENCHFILE) --vcdgz=$(SIMDIR)/$(TESTBENCHFILE).vcdgz
#@gunzip --stdout $(SIMDIR)/$(TESTBENCHFILE).vcdgz | $(WAVEFORM_VIEWER) --vcd

WAVEFORM_VIEWER = gtkwave

.PHONY: clean

all: clean make run view

compile:
	@$(GHDL_CMD) -i $(GHDL_FLAGS) --workdir=simulation --work=work $(TESTBENCHPATH) $(FILES)
	@$(GHDL_CMD) -m  $(GHDL_FLAGS) --workdir=simulation --work=work $(TESTBENCHFILE)

make:
ifeq ($(strip $(TESTBENCH)),)
	@echo "TESTBENCH not set. Use TESTBENCH=<value> to set it."
	@exit 1
endif

	@mkdir -p simulation
	make compile TESTBENCH=${TESTBENCH}

run:
	@$(GHDL_CMD) -r $(GHDL_FLAGS) $(TESTBENCHFILE) --wave=$(SIMDIR)/$(TESTBENCHFILE).ghw

view:
	@$(WAVEFORM_VIEWER) $(SIMDIR)/$(TESTBENCHFILE).ghw

clean:
	@rm -rf $(SIMDIR)