create_clock -add -name sys_clk_pin -period 4.00 -waveform {0 2} [get_ports { clk }];
set_property HD.CLK_SRC BUFGCTRL_X0Y16 [get_ports clk]