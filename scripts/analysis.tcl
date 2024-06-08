open_project /home/li/Documents/Projects/rho-CIM2/rho-CIM2.xpr
# set_property board_part digilentinc.com:arty-a7-35:part0:1.1 [current_project]
set_property part xc7a200tfbg484-2 [current_project]
set_param synth.elaboration.rodinMoreOptions "rt::set_parameter var_size_limit 5000000"
add_files -norecurse {/home/li/Documents/GitHub/rho-cim/hdl/flatten_fc_layer.sv /home/li/Documents/GitHub/rho-cim/hdl/conv_ibuf.sv /home/li/Documents/GitHub/rho-cim/hdl/pool_layer.sv /home/li/Documents/GitHub/rho-cim/hdl/fc_ctrl.sv /home/li/Documents/GitHub/rho-cim/hdl/flatten_fc_ibuf.sv /home/li/Documents/GitHub/rho-cim/hdl/flatten_fc_ctrl.sv /home/li/Documents/GitHub/rho-cim/hdl/conv_layer.sv /home/li/Documents/GitHub/rho-cim/hdl/fc_func.sv /home/li/Documents/GitHub/rho-cim/hdl/conv_ctrl.sv /home/li/Documents/GitHub/rho-cim/hdl/fc_layer.sv /home/li/Documents/GitHub/rho-cim/hdl/conv_func.sv /home/li/Documents/GitHub/rho-cim/hdl/fc_ibuf.sv}
add_files -norecurse /home/li/Documents/GitHub/rho-cim/perf-sim/gen_hdl/vgg16_d8_c128.sv
set_property top vgg16_d8_c128_top [current_fileset]
set_property -name {STEPS.SYNTH_DESIGN.ARGS.MORE OPTIONS} -value {-mode out_of_context} -objects [get_runs synth_1]
reset_run synth_1
launch_runs synth_1 -jobs 16
wait_on_run synth_1
open_run synth_1 -name synth_1
report_utilization > /home/li/Documents/Projects/report/power.txt
report_power > /home/li/Documents/Projects/report/power.txt
exit