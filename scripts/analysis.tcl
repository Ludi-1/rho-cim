open_project /home/li/Documents/Projects/rho-CIM2/rho-CIM2.xpr
update_compile_order -fileset sources_1
set_property -name {STEPS.SYNTH_DESIGN.ARGS.MORE OPTIONS} -value {-mode out_of_context} -objects [get_runs synth_1]
reset_run synth_1
launch_runs synth_1 -jobs 16
wait_on_run synth_1
open_run synth_1 -name synth_1
report_utilization > /home/li/Documents/Projects/report/power.txt
report_power > /home/li/Documents/Projects/report/power.txt
exit