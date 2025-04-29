# SPDX-License-Identifier: MIT
# Author: regymm
set origin_dir "."

# Set the project name
set _xil_proj_name_ "TimeCard_NoVendIPs"

# Set the directory path for the original project from where this script was exported
set orig_proj_dir "[file normalize "$origin_dir/TimeCard_NoVendIPs"]"

# Create project
create_project ${_xil_proj_name_} ./${_xil_proj_name_} -part xc7a100tfgg484-1

# Set the directory path for the new project
set proj_dir [get_property directory [current_project]]

# Set project properties
set obj [current_project]
set_property -name "part" -value "xc7a100tfgg484-1" -objects $obj

# Create 'sources_1' fileset (if not found)
if {[string equal [get_filesets -quiet sources_1] ""]} {
  create_fileset -srcset sources_1
}

# Set 'sources_1' fileset object
set obj [get_filesets sources_1]
set files [list \
 [file normalize "${origin_dir}/../../IPs_TC/AdjustableClock/AdjustableClock_v.v"] \
 [file normalize "${origin_dir}/../../IPs_TC/BufgMux_IPI.v"] \
 [file normalize "${origin_dir}/../../IPs_TC/ClockDetector/ClockDetector_v.v"] \
 [file normalize "${origin_dir}/../../IPs_TC/CommunicationSelector/CommunicationSelector.v"] \
 [file normalize "${origin_dir}/../../IPs_TC/ConfMaster/ConfMaster_v.v"] \
 [file normalize "${origin_dir}/../../IPs_TC/CoreList/CoreList_v.v"] \
 [file normalize "${origin_dir}/../../IPs_TC/DummyAxiSlave/DummyAxiSlave_v.v"] \
 [file normalize "${origin_dir}/../../IPs_TC/FpgaVersion/FpgaVersion_v.v"] \
 [file normalize "${origin_dir}/../../IPs_TC/FrequencyCounter/FrequencyCounter_v.v"] \
 [file normalize "${origin_dir}/../../IPs_TC/MsiIrq/MsiIrq.v"] \
 [file normalize "${origin_dir}/../../IPs_TC/PpsGenerator/PpsGenerator_v.v"] \
 [file normalize "${origin_dir}/../../IPs_TC/PpsSlave/PpsSlave_v.v"] \
 [file normalize "${origin_dir}/../../IPs_TC/PpsSourceSelector/PpsSourceSelector.v"] \
 [file normalize "${origin_dir}/../../IPs_TC/SignalGenerator/SignalGenerator_v.v"] \
 [file normalize "${origin_dir}/../../IPs_TC/SignalTimestamper/SignalTimestamper_v.v"] \
 [file normalize "${origin_dir}/../../IPs_TC/SmaSelector/SmaSelector_v.v"] \
 [file normalize "${origin_dir}/Top/TimeCardNoBd.v"] \
 [file normalize "${origin_dir}/../../IPs_TC/TodSlave/TodSlave_v.v"] \
 [file normalize "${origin_dir}/../../IPs_3rdParty/AxiLiteXbar/addrdecode.v"] \
 [file normalize "${origin_dir}/../../IPs_3rdParty/AxiLiteXbar/afifo.v"] \
 [file normalize "${origin_dir}/../../IPs_3rdParty/Axi16550/axi_uart16550.v"] \
 [file normalize "${origin_dir}/../../IPs_3rdParty/Axi16550/axil2mm.v"] \
 [file normalize "${origin_dir}/../../IPs_3rdParty/AxiGpio/axil_gpio.v"] \
 [file normalize "${origin_dir}/../../IPs_3rdParty/Pcie_7x/axil_to_al.v"] \
 [file normalize "${origin_dir}/../../IPs_3rdParty/AxiLiteXbar/axilxbar.v"] \
 [file normalize "${origin_dir}/../../IPs_3rdParty/Pcie_7x/axis_pcie_to_al_us.v"] \
 [file normalize "${origin_dir}/../../IPs_3rdParty/AxiLiteXbar/axixclk_al2al.v"] \
 [file normalize "${origin_dir}/../../IPs_3rdParty/Xc7Mmcm/mmcm_10_to_200.v"] \
 [file normalize "${origin_dir}/../../IPs_3rdParty/Xc7Mmcm/mmcm_200_to_50_200.v"] \
 [file normalize "${origin_dir}/../../IPs_3rdParty/Xc7Mmcm/mmcm_200_to_50_200_25_50.v"] \
 [file normalize "${origin_dir}/../../IPs_3rdParty/Pcie_7x/pcie_7x.v"] \
 [file normalize "${origin_dir}/../../IPs_3rdParty/Pcie_7x/pcie_7x_aximm_msi_bd.v"] \
 [file normalize "${origin_dir}/../../IPs_3rdParty/Pcie_7x/pcie_axi_rx.v"] \
 [file normalize "${origin_dir}/../../IPs_3rdParty/Pcie_7x/pcie_axi_tx.v"] \
 [file normalize "${origin_dir}/../../IPs_3rdParty/Pcie_7x/pcie_block.v"] \
 [file normalize "${origin_dir}/../../IPs_3rdParty/Pcie_7x/pcie_brams.v"] \
 [file normalize "${origin_dir}/../../IPs_3rdParty/Pcie_7x/pcie_tx_thrtl_ctl.v"] \
 [file normalize "${origin_dir}/../../IPs_3rdParty/Pcie_7x/pipe_wrapper.v"] \
 [file normalize "${origin_dir}/../../IPs_3rdParty/PSReset/reset_counter.v"] \
 [file normalize "${origin_dir}/../../IPs_3rdParty/AxiLiteXbar/skidbuffer.v"] \
 [file normalize "${origin_dir}/../../IPs_3rdParty/Axi16550/uart16550.v"] \
 [file normalize "${origin_dir}/../../IPs_3rdParty/AxiLiteXbar/xbar_2_2.v"] \
 [file normalize "${origin_dir}/../../IPs_3rdParty/AxiLiteXbar/xbar_ptp_1_23.v"] \
 [file normalize "${origin_dir}/../../IPs_3rdParty/AxiLiteXbar/xbar_sys_1_15.v"] \
 [file normalize "${origin_dir}/../../IPs_3rdParty/Pcie_7x/xilinx_pcie_mmcm.v"] \
 [file normalize "${origin_dir}/../../IPs_TC/TimeCard_Package.svh"] \
 [file normalize "${origin_dir}/../../IPs_TC/AdjustableClock/AdjustableClock.sv"] \
 [file normalize "${origin_dir}/../../IPs_TC/ClockDetector/ClockDetector.sv"] \
 [file normalize "${origin_dir}/../../IPs_TC/ConfMaster/ConfMaster.sv"] \
 [file normalize "${origin_dir}/../../IPs_TC/CoreList/CoreList.sv"] \
 [file normalize "${origin_dir}/../../IPs_TC/DummyAxiSlave/DummyAxiSlave.sv"] \
 [file normalize "${origin_dir}/../../IPs_TC/FpgaVersion/FpgaVersion.sv"] \
 [file normalize "${origin_dir}/../../IPs_TC/FrequencyCounter/FrequencyCounter.sv"] \
 [file normalize "${origin_dir}/../../IPs_TC/PpsGenerator/PpsGenerator.sv"] \
 [file normalize "${origin_dir}/../../IPs_TC/PpsSlave/PpsSlave.sv"] \
 [file normalize "${origin_dir}/../../IPs_TC/SignalGenerator/SignalGenerator.sv"] \
 [file normalize "${origin_dir}/../../IPs_TC/SignalTimestamper/SignalTimestamper.sv"] \
 [file normalize "${origin_dir}/../../IPs_TC/SmaSelector/SmaSelector.sv"] \
 [file normalize "${origin_dir}/../../IPs_TC/TodSlave/TodSlave.sv"] \
 [file normalize "${origin_dir}/Top/TimeCardTop.v"] \
 [file normalize "${origin_dir}/../../IPs_3rdParty/AxiLiteXbar/axi2axilite.v"] \
 [file normalize "${origin_dir}/../../IPs_3rdParty/AxiLiteXbar/axi_addr.v"] \
 [file normalize "${origin_dir}/../../IPs_3rdParty/AxiLiteXbar/sfifo.v"] \
]
add_files -norecurse -fileset $obj $files

# Set 'sources_1' fileset file properties for remote files
set file "$origin_dir/../../IPs_TC/TimeCard_Package.svh"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property -name "file_type" -value "SystemVerilog" -objects $file_obj

set file "$origin_dir/../../IPs_TC/AdjustableClock/AdjustableClock.sv"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property -name "file_type" -value "SystemVerilog" -objects $file_obj

set file "$origin_dir/../../IPs_TC/ClockDetector/ClockDetector.sv"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property -name "file_type" -value "SystemVerilog" -objects $file_obj

set file "$origin_dir/../../IPs_TC/ConfMaster/ConfMaster.sv"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property -name "file_type" -value "SystemVerilog" -objects $file_obj

set file "$origin_dir/../../IPs_TC/CoreList/CoreList.sv"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property -name "file_type" -value "SystemVerilog" -objects $file_obj

set file "$origin_dir/../../IPs_TC/DummyAxiSlave/DummyAxiSlave.sv"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property -name "file_type" -value "SystemVerilog" -objects $file_obj

set file "$origin_dir/../../IPs_TC/FpgaVersion/FpgaVersion.sv"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property -name "file_type" -value "SystemVerilog" -objects $file_obj

set file "$origin_dir/../../IPs_TC/FrequencyCounter/FrequencyCounter.sv"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property -name "file_type" -value "SystemVerilog" -objects $file_obj

set file "$origin_dir/../../IPs_TC/PpsGenerator/PpsGenerator.sv"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property -name "file_type" -value "SystemVerilog" -objects $file_obj

set file "$origin_dir/../../IPs_TC/PpsSlave/PpsSlave.sv"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property -name "file_type" -value "SystemVerilog" -objects $file_obj

set file "$origin_dir/../../IPs_TC/SignalGenerator/SignalGenerator.sv"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property -name "file_type" -value "SystemVerilog" -objects $file_obj

set file "$origin_dir/../../IPs_TC/SignalTimestamper/SignalTimestamper.sv"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property -name "file_type" -value "SystemVerilog" -objects $file_obj

set file "$origin_dir/../../IPs_TC/SmaSelector/SmaSelector.sv"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property -name "file_type" -value "SystemVerilog" -objects $file_obj

set file "$origin_dir/../../IPs_TC/TodSlave/TodSlave.sv"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property -name "file_type" -value "SystemVerilog" -objects $file_obj

# Set 'sources_1' fileset properties
set obj [get_filesets sources_1]
set_property -name "top" -value "TimeCardTop" -objects $obj

# Create 'constrs_1' fileset (if not found)
if {[string equal [get_filesets -quiet constrs_1] ""]} {
  create_fileset -constrset constrs_1
}

# Set 'constrs_1' fileset object
set obj [get_filesets constrs_1]

# Add/Import constrs file and set constrs file properties
set file "[file normalize "$origin_dir/Constraints/PinoutConstraint.xdc"]"
set file_added [add_files -norecurse -fileset $obj [list $file]]
set file "$origin_dir/Constraints/PinoutConstraint.xdc"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets constrs_1] [list "*$file"]]
set_property -name "file_type" -value "XDC" -objects $file_obj

# Set 'constrs_1' fileset properties
set obj [get_filesets constrs_1]
set_property -name "target_part" -value "xc7a100tfgg484-1" -objects $obj

# Create 'sim_1' fileset (if not found)
if {[string equal [get_filesets -quiet sim_1] ""]} {
  create_fileset -simset sim_1
}

# Set 'sim_1' fileset object
set obj [get_filesets sim_1]

set VivadoVersion [lindex [split [version -short] "."] 0]
set Synthesis_Flow "Vivado Synthesis $VivadoVersion"
set Implementation_Flow "Vivado Implementation $VivadoVersion"

# Create 'synth_1' run (if not found)
if {[string equal [get_runs -quiet synth_1] ""]} {
    create_run -name synth_1 -part xc7a100tfgg484-1 -flow $Synthesis_Flow -strategy "Vivado Synthesis Defaults" -report_strategy {No Reports} -constrset constrs_1
} else {
  set_property strategy "Vivado Synthesis Defaults" [get_runs synth_1]
  set_property flow $Synthesis_Flow [get_runs synth_1]
}
set obj [get_runs synth_1]

# Create 'impl_1' run (if not found)
if {[string equal [get_runs -quiet impl_1] ""]} {
    create_run -name impl_1 -part xc7a100tfgg484-1 -flow $Implementation_Flow -strategy "Vivado Implementation Defaults" -report_strategy {No Reports} -constrset constrs_1 -parent_run synth_1
} else {
  set_property strategy "Vivado Implementation Defaults" [get_runs impl_1]
  set_property flow $Implementation_Flow [get_runs impl_1]
}

puts "INFO: Project created:${_xil_proj_name_}"

# set the current synth run
current_run -synthesis [get_runs synth_1]
# set the current impl run
current_run -implementation [get_runs impl_1]

# run synthese
reset_run synth_1
launch_runs synth_1 -jobs 12
wait_on_run synth_1

# run implementation and bitstream
reset_run impl_1
launch_runs impl_1 -to_step write_bitstream -jobs 12
wait_on_run impl_1

puts "INFO: Bitstream generated:${_xil_proj_name_}"
