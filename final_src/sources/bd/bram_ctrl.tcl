
################################################################
# This is a generated script based on design: bram_ctrl
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2024.2
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   if { [string compare $scripts_vivado_version $current_vivado_version] > 0 } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2042 -severity "ERROR" " This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Sourcing the script failed since it was created with a future version of Vivado."}

   } else {
     catch {common::send_gid_msg -ssname BD::TCL -id 2041 -severity "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   }

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source bram_ctrl_script.tcl

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xczu7ev-ffvc1156-2-e
   set_property BOARD_PART xilinx.com:zcu106:part0:2.6 [current_project]
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name bram_ctrl

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_gid_msg -ssname BD::TCL -id 2001 -severity "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_gid_msg -ssname BD::TCL -id 2002 -severity "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_gid_msg -ssname BD::TCL -id 2003 -severity "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_gid_msg -ssname BD::TCL -id 2004 -severity "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_gid_msg -ssname BD::TCL -id 2005 -severity "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_gid_msg -ssname BD::TCL -id 2006 -severity "ERROR" $errMsg}
   return $nRet
}

set bCheckIPsPassed 1
##################################################################
# CHECK IPs
##################################################################
set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips "\ 
xilinx.com:ip:axi_bram_ctrl:4.1\
xilinx.com:ip:blk_mem_gen:8.4\
"

   set list_ips_missing ""
   common::send_gid_msg -ssname BD::TCL -id 2011 -severity "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2012 -severity "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

}

if { $bCheckIPsPassed != 1 } {
  common::send_gid_msg -ssname BD::TCL -id 2023 -severity "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 3
}

##################################################################
# DESIGN PROCs
##################################################################



# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder
  variable design_name

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports

  # Create ports
  set addrb_0 [ create_bd_port -dir I -from 7 -to 0 addrb_0 ]
  set clkb_0 [ create_bd_port -dir I -type clk clkb_0 ]
  set dinb_0 [ create_bd_port -dir I -from 127 -to 0 dinb_0 ]
  set doutb_0 [ create_bd_port -dir O -from 127 -to 0 doutb_0 ]
  set enb_0 [ create_bd_port -dir I enb_0 ]
  set web_0 [ create_bd_port -dir I -from 15 -to 0 web_0 ]
  set s_axi_aclk_0 [ create_bd_port -dir I -type clk s_axi_aclk_0 ]
  set s_axi_araddr_0 [ create_bd_port -dir I -from 16 -to 0 s_axi_araddr_0 ]
  set s_axi_arburst_0 [ create_bd_port -dir I -from 1 -to 0 s_axi_arburst_0 ]
  set s_axi_arcache_0 [ create_bd_port -dir I -from 3 -to 0 s_axi_arcache_0 ]
  set s_axi_aresetn_0 [ create_bd_port -dir I -type rst s_axi_aresetn_0 ]
  set s_axi_arlen_0 [ create_bd_port -dir I -from 7 -to 0 s_axi_arlen_0 ]
  set s_axi_arlock_0 [ create_bd_port -dir I s_axi_arlock_0 ]
  set s_axi_arprot_0 [ create_bd_port -dir I -from 2 -to 0 s_axi_arprot_0 ]
  set s_axi_arready_0 [ create_bd_port -dir O s_axi_arready_0 ]
  set s_axi_arsize_0 [ create_bd_port -dir I -from 2 -to 0 s_axi_arsize_0 ]
  set s_axi_arvalid_0 [ create_bd_port -dir I s_axi_arvalid_0 ]
  set s_axi_awaddr_0 [ create_bd_port -dir I -from 16 -to 0 s_axi_awaddr_0 ]
  set s_axi_awburst_0 [ create_bd_port -dir I -from 1 -to 0 s_axi_awburst_0 ]
  set s_axi_awcache_0 [ create_bd_port -dir I -from 3 -to 0 s_axi_awcache_0 ]
  set s_axi_awlen_0 [ create_bd_port -dir I -from 7 -to 0 s_axi_awlen_0 ]
  set s_axi_awlock_0 [ create_bd_port -dir I s_axi_awlock_0 ]
  set s_axi_awprot_0 [ create_bd_port -dir I -from 2 -to 0 s_axi_awprot_0 ]
  set s_axi_awready_0 [ create_bd_port -dir O s_axi_awready_0 ]
  set s_axi_awsize_0 [ create_bd_port -dir I -from 2 -to 0 s_axi_awsize_0 ]
  set s_axi_awvalid_0 [ create_bd_port -dir I s_axi_awvalid_0 ]
  set s_axi_bready_0 [ create_bd_port -dir I s_axi_bready_0 ]
  set s_axi_bresp_0 [ create_bd_port -dir O -from 1 -to 0 s_axi_bresp_0 ]
  set s_axi_bvalid_0 [ create_bd_port -dir O s_axi_bvalid_0 ]
  set s_axi_rdata_0 [ create_bd_port -dir O -from 127 -to 0 s_axi_rdata_0 ]
  set s_axi_rlast_0 [ create_bd_port -dir O s_axi_rlast_0 ]
  set s_axi_rready_0 [ create_bd_port -dir I s_axi_rready_0 ]
  set s_axi_rresp_0 [ create_bd_port -dir O -from 1 -to 0 s_axi_rresp_0 ]
  set s_axi_rvalid_0 [ create_bd_port -dir O s_axi_rvalid_0 ]
  set s_axi_wdata_0 [ create_bd_port -dir I -from 127 -to 0 s_axi_wdata_0 ]
  set s_axi_wlast_0 [ create_bd_port -dir I s_axi_wlast_0 ]
  set s_axi_wready_0 [ create_bd_port -dir O s_axi_wready_0 ]
  set s_axi_wstrb_0 [ create_bd_port -dir I -from 15 -to 0 s_axi_wstrb_0 ]
  set s_axi_wvalid_0 [ create_bd_port -dir I s_axi_wvalid_0 ]

  # Create instance: axi_bram_ctrl_0, and set properties
  set axi_bram_ctrl_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.1 axi_bram_ctrl_0 ]
  set_property -dict [list \
    CONFIG.DATA_WIDTH {128} \
    CONFIG.SINGLE_PORT_BRAM {1} \
  ] $axi_bram_ctrl_0


  # Create instance: blk_mem_gen_0, and set properties
  set blk_mem_gen_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 blk_mem_gen_0 ]
  set_property -dict [list \
    CONFIG.Byte_Size {8} \
    CONFIG.Enable_32bit_Address {false} \
    CONFIG.Memory_Type {True_Dual_Port_RAM} \
    CONFIG.Register_PortA_Output_of_Memory_Primitives {false} \
    CONFIG.Register_PortB_Output_of_Memory_Primitives {false} \
    CONFIG.Use_Byte_Write_Enable {true} \
    CONFIG.Write_Depth_A {256} \
    CONFIG.Write_Width_A {128} \
    CONFIG.use_bram_block {Stand_Alone} \
  ] $blk_mem_gen_0


  # Create interface connections
  connect_bd_intf_net -intf_net axi_bram_ctrl_0_BRAM_PORTA [get_bd_intf_pins blk_mem_gen_0/BRAM_PORTA] [get_bd_intf_pins axi_bram_ctrl_0/BRAM_PORTA]

  # Create port connections
  connect_bd_net -net addrb_0_1  [get_bd_ports addrb_0] \
  [get_bd_pins blk_mem_gen_0/addrb]
  connect_bd_net -net axi_bram_ctrl_0_s_axi_arready  [get_bd_pins axi_bram_ctrl_0/s_axi_arready] \
  [get_bd_ports s_axi_arready_0]
  connect_bd_net -net axi_bram_ctrl_0_s_axi_awready  [get_bd_pins axi_bram_ctrl_0/s_axi_awready] \
  [get_bd_ports s_axi_awready_0]
  connect_bd_net -net axi_bram_ctrl_0_s_axi_bresp  [get_bd_pins axi_bram_ctrl_0/s_axi_bresp] \
  [get_bd_ports s_axi_bresp_0]
  connect_bd_net -net axi_bram_ctrl_0_s_axi_bvalid  [get_bd_pins axi_bram_ctrl_0/s_axi_bvalid] \
  [get_bd_ports s_axi_bvalid_0]
  connect_bd_net -net axi_bram_ctrl_0_s_axi_rdata  [get_bd_pins axi_bram_ctrl_0/s_axi_rdata] \
  [get_bd_ports s_axi_rdata_0]
  connect_bd_net -net axi_bram_ctrl_0_s_axi_rlast  [get_bd_pins axi_bram_ctrl_0/s_axi_rlast] \
  [get_bd_ports s_axi_rlast_0]
  connect_bd_net -net axi_bram_ctrl_0_s_axi_rresp  [get_bd_pins axi_bram_ctrl_0/s_axi_rresp] \
  [get_bd_ports s_axi_rresp_0]
  connect_bd_net -net axi_bram_ctrl_0_s_axi_rvalid  [get_bd_pins axi_bram_ctrl_0/s_axi_rvalid] \
  [get_bd_ports s_axi_rvalid_0]
  connect_bd_net -net axi_bram_ctrl_0_s_axi_wready  [get_bd_pins axi_bram_ctrl_0/s_axi_wready] \
  [get_bd_ports s_axi_wready_0]
  connect_bd_net -net blk_mem_gen_0_doutb  [get_bd_pins blk_mem_gen_0/doutb] \
  [get_bd_ports doutb_0]
  connect_bd_net -net clkb_0_1  [get_bd_ports clkb_0] \
  [get_bd_pins blk_mem_gen_0/clkb]
  connect_bd_net -net dinb_0_1  [get_bd_ports dinb_0] \
  [get_bd_pins blk_mem_gen_0/dinb]
  connect_bd_net -net enb_0_1  [get_bd_ports enb_0] \
  [get_bd_pins blk_mem_gen_0/enb]
  connect_bd_net -net s_axi_aclk_0_1  [get_bd_ports s_axi_aclk_0] \
  [get_bd_pins axi_bram_ctrl_0/s_axi_aclk]
  connect_bd_net -net s_axi_araddr_0_1  [get_bd_ports s_axi_araddr_0] \
  [get_bd_pins axi_bram_ctrl_0/s_axi_araddr]
  connect_bd_net -net s_axi_arburst_0_1  [get_bd_ports s_axi_arburst_0] \
  [get_bd_pins axi_bram_ctrl_0/s_axi_arburst]
  connect_bd_net -net s_axi_arcache_0_1  [get_bd_ports s_axi_arcache_0] \
  [get_bd_pins axi_bram_ctrl_0/s_axi_arcache]
  connect_bd_net -net s_axi_aresetn_0_1  [get_bd_ports s_axi_aresetn_0] \
  [get_bd_pins axi_bram_ctrl_0/s_axi_aresetn]
  connect_bd_net -net s_axi_arlen_0_1  [get_bd_ports s_axi_arlen_0] \
  [get_bd_pins axi_bram_ctrl_0/s_axi_arlen]
  connect_bd_net -net s_axi_arlock_0_1  [get_bd_ports s_axi_arlock_0] \
  [get_bd_pins axi_bram_ctrl_0/s_axi_arlock]
  connect_bd_net -net s_axi_arprot_0_1  [get_bd_ports s_axi_arprot_0] \
  [get_bd_pins axi_bram_ctrl_0/s_axi_arprot]
  connect_bd_net -net s_axi_arsize_0_1  [get_bd_ports s_axi_arsize_0] \
  [get_bd_pins axi_bram_ctrl_0/s_axi_arsize]
  connect_bd_net -net s_axi_arvalid_0_1  [get_bd_ports s_axi_arvalid_0] \
  [get_bd_pins axi_bram_ctrl_0/s_axi_arvalid]
  connect_bd_net -net s_axi_awaddr_0_1  [get_bd_ports s_axi_awaddr_0] \
  [get_bd_pins axi_bram_ctrl_0/s_axi_awaddr]
  connect_bd_net -net s_axi_awburst_0_1  [get_bd_ports s_axi_awburst_0] \
  [get_bd_pins axi_bram_ctrl_0/s_axi_awburst]
  connect_bd_net -net s_axi_awcache_0_1  [get_bd_ports s_axi_awcache_0] \
  [get_bd_pins axi_bram_ctrl_0/s_axi_awcache]
  connect_bd_net -net s_axi_awlen_0_1  [get_bd_ports s_axi_awlen_0] \
  [get_bd_pins axi_bram_ctrl_0/s_axi_awlen]
  connect_bd_net -net s_axi_awlock_0_1  [get_bd_ports s_axi_awlock_0] \
  [get_bd_pins axi_bram_ctrl_0/s_axi_awlock]
  connect_bd_net -net s_axi_awprot_0_1  [get_bd_ports s_axi_awprot_0] \
  [get_bd_pins axi_bram_ctrl_0/s_axi_awprot]
  connect_bd_net -net s_axi_awsize_0_1  [get_bd_ports s_axi_awsize_0] \
  [get_bd_pins axi_bram_ctrl_0/s_axi_awsize]
  connect_bd_net -net s_axi_awvalid_0_1  [get_bd_ports s_axi_awvalid_0] \
  [get_bd_pins axi_bram_ctrl_0/s_axi_awvalid]
  connect_bd_net -net s_axi_bready_0_1  [get_bd_ports s_axi_bready_0] \
  [get_bd_pins axi_bram_ctrl_0/s_axi_bready]
  connect_bd_net -net s_axi_rready_0_1  [get_bd_ports s_axi_rready_0] \
  [get_bd_pins axi_bram_ctrl_0/s_axi_rready]
  connect_bd_net -net s_axi_wdata_0_1  [get_bd_ports s_axi_wdata_0] \
  [get_bd_pins axi_bram_ctrl_0/s_axi_wdata]
  connect_bd_net -net s_axi_wlast_0_1  [get_bd_ports s_axi_wlast_0] \
  [get_bd_pins axi_bram_ctrl_0/s_axi_wlast]
  connect_bd_net -net s_axi_wstrb_0_1  [get_bd_ports s_axi_wstrb_0] \
  [get_bd_pins axi_bram_ctrl_0/s_axi_wstrb]
  connect_bd_net -net s_axi_wvalid_0_1  [get_bd_ports s_axi_wvalid_0] \
  [get_bd_pins axi_bram_ctrl_0/s_axi_wvalid]
  connect_bd_net -net web_0_1  [get_bd_ports web_0] \
  [get_bd_pins blk_mem_gen_0/web]

  # Create address segments


  # Restore current instance
  current_bd_instance $oldCurInst

  validate_bd_design
  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


