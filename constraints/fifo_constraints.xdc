# =============================================================================
# Project       : Synchronous FIFO Memory Design
# File          : fifo_constraints.xdc
# Description   : Timing Constraints for Vivado RTL Synthesis & Implementation
# Target Device : Xilinx Artix-7 (xc7a35tcpg236-1) / Basys 3 Development Board
# =============================================================================

# -----------------------------------------------------------------------------
# Primary Clock Definition (100 MHz System Clock, 10.0 ns Period)
# -----------------------------------------------------------------------------
create_clock -period 10.000 -name clk -waveform {0.000 5.000} [get_ports clk]

# -----------------------------------------------------------------------------
# Input Delay Constraints (Referenced to System Clock)
# Max delay: 2.0 ns, Min delay: 0.5 ns
# -----------------------------------------------------------------------------
set_input_delay -clock [get_clocks clk] -max 2.000 [get_ports rst]
set_input_delay -clock [get_clocks clk] -min 0.500 [get_ports rst]

set_input_delay -clock [get_clocks clk] -max 2.000 [get_ports wr_en]
set_input_delay -clock [get_clocks clk] -min 0.500 [get_ports wr_en]

set_input_delay -clock [get_clocks clk] -max 2.000 [get_ports rd_en]
set_input_delay -clock [get_clocks clk] -min 0.500 [get_ports rd_en]

set_input_delay -clock [get_clocks clk] -max 2.000 [get_ports {din[*]}]
set_input_delay -clock [get_clocks clk] -min 0.500 [get_ports {din[*]}]

# -----------------------------------------------------------------------------
# Output Delay Constraints (Referenced to System Clock)
# Max delay: 2.0 ns, Min delay: 0.5 ns
# -----------------------------------------------------------------------------
set_output_delay -clock [get_clocks clk] -max 2.000 [get_ports full]
set_output_delay -clock [get_clocks clk] -min 0.500 [get_ports full]

set_output_delay -clock [get_clocks clk] -max 2.000 [get_ports empty]
set_output_delay -clock [get_clocks clk] -min 0.500 [get_ports empty]

set_output_delay -clock [get_clocks clk] -max 2.000 [get_ports {dout[*]}]
set_output_delay -clock [get_clocks clk] -min 0.500 [get_ports {dout[*]}]
