open_project /home/li/Documents/Projects/rho-CIM2/rho-CIM2.xpr
update_compile_order -fileset sources_1
set_property -name {STEPS.SYNTH_DESIGN.ARGS.MORE OPTIONS} -value {-mode out_of_context} -objects [get_runs synth_1]
reset_run synth_1
launch_runs synth_1 -jobs 16
exit