# =============================================================================
# Project       : Synchronous FIFO Memory Design
# File          : run_sim.tcl
# Description   : Vivado Batch TCL Script for RTL Simulation via XSIM
# Usage         : vivado -mode batch -source run_sim.tcl
# =============================================================================

set project_name "fifo_sim_proj"
set part_number  "xc7a35tcpg236-1"

puts "=================================================================="
puts "  STARTING VIVADO XSIM SIMULATION: Synchronous FIFO Memory Design "
puts "=================================================================="

# 1. Create In-Memory Project
create_project -force $project_name ./sim_work -part $part_number

# 2. Add RTL Source Files
add_files -norecurse {
    ../rtl/fifo_mem.v
    ../rtl/write_pointer.v
    ../rtl/read_pointer.v
    ../rtl/fifo_control.v
    ../rtl/fifo_status.v
    ../rtl/fifo_top.v
}

# 3. Add Testbench
add_files -fileset sim_1 -norecurse {
    ../testbench/fifo_tb.v
}

# 4. Set Simulation Top Module
set_property top fifo_tb [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]

# 5. Configure Simulation Options
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

# 6. Launch Simulation
puts "\n[VIVADO-SIM] Elaborating and launching XSIM..."
launch_simulation -simset [get_filesets sim_1] -mode behavioral

# 7. Run Simulation until completion
puts "\n[VIVADO-SIM] Running simulation..."
run all

# 8. Close Simulation and Project
puts "\n[VIVADO-SIM] Simulation complete. Closing project."
close_sim
close_project
exit
