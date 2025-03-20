# ================================================
# Clock Definition
# ================================================
# Define the AXI Clock. Adjust the period as needed.
# Examples:
# 1 ns   = 1 GHz
# 0.5 ns = 2 GHz
# 10 ns  = 100 MHz
# 20 ns  = 50 MHz

create_clock -name s_axi_aclk -period 10 [get_ports s_axi_aclk];

# ================================================
# Delay Definitions
# ================================================

# Max delay = 40% of the clock period
set input_delay_max  [expr 0.4 * [get_property PERIOD [get_clocks s_axi_aclk]]]
set output_delay_max [expr 0.4 * [get_property PERIOD [get_clocks s_axi_aclk]]]

# Min delay = -10% of the clock period
set input_delay_min  [expr -0.1 * [get_property PERIOD [get_clocks s_axi_aclk]]]
set output_delay_min [expr -0.1 * [get_property PERIOD [get_clocks s_axi_aclk]]]

# ================================================
# Apply Scalable Input Delays (Max and Min)
# ================================================

# Input Delays - Max
set_input_delay -clock [get_clocks s_axi_aclk] -max $input_delay_max \
    [get_ports {
        s_axi_araddr[*]  s_axi_arburst[*]  s_axi_arcache[*]
        s_axi_arlen[*]   s_axi_arlock      s_axi_arprot[*]
        s_axi_arsize[*]  s_axi_arvalid

        s_axi_awaddr[*]  s_axi_awburst[*]  s_axi_awcache[*]
        s_axi_awlen[*]   s_axi_awlock      s_axi_awprot[*]
        s_axi_awsize[*]  s_axi_awvalid

        s_axi_wdata[*]   s_axi_wstrb[*]    s_axi_wlast
        s_axi_wvalid     s_axi_bready      s_axi_rready

        s_axi_aresetn
    }]

# Input Delays - Min
set_input_delay -clock [get_clocks s_axi_aclk] -min $input_delay_min \
    [get_ports {
        s_axi_araddr[*]  s_axi_arburst[*]  s_axi_arcache[*]
        s_axi_arlen[*]   s_axi_arlock      s_axi_arprot[*]
        s_axi_arsize[*]  s_axi_arvalid

        s_axi_awaddr[*]  s_axi_awburst[*]  s_axi_awcache[*]
        s_axi_awlen[*]   s_axi_awlock      s_axi_awprot[*]
        s_axi_awsize[*]  s_axi_awvalid

        s_axi_wdata[*]   s_axi_wstrb[*]    s_axi_wlast
        s_axi_wvalid     s_axi_bready      s_axi_rready

        s_axi_aresetn
    }]

# ================================================
# Apply Scalable Output Delays (Max and Min)
# ================================================

# Output Delays - Max
set_output_delay -clock [get_clocks s_axi_aclk] -max $output_delay_max \
    [get_ports {
        s_axi_arready    s_axi_awready

        s_axi_bresp[*]   s_axi_bvalid

        s_axi_rdata[*]   s_axi_rlast
        s_axi_rresp[*]   s_axi_rvalid

        s_axi_wready
    }]

# Output Delays - Min
set_output_delay -clock [get_clocks s_axi_aclk] -min $output_delay_min \
    [get_ports {
        s_axi_arready    s_axi_awready

        s_axi_bresp[*]   s_axi_bvalid

        s_axi_rdata[*]   s_axi_rlast
        s_axi_rresp[*]   s_axi_rvalid

        s_axi_wready
    }]

# ================================================
# Asynchronous Reset Handling
# ================================================

# Exclude asynchronous reset from timing analysis
set_false_path -from [get_ports s_axi_aresetn]

# ================================================
# Additional Constraints (Example for I/O Pins)
# ================================================

# Define I/O constraints for specific pins (example)
# If the Kria K26 SOM has specific I/O constraints, adjust as necessary
# Here is an example for I/O pins definition
# Please replace `s_axi_*` with your actual signal names if they differ.

# Set I/O standards for AXI signals (Example: LVCMOS33 for 3.3V I/O)
set_property IOSTANDARD LVCMOS33 [get_ports {s_axi_araddr[*]}]
set_property IOSTANDARD LVCMOS33 [get_ports {s_axi_awaddr[*]}]
set_property IOSTANDARD LVCMOS33 [get_ports {s_axi_wdata[*]}]
set_property IOSTANDARD LVCMOS33 [get_ports {s_axi_rdata[*]}]

# Set drive strength for I/O pins (if required)
set_property DRIVE 8 [get_ports {s_axi_araddr[*]}]
set_property DRIVE 8 [get_ports {s_axi_awaddr[*]}]
set_property DRIVE 8 [get_ports {s_axi_wdata[*]}]
set_property DRIVE 8 [get_ports {s_axi_rdata[*]}]

# ================================================
# End of XDC File
# ================================================