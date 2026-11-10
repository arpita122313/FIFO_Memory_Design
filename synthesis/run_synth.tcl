# =============================================================================
# Project       : Synchronous FIFO Memory Design
# File          : run_synth.tcl
# Description   : Vivado Batch TCL Script for RTL Synthesis & Timing Analysis
# Target Device : Xilinx Artix-7 (xc7a35tcpg236-1)
# Usage         : vivado -mode batch -source run_synth.tcl
# =============================================================================

set project_name "fifo_synth_proj"
set part_number  "xc7a35tcpg236-1"
set output_dir   "./reports"

file mkdir $output_dir

puts "=================================================================="
puts "  STARTING VIVADO SYNTHESIS: Synchronous FIFO Memory Design       "
puts "  Target Part: $part_number                                       "
puts "=================================================================="

# 1. Create In-Memory Project
create_project -force $project_name ./synth_work -part $part_number

# 2. Add RTL Source Files
add_files -norecurse {
    ../rtl/fifo_mem.v
    ../rtl/write_pointer.v
    ../rtl/read_pointer.v
    ../rtl/fifo_control.v
    ../rtl/fifo_status.v
    ../rtl/fifo_top.v
}

# 3. Add Timing Constraints
add_files -fileset constrs_1 -norecurse ../constraints/fifo_constraints.xdc

# 4. Set Top-Level Module
set_property top fifo_top [current_fileset]
update_compile_order -fileset sources_1

# 5. Run Out-Of-Context RTL Synthesis
puts "\n[VIVADO-SYNTH] Executing synth_design..."
synth_design -top fifo_top -part $part_number -mode out_of_context

# 6. Generate Utilization Reports
puts "\n[VIVADO-SYNTH] Generating Utilization Reports..."
report_utilization -file "$output_dir/fifo_utilization.rpt" -pb "$output_dir/fifo_utilization.pb"
report_utilization -hierarchical -file "$output_dir/fifo_utilization_hierarchical.rpt"

# 7. Generate Timing Summary Reports
puts "\n[VIVADO-SYNTH] Generating Timing Summary..."
report_timing_summary -delay_type min_max \
                      -report_unconstrained \
                      -check_timing_verbose \
                      -max_paths 10 \
                      -nworst 1 \
                      -file "$output_dir/fifo_timing_summary.rpt"

# 8. Generate Power Report
puts "\n[VIVADO-SYNTH] Generating Power Report..."
report_power -file "$output_dir/fifo_power.rpt"

# 9. Write Synthesized Design Checkpoint & Netlist
puts "\n[VIVADO-SYNTH] Writing Synthesized Checkpoint and Gate-level Verilog Netlist..."
write_checkpoint -force "$output_dir/fifo_synth.dcp"
write_verilog -force -mode funcsim "$output_dir/fifo_netlist.v"

puts "\n=================================================================="
puts "  SYNTHESIS COMPLETED SUCCESSFULLY! Reports saved to: $output_dir"
puts "=================================================================="
close_project
exit
