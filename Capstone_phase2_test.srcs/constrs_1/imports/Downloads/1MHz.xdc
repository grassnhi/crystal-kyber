# ================================================
# Clock Definition
# ================================================
# Define the AXI Clock. Adjust the period as needed.
# Examples:
# 1 ns   = 1 GHz
# 0.5 ns = 2 GHz
# 10 ns  = 100 MHz
# 20 ns  = 50 MHz

create_clock -name clk -period 10 [get_ports clk];

# ================================================
# Delay Definitions
# ================================================

# Max delay = 40% of the clock period
set input_delay_max  [expr 0.4 * [get_property PERIOD [get_clocks clk]]]
set output_delay_max [expr 0.4 * [get_property PERIOD [get_clocks clk]]]

# Min delay = -10% of the clock period
set input_delay_min  [expr -0.1 * [get_property PERIOD [get_clocks clk]]]
set output_delay_min [expr -0.1 * [get_property PERIOD [get_clocks clk]]]

# ================================================
# Apply Scalable Input Delays (Max and Min)
# ================================================

# Input Delays - Max
set_input_delay -clock [get_clocks clk] -max $input_delay_max \
    [get_ports {
        rst         start

        mode[*]     random_coin[*]
        m_in[*]     c_in[*]
        pk_in[*]    sk_in[*]
    }]

# Input Delays - Min
set_input_delay -clock [get_clocks clk] -min $input_delay_min \
    [get_ports {
        rst         start

        mode[*]     random_coin[*]
        m_in[*]     c_in[*]
        pk_in[*]    sk_in[*]
    }]

# ================================================
# Apply Scalable Output Delays (Max and Min)
# ================================================

# Output Delays - Max
set_output_delay -clock [get_clocks clk] -max $output_delay_max \
    [get_ports {
        m_out[*]    c_out[*]
        pk_out[*]   sk_out[*]

        finish
    }]

# Output Delays - Min
set_output_delay -clock [get_clocks clk] -min $output_delay_min \
    [get_ports {
        m_out[*]    c_out[*]
        pk_out[*]   sk_out[*]

        finish
    }]

# ================================================
# Asynchronous Reset Handling
# ================================================

# Exclude asynchronous reset from timing analysis
set_false_path -from [get_ports rst]

# ================================================
# Additional Constraints (Example for I/O Pins)
# ================================================

# Define I/O constraints for specific pins (example)
# If the Kria K26 SOM has specific I/O constraints, adjust as necessary
# Here is an example for I/O pins definition
# Please replace `s_axi_*` with your actual signal names if they differ.

# Set I/O standards for AXI signals (Example: LVCMOS33 for 3.3V I/O)
# set_property IOSTANDARD LVCMOS33 [get_ports {s_axi_araddr[*]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {s_axi_awaddr[*]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {s_axi_wdata[*]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {s_axi_rdata[*]}]

# Set drive strength for I/O pins (if required)
# set_property DRIVE 8 [get_ports {s_axi_araddr[*]}]
# set_property DRIVE 8 [get_ports {s_axi_awaddr[*]}]
# set_property DRIVE 8 [get_ports {s_axi_wdata[*]}]
# set_property DRIVE 8 [get_ports {s_axi_rdata[*]}]

# ================================================
# End of XDC File
# ================================================