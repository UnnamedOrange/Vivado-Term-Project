
################################################################
# This is a generated script based on design: design_1
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
set scripts_vivado_version 2018.3
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   catch {common::send_msg_id "BD_TCL-109" "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source design_1_script.tcl

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xc7a35tcpg236-1
   set_property BOARD_PART digilentinc.com:basys3:part0:1.1 [current_project]
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name design_1

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
      common::send_msg_id "BD_TCL-001" "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_msg_id "BD_TCL-002" "INFO" "Constructing design in IPI design <$cur_design>..."

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

   common::send_msg_id "BD_TCL-003" "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_msg_id "BD_TCL-004" "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_msg_id "BD_TCL-005" "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_msg_id "BD_TCL-114" "ERROR" $errMsg}
   return $nRet
}

set bCheckIPsPassed 1
##################################################################
# CHECK IPs
##################################################################
set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips "\ 
UnnamedOrange:Pmod:PmodAMP3:1.0\
digilentinc.com:IP:PmodSD:1.0\
UnnamedOrange:user:audio_synthesis:1.0\
xilinx.com:ip:blk_mem_gen:8.4\
xilinx.com:ip:clk_wiz:6.0\
pku.edu.cn:user:core:1.0\
UnnamedOrange:user:cpu_data_transmitter:1.0\
pku.edu.cn:user:fifo_controller:1.0\
xilinx.com:ip:fifo_generator:13.2\
pku.edu.cn:user:keyboard:1.0\
xilinx.com:ip:mdm:3.2\
xilinx.com:ip:microblaze:11.0\
xilinx.com:ip:proc_sys_reset:5.0\
pku.edu.cn:user:vga:1.0\
xilinx.com:ip:lmb_bram_if_cntlr:4.0\
xilinx.com:ip:lmb_v10:3.0\
"

   set list_ips_missing ""
   common::send_msg_id "BD_TCL-006" "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_msg_id "BD_TCL-115" "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

}

if { $bCheckIPsPassed != 1 } {
  common::send_msg_id "BD_TCL-1003" "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 3
}

##################################################################
# DESIGN PROCs
##################################################################


# Hierarchical cell: microblaze_0_local_memory
proc create_hier_cell_microblaze_0_local_memory { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" "create_hier_cell_microblaze_0_local_memory() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode MirroredMaster -vlnv xilinx.com:interface:lmb_rtl:1.0 DLMB
  create_bd_intf_pin -mode MirroredMaster -vlnv xilinx.com:interface:lmb_rtl:1.0 ILMB

  # Create pins
  create_bd_pin -dir I -type clk LMB_Clk
  create_bd_pin -dir I -type rst SYS_Rst

  # Create instance: dlmb_bram_if_cntlr, and set properties
  set dlmb_bram_if_cntlr [ create_bd_cell -type ip -vlnv xilinx.com:ip:lmb_bram_if_cntlr:4.0 dlmb_bram_if_cntlr ]
  set_property -dict [ list \
   CONFIG.C_ECC {0} \
 ] $dlmb_bram_if_cntlr

  # Create instance: dlmb_v10, and set properties
  set dlmb_v10 [ create_bd_cell -type ip -vlnv xilinx.com:ip:lmb_v10:3.0 dlmb_v10 ]

  # Create instance: ilmb_bram_if_cntlr, and set properties
  set ilmb_bram_if_cntlr [ create_bd_cell -type ip -vlnv xilinx.com:ip:lmb_bram_if_cntlr:4.0 ilmb_bram_if_cntlr ]
  set_property -dict [ list \
   CONFIG.C_ECC {0} \
 ] $ilmb_bram_if_cntlr

  # Create instance: ilmb_v10, and set properties
  set ilmb_v10 [ create_bd_cell -type ip -vlnv xilinx.com:ip:lmb_v10:3.0 ilmb_v10 ]

  # Create instance: lmb_bram, and set properties
  set lmb_bram [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 lmb_bram ]
  set_property -dict [ list \
   CONFIG.Memory_Type {True_Dual_Port_RAM} \
   CONFIG.use_bram_block {BRAM_Controller} \
 ] $lmb_bram

  # Create interface connections
  connect_bd_intf_net -intf_net microblaze_0_dlmb [get_bd_intf_pins DLMB] [get_bd_intf_pins dlmb_v10/LMB_M]
  connect_bd_intf_net -intf_net microblaze_0_dlmb_bus [get_bd_intf_pins dlmb_bram_if_cntlr/SLMB] [get_bd_intf_pins dlmb_v10/LMB_Sl_0]
  connect_bd_intf_net -intf_net microblaze_0_dlmb_cntlr [get_bd_intf_pins dlmb_bram_if_cntlr/BRAM_PORT] [get_bd_intf_pins lmb_bram/BRAM_PORTA]
  connect_bd_intf_net -intf_net microblaze_0_ilmb [get_bd_intf_pins ILMB] [get_bd_intf_pins ilmb_v10/LMB_M]
  connect_bd_intf_net -intf_net microblaze_0_ilmb_bus [get_bd_intf_pins ilmb_bram_if_cntlr/SLMB] [get_bd_intf_pins ilmb_v10/LMB_Sl_0]
  connect_bd_intf_net -intf_net microblaze_0_ilmb_cntlr [get_bd_intf_pins ilmb_bram_if_cntlr/BRAM_PORT] [get_bd_intf_pins lmb_bram/BRAM_PORTB]

  # Create port connections
  connect_bd_net -net SYS_Rst_1 [get_bd_pins SYS_Rst] [get_bd_pins dlmb_bram_if_cntlr/LMB_Rst] [get_bd_pins dlmb_v10/SYS_Rst] [get_bd_pins ilmb_bram_if_cntlr/LMB_Rst] [get_bd_pins ilmb_v10/SYS_Rst]
  connect_bd_net -net microblaze_0_Clk [get_bd_pins LMB_Clk] [get_bd_pins dlmb_bram_if_cntlr/LMB_Clk] [get_bd_pins dlmb_v10/LMB_Clk] [get_bd_pins ilmb_bram_if_cntlr/LMB_Clk] [get_bd_pins ilmb_v10/LMB_Clk]

  # Restore current instance
  current_bd_instance $oldCurInst
}


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
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set ja [ create_bd_intf_port -mode Master -vlnv digilentinc.com:interface:pmod_rtl:1.0 ja ]

  # Create ports
  set DEBUG_BASE_ADDR_0 [ create_bd_port -dir O -from 15 -to 0 DEBUG_BASE_ADDR_0 ]
  set EX_BCLK_0 [ create_bd_port -dir O EX_BCLK_0 ]
  set EX_LRCLK_0 [ create_bd_port -dir O EX_LRCLK_0 ]
  set EX_MCLK_0 [ create_bd_port -dir O EX_MCLK_0 ]
  set EX_SDATA_0 [ create_bd_port -dir O EX_SDATA_0 ]
  set KB_CLK_0 [ create_bd_port -dir I -type clk KB_CLK_0 ]
  set KB_DATA_0 [ create_bd_port -dir I KB_DATA_0 ]
  set hsync_0 [ create_bd_port -dir O hsync_0 ]
  set no_suppress_0 [ create_bd_port -dir I no_suppress_0 ]
  set reset [ create_bd_port -dir I -type rst reset ]
  set_property -dict [ list \
   CONFIG.POLARITY {ACTIVE_HIGH} \
 ] $reset
  set segs_L_0 [ create_bd_port -dir O -from 7 -to 0 segs_L_0 ]
  set sels_L_0 [ create_bd_port -dir O -from 3 -to 0 sels_L_0 ]
  set song_selection_0 [ create_bd_port -dir I -from 7 -to 0 song_selection_0 ]
  set sys_clock [ create_bd_port -dir I -type clk sys_clock ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {100000000} \
   CONFIG.PHASE {0.000} \
 ] $sys_clock
  set vga_b_0 [ create_bd_port -dir O -from 3 -to 0 vga_b_0 ]
  set vga_g_0 [ create_bd_port -dir O -from 3 -to 0 vga_g_0 ]
  set vga_r_0 [ create_bd_port -dir O -from 3 -to 0 vga_r_0 ]
  set vsync_0 [ create_bd_port -dir O vsync_0 ]

  # Create instance: PmodAMP3_0, and set properties
  set PmodAMP3_0 [ create_bd_cell -type ip -vlnv UnnamedOrange:Pmod:PmodAMP3:1.0 PmodAMP3_0 ]
  set_property -dict [ list \
   CONFIG.BCLK_freq {2822400} \
   CONFIG.MCLK_divided_by_BCLK {4} \
   CONFIG.log_MCLK_divided_by_BCLK {2} \
   CONFIG.resolution {32} \
   CONFIG.width {32} \
 ] $PmodAMP3_0

  # Create instance: PmodSD_0, and set properties
  set PmodSD_0 [ create_bd_cell -type ip -vlnv digilentinc.com:IP:PmodSD:1.0 PmodSD_0 ]
  set_property -dict [ list \
   CONFIG.PMOD {ja} \
   CONFIG.USE_BOARD_FLOW {true} \
 ] $PmodSD_0

  # Create instance: audio_synthesis_0, and set properties
  set audio_synthesis_0 [ create_bd_cell -type ip -vlnv UnnamedOrange:user:audio_synthesis:1.0 audio_synthesis_0 ]
  set_property -dict [ list \
   CONFIG.resolution_output {32} \
 ] $audio_synthesis_0

  # Create instance: blk_mem_gen_0, and set properties
  set blk_mem_gen_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 blk_mem_gen_0 ]
  set_property -dict [ list \
   CONFIG.Assume_Synchronous_Clk {true} \
   CONFIG.Byte_Size {9} \
   CONFIG.EN_SAFETY_CKT {false} \
   CONFIG.Enable_32bit_Address {false} \
   CONFIG.Enable_A {Always_Enabled} \
   CONFIG.Enable_B {Use_ENB_Pin} \
   CONFIG.Fill_Remaining_Memory_Locations {false} \
   CONFIG.Memory_Type {Simple_Dual_Port_RAM} \
   CONFIG.Operating_Mode_A {NO_CHANGE} \
   CONFIG.Operating_Mode_B {READ_FIRST} \
   CONFIG.Port_B_Clock {100} \
   CONFIG.Port_B_Enable_Rate {100} \
   CONFIG.Port_B_Write_Rate {0} \
   CONFIG.Read_Width_A {24} \
   CONFIG.Read_Width_B {24} \
   CONFIG.Register_PortA_Output_of_Memory_Primitives {false} \
   CONFIG.Register_PortB_Output_of_Memory_Primitives {true} \
   CONFIG.Use_Byte_Write_Enable {false} \
   CONFIG.Use_RSTA_Pin {false} \
   CONFIG.Use_RSTB_Pin {false} \
   CONFIG.Write_Width_A {24} \
   CONFIG.Write_Width_B {24} \
   CONFIG.use_bram_block {Stand_Alone} \
 ] $blk_mem_gen_0

  # Create instance: blk_mem_gen_1, and set properties
  set blk_mem_gen_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 blk_mem_gen_1 ]
  set_property -dict [ list \
   CONFIG.Assume_Synchronous_Clk {true} \
   CONFIG.Byte_Size {9} \
   CONFIG.EN_SAFETY_CKT {false} \
   CONFIG.Enable_32bit_Address {false} \
   CONFIG.Enable_A {Always_Enabled} \
   CONFIG.Enable_B {Use_ENB_Pin} \
   CONFIG.Memory_Type {Simple_Dual_Port_RAM} \
   CONFIG.Operating_Mode_A {NO_CHANGE} \
   CONFIG.Operating_Mode_B {READ_FIRST} \
   CONFIG.Port_B_Clock {100} \
   CONFIG.Port_B_Enable_Rate {100} \
   CONFIG.Port_B_Write_Rate {0} \
   CONFIG.Read_Width_A {8} \
   CONFIG.Read_Width_B {4} \
   CONFIG.Register_PortA_Output_of_Memory_Primitives {false} \
   CONFIG.Register_PortB_Output_of_Memory_Primitives {true} \
   CONFIG.Use_Byte_Write_Enable {false} \
   CONFIG.Use_RSTA_Pin {false} \
   CONFIG.Use_RSTB_Pin {false} \
   CONFIG.Write_Depth_A {4096} \
   CONFIG.Write_Width_A {8} \
   CONFIG.Write_Width_B {4} \
   CONFIG.use_bram_block {Stand_Alone} \
 ] $blk_mem_gen_1

  # Create instance: blk_mem_gen_2, and set properties
  set blk_mem_gen_2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 blk_mem_gen_2 ]
  set_property -dict [ list \
   CONFIG.Assume_Synchronous_Clk {true} \
   CONFIG.Byte_Size {9} \
   CONFIG.EN_SAFETY_CKT {false} \
   CONFIG.Enable_32bit_Address {false} \
   CONFIG.Enable_A {Always_Enabled} \
   CONFIG.Enable_B {Use_ENB_Pin} \
   CONFIG.Memory_Type {Simple_Dual_Port_RAM} \
   CONFIG.Operating_Mode_A {NO_CHANGE} \
   CONFIG.Operating_Mode_B {READ_FIRST} \
   CONFIG.Port_B_Clock {100} \
   CONFIG.Port_B_Enable_Rate {100} \
   CONFIG.Port_B_Write_Rate {0} \
   CONFIG.Register_PortA_Output_of_Memory_Primitives {false} \
   CONFIG.Register_PortB_Output_of_Memory_Primitives {true} \
   CONFIG.Use_Byte_Write_Enable {false} \
   CONFIG.Use_RSTA_Pin {false} \
   CONFIG.use_bram_block {Stand_Alone} \
 ] $blk_mem_gen_2

  # Create instance: blk_mem_gen_3, and set properties
  set blk_mem_gen_3 [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 blk_mem_gen_3 ]
  set_property -dict [ list \
   CONFIG.Assume_Synchronous_Clk {true} \
   CONFIG.Byte_Size {9} \
   CONFIG.EN_SAFETY_CKT {false} \
   CONFIG.Enable_32bit_Address {false} \
   CONFIG.Enable_A {Always_Enabled} \
   CONFIG.Enable_B {Use_ENB_Pin} \
   CONFIG.Memory_Type {Simple_Dual_Port_RAM} \
   CONFIG.Operating_Mode_A {NO_CHANGE} \
   CONFIG.Operating_Mode_B {READ_FIRST} \
   CONFIG.Port_B_Clock {100} \
   CONFIG.Port_B_Enable_Rate {100} \
   CONFIG.Port_B_Write_Rate {0} \
   CONFIG.Register_PortA_Output_of_Memory_Primitives {false} \
   CONFIG.Register_PortB_Output_of_Memory_Primitives {true} \
   CONFIG.Use_Byte_Write_Enable {false} \
   CONFIG.Use_RSTA_Pin {false} \
   CONFIG.Write_Depth_A {4096} \
   CONFIG.use_bram_block {Stand_Alone} \
 ] $blk_mem_gen_3

  # Create instance: blk_mem_gen_4, and set properties
  set blk_mem_gen_4 [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 blk_mem_gen_4 ]
  set_property -dict [ list \
   CONFIG.Assume_Synchronous_Clk {true} \
   CONFIG.Byte_Size {9} \
   CONFIG.EN_SAFETY_CKT {false} \
   CONFIG.Enable_32bit_Address {false} \
   CONFIG.Enable_A {Always_Enabled} \
   CONFIG.Enable_B {Use_ENB_Pin} \
   CONFIG.Memory_Type {Simple_Dual_Port_RAM} \
   CONFIG.Operating_Mode_A {NO_CHANGE} \
   CONFIG.Operating_Mode_B {READ_FIRST} \
   CONFIG.Port_B_Clock {100} \
   CONFIG.Port_B_Enable_Rate {100} \
   CONFIG.Port_B_Write_Rate {0} \
   CONFIG.Read_Width_A {16} \
   CONFIG.Read_Width_B {16} \
   CONFIG.Register_PortA_Output_of_Memory_Primitives {false} \
   CONFIG.Register_PortB_Output_of_Memory_Primitives {true} \
   CONFIG.Use_Byte_Write_Enable {false} \
   CONFIG.Use_RSTA_Pin {false} \
   CONFIG.Write_Depth_A {26280} \
   CONFIG.Write_Width_A {16} \
   CONFIG.Write_Width_B {16} \
   CONFIG.use_bram_block {Stand_Alone} \
 ] $blk_mem_gen_4

  # Create instance: blk_mem_gen_5, and set properties
  set blk_mem_gen_5 [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 blk_mem_gen_5 ]
  set_property -dict [ list \
   CONFIG.Assume_Synchronous_Clk {true} \
   CONFIG.Byte_Size {9} \
   CONFIG.EN_SAFETY_CKT {false} \
   CONFIG.Enable_32bit_Address {false} \
   CONFIG.Enable_A {Always_Enabled} \
   CONFIG.Enable_B {Use_ENB_Pin} \
   CONFIG.Memory_Type {Simple_Dual_Port_RAM} \
   CONFIG.Operating_Mode_A {NO_CHANGE} \
   CONFIG.Operating_Mode_B {READ_FIRST} \
   CONFIG.Port_B_Clock {100} \
   CONFIG.Port_B_Enable_Rate {100} \
   CONFIG.Port_B_Write_Rate {0} \
   CONFIG.Read_Width_A {8} \
   CONFIG.Read_Width_B {4} \
   CONFIG.Register_PortA_Output_of_Memory_Primitives {false} \
   CONFIG.Register_PortB_Output_of_Memory_Primitives {true} \
   CONFIG.Use_Byte_Write_Enable {false} \
   CONFIG.Use_RSTA_Pin {false} \
   CONFIG.Use_RSTB_Pin {false} \
   CONFIG.Write_Depth_A {4096} \
   CONFIG.Write_Width_A {8} \
   CONFIG.Write_Width_B {4} \
   CONFIG.use_bram_block {Stand_Alone} \
 ] $blk_mem_gen_5

  # Create instance: blk_mem_gen_6, and set properties
  set blk_mem_gen_6 [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 blk_mem_gen_6 ]
  set_property -dict [ list \
   CONFIG.Assume_Synchronous_Clk {true} \
   CONFIG.Byte_Size {9} \
   CONFIG.EN_SAFETY_CKT {false} \
   CONFIG.Enable_32bit_Address {false} \
   CONFIG.Enable_A {Always_Enabled} \
   CONFIG.Enable_B {Use_ENB_Pin} \
   CONFIG.Memory_Type {Simple_Dual_Port_RAM} \
   CONFIG.Operating_Mode_A {NO_CHANGE} \
   CONFIG.Operating_Mode_B {READ_FIRST} \
   CONFIG.Port_B_Clock {100} \
   CONFIG.Port_B_Enable_Rate {100} \
   CONFIG.Port_B_Write_Rate {0} \
   CONFIG.Read_Width_A {8} \
   CONFIG.Read_Width_B {4} \
   CONFIG.Register_PortA_Output_of_Memory_Primitives {false} \
   CONFIG.Register_PortB_Output_of_Memory_Primitives {true} \
   CONFIG.Use_Byte_Write_Enable {false} \
   CONFIG.Use_RSTA_Pin {false} \
   CONFIG.Use_RSTB_Pin {false} \
   CONFIG.Write_Depth_A {4096} \
   CONFIG.Write_Width_A {8} \
   CONFIG.Write_Width_B {4} \
   CONFIG.use_bram_block {Stand_Alone} \
 ] $blk_mem_gen_6

  # Create instance: clk_wiz, and set properties
  set clk_wiz [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:6.0 clk_wiz ]
  set_property -dict [ list \
   CONFIG.CLKOUT1_JITTER {126.133} \
   CONFIG.CLKOUT1_PHASE_ERROR {94.994} \
   CONFIG.CLKOUT2_JITTER {197.987} \
   CONFIG.CLKOUT2_PHASE_ERROR {94.994} \
   CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {11.2896} \
   CONFIG.CLKOUT2_USED {true} \
   CONFIG.CLK_IN1_BOARD_INTERFACE {sys_clock} \
   CONFIG.MMCM_CLKFBOUT_MULT_F {10.500} \
   CONFIG.MMCM_CLKOUT0_DIVIDE_F {10.500} \
   CONFIG.MMCM_CLKOUT1_DIVIDE {93} \
   CONFIG.MMCM_DIVCLK_DIVIDE {1} \
   CONFIG.NUM_OUT_CLKS {2} \
   CONFIG.RESET_BOARD_INTERFACE {reset} \
   CONFIG.USE_BOARD_FLOW {true} \
 ] $clk_wiz

  # Create instance: core_0, and set properties
  set core_0 [ create_bd_cell -type ip -vlnv pku.edu.cn:user:core:1.0 core_0 ]
  set_property -dict [ list \
   CONFIG.play_delay {110250} \
 ] $core_0

  # Create instance: cpu_data_transmitter_0, and set properties
  set cpu_data_transmitter_0 [ create_bd_cell -type ip -vlnv UnnamedOrange:user:cpu_data_transmitter:1.0 cpu_data_transmitter_0 ]

  # Create instance: cpu_data_transmitter_1, and set properties
  set cpu_data_transmitter_1 [ create_bd_cell -type ip -vlnv UnnamedOrange:user:cpu_data_transmitter:1.0 cpu_data_transmitter_1 ]

  # Create instance: fifo_controller_0, and set properties
  set fifo_controller_0 [ create_bd_cell -type ip -vlnv pku.edu.cn:user:fifo_controller:1.0 fifo_controller_0 ]

  # Create instance: fifo_controller_1, and set properties
  set fifo_controller_1 [ create_bd_cell -type ip -vlnv pku.edu.cn:user:fifo_controller:1.0 fifo_controller_1 ]

  # Create instance: fifo_generator_0, and set properties
  set fifo_generator_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:fifo_generator:13.2 fifo_generator_0 ]
  set_property -dict [ list \
   CONFIG.Data_Count_Width {10} \
   CONFIG.Fifo_Implementation {Common_Clock_Distributed_RAM} \
   CONFIG.Full_Threshold_Assert_Value {1022} \
   CONFIG.Full_Threshold_Negate_Value {1021} \
   CONFIG.Input_Data_Width {8} \
   CONFIG.Input_Depth {1024} \
   CONFIG.Output_Data_Width {8} \
   CONFIG.Output_Depth {1024} \
   CONFIG.Read_Data_Count_Width {10} \
   CONFIG.Reset_Type {Synchronous_Reset} \
   CONFIG.Use_Dout_Reset {true} \
   CONFIG.Valid_Flag {true} \
   CONFIG.Write_Data_Count_Width {10} \
 ] $fifo_generator_0

  # Create instance: fifo_generator_1, and set properties
  set fifo_generator_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:fifo_generator:13.2 fifo_generator_1 ]
  set_property -dict [ list \
   CONFIG.Data_Count_Width {10} \
   CONFIG.Fifo_Implementation {Common_Clock_Distributed_RAM} \
   CONFIG.Full_Threshold_Assert_Value {1022} \
   CONFIG.Full_Threshold_Negate_Value {1021} \
   CONFIG.Input_Data_Width {8} \
   CONFIG.Input_Depth {1024} \
   CONFIG.Output_Data_Width {8} \
   CONFIG.Output_Depth {1024} \
   CONFIG.Read_Data_Count_Width {10} \
   CONFIG.Reset_Type {Synchronous_Reset} \
   CONFIG.Use_Dout_Reset {true} \
   CONFIG.Valid_Flag {true} \
   CONFIG.Write_Data_Count_Width {10} \
 ] $fifo_generator_1

  # Create instance: keyboard_0, and set properties
  set keyboard_0 [ create_bd_cell -type ip -vlnv pku.edu.cn:user:keyboard:1.0 keyboard_0 ]

  # Create instance: mdm_1, and set properties
  set mdm_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:mdm:3.2 mdm_1 ]

  # Create instance: microblaze_0, and set properties
  set microblaze_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:microblaze:11.0 microblaze_0 ]
  set_property -dict [ list \
   CONFIG.C_DEBUG_ENABLED {1} \
   CONFIG.C_D_AXI {1} \
   CONFIG.C_D_LMB {1} \
   CONFIG.C_I_LMB {1} \
 ] $microblaze_0

  # Create instance: microblaze_0_axi_periph, and set properties
  set microblaze_0_axi_periph [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 microblaze_0_axi_periph ]
  set_property -dict [ list \
   CONFIG.NUM_MI {4} \
 ] $microblaze_0_axi_periph

  # Create instance: microblaze_0_local_memory
  create_hier_cell_microblaze_0_local_memory [current_bd_instance .] microblaze_0_local_memory

  # Create instance: rst_clk_wiz_100M, and set properties
  set rst_clk_wiz_100M [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_clk_wiz_100M ]

  # Create instance: vga_0, and set properties
  set vga_0 [ create_bd_cell -type ip -vlnv pku.edu.cn:user:vga:1.0 vga_0 ]

  # Create interface connections
  connect_bd_intf_net -intf_net PmodSD_0_Pmod_out [get_bd_intf_ports ja] [get_bd_intf_pins PmodSD_0/Pmod_out]
  connect_bd_intf_net -intf_net core_0_DB_BRAM_PORT_A [get_bd_intf_pins blk_mem_gen_0/BRAM_PORTA] [get_bd_intf_pins core_0/DB_BRAM_PORT_A]
  connect_bd_intf_net -intf_net core_0_DB_BRAM_PORT_B [get_bd_intf_pins blk_mem_gen_0/BRAM_PORTB] [get_bd_intf_pins core_0/DB_BRAM_PORT_B]
  connect_bd_intf_net -intf_net core_0_DO_0_BRAM_PORT_A [get_bd_intf_pins blk_mem_gen_1/BRAM_PORTA] [get_bd_intf_pins core_0/DO_0_BRAM_PORT_A]
  connect_bd_intf_net -intf_net core_0_DO_0_BRAM_PORT_B [get_bd_intf_pins blk_mem_gen_1/BRAM_PORTB] [get_bd_intf_pins core_0/DO_0_BRAM_PORT_B]
  connect_bd_intf_net -intf_net core_0_DO_1_BRAM_PORT_A [get_bd_intf_pins blk_mem_gen_5/BRAM_PORTA] [get_bd_intf_pins core_0/DO_1_BRAM_PORT_A]
  connect_bd_intf_net -intf_net core_0_DO_1_BRAM_PORT_B [get_bd_intf_pins blk_mem_gen_5/BRAM_PORTB] [get_bd_intf_pins core_0/DO_1_BRAM_PORT_B]
  connect_bd_intf_net -intf_net core_0_DO_2_BRAM_PORT_A [get_bd_intf_pins blk_mem_gen_6/BRAM_PORTA] [get_bd_intf_pins core_0/DO_2_BRAM_PORT_A]
  connect_bd_intf_net -intf_net core_0_DO_2_BRAM_PORT_B [get_bd_intf_pins blk_mem_gen_6/BRAM_PORTB] [get_bd_intf_pins core_0/DO_2_BRAM_PORT_B]
  connect_bd_intf_net -intf_net core_0_DP_BRAM_PORT_A [get_bd_intf_pins blk_mem_gen_2/BRAM_PORTA] [get_bd_intf_pins core_0/DP_BRAM_PORT_A]
  connect_bd_intf_net -intf_net core_0_DP_BRAM_PORT_B [get_bd_intf_pins blk_mem_gen_2/BRAM_PORTB] [get_bd_intf_pins core_0/DP_BRAM_PORT_B]
  connect_bd_intf_net -intf_net core_0_DS_BRAM_PORT_A [get_bd_intf_pins blk_mem_gen_4/BRAM_PORTA] [get_bd_intf_pins core_0/DS_BRAM_PORT_A]
  connect_bd_intf_net -intf_net core_0_DS_BRAM_PORT_B [get_bd_intf_pins blk_mem_gen_4/BRAM_PORTB] [get_bd_intf_pins core_0/DS_BRAM_PORT_B]
  connect_bd_intf_net -intf_net core_0_DT_BRAM_PORT_A [get_bd_intf_pins blk_mem_gen_3/BRAM_PORTA] [get_bd_intf_pins core_0/DT_BRAM_PORT_A]
  connect_bd_intf_net -intf_net core_0_DT_BRAM_PORT_B [get_bd_intf_pins blk_mem_gen_3/BRAM_PORTB] [get_bd_intf_pins core_0/DT_BRAM_PORT_B]
  connect_bd_intf_net -intf_net microblaze_0_M_AXI_DP [get_bd_intf_pins microblaze_0/M_AXI_DP] [get_bd_intf_pins microblaze_0_axi_periph/S00_AXI]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M00_AXI [get_bd_intf_pins cpu_data_transmitter_0/S00_AXI] [get_bd_intf_pins microblaze_0_axi_periph/M00_AXI]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M01_AXI [get_bd_intf_pins PmodSD_0/AXI_LITE_SPI] [get_bd_intf_pins microblaze_0_axi_periph/M01_AXI]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M02_AXI [get_bd_intf_pins PmodSD_0/AXI_LITE_SDCS] [get_bd_intf_pins microblaze_0_axi_periph/M02_AXI]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M03_AXI [get_bd_intf_pins cpu_data_transmitter_1/S00_AXI] [get_bd_intf_pins microblaze_0_axi_periph/M03_AXI]
  connect_bd_intf_net -intf_net microblaze_0_debug [get_bd_intf_pins mdm_1/MBDEBUG_0] [get_bd_intf_pins microblaze_0/DEBUG]
  connect_bd_intf_net -intf_net microblaze_0_dlmb_1 [get_bd_intf_pins microblaze_0/DLMB] [get_bd_intf_pins microblaze_0_local_memory/DLMB]
  connect_bd_intf_net -intf_net microblaze_0_ilmb_1 [get_bd_intf_pins microblaze_0/ILMB] [get_bd_intf_pins microblaze_0_local_memory/ILMB]

  # Create port connections
  connect_bd_net -net KB_CLK_0_1 [get_bd_ports KB_CLK_0] [get_bd_pins keyboard_0/kbclk]
  connect_bd_net -net KB_DATA_0_1 [get_bd_ports KB_DATA_0] [get_bd_pins keyboard_0/kbdata]
  connect_bd_net -net PmodAMP3_0_EX_BCLK [get_bd_ports EX_BCLK_0] [get_bd_pins PmodAMP3_0/EX_BCLK]
  connect_bd_net -net PmodAMP3_0_EX_LRCLK [get_bd_ports EX_LRCLK_0] [get_bd_pins PmodAMP3_0/EX_LRCLK]
  connect_bd_net -net PmodAMP3_0_EX_MCLK [get_bd_ports EX_MCLK_0] [get_bd_pins PmodAMP3_0/EX_MCLK]
  connect_bd_net -net PmodAMP3_0_EX_SDATA [get_bd_ports EX_SDATA_0] [get_bd_pins PmodAMP3_0/EX_SDATA]
  connect_bd_net -net audio_synthesis_0_AUDIO_OUT [get_bd_pins PmodAMP3_0/SAMPLE] [get_bd_pins audio_synthesis_0/AUDIO_OUT]
  connect_bd_net -net clk_wiz_clk_out2 [get_bd_pins PmodAMP3_0/CLK] [get_bd_pins clk_wiz/clk_out2]
  connect_bd_net -net clk_wiz_locked [get_bd_pins clk_wiz/locked] [get_bd_pins rst_clk_wiz_100M/dcm_locked]
  connect_bd_net -net core_0_AUDIO_EN [get_bd_pins PmodAMP3_0/EN] [get_bd_pins audio_synthesis_0/EN] [get_bd_pins core_0/AUDIO_EN]
  connect_bd_net -net core_0_AUX_AUDIO_EN [get_bd_pins audio_synthesis_0/AUX_AUDIO_EN] [get_bd_pins core_0/AUX_AUDIO_EN]
  connect_bd_net -net core_0_AUX_AUDIO_OUT [get_bd_pins audio_synthesis_0/AUX_AUDIO_IN] [get_bd_pins core_0/AUX_AUDIO_OUT]
  connect_bd_net -net core_0_AUX_AUDIO_VOLUMN [get_bd_pins audio_synthesis_0/AUX_AUDIO_VOLUMN] [get_bd_pins core_0/AUX_AUDIO_VOLUMN]
  connect_bd_net -net core_0_MAIN_AUDIO_EN [get_bd_pins audio_synthesis_0/MAIN_AUDIO_EN] [get_bd_pins core_0/MAIN_AUDIO_EN]
  connect_bd_net -net core_0_MAIN_AUDIO_OUT [get_bd_pins audio_synthesis_0/MAIN_AUDIO_IN] [get_bd_pins core_0/MAIN_AUDIO_OUT]
  connect_bd_net -net core_0_MAIN_AUDIO_VOLUMN [get_bd_pins audio_synthesis_0/MAIN_AUDIO_VOLUMN] [get_bd_pins core_0/MAIN_AUDIO_VOLUMN]
  connect_bd_net -net core_0_pre_init_aux_info [get_bd_pins core_0/pre_init_aux_info] [get_bd_pins cpu_data_transmitter_0/INIT_AUX_INFO]
  connect_bd_net -net core_0_pre_init_index [get_bd_pins core_0/pre_init_index] [get_bd_pins cpu_data_transmitter_0/INIT_INDEX]
  connect_bd_net -net core_0_pre_request_data [get_bd_pins core_0/pre_request_data] [get_bd_pins fifo_controller_0/REQUEST_DATA]
  connect_bd_net -net core_0_pre_restart [get_bd_pins core_0/pre_restart] [get_bd_pins fifo_controller_0/RESTART]
  connect_bd_net -net core_0_song_init_aux_info [get_bd_pins core_0/song_init_aux_info] [get_bd_pins cpu_data_transmitter_1/INIT_AUX_INFO]
  connect_bd_net -net core_0_song_init_index [get_bd_pins core_0/song_init_index] [get_bd_pins cpu_data_transmitter_1/INIT_INDEX]
  connect_bd_net -net core_0_song_request_data [get_bd_pins core_0/song_request_data] [get_bd_pins fifo_controller_1/REQUEST_DATA]
  connect_bd_net -net core_0_song_restart [get_bd_pins core_0/song_restart] [get_bd_pins fifo_controller_1/RESTART]
  connect_bd_net -net core_0_vga_b [get_bd_pins core_0/vga_b] [get_bd_pins vga_0/get_b]
  connect_bd_net -net core_0_vga_g [get_bd_pins core_0/vga_g] [get_bd_pins vga_0/get_g]
  connect_bd_net -net core_0_vga_r [get_bd_pins core_0/vga_r] [get_bd_pins vga_0/get_r]
  connect_bd_net -net core_0_vga_reset [get_bd_pins core_0/vga_reset] [get_bd_pins vga_0/rst]
  connect_bd_net -net cpu_data_transmitter_0_DATA_OUT [get_bd_pins cpu_data_transmitter_0/DATA_OUT] [get_bd_pins fifo_controller_0/C_DATA_OUT]
  connect_bd_net -net cpu_data_transmitter_0_DATA_READY [get_bd_pins cpu_data_transmitter_0/DATA_READY] [get_bd_pins fifo_controller_0/C_DATA_READY]
  connect_bd_net -net cpu_data_transmitter_0_TRANSMIT_FINISHED [get_bd_pins cpu_data_transmitter_0/TRANSMIT_FINISHED] [get_bd_pins fifo_controller_0/C_TRANSMIT_FINISHED]
  connect_bd_net -net cpu_data_transmitter_1_DATA_OUT [get_bd_pins cpu_data_transmitter_1/DATA_OUT] [get_bd_pins fifo_controller_1/C_DATA_OUT]
  connect_bd_net -net cpu_data_transmitter_1_DATA_READY [get_bd_pins cpu_data_transmitter_1/DATA_READY] [get_bd_pins fifo_controller_1/C_DATA_READY]
  connect_bd_net -net cpu_data_transmitter_1_TRANSMIT_FINISHED [get_bd_pins cpu_data_transmitter_1/TRANSMIT_FINISHED] [get_bd_pins fifo_controller_1/C_TRANSMIT_FINISHED]
  connect_bd_net -net fifo_controller_0_C_REQUEST_DATA [get_bd_pins cpu_data_transmitter_0/REQUEST_DATA] [get_bd_pins fifo_controller_0/C_REQUEST_DATA]
  connect_bd_net -net fifo_controller_0_C_RESTART [get_bd_pins cpu_data_transmitter_0/RESTART] [get_bd_pins fifo_controller_0/C_RESTART]
  connect_bd_net -net fifo_controller_0_DATA_OUT [get_bd_pins core_0/pre_data_in] [get_bd_pins fifo_controller_0/DATA_OUT]
  connect_bd_net -net fifo_controller_0_DATA_READY [get_bd_pins core_0/pre_data_ready] [get_bd_pins fifo_controller_0/DATA_READY]
  connect_bd_net -net fifo_controller_0_Q_IN [get_bd_pins fifo_controller_0/Q_IN] [get_bd_pins fifo_generator_0/din]
  connect_bd_net -net fifo_controller_0_Q_REN [get_bd_pins fifo_controller_0/Q_REN] [get_bd_pins fifo_generator_0/rd_en]
  connect_bd_net -net fifo_controller_0_Q_RST [get_bd_pins fifo_controller_0/Q_RST] [get_bd_pins fifo_generator_0/srst]
  connect_bd_net -net fifo_controller_0_Q_WEN [get_bd_pins fifo_controller_0/Q_WEN] [get_bd_pins fifo_generator_0/wr_en]
  connect_bd_net -net fifo_controller_0_TRANSMIT_FINISHED [get_bd_pins core_0/pre_transmit_finished] [get_bd_pins fifo_controller_0/TRANSMIT_FINISHED]
  connect_bd_net -net fifo_controller_1_C_REQUEST_DATA [get_bd_pins cpu_data_transmitter_1/REQUEST_DATA] [get_bd_pins fifo_controller_1/C_REQUEST_DATA]
  connect_bd_net -net fifo_controller_1_C_RESTART [get_bd_pins cpu_data_transmitter_1/RESTART] [get_bd_pins fifo_controller_1/C_RESTART]
  connect_bd_net -net fifo_controller_1_DATA_OUT [get_bd_pins core_0/song_data_in] [get_bd_pins fifo_controller_1/DATA_OUT]
  connect_bd_net -net fifo_controller_1_DATA_READY [get_bd_pins core_0/song_data_ready] [get_bd_pins fifo_controller_1/DATA_READY]
  connect_bd_net -net fifo_controller_1_Q_IN [get_bd_pins fifo_controller_1/Q_IN] [get_bd_pins fifo_generator_1/din]
  connect_bd_net -net fifo_controller_1_Q_REN [get_bd_pins fifo_controller_1/Q_REN] [get_bd_pins fifo_generator_1/rd_en]
  connect_bd_net -net fifo_controller_1_Q_RST [get_bd_pins fifo_controller_1/Q_RST] [get_bd_pins fifo_generator_1/srst]
  connect_bd_net -net fifo_controller_1_Q_WEN [get_bd_pins fifo_controller_1/Q_WEN] [get_bd_pins fifo_generator_1/wr_en]
  connect_bd_net -net fifo_controller_1_TRANSMIT_FINISHED [get_bd_pins core_0/song_transmit_finished] [get_bd_pins fifo_controller_1/TRANSMIT_FINISHED]
  connect_bd_net -net fifo_generator_0_dout [get_bd_pins fifo_controller_0/Q_OUT] [get_bd_pins fifo_generator_0/dout]
  connect_bd_net -net fifo_generator_0_empty [get_bd_pins fifo_controller_0/Q_EMPTY] [get_bd_pins fifo_generator_0/empty]
  connect_bd_net -net fifo_generator_0_full [get_bd_pins fifo_controller_0/Q_FULL] [get_bd_pins fifo_generator_0/full]
  connect_bd_net -net fifo_generator_0_valid [get_bd_pins fifo_controller_0/Q_VALID] [get_bd_pins fifo_generator_0/valid]
  connect_bd_net -net fifo_generator_1_dout [get_bd_pins fifo_controller_1/Q_OUT] [get_bd_pins fifo_generator_1/dout]
  connect_bd_net -net fifo_generator_1_empty [get_bd_pins fifo_controller_1/Q_EMPTY] [get_bd_pins fifo_generator_1/empty]
  connect_bd_net -net fifo_generator_1_full [get_bd_pins fifo_controller_1/Q_FULL] [get_bd_pins fifo_generator_1/full]
  connect_bd_net -net fifo_generator_1_valid [get_bd_pins fifo_controller_1/Q_VALID] [get_bd_pins fifo_generator_1/valid]
  connect_bd_net -net keyboard_0_CHANGE [get_bd_pins core_0/IS_KEY_CHANGED] [get_bd_pins keyboard_0/CHANGE]
  connect_bd_net -net keyboard_0_DOWN [get_bd_pins core_0/IS_KEY_DOWN] [get_bd_pins keyboard_0/DOWN]
  connect_bd_net -net mdm_1_debug_sys_rst [get_bd_pins mdm_1/Debug_SYS_Rst] [get_bd_pins rst_clk_wiz_100M/mb_debug_sys_rst]
  connect_bd_net -net microblaze_0_Clk [get_bd_pins PmodSD_0/s_axi_aclk] [get_bd_pins clk_wiz/clk_out1] [get_bd_pins core_0/CLK] [get_bd_pins cpu_data_transmitter_0/s00_axi_aclk] [get_bd_pins cpu_data_transmitter_1/s00_axi_aclk] [get_bd_pins fifo_generator_0/clk] [get_bd_pins fifo_generator_1/clk] [get_bd_pins keyboard_0/CLK] [get_bd_pins microblaze_0/Clk] [get_bd_pins microblaze_0_axi_periph/ACLK] [get_bd_pins microblaze_0_axi_periph/M00_ACLK] [get_bd_pins microblaze_0_axi_periph/M01_ACLK] [get_bd_pins microblaze_0_axi_periph/M02_ACLK] [get_bd_pins microblaze_0_axi_periph/M03_ACLK] [get_bd_pins microblaze_0_axi_periph/S00_ACLK] [get_bd_pins microblaze_0_local_memory/LMB_Clk] [get_bd_pins rst_clk_wiz_100M/slowest_sync_clk] [get_bd_pins vga_0/clk]
  connect_bd_net -net no_suppress_0_1 [get_bd_ports no_suppress_0] [get_bd_pins core_0/no_suppress]
  connect_bd_net -net reset_1 [get_bd_ports reset] [get_bd_pins clk_wiz/reset] [get_bd_pins rst_clk_wiz_100M/ext_reset_in]
  connect_bd_net -net rst_clk_wiz_100M_bus_struct_reset [get_bd_pins microblaze_0_local_memory/SYS_Rst] [get_bd_pins rst_clk_wiz_100M/bus_struct_reset]
  connect_bd_net -net rst_clk_wiz_100M_mb_reset [get_bd_pins microblaze_0/Reset] [get_bd_pins rst_clk_wiz_100M/mb_reset]
  connect_bd_net -net rst_clk_wiz_100M_peripheral_aresetn [get_bd_pins PmodAMP3_0/RESET_L] [get_bd_pins PmodSD_0/s_axi_aresetn] [get_bd_pins core_0/RESET_L] [get_bd_pins cpu_data_transmitter_0/s00_axi_aresetn] [get_bd_pins cpu_data_transmitter_1/s00_axi_aresetn] [get_bd_pins fifo_controller_0/RESET_L] [get_bd_pins fifo_controller_1/RESET_L] [get_bd_pins keyboard_0/RESET_L] [get_bd_pins microblaze_0_axi_periph/ARESETN] [get_bd_pins microblaze_0_axi_periph/M00_ARESETN] [get_bd_pins microblaze_0_axi_periph/M01_ARESETN] [get_bd_pins microblaze_0_axi_periph/M02_ARESETN] [get_bd_pins microblaze_0_axi_periph/M03_ARESETN] [get_bd_pins microblaze_0_axi_periph/S00_ARESETN] [get_bd_pins rst_clk_wiz_100M/peripheral_aresetn]
  connect_bd_net -net song_selection_0_1 [get_bd_ports song_selection_0] [get_bd_pins core_0/song_selection]
  connect_bd_net -net sys_clock_1 [get_bd_ports sys_clock] [get_bd_pins clk_wiz/clk_in1]
  connect_bd_net -net vga_0_hcnt_request [get_bd_pins core_0/vga_y] [get_bd_pins vga_0/hcnt_request]
  connect_bd_net -net vga_0_hsync [get_bd_ports hsync_0] [get_bd_pins vga_0/hsync]
  connect_bd_net -net vga_0_request [get_bd_pins core_0/vga_request] [get_bd_pins vga_0/request]
  connect_bd_net -net vga_0_vcnt_request [get_bd_pins core_0/vga_x] [get_bd_pins vga_0/vcnt_request]
  connect_bd_net -net vga_0_vga_b [get_bd_ports vga_b_0] [get_bd_pins vga_0/vga_b]
  connect_bd_net -net vga_0_vga_g [get_bd_ports vga_g_0] [get_bd_pins vga_0/vga_g]
  connect_bd_net -net vga_0_vga_r [get_bd_ports vga_r_0] [get_bd_pins vga_0/vga_r]
  connect_bd_net -net vga_0_vsync [get_bd_ports vsync_0] [get_bd_pins vga_0/vsync]

  # Create address segments
  create_bd_addr_seg -range 0x00010000 -offset 0x44A00000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs PmodSD_0/AXI_LITE_SPI/Reg0] SEG_PmodSD_0_Reg0
  create_bd_addr_seg -range 0x00010000 -offset 0x44A10000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs PmodSD_0/AXI_LITE_SDCS/Reg0] SEG_PmodSD_0_Reg01
  create_bd_addr_seg -range 0x00010000 -offset 0x44A20000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs cpu_data_transmitter_0/S00_AXI/S00_AXI_reg] SEG_cpu_data_transmitter_0_S00_AXI_reg
  create_bd_addr_seg -range 0x00010000 -offset 0x44A30000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs cpu_data_transmitter_1/S00_AXI/S00_AXI_reg] SEG_cpu_data_transmitter_1_S00_AXI_reg
  create_bd_addr_seg -range 0x00010000 -offset 0x00000000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs microblaze_0_local_memory/dlmb_bram_if_cntlr/SLMB/Mem] SEG_dlmb_bram_if_cntlr_Mem
  create_bd_addr_seg -range 0x00010000 -offset 0x00000000 [get_bd_addr_spaces microblaze_0/Instruction] [get_bd_addr_segs microblaze_0_local_memory/ilmb_bram_if_cntlr/SLMB/Mem] SEG_ilmb_bram_if_cntlr_Mem


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


