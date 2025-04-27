// SPDX-License-Identifier: GPL-3.0
// Author: regymm
`timescale 1 ps / 1 ps

/*pythonblk
# Abstract wires in between, not ports on modules
# WIP: python generated port definition and wiring
ptp_axil_portname = { # IO direction is S
'ARADDR': ('AxiReadAddrAddress_AdrIn', 32, 'in'),
'ARPROT': ('AxiReadAddrProt_DatIn', 3, 'in'),
'ARREADY': ('AxiReadAddrReady_RdyOut', 1, 'out'),
'ARVALID': ('AxiReadAddrValid_ValIn', 1, 'in'),
'RDATA': ('AxiReadDataData_DatOut', 32, 'out'),
'RREADY': ('AxiReadDataReady_RdyIn', 1, 'in'),
'RRESP': ('AxiReadDataResponse_DatOut', 2, 'out'),
'RVALID': ('AxiReadDataValid_ValOut', 1, 'out'),
'AWADDR': ('AxiWriteAddrAddress_AdrIn', 32, 'in'),
'AWPROT': ('AxiWriteAddrProt_DatIn', 3, 'in'),
'AWREADY': ('AxiWriteAddrReady_RdyOut', 1, 'out'),
'AWVALID': ('AxiWriteAddrValid_ValIn', 1, 'in'),
'WDATA': ('AxiWriteDataData_DatIn', 32, 'in'),
'WREADY': ('AxiWriteDataReady_RdyOut', 1, 'out'),
'WSTRB': ('AxiWriteDataStrobe_DatIn', 4, 'in'),
'WVALID': ('AxiWriteDataValid_ValIn', 1, 'in'),
'BRESP': ('AxiWriteRespResponse_DatOut', 2, 'out'),
'BREADY': ('AxiWriteRespReady_RdyIn', 1, 'in'),
'BVALID': ('AxiWriteRespValid_ValOut', 1, 'out')
}
xil_axil_portname = {
'ARADDR': ('s_axi_araddr', 32, 'in'),
'ARREADY': ('s_axi_arready', 1, 'out'),
'ARVALID': ('s_axi_arvalid', 1, 'in'),
'RDATA': ('s_axi_rdata', 32, 'out'),
'RREADY': ('s_axi_rready', 1, 'in'),
'RRESP': ('s_axi_rresp', 2, 'out'),
'RVALID': ('s_axi_rvalid', 1, 'out'),
'AWADDR': ('s_axi_awaddr', 32, 'in'),
'AWREADY': ('s_axi_awready', 1, 'out'),
'AWVALID': ('s_axi_awvalid', 1, 'in'),
'WDATA': ('s_axi_wdata', 32, 'in'),
'WREADY': ('s_axi_wready', 1, 'out'),
'WSTRB': ('s_axi_wstrb', 4, 'in'),
'WVALID': ('s_axi_wvalid', 1, 'in'),
'BRESP': ('s_axi_bresp', 2, 'out'),
'BREADY': ('s_axi_bready', 1, 'in'),
'BVALID': ('s_axi_bvalid', 1, 'out')
}

# this addr is a number, default is just length specified in ARADDR, etc
# wire_definition=True: generate wire definitions
# portname=True: generate dict of tuples just like xil_axil_portname, used in PORT_AXIL
def WIRE_AXIL(prefix, wire_definition=False, portname=False, addr=None):
     pass
# this addr is passed as [15:0], as we allow non-zero-starting address
def PORT_AXIL(module_name, signal_name, addr='', unused_in='0'):
     pass
*/

module TimeCard_NoBd (
     // global reset, resets everything except PCIe
     input wire ResetN_RstIn,

     // It's all about clocks. 
     // High precision 10 MHz clock in, drives the most important PTP peripherals at 50/200 MHz, used for holdover when GPS signal is lost
     input wire Mhz10ClkDcxo1_ClkIn,
     input wire Mhz10ClkDcxo2_ClkIn,
     input wire Mhz10ClkMac_ClkIn,
     input wire Mhz10ClkSma_ClkIn,
     // 200 MHz clock in from diff. xtal on board, drives system peripherals at 50 MHz
     input wire Mhz200Clk_ClkIn_clk_n,
     input wire Mhz200Clk_ClkIn_clk_p,
     // A comprehensivie clock detector selects the clock, and when clock source changes, reset is issued
     // PTP 50 MHz
     output wire Mhz50Clk_ClkOut,
     output wire [0:0]Reset50MhzN_RstOut,
     // system 50 MHz
     output wire Mhz50Clk_ClkOut_0,
     output wire [0:0]Reset50MhzN_RstOut_0,
     // 62.5 MHz from PCIe Gen1 x1, unused
     output wire Mhz62_5Clk_ClkOut,
     output wire [0:0]Reset62_5MhzN_RstOut,

     // Each GNSS has 3 pins, UART Rx/Tx, and PPS in, simple but powerful
     //  on TimeCard, only Gnss1 is used
     input wire UartGnss1Rx_DatIn,
     output wire UartGnss1Tx_DatOut,
     input wire PpsGnss1_EvtIn,
     input wire UartGnss2Rx_DatIn,
     output wire UartGnss2Tx_DatOut,
     input wire PpsGnss2_EvtIn,
     output wire Pps_EvtOut,

     // GPIOs, used for reset GNSS/MAC
     input wire [1:0]Ext_DatIn,
     output wire [6:0]Ext_DatOut,
     output wire [1:0]GpioGnss_DatOut,
     input wire [1:0]GpioMac_DatIn,

     // PCIe, this is the main interface with PC, but not compulsary. The card can run standalone
     input wire PciePerstN_RstIn,
     input wire [0:0]PcieRefClockN,
     input wire [0:0]PcieRefClockP,
     input wire [0:0]pcie_7x_mgt_0_rxn,
     input wire [0:0]pcie_7x_mgt_0_rxp,
     output wire [0:0]pcie_7x_mgt_0_txn,
     output wire [0:0]pcie_7x_mgt_0_txp,

     // 4 SMA on TimeCard, with very customizable I/O sources
     input wire SmaIn1_DatIn,
     output wire SmaIn1_EnOut,
     input wire SmaIn2_DatIn,
     output wire SmaIn2_EnOut,
     input wire SmaIn3_DatIn,
     output wire SmaIn3_EnOut,
     input wire SmaIn4_DatIn,
     output wire SmaIn4_EnOut,
     output wire SmaOut1_DatOut,
     output wire SmaOut1_EnOut,
     output wire SmaOut2_DatOut,
     output wire SmaOut2_EnOut,
     output wire SmaOut3_DatOut,
     output wire SmaOut3_EnOut,
     output wire SmaOut4_DatOut,
     output wire SmaOut4_EnOut,

     // Indicator of PTP core in sync / in holdover, useful for monitoring
     output wire InHoldover_DatOut,
     output wire InSync_DatOut,

     // Golden Image or not, for FPGAVersion, unused
     input wire GoldenImageN_EnaIn,

     // System I2C, unused. There's a 5pin header for DAC and control MAC frequency by I2C
     inout wire I2c_scl_io,
     inout wire I2c_sda_io,
     // SPI Flash and startup configuration IO pins, unused
     inout wire SpiFlash_io0_io,
     inout wire SpiFlash_io1_io,
     inout wire SpiFlash_io2_io,
     inout wire SpiFlash_io3_io,
     output wire SpiFlash_ss_o,
     output wire StartUpIo_cfgclk,
     output wire StartUpIo_cfgmclk,
     output wire StartUpIo_preq,

     // UART/I2C communication selector for miniature atomic clock (MAC)
     //  most people don't have the luxury of a MAC, unused
     output wire Clk_RxSdaT_EnaOut,
     input wire Clk_RxSda_DatIn,
     output wire Clk_RxSda_DatOut,
     output wire Clk_TxSclT_EnaOut,
     input wire Clk_TxScl_DatIn,
     output wire Clk_TxScl_DatOut,
     // MAC PPS I/O, unused
     output wire MacPps0_EvtOut,
     output wire MacPps1_EvtOut,
     input wire MacPps_EvtIn
);

     wire PTP_M_AXI_ACLK;
     wire SYS_M_AXI_ACLK;
     wire PCIE_M_AXI_ACLK;
     wire SYS_M_AXI_ARESETN;
     wire PTP_M_AXI_ARESETN;
     wire PCIE_M_AXI_ARESETN;

     assign Mhz50Clk_ClkOut = PTP_M_AXI_ACLK;
     assign Mhz50Clk_ClkOut_0 = SYS_M_AXI_ACLK;
     assign Mhz62_5Clk_ClkOut = PCIE_M_AXI_ACLK;
     assign Reset50MhzN_RstOut[0] = PTP_M_AXI_ARESETN;
     assign Reset50MhzN_RstOut_0[0] = SYS_M_AXI_ARESETN;
     assign Reset62_5MhzN_RstOut[0] = PCIE_M_AXI_ARESETN;
     assign Ext_DatOut[6:0] = ext_gpio2o[6:0];
     assign GpioGnss_DatOut[1:0] = gnssmac_gpio2o;

     // Core of the clock management: select the available 10 MHz stable clock, and PPS
     // when selection changes, reset is issued
     // 3 selections by ClockDetector, choose 1 in 4
     wire ClockDetector_v_0_ClkMux1Select_EnOut;
     wire ClockDetector_v_0_ClkMux2Select_EnOut;
     wire ClockDetector_v_0_ClkMux3Select_EnOut;
     wire BufgMux_IPI_0_ClkOut_ClkOut;
     wire BufgMux_IPI_1_ClkOut_ClkOut;
     wire BufgMux_IPI_2_ClkOut_ClkOut;
     BufgMux_IPI BufgMux_IPI_SMAMAC
          (.ClkIn0_ClkIn(Mhz10ClkSma_ClkIn_BufgCe),
          .ClkIn1_ClkIn(Mhz10ClkMac_ClkIn),
          .ClkOut_ClkOut(BufgMux_IPI_0_ClkOut_ClkOut),
          .SelecteClk1_EnIn(ClockDetector_v_0_ClkMux1Select_EnOut));
     BufgMux_IPI BufgMux_IPI_DCXO1DCXO2
          (.ClkIn0_ClkIn(Mhz10ClkDcxo1_ClkIn),
          .ClkIn1_ClkIn(Mhz10ClkDcxo2_ClkIn),
          .ClkOut_ClkOut(BufgMux_IPI_1_ClkOut_ClkOut),
          .SelecteClk1_EnIn(ClockDetector_v_0_ClkMux2Select_EnOut));
     BufgMux_IPI BufgMux_IPI_SMAMAC_DCXO2DCXO2
          (.ClkIn0_ClkIn(BufgMux_IPI_0_ClkOut_ClkOut),
          .ClkIn1_ClkIn(BufgMux_IPI_1_ClkOut_ClkOut),
          .ClkOut_ClkOut(BufgMux_IPI_2_ClkOut_ClkOut),
          .SelecteClk1_EnIn(ClockDetector_v_0_ClkMux3Select_EnOut));
     wire clk_200from10;
     wire clk_sys_locked;
     wire clk_200fromsys;
     wire PTP_NX_CLK;
     wire clk_ptp_locked;
     mmcm_200_to_50_200_25_50 mmcm_200_to_50_200_25_50_inst
          (.clk_in1_n(Mhz200Clk_ClkIn_clk_n),
          .clk_in1_p(Mhz200Clk_ClkIn_clk_p),
          .clk_out1(SYS_M_AXI_ACLK),
          .clk_out2(clk_200fromsys),
          .locked(clk_sys_locked),
          .resetn(ResetN_RstIn));
     mmcm_10_to_200 mmcm_10_to_200_inst
          (.clk_in1(BufgMux_IPI_2_ClkOut_ClkOut),
          .clk_out1(clk_200from10),
          .resetn(ClockDetector_ClockRstN));
     mmcm_200_to_50_200 mmcm_200_to_50_200_inst
          (.clk_in1(clk_200fromsys),
          .clk_in2(clk_200from10),
          .clk_in_sel(ClockDetector_v_0_ClkWiz2Select_EnOut),
          .clk_out1(PTP_M_AXI_ACLK),
          .clk_out2(PTP_NX_CLK),
          .locked(clk_ptp_locked),
          .resetn(ClockDetector_ClockRstN));
     wire ClockDetector_v_0_ClkWiz2Select_EnOut;
     wire [1:0]ClockDetector_v_0_PpsSourceSelect_DatOut;
     wire ClockDetector_ClockRstN;
     ClockDetector_v #(
          .ClockSelect_Gen(4'b0),
          .PpsSelect_Gen(2'b0)
          ) ClockDetector_v_0 (
          .AxiReadAddrAddress_AdrIn(xbar_sys_1_15_0_m_axi_4_ARADDR[15:0]),
          .AxiReadAddrProt_DatIn(xbar_sys_1_15_0_m_axi_4_ARPROT),
          .AxiReadAddrReady_RdyOut(xbar_sys_1_15_0_m_axi_4_ARREADY),
          .AxiReadAddrValid_ValIn(xbar_sys_1_15_0_m_axi_4_ARVALID),
          .AxiReadDataData_DatOut(xbar_sys_1_15_0_m_axi_4_RDATA),
          .AxiReadDataReady_RdyIn(xbar_sys_1_15_0_m_axi_4_RREADY),
          .AxiReadDataResponse_DatOut(xbar_sys_1_15_0_m_axi_4_RRESP),
          .AxiReadDataValid_ValOut(xbar_sys_1_15_0_m_axi_4_RVALID),
          .AxiWriteAddrAddress_AdrIn(xbar_sys_1_15_0_m_axi_4_AWADDR[15:0]),
          .AxiWriteAddrProt_DatIn(xbar_sys_1_15_0_m_axi_4_AWPROT),
          .AxiWriteAddrReady_RdyOut(xbar_sys_1_15_0_m_axi_4_AWREADY),
          .AxiWriteAddrValid_ValIn(xbar_sys_1_15_0_m_axi_4_AWVALID),
          .AxiWriteDataData_DatIn(xbar_sys_1_15_0_m_axi_4_WDATA),
          .AxiWriteDataReady_RdyOut(xbar_sys_1_15_0_m_axi_4_WREADY),
          .AxiWriteDataStrobe_DatIn(xbar_sys_1_15_0_m_axi_4_WSTRB),
          .AxiWriteDataValid_ValIn(xbar_sys_1_15_0_m_axi_4_WVALID),
          .AxiWriteRespReady_RdyIn(xbar_sys_1_15_0_m_axi_4_BREADY),
          .AxiWriteRespResponse_DatOut(xbar_sys_1_15_0_m_axi_4_BRESP),
          .AxiWriteRespValid_ValOut(xbar_sys_1_15_0_m_axi_4_BVALID),
          .ClkMux1Select_EnOut(ClockDetector_v_0_ClkMux1Select_EnOut),
          .ClkMux2Select_EnOut(ClockDetector_v_0_ClkMux2Select_EnOut),
          .ClkMux3Select_EnOut(ClockDetector_v_0_ClkMux3Select_EnOut),
          .ClkWiz2Select_EnOut(ClockDetector_v_0_ClkWiz2Select_EnOut),
          .ClockRstN_RstOut(ClockDetector_ClockRstN),
          .Mhz10ClkDcxo1_ClkIn(Mhz10ClkDcxo1_ClkIn),
          .Mhz10ClkDcxo2_ClkIn(Mhz10ClkDcxo2_ClkIn),
          .Mhz10ClkMac_ClkIn(Mhz10ClkMac_ClkIn),
          .Mhz10ClkSma_ClkIn(Mhz10ClkSma_ClkIn_BufgCe),
          .PpsSourceAvailable_DatIn(PpsSourceSelector_0_PpsSourceAvailable_DatOut),
          .PpsSourceSelect_DatOut(ClockDetector_v_0_PpsSourceSelect_DatOut),
          .SysClk_ClkIn(SYS_M_AXI_ACLK),
          .SysRstN_RstIn(SYS_M_AXI_ARESETN));
     reset_counter #(.USE_AUX_RESET(1)) ptp_ip_reset (
          .aux_reset_in(ClockDetector_ClockRstN),
          .clk_locked(clk_ptp_locked),
          .ext_reset_in(ResetN_RstIn),
          .rst_3_n(PTP_M_AXI_ARESETN),
          .slowest_sync_clk(PTP_M_AXI_ACLK));
     reset_counter #(.USE_AUX_RESET(0)) sys_ip_reset (
          .aux_reset_in(1'b0),
          .clk_locked(clk_sys_locked),
          .ext_reset_in(ResetN_RstIn),
          .rst_3_n(SYS_M_AXI_ARESETN),
          .slowest_sync_clk(SYS_M_AXI_ACLK));
     // Core of the PTP gateware: PpsSlave, TodSlave, AdjustableClock
     /*python WIRE_AXIL('PTP_ADJCLK_M_AXI_', wire_definition=True, addr=16) */
     wire AdjustableClock_v_0_ServoFactorsValid_ValOut;
     wire [31:0]AdjustableClock_v_0_servo_drift_FactorI;
     wire [31:0]AdjustableClock_v_0_servo_drift_FactorP;
     wire [31:0]AdjustableClock_v_0_servo_offset_FactorI;
     wire [31:0]AdjustableClock_v_0_servo_offset_FactorP;
     wire [31:0]AdjustableClock_0_time_out_Nanosecond;
     wire [31:0]AdjustableClock_0_time_out_Second;
     wire AdjustableClock_0_time_out_TimeJump;
     wire AdjustableClock_0_time_out_Valid;
     (* mark_debug = "true" *) wire AdjustableClock_v_0_InHoldover_DatOut;
     (* mark_debug = "true" *) wire AdjustableClock_v_0_InSync_DatOut;
     AdjustableClock_v #(
          .ClockPeriod_Gen(20),
          .ClockInSyncThreshold_Gen(500),
          .ClockInHoldoverTimeoutSecond_Gen(3)
          ) AdjustableClock_v_0 (
          /*python
          PORT_AXIL(ptp_axil_portname, WIRE_AXIL('PTP_ADJCLK_M_AXI_', portname=True), addr='[15:0]')
          */
          .AxiReadAddrAddress_AdrIn(xbar_ptp_1_23_0_m_axi_0_ARADDR[15:0]),
          .AxiReadAddrProt_DatIn(xbar_ptp_1_23_0_m_axi_0_ARPROT),
          .AxiReadAddrReady_RdyOut(xbar_ptp_1_23_0_m_axi_0_ARREADY),
          .AxiReadAddrValid_ValIn(xbar_ptp_1_23_0_m_axi_0_ARVALID),
          .AxiReadDataData_DatOut(xbar_ptp_1_23_0_m_axi_0_RDATA),
          .AxiReadDataReady_RdyIn(xbar_ptp_1_23_0_m_axi_0_RREADY),
          .AxiReadDataResponse_DatOut(xbar_ptp_1_23_0_m_axi_0_RRESP),
          .AxiReadDataValid_ValOut(xbar_ptp_1_23_0_m_axi_0_RVALID),
          .AxiWriteAddrAddress_AdrIn(xbar_ptp_1_23_0_m_axi_0_AWADDR[15:0]),
          .AxiWriteAddrProt_DatIn(xbar_ptp_1_23_0_m_axi_0_AWPROT),
          .AxiWriteAddrReady_RdyOut(xbar_ptp_1_23_0_m_axi_0_AWREADY),
          .AxiWriteAddrValid_ValIn(xbar_ptp_1_23_0_m_axi_0_AWVALID),
          .AxiWriteDataData_DatIn(xbar_ptp_1_23_0_m_axi_0_WDATA),
          .AxiWriteDataReady_RdyOut(xbar_ptp_1_23_0_m_axi_0_WREADY),
          .AxiWriteDataStrobe_DatIn(xbar_ptp_1_23_0_m_axi_0_WSTRB),
          .AxiWriteDataValid_ValIn(xbar_ptp_1_23_0_m_axi_0_WVALID),
          .AxiWriteRespReady_RdyIn(xbar_ptp_1_23_0_m_axi_0_BREADY),
          .AxiWriteRespResponse_DatOut(xbar_ptp_1_23_0_m_axi_0_BRESP),
          .AxiWriteRespValid_ValOut(xbar_ptp_1_23_0_m_axi_0_BVALID),
          .ClockTime_Nanosecond_DatOut(AdjustableClock_0_time_out_Nanosecond),
          .ClockTime_Second_DatOut(AdjustableClock_0_time_out_Second),
          .ClockTime_TimeJump_DatOut(AdjustableClock_0_time_out_TimeJump),
          .ClockTime_ValOut(AdjustableClock_0_time_out_Valid),
          .DriftAdjustmentIn1_Interval_DatIn(PpsSlave_v_0_drift_adjustment_out_Interval),
          .DriftAdjustmentIn1_Nanosecond_DatIn(PpsSlave_v_0_drift_adjustment_out_Nanosecond),
          .DriftAdjustmentIn1_Sign_DatIn(PpsSlave_v_0_drift_adjustment_out_Sign),
          .DriftAdjustmentIn1_ValIn(PpsSlave_v_0_drift_adjustment_out_Valid),
          .DriftAdjustmentIn2_Interval_DatIn(PpsSlave_v_0_drift_adjustment_out_Interval),
          .DriftAdjustmentIn2_Nanosecond_DatIn(PpsSlave_v_0_drift_adjustment_out_Nanosecond),
          .DriftAdjustmentIn2_Sign_DatIn(1'b0),
          .DriftAdjustmentIn2_ValIn(1'b0),
          .DriftAdjustmentIn3_Interval_DatIn(32'b0),
          .DriftAdjustmentIn3_Nanosecond_DatIn(32'b0),
          .DriftAdjustmentIn3_Sign_DatIn(1'b0),
          .DriftAdjustmentIn3_ValIn(1'b0),
          .DriftAdjustmentIn4_Interval_DatIn(32'b0),
          .DriftAdjustmentIn4_Nanosecond_DatIn(32'b0),
          .DriftAdjustmentIn4_Sign_DatIn(1'b0),
          .DriftAdjustmentIn4_ValIn(1'b0),
          .DriftAdjustmentIn5_Interval_DatIn(32'b0),
          .DriftAdjustmentIn5_Nanosecond_DatIn(32'b0),
          .DriftAdjustmentIn5_Sign_DatIn(1'b0),
          .DriftAdjustmentIn5_ValIn(1'b0),
          .InHoldover_DatOut(InHoldover_DatOut),
          .InSync_DatOut(InSync_DatOut),
          .OffsetAdjustmentIn1_Interval_DatIn(PpsSlave_v_0_offset_adjustment_out_Interval),
          .OffsetAdjustmentIn1_Nanosecond_DatIn(PpsSlave_v_0_offset_adjustment_out_Nanosecond),
          .OffsetAdjustmentIn1_Second_DatIn(PpsSlave_v_0_offset_adjustment_out_Second),
          .OffsetAdjustmentIn1_Sign_DatIn(PpsSlave_v_0_offset_adjustment_out_Sign),
          .OffsetAdjustmentIn1_ValIn(PpsSlave_v_0_offset_adjustment_out_Valid),
          .OffsetAdjustmentIn2_Interval_DatIn(32'b0),
          .OffsetAdjustmentIn2_Nanosecond_DatIn(32'b0),
          .OffsetAdjustmentIn2_Second_DatIn(32'b0),
          .OffsetAdjustmentIn2_Sign_DatIn(1'b0),
          .OffsetAdjustmentIn2_ValIn(1'b0),
          .OffsetAdjustmentIn3_Interval_DatIn(32'b0),
          .OffsetAdjustmentIn3_Nanosecond_DatIn(32'b0),
          .OffsetAdjustmentIn3_Second_DatIn(32'b0),
          .OffsetAdjustmentIn3_Sign_DatIn(1'b0),
          .OffsetAdjustmentIn3_ValIn(1'b0),
          .OffsetAdjustmentIn4_Interval_DatIn(32'b0),
          .OffsetAdjustmentIn4_Nanosecond_DatIn(32'b0),
          .OffsetAdjustmentIn4_Second_DatIn(32'b0),
          .OffsetAdjustmentIn4_Sign_DatIn(1'b0),
          .OffsetAdjustmentIn4_ValIn(1'b0),
          .OffsetAdjustmentIn5_Interval_DatIn(32'b0),
          .OffsetAdjustmentIn5_Nanosecond_DatIn(32'b0),
          .OffsetAdjustmentIn5_Second_DatIn(32'b0),
          .OffsetAdjustmentIn5_Sign_DatIn(1'b0),
          .OffsetAdjustmentIn5_ValIn(1'b0),
          .ServoDriftFactorI_DatOut(AdjustableClock_v_0_servo_drift_FactorI),
          .ServoDriftFactorP_DatOut(AdjustableClock_v_0_servo_drift_FactorP),
          .ServoFactorsValid_ValOut(AdjustableClock_v_0_ServoFactorsValid_ValOut),
          .ServoOffsetFactorI_DatOut(AdjustableClock_v_0_servo_offset_FactorI),
          .ServoOffsetFactorP_DatOut(AdjustableClock_v_0_servo_offset_FactorP),
          .SysClk_ClkIn(PTP_M_AXI_ACLK),
          .SysRstN_RstIn(PTP_M_AXI_ARESETN),
          .TimeAdjustmentIn1_Nanosecond_DatIn(TodSlave_v_0_time_adjustment_out_Nanosecond),
          .TimeAdjustmentIn1_Second_DatIn(TodSlave_v_0_time_adjustment_out_Second),
          .TimeAdjustmentIn1_ValIn(TodSlave_v_0_time_adjustment_out_Valid),
          .TimeAdjustmentIn2_Nanosecond_DatIn(32'b0),
          .TimeAdjustmentIn2_Second_DatIn(32'b0),
          .TimeAdjustmentIn2_ValIn(1'b0),
          .TimeAdjustmentIn3_Nanosecond_DatIn(32'b0),
          .TimeAdjustmentIn3_Second_DatIn(32'b0),
          .TimeAdjustmentIn3_ValIn(1'b0),
          .TimeAdjustmentIn4_Nanosecond_DatIn(32'b0),
          .TimeAdjustmentIn4_Second_DatIn(32'b0),
          .TimeAdjustmentIn4_ValIn(1'b0),
          .TimeAdjustmentIn5_Nanosecond_DatIn(32'b0),
          .TimeAdjustmentIn5_Second_DatIn(32'b0),
          .TimeAdjustmentIn5_ValIn(1'b0));
     wire [31:0]TodSlave_v_0_time_adjustment_out_Nanosecond;
     wire [31:0]TodSlave_v_0_time_adjustment_out_Second;
     wire TodSlave_v_0_time_adjustment_out_Valid;
     TodSlave_v #(
          .ClockPeriod_Gen(20),
          .UartDefaultBaudRate_Gen(7), // 115200 GNSS baud rate
          .UartPolarity_Gen("true"),
          .ReceiveCurrentTime_Gen("true"),
          .Sim_Gen("false")
     ) TodSlave_v_0 (
          .AxiReadAddrAddress_AdrIn(xbar_ptp_1_23_0_m_axi_5_ARADDR[15:0]),
          .AxiReadAddrProt_DatIn(xbar_ptp_1_23_0_m_axi_5_ARPROT),
          .AxiReadAddrReady_RdyOut(xbar_ptp_1_23_0_m_axi_5_ARREADY),
          .AxiReadAddrValid_ValIn(xbar_ptp_1_23_0_m_axi_5_ARVALID),
          .AxiReadDataData_DatOut(xbar_ptp_1_23_0_m_axi_5_RDATA),
          .AxiReadDataReady_RdyIn(xbar_ptp_1_23_0_m_axi_5_RREADY),
          .AxiReadDataResponse_DatOut(xbar_ptp_1_23_0_m_axi_5_RRESP),
          .AxiReadDataValid_ValOut(xbar_ptp_1_23_0_m_axi_5_RVALID),
          .AxiWriteAddrAddress_AdrIn(xbar_ptp_1_23_0_m_axi_5_AWADDR[15:0]),
          .AxiWriteAddrProt_DatIn(xbar_ptp_1_23_0_m_axi_5_AWPROT),
          .AxiWriteAddrReady_RdyOut(xbar_ptp_1_23_0_m_axi_5_AWREADY),
          .AxiWriteAddrValid_ValIn(xbar_ptp_1_23_0_m_axi_5_AWVALID),
          .AxiWriteDataData_DatIn(xbar_ptp_1_23_0_m_axi_5_WDATA),
          .AxiWriteDataReady_RdyOut(xbar_ptp_1_23_0_m_axi_5_WREADY),
          .AxiWriteDataStrobe_DatIn(xbar_ptp_1_23_0_m_axi_5_WSTRB),
          .AxiWriteDataValid_ValIn(xbar_ptp_1_23_0_m_axi_5_WVALID),
          .AxiWriteRespReady_RdyIn(xbar_ptp_1_23_0_m_axi_5_BREADY),
          .AxiWriteRespResponse_DatOut(xbar_ptp_1_23_0_m_axi_5_BRESP),
          .AxiWriteRespValid_ValOut(xbar_ptp_1_23_0_m_axi_5_BVALID),
          .ClockTime_Nanosecond_DatIn(AdjustableClock_0_time_out_Nanosecond),
          .ClockTime_Second_DatIn(AdjustableClock_0_time_out_Second),
          .ClockTime_TimeJump_DatIn(AdjustableClock_0_time_out_TimeJump),
          .ClockTime_ValIn(AdjustableClock_0_time_out_Valid),
          .RxUart_DatIn(UartGnss1Rx_DatIn),
          .SysClk_ClkIn(PTP_M_AXI_ACLK),
          .SysRstN_RstIn(PTP_M_AXI_ARESETN),
          .TimeAdjustment_Nanosecond_DatOut(TodSlave_v_0_time_adjustment_out_Nanosecond),
          .TimeAdjustment_Second_DatOut(TodSlave_v_0_time_adjustment_out_Second),
          .TimeAdjustment_ValOut(TodSlave_v_0_time_adjustment_out_Valid));
     wire [31:0]PpsSlave_v_0_drift_adjustment_out_Interval;
     wire [31:0]PpsSlave_v_0_drift_adjustment_out_Nanosecond;
     wire PpsSlave_v_0_drift_adjustment_out_Sign;
     wire PpsSlave_v_0_drift_adjustment_out_Valid;
     wire [31:0]PpsSlave_v_0_offset_adjustment_out_Interval;
     wire [31:0]PpsSlave_v_0_offset_adjustment_out_Nanosecond;
     wire [31:0]PpsSlave_v_0_offset_adjustment_out_Second;
     wire PpsSlave_v_0_offset_adjustment_out_Sign;
     wire PpsSlave_v_0_offset_adjustment_out_Valid;
     PpsSlave_v #(
          .ClockPeriod_Gen(20),
          .CableDelay_Gen("false"),
          .InputDelay_Gen(0),
          .InputPolarity_Gen("true"),
          .HighResFreqMultiply_Gen(4),
          .DriftMulP_Gen(3),
          .DriftDivP_Gen(4),
          .DriftMulI_Gen(3),
          .DriftDivI_Gen(16),
          .OffsetMulP_Gen(3),
          .OffsetDivP_Gen(4),
          .OffsetMulI_Gen(3),
          .OffsetDivI_Gen(16),
          .Sim_Gen("false")
     ) PpsSlave_v_0 (
          .AxiReadAddrAddress_AdrIn(xbar_ptp_1_23_0_m_axi_4_ARADDR[15:0]),
          .AxiReadAddrProt_DatIn(xbar_ptp_1_23_0_m_axi_4_ARPROT),
          .AxiReadAddrReady_RdyOut(xbar_ptp_1_23_0_m_axi_4_ARREADY),
          .AxiReadAddrValid_ValIn(xbar_ptp_1_23_0_m_axi_4_ARVALID),
          .AxiReadDataData_DatOut(xbar_ptp_1_23_0_m_axi_4_RDATA),
          .AxiReadDataReady_RdyIn(xbar_ptp_1_23_0_m_axi_4_RREADY),
          .AxiReadDataResponse_DatOut(xbar_ptp_1_23_0_m_axi_4_RRESP),
          .AxiReadDataValid_ValOut(xbar_ptp_1_23_0_m_axi_4_RVALID),
          .AxiWriteAddrAddress_AdrIn(xbar_ptp_1_23_0_m_axi_4_AWADDR[15:0]),
          .AxiWriteAddrProt_DatIn(xbar_ptp_1_23_0_m_axi_4_AWPROT),
          .AxiWriteAddrReady_RdyOut(xbar_ptp_1_23_0_m_axi_4_AWREADY),
          .AxiWriteAddrValid_ValIn(xbar_ptp_1_23_0_m_axi_4_AWVALID),
          .AxiWriteDataData_DatIn(xbar_ptp_1_23_0_m_axi_4_WDATA),
          .AxiWriteDataReady_RdyOut(xbar_ptp_1_23_0_m_axi_4_WREADY),
          .AxiWriteDataStrobe_DatIn(xbar_ptp_1_23_0_m_axi_4_WSTRB),
          .AxiWriteDataValid_ValIn(xbar_ptp_1_23_0_m_axi_4_WVALID),
          .AxiWriteRespReady_RdyIn(xbar_ptp_1_23_0_m_axi_4_BREADY),
          .AxiWriteRespResponse_DatOut(xbar_ptp_1_23_0_m_axi_4_BRESP),
          .AxiWriteRespValid_ValOut(xbar_ptp_1_23_0_m_axi_4_BVALID),
          .ClockTime_Nanosecond_DatIn(AdjustableClock_0_time_out_Nanosecond),
          .ClockTime_Second_DatIn(AdjustableClock_0_time_out_Second),
          .ClockTime_TimeJump_DatIn(AdjustableClock_0_time_out_TimeJump),
          .ClockTime_ValIn(AdjustableClock_0_time_out_Valid),
          .DriftAdjustment_Interval_DatOut(PpsSlave_v_0_drift_adjustment_out_Interval),
          .DriftAdjustment_Nanosecond_DatOut(PpsSlave_v_0_drift_adjustment_out_Nanosecond),
          .DriftAdjustment_Sign_DatOut(PpsSlave_v_0_drift_adjustment_out_Sign),
          .DriftAdjustment_ValOut(PpsSlave_v_0_drift_adjustment_out_Valid),
          .OffsetAdjustment_Interval_DatOut(PpsSlave_v_0_offset_adjustment_out_Interval),
          .OffsetAdjustment_Nanosecond_DatOut(PpsSlave_v_0_offset_adjustment_out_Nanosecond),
          .OffsetAdjustment_Second_DatOut(PpsSlave_v_0_offset_adjustment_out_Second),
          .OffsetAdjustment_Sign_DatOut(PpsSlave_v_0_offset_adjustment_out_Sign),
          .OffsetAdjustment_ValOut(PpsSlave_v_0_offset_adjustment_out_Valid),
          .Pps_EvtIn(PpsSourceSelector_0_SlavePps_EvtOut),
          .ServoDriftFactorI_DatIn(AdjustableClock_v_0_servo_drift_FactorI),
          .ServoDriftFactorP_DatIn(AdjustableClock_v_0_servo_drift_FactorP),
          .ServoOffsetFactorI_DatIn(AdjustableClock_v_0_servo_offset_FactorI),
          .ServoOffsetFactorP_DatIn(AdjustableClock_v_0_servo_offset_FactorP),
          .Servo_ValIn(AdjustableClock_v_0_ServoFactorsValid_ValOut),
          .SysClkNx_ClkIn(PTP_NX_CLK),
          .SysClk_ClkIn(PTP_M_AXI_ACLK),
          .SysRstN_RstIn(PTP_M_AXI_ARESETN));
     // MAC UART/I2C selector, again, most people don't have a MAC
     wire CommunicationSelector_0_I2cSclIn_DatOut;
     wire CommunicationSelector_0_I2cSdaIn_DatOut;
     wire CommunicationSelector_0_Irq_DatOut;
     wire CommunicationSelector_0_RxSdaT_EnaOut;
     wire CommunicationSelector_0_RxSda_DatOut;
     wire CommunicationSelector_0_TxSclT_EnaOut;
     wire CommunicationSelector_0_TxScl_DatOut;
     wire CommunicationSelector_0_UartRx_DatOut;
     CommunicationSelector CommunicationSelector_0 (
          .I2cIrq_DatIn(iic_clock_gpio2o),
          .I2cSclIn_DatOut(CommunicationSelector_0_I2cSclIn_DatOut),
          .I2cSclOut_DatIn(axi_iic_clock_scl_o),
          .I2cSclT_EnaIn(axi_iic_clock_scl_t),
          .I2cSdaIn_DatOut(CommunicationSelector_0_I2cSdaIn_DatOut),
          .I2cSdaOut_DatIn(axi_iic_clock_sda_o),
          .I2cSdaT_EnaIn(axi_iic_clock_sda_t),
          .Irq_DatOut(CommunicationSelector_0_Irq_DatOut),
          .RxSdaT_EnaOut(Clk_RxSdaT_EnaOut),
          .RxSda_DatIn(Clk_RxSda_DatIn),
          .RxSda_DatOut(Clk_RxSda_DatOut),
          .SelIn_DatIn(ext_gpio2o[31]),
          .TxSclT_EnaOut(Clk_TxSclT_EnaOut),
          .TxScl_DatIn(Clk_TxScl_DatIn),
          .TxScl_DatOut(Clk_TxScl_DatOut),
          .UartIrq_DatIn(axi_uart16550_mac_ip2intc_irpt),
          .UartRx_DatOut(CommunicationSelector_0_UartRx_DatOut),
          .UartTx_DatIn(axi_uart16550_mac_sout));
     // embedded AXI host to config blocks
     wire [31:0]ConfMaster_v_0_m_axi_ARADDR;
     wire [2:0]ConfMaster_v_0_m_axi_ARPROT;
     wire ConfMaster_v_0_m_axi_ARREADY;
     wire ConfMaster_v_0_m_axi_ARVALID;
     wire [31:0]ConfMaster_v_0_m_axi_AWADDR;
     wire [2:0]ConfMaster_v_0_m_axi_AWPROT;
     wire ConfMaster_v_0_m_axi_AWREADY;
     wire ConfMaster_v_0_m_axi_AWVALID;
     wire ConfMaster_v_0_m_axi_BREADY;
     wire [1:0]ConfMaster_v_0_m_axi_BRESP;
     wire ConfMaster_v_0_m_axi_BVALID;
     wire [31:0]ConfMaster_v_0_m_axi_RDATA;
     wire ConfMaster_v_0_m_axi_RREADY;
     wire [1:0]ConfMaster_v_0_m_axi_RRESP;
     wire ConfMaster_v_0_m_axi_RVALID;
     wire [31:0]ConfMaster_v_0_m_axi_WDATA;
     wire ConfMaster_v_0_m_axi_WREADY;
     wire [3:0]ConfMaster_v_0_m_axi_WSTRB;
     wire ConfMaster_v_0_m_axi_WVALID;
     ConfMaster_v #(
          .ConfigListSize(14),
          .RomAddrWidth_Con(4),
          .AxiTimeout_Gen(0),
          .ClockPeriod_Gen(20),
          .ConfigFile_Processed("~/PTP/Time-Card-Flex/FPGA/Targets/TimeCard_NoVendIPs/DefaultConfigFile.dat")
          ) ConfMaster_v_0 (
          .AxiReadAddrAddress_AdrOut(ConfMaster_v_0_m_axi_ARADDR),
          .AxiReadAddrProt_DatOut(ConfMaster_v_0_m_axi_ARPROT),
          .AxiReadAddrReady_RdyIn(ConfMaster_v_0_m_axi_ARREADY),
          .AxiReadAddrValid_ValOut(ConfMaster_v_0_m_axi_ARVALID),
          .AxiReadDataData_DatIn(ConfMaster_v_0_m_axi_RDATA),
          .AxiReadDataReady_RdyOut(ConfMaster_v_0_m_axi_RREADY),
          .AxiReadDataResponse_DatIn(ConfMaster_v_0_m_axi_RRESP),
          .AxiReadDataValid_ValIn(ConfMaster_v_0_m_axi_RVALID),
          .AxiWriteAddrAddress_AdrOut(ConfMaster_v_0_m_axi_AWADDR),
          .AxiWriteAddrProt_DatOut(ConfMaster_v_0_m_axi_AWPROT),
          .AxiWriteAddrReady_RdyIn(ConfMaster_v_0_m_axi_AWREADY),
          .AxiWriteAddrValid_ValOut(ConfMaster_v_0_m_axi_AWVALID),
          .AxiWriteDataData_DatOut(ConfMaster_v_0_m_axi_WDATA),
          .AxiWriteDataReady_RdyIn(ConfMaster_v_0_m_axi_WREADY),
          .AxiWriteDataStrobe_DatOut(ConfMaster_v_0_m_axi_WSTRB),
          .AxiWriteDataValid_ValOut(ConfMaster_v_0_m_axi_WVALID),
          .AxiWriteRespReady_RdyOut(ConfMaster_v_0_m_axi_BREADY),
          .AxiWriteRespResponse_DatIn(ConfMaster_v_0_m_axi_BRESP),
          .AxiWriteRespValid_ValIn(ConfMaster_v_0_m_axi_BVALID),
          .SysClk_ClkIn(PTP_M_AXI_ACLK),
          .SysRstN_RstIn(PTP_M_AXI_ARESETN));
     // list of peripherals
     CoreList_v #(
          .CoreListBytes_Con(2688),
          .RomAddrWidth_Con(10),
          .ClockPeriod_Gen(20),
          .CoreListFile_Processed("~/PTP/Time-Card-Flex/FPGA/Targets/TimeCard_NoVendIPs/CoreListFile.dat")
          ) CoreList_v_0 (
          .AxiReadAddrAddress_AdrIn(xbar_ptp_1_23_0_m_axi_23_ARADDR[15:0]),
          .AxiReadAddrProt_DatIn(xbar_ptp_1_23_0_m_axi_23_ARPROT),
          .AxiReadAddrReady_RdyOut(xbar_ptp_1_23_0_m_axi_23_ARREADY),
          .AxiReadAddrValid_ValIn(xbar_ptp_1_23_0_m_axi_23_ARVALID),
          .AxiReadDataData_DatOut(xbar_ptp_1_23_0_m_axi_23_RDATA),
          .AxiReadDataReady_RdyIn(xbar_ptp_1_23_0_m_axi_23_RREADY),
          .AxiReadDataResponse_DatOut(xbar_ptp_1_23_0_m_axi_23_RRESP),
          .AxiReadDataValid_ValOut(xbar_ptp_1_23_0_m_axi_23_RVALID),
          .AxiWriteAddrAddress_AdrIn(xbar_ptp_1_23_0_m_axi_23_AWADDR[15:0]),
          .AxiWriteAddrProt_DatIn(xbar_ptp_1_23_0_m_axi_23_AWPROT),
          .AxiWriteAddrReady_RdyOut(xbar_ptp_1_23_0_m_axi_23_AWREADY),
          .AxiWriteAddrValid_ValIn(xbar_ptp_1_23_0_m_axi_23_AWVALID),
          .AxiWriteDataData_DatIn(xbar_ptp_1_23_0_m_axi_23_WDATA),
          .AxiWriteDataReady_RdyOut(xbar_ptp_1_23_0_m_axi_23_WREADY),
          .AxiWriteDataStrobe_DatIn(xbar_ptp_1_23_0_m_axi_23_WSTRB),
          .AxiWriteDataValid_ValIn(xbar_ptp_1_23_0_m_axi_23_WVALID),
          .AxiWriteRespReady_RdyIn(xbar_ptp_1_23_0_m_axi_23_BREADY),
          .AxiWriteRespResponse_DatOut(xbar_ptp_1_23_0_m_axi_23_BRESP),
          .AxiWriteRespValid_ValOut(xbar_ptp_1_23_0_m_axi_23_BVALID),
          .SysClk_ClkIn(PTP_M_AXI_ACLK),
          .SysRstN_RstIn(PTP_M_AXI_ARESETN));
     DummyAxiSlave_v #(
          .ClockPeriod_Gen(20),
          .RamAddrWidth_Gen(10)
          ) DummyAxiSlave_v_0 (
          .AxiReadAddrAddress_AdrIn(xbar_ptp_1_23_0_m_axi_7_ARADDR[15:0]),
          .AxiReadAddrProt_DatIn(xbar_ptp_1_23_0_m_axi_7_ARPROT),
          .AxiReadAddrReady_RdyOut(xbar_ptp_1_23_0_m_axi_7_ARREADY),
          .AxiReadAddrValid_ValIn(xbar_ptp_1_23_0_m_axi_7_ARVALID),
          .AxiReadDataData_DatOut(xbar_ptp_1_23_0_m_axi_7_RDATA),
          .AxiReadDataReady_RdyIn(xbar_ptp_1_23_0_m_axi_7_RREADY),
          .AxiReadDataResponse_DatOut(xbar_ptp_1_23_0_m_axi_7_RRESP),
          .AxiReadDataValid_ValOut(xbar_ptp_1_23_0_m_axi_7_RVALID),
          .AxiWriteAddrAddress_AdrIn(xbar_ptp_1_23_0_m_axi_7_AWADDR[15:0]),
          .AxiWriteAddrProt_DatIn(xbar_ptp_1_23_0_m_axi_7_AWPROT),
          .AxiWriteAddrReady_RdyOut(xbar_ptp_1_23_0_m_axi_7_AWREADY),
          .AxiWriteAddrValid_ValIn(xbar_ptp_1_23_0_m_axi_7_AWVALID),
          .AxiWriteDataData_DatIn(xbar_ptp_1_23_0_m_axi_7_WDATA),
          .AxiWriteDataReady_RdyOut(xbar_ptp_1_23_0_m_axi_7_WREADY),
          .AxiWriteDataStrobe_DatIn(xbar_ptp_1_23_0_m_axi_7_WSTRB),
          .AxiWriteDataValid_ValIn(xbar_ptp_1_23_0_m_axi_7_WVALID),
          .AxiWriteRespReady_RdyIn(xbar_ptp_1_23_0_m_axi_7_BREADY),
          .AxiWriteRespResponse_DatOut(xbar_ptp_1_23_0_m_axi_7_BRESP),
          .AxiWriteRespValid_ValOut(xbar_ptp_1_23_0_m_axi_7_BVALID),
          .SysClk_ClkIn(PTP_M_AXI_ACLK),
          .SysRstN_RstIn(PTP_M_AXI_ARESETN));
     DummyAxiSlave_v #(
          .ClockPeriod_Gen(20),
          .RamAddrWidth_Gen(10)
          ) DummyAxiSlave_v_1 (
          .AxiReadAddrAddress_AdrIn(xbar_ptp_1_23_0_m_axi_8_ARADDR[15:0]),
          .AxiReadAddrProt_DatIn(xbar_ptp_1_23_0_m_axi_8_ARPROT),
          .AxiReadAddrReady_RdyOut(xbar_ptp_1_23_0_m_axi_8_ARREADY),
          .AxiReadAddrValid_ValIn(xbar_ptp_1_23_0_m_axi_8_ARVALID),
          .AxiReadDataData_DatOut(xbar_ptp_1_23_0_m_axi_8_RDATA),
          .AxiReadDataReady_RdyIn(xbar_ptp_1_23_0_m_axi_8_RREADY),
          .AxiReadDataResponse_DatOut(xbar_ptp_1_23_0_m_axi_8_RRESP),
          .AxiReadDataValid_ValOut(xbar_ptp_1_23_0_m_axi_8_RVALID),
          .AxiWriteAddrAddress_AdrIn(xbar_ptp_1_23_0_m_axi_8_AWADDR[15:0]),
          .AxiWriteAddrProt_DatIn(xbar_ptp_1_23_0_m_axi_8_AWPROT),
          .AxiWriteAddrReady_RdyOut(xbar_ptp_1_23_0_m_axi_8_AWREADY),
          .AxiWriteAddrValid_ValIn(xbar_ptp_1_23_0_m_axi_8_AWVALID),
          .AxiWriteDataData_DatIn(xbar_ptp_1_23_0_m_axi_8_WDATA),
          .AxiWriteDataReady_RdyOut(xbar_ptp_1_23_0_m_axi_8_WREADY),
          .AxiWriteDataStrobe_DatIn(xbar_ptp_1_23_0_m_axi_8_WSTRB),
          .AxiWriteDataValid_ValIn(xbar_ptp_1_23_0_m_axi_8_WVALID),
          .AxiWriteRespReady_RdyIn(xbar_ptp_1_23_0_m_axi_8_BREADY),
          .AxiWriteRespResponse_DatOut(xbar_ptp_1_23_0_m_axi_8_BRESP),
          .AxiWriteRespValid_ValOut(xbar_ptp_1_23_0_m_axi_8_BVALID),
          .SysClk_ClkIn(PTP_M_AXI_ACLK),
          .SysRstN_RstIn(PTP_M_AXI_ARESETN));
     DummyAxiSlave_v #(
          .ClockPeriod_Gen(20),
          .RamAddrWidth_Gen(10)
          ) DummyAxiSlave_v_2 (
          .AxiReadAddrAddress_AdrIn(xbar_ptp_1_23_0_m_axi_9_ARADDR[15:0]),
          .AxiReadAddrProt_DatIn(xbar_ptp_1_23_0_m_axi_9_ARPROT),
          .AxiReadAddrReady_RdyOut(xbar_ptp_1_23_0_m_axi_9_ARREADY),
          .AxiReadAddrValid_ValIn(xbar_ptp_1_23_0_m_axi_9_ARVALID),
          .AxiReadDataData_DatOut(xbar_ptp_1_23_0_m_axi_9_RDATA),
          .AxiReadDataReady_RdyIn(xbar_ptp_1_23_0_m_axi_9_RREADY),
          .AxiReadDataResponse_DatOut(xbar_ptp_1_23_0_m_axi_9_RRESP),
          .AxiReadDataValid_ValOut(xbar_ptp_1_23_0_m_axi_9_RVALID),
          .AxiWriteAddrAddress_AdrIn(xbar_ptp_1_23_0_m_axi_9_AWADDR[15:0]),
          .AxiWriteAddrProt_DatIn(xbar_ptp_1_23_0_m_axi_9_AWPROT),
          .AxiWriteAddrReady_RdyOut(xbar_ptp_1_23_0_m_axi_9_AWREADY),
          .AxiWriteAddrValid_ValIn(xbar_ptp_1_23_0_m_axi_9_AWVALID),
          .AxiWriteDataData_DatIn(xbar_ptp_1_23_0_m_axi_9_WDATA),
          .AxiWriteDataReady_RdyOut(xbar_ptp_1_23_0_m_axi_9_WREADY),
          .AxiWriteDataStrobe_DatIn(xbar_ptp_1_23_0_m_axi_9_WSTRB),
          .AxiWriteDataValid_ValIn(xbar_ptp_1_23_0_m_axi_9_WVALID),
          .AxiWriteRespReady_RdyIn(xbar_ptp_1_23_0_m_axi_9_BREADY),
          .AxiWriteRespResponse_DatOut(xbar_ptp_1_23_0_m_axi_9_BRESP),
          .AxiWriteRespValid_ValOut(xbar_ptp_1_23_0_m_axi_9_BVALID),
          .SysClk_ClkIn(PTP_M_AXI_ACLK),
          .SysRstN_RstIn(PTP_M_AXI_ARESETN));
     /*python
     */
     DummyAxiSlave_v #(
          .ClockPeriod_Gen(20),
          .RamAddrWidth_Gen(10)
          ) DummyAxiSlave_v_3 (
          .AxiReadAddrAddress_AdrIn(xbar_ptp_1_23_0_m_axi_10_ARADDR[15:0]),
          .AxiReadAddrProt_DatIn(xbar_ptp_1_23_0_m_axi_10_ARPROT),
          .AxiReadAddrReady_RdyOut(xbar_ptp_1_23_0_m_axi_10_ARREADY),
          .AxiReadAddrValid_ValIn(xbar_ptp_1_23_0_m_axi_10_ARVALID),
          .AxiReadDataData_DatOut(xbar_ptp_1_23_0_m_axi_10_RDATA),
          .AxiReadDataReady_RdyIn(xbar_ptp_1_23_0_m_axi_10_RREADY),
          .AxiReadDataResponse_DatOut(xbar_ptp_1_23_0_m_axi_10_RRESP),
          .AxiReadDataValid_ValOut(xbar_ptp_1_23_0_m_axi_10_RVALID),
          .AxiWriteAddrAddress_AdrIn(xbar_ptp_1_23_0_m_axi_10_AWADDR[15:0]),
          .AxiWriteAddrProt_DatIn(xbar_ptp_1_23_0_m_axi_10_AWPROT),
          .AxiWriteAddrReady_RdyOut(xbar_ptp_1_23_0_m_axi_10_AWREADY),
          .AxiWriteAddrValid_ValIn(xbar_ptp_1_23_0_m_axi_10_AWVALID),
          .AxiWriteDataData_DatIn(xbar_ptp_1_23_0_m_axi_10_WDATA),
          .AxiWriteDataReady_RdyOut(xbar_ptp_1_23_0_m_axi_10_WREADY),
          .AxiWriteDataStrobe_DatIn(xbar_ptp_1_23_0_m_axi_10_WSTRB),
          .AxiWriteDataValid_ValIn(xbar_ptp_1_23_0_m_axi_10_WVALID),
          .AxiWriteRespReady_RdyIn(xbar_ptp_1_23_0_m_axi_10_BREADY),
          .AxiWriteRespResponse_DatOut(xbar_ptp_1_23_0_m_axi_10_BRESP),
          .AxiWriteRespValid_ValOut(xbar_ptp_1_23_0_m_axi_10_BVALID),
          .SysClk_ClkIn(PTP_M_AXI_ACLK),
          .SysRstN_RstIn(PTP_M_AXI_ARESETN));
     DummyAxiSlave_v #(
          .ClockPeriod_Gen(20),
          .RamAddrWidth_Gen(10)
          ) DummyAxiSlave_v_4 (
          .AxiReadAddrAddress_AdrIn(xbar_ptp_1_23_0_m_axi_11_ARADDR[15:0]),
          .AxiReadAddrProt_DatIn(xbar_ptp_1_23_0_m_axi_11_ARPROT),
          .AxiReadAddrReady_RdyOut(xbar_ptp_1_23_0_m_axi_11_ARREADY),
          .AxiReadAddrValid_ValIn(xbar_ptp_1_23_0_m_axi_11_ARVALID),
          .AxiReadDataData_DatOut(xbar_ptp_1_23_0_m_axi_11_RDATA),
          .AxiReadDataReady_RdyIn(xbar_ptp_1_23_0_m_axi_11_RREADY),
          .AxiReadDataResponse_DatOut(xbar_ptp_1_23_0_m_axi_11_RRESP),
          .AxiReadDataValid_ValOut(xbar_ptp_1_23_0_m_axi_11_RVALID),
          .AxiWriteAddrAddress_AdrIn(xbar_ptp_1_23_0_m_axi_11_AWADDR[15:0]),
          .AxiWriteAddrProt_DatIn(xbar_ptp_1_23_0_m_axi_11_AWPROT),
          .AxiWriteAddrReady_RdyOut(xbar_ptp_1_23_0_m_axi_11_AWREADY),
          .AxiWriteAddrValid_ValIn(xbar_ptp_1_23_0_m_axi_11_AWVALID),
          .AxiWriteDataData_DatIn(xbar_ptp_1_23_0_m_axi_11_WDATA),
          .AxiWriteDataReady_RdyOut(xbar_ptp_1_23_0_m_axi_11_WREADY),
          .AxiWriteDataStrobe_DatIn(xbar_ptp_1_23_0_m_axi_11_WSTRB),
          .AxiWriteDataValid_ValIn(xbar_ptp_1_23_0_m_axi_11_WVALID),
          .AxiWriteRespReady_RdyIn(xbar_ptp_1_23_0_m_axi_11_BREADY),
          .AxiWriteRespResponse_DatOut(xbar_ptp_1_23_0_m_axi_11_BRESP),
          .AxiWriteRespValid_ValOut(xbar_ptp_1_23_0_m_axi_11_BVALID),
          .SysClk_ClkIn(PTP_M_AXI_ACLK),
          .SysRstN_RstIn(PTP_M_AXI_ARESETN));
     // DummyAxiSlave_v #(
     //      .ClockPeriod_Gen(20),
     //      .RamAddrWidth_Gen(10)
     //      ) DummyAxiSlave_v_5 (
     //      .AxiReadAddrAddress_AdrIn(xbar_ptp_1_23_0_m_axi_11_ARADDR[15:0]),
     //      .AxiReadAddrProt_DatIn(xbar_ptp_1_23_0_m_axi_11_ARPROT),
     //      .AxiReadAddrReady_RdyOut(xbar_ptp_1_23_0_m_axi_11_ARREADY),
     //      .AxiReadAddrValid_ValIn(xbar_ptp_1_23_0_m_axi_11_ARVALID),
     //      .AxiReadDataData_DatOut(xbar_ptp_1_23_0_m_axi_11_RDATA),
     //      .AxiReadDataReady_RdyIn(xbar_ptp_1_23_0_m_axi_11_RREADY),
     //      .AxiReadDataResponse_DatOut(xbar_ptp_1_23_0_m_axi_11_RRESP),
     //      .AxiReadDataValid_ValOut(xbar_ptp_1_23_0_m_axi_11_RVALID),
     //      .AxiWriteAddrAddress_AdrIn(xbar_ptp_1_23_0_m_axi_11_AWADDR[15:0]),
     //      .AxiWriteAddrProt_DatIn(xbar_ptp_1_23_0_m_axi_11_AWPROT),
     //      .AxiWriteAddrReady_RdyOut(xbar_ptp_1_23_0_m_axi_11_AWREADY),
     //      .AxiWriteAddrValid_ValIn(xbar_ptp_1_23_0_m_axi_11_AWVALID),
     //      .AxiWriteDataData_DatIn(xbar_ptp_1_23_0_m_axi_11_WDATA),
     //      .AxiWriteDataReady_RdyOut(xbar_ptp_1_23_0_m_axi_11_WREADY),
     //      .AxiWriteDataStrobe_DatIn(xbar_ptp_1_23_0_m_axi_11_WSTRB),
     //      .AxiWriteDataValid_ValIn(xbar_ptp_1_23_0_m_axi_11_WVALID),
     //      .AxiWriteRespReady_RdyIn(xbar_ptp_1_23_0_m_axi_11_BREADY),
     //      .AxiWriteRespResponse_DatOut(xbar_ptp_1_23_0_m_axi_11_BRESP),
     //      .AxiWriteRespValid_ValOut(xbar_ptp_1_23_0_m_axi_11_BVALID),
     //      .SysClk_ClkIn(SYS_M_AXI_ACLK),
     //      .SysRstN_RstIn(SYS_M_AXI_ARESETN));
     // DummyAxiSlave_v #(
     //      .ClockPeriod_Gen(20),
     //      .RamAddrWidth_Gen(10)
     //      ) DummyAxiSlave_v_6 (
     //      .AxiReadAddrAddress_AdrIn(xbar_ptp_1_23_0_m_axi_11_ARADDR[15:0]),
     //      .AxiReadAddrProt_DatIn(xbar_ptp_1_23_0_m_axi_11_ARPROT),
     //      .AxiReadAddrReady_RdyOut(xbar_ptp_1_23_0_m_axi_11_ARREADY),
     //      .AxiReadAddrValid_ValIn(xbar_ptp_1_23_0_m_axi_11_ARVALID),
     //      .AxiReadDataData_DatOut(xbar_ptp_1_23_0_m_axi_11_RDATA),
     //      .AxiReadDataReady_RdyIn(xbar_ptp_1_23_0_m_axi_11_RREADY),
     //      .AxiReadDataResponse_DatOut(xbar_ptp_1_23_0_m_axi_11_RRESP),
     //      .AxiReadDataValid_ValOut(xbar_ptp_1_23_0_m_axi_11_RVALID),
     //      .AxiWriteAddrAddress_AdrIn(xbar_ptp_1_23_0_m_axi_11_AWADDR[15:0]),
     //      .AxiWriteAddrProt_DatIn(xbar_ptp_1_23_0_m_axi_11_AWPROT),
     //      .AxiWriteAddrReady_RdyOut(xbar_ptp_1_23_0_m_axi_11_AWREADY),
     //      .AxiWriteAddrValid_ValIn(xbar_ptp_1_23_0_m_axi_11_AWVALID),
     //      .AxiWriteDataData_DatIn(xbar_ptp_1_23_0_m_axi_11_WDATA),
     //      .AxiWriteDataReady_RdyOut(xbar_ptp_1_23_0_m_axi_11_WREADY),
     //      .AxiWriteDataStrobe_DatIn(xbar_ptp_1_23_0_m_axi_11_WSTRB),
     //      .AxiWriteDataValid_ValIn(xbar_ptp_1_23_0_m_axi_11_WVALID),
     //      .AxiWriteRespReady_RdyIn(xbar_ptp_1_23_0_m_axi_11_BREADY),
     //      .AxiWriteRespResponse_DatOut(xbar_ptp_1_23_0_m_axi_11_BRESP),
     //      .AxiWriteRespValid_ValOut(xbar_ptp_1_23_0_m_axi_11_BVALID),
     //      .SysClk_ClkIn(SYS_M_AXI_ACLK),
     //      .SysRstN_RstIn(SYS_M_AXI_ARESETN));
     // Version register, this is under system clock!
     FpgaVersion_v #(
          .VersionNumber_Gen(16'h000c),
          .VersionNumber_Golden_Gen(16'h000c)
     ) FpgaVersion_v_0 (
          .AxiReadAddrAddress_AdrIn(xbar_sys_1_15_0_m_axi_1_ARADDR[15:0]),
          .AxiReadAddrProt_DatIn(xbar_sys_1_15_0_m_axi_1_ARPROT),
          .AxiReadAddrReady_RdyOut(xbar_sys_1_15_0_m_axi_1_ARREADY),
          .AxiReadAddrValid_ValIn(xbar_sys_1_15_0_m_axi_1_ARVALID),
          .AxiReadDataData_DatOut(xbar_sys_1_15_0_m_axi_1_RDATA),
          .AxiReadDataReady_RdyIn(xbar_sys_1_15_0_m_axi_1_RREADY),
          .AxiReadDataResponse_DatOut(xbar_sys_1_15_0_m_axi_1_RRESP),
          .AxiReadDataValid_ValOut(xbar_sys_1_15_0_m_axi_1_RVALID),
          .AxiWriteAddrAddress_AdrIn(xbar_sys_1_15_0_m_axi_1_AWADDR[15:0]),
          .AxiWriteAddrProt_DatIn(xbar_sys_1_15_0_m_axi_1_AWPROT),
          .AxiWriteAddrReady_RdyOut(xbar_sys_1_15_0_m_axi_1_AWREADY),
          .AxiWriteAddrValid_ValIn(xbar_sys_1_15_0_m_axi_1_AWVALID),
          .AxiWriteDataData_DatIn(xbar_sys_1_15_0_m_axi_1_WDATA),
          .AxiWriteDataReady_RdyOut(xbar_sys_1_15_0_m_axi_1_WREADY),
          .AxiWriteDataStrobe_DatIn(xbar_sys_1_15_0_m_axi_1_WSTRB),
          .AxiWriteDataValid_ValIn(xbar_sys_1_15_0_m_axi_1_WVALID),
          .AxiWriteRespReady_RdyIn(xbar_sys_1_15_0_m_axi_1_BREADY),
          .AxiWriteRespResponse_DatOut(xbar_sys_1_15_0_m_axi_1_BRESP),
          .AxiWriteRespValid_ValOut(xbar_sys_1_15_0_m_axi_1_BVALID),
          .GoldenImageN_EnaIn(GoldenImageN_EnaIn),
          .SysClk_ClkIn(SYS_M_AXI_ACLK),
          .SysRstN_RstIn(SYS_M_AXI_ARESETN));
     // 4 frequency counters, unused in ordinary operation... but it's cool to count frequency!
     FrequencyCounter_v #(
          .OutputPolarity_Gen("true")
          ) FrequencyCounter_v_0 (
          .AxiReadAddrAddress_AdrIn(xbar_ptp_1_23_0_m_axi_19_ARADDR[15:0]),
          .AxiReadAddrProt_DatIn(xbar_ptp_1_23_0_m_axi_19_ARPROT),
          .AxiReadAddrReady_RdyOut(xbar_ptp_1_23_0_m_axi_19_ARREADY),
          .AxiReadAddrValid_ValIn(xbar_ptp_1_23_0_m_axi_19_ARVALID),
          .AxiReadDataData_DatOut(xbar_ptp_1_23_0_m_axi_19_RDATA),
          .AxiReadDataReady_RdyIn(xbar_ptp_1_23_0_m_axi_19_RREADY),
          .AxiReadDataResponse_DatOut(xbar_ptp_1_23_0_m_axi_19_RRESP),
          .AxiReadDataValid_ValOut(xbar_ptp_1_23_0_m_axi_19_RVALID),
          .AxiWriteAddrAddress_AdrIn(xbar_ptp_1_23_0_m_axi_19_AWADDR[15:0]),
          .AxiWriteAddrProt_DatIn(xbar_ptp_1_23_0_m_axi_19_AWPROT),
          .AxiWriteAddrReady_RdyOut(xbar_ptp_1_23_0_m_axi_19_AWREADY),
          .AxiWriteAddrValid_ValIn(xbar_ptp_1_23_0_m_axi_19_AWVALID),
          .AxiWriteDataData_DatIn(xbar_ptp_1_23_0_m_axi_19_WDATA),
          .AxiWriteDataReady_RdyOut(xbar_ptp_1_23_0_m_axi_19_WREADY),
          .AxiWriteDataStrobe_DatIn(xbar_ptp_1_23_0_m_axi_19_WSTRB),
          .AxiWriteDataValid_ValIn(xbar_ptp_1_23_0_m_axi_19_WVALID),
          .AxiWriteRespReady_RdyIn(xbar_ptp_1_23_0_m_axi_19_BREADY),
          .AxiWriteRespResponse_DatOut(xbar_ptp_1_23_0_m_axi_19_BRESP),
          .AxiWriteRespValid_ValOut(xbar_ptp_1_23_0_m_axi_19_BVALID),
          .ClockTime_Nanosecond_DatIn(AdjustableClock_0_time_out_Nanosecond),
          .ClockTime_Second_DatIn(AdjustableClock_0_time_out_Second),
          .ClockTime_TimeJump_DatIn(AdjustableClock_0_time_out_TimeJump),
          .ClockTime_ValIn(AdjustableClock_0_time_out_Valid),
          .Frequency_EvtIn(SmaSelector_v_0_SmaFreqCnt1Source_EvtOut),
          .SysClk_ClkIn(PTP_M_AXI_ACLK),
          .SysRstN_RstIn(PTP_M_AXI_ARESETN));
     FrequencyCounter_v #(
          .OutputPolarity_Gen("true")
          ) FrequencyCounter_v_1 (
          .AxiReadAddrAddress_AdrIn(xbar_ptp_1_23_0_m_axi_20_ARADDR[15:0]),
          .AxiReadAddrProt_DatIn(xbar_ptp_1_23_0_m_axi_20_ARPROT),
          .AxiReadAddrReady_RdyOut(xbar_ptp_1_23_0_m_axi_20_ARREADY),
          .AxiReadAddrValid_ValIn(xbar_ptp_1_23_0_m_axi_20_ARVALID),
          .AxiReadDataData_DatOut(xbar_ptp_1_23_0_m_axi_20_RDATA),
          .AxiReadDataReady_RdyIn(xbar_ptp_1_23_0_m_axi_20_RREADY),
          .AxiReadDataResponse_DatOut(xbar_ptp_1_23_0_m_axi_20_RRESP),
          .AxiReadDataValid_ValOut(xbar_ptp_1_23_0_m_axi_20_RVALID),
          .AxiWriteAddrAddress_AdrIn(xbar_ptp_1_23_0_m_axi_20_AWADDR[15:0]),
          .AxiWriteAddrProt_DatIn(xbar_ptp_1_23_0_m_axi_20_AWPROT),
          .AxiWriteAddrReady_RdyOut(xbar_ptp_1_23_0_m_axi_20_AWREADY),
          .AxiWriteAddrValid_ValIn(xbar_ptp_1_23_0_m_axi_20_AWVALID),
          .AxiWriteDataData_DatIn(xbar_ptp_1_23_0_m_axi_20_WDATA),
          .AxiWriteDataReady_RdyOut(xbar_ptp_1_23_0_m_axi_20_WREADY),
          .AxiWriteDataStrobe_DatIn(xbar_ptp_1_23_0_m_axi_20_WSTRB),
          .AxiWriteDataValid_ValIn(xbar_ptp_1_23_0_m_axi_20_WVALID),
          .AxiWriteRespReady_RdyIn(xbar_ptp_1_23_0_m_axi_20_BREADY),
          .AxiWriteRespResponse_DatOut(xbar_ptp_1_23_0_m_axi_20_BRESP),
          .AxiWriteRespValid_ValOut(xbar_ptp_1_23_0_m_axi_20_BVALID),
          .ClockTime_Nanosecond_DatIn(AdjustableClock_0_time_out_Nanosecond),
          .ClockTime_Second_DatIn(AdjustableClock_0_time_out_Second),
          .ClockTime_TimeJump_DatIn(AdjustableClock_0_time_out_TimeJump),
          .ClockTime_ValIn(AdjustableClock_0_time_out_Valid),
          .Frequency_EvtIn(SmaSelector_v_0_SmaFreqCnt2Source_EvtOut),
          .SysClk_ClkIn(PTP_M_AXI_ACLK),
          .SysRstN_RstIn(PTP_M_AXI_ARESETN));
     FrequencyCounter_v #(
          .OutputPolarity_Gen("true")
          ) FrequencyCounter_v_2 (
          .AxiReadAddrAddress_AdrIn(xbar_ptp_1_23_0_m_axi_21_ARADDR[15:0]),
          .AxiReadAddrProt_DatIn(xbar_ptp_1_23_0_m_axi_21_ARPROT),
          .AxiReadAddrReady_RdyOut(xbar_ptp_1_23_0_m_axi_21_ARREADY),
          .AxiReadAddrValid_ValIn(xbar_ptp_1_23_0_m_axi_21_ARVALID),
          .AxiReadDataData_DatOut(xbar_ptp_1_23_0_m_axi_21_RDATA),
          .AxiReadDataReady_RdyIn(xbar_ptp_1_23_0_m_axi_21_RREADY),
          .AxiReadDataResponse_DatOut(xbar_ptp_1_23_0_m_axi_21_RRESP),
          .AxiReadDataValid_ValOut(xbar_ptp_1_23_0_m_axi_21_RVALID),
          .AxiWriteAddrAddress_AdrIn(xbar_ptp_1_23_0_m_axi_21_AWADDR[15:0]),
          .AxiWriteAddrProt_DatIn(xbar_ptp_1_23_0_m_axi_21_AWPROT),
          .AxiWriteAddrReady_RdyOut(xbar_ptp_1_23_0_m_axi_21_AWREADY),
          .AxiWriteAddrValid_ValIn(xbar_ptp_1_23_0_m_axi_21_AWVALID),
          .AxiWriteDataData_DatIn(xbar_ptp_1_23_0_m_axi_21_WDATA),
          .AxiWriteDataReady_RdyOut(xbar_ptp_1_23_0_m_axi_21_WREADY),
          .AxiWriteDataStrobe_DatIn(xbar_ptp_1_23_0_m_axi_21_WSTRB),
          .AxiWriteDataValid_ValIn(xbar_ptp_1_23_0_m_axi_21_WVALID),
          .AxiWriteRespReady_RdyIn(xbar_ptp_1_23_0_m_axi_21_BREADY),
          .AxiWriteRespResponse_DatOut(xbar_ptp_1_23_0_m_axi_21_BRESP),
          .AxiWriteRespValid_ValOut(xbar_ptp_1_23_0_m_axi_21_BVALID),
          .ClockTime_Nanosecond_DatIn(AdjustableClock_0_time_out_Nanosecond),
          .ClockTime_Second_DatIn(AdjustableClock_0_time_out_Second),
          .ClockTime_TimeJump_DatIn(AdjustableClock_0_time_out_TimeJump),
          .ClockTime_ValIn(AdjustableClock_0_time_out_Valid),
          .Frequency_EvtIn(SmaSelector_v_0_SmaFreqCnt3Source_EvtOut),
          .SysClk_ClkIn(PTP_M_AXI_ACLK),
          .SysRstN_RstIn(PTP_M_AXI_ARESETN));
     FrequencyCounter_v #(
          .OutputPolarity_Gen("true")
          ) FrequencyCounter_v_3 (
          .AxiReadAddrAddress_AdrIn(xbar_ptp_1_23_0_m_axi_22_ARADDR[15:0]),
          .AxiReadAddrProt_DatIn(xbar_ptp_1_23_0_m_axi_22_ARPROT),
          .AxiReadAddrReady_RdyOut(xbar_ptp_1_23_0_m_axi_22_ARREADY),
          .AxiReadAddrValid_ValIn(xbar_ptp_1_23_0_m_axi_22_ARVALID),
          .AxiReadDataData_DatOut(xbar_ptp_1_23_0_m_axi_22_RDATA),
          .AxiReadDataReady_RdyIn(xbar_ptp_1_23_0_m_axi_22_RREADY),
          .AxiReadDataResponse_DatOut(xbar_ptp_1_23_0_m_axi_22_RRESP),
          .AxiReadDataValid_ValOut(xbar_ptp_1_23_0_m_axi_22_RVALID),
          .AxiWriteAddrAddress_AdrIn(xbar_ptp_1_23_0_m_axi_22_AWADDR[15:0]),
          .AxiWriteAddrProt_DatIn(xbar_ptp_1_23_0_m_axi_22_AWPROT),
          .AxiWriteAddrReady_RdyOut(xbar_ptp_1_23_0_m_axi_22_AWREADY),
          .AxiWriteAddrValid_ValIn(xbar_ptp_1_23_0_m_axi_22_AWVALID),
          .AxiWriteDataData_DatIn(xbar_ptp_1_23_0_m_axi_22_WDATA),
          .AxiWriteDataReady_RdyOut(xbar_ptp_1_23_0_m_axi_22_WREADY),
          .AxiWriteDataStrobe_DatIn(xbar_ptp_1_23_0_m_axi_22_WSTRB),
          .AxiWriteDataValid_ValIn(xbar_ptp_1_23_0_m_axi_22_WVALID),
          .AxiWriteRespReady_RdyIn(xbar_ptp_1_23_0_m_axi_22_BREADY),
          .AxiWriteRespResponse_DatOut(xbar_ptp_1_23_0_m_axi_22_BRESP),
          .AxiWriteRespValid_ValOut(xbar_ptp_1_23_0_m_axi_22_BVALID),
          .ClockTime_Nanosecond_DatIn(AdjustableClock_0_time_out_Nanosecond),
          .ClockTime_Second_DatIn(AdjustableClock_0_time_out_Second),
          .ClockTime_TimeJump_DatIn(AdjustableClock_0_time_out_TimeJump),
          .ClockTime_ValIn(AdjustableClock_0_time_out_Valid),
          .Frequency_EvtIn(SmaSelector_v_0_SmaFreqCnt4Source_EvtOut),
          .SysClk_ClkIn(PTP_M_AXI_ACLK),
          .SysRstN_RstIn(PTP_M_AXI_ARESETN));
     // Generate FPGA PPS, this combines long term stable GNSS + short term stable DCXO
     PpsGenerator_v #(
          .ClockPeriod_Gen(20),
          .CableDelay_Gen("true"),
          .OutputDelay_Gen(0),
          .OutputPolarity_Gen("true"),
          .HighResFreqMultiply_Gen(4),
          .Sim_Gen("false")
          ) PpsGenerator_v_0 (
          .AxiReadAddrAddress_AdrIn(xbar_ptp_1_23_0_m_axi_3_ARADDR[15:0]),
          .AxiReadAddrProt_DatIn(xbar_ptp_1_23_0_m_axi_3_ARPROT),
          .AxiReadAddrReady_RdyOut(xbar_ptp_1_23_0_m_axi_3_ARREADY),
          .AxiReadAddrValid_ValIn(xbar_ptp_1_23_0_m_axi_3_ARVALID),
          .AxiReadDataData_DatOut(xbar_ptp_1_23_0_m_axi_3_RDATA),
          .AxiReadDataReady_RdyIn(xbar_ptp_1_23_0_m_axi_3_RREADY),
          .AxiReadDataResponse_DatOut(xbar_ptp_1_23_0_m_axi_3_RRESP),
          .AxiReadDataValid_ValOut(xbar_ptp_1_23_0_m_axi_3_RVALID),
          .AxiWriteAddrAddress_AdrIn(xbar_ptp_1_23_0_m_axi_3_AWADDR[15:0]),
          .AxiWriteAddrProt_DatIn(xbar_ptp_1_23_0_m_axi_3_AWPROT),
          .AxiWriteAddrReady_RdyOut(xbar_ptp_1_23_0_m_axi_3_AWREADY),
          .AxiWriteAddrValid_ValIn(xbar_ptp_1_23_0_m_axi_3_AWVALID),
          .AxiWriteDataData_DatIn(xbar_ptp_1_23_0_m_axi_3_WDATA),
          .AxiWriteDataReady_RdyOut(xbar_ptp_1_23_0_m_axi_3_WREADY),
          .AxiWriteDataStrobe_DatIn(xbar_ptp_1_23_0_m_axi_3_WSTRB),
          .AxiWriteDataValid_ValIn(xbar_ptp_1_23_0_m_axi_3_WVALID),
          .AxiWriteRespReady_RdyIn(xbar_ptp_1_23_0_m_axi_3_BREADY),
          .AxiWriteRespResponse_DatOut(xbar_ptp_1_23_0_m_axi_3_BRESP),
          .AxiWriteRespValid_ValOut(xbar_ptp_1_23_0_m_axi_3_BVALID),
          .ClockTime_Nanosecond_DatIn(AdjustableClock_0_time_out_Nanosecond),
          .ClockTime_Second_DatIn(AdjustableClock_0_time_out_Second),
          .ClockTime_TimeJump_DatIn(AdjustableClock_0_time_out_TimeJump),
          .ClockTime_ValIn(AdjustableClock_0_time_out_Valid),
          .Pps_EvtOut(Pps_EvtOut),
          .SysClkNx_ClkIn(PTP_NX_CLK),
          .SysClk_ClkIn(PTP_M_AXI_ACLK),
          .SysRstN_RstIn(PTP_M_AXI_ARESETN));
     // PPS source selector
     wire PpsSourceSelector_0_MacPps_EvtOut;
     wire [3:0]PpsSourceSelector_0_PpsSourceAvailable_DatOut;
     wire PpsSourceSelector_0_SlavePps_EvtOut;
     wire PpsSourceSelector_1_MacPps_EvtOut;
     // Drives the PTP function. Also outputs to MAC input for feedback
     PpsSourceSelector #(
          .ClockClkPeriodNanosecond_Gen(20),
          .PpsAvailableThreshold_Gen(3)
          ) PpsSourceSelector_0 (
          .GnssPps_EvtIn(PpsGnss1_EvtIn),
          .MacPps_EvtIn(MacPps_EvtIn),
          .MacPps_EvtOut(MacPps0_EvtOut),
          .PpsSourceAvailable_DatOut(PpsSourceSelector_0_PpsSourceAvailable_DatOut),
          .PpsSourceSelect_DatIn(ClockDetector_v_0_PpsSourceSelect_DatOut),
          .SlavePps_EvtOut(PpsSourceSelector_0_SlavePps_EvtOut),
          .SmaPps_EvtIn(SmaSelector_v_0_SmaExtPpsSource1_EvtOut),
          .SysClk_ClkIn(SYS_M_AXI_ACLK),
          .SysRstN_RstIn(SYS_M_AXI_ARESETN));
     // unused
     PpsSourceSelector #(
          .ClockClkPeriodNanosecond_Gen(20),
          .PpsAvailableThreshold_Gen(3)
          ) PpsSourceSelector_1 (
          .GnssPps_EvtIn(PpsGnss2_EvtIn),
          .MacPps_EvtIn(1'b0),
          .MacPps_EvtOut(MacPps1_EvtOut),
          .PpsSourceSelect_DatIn(2'b0),
          .SmaPps_EvtIn(SmaSelector_v_0_SmaExtPpsSource2_EvtOut),
          .SysClk_ClkIn(SYS_M_AXI_ACLK),
          .SysRstN_RstIn(SYS_M_AXI_ARESETN));
     // 4 signal generators to SMA output, unused 
     wire SignalGenerator_v_0_Irq_EvtOut;
     wire SignalGenerator_v_0_SignalGenerator_EvtOut;
     wire SignalGenerator_v_1_Irq_EvtOut;
     wire SignalGenerator_v_1_SignalGenerator_EvtOut;
     wire SignalGenerator_v_2_Irq_EvtOut;
     wire SignalGenerator_v_2_SignalGenerator_EvtOut;
     wire SignalGenerator_v_3_Irq_EvtOut;
     wire SignalGenerator_v_3_SignalGenerator_EvtOut;
     SignalGenerator_v #(
          .ClockPeriod_Gen(20),
          .CableDelay_Gen("true"),
          .OutputDelay_Gen(0),
          .OutputPolarity_Gen("true"),
          .HighResFreqMultiply_Gen(4)
          ) SignalGenerator_v_0 (
          .AxiReadAddrAddress_AdrIn(xbar_ptp_1_23_0_m_axi_13_ARADDR[15:0]),
          .AxiReadAddrProt_DatIn(xbar_ptp_1_23_0_m_axi_13_ARPROT),
          .AxiReadAddrReady_RdyOut(xbar_ptp_1_23_0_m_axi_13_ARREADY),
          .AxiReadAddrValid_ValIn(xbar_ptp_1_23_0_m_axi_13_ARVALID),
          .AxiReadDataData_DatOut(xbar_ptp_1_23_0_m_axi_13_RDATA),
          .AxiReadDataReady_RdyIn(xbar_ptp_1_23_0_m_axi_13_RREADY),
          .AxiReadDataResponse_DatOut(xbar_ptp_1_23_0_m_axi_13_RRESP),
          .AxiReadDataValid_ValOut(xbar_ptp_1_23_0_m_axi_13_RVALID),
          .AxiWriteAddrAddress_AdrIn(xbar_ptp_1_23_0_m_axi_13_AWADDR[15:0]),
          .AxiWriteAddrProt_DatIn(xbar_ptp_1_23_0_m_axi_13_AWPROT),
          .AxiWriteAddrReady_RdyOut(xbar_ptp_1_23_0_m_axi_13_AWREADY),
          .AxiWriteAddrValid_ValIn(xbar_ptp_1_23_0_m_axi_13_AWVALID),
          .AxiWriteDataData_DatIn(xbar_ptp_1_23_0_m_axi_13_WDATA),
          .AxiWriteDataReady_RdyOut(xbar_ptp_1_23_0_m_axi_13_WREADY),
          .AxiWriteDataStrobe_DatIn(xbar_ptp_1_23_0_m_axi_13_WSTRB),
          .AxiWriteDataValid_ValIn(xbar_ptp_1_23_0_m_axi_13_WVALID),
          .AxiWriteRespReady_RdyIn(xbar_ptp_1_23_0_m_axi_13_BREADY),
          .AxiWriteRespResponse_DatOut(xbar_ptp_1_23_0_m_axi_13_BRESP),
          .AxiWriteRespValid_ValOut(xbar_ptp_1_23_0_m_axi_13_BVALID),
          .ClockTime_Nanosecond_DatIn(AdjustableClock_0_time_out_Nanosecond),
          .ClockTime_Second_DatIn(AdjustableClock_0_time_out_Second),
          .ClockTime_TimeJump_DatIn(AdjustableClock_0_time_out_TimeJump),
          .ClockTime_ValIn(AdjustableClock_0_time_out_Valid),
          .Irq_EvtOut(SignalGenerator_v_0_Irq_EvtOut),
          .SignalGenerator_EvtOut(SignalGenerator_v_0_SignalGenerator_EvtOut),
          .SysClkNx_ClkIn(PTP_NX_CLK),
          .SysClk_ClkIn(PTP_M_AXI_ACLK),
          .SysRstN_RstIn(PTP_M_AXI_ARESETN));
     SignalGenerator_v #(
          .ClockPeriod_Gen(20),
          .CableDelay_Gen("true"),
          .OutputDelay_Gen(0),
          .OutputPolarity_Gen("true"),
          .HighResFreqMultiply_Gen(4)
          ) SignalGenerator_v_1 (
          .AxiReadAddrAddress_AdrIn(xbar_ptp_1_23_0_m_axi_14_ARADDR[15:0]),
          .AxiReadAddrProt_DatIn(xbar_ptp_1_23_0_m_axi_14_ARPROT),
          .AxiReadAddrReady_RdyOut(xbar_ptp_1_23_0_m_axi_14_ARREADY),
          .AxiReadAddrValid_ValIn(xbar_ptp_1_23_0_m_axi_14_ARVALID),
          .AxiReadDataData_DatOut(xbar_ptp_1_23_0_m_axi_14_RDATA),
          .AxiReadDataReady_RdyIn(xbar_ptp_1_23_0_m_axi_14_RREADY),
          .AxiReadDataResponse_DatOut(xbar_ptp_1_23_0_m_axi_14_RRESP),
          .AxiReadDataValid_ValOut(xbar_ptp_1_23_0_m_axi_14_RVALID),
          .AxiWriteAddrAddress_AdrIn(xbar_ptp_1_23_0_m_axi_14_AWADDR[15:0]),
          .AxiWriteAddrProt_DatIn(xbar_ptp_1_23_0_m_axi_14_AWPROT),
          .AxiWriteAddrReady_RdyOut(xbar_ptp_1_23_0_m_axi_14_AWREADY),
          .AxiWriteAddrValid_ValIn(xbar_ptp_1_23_0_m_axi_14_AWVALID),
          .AxiWriteDataData_DatIn(xbar_ptp_1_23_0_m_axi_14_WDATA),
          .AxiWriteDataReady_RdyOut(xbar_ptp_1_23_0_m_axi_14_WREADY),
          .AxiWriteDataStrobe_DatIn(xbar_ptp_1_23_0_m_axi_14_WSTRB),
          .AxiWriteDataValid_ValIn(xbar_ptp_1_23_0_m_axi_14_WVALID),
          .AxiWriteRespReady_RdyIn(xbar_ptp_1_23_0_m_axi_14_BREADY),
          .AxiWriteRespResponse_DatOut(xbar_ptp_1_23_0_m_axi_14_BRESP),
          .AxiWriteRespValid_ValOut(xbar_ptp_1_23_0_m_axi_14_BVALID),
          .ClockTime_Nanosecond_DatIn(AdjustableClock_0_time_out_Nanosecond),
          .ClockTime_Second_DatIn(AdjustableClock_0_time_out_Second),
          .ClockTime_TimeJump_DatIn(AdjustableClock_0_time_out_TimeJump),
          .ClockTime_ValIn(AdjustableClock_0_time_out_Valid),
          .Irq_EvtOut(SignalGenerator_v_1_Irq_EvtOut),
          .SignalGenerator_EvtOut(SignalGenerator_v_1_SignalGenerator_EvtOut),
          .SysClkNx_ClkIn(PTP_NX_CLK),
          .SysClk_ClkIn(PTP_M_AXI_ACLK),
          .SysRstN_RstIn(PTP_M_AXI_ARESETN));
     SignalGenerator_v #(
          .ClockPeriod_Gen(20),
          .CableDelay_Gen("true"),
          .OutputDelay_Gen(0),
          .OutputPolarity_Gen("true"),
          .HighResFreqMultiply_Gen(4)
          ) SignalGenerator_v_2 (
          .AxiReadAddrAddress_AdrIn(xbar_ptp_1_23_0_m_axi_15_ARADDR[15:0]),
          .AxiReadAddrProt_DatIn(xbar_ptp_1_23_0_m_axi_15_ARPROT),
          .AxiReadAddrReady_RdyOut(xbar_ptp_1_23_0_m_axi_15_ARREADY),
          .AxiReadAddrValid_ValIn(xbar_ptp_1_23_0_m_axi_15_ARVALID),
          .AxiReadDataData_DatOut(xbar_ptp_1_23_0_m_axi_15_RDATA),
          .AxiReadDataReady_RdyIn(xbar_ptp_1_23_0_m_axi_15_RREADY),
          .AxiReadDataResponse_DatOut(xbar_ptp_1_23_0_m_axi_15_RRESP),
          .AxiReadDataValid_ValOut(xbar_ptp_1_23_0_m_axi_15_RVALID),
          .AxiWriteAddrAddress_AdrIn(xbar_ptp_1_23_0_m_axi_15_AWADDR[15:0]),
          .AxiWriteAddrProt_DatIn(xbar_ptp_1_23_0_m_axi_15_AWPROT),
          .AxiWriteAddrReady_RdyOut(xbar_ptp_1_23_0_m_axi_15_AWREADY),
          .AxiWriteAddrValid_ValIn(xbar_ptp_1_23_0_m_axi_15_AWVALID),
          .AxiWriteDataData_DatIn(xbar_ptp_1_23_0_m_axi_15_WDATA),
          .AxiWriteDataReady_RdyOut(xbar_ptp_1_23_0_m_axi_15_WREADY),
          .AxiWriteDataStrobe_DatIn(xbar_ptp_1_23_0_m_axi_15_WSTRB),
          .AxiWriteDataValid_ValIn(xbar_ptp_1_23_0_m_axi_15_WVALID),
          .AxiWriteRespReady_RdyIn(xbar_ptp_1_23_0_m_axi_15_BREADY),
          .AxiWriteRespResponse_DatOut(xbar_ptp_1_23_0_m_axi_15_BRESP),
          .AxiWriteRespValid_ValOut(xbar_ptp_1_23_0_m_axi_15_BVALID),
          .ClockTime_Nanosecond_DatIn(AdjustableClock_0_time_out_Nanosecond),
          .ClockTime_Second_DatIn(AdjustableClock_0_time_out_Second),
          .ClockTime_TimeJump_DatIn(AdjustableClock_0_time_out_TimeJump),
          .ClockTime_ValIn(AdjustableClock_0_time_out_Valid),
          .Irq_EvtOut(SignalGenerator_v_2_Irq_EvtOut),
          .SignalGenerator_EvtOut(SignalGenerator_v_2_SignalGenerator_EvtOut),
          .SysClkNx_ClkIn(PTP_NX_CLK),
          .SysClk_ClkIn(PTP_M_AXI_ACLK),
          .SysRstN_RstIn(PTP_M_AXI_ARESETN));
     SignalGenerator_v #(
          .ClockPeriod_Gen(20),
          .CableDelay_Gen("true"),
          .OutputDelay_Gen(0),
          .OutputPolarity_Gen("true"),
          .HighResFreqMultiply_Gen(4)
          ) SignalGenerator_v_3 (
          .AxiReadAddrAddress_AdrIn(xbar_ptp_1_23_0_m_axi_16_ARADDR[15:0]),
          .AxiReadAddrProt_DatIn(xbar_ptp_1_23_0_m_axi_16_ARPROT),
          .AxiReadAddrReady_RdyOut(xbar_ptp_1_23_0_m_axi_16_ARREADY),
          .AxiReadAddrValid_ValIn(xbar_ptp_1_23_0_m_axi_16_ARVALID),
          .AxiReadDataData_DatOut(xbar_ptp_1_23_0_m_axi_16_RDATA),
          .AxiReadDataReady_RdyIn(xbar_ptp_1_23_0_m_axi_16_RREADY),
          .AxiReadDataResponse_DatOut(xbar_ptp_1_23_0_m_axi_16_RRESP),
          .AxiReadDataValid_ValOut(xbar_ptp_1_23_0_m_axi_16_RVALID),
          .AxiWriteAddrAddress_AdrIn(xbar_ptp_1_23_0_m_axi_16_AWADDR[15:0]),
          .AxiWriteAddrProt_DatIn(xbar_ptp_1_23_0_m_axi_16_AWPROT),
          .AxiWriteAddrReady_RdyOut(xbar_ptp_1_23_0_m_axi_16_AWREADY),
          .AxiWriteAddrValid_ValIn(xbar_ptp_1_23_0_m_axi_16_AWVALID),
          .AxiWriteDataData_DatIn(xbar_ptp_1_23_0_m_axi_16_WDATA),
          .AxiWriteDataReady_RdyOut(xbar_ptp_1_23_0_m_axi_16_WREADY),
          .AxiWriteDataStrobe_DatIn(xbar_ptp_1_23_0_m_axi_16_WSTRB),
          .AxiWriteDataValid_ValIn(xbar_ptp_1_23_0_m_axi_16_WVALID),
          .AxiWriteRespReady_RdyIn(xbar_ptp_1_23_0_m_axi_16_BREADY),
          .AxiWriteRespResponse_DatOut(xbar_ptp_1_23_0_m_axi_16_BRESP),
          .AxiWriteRespValid_ValOut(xbar_ptp_1_23_0_m_axi_16_BVALID),
          .ClockTime_Nanosecond_DatIn(AdjustableClock_0_time_out_Nanosecond),
          .ClockTime_Second_DatIn(AdjustableClock_0_time_out_Second),
          .ClockTime_TimeJump_DatIn(AdjustableClock_0_time_out_TimeJump),
          .ClockTime_ValIn(AdjustableClock_0_time_out_Valid),
          .Irq_EvtOut(SignalGenerator_v_3_Irq_EvtOut),
          .SignalGenerator_EvtOut(SignalGenerator_v_3_SignalGenerator_EvtOut),
          .SysClkNx_ClkIn(PTP_NX_CLK),
          .SysClk_ClkIn(PTP_M_AXI_ACLK),
          .SysRstN_RstIn(PTP_M_AXI_ARESETN));
     // 6 Timestampers, using PPS from GNSS, FPGA, or SMA 1-4, unused by default
     wire Timestamper_Gnss1Pps_Irq_EvtOut;
     wire Timestamper_FpgaPps_Irq_EvtOut;
     wire Timestamper_0_Irq_EvtOut;
     wire Timestamper_1_Irq_EvtOut;
     wire Timestamper_2_Irq_EvtOut;
     wire Timestamper_3_Irq_EvtOut;
     SignalTimestamper_v #(
          .ClockPeriod_Gen(20),
          .CableDelay_Gen("true"),
          .InputDelay_Gen(0),
          .InputPolarity_Gen("true"),
          .HighResFreqMultiply_Gen(4)
          ) TS_Gnss1Pps (
          .AxiReadAddrAddress_AdrIn(xbar_ptp_1_23_0_m_axi_1_ARADDR[15:0]),
          .AxiReadAddrProt_DatIn(xbar_ptp_1_23_0_m_axi_1_ARPROT),
          .AxiReadAddrReady_RdyOut(xbar_ptp_1_23_0_m_axi_1_ARREADY),
          .AxiReadAddrValid_ValIn(xbar_ptp_1_23_0_m_axi_1_ARVALID),
          .AxiReadDataData_DatOut(xbar_ptp_1_23_0_m_axi_1_RDATA),
          .AxiReadDataReady_RdyIn(xbar_ptp_1_23_0_m_axi_1_RREADY),
          .AxiReadDataResponse_DatOut(xbar_ptp_1_23_0_m_axi_1_RRESP),
          .AxiReadDataValid_ValOut(xbar_ptp_1_23_0_m_axi_1_RVALID),
          .AxiWriteAddrAddress_AdrIn(xbar_ptp_1_23_0_m_axi_1_AWADDR[15:0]),
          .AxiWriteAddrProt_DatIn(xbar_ptp_1_23_0_m_axi_1_AWPROT),
          .AxiWriteAddrReady_RdyOut(xbar_ptp_1_23_0_m_axi_1_AWREADY),
          .AxiWriteAddrValid_ValIn(xbar_ptp_1_23_0_m_axi_1_AWVALID),
          .AxiWriteDataData_DatIn(xbar_ptp_1_23_0_m_axi_1_WDATA),
          .AxiWriteDataReady_RdyOut(xbar_ptp_1_23_0_m_axi_1_WREADY),
          .AxiWriteDataStrobe_DatIn(xbar_ptp_1_23_0_m_axi_1_WSTRB),
          .AxiWriteDataValid_ValIn(xbar_ptp_1_23_0_m_axi_1_WVALID),
          .AxiWriteRespReady_RdyIn(xbar_ptp_1_23_0_m_axi_1_BREADY),
          .AxiWriteRespResponse_DatOut(xbar_ptp_1_23_0_m_axi_1_BRESP),
          .AxiWriteRespValid_ValOut(xbar_ptp_1_23_0_m_axi_1_BVALID),
          .ClockTime_Nanosecond_DatIn(AdjustableClock_0_time_out_Nanosecond),
          .ClockTime_Second_DatIn(AdjustableClock_0_time_out_Second),
          .ClockTime_TimeJump_DatIn(AdjustableClock_0_time_out_TimeJump),
          .ClockTime_ValIn(AdjustableClock_0_time_out_Valid),
          .Irq_EvtOut(Timestamper_Gnss1Pps_Irq_EvtOut),
          .SignalTimestamper_EvtIn(PpsGnss1_EvtIn),
          .SysClkNx_ClkIn(PTP_NX_CLK),
          .SysClk_ClkIn(PTP_M_AXI_ACLK),
          .SysRstN_RstIn(PTP_M_AXI_ARESETN));
     SignalTimestamper_v #(
          .ClockPeriod_Gen(20),
          .CableDelay_Gen("true"),
          .InputDelay_Gen(0),
          .InputPolarity_Gen("true"),
          .HighResFreqMultiply_Gen(4)
          ) TS_FpgaPPS (
          .AxiReadAddrAddress_AdrIn(xbar_ptp_1_23_0_m_axi_12_ARADDR[15:0]),
          .AxiReadAddrProt_DatIn(xbar_ptp_1_23_0_m_axi_12_ARPROT),
          .AxiReadAddrReady_RdyOut(xbar_ptp_1_23_0_m_axi_12_ARREADY),
          .AxiReadAddrValid_ValIn(xbar_ptp_1_23_0_m_axi_12_ARVALID),
          .AxiReadDataData_DatOut(xbar_ptp_1_23_0_m_axi_12_RDATA),
          .AxiReadDataReady_RdyIn(xbar_ptp_1_23_0_m_axi_12_RREADY),
          .AxiReadDataResponse_DatOut(xbar_ptp_1_23_0_m_axi_12_RRESP),
          .AxiReadDataValid_ValOut(xbar_ptp_1_23_0_m_axi_12_RVALID),
          .AxiWriteAddrAddress_AdrIn(xbar_ptp_1_23_0_m_axi_12_AWADDR[15:0]),
          .AxiWriteAddrProt_DatIn(xbar_ptp_1_23_0_m_axi_12_AWPROT),
          .AxiWriteAddrReady_RdyOut(xbar_ptp_1_23_0_m_axi_12_AWREADY),
          .AxiWriteAddrValid_ValIn(xbar_ptp_1_23_0_m_axi_12_AWVALID),
          .AxiWriteDataData_DatIn(xbar_ptp_1_23_0_m_axi_12_WDATA),
          .AxiWriteDataReady_RdyOut(xbar_ptp_1_23_0_m_axi_12_WREADY),
          .AxiWriteDataStrobe_DatIn(xbar_ptp_1_23_0_m_axi_12_WSTRB),
          .AxiWriteDataValid_ValIn(xbar_ptp_1_23_0_m_axi_12_WVALID),
          .AxiWriteRespReady_RdyIn(xbar_ptp_1_23_0_m_axi_12_BREADY),
          .AxiWriteRespResponse_DatOut(xbar_ptp_1_23_0_m_axi_12_BRESP),
          .AxiWriteRespValid_ValOut(xbar_ptp_1_23_0_m_axi_12_BVALID),
          .ClockTime_Nanosecond_DatIn(AdjustableClock_0_time_out_Nanosecond),
          .ClockTime_Second_DatIn(AdjustableClock_0_time_out_Second),
          .ClockTime_TimeJump_DatIn(AdjustableClock_0_time_out_TimeJump),
          .ClockTime_ValIn(AdjustableClock_0_time_out_Valid),
          .Irq_EvtOut(Timestamper_FpgaPps_Irq_EvtOut),
          .SignalTimestamper_EvtIn(Pps_EvtOut),
          .SysClkNx_ClkIn(PTP_NX_CLK),
          .SysClk_ClkIn(PTP_M_AXI_ACLK),
          .SysRstN_RstIn(PTP_M_AXI_ARESETN));
     SignalTimestamper_v #(
          .ClockPeriod_Gen(20),
          .CableDelay_Gen("true"),
          .InputDelay_Gen(0),
          .InputPolarity_Gen("true"),
          .HighResFreqMultiply_Gen(4)
          ) TS0 (
          .AxiReadAddrAddress_AdrIn(xbar_ptp_1_23_0_m_axi_2_ARADDR[15:0]),
          .AxiReadAddrProt_DatIn(xbar_ptp_1_23_0_m_axi_2_ARPROT),
          .AxiReadAddrReady_RdyOut(xbar_ptp_1_23_0_m_axi_2_ARREADY),
          .AxiReadAddrValid_ValIn(xbar_ptp_1_23_0_m_axi_2_ARVALID),
          .AxiReadDataData_DatOut(xbar_ptp_1_23_0_m_axi_2_RDATA),
          .AxiReadDataReady_RdyIn(xbar_ptp_1_23_0_m_axi_2_RREADY),
          .AxiReadDataResponse_DatOut(xbar_ptp_1_23_0_m_axi_2_RRESP),
          .AxiReadDataValid_ValOut(xbar_ptp_1_23_0_m_axi_2_RVALID),
          .AxiWriteAddrAddress_AdrIn(xbar_ptp_1_23_0_m_axi_2_AWADDR[15:0]),
          .AxiWriteAddrProt_DatIn(xbar_ptp_1_23_0_m_axi_2_AWPROT),
          .AxiWriteAddrReady_RdyOut(xbar_ptp_1_23_0_m_axi_2_AWREADY),
          .AxiWriteAddrValid_ValIn(xbar_ptp_1_23_0_m_axi_2_AWVALID),
          .AxiWriteDataData_DatIn(xbar_ptp_1_23_0_m_axi_2_WDATA),
          .AxiWriteDataReady_RdyOut(xbar_ptp_1_23_0_m_axi_2_WREADY),
          .AxiWriteDataStrobe_DatIn(xbar_ptp_1_23_0_m_axi_2_WSTRB),
          .AxiWriteDataValid_ValIn(xbar_ptp_1_23_0_m_axi_2_WVALID),
          .AxiWriteRespReady_RdyIn(xbar_ptp_1_23_0_m_axi_2_BREADY),
          .AxiWriteRespResponse_DatOut(xbar_ptp_1_23_0_m_axi_2_BRESP),
          .AxiWriteRespValid_ValOut(xbar_ptp_1_23_0_m_axi_2_BVALID),
          .ClockTime_Nanosecond_DatIn(AdjustableClock_0_time_out_Nanosecond),
          .ClockTime_Second_DatIn(AdjustableClock_0_time_out_Second),
          .ClockTime_TimeJump_DatIn(AdjustableClock_0_time_out_TimeJump),
          .ClockTime_ValIn(AdjustableClock_0_time_out_Valid),
          .Irq_EvtOut(Timestamper_0_Irq_EvtOut),
          .SignalTimestamper_EvtIn(SmaSelector_v_0_SmaTs1Source_EvtOut),
          .SysClkNx_ClkIn(PTP_NX_CLK),
          .SysClk_ClkIn(PTP_M_AXI_ACLK),
          .SysRstN_RstIn(PTP_M_AXI_ARESETN));
     SignalTimestamper_v #(
          .ClockPeriod_Gen(20),
          .CableDelay_Gen("true"),
          .InputDelay_Gen(0),
          .InputPolarity_Gen("true"),
          .HighResFreqMultiply_Gen(4)
          ) TS1 (
          .AxiReadAddrAddress_AdrIn(xbar_ptp_1_23_0_m_axi_6_ARADDR[15:0]),
          .AxiReadAddrProt_DatIn(xbar_ptp_1_23_0_m_axi_6_ARPROT),
          .AxiReadAddrReady_RdyOut(xbar_ptp_1_23_0_m_axi_6_ARREADY),
          .AxiReadAddrValid_ValIn(xbar_ptp_1_23_0_m_axi_6_ARVALID),
          .AxiReadDataData_DatOut(xbar_ptp_1_23_0_m_axi_6_RDATA),
          .AxiReadDataReady_RdyIn(xbar_ptp_1_23_0_m_axi_6_RREADY),
          .AxiReadDataResponse_DatOut(xbar_ptp_1_23_0_m_axi_6_RRESP),
          .AxiReadDataValid_ValOut(xbar_ptp_1_23_0_m_axi_6_RVALID),
          .AxiWriteAddrAddress_AdrIn(xbar_ptp_1_23_0_m_axi_6_AWADDR[15:0]),
          .AxiWriteAddrProt_DatIn(xbar_ptp_1_23_0_m_axi_6_AWPROT),
          .AxiWriteAddrReady_RdyOut(xbar_ptp_1_23_0_m_axi_6_AWREADY),
          .AxiWriteAddrValid_ValIn(xbar_ptp_1_23_0_m_axi_6_AWVALID),
          .AxiWriteDataData_DatIn(xbar_ptp_1_23_0_m_axi_6_WDATA),
          .AxiWriteDataReady_RdyOut(xbar_ptp_1_23_0_m_axi_6_WREADY),
          .AxiWriteDataStrobe_DatIn(xbar_ptp_1_23_0_m_axi_6_WSTRB),
          .AxiWriteDataValid_ValIn(xbar_ptp_1_23_0_m_axi_6_WVALID),
          .AxiWriteRespReady_RdyIn(xbar_ptp_1_23_0_m_axi_6_BREADY),
          .AxiWriteRespResponse_DatOut(xbar_ptp_1_23_0_m_axi_6_BRESP),
          .AxiWriteRespValid_ValOut(xbar_ptp_1_23_0_m_axi_6_BVALID),
          .ClockTime_Nanosecond_DatIn(AdjustableClock_0_time_out_Nanosecond),
          .ClockTime_Second_DatIn(AdjustableClock_0_time_out_Second),
          .ClockTime_TimeJump_DatIn(AdjustableClock_0_time_out_TimeJump),
          .ClockTime_ValIn(AdjustableClock_0_time_out_Valid),
          .Irq_EvtOut(Timestamper_1_Irq_EvtOut),
          .SignalTimestamper_EvtIn(SmaSelector_v_0_SmaTs2Source_EvtOut),
          .SysClkNx_ClkIn(PTP_NX_CLK),
          .SysClk_ClkIn(PTP_M_AXI_ACLK),
          .SysRstN_RstIn(PTP_M_AXI_ARESETN));
     SignalTimestamper_v #(
          .ClockPeriod_Gen(20),
          .CableDelay_Gen("true"),
          .InputDelay_Gen(0),
          .InputPolarity_Gen("true"),
          .HighResFreqMultiply_Gen(4)
          ) TS2 (
          .AxiReadAddrAddress_AdrIn(xbar_ptp_1_23_0_m_axi_17_ARADDR[15:0]),
          .AxiReadAddrProt_DatIn(xbar_ptp_1_23_0_m_axi_17_ARPROT),
          .AxiReadAddrReady_RdyOut(xbar_ptp_1_23_0_m_axi_17_ARREADY),
          .AxiReadAddrValid_ValIn(xbar_ptp_1_23_0_m_axi_17_ARVALID),
          .AxiReadDataData_DatOut(xbar_ptp_1_23_0_m_axi_17_RDATA),
          .AxiReadDataReady_RdyIn(xbar_ptp_1_23_0_m_axi_17_RREADY),
          .AxiReadDataResponse_DatOut(xbar_ptp_1_23_0_m_axi_17_RRESP),
          .AxiReadDataValid_ValOut(xbar_ptp_1_23_0_m_axi_17_RVALID),
          .AxiWriteAddrAddress_AdrIn(xbar_ptp_1_23_0_m_axi_17_AWADDR[15:0]),
          .AxiWriteAddrProt_DatIn(xbar_ptp_1_23_0_m_axi_17_AWPROT),
          .AxiWriteAddrReady_RdyOut(xbar_ptp_1_23_0_m_axi_17_AWREADY),
          .AxiWriteAddrValid_ValIn(xbar_ptp_1_23_0_m_axi_17_AWVALID),
          .AxiWriteDataData_DatIn(xbar_ptp_1_23_0_m_axi_17_WDATA),
          .AxiWriteDataReady_RdyOut(xbar_ptp_1_23_0_m_axi_17_WREADY),
          .AxiWriteDataStrobe_DatIn(xbar_ptp_1_23_0_m_axi_17_WSTRB),
          .AxiWriteDataValid_ValIn(xbar_ptp_1_23_0_m_axi_17_WVALID),
          .AxiWriteRespReady_RdyIn(xbar_ptp_1_23_0_m_axi_17_BREADY),
          .AxiWriteRespResponse_DatOut(xbar_ptp_1_23_0_m_axi_17_BRESP),
          .AxiWriteRespValid_ValOut(xbar_ptp_1_23_0_m_axi_17_BVALID),
          .ClockTime_Nanosecond_DatIn(AdjustableClock_0_time_out_Nanosecond),
          .ClockTime_Second_DatIn(AdjustableClock_0_time_out_Second),
          .ClockTime_TimeJump_DatIn(AdjustableClock_0_time_out_TimeJump),
          .ClockTime_ValIn(AdjustableClock_0_time_out_Valid),
          .Irq_EvtOut(Timestamper_2_Irq_EvtOut),
          .SignalTimestamper_EvtIn(SmaSelector_v_0_SmaTs3Source_EvtOut),
          .SysClkNx_ClkIn(PTP_NX_CLK),
          .SysClk_ClkIn(PTP_M_AXI_ACLK),
          .SysRstN_RstIn(PTP_M_AXI_ARESETN));
     SignalTimestamper_v #(
          .ClockPeriod_Gen(20),
          .CableDelay_Gen("true"),
          .InputDelay_Gen(0),
          .InputPolarity_Gen("true"),
          .HighResFreqMultiply_Gen(4)
          ) TS3 (
          .AxiReadAddrAddress_AdrIn(xbar_ptp_1_23_0_m_axi_18_ARADDR[15:0]),
          .AxiReadAddrProt_DatIn(xbar_ptp_1_23_0_m_axi_18_ARPROT),
          .AxiReadAddrReady_RdyOut(xbar_ptp_1_23_0_m_axi_18_ARREADY),
          .AxiReadAddrValid_ValIn(xbar_ptp_1_23_0_m_axi_18_ARVALID),
          .AxiReadDataData_DatOut(xbar_ptp_1_23_0_m_axi_18_RDATA),
          .AxiReadDataReady_RdyIn(xbar_ptp_1_23_0_m_axi_18_RREADY),
          .AxiReadDataResponse_DatOut(xbar_ptp_1_23_0_m_axi_18_RRESP),
          .AxiReadDataValid_ValOut(xbar_ptp_1_23_0_m_axi_18_RVALID),
          .AxiWriteAddrAddress_AdrIn(xbar_ptp_1_23_0_m_axi_18_AWADDR[15:0]),
          .AxiWriteAddrProt_DatIn(xbar_ptp_1_23_0_m_axi_18_AWPROT),
          .AxiWriteAddrReady_RdyOut(xbar_ptp_1_23_0_m_axi_18_AWREADY),
          .AxiWriteAddrValid_ValIn(xbar_ptp_1_23_0_m_axi_18_AWVALID),
          .AxiWriteDataData_DatIn(xbar_ptp_1_23_0_m_axi_18_WDATA),
          .AxiWriteDataReady_RdyOut(xbar_ptp_1_23_0_m_axi_18_WREADY),
          .AxiWriteDataStrobe_DatIn(xbar_ptp_1_23_0_m_axi_18_WSTRB),
          .AxiWriteDataValid_ValIn(xbar_ptp_1_23_0_m_axi_18_WVALID),
          .AxiWriteRespReady_RdyIn(xbar_ptp_1_23_0_m_axi_18_BREADY),
          .AxiWriteRespResponse_DatOut(xbar_ptp_1_23_0_m_axi_18_BRESP),
          .AxiWriteRespValid_ValOut(xbar_ptp_1_23_0_m_axi_18_BVALID),
          .ClockTime_Nanosecond_DatIn(AdjustableClock_0_time_out_Nanosecond),
          .ClockTime_Second_DatIn(AdjustableClock_0_time_out_Second),
          .ClockTime_TimeJump_DatIn(AdjustableClock_0_time_out_TimeJump),
          .ClockTime_ValIn(AdjustableClock_0_time_out_Valid),
          .Irq_EvtOut(Timestamper_3_Irq_EvtOut),
          .SignalTimestamper_EvtIn(SmaSelector_v_0_SmaTs4Source_EvtOut),
          .SysClkNx_ClkIn(PTP_NX_CLK),
          .SysClk_ClkIn(PTP_M_AXI_ACLK),
          .SysRstN_RstIn(PTP_M_AXI_ARESETN));
     // SMA input/output selector, this have 2 AXI interfaces
     wire SmaSelector_v_0_Sma10MHzSourceEnable_EnOut;
     wire SmaSelector_v_0_SmaExtPpsSource1_EvtOut;
     wire SmaSelector_v_0_SmaExtPpsSource2_EvtOut;
     wire SmaSelector_v_0_SmaFreqCnt1Source_EvtOut;
     wire SmaSelector_v_0_SmaFreqCnt2Source_EvtOut;
     wire SmaSelector_v_0_SmaFreqCnt3Source_EvtOut;
     wire SmaSelector_v_0_SmaFreqCnt4Source_EvtOut;
     wire SmaSelector_v_0_SmaTs1Source_EvtOut;
     wire SmaSelector_v_0_SmaTs2Source_EvtOut;
     wire SmaSelector_v_0_SmaTs3Source_EvtOut;
     wire SmaSelector_v_0_SmaTs4Source_EvtOut;
     wire SmaSelector_v_0_SmaUartExtSource_DatOut;
     SmaSelector_v #(
          .SmaInput1SourceSelect_Gen(16'H8000),
          .SmaInput2SourceSelect_Gen(16'H8001),
          .SmaInput3SourceSelect_Gen(16'H0000),
          .SmaInput4SourceSelect_Gen(16'H0000),
          .SmaOutput1SourceSelect_Gen(16'H0000),
          .SmaOutput2SourceSelect_Gen(16'H0000),
          .SmaOutput3SourceSelect_Gen(16'H8000),
          .SmaOutput4SourceSelect_Gen(16'H8001)
          ) SmaSelector_v_0 (
          .Axi1ReadAddrAddress_AdrIn(xbar_sys_1_15_0_m_axi_5_ARADDR[15:0]),
          .Axi1ReadAddrProt_DatIn(xbar_sys_1_15_0_m_axi_5_ARPROT),
          .Axi1ReadAddrReady_RdyOut(xbar_sys_1_15_0_m_axi_5_ARREADY),
          .Axi1ReadAddrValid_ValIn(xbar_sys_1_15_0_m_axi_5_ARVALID),
          .Axi1ReadDataData_DatOut(xbar_sys_1_15_0_m_axi_5_RDATA),
          .Axi1ReadDataReady_RdyIn(xbar_sys_1_15_0_m_axi_5_RREADY),
          .Axi1ReadDataResponse_DatOut(xbar_sys_1_15_0_m_axi_5_RRESP),
          .Axi1ReadDataValid_ValOut(xbar_sys_1_15_0_m_axi_5_RVALID),
          .Axi1WriteAddrAddress_AdrIn(xbar_sys_1_15_0_m_axi_5_AWADDR[15:0]),
          .Axi1WriteAddrProt_DatIn(xbar_sys_1_15_0_m_axi_5_AWPROT),
          .Axi1WriteAddrReady_RdyOut(xbar_sys_1_15_0_m_axi_5_AWREADY),
          .Axi1WriteAddrValid_ValIn(xbar_sys_1_15_0_m_axi_5_AWVALID),
          .Axi1WriteDataData_DatIn(xbar_sys_1_15_0_m_axi_5_WDATA),
          .Axi1WriteDataReady_RdyOut(xbar_sys_1_15_0_m_axi_5_WREADY),
          .Axi1WriteDataStrobe_DatIn(xbar_sys_1_15_0_m_axi_5_WSTRB),
          .Axi1WriteDataValid_ValIn(xbar_sys_1_15_0_m_axi_5_WVALID),
          .Axi1WriteRespReady_RdyIn(xbar_sys_1_15_0_m_axi_5_BREADY),
          .Axi1WriteRespResponse_DatOut(xbar_sys_1_15_0_m_axi_5_BRESP),
          .Axi1WriteRespValid_ValOut(xbar_sys_1_15_0_m_axi_5_BVALID),
          .Axi2ReadAddrAddress_AdrIn(xbar_sys_1_15_0_m_axi_13_ARADDR[15:0]),
          .Axi2ReadAddrProt_DatIn(xbar_sys_1_15_0_m_axi_13_ARPROT),
          .Axi2ReadAddrReady_RdyOut(xbar_sys_1_15_0_m_axi_13_ARREADY),
          .Axi2ReadAddrValid_ValIn(xbar_sys_1_15_0_m_axi_13_ARVALID),
          .Axi2ReadDataData_DatOut(xbar_sys_1_15_0_m_axi_13_RDATA),
          .Axi2ReadDataReady_RdyIn(xbar_sys_1_15_0_m_axi_13_RREADY),
          .Axi2ReadDataResponse_DatOut(xbar_sys_1_15_0_m_axi_13_RRESP),
          .Axi2ReadDataValid_ValOut(xbar_sys_1_15_0_m_axi_13_RVALID),
          .Axi2WriteAddrAddress_AdrIn(xbar_sys_1_15_0_m_axi_13_AWADDR[15:0]),
          .Axi2WriteAddrProt_DatIn(xbar_sys_1_15_0_m_axi_13_AWPROT),
          .Axi2WriteAddrReady_RdyOut(xbar_sys_1_15_0_m_axi_13_AWREADY),
          .Axi2WriteAddrValid_ValIn(xbar_sys_1_15_0_m_axi_13_AWVALID),
          .Axi2WriteDataData_DatIn(xbar_sys_1_15_0_m_axi_13_WDATA),
          .Axi2WriteDataReady_RdyOut(xbar_sys_1_15_0_m_axi_13_WREADY),
          .Axi2WriteDataStrobe_DatIn(xbar_sys_1_15_0_m_axi_13_WSTRB),
          .Axi2WriteDataValid_ValIn(xbar_sys_1_15_0_m_axi_13_WVALID),
          .Axi2WriteRespReady_RdyIn(xbar_sys_1_15_0_m_axi_13_BREADY),
          .Axi2WriteRespResponse_DatOut(xbar_sys_1_15_0_m_axi_13_BRESP),
          .Axi2WriteRespValid_ValOut(xbar_sys_1_15_0_m_axi_13_BVALID),
          .Sma10MHzSourceEnable_EnOut(SmaSelector_v_0_Sma10MHzSourceEnable_EnOut),
          .Sma10MHzSource_ClkIn(Mhz10ClkMac_ClkIn),
          .SmaDcfMasterSource_DatIn(1'b1),
          .SmaExtPpsSource1_EvtOut(SmaSelector_v_0_SmaExtPpsSource1_EvtOut),
          .SmaExtPpsSource2_EvtOut(SmaSelector_v_0_SmaExtPpsSource2_EvtOut),
          .SmaFpgaPpsSource_EvtIn(Pps_EvtOut),
          .SmaFreqCnt1Source_EvtOut(SmaSelector_v_0_SmaFreqCnt1Source_EvtOut),
          .SmaFreqCnt2Source_EvtOut(SmaSelector_v_0_SmaFreqCnt2Source_EvtOut),
          .SmaFreqCnt3Source_EvtOut(SmaSelector_v_0_SmaFreqCnt3Source_EvtOut),
          .SmaFreqCnt4Source_EvtOut(SmaSelector_v_0_SmaFreqCnt4Source_EvtOut),
          .SmaGnss1PpsSource_EvtIn(PpsGnss1_EvtIn),
          .SmaGnss2PpsSource_EvtIn(PpsGnss2_EvtIn),
          .SmaIn1_DatIn(SmaIn1_DatIn),
          .SmaIn1_EnOut(SmaIn1_EnOut),
          .SmaIn2_DatIn(SmaIn2_DatIn),
          .SmaIn2_EnOut(SmaIn2_EnOut),
          .SmaIn3_DatIn(SmaIn3_DatIn),
          .SmaIn3_EnOut(SmaIn3_EnOut),
          .SmaIn4_DatIn(SmaIn4_DatIn),
          .SmaIn4_EnOut(SmaIn4_EnOut),
          .SmaIrigMasterSource_DatIn(1'b1),
          .SmaMacPpsSource_EvtIn(MacPps_EvtIn),
          .SmaOut1_DatOut(SmaOut1_DatOut),
          .SmaOut1_EnOut(SmaOut1_EnOut),
          .SmaOut2_DatOut(SmaOut2_DatOut),
          .SmaOut2_EnOut(SmaOut2_EnOut),
          .SmaOut3_DatOut(SmaOut3_DatOut),
          .SmaOut3_EnOut(SmaOut3_EnOut),
          .SmaOut4_DatOut(SmaOut4_DatOut),
          .SmaOut4_EnOut(SmaOut4_EnOut),
          .SmaSignalGen1Source_DatIn(SignalGenerator_v_0_SignalGenerator_EvtOut),
          .SmaSignalGen2Source_DatIn(SignalGenerator_v_1_SignalGenerator_EvtOut),
          .SmaSignalGen3Source_DatIn(SignalGenerator_v_2_SignalGenerator_EvtOut),
          .SmaSignalGen4Source_DatIn(SignalGenerator_v_3_SignalGenerator_EvtOut),
          .SmaTs1Source_EvtOut(SmaSelector_v_0_SmaTs1Source_EvtOut),
          .SmaTs2Source_EvtOut(SmaSelector_v_0_SmaTs2Source_EvtOut),
          .SmaTs3Source_EvtOut(SmaSelector_v_0_SmaTs3Source_EvtOut),
          .SmaTs4Source_EvtOut(SmaSelector_v_0_SmaTs4Source_EvtOut),
          .SmaUartExtSource_DatIn(axi_uart16550_ext_sout),
          .SmaUartExtSource_DatOut(SmaSelector_v_0_SmaUartExtSource_DatOut),
          .SmaUartGnss1Source_DatIn(UartGnss1Rx_DatIn),
          .SmaUartGnss2Source_DatIn(UartGnss2Rx_DatIn),
          .SysClk_ClkIn(SYS_M_AXI_ACLK),
          .SysRstN_RstIn(SYS_M_AXI_ARESETN));
     // 2 IICs and 1 SPI
     // bit bang IIC system sensors
     wire iic_gpio2o;
     axil_gpio #(
          .ALL_INPUT(0),
          .ALL_OUTPUT(0),
          .WIDTH(2),
          .DEFAULT_OUTPUT(32'h0),
          .DEFAULT_TRI(32'hFFFFFFFF),
          .ALL_INPUT_2(0),
          .ALL_OUTPUT_2(1),
          .WIDTH_2(1),
          .DEFAULT_OUTPUT_2(32'h0),
          .DEFAULT_TRI_2(32'hFFFFFFFF)
          ) axil_gpio_iic (
          .gpio_i({I2c_scl_i, I2c_sda_i}),
          .gpio_o({I2c_scl_o, I2c_sda_o}),
          .gpio_t({I2c_scl_t, I2c_sda_t}),
          .gpio2_i(32'b0),
          .gpio2_o(iic_gpio2o),
          .s_axi_clk(SYS_M_AXI_ACLK),
          .s_axi_aresetn(SYS_M_AXI_ARESETN),
          .s_axi_araddr(xbar_sys_1_15_0_m_axi_6_ARADDR),
          .s_axi_arready(xbar_sys_1_15_0_m_axi_6_ARREADY),
          .s_axi_arvalid(xbar_sys_1_15_0_m_axi_6_ARVALID),
          .s_axi_awaddr(xbar_sys_1_15_0_m_axi_6_AWADDR),
          .s_axi_awready(xbar_sys_1_15_0_m_axi_6_AWREADY),
          .s_axi_awvalid(xbar_sys_1_15_0_m_axi_6_AWVALID),
          .s_axi_bready(xbar_sys_1_15_0_m_axi_6_BREADY),
          .s_axi_bresp(xbar_sys_1_15_0_m_axi_6_BRESP),
          .s_axi_bvalid(xbar_sys_1_15_0_m_axi_6_BVALID),
          .s_axi_rdata(xbar_sys_1_15_0_m_axi_6_RDATA),
          .s_axi_rready(xbar_sys_1_15_0_m_axi_6_RREADY),
          .s_axi_rresp(xbar_sys_1_15_0_m_axi_6_RRESP),
          .s_axi_rvalid(xbar_sys_1_15_0_m_axi_6_RVALID),
          .s_axi_wdata(xbar_sys_1_15_0_m_axi_6_WDATA),
          .s_axi_wready(xbar_sys_1_15_0_m_axi_6_WREADY),
          .s_axi_wstrb(xbar_sys_1_15_0_m_axi_6_WSTRB),
          .s_axi_wvalid(xbar_sys_1_15_0_m_axi_6_WVALID));
     // bit bang IIC MAC, connected to CommunicationSelector
     wire I2c_scl_i;
     wire I2c_scl_o;
     wire I2c_scl_t;
     wire I2c_sda_i;
     wire I2c_sda_o;
     wire I2c_sda_t;
     IOBUF I2c_scl_iobuf
     (.I(I2c_scl_o),
     .IO(I2c_scl_io),
     .O(I2c_scl_i),
     .T(I2c_scl_t));
     IOBUF I2c_sda_iobuf
     (.I(I2c_sda_o),
     .IO(I2c_sda_io),
     .O(I2c_sda_i),
     .T(I2c_sda_t));
     wire SpiFlash_io0_i;
     wire SpiFlash_io0_o;
     wire SpiFlash_io0_t;
     wire SpiFlash_io1_i;
     wire SpiFlash_io1_o;
     wire SpiFlash_io1_t;
     wire SpiFlash_io2_i;
     wire SpiFlash_io2_o;
     wire SpiFlash_io2_t;
     wire SpiFlash_io3_i;
     wire SpiFlash_io3_o;
     wire SpiFlash_io3_t;
     wire SpiFlash_ss_o;
     IOBUF SpiFlash_io0_iobuf
     (.I(SpiFlash_io0_o),
     .IO(SpiFlash_io0_io),
     .O(SpiFlash_io0_i),
     .T(SpiFlash_io0_t));
     IOBUF SpiFlash_io1_iobuf
     (.I(SpiFlash_io1_o),
     .IO(SpiFlash_io1_io),
     .O(SpiFlash_io1_i),
     .T(SpiFlash_io1_t));
     IOBUF SpiFlash_io2_iobuf
     (.I(SpiFlash_io2_o),
     .IO(SpiFlash_io2_io),
     .O(SpiFlash_io2_i),
     .T(SpiFlash_io2_t));
     IOBUF SpiFlash_io3_iobuf
     (.I(SpiFlash_io3_o),
     .IO(SpiFlash_io3_io),
     .O(SpiFlash_io3_i),
     .T(SpiFlash_io3_t));
     OBUF SpiFlash_ss_iobuf_0
     (.I(SpiFlash_ss_o),
     .O(SpiFlash_ss_i));
     assign StartUpIo_cfgclk = 1'b0;
     assign StartUpIo_cfgmclk = 1'b0;
     assign StartUpIo_preq = 1'b0;
     wire axi_iic_clock_scl_o;
     wire axi_iic_clock_scl_t;
     wire axi_iic_clock_sda_o;
     wire axi_iic_clock_sda_t;
     wire iic_clock_gpio2o;
     axil_gpio #(
          .ALL_INPUT(0),
          .ALL_OUTPUT(0),
          .WIDTH(2),
          .DEFAULT_OUTPUT(32'h0),
          .DEFAULT_TRI(32'hFFFFFFFF),
          .ALL_INPUT_2(0),
          .ALL_OUTPUT_2(1),
          .WIDTH_2(1),
          .DEFAULT_OUTPUT_2(32'h0),
          .DEFAULT_TRI_2(32'hFFFFFFFF)
          ) axil_gpio_iic_clock (
          .gpio_i({CommunicationSelector_0_I2cSclIn_DatOut, CommunicationSelector_0_I2cSdaIn_DatOut}),
          .gpio_o({axi_iic_clock_scl_o, axi_iic_clock_sda_o}),
          .gpio_t({axi_iic_clock_scl_t, axi_iic_clock_sda_t}),
          .gpio2_i(32'b0),
          .gpio2_o(iic_clock_gpio2o),
          .s_axi_clk(SYS_M_AXI_ACLK),
          .s_axi_aresetn(SYS_M_AXI_ARESETN),
          .s_axi_araddr(xbar_sys_1_15_0_m_axi_12_ARADDR),
          .s_axi_arready(xbar_sys_1_15_0_m_axi_12_ARREADY),
          .s_axi_arvalid(xbar_sys_1_15_0_m_axi_12_ARVALID),
          .s_axi_awaddr(xbar_sys_1_15_0_m_axi_12_AWADDR),
          .s_axi_awready(xbar_sys_1_15_0_m_axi_12_AWREADY),
          .s_axi_awvalid(xbar_sys_1_15_0_m_axi_12_AWVALID),
          .s_axi_bready(xbar_sys_1_15_0_m_axi_12_BREADY),
          .s_axi_bresp(xbar_sys_1_15_0_m_axi_12_BRESP),
          .s_axi_bvalid(xbar_sys_1_15_0_m_axi_12_BVALID),
          .s_axi_rdata(xbar_sys_1_15_0_m_axi_12_RDATA),
          .s_axi_rready(xbar_sys_1_15_0_m_axi_12_RREADY),
          .s_axi_rresp(xbar_sys_1_15_0_m_axi_12_RRESP),
          .s_axi_rvalid(xbar_sys_1_15_0_m_axi_12_RVALID),
          .s_axi_wdata(xbar_sys_1_15_0_m_axi_12_WDATA),
          .s_axi_wready(xbar_sys_1_15_0_m_axi_12_WREADY),
          .s_axi_wstrb(xbar_sys_1_15_0_m_axi_12_WSTRB),
          .s_axi_wvalid(xbar_sys_1_15_0_m_axi_12_WVALID));
     // bit bang QSPI Flash
     wire qspi_gpio2o;
     axil_gpio #(
          .ALL_INPUT(0),
          .ALL_OUTPUT(0),
          .WIDTH(5),
          .DEFAULT_OUTPUT(32'hFFFFFFFF),
          .DEFAULT_TRI(32'hFFFFFFFF),
          .ALL_INPUT_2(0),
          .ALL_OUTPUT_2(1),
          .WIDTH_2(1),
          .DEFAULT_OUTPUT_2(32'h0),
          .DEFAULT_TRI_2(32'hFFFFFFFF)
          ) axil_gpio_qspi (
          .gpio_i({               SpiFlash_io3_i, SpiFlash_io2_i, SpiFlash_io1_i, SpiFlash_io0_i}),
          .gpio_o({SpiFlash_ss_o, SpiFlash_io3_o, SpiFlash_io2_o, SpiFlash_io1_o, SpiFlash_io0_o}),
          .gpio_t({               SpiFlash_io3_t, SpiFlash_io2_t, SpiFlash_io1_t, SpiFlash_io0_t}),
          .gpio2_i(32'b0),
          .gpio2_o(qspi_gpio2o),
          .s_axi_clk(SYS_M_AXI_ACLK),
          .s_axi_aresetn(SYS_M_AXI_ARESETN),
          .s_axi_araddr(xbar_sys_1_15_0_m_axi_15_ARADDR),
          .s_axi_arready(xbar_sys_1_15_0_m_axi_15_ARREADY),
          .s_axi_arvalid(xbar_sys_1_15_0_m_axi_15_ARVALID),
          .s_axi_awaddr(xbar_sys_1_15_0_m_axi_15_AWADDR),
          .s_axi_awready(xbar_sys_1_15_0_m_axi_15_AWREADY),
          .s_axi_awvalid(xbar_sys_1_15_0_m_axi_15_AWVALID),
          .s_axi_bready(xbar_sys_1_15_0_m_axi_15_BREADY),
          .s_axi_bresp(xbar_sys_1_15_0_m_axi_15_BRESP),
          .s_axi_bvalid(xbar_sys_1_15_0_m_axi_15_BVALID),
          .s_axi_rdata(xbar_sys_1_15_0_m_axi_15_RDATA),
          .s_axi_rready(xbar_sys_1_15_0_m_axi_15_RREADY),
          .s_axi_rresp(xbar_sys_1_15_0_m_axi_15_RRESP),
          .s_axi_rvalid(xbar_sys_1_15_0_m_axi_15_RVALID),
          .s_axi_wdata(xbar_sys_1_15_0_m_axi_15_WDATA),
          .s_axi_wready(xbar_sys_1_15_0_m_axi_15_WREADY),
          .s_axi_wstrb(xbar_sys_1_15_0_m_axi_15_WSTRB),
          .s_axi_wvalid(xbar_sys_1_15_0_m_axi_15_WVALID));
     wire axi_uart16550_ext_ip2intc_irpt;
     wire axi_uart16550_ext_sout;
     wire axi_uart16550_gnss1_ip2intc_irpt;
     wire axi_uart16550_gnss1_sout;
     wire axi_uart16550_gnss2_ip2intc_irpt;
     wire axi_uart16550_gnss2_sout;
     wire axi_uart16550_mac_ip2intc_irpt;
     wire axi_uart16550_mac_sout;
     // 4 UARTs
     // TX/RX "external", connected to SMA, unused
     axi_uart16550 #(
          .CLOCK_FREQ(50000000),
          .LENDIAN(1)
          ) uart16550_ext (
          .s_axi_clk(SYS_M_AXI_ACLK),
          .s_axi_araddr(xbar_sys_1_15_0_m_axi_11_ARADDR[12:0]),
          .s_axi_aresetn(SYS_M_AXI_ARESETN),
          .s_axi_arready(xbar_sys_1_15_0_m_axi_11_ARREADY),
          .s_axi_arvalid(xbar_sys_1_15_0_m_axi_11_ARVALID),
          .s_axi_awaddr(xbar_sys_1_15_0_m_axi_11_AWADDR[12:0]),
          .s_axi_awready(xbar_sys_1_15_0_m_axi_11_AWREADY),
          .s_axi_awvalid(xbar_sys_1_15_0_m_axi_11_AWVALID),
          .s_axi_bready(xbar_sys_1_15_0_m_axi_11_BREADY),
          .s_axi_bresp(xbar_sys_1_15_0_m_axi_11_BRESP),
          .s_axi_bvalid(xbar_sys_1_15_0_m_axi_11_BVALID),
          .s_axi_rdata(xbar_sys_1_15_0_m_axi_11_RDATA),
          .s_axi_rready(xbar_sys_1_15_0_m_axi_11_RREADY),
          .s_axi_rresp(xbar_sys_1_15_0_m_axi_11_RRESP),
          .s_axi_rvalid(xbar_sys_1_15_0_m_axi_11_RVALID),
          .s_axi_wdata(xbar_sys_1_15_0_m_axi_11_WDATA),
          .s_axi_wready(xbar_sys_1_15_0_m_axi_11_WREADY),
          .s_axi_wstrb(xbar_sys_1_15_0_m_axi_11_WSTRB),
          .s_axi_wvalid(xbar_sys_1_15_0_m_axi_11_WVALID),
          .rx(SmaSelector_v_0_SmaUartExtSource_DatOut),
          .tx(axi_uart16550_ext_sout),
          .irq(axi_uart16550_ext_ip2intc_irpt));
     // Mainly used GNSS1 UART
     axi_uart16550 #(
          .CLOCK_FREQ(50000000),
          .LENDIAN(1)
          ) uart16550_gnss1 (
          .s_axi_clk(SYS_M_AXI_ACLK),
          .s_axi_araddr(xbar_sys_1_15_0_m_axi_7_ARADDR[12:0]),
          .s_axi_aresetn(SYS_M_AXI_ARESETN),
          .s_axi_arready(xbar_sys_1_15_0_m_axi_7_ARREADY),
          .s_axi_arvalid(xbar_sys_1_15_0_m_axi_7_ARVALID),
          .s_axi_awaddr(xbar_sys_1_15_0_m_axi_7_AWADDR[12:0]),
          .s_axi_awready(xbar_sys_1_15_0_m_axi_7_AWREADY),
          .s_axi_awvalid(xbar_sys_1_15_0_m_axi_7_AWVALID),
          .s_axi_bready(xbar_sys_1_15_0_m_axi_7_BREADY),
          .s_axi_bresp(xbar_sys_1_15_0_m_axi_7_BRESP),
          .s_axi_bvalid(xbar_sys_1_15_0_m_axi_7_BVALID),
          .s_axi_rdata(xbar_sys_1_15_0_m_axi_7_RDATA),
          .s_axi_rready(xbar_sys_1_15_0_m_axi_7_RREADY),
          .s_axi_rresp(xbar_sys_1_15_0_m_axi_7_RRESP),
          .s_axi_rvalid(xbar_sys_1_15_0_m_axi_7_RVALID),
          .s_axi_wdata(xbar_sys_1_15_0_m_axi_7_WDATA),
          .s_axi_wready(xbar_sys_1_15_0_m_axi_7_WREADY),
          .s_axi_wstrb(xbar_sys_1_15_0_m_axi_7_WSTRB),
          .s_axi_wvalid(xbar_sys_1_15_0_m_axi_7_WVALID),
          .rx(UartGnss1Rx_DatIn),
          .tx(UartGnss1Tx_DatOut),
          .irq(axi_uart16550_gnss1_ip2intc_irpt));
     // Unused GNSS2 UART
     axi_uart16550 #(
          .CLOCK_FREQ(50000000),
          .LENDIAN(1)
          ) uart16550_gnss2 (
          .s_axi_clk(SYS_M_AXI_ACLK),
          .s_axi_araddr(xbar_sys_1_15_0_m_axi_8_ARADDR),
          .s_axi_aresetn(SYS_M_AXI_ARESETN),
          .s_axi_arready(xbar_sys_1_15_0_m_axi_8_ARREADY),
          .s_axi_arvalid(xbar_sys_1_15_0_m_axi_8_ARVALID),
          .s_axi_awaddr(xbar_sys_1_15_0_m_axi_8_AWADDR[12:0]),
          .s_axi_awready(xbar_sys_1_15_0_m_axi_8_AWREADY),
          .s_axi_awvalid(xbar_sys_1_15_0_m_axi_8_AWVALID),
          .s_axi_bready(xbar_sys_1_15_0_m_axi_8_BREADY),
          .s_axi_bresp(xbar_sys_1_15_0_m_axi_8_BRESP),
          .s_axi_bvalid(xbar_sys_1_15_0_m_axi_8_BVALID),
          .s_axi_rdata(xbar_sys_1_15_0_m_axi_8_RDATA),
          .s_axi_rready(xbar_sys_1_15_0_m_axi_8_RREADY),
          .s_axi_rresp(xbar_sys_1_15_0_m_axi_8_RRESP),
          .s_axi_rvalid(xbar_sys_1_15_0_m_axi_8_RVALID),
          .s_axi_wdata(xbar_sys_1_15_0_m_axi_8_WDATA),
          .s_axi_wready(xbar_sys_1_15_0_m_axi_8_WREADY),
          .s_axi_wstrb(xbar_sys_1_15_0_m_axi_8_WSTRB),
          .s_axi_wvalid(xbar_sys_1_15_0_m_axi_8_WVALID),
          .rx(UartGnss2Rx_DatIn),
          .tx(UartGnss2Tx_DatOut),
          .irq(axi_uart16550_gnss2_ip2intc_irpt));
     // Unused MAC UART, connected to CommunicationSelector
     axi_uart16550 #(
          .CLOCK_FREQ(50000000),
          .LENDIAN(1)
          ) uart16550_mac (
          .s_axi_clk(SYS_M_AXI_ACLK),
          .s_axi_aresetn(SYS_M_AXI_ARESETN),
          .s_axi_araddr(xbar_sys_1_15_0_m_axi_9_ARADDR),
          .s_axi_arready(xbar_sys_1_15_0_m_axi_9_ARREADY),
          .s_axi_arvalid(xbar_sys_1_15_0_m_axi_9_ARVALID),
          .s_axi_awaddr(xbar_sys_1_15_0_m_axi_9_AWADDR),
          .s_axi_awready(xbar_sys_1_15_0_m_axi_9_AWREADY),
          .s_axi_awvalid(xbar_sys_1_15_0_m_axi_9_AWVALID),
          .s_axi_bready(xbar_sys_1_15_0_m_axi_9_BREADY),
          .s_axi_bresp(xbar_sys_1_15_0_m_axi_9_BRESP),
          .s_axi_bvalid(xbar_sys_1_15_0_m_axi_9_BVALID),
          .s_axi_rdata(xbar_sys_1_15_0_m_axi_9_RDATA),
          .s_axi_rready(xbar_sys_1_15_0_m_axi_9_RREADY),
          .s_axi_rresp(xbar_sys_1_15_0_m_axi_9_RRESP),
          .s_axi_rvalid(xbar_sys_1_15_0_m_axi_9_RVALID),
          .s_axi_wdata(xbar_sys_1_15_0_m_axi_9_WDATA),
          .s_axi_wready(xbar_sys_1_15_0_m_axi_9_WREADY),
          .s_axi_wstrb(xbar_sys_1_15_0_m_axi_9_WSTRB),
          .s_axi_wvalid(xbar_sys_1_15_0_m_axi_9_WVALID),
          .rx(CommunicationSelector_0_UartRx_DatOut),
          .tx(axi_uart16550_mac_sout),
          .irq(axi_uart16550_mac_ip2intc_irpt));
     // 2 GPIOs
     // GPIOs for MAC/GNSS reset and aux signals, most pins unused
     wire [31:0]ext_gpio2o;
     axil_gpio #(
          .ALL_INPUT(1),
          .ALL_OUTPUT(0),
          .WIDTH(2),
          .DEFAULT_OUTPUT(32'h0),
          .DEFAULT_TRI(32'hFFFFFFFF),
          .ALL_INPUT_2(0),
          .ALL_OUTPUT_2(1),
          .WIDTH_2(32),
          .DEFAULT_OUTPUT_2(32'h0),
          .DEFAULT_TRI_2(32'hFFFFFFFF)
          ) axil_gpio_ext (
          .gpio_i(Ext_DatIn),
          .gpio2_i(32'b0),
          .gpio2_o(ext_gpio2o),
          .s_axi_clk(SYS_M_AXI_ACLK),
          .s_axi_araddr(xbar_sys_1_15_0_m_axi_2_ARADDR),
          .s_axi_aresetn(SYS_M_AXI_ARESETN),
          .s_axi_arready(xbar_sys_1_15_0_m_axi_2_ARREADY),
          .s_axi_arvalid(xbar_sys_1_15_0_m_axi_2_ARVALID),
          .s_axi_awaddr(xbar_sys_1_15_0_m_axi_2_AWADDR),
          .s_axi_awready(xbar_sys_1_15_0_m_axi_2_AWREADY),
          .s_axi_awvalid(xbar_sys_1_15_0_m_axi_2_AWVALID),
          .s_axi_bready(xbar_sys_1_15_0_m_axi_2_BREADY),
          .s_axi_bresp(xbar_sys_1_15_0_m_axi_2_BRESP),
          .s_axi_bvalid(xbar_sys_1_15_0_m_axi_2_BVALID),
          .s_axi_rdata(xbar_sys_1_15_0_m_axi_2_RDATA),
          .s_axi_rready(xbar_sys_1_15_0_m_axi_2_RREADY),
          .s_axi_rresp(xbar_sys_1_15_0_m_axi_2_RRESP),
          .s_axi_rvalid(xbar_sys_1_15_0_m_axi_2_RVALID),
          .s_axi_wdata(xbar_sys_1_15_0_m_axi_2_WDATA),
          .s_axi_wready(xbar_sys_1_15_0_m_axi_2_WREADY),
          .s_axi_wstrb(xbar_sys_1_15_0_m_axi_2_WSTRB),
          .s_axi_wvalid(xbar_sys_1_15_0_m_axi_2_WVALID));
     wire [1:0]gnssmac_gpio2o;
     axil_gpio #(
          .ALL_INPUT(1),
          .ALL_OUTPUT(0),
          .WIDTH(2),
          .DEFAULT_OUTPUT(32'h0),
          .DEFAULT_TRI(32'hFFFFFFFF),
          .ALL_INPUT_2(0),
          .ALL_OUTPUT_2(1),
          .WIDTH_2(2),
          .DEFAULT_OUTPUT_2(32'h0),
          .DEFAULT_TRI_2(32'hFFFFFFFF)
          ) axil_gpio_gnssmac (
          .gpio_i(GpioMac_DatIn),
          .gpio2_i(2'b0),
          .gpio2_o(gnssmac_gpio2o),
          .s_axi_clk(SYS_M_AXI_ACLK),
          .s_axi_aresetn(SYS_M_AXI_ARESETN),
          .s_axi_araddr(xbar_sys_1_15_0_m_axi_3_ARADDR),
          .s_axi_arready(xbar_sys_1_15_0_m_axi_3_ARREADY),
          .s_axi_arvalid(xbar_sys_1_15_0_m_axi_3_ARVALID),
          .s_axi_awaddr(xbar_sys_1_15_0_m_axi_3_AWADDR),
          .s_axi_awready(xbar_sys_1_15_0_m_axi_3_AWREADY),
          .s_axi_awvalid(xbar_sys_1_15_0_m_axi_3_AWVALID),
          .s_axi_bready(xbar_sys_1_15_0_m_axi_3_BREADY),
          .s_axi_bresp(xbar_sys_1_15_0_m_axi_3_BRESP),
          .s_axi_bvalid(xbar_sys_1_15_0_m_axi_3_BVALID),
          .s_axi_rdata(xbar_sys_1_15_0_m_axi_3_RDATA),
          .s_axi_rready(xbar_sys_1_15_0_m_axi_3_RREADY),
          .s_axi_rresp(xbar_sys_1_15_0_m_axi_3_RRESP),
          .s_axi_rvalid(xbar_sys_1_15_0_m_axi_3_RVALID),
          .s_axi_wdata(xbar_sys_1_15_0_m_axi_3_WDATA),
          .s_axi_wready(xbar_sys_1_15_0_m_axi_3_WREADY),
          .s_axi_wstrb(xbar_sys_1_15_0_m_axi_3_WSTRB),
          .s_axi_wvalid(xbar_sys_1_15_0_m_axi_3_WVALID));

     // PCIe AXI memory mapped host and MSI interrupt
     wire [31:0]pcie_m_axi_ARADDR;
     wire pcie_m_axi_ARREADY;
     wire pcie_m_axi_ARVALID;
     wire [31:0]pcie_m_axi_AWADDR;
     wire pcie_m_axi_AWREADY;
     wire pcie_m_axi_AWVALID;
     wire pcie_m_axi_BREADY;
     wire [1:0]pcie_m_axi_BRESP;
     wire pcie_m_axi_BVALID;
     wire [31:0]pcie_m_axi_RDATA;
     wire pcie_m_axi_RREADY;
     wire [1:0]pcie_m_axi_RRESP;
     wire pcie_m_axi_RVALID;
     wire [31:0]pcie_m_axi_WDATA;
     wire pcie_m_axi_WREADY;
     wire [3:0]pcie_m_axi_WSTRB;
     wire pcie_m_axi_WVALID;
     wire MsiIrqEnable_EnIn;
     wire [2:0]MsiVectorWidth_DatIn;
     wire MsiGrant_ValIn;
     wire MsiReq_ValOut;
     wire [4:0]MsiVectorNum_DatOut;
     pcie_7x_aximm_msi_bd pcie_7x_aximm_msi_bd_0 (
          .m_axi_clk(PCIE_M_AXI_ACLK),
          .m_axi_aresetn(PCIE_M_AXI_ARESETN),
          .m_axi_araddr(pcie_m_axi_ARADDR),
          .m_axi_arready(pcie_m_axi_ARREADY),
          .m_axi_arvalid(pcie_m_axi_ARVALID),
          .m_axi_awaddr(pcie_m_axi_AWADDR),
          .m_axi_awready(pcie_m_axi_AWREADY),
          .m_axi_awvalid(pcie_m_axi_AWVALID),
          .m_axi_bready(pcie_m_axi_BREADY),
          .m_axi_bresp(pcie_m_axi_BRESP),
          .m_axi_bvalid(pcie_m_axi_BVALID),
          .m_axi_rdata(pcie_m_axi_RDATA),
          .m_axi_rready(pcie_m_axi_RREADY),
          .m_axi_rresp(pcie_m_axi_RRESP),
          .m_axi_rvalid(pcie_m_axi_RVALID),
          .m_axi_wdata(pcie_m_axi_WDATA),
          .m_axi_wready(pcie_m_axi_WREADY),
          .m_axi_wstrb(pcie_m_axi_WSTRB),
          .m_axi_wvalid(pcie_m_axi_WVALID),
          .intx_msi_grant(MsiGrant_ValIn),
          .intx_msi_request(MsiReq_ValOut),
          .msi_enable(MsiIrqEnable_EnIn),
          .msi_vector_num(MsiVectorNum_DatOut),
          .msi_vector_width(MsiVectorWidth_DatIn),
          .refclk(PcieRefClock),
          .sys_rst_n(PciePerstN_RstIn),
          .pci_exp_rxn(pcie_7x_mgt_0_rxn),
          .pci_exp_rxp(pcie_7x_mgt_0_rxp),
          .pci_exp_txn(pcie_7x_mgt_0_txn),
          .pci_exp_txp(pcie_7x_mgt_0_txp));
     MsiIrq #(
          .NumberOfInterrupts_Gen(20),
          .LevelInterrupt_Gen(32'h000E05B8)
          ) MsiIrq_0 (
          .SysClk_ClkIn(PCIE_M_AXI_ACLK),
          .SysRstN_RstIn(PCIE_M_AXI_ARESETN),
          .MsiGrant_ValIn(MsiGrant_ValIn),
          .MsiIrqEnable_EnIn(MsiIrqEnable_EnIn),
          .MsiReq_ValOut(MsiReq_ValOut),
          .MsiVectorNum_DatOut(MsiVectorNum_DatOut),
          .MsiVectorWidth_DatIn(MsiVectorWidth_DatIn),
          .IrqIn0_DatIn(Timestamper_FpgaPps_Irq_EvtOut),
          .IrqIn1_DatIn(Timestamper_Gnss1Pps_Irq_EvtOut),
          .IrqIn2_DatIn(Timestamper_0_Irq_EvtOut),
          .IrqIn3_DatIn(axi_uart16550_gnss1_ip2intc_irpt),
          .IrqIn4_DatIn(axi_uart16550_gnss2_ip2intc_irpt),
          .IrqIn5_DatIn(CommunicationSelector_0_Irq_DatOut),
          .IrqIn6_DatIn(Timestamper_1_Irq_EvtOut),
          .IrqIn7_DatIn(iic_gpio2o), // axi i2c
          .IrqIn8_DatIn(1'b0),
          .IrqIn9_DatIn(qspi_gpio2o),
          .IrqIn10_DatIn(1'b0),
          .IrqIn11_DatIn(SignalGenerator_v_0_Irq_EvtOut),
          .IrqIn12_DatIn(SignalGenerator_v_1_Irq_EvtOut),
          .IrqIn13_DatIn(SignalGenerator_v_2_Irq_EvtOut),
          .IrqIn14_DatIn(SignalGenerator_v_3_Irq_EvtOut),
          .IrqIn15_DatIn(Timestamper_2_Irq_EvtOut),
          .IrqIn16_DatIn(Timestamper_3_Irq_EvtOut),
          .IrqIn17_DatIn(1'b0),
          .IrqIn18_DatIn(1'b0),
          .IrqIn19_DatIn(axi_uart16550_ext_ip2intc_irpt),
          .IrqIn20_DatIn(1'b0),
          .IrqIn21_DatIn(1'b0),
          .IrqIn22_DatIn(1'b0),
          .IrqIn23_DatIn(1'b0),
          .IrqIn24_DatIn(1'b0),
          .IrqIn25_DatIn(1'b0),
          .IrqIn26_DatIn(1'b0),
          .IrqIn27_DatIn(1'b0),
          .IrqIn28_DatIn(1'b0),
          .IrqIn29_DatIn(1'b0),
          .IrqIn30_DatIn(1'b0),
          .IrqIn31_DatIn(1'b0));
     wire PcieRefClock;
     IBUFDS_GTE2 IBUFDS_GTE2_PCIe (
          .I(PcieRefClockP[0]),
          .IB(PcieRefClockN[0]),
          .O(PcieRefClock),
          .ODIV2(),
          .CEB(1'b0));
     wire Mhz10ClkSma_ClkIn_BufgCe;
     BUFGCE BUFGCE_Mhz10ClkSma_ClkIn1 (
          .I(Mhz10ClkSma_ClkIn),
          .CE(SmaSelector_v_0_Sma10MHzSourceEnable_EnOut),
          .O(Mhz10ClkSma_ClkIn_BufgCe));

     // AXI infrastructures, clock domain crossing and interconnects
     wire [31:0]axixclk_al2al_0_M_AXI_ARADDR;
     wire axixclk_al2al_0_M_AXI_ARESETN;
     wire [2:0]axixclk_al2al_0_M_AXI_ARPROT;
     wire axixclk_al2al_0_M_AXI_ARREADY;
     wire axixclk_al2al_0_M_AXI_ARVALID;
     wire [31:0]axixclk_al2al_0_M_AXI_AWADDR;
     wire [2:0]axixclk_al2al_0_M_AXI_AWPROT;
     wire axixclk_al2al_0_M_AXI_AWREADY;
     wire axixclk_al2al_0_M_AXI_AWVALID;
     wire axixclk_al2al_0_M_AXI_BREADY;
     wire [1:0]axixclk_al2al_0_M_AXI_BRESP;
     wire axixclk_al2al_0_M_AXI_BVALID;
     wire [31:0]axixclk_al2al_0_M_AXI_RDATA;
     wire axixclk_al2al_0_M_AXI_RREADY;
     wire [1:0]axixclk_al2al_0_M_AXI_RRESP;
     wire axixclk_al2al_0_M_AXI_RVALID;
     wire [31:0]axixclk_al2al_0_M_AXI_WDATA;
     wire axixclk_al2al_0_M_AXI_WREADY;
     wire [3:0]axixclk_al2al_0_M_AXI_WSTRB;
     wire axixclk_al2al_0_M_AXI_WVALID;
     axixclk_al2al /* all default settings */ axixclk_PTP_SYS (
          .S_AXI_ACLK(PTP_M_AXI_ACLK),
          .S_AXI_ARESETN(SYS_M_AXI_ARESETN),
          .S_AXI_ARADDR(xbar_2_2_0_m_axi_1_ARADDR),
          .S_AXI_ARPROT(xbar_2_2_0_m_axi_1_ARPROT),
          .S_AXI_ARREADY(xbar_2_2_0_m_axi_1_ARREADY),
          .S_AXI_ARVALID(xbar_2_2_0_m_axi_1_ARVALID),
          .S_AXI_AWADDR(xbar_2_2_0_m_axi_1_AWADDR),
          .S_AXI_AWPROT(xbar_2_2_0_m_axi_1_AWPROT),
          .S_AXI_AWREADY(xbar_2_2_0_m_axi_1_AWREADY),
          .S_AXI_AWVALID(xbar_2_2_0_m_axi_1_AWVALID),
          .S_AXI_BREADY(xbar_2_2_0_m_axi_1_BREADY),
          .S_AXI_BRESP(xbar_2_2_0_m_axi_1_BRESP),
          .S_AXI_BVALID(xbar_2_2_0_m_axi_1_BVALID),
          .S_AXI_RDATA(xbar_2_2_0_m_axi_1_RDATA),
          .S_AXI_RREADY(xbar_2_2_0_m_axi_1_RREADY),
          .S_AXI_RRESP(xbar_2_2_0_m_axi_1_RRESP),
          .S_AXI_RVALID(xbar_2_2_0_m_axi_1_RVALID),
          .S_AXI_WDATA(xbar_2_2_0_m_axi_1_WDATA),
          .S_AXI_WREADY(xbar_2_2_0_m_axi_1_WREADY),
          .S_AXI_WSTRB(xbar_2_2_0_m_axi_1_WSTRB),
          .S_AXI_WVALID(xbar_2_2_0_m_axi_1_WVALID),
          .M_AXI_ACLK(SYS_M_AXI_ACLK),
          .M_AXI_ARESETN(axixclk_al2al_0_M_AXI_ARESETN),
          .M_AXI_ARADDR(axixclk_al2al_0_M_AXI_ARADDR),
          .M_AXI_ARPROT(axixclk_al2al_0_M_AXI_ARPROT),
          .M_AXI_ARREADY(axixclk_al2al_0_M_AXI_ARREADY),
          .M_AXI_ARVALID(axixclk_al2al_0_M_AXI_ARVALID),
          .M_AXI_AWADDR(axixclk_al2al_0_M_AXI_AWADDR),
          .M_AXI_AWPROT(axixclk_al2al_0_M_AXI_AWPROT),
          .M_AXI_AWREADY(axixclk_al2al_0_M_AXI_AWREADY),
          .M_AXI_AWVALID(axixclk_al2al_0_M_AXI_AWVALID),
          .M_AXI_BREADY(axixclk_al2al_0_M_AXI_BREADY),
          .M_AXI_BRESP(axixclk_al2al_0_M_AXI_BRESP),
          .M_AXI_BVALID(axixclk_al2al_0_M_AXI_BVALID),
          .M_AXI_RDATA(axixclk_al2al_0_M_AXI_RDATA),
          .M_AXI_RREADY(axixclk_al2al_0_M_AXI_RREADY),
          .M_AXI_RRESP(axixclk_al2al_0_M_AXI_RRESP),
          .M_AXI_RVALID(axixclk_al2al_0_M_AXI_RVALID),
          .M_AXI_WDATA(axixclk_al2al_0_M_AXI_WDATA),
          .M_AXI_WREADY(axixclk_al2al_0_M_AXI_WREADY),
          .M_AXI_WSTRB(axixclk_al2al_0_M_AXI_WSTRB),
          .M_AXI_WVALID(axixclk_al2al_0_M_AXI_WVALID));
     wire [31:0]axixclk_al2al_1_M_AXI_ARADDR;
     wire [2:0]axixclk_al2al_1_M_AXI_ARPROT;
     wire axixclk_al2al_1_M_AXI_ARREADY;
     wire axixclk_al2al_1_M_AXI_ARVALID;
     wire [31:0]axixclk_al2al_1_M_AXI_AWADDR;
     wire [2:0]axixclk_al2al_1_M_AXI_AWPROT;
     wire axixclk_al2al_1_M_AXI_AWREADY;
     wire axixclk_al2al_1_M_AXI_AWVALID;
     wire axixclk_al2al_1_M_AXI_BREADY;
     wire [1:0]axixclk_al2al_1_M_AXI_BRESP;
     wire axixclk_al2al_1_M_AXI_BVALID;
     wire [31:0]axixclk_al2al_1_M_AXI_RDATA;
     wire axixclk_al2al_1_M_AXI_RREADY;
     wire [1:0]axixclk_al2al_1_M_AXI_RRESP;
     wire axixclk_al2al_1_M_AXI_RVALID;
     wire [31:0]axixclk_al2al_1_M_AXI_WDATA;
     wire axixclk_al2al_1_M_AXI_WREADY;
     wire [3:0]axixclk_al2al_1_M_AXI_WSTRB;
     wire axixclk_al2al_1_M_AXI_WVALID;
     axixclk_al2al axixclk_PCIE_PTP (
          .S_AXI_ACLK(PCIE_M_AXI_ACLK),
          .S_AXI_ARESETN(PCIE_M_AXI_ARESETN),
          .S_AXI_ARADDR(pcie_m_axi_ARADDR),
          .S_AXI_ARPROT(3'b0),
          .S_AXI_ARREADY(pcie_m_axi_ARREADY),
          .S_AXI_ARVALID(pcie_m_axi_ARVALID),
          .S_AXI_AWADDR(pcie_m_axi_AWADDR),
          .S_AXI_AWPROT(3'b0),
          .S_AXI_AWREADY(pcie_m_axi_AWREADY),
          .S_AXI_AWVALID(pcie_m_axi_AWVALID),
          .S_AXI_BREADY(pcie_m_axi_BREADY),
          .S_AXI_BRESP(pcie_m_axi_BRESP),
          .S_AXI_BVALID(pcie_m_axi_BVALID),
          .S_AXI_RDATA(pcie_m_axi_RDATA),
          .S_AXI_RREADY(pcie_m_axi_RREADY),
          .S_AXI_RRESP(pcie_m_axi_RRESP),
          .S_AXI_RVALID(pcie_m_axi_RVALID),
          .S_AXI_WDATA(pcie_m_axi_WDATA),
          .S_AXI_WREADY(pcie_m_axi_WREADY),
          .S_AXI_WSTRB(pcie_m_axi_WSTRB),
          .S_AXI_WVALID(pcie_m_axi_WVALID),
          .M_AXI_ACLK(PTP_M_AXI_ACLK),
          .M_AXI_ARADDR(axixclk_al2al_1_M_AXI_ARADDR),
          .M_AXI_ARPROT(axixclk_al2al_1_M_AXI_ARPROT),
          .M_AXI_ARREADY(axixclk_al2al_1_M_AXI_ARREADY),
          .M_AXI_ARVALID(axixclk_al2al_1_M_AXI_ARVALID),
          .M_AXI_AWADDR(axixclk_al2al_1_M_AXI_AWADDR),
          .M_AXI_AWPROT(axixclk_al2al_1_M_AXI_AWPROT),
          .M_AXI_AWREADY(axixclk_al2al_1_M_AXI_AWREADY),
          .M_AXI_AWVALID(axixclk_al2al_1_M_AXI_AWVALID),
          .M_AXI_BREADY(axixclk_al2al_1_M_AXI_BREADY),
          .M_AXI_BRESP(axixclk_al2al_1_M_AXI_BRESP),
          .M_AXI_BVALID(axixclk_al2al_1_M_AXI_BVALID),
          .M_AXI_RDATA(axixclk_al2al_1_M_AXI_RDATA),
          .M_AXI_RREADY(axixclk_al2al_1_M_AXI_RREADY),
          .M_AXI_RRESP(axixclk_al2al_1_M_AXI_RRESP),
          .M_AXI_RVALID(axixclk_al2al_1_M_AXI_RVALID),
          .M_AXI_WDATA(axixclk_al2al_1_M_AXI_WDATA),
          .M_AXI_WREADY(axixclk_al2al_1_M_AXI_WREADY),
          .M_AXI_WSTRB(axixclk_al2al_1_M_AXI_WSTRB),
          .M_AXI_WVALID(axixclk_al2al_1_M_AXI_WVALID));
     // AXI XBARs
     wire [31:0]xbar_2_2_0_m_axi_0_ARADDR;
     wire [2:0]xbar_2_2_0_m_axi_0_ARPROT;
     wire xbar_2_2_0_m_axi_0_ARREADY;
     wire xbar_2_2_0_m_axi_0_ARVALID;
     wire [31:0]xbar_2_2_0_m_axi_0_AWADDR;
     wire [2:0]xbar_2_2_0_m_axi_0_AWPROT;
     wire xbar_2_2_0_m_axi_0_AWREADY;
     wire xbar_2_2_0_m_axi_0_AWVALID;
     wire xbar_2_2_0_m_axi_0_BREADY;
     wire [1:0]xbar_2_2_0_m_axi_0_BRESP;
     wire xbar_2_2_0_m_axi_0_BVALID;
     wire [31:0]xbar_2_2_0_m_axi_0_RDATA;
     wire xbar_2_2_0_m_axi_0_RREADY;
     wire [1:0]xbar_2_2_0_m_axi_0_RRESP;
     wire xbar_2_2_0_m_axi_0_RVALID;
     wire [31:0]xbar_2_2_0_m_axi_0_WDATA;
     wire xbar_2_2_0_m_axi_0_WREADY;
     wire [3:0]xbar_2_2_0_m_axi_0_WSTRB;
     wire xbar_2_2_0_m_axi_0_WVALID;
     wire [31:0]xbar_2_2_0_m_axi_1_ARADDR;
     wire [2:0]xbar_2_2_0_m_axi_1_ARPROT;
     wire xbar_2_2_0_m_axi_1_ARREADY;
     wire xbar_2_2_0_m_axi_1_ARVALID;
     wire [31:0]xbar_2_2_0_m_axi_1_AWADDR;
     wire [2:0]xbar_2_2_0_m_axi_1_AWPROT;
     wire xbar_2_2_0_m_axi_1_AWREADY;
     wire xbar_2_2_0_m_axi_1_AWVALID;
     wire xbar_2_2_0_m_axi_1_BREADY;
     wire [1:0]xbar_2_2_0_m_axi_1_BRESP;
     wire xbar_2_2_0_m_axi_1_BVALID;
     wire [31:0]xbar_2_2_0_m_axi_1_RDATA;
     wire xbar_2_2_0_m_axi_1_RREADY;
     wire [1:0]xbar_2_2_0_m_axi_1_RRESP;
     wire xbar_2_2_0_m_axi_1_RVALID;
     wire [31:0]xbar_2_2_0_m_axi_1_WDATA;
     wire xbar_2_2_0_m_axi_1_WREADY;
     wire [3:0]xbar_2_2_0_m_axi_1_WSTRB;
     wire xbar_2_2_0_m_axi_1_WVALID;
     xbar_2_2 xbar_2_2_0 (
          .S_AXI_ACLK(PTP_M_AXI_ACLK),
          .S_AXI_ARESETN(PTP_M_AXI_ARESETN),
          .S_AXI_0_ARADDR(axixclk_al2al_1_M_AXI_ARADDR),
          .S_AXI_0_ARPROT(axixclk_al2al_1_M_AXI_ARPROT),
          .S_AXI_0_ARREADY(axixclk_al2al_1_M_AXI_ARREADY),
          .S_AXI_0_ARVALID(axixclk_al2al_1_M_AXI_ARVALID),
          .S_AXI_0_AWADDR(axixclk_al2al_1_M_AXI_AWADDR),
          .S_AXI_0_AWPROT(axixclk_al2al_1_M_AXI_AWPROT),
          .S_AXI_0_AWREADY(axixclk_al2al_1_M_AXI_AWREADY),
          .S_AXI_0_AWVALID(axixclk_al2al_1_M_AXI_AWVALID),
          .S_AXI_0_BREADY(axixclk_al2al_1_M_AXI_BREADY),
          .S_AXI_0_BRESP(axixclk_al2al_1_M_AXI_BRESP),
          .S_AXI_0_BVALID(axixclk_al2al_1_M_AXI_BVALID),
          .S_AXI_0_RDATA(axixclk_al2al_1_M_AXI_RDATA),
          .S_AXI_0_RREADY(axixclk_al2al_1_M_AXI_RREADY),
          .S_AXI_0_RRESP(axixclk_al2al_1_M_AXI_RRESP),
          .S_AXI_0_RVALID(axixclk_al2al_1_M_AXI_RVALID),
          .S_AXI_0_WDATA(axixclk_al2al_1_M_AXI_WDATA),
          .S_AXI_0_WREADY(axixclk_al2al_1_M_AXI_WREADY),
          .S_AXI_0_WSTRB(axixclk_al2al_1_M_AXI_WSTRB),
          .S_AXI_0_WVALID(axixclk_al2al_1_M_AXI_WVALID),
          .S_AXI_1_ARADDR(ConfMaster_v_0_m_axi_ARADDR),
          .S_AXI_1_ARPROT(ConfMaster_v_0_m_axi_ARPROT),
          .S_AXI_1_ARREADY(ConfMaster_v_0_m_axi_ARREADY),
          .S_AXI_1_ARVALID(ConfMaster_v_0_m_axi_ARVALID),
          .S_AXI_1_AWADDR(ConfMaster_v_0_m_axi_AWADDR),
          .S_AXI_1_AWPROT(ConfMaster_v_0_m_axi_AWPROT),
          .S_AXI_1_AWREADY(ConfMaster_v_0_m_axi_AWREADY),
          .S_AXI_1_AWVALID(ConfMaster_v_0_m_axi_AWVALID),
          .S_AXI_1_BREADY(ConfMaster_v_0_m_axi_BREADY),
          .S_AXI_1_BRESP(ConfMaster_v_0_m_axi_BRESP),
          .S_AXI_1_BVALID(ConfMaster_v_0_m_axi_BVALID),
          .S_AXI_1_RDATA(ConfMaster_v_0_m_axi_RDATA),
          .S_AXI_1_RREADY(ConfMaster_v_0_m_axi_RREADY),
          .S_AXI_1_RRESP(ConfMaster_v_0_m_axi_RRESP),
          .S_AXI_1_RVALID(ConfMaster_v_0_m_axi_RVALID),
          .S_AXI_1_WDATA(ConfMaster_v_0_m_axi_WDATA),
          .S_AXI_1_WREADY(ConfMaster_v_0_m_axi_WREADY),
          .S_AXI_1_WSTRB(ConfMaster_v_0_m_axi_WSTRB),
          .S_AXI_1_WVALID(ConfMaster_v_0_m_axi_WVALID),
          .M_AXI_0_ARADDR(xbar_2_2_0_m_axi_0_ARADDR),
          .M_AXI_0_ARPROT(xbar_2_2_0_m_axi_0_ARPROT),
          .M_AXI_0_ARREADY(xbar_2_2_0_m_axi_0_ARREADY),
          .M_AXI_0_ARVALID(xbar_2_2_0_m_axi_0_ARVALID),
          .M_AXI_0_AWADDR(xbar_2_2_0_m_axi_0_AWADDR),
          .M_AXI_0_AWPROT(xbar_2_2_0_m_axi_0_AWPROT),
          .M_AXI_0_AWREADY(xbar_2_2_0_m_axi_0_AWREADY),
          .M_AXI_0_AWVALID(xbar_2_2_0_m_axi_0_AWVALID),
          .M_AXI_0_BREADY(xbar_2_2_0_m_axi_0_BREADY),
          .M_AXI_0_BRESP(xbar_2_2_0_m_axi_0_BRESP),
          .M_AXI_0_BVALID(xbar_2_2_0_m_axi_0_BVALID),
          .M_AXI_0_RDATA(xbar_2_2_0_m_axi_0_RDATA),
          .M_AXI_0_RREADY(xbar_2_2_0_m_axi_0_RREADY),
          .M_AXI_0_RRESP(xbar_2_2_0_m_axi_0_RRESP),
          .M_AXI_0_RVALID(xbar_2_2_0_m_axi_0_RVALID),
          .M_AXI_0_WDATA(xbar_2_2_0_m_axi_0_WDATA),
          .M_AXI_0_WREADY(xbar_2_2_0_m_axi_0_WREADY),
          .M_AXI_0_WSTRB(xbar_2_2_0_m_axi_0_WSTRB),
          .M_AXI_0_WVALID(xbar_2_2_0_m_axi_0_WVALID),
          .M_AXI_1_ARADDR(xbar_2_2_0_m_axi_1_ARADDR),
          .M_AXI_1_ARPROT(xbar_2_2_0_m_axi_1_ARPROT),
          .M_AXI_1_ARREADY(xbar_2_2_0_m_axi_1_ARREADY),
          .M_AXI_1_ARVALID(xbar_2_2_0_m_axi_1_ARVALID),
          .M_AXI_1_AWADDR(xbar_2_2_0_m_axi_1_AWADDR),
          .M_AXI_1_AWPROT(xbar_2_2_0_m_axi_1_AWPROT),
          .M_AXI_1_AWREADY(xbar_2_2_0_m_axi_1_AWREADY),
          .M_AXI_1_AWVALID(xbar_2_2_0_m_axi_1_AWVALID),
          .M_AXI_1_BREADY(xbar_2_2_0_m_axi_1_BREADY),
          .M_AXI_1_BRESP(xbar_2_2_0_m_axi_1_BRESP),
          .M_AXI_1_BVALID(xbar_2_2_0_m_axi_1_BVALID),
          .M_AXI_1_RDATA(xbar_2_2_0_m_axi_1_RDATA),
          .M_AXI_1_RREADY(xbar_2_2_0_m_axi_1_RREADY),
          .M_AXI_1_RRESP(xbar_2_2_0_m_axi_1_RRESP),
          .M_AXI_1_RVALID(xbar_2_2_0_m_axi_1_RVALID),
          .M_AXI_1_WDATA(xbar_2_2_0_m_axi_1_WDATA),
          .M_AXI_1_WREADY(xbar_2_2_0_m_axi_1_WREADY),
          .M_AXI_1_WSTRB(xbar_2_2_0_m_axi_1_WSTRB),
          .M_AXI_1_WVALID(xbar_2_2_0_m_axi_1_WVALID));
     wire [31:0]xbar_ptp_1_23_0_m_axi_0_ARADDR;
     wire [2:0]xbar_ptp_1_23_0_m_axi_0_ARPROT;
     wire xbar_ptp_1_23_0_m_axi_0_ARREADY;
     wire xbar_ptp_1_23_0_m_axi_0_ARVALID;
     wire [31:0]xbar_ptp_1_23_0_m_axi_0_AWADDR;
     wire [2:0]xbar_ptp_1_23_0_m_axi_0_AWPROT;
     wire xbar_ptp_1_23_0_m_axi_0_AWREADY;
     wire xbar_ptp_1_23_0_m_axi_0_AWVALID;
     wire xbar_ptp_1_23_0_m_axi_0_BREADY;
     wire [1:0]xbar_ptp_1_23_0_m_axi_0_BRESP;
     wire xbar_ptp_1_23_0_m_axi_0_BVALID;
     wire [31:0]xbar_ptp_1_23_0_m_axi_0_RDATA;
     wire xbar_ptp_1_23_0_m_axi_0_RREADY;
     wire [1:0]xbar_ptp_1_23_0_m_axi_0_RRESP;
     wire xbar_ptp_1_23_0_m_axi_0_RVALID;
     wire [31:0]xbar_ptp_1_23_0_m_axi_0_WDATA;
     wire xbar_ptp_1_23_0_m_axi_0_WREADY;
     wire [3:0]xbar_ptp_1_23_0_m_axi_0_WSTRB;
     wire xbar_ptp_1_23_0_m_axi_0_WVALID;
     wire [31:0]xbar_ptp_1_23_0_m_axi_10_ARADDR;
     wire [2:0]xbar_ptp_1_23_0_m_axi_10_ARPROT;
     wire xbar_ptp_1_23_0_m_axi_10_ARREADY;
     wire xbar_ptp_1_23_0_m_axi_10_ARVALID;
     wire [31:0]xbar_ptp_1_23_0_m_axi_10_AWADDR;
     wire [2:0]xbar_ptp_1_23_0_m_axi_10_AWPROT;
     wire xbar_ptp_1_23_0_m_axi_10_AWREADY;
     wire xbar_ptp_1_23_0_m_axi_10_AWVALID;
     wire xbar_ptp_1_23_0_m_axi_10_BREADY;
     wire [1:0]xbar_ptp_1_23_0_m_axi_10_BRESP;
     wire xbar_ptp_1_23_0_m_axi_10_BVALID;
     wire [31:0]xbar_ptp_1_23_0_m_axi_10_RDATA;
     wire xbar_ptp_1_23_0_m_axi_10_RREADY;
     wire [1:0]xbar_ptp_1_23_0_m_axi_10_RRESP;
     wire xbar_ptp_1_23_0_m_axi_10_RVALID;
     wire [31:0]xbar_ptp_1_23_0_m_axi_10_WDATA;
     wire xbar_ptp_1_23_0_m_axi_10_WREADY;
     wire [3:0]xbar_ptp_1_23_0_m_axi_10_WSTRB;
     wire xbar_ptp_1_23_0_m_axi_10_WVALID;
     wire [31:0]xbar_ptp_1_23_0_m_axi_11_ARADDR;
     wire [2:0]xbar_ptp_1_23_0_m_axi_11_ARPROT;
     wire xbar_ptp_1_23_0_m_axi_11_ARREADY;
     wire xbar_ptp_1_23_0_m_axi_11_ARVALID;
     wire [31:0]xbar_ptp_1_23_0_m_axi_11_AWADDR;
     wire [2:0]xbar_ptp_1_23_0_m_axi_11_AWPROT;
     wire xbar_ptp_1_23_0_m_axi_11_AWREADY;
     wire xbar_ptp_1_23_0_m_axi_11_AWVALID;
     wire xbar_ptp_1_23_0_m_axi_11_BREADY;
     wire [1:0]xbar_ptp_1_23_0_m_axi_11_BRESP;
     wire xbar_ptp_1_23_0_m_axi_11_BVALID;
     wire [31:0]xbar_ptp_1_23_0_m_axi_11_RDATA;
     wire xbar_ptp_1_23_0_m_axi_11_RREADY;
     wire [1:0]xbar_ptp_1_23_0_m_axi_11_RRESP;
     wire xbar_ptp_1_23_0_m_axi_11_RVALID;
     wire [31:0]xbar_ptp_1_23_0_m_axi_11_WDATA;
     wire xbar_ptp_1_23_0_m_axi_11_WREADY;
     wire [3:0]xbar_ptp_1_23_0_m_axi_11_WSTRB;
     wire xbar_ptp_1_23_0_m_axi_11_WVALID;
     wire [31:0]xbar_ptp_1_23_0_m_axi_12_ARADDR;
     wire [2:0]xbar_ptp_1_23_0_m_axi_12_ARPROT;
     wire xbar_ptp_1_23_0_m_axi_12_ARREADY;
     wire xbar_ptp_1_23_0_m_axi_12_ARVALID;
     wire [31:0]xbar_ptp_1_23_0_m_axi_12_AWADDR;
     wire [2:0]xbar_ptp_1_23_0_m_axi_12_AWPROT;
     wire xbar_ptp_1_23_0_m_axi_12_AWREADY;
     wire xbar_ptp_1_23_0_m_axi_12_AWVALID;
     wire xbar_ptp_1_23_0_m_axi_12_BREADY;
     wire [1:0]xbar_ptp_1_23_0_m_axi_12_BRESP;
     wire xbar_ptp_1_23_0_m_axi_12_BVALID;
     wire [31:0]xbar_ptp_1_23_0_m_axi_12_RDATA;
     wire xbar_ptp_1_23_0_m_axi_12_RREADY;
     wire [1:0]xbar_ptp_1_23_0_m_axi_12_RRESP;
     wire xbar_ptp_1_23_0_m_axi_12_RVALID;
     wire [31:0]xbar_ptp_1_23_0_m_axi_12_WDATA;
     wire xbar_ptp_1_23_0_m_axi_12_WREADY;
     wire [3:0]xbar_ptp_1_23_0_m_axi_12_WSTRB;
     wire xbar_ptp_1_23_0_m_axi_12_WVALID;
     wire [31:0]xbar_ptp_1_23_0_m_axi_13_ARADDR;
     wire [2:0]xbar_ptp_1_23_0_m_axi_13_ARPROT;
     wire xbar_ptp_1_23_0_m_axi_13_ARREADY;
     wire xbar_ptp_1_23_0_m_axi_13_ARVALID;
     wire [31:0]xbar_ptp_1_23_0_m_axi_13_AWADDR;
     wire [2:0]xbar_ptp_1_23_0_m_axi_13_AWPROT;
     wire xbar_ptp_1_23_0_m_axi_13_AWREADY;
     wire xbar_ptp_1_23_0_m_axi_13_AWVALID;
     wire xbar_ptp_1_23_0_m_axi_13_BREADY;
     wire [1:0]xbar_ptp_1_23_0_m_axi_13_BRESP;
     wire xbar_ptp_1_23_0_m_axi_13_BVALID;
     wire [31:0]xbar_ptp_1_23_0_m_axi_13_RDATA;
     wire xbar_ptp_1_23_0_m_axi_13_RREADY;
     wire [1:0]xbar_ptp_1_23_0_m_axi_13_RRESP;
     wire xbar_ptp_1_23_0_m_axi_13_RVALID;
     wire [31:0]xbar_ptp_1_23_0_m_axi_13_WDATA;
     wire xbar_ptp_1_23_0_m_axi_13_WREADY;
     wire [3:0]xbar_ptp_1_23_0_m_axi_13_WSTRB;
     wire xbar_ptp_1_23_0_m_axi_13_WVALID;
     wire [31:0]xbar_ptp_1_23_0_m_axi_14_ARADDR;
     wire [2:0]xbar_ptp_1_23_0_m_axi_14_ARPROT;
     wire xbar_ptp_1_23_0_m_axi_14_ARREADY;
     wire xbar_ptp_1_23_0_m_axi_14_ARVALID;
     wire [31:0]xbar_ptp_1_23_0_m_axi_14_AWADDR;
     wire [2:0]xbar_ptp_1_23_0_m_axi_14_AWPROT;
     wire xbar_ptp_1_23_0_m_axi_14_AWREADY;
     wire xbar_ptp_1_23_0_m_axi_14_AWVALID;
     wire xbar_ptp_1_23_0_m_axi_14_BREADY;
     wire [1:0]xbar_ptp_1_23_0_m_axi_14_BRESP;
     wire xbar_ptp_1_23_0_m_axi_14_BVALID;
     wire [31:0]xbar_ptp_1_23_0_m_axi_14_RDATA;
     wire xbar_ptp_1_23_0_m_axi_14_RREADY;
     wire [1:0]xbar_ptp_1_23_0_m_axi_14_RRESP;
     wire xbar_ptp_1_23_0_m_axi_14_RVALID;
     wire [31:0]xbar_ptp_1_23_0_m_axi_14_WDATA;
     wire xbar_ptp_1_23_0_m_axi_14_WREADY;
     wire [3:0]xbar_ptp_1_23_0_m_axi_14_WSTRB;
     wire xbar_ptp_1_23_0_m_axi_14_WVALID;
     wire [31:0]xbar_ptp_1_23_0_m_axi_15_ARADDR;
     wire [2:0]xbar_ptp_1_23_0_m_axi_15_ARPROT;
     wire xbar_ptp_1_23_0_m_axi_15_ARREADY;
     wire xbar_ptp_1_23_0_m_axi_15_ARVALID;
     wire [31:0]xbar_ptp_1_23_0_m_axi_15_AWADDR;
     wire [2:0]xbar_ptp_1_23_0_m_axi_15_AWPROT;
     wire xbar_ptp_1_23_0_m_axi_15_AWREADY;
     wire xbar_ptp_1_23_0_m_axi_15_AWVALID;
     wire xbar_ptp_1_23_0_m_axi_15_BREADY;
     wire [1:0]xbar_ptp_1_23_0_m_axi_15_BRESP;
     wire xbar_ptp_1_23_0_m_axi_15_BVALID;
     wire [31:0]xbar_ptp_1_23_0_m_axi_15_RDATA;
     wire xbar_ptp_1_23_0_m_axi_15_RREADY;
     wire [1:0]xbar_ptp_1_23_0_m_axi_15_RRESP;
     wire xbar_ptp_1_23_0_m_axi_15_RVALID;
     wire [31:0]xbar_ptp_1_23_0_m_axi_15_WDATA;
     wire xbar_ptp_1_23_0_m_axi_15_WREADY;
     wire [3:0]xbar_ptp_1_23_0_m_axi_15_WSTRB;
     wire xbar_ptp_1_23_0_m_axi_15_WVALID;
     wire [31:0]xbar_ptp_1_23_0_m_axi_16_ARADDR;
     wire [2:0]xbar_ptp_1_23_0_m_axi_16_ARPROT;
     wire xbar_ptp_1_23_0_m_axi_16_ARREADY;
     wire xbar_ptp_1_23_0_m_axi_16_ARVALID;
     wire [31:0]xbar_ptp_1_23_0_m_axi_16_AWADDR;
     wire [2:0]xbar_ptp_1_23_0_m_axi_16_AWPROT;
     wire xbar_ptp_1_23_0_m_axi_16_AWREADY;
     wire xbar_ptp_1_23_0_m_axi_16_AWVALID;
     wire xbar_ptp_1_23_0_m_axi_16_BREADY;
     wire [1:0]xbar_ptp_1_23_0_m_axi_16_BRESP;
     wire xbar_ptp_1_23_0_m_axi_16_BVALID;
     wire [31:0]xbar_ptp_1_23_0_m_axi_16_RDATA;
     wire xbar_ptp_1_23_0_m_axi_16_RREADY;
     wire [1:0]xbar_ptp_1_23_0_m_axi_16_RRESP;
     wire xbar_ptp_1_23_0_m_axi_16_RVALID;
     wire [31:0]xbar_ptp_1_23_0_m_axi_16_WDATA;
     wire xbar_ptp_1_23_0_m_axi_16_WREADY;
     wire [3:0]xbar_ptp_1_23_0_m_axi_16_WSTRB;
     wire xbar_ptp_1_23_0_m_axi_16_WVALID;
     wire [31:0]xbar_ptp_1_23_0_m_axi_17_ARADDR;
     wire [2:0]xbar_ptp_1_23_0_m_axi_17_ARPROT;
     wire xbar_ptp_1_23_0_m_axi_17_ARREADY;
     wire xbar_ptp_1_23_0_m_axi_17_ARVALID;
     wire [31:0]xbar_ptp_1_23_0_m_axi_17_AWADDR;
     wire [2:0]xbar_ptp_1_23_0_m_axi_17_AWPROT;
     wire xbar_ptp_1_23_0_m_axi_17_AWREADY;
     wire xbar_ptp_1_23_0_m_axi_17_AWVALID;
     wire xbar_ptp_1_23_0_m_axi_17_BREADY;
     wire [1:0]xbar_ptp_1_23_0_m_axi_17_BRESP;
     wire xbar_ptp_1_23_0_m_axi_17_BVALID;
     wire [31:0]xbar_ptp_1_23_0_m_axi_17_RDATA;
     wire xbar_ptp_1_23_0_m_axi_17_RREADY;
     wire [1:0]xbar_ptp_1_23_0_m_axi_17_RRESP;
     wire xbar_ptp_1_23_0_m_axi_17_RVALID;
     wire [31:0]xbar_ptp_1_23_0_m_axi_17_WDATA;
     wire xbar_ptp_1_23_0_m_axi_17_WREADY;
     wire [3:0]xbar_ptp_1_23_0_m_axi_17_WSTRB;
     wire xbar_ptp_1_23_0_m_axi_17_WVALID;
     wire [31:0]xbar_ptp_1_23_0_m_axi_18_ARADDR;
     wire [2:0]xbar_ptp_1_23_0_m_axi_18_ARPROT;
     wire xbar_ptp_1_23_0_m_axi_18_ARREADY;
     wire xbar_ptp_1_23_0_m_axi_18_ARVALID;
     wire [31:0]xbar_ptp_1_23_0_m_axi_18_AWADDR;
     wire [2:0]xbar_ptp_1_23_0_m_axi_18_AWPROT;
     wire xbar_ptp_1_23_0_m_axi_18_AWREADY;
     wire xbar_ptp_1_23_0_m_axi_18_AWVALID;
     wire xbar_ptp_1_23_0_m_axi_18_BREADY;
     wire [1:0]xbar_ptp_1_23_0_m_axi_18_BRESP;
     wire xbar_ptp_1_23_0_m_axi_18_BVALID;
     wire [31:0]xbar_ptp_1_23_0_m_axi_18_RDATA;
     wire xbar_ptp_1_23_0_m_axi_18_RREADY;
     wire [1:0]xbar_ptp_1_23_0_m_axi_18_RRESP;
     wire xbar_ptp_1_23_0_m_axi_18_RVALID;
     wire [31:0]xbar_ptp_1_23_0_m_axi_18_WDATA;
     wire xbar_ptp_1_23_0_m_axi_18_WREADY;
     wire [3:0]xbar_ptp_1_23_0_m_axi_18_WSTRB;
     wire xbar_ptp_1_23_0_m_axi_18_WVALID;
     wire [31:0]xbar_ptp_1_23_0_m_axi_19_ARADDR;
     wire [2:0]xbar_ptp_1_23_0_m_axi_19_ARPROT;
     wire xbar_ptp_1_23_0_m_axi_19_ARREADY;
     wire xbar_ptp_1_23_0_m_axi_19_ARVALID;
     wire [31:0]xbar_ptp_1_23_0_m_axi_19_AWADDR;
     wire [2:0]xbar_ptp_1_23_0_m_axi_19_AWPROT;
     wire xbar_ptp_1_23_0_m_axi_19_AWREADY;
     wire xbar_ptp_1_23_0_m_axi_19_AWVALID;
     wire xbar_ptp_1_23_0_m_axi_19_BREADY;
     wire [1:0]xbar_ptp_1_23_0_m_axi_19_BRESP;
     wire xbar_ptp_1_23_0_m_axi_19_BVALID;
     wire [31:0]xbar_ptp_1_23_0_m_axi_19_RDATA;
     wire xbar_ptp_1_23_0_m_axi_19_RREADY;
     wire [1:0]xbar_ptp_1_23_0_m_axi_19_RRESP;
     wire xbar_ptp_1_23_0_m_axi_19_RVALID;
     wire [31:0]xbar_ptp_1_23_0_m_axi_19_WDATA;
     wire xbar_ptp_1_23_0_m_axi_19_WREADY;
     wire [3:0]xbar_ptp_1_23_0_m_axi_19_WSTRB;
     wire xbar_ptp_1_23_0_m_axi_19_WVALID;
     wire [31:0]xbar_ptp_1_23_0_m_axi_1_ARADDR;
     wire [2:0]xbar_ptp_1_23_0_m_axi_1_ARPROT;
     wire xbar_ptp_1_23_0_m_axi_1_ARREADY;
     wire xbar_ptp_1_23_0_m_axi_1_ARVALID;
     wire [31:0]xbar_ptp_1_23_0_m_axi_1_AWADDR;
     wire [2:0]xbar_ptp_1_23_0_m_axi_1_AWPROT;
     wire xbar_ptp_1_23_0_m_axi_1_AWREADY;
     wire xbar_ptp_1_23_0_m_axi_1_AWVALID;
     wire xbar_ptp_1_23_0_m_axi_1_BREADY;
     wire [1:0]xbar_ptp_1_23_0_m_axi_1_BRESP;
     wire xbar_ptp_1_23_0_m_axi_1_BVALID;
     wire [31:0]xbar_ptp_1_23_0_m_axi_1_RDATA;
     wire xbar_ptp_1_23_0_m_axi_1_RREADY;
     wire [1:0]xbar_ptp_1_23_0_m_axi_1_RRESP;
     wire xbar_ptp_1_23_0_m_axi_1_RVALID;
     wire [31:0]xbar_ptp_1_23_0_m_axi_1_WDATA;
     wire xbar_ptp_1_23_0_m_axi_1_WREADY;
     wire [3:0]xbar_ptp_1_23_0_m_axi_1_WSTRB;
     wire xbar_ptp_1_23_0_m_axi_1_WVALID;
     wire [31:0]xbar_ptp_1_23_0_m_axi_20_ARADDR;
     wire [2:0]xbar_ptp_1_23_0_m_axi_20_ARPROT;
     wire xbar_ptp_1_23_0_m_axi_20_ARREADY;
     wire xbar_ptp_1_23_0_m_axi_20_ARVALID;
     wire [31:0]xbar_ptp_1_23_0_m_axi_20_AWADDR;
     wire [2:0]xbar_ptp_1_23_0_m_axi_20_AWPROT;
     wire xbar_ptp_1_23_0_m_axi_20_AWREADY;
     wire xbar_ptp_1_23_0_m_axi_20_AWVALID;
     wire xbar_ptp_1_23_0_m_axi_20_BREADY;
     wire [1:0]xbar_ptp_1_23_0_m_axi_20_BRESP;
     wire xbar_ptp_1_23_0_m_axi_20_BVALID;
     wire [31:0]xbar_ptp_1_23_0_m_axi_20_RDATA;
     wire xbar_ptp_1_23_0_m_axi_20_RREADY;
     wire [1:0]xbar_ptp_1_23_0_m_axi_20_RRESP;
     wire xbar_ptp_1_23_0_m_axi_20_RVALID;
     wire [31:0]xbar_ptp_1_23_0_m_axi_20_WDATA;
     wire xbar_ptp_1_23_0_m_axi_20_WREADY;
     wire [3:0]xbar_ptp_1_23_0_m_axi_20_WSTRB;
     wire xbar_ptp_1_23_0_m_axi_20_WVALID;
     wire [31:0]xbar_ptp_1_23_0_m_axi_21_ARADDR;
     wire [2:0]xbar_ptp_1_23_0_m_axi_21_ARPROT;
     wire xbar_ptp_1_23_0_m_axi_21_ARREADY;
     wire xbar_ptp_1_23_0_m_axi_21_ARVALID;
     wire [31:0]xbar_ptp_1_23_0_m_axi_21_AWADDR;
     wire [2:0]xbar_ptp_1_23_0_m_axi_21_AWPROT;
     wire xbar_ptp_1_23_0_m_axi_21_AWREADY;
     wire xbar_ptp_1_23_0_m_axi_21_AWVALID;
     wire xbar_ptp_1_23_0_m_axi_21_BREADY;
     wire [1:0]xbar_ptp_1_23_0_m_axi_21_BRESP;
     wire xbar_ptp_1_23_0_m_axi_21_BVALID;
     wire [31:0]xbar_ptp_1_23_0_m_axi_21_RDATA;
     wire xbar_ptp_1_23_0_m_axi_21_RREADY;
     wire [1:0]xbar_ptp_1_23_0_m_axi_21_RRESP;
     wire xbar_ptp_1_23_0_m_axi_21_RVALID;
     wire [31:0]xbar_ptp_1_23_0_m_axi_21_WDATA;
     wire xbar_ptp_1_23_0_m_axi_21_WREADY;
     wire [3:0]xbar_ptp_1_23_0_m_axi_21_WSTRB;
     wire xbar_ptp_1_23_0_m_axi_21_WVALID;
     wire [31:0]xbar_ptp_1_23_0_m_axi_22_ARADDR;
     wire [2:0]xbar_ptp_1_23_0_m_axi_22_ARPROT;
     wire xbar_ptp_1_23_0_m_axi_22_ARREADY;
     wire xbar_ptp_1_23_0_m_axi_22_ARVALID;
     wire [31:0]xbar_ptp_1_23_0_m_axi_22_AWADDR;
     wire [2:0]xbar_ptp_1_23_0_m_axi_22_AWPROT;
     wire xbar_ptp_1_23_0_m_axi_22_AWREADY;
     wire xbar_ptp_1_23_0_m_axi_22_AWVALID;
     wire xbar_ptp_1_23_0_m_axi_22_BREADY;
     wire [1:0]xbar_ptp_1_23_0_m_axi_22_BRESP;
     wire xbar_ptp_1_23_0_m_axi_22_BVALID;
     wire [31:0]xbar_ptp_1_23_0_m_axi_22_RDATA;
     wire xbar_ptp_1_23_0_m_axi_22_RREADY;
     wire [1:0]xbar_ptp_1_23_0_m_axi_22_RRESP;
     wire xbar_ptp_1_23_0_m_axi_22_RVALID;
     wire [31:0]xbar_ptp_1_23_0_m_axi_22_WDATA;
     wire xbar_ptp_1_23_0_m_axi_22_WREADY;
     wire [3:0]xbar_ptp_1_23_0_m_axi_22_WSTRB;
     wire xbar_ptp_1_23_0_m_axi_22_WVALID;
     wire [31:0]xbar_ptp_1_23_0_m_axi_23_ARADDR;
     wire [2:0]xbar_ptp_1_23_0_m_axi_23_ARPROT;
     wire xbar_ptp_1_23_0_m_axi_23_ARREADY;
     wire xbar_ptp_1_23_0_m_axi_23_ARVALID;
     wire [31:0]xbar_ptp_1_23_0_m_axi_23_AWADDR;
     wire [2:0]xbar_ptp_1_23_0_m_axi_23_AWPROT;
     wire xbar_ptp_1_23_0_m_axi_23_AWREADY;
     wire xbar_ptp_1_23_0_m_axi_23_AWVALID;
     wire xbar_ptp_1_23_0_m_axi_23_BREADY;
     wire [1:0]xbar_ptp_1_23_0_m_axi_23_BRESP;
     wire xbar_ptp_1_23_0_m_axi_23_BVALID;
     wire [31:0]xbar_ptp_1_23_0_m_axi_23_RDATA;
     wire xbar_ptp_1_23_0_m_axi_23_RREADY;
     wire [1:0]xbar_ptp_1_23_0_m_axi_23_RRESP;
     wire xbar_ptp_1_23_0_m_axi_23_RVALID;
     wire [31:0]xbar_ptp_1_23_0_m_axi_23_WDATA;
     wire xbar_ptp_1_23_0_m_axi_23_WREADY;
     wire [3:0]xbar_ptp_1_23_0_m_axi_23_WSTRB;
     wire xbar_ptp_1_23_0_m_axi_23_WVALID;
     wire [31:0]xbar_ptp_1_23_0_m_axi_2_ARADDR;
     wire [2:0]xbar_ptp_1_23_0_m_axi_2_ARPROT;
     wire xbar_ptp_1_23_0_m_axi_2_ARREADY;
     wire xbar_ptp_1_23_0_m_axi_2_ARVALID;
     wire [31:0]xbar_ptp_1_23_0_m_axi_2_AWADDR;
     wire [2:0]xbar_ptp_1_23_0_m_axi_2_AWPROT;
     wire xbar_ptp_1_23_0_m_axi_2_AWREADY;
     wire xbar_ptp_1_23_0_m_axi_2_AWVALID;
     wire xbar_ptp_1_23_0_m_axi_2_BREADY;
     wire [1:0]xbar_ptp_1_23_0_m_axi_2_BRESP;
     wire xbar_ptp_1_23_0_m_axi_2_BVALID;
     wire [31:0]xbar_ptp_1_23_0_m_axi_2_RDATA;
     wire xbar_ptp_1_23_0_m_axi_2_RREADY;
     wire [1:0]xbar_ptp_1_23_0_m_axi_2_RRESP;
     wire xbar_ptp_1_23_0_m_axi_2_RVALID;
     wire [31:0]xbar_ptp_1_23_0_m_axi_2_WDATA;
     wire xbar_ptp_1_23_0_m_axi_2_WREADY;
     wire [3:0]xbar_ptp_1_23_0_m_axi_2_WSTRB;
     wire xbar_ptp_1_23_0_m_axi_2_WVALID;
     wire [31:0]xbar_ptp_1_23_0_m_axi_3_ARADDR;
     wire [2:0]xbar_ptp_1_23_0_m_axi_3_ARPROT;
     wire xbar_ptp_1_23_0_m_axi_3_ARREADY;
     wire xbar_ptp_1_23_0_m_axi_3_ARVALID;
     wire [31:0]xbar_ptp_1_23_0_m_axi_3_AWADDR;
     wire [2:0]xbar_ptp_1_23_0_m_axi_3_AWPROT;
     wire xbar_ptp_1_23_0_m_axi_3_AWREADY;
     wire xbar_ptp_1_23_0_m_axi_3_AWVALID;
     wire xbar_ptp_1_23_0_m_axi_3_BREADY;
     wire [1:0]xbar_ptp_1_23_0_m_axi_3_BRESP;
     wire xbar_ptp_1_23_0_m_axi_3_BVALID;
     wire [31:0]xbar_ptp_1_23_0_m_axi_3_RDATA;
     wire xbar_ptp_1_23_0_m_axi_3_RREADY;
     wire [1:0]xbar_ptp_1_23_0_m_axi_3_RRESP;
     wire xbar_ptp_1_23_0_m_axi_3_RVALID;
     wire [31:0]xbar_ptp_1_23_0_m_axi_3_WDATA;
     wire xbar_ptp_1_23_0_m_axi_3_WREADY;
     wire [3:0]xbar_ptp_1_23_0_m_axi_3_WSTRB;
     wire xbar_ptp_1_23_0_m_axi_3_WVALID;
     wire [31:0]xbar_ptp_1_23_0_m_axi_4_ARADDR;
     wire [2:0]xbar_ptp_1_23_0_m_axi_4_ARPROT;
     wire xbar_ptp_1_23_0_m_axi_4_ARREADY;
     wire xbar_ptp_1_23_0_m_axi_4_ARVALID;
     wire [31:0]xbar_ptp_1_23_0_m_axi_4_AWADDR;
     wire [2:0]xbar_ptp_1_23_0_m_axi_4_AWPROT;
     wire xbar_ptp_1_23_0_m_axi_4_AWREADY;
     wire xbar_ptp_1_23_0_m_axi_4_AWVALID;
     wire xbar_ptp_1_23_0_m_axi_4_BREADY;
     wire [1:0]xbar_ptp_1_23_0_m_axi_4_BRESP;
     wire xbar_ptp_1_23_0_m_axi_4_BVALID;
     wire [31:0]xbar_ptp_1_23_0_m_axi_4_RDATA;
     wire xbar_ptp_1_23_0_m_axi_4_RREADY;
     wire [1:0]xbar_ptp_1_23_0_m_axi_4_RRESP;
     wire xbar_ptp_1_23_0_m_axi_4_RVALID;
     wire [31:0]xbar_ptp_1_23_0_m_axi_4_WDATA;
     wire xbar_ptp_1_23_0_m_axi_4_WREADY;
     wire [3:0]xbar_ptp_1_23_0_m_axi_4_WSTRB;
     wire xbar_ptp_1_23_0_m_axi_4_WVALID;
     wire [31:0]xbar_ptp_1_23_0_m_axi_5_ARADDR;
     wire [2:0]xbar_ptp_1_23_0_m_axi_5_ARPROT;
     wire xbar_ptp_1_23_0_m_axi_5_ARREADY;
     wire xbar_ptp_1_23_0_m_axi_5_ARVALID;
     wire [31:0]xbar_ptp_1_23_0_m_axi_5_AWADDR;
     wire [2:0]xbar_ptp_1_23_0_m_axi_5_AWPROT;
     wire xbar_ptp_1_23_0_m_axi_5_AWREADY;
     wire xbar_ptp_1_23_0_m_axi_5_AWVALID;
     wire xbar_ptp_1_23_0_m_axi_5_BREADY;
     wire [1:0]xbar_ptp_1_23_0_m_axi_5_BRESP;
     wire xbar_ptp_1_23_0_m_axi_5_BVALID;
     wire [31:0]xbar_ptp_1_23_0_m_axi_5_RDATA;
     wire xbar_ptp_1_23_0_m_axi_5_RREADY;
     wire [1:0]xbar_ptp_1_23_0_m_axi_5_RRESP;
     wire xbar_ptp_1_23_0_m_axi_5_RVALID;
     wire [31:0]xbar_ptp_1_23_0_m_axi_5_WDATA;
     wire xbar_ptp_1_23_0_m_axi_5_WREADY;
     wire [3:0]xbar_ptp_1_23_0_m_axi_5_WSTRB;
     wire xbar_ptp_1_23_0_m_axi_5_WVALID;
     wire [31:0]xbar_ptp_1_23_0_m_axi_6_ARADDR;
     wire [2:0]xbar_ptp_1_23_0_m_axi_6_ARPROT;
     wire xbar_ptp_1_23_0_m_axi_6_ARREADY;
     wire xbar_ptp_1_23_0_m_axi_6_ARVALID;
     wire [31:0]xbar_ptp_1_23_0_m_axi_6_AWADDR;
     wire [2:0]xbar_ptp_1_23_0_m_axi_6_AWPROT;
     wire xbar_ptp_1_23_0_m_axi_6_AWREADY;
     wire xbar_ptp_1_23_0_m_axi_6_AWVALID;
     wire xbar_ptp_1_23_0_m_axi_6_BREADY;
     wire [1:0]xbar_ptp_1_23_0_m_axi_6_BRESP;
     wire xbar_ptp_1_23_0_m_axi_6_BVALID;
     wire [31:0]xbar_ptp_1_23_0_m_axi_6_RDATA;
     wire xbar_ptp_1_23_0_m_axi_6_RREADY;
     wire [1:0]xbar_ptp_1_23_0_m_axi_6_RRESP;
     wire xbar_ptp_1_23_0_m_axi_6_RVALID;
     wire [31:0]xbar_ptp_1_23_0_m_axi_6_WDATA;
     wire xbar_ptp_1_23_0_m_axi_6_WREADY;
     wire [3:0]xbar_ptp_1_23_0_m_axi_6_WSTRB;
     wire xbar_ptp_1_23_0_m_axi_6_WVALID;
     wire [31:0]xbar_ptp_1_23_0_m_axi_7_ARADDR;
     wire [2:0]xbar_ptp_1_23_0_m_axi_7_ARPROT;
     wire xbar_ptp_1_23_0_m_axi_7_ARREADY;
     wire xbar_ptp_1_23_0_m_axi_7_ARVALID;
     wire [31:0]xbar_ptp_1_23_0_m_axi_7_AWADDR;
     wire [2:0]xbar_ptp_1_23_0_m_axi_7_AWPROT;
     wire xbar_ptp_1_23_0_m_axi_7_AWREADY;
     wire xbar_ptp_1_23_0_m_axi_7_AWVALID;
     wire xbar_ptp_1_23_0_m_axi_7_BREADY;
     wire [1:0]xbar_ptp_1_23_0_m_axi_7_BRESP;
     wire xbar_ptp_1_23_0_m_axi_7_BVALID;
     wire [31:0]xbar_ptp_1_23_0_m_axi_7_RDATA;
     wire xbar_ptp_1_23_0_m_axi_7_RREADY;
     wire [1:0]xbar_ptp_1_23_0_m_axi_7_RRESP;
     wire xbar_ptp_1_23_0_m_axi_7_RVALID;
     wire [31:0]xbar_ptp_1_23_0_m_axi_7_WDATA;
     wire xbar_ptp_1_23_0_m_axi_7_WREADY;
     wire [3:0]xbar_ptp_1_23_0_m_axi_7_WSTRB;
     wire xbar_ptp_1_23_0_m_axi_7_WVALID;
     wire [31:0]xbar_ptp_1_23_0_m_axi_8_ARADDR;
     wire [2:0]xbar_ptp_1_23_0_m_axi_8_ARPROT;
     wire xbar_ptp_1_23_0_m_axi_8_ARREADY;
     wire xbar_ptp_1_23_0_m_axi_8_ARVALID;
     wire [31:0]xbar_ptp_1_23_0_m_axi_8_AWADDR;
     wire [2:0]xbar_ptp_1_23_0_m_axi_8_AWPROT;
     wire xbar_ptp_1_23_0_m_axi_8_AWREADY;
     wire xbar_ptp_1_23_0_m_axi_8_AWVALID;
     wire xbar_ptp_1_23_0_m_axi_8_BREADY;
     wire [1:0]xbar_ptp_1_23_0_m_axi_8_BRESP;
     wire xbar_ptp_1_23_0_m_axi_8_BVALID;
     wire [31:0]xbar_ptp_1_23_0_m_axi_8_RDATA;
     wire xbar_ptp_1_23_0_m_axi_8_RREADY;
     wire [1:0]xbar_ptp_1_23_0_m_axi_8_RRESP;
     wire xbar_ptp_1_23_0_m_axi_8_RVALID;
     wire [31:0]xbar_ptp_1_23_0_m_axi_8_WDATA;
     wire xbar_ptp_1_23_0_m_axi_8_WREADY;
     wire [3:0]xbar_ptp_1_23_0_m_axi_8_WSTRB;
     wire xbar_ptp_1_23_0_m_axi_8_WVALID;
     wire [31:0]xbar_ptp_1_23_0_m_axi_9_ARADDR;
     wire [2:0]xbar_ptp_1_23_0_m_axi_9_ARPROT;
     wire xbar_ptp_1_23_0_m_axi_9_ARREADY;
     wire xbar_ptp_1_23_0_m_axi_9_ARVALID;
     wire [31:0]xbar_ptp_1_23_0_m_axi_9_AWADDR;
     wire [2:0]xbar_ptp_1_23_0_m_axi_9_AWPROT;
     wire xbar_ptp_1_23_0_m_axi_9_AWREADY;
     wire xbar_ptp_1_23_0_m_axi_9_AWVALID;
     wire xbar_ptp_1_23_0_m_axi_9_BREADY;
     wire [1:0]xbar_ptp_1_23_0_m_axi_9_BRESP;
     wire xbar_ptp_1_23_0_m_axi_9_BVALID;
     wire [31:0]xbar_ptp_1_23_0_m_axi_9_RDATA;
     wire xbar_ptp_1_23_0_m_axi_9_RREADY;
     wire [1:0]xbar_ptp_1_23_0_m_axi_9_RRESP;
     wire xbar_ptp_1_23_0_m_axi_9_RVALID;
     wire [31:0]xbar_ptp_1_23_0_m_axi_9_WDATA;
     wire xbar_ptp_1_23_0_m_axi_9_WREADY;
     wire [3:0]xbar_ptp_1_23_0_m_axi_9_WSTRB;
     wire xbar_ptp_1_23_0_m_axi_9_WVALID;
     xbar_ptp_1_23 xbar_ptp_1_23_0 (
          .S_AXI_ACLK(PTP_M_AXI_ACLK),
          .S_AXI_ARESETN(PTP_M_AXI_ARESETN),
          .S_AXI_0_ARADDR(xbar_2_2_0_m_axi_0_ARADDR),
          .S_AXI_0_ARPROT(xbar_2_2_0_m_axi_0_ARPROT),
          .S_AXI_0_ARREADY(xbar_2_2_0_m_axi_0_ARREADY),
          .S_AXI_0_ARVALID(xbar_2_2_0_m_axi_0_ARVALID),
          .S_AXI_0_AWADDR(xbar_2_2_0_m_axi_0_AWADDR),
          .S_AXI_0_AWPROT(xbar_2_2_0_m_axi_0_AWPROT),
          .S_AXI_0_AWREADY(xbar_2_2_0_m_axi_0_AWREADY),
          .S_AXI_0_AWVALID(xbar_2_2_0_m_axi_0_AWVALID),
          .S_AXI_0_BREADY(xbar_2_2_0_m_axi_0_BREADY),
          .S_AXI_0_BRESP(xbar_2_2_0_m_axi_0_BRESP),
          .S_AXI_0_BVALID(xbar_2_2_0_m_axi_0_BVALID),
          .S_AXI_0_RDATA(xbar_2_2_0_m_axi_0_RDATA),
          .S_AXI_0_RREADY(xbar_2_2_0_m_axi_0_RREADY),
          .S_AXI_0_RRESP(xbar_2_2_0_m_axi_0_RRESP),
          .S_AXI_0_RVALID(xbar_2_2_0_m_axi_0_RVALID),
          .S_AXI_0_WDATA(xbar_2_2_0_m_axi_0_WDATA),
          .S_AXI_0_WREADY(xbar_2_2_0_m_axi_0_WREADY),
          .S_AXI_0_WSTRB(xbar_2_2_0_m_axi_0_WSTRB),
          .S_AXI_0_WVALID(xbar_2_2_0_m_axi_0_WVALID),
          .M_AXI_0_ARADDR(xbar_ptp_1_23_0_m_axi_0_ARADDR),
          .M_AXI_0_ARPROT(xbar_ptp_1_23_0_m_axi_0_ARPROT),
          .M_AXI_0_ARREADY(xbar_ptp_1_23_0_m_axi_0_ARREADY),
          .M_AXI_0_ARVALID(xbar_ptp_1_23_0_m_axi_0_ARVALID),
          .M_AXI_0_AWADDR(xbar_ptp_1_23_0_m_axi_0_AWADDR),
          .M_AXI_0_AWPROT(xbar_ptp_1_23_0_m_axi_0_AWPROT),
          .M_AXI_0_AWREADY(xbar_ptp_1_23_0_m_axi_0_AWREADY),
          .M_AXI_0_AWVALID(xbar_ptp_1_23_0_m_axi_0_AWVALID),
          .M_AXI_0_BREADY(xbar_ptp_1_23_0_m_axi_0_BREADY),
          .M_AXI_0_BRESP(xbar_ptp_1_23_0_m_axi_0_BRESP),
          .M_AXI_0_BVALID(xbar_ptp_1_23_0_m_axi_0_BVALID),
          .M_AXI_0_RDATA(xbar_ptp_1_23_0_m_axi_0_RDATA),
          .M_AXI_0_RREADY(xbar_ptp_1_23_0_m_axi_0_RREADY),
          .M_AXI_0_RRESP(xbar_ptp_1_23_0_m_axi_0_RRESP),
          .M_AXI_0_RVALID(xbar_ptp_1_23_0_m_axi_0_RVALID),
          .M_AXI_0_WDATA(xbar_ptp_1_23_0_m_axi_0_WDATA),
          .M_AXI_0_WREADY(xbar_ptp_1_23_0_m_axi_0_WREADY),
          .M_AXI_0_WSTRB(xbar_ptp_1_23_0_m_axi_0_WSTRB),
          .M_AXI_0_WVALID(xbar_ptp_1_23_0_m_axi_0_WVALID),
          .M_AXI_1_ARADDR(xbar_ptp_1_23_0_m_axi_1_ARADDR),
          .M_AXI_1_ARPROT(xbar_ptp_1_23_0_m_axi_1_ARPROT),
          .M_AXI_1_ARREADY(xbar_ptp_1_23_0_m_axi_1_ARREADY),
          .M_AXI_1_ARVALID(xbar_ptp_1_23_0_m_axi_1_ARVALID),
          .M_AXI_1_AWADDR(xbar_ptp_1_23_0_m_axi_1_AWADDR),
          .M_AXI_1_AWPROT(xbar_ptp_1_23_0_m_axi_1_AWPROT),
          .M_AXI_1_AWREADY(xbar_ptp_1_23_0_m_axi_1_AWREADY),
          .M_AXI_1_AWVALID(xbar_ptp_1_23_0_m_axi_1_AWVALID),
          .M_AXI_1_BREADY(xbar_ptp_1_23_0_m_axi_1_BREADY),
          .M_AXI_1_BRESP(xbar_ptp_1_23_0_m_axi_1_BRESP),
          .M_AXI_1_BVALID(xbar_ptp_1_23_0_m_axi_1_BVALID),
          .M_AXI_1_RDATA(xbar_ptp_1_23_0_m_axi_1_RDATA),
          .M_AXI_1_RREADY(xbar_ptp_1_23_0_m_axi_1_RREADY),
          .M_AXI_1_RRESP(xbar_ptp_1_23_0_m_axi_1_RRESP),
          .M_AXI_1_RVALID(xbar_ptp_1_23_0_m_axi_1_RVALID),
          .M_AXI_1_WDATA(xbar_ptp_1_23_0_m_axi_1_WDATA),
          .M_AXI_1_WREADY(xbar_ptp_1_23_0_m_axi_1_WREADY),
          .M_AXI_1_WSTRB(xbar_ptp_1_23_0_m_axi_1_WSTRB),
          .M_AXI_1_WVALID(xbar_ptp_1_23_0_m_axi_1_WVALID),
          .M_AXI_2_ARADDR(xbar_ptp_1_23_0_m_axi_2_ARADDR),
          .M_AXI_2_ARPROT(xbar_ptp_1_23_0_m_axi_2_ARPROT),
          .M_AXI_2_ARREADY(xbar_ptp_1_23_0_m_axi_2_ARREADY),
          .M_AXI_2_ARVALID(xbar_ptp_1_23_0_m_axi_2_ARVALID),
          .M_AXI_2_AWADDR(xbar_ptp_1_23_0_m_axi_2_AWADDR),
          .M_AXI_2_AWPROT(xbar_ptp_1_23_0_m_axi_2_AWPROT),
          .M_AXI_2_AWREADY(xbar_ptp_1_23_0_m_axi_2_AWREADY),
          .M_AXI_2_AWVALID(xbar_ptp_1_23_0_m_axi_2_AWVALID),
          .M_AXI_2_BREADY(xbar_ptp_1_23_0_m_axi_2_BREADY),
          .M_AXI_2_BRESP(xbar_ptp_1_23_0_m_axi_2_BRESP),
          .M_AXI_2_BVALID(xbar_ptp_1_23_0_m_axi_2_BVALID),
          .M_AXI_2_RDATA(xbar_ptp_1_23_0_m_axi_2_RDATA),
          .M_AXI_2_RREADY(xbar_ptp_1_23_0_m_axi_2_RREADY),
          .M_AXI_2_RRESP(xbar_ptp_1_23_0_m_axi_2_RRESP),
          .M_AXI_2_RVALID(xbar_ptp_1_23_0_m_axi_2_RVALID),
          .M_AXI_2_WDATA(xbar_ptp_1_23_0_m_axi_2_WDATA),
          .M_AXI_2_WREADY(xbar_ptp_1_23_0_m_axi_2_WREADY),
          .M_AXI_2_WSTRB(xbar_ptp_1_23_0_m_axi_2_WSTRB),
          .M_AXI_2_WVALID(xbar_ptp_1_23_0_m_axi_2_WVALID),
          .M_AXI_3_ARADDR(xbar_ptp_1_23_0_m_axi_3_ARADDR),
          .M_AXI_3_ARPROT(xbar_ptp_1_23_0_m_axi_3_ARPROT),
          .M_AXI_3_ARREADY(xbar_ptp_1_23_0_m_axi_3_ARREADY),
          .M_AXI_3_ARVALID(xbar_ptp_1_23_0_m_axi_3_ARVALID),
          .M_AXI_3_AWADDR(xbar_ptp_1_23_0_m_axi_3_AWADDR),
          .M_AXI_3_AWPROT(xbar_ptp_1_23_0_m_axi_3_AWPROT),
          .M_AXI_3_AWREADY(xbar_ptp_1_23_0_m_axi_3_AWREADY),
          .M_AXI_3_AWVALID(xbar_ptp_1_23_0_m_axi_3_AWVALID),
          .M_AXI_3_BREADY(xbar_ptp_1_23_0_m_axi_3_BREADY),
          .M_AXI_3_BRESP(xbar_ptp_1_23_0_m_axi_3_BRESP),
          .M_AXI_3_BVALID(xbar_ptp_1_23_0_m_axi_3_BVALID),
          .M_AXI_3_RDATA(xbar_ptp_1_23_0_m_axi_3_RDATA),
          .M_AXI_3_RREADY(xbar_ptp_1_23_0_m_axi_3_RREADY),
          .M_AXI_3_RRESP(xbar_ptp_1_23_0_m_axi_3_RRESP),
          .M_AXI_3_RVALID(xbar_ptp_1_23_0_m_axi_3_RVALID),
          .M_AXI_3_WDATA(xbar_ptp_1_23_0_m_axi_3_WDATA),
          .M_AXI_3_WREADY(xbar_ptp_1_23_0_m_axi_3_WREADY),
          .M_AXI_3_WSTRB(xbar_ptp_1_23_0_m_axi_3_WSTRB),
          .M_AXI_3_WVALID(xbar_ptp_1_23_0_m_axi_3_WVALID),
          .M_AXI_4_ARADDR(xbar_ptp_1_23_0_m_axi_4_ARADDR),
          .M_AXI_4_ARPROT(xbar_ptp_1_23_0_m_axi_4_ARPROT),
          .M_AXI_4_ARREADY(xbar_ptp_1_23_0_m_axi_4_ARREADY),
          .M_AXI_4_ARVALID(xbar_ptp_1_23_0_m_axi_4_ARVALID),
          .M_AXI_4_AWADDR(xbar_ptp_1_23_0_m_axi_4_AWADDR),
          .M_AXI_4_AWPROT(xbar_ptp_1_23_0_m_axi_4_AWPROT),
          .M_AXI_4_AWREADY(xbar_ptp_1_23_0_m_axi_4_AWREADY),
          .M_AXI_4_AWVALID(xbar_ptp_1_23_0_m_axi_4_AWVALID),
          .M_AXI_4_BREADY(xbar_ptp_1_23_0_m_axi_4_BREADY),
          .M_AXI_4_BRESP(xbar_ptp_1_23_0_m_axi_4_BRESP),
          .M_AXI_4_BVALID(xbar_ptp_1_23_0_m_axi_4_BVALID),
          .M_AXI_4_RDATA(xbar_ptp_1_23_0_m_axi_4_RDATA),
          .M_AXI_4_RREADY(xbar_ptp_1_23_0_m_axi_4_RREADY),
          .M_AXI_4_RRESP(xbar_ptp_1_23_0_m_axi_4_RRESP),
          .M_AXI_4_RVALID(xbar_ptp_1_23_0_m_axi_4_RVALID),
          .M_AXI_4_WDATA(xbar_ptp_1_23_0_m_axi_4_WDATA),
          .M_AXI_4_WREADY(xbar_ptp_1_23_0_m_axi_4_WREADY),
          .M_AXI_4_WSTRB(xbar_ptp_1_23_0_m_axi_4_WSTRB),
          .M_AXI_4_WVALID(xbar_ptp_1_23_0_m_axi_4_WVALID),
          .M_AXI_5_ARADDR(xbar_ptp_1_23_0_m_axi_5_ARADDR),
          .M_AXI_5_ARPROT(xbar_ptp_1_23_0_m_axi_5_ARPROT),
          .M_AXI_5_ARREADY(xbar_ptp_1_23_0_m_axi_5_ARREADY),
          .M_AXI_5_ARVALID(xbar_ptp_1_23_0_m_axi_5_ARVALID),
          .M_AXI_5_AWADDR(xbar_ptp_1_23_0_m_axi_5_AWADDR),
          .M_AXI_5_AWPROT(xbar_ptp_1_23_0_m_axi_5_AWPROT),
          .M_AXI_5_AWREADY(xbar_ptp_1_23_0_m_axi_5_AWREADY),
          .M_AXI_5_AWVALID(xbar_ptp_1_23_0_m_axi_5_AWVALID),
          .M_AXI_5_BREADY(xbar_ptp_1_23_0_m_axi_5_BREADY),
          .M_AXI_5_BRESP(xbar_ptp_1_23_0_m_axi_5_BRESP),
          .M_AXI_5_BVALID(xbar_ptp_1_23_0_m_axi_5_BVALID),
          .M_AXI_5_RDATA(xbar_ptp_1_23_0_m_axi_5_RDATA),
          .M_AXI_5_RREADY(xbar_ptp_1_23_0_m_axi_5_RREADY),
          .M_AXI_5_RRESP(xbar_ptp_1_23_0_m_axi_5_RRESP),
          .M_AXI_5_RVALID(xbar_ptp_1_23_0_m_axi_5_RVALID),
          .M_AXI_5_WDATA(xbar_ptp_1_23_0_m_axi_5_WDATA),
          .M_AXI_5_WREADY(xbar_ptp_1_23_0_m_axi_5_WREADY),
          .M_AXI_5_WSTRB(xbar_ptp_1_23_0_m_axi_5_WSTRB),
          .M_AXI_5_WVALID(xbar_ptp_1_23_0_m_axi_5_WVALID),
          .M_AXI_6_ARADDR(xbar_ptp_1_23_0_m_axi_6_ARADDR),
          .M_AXI_6_ARPROT(xbar_ptp_1_23_0_m_axi_6_ARPROT),
          .M_AXI_6_ARREADY(xbar_ptp_1_23_0_m_axi_6_ARREADY),
          .M_AXI_6_ARVALID(xbar_ptp_1_23_0_m_axi_6_ARVALID),
          .M_AXI_6_AWADDR(xbar_ptp_1_23_0_m_axi_6_AWADDR),
          .M_AXI_6_AWPROT(xbar_ptp_1_23_0_m_axi_6_AWPROT),
          .M_AXI_6_AWREADY(xbar_ptp_1_23_0_m_axi_6_AWREADY),
          .M_AXI_6_AWVALID(xbar_ptp_1_23_0_m_axi_6_AWVALID),
          .M_AXI_6_BREADY(xbar_ptp_1_23_0_m_axi_6_BREADY),
          .M_AXI_6_BRESP(xbar_ptp_1_23_0_m_axi_6_BRESP),
          .M_AXI_6_BVALID(xbar_ptp_1_23_0_m_axi_6_BVALID),
          .M_AXI_6_RDATA(xbar_ptp_1_23_0_m_axi_6_RDATA),
          .M_AXI_6_RREADY(xbar_ptp_1_23_0_m_axi_6_RREADY),
          .M_AXI_6_RRESP(xbar_ptp_1_23_0_m_axi_6_RRESP),
          .M_AXI_6_RVALID(xbar_ptp_1_23_0_m_axi_6_RVALID),
          .M_AXI_6_WDATA(xbar_ptp_1_23_0_m_axi_6_WDATA),
          .M_AXI_6_WREADY(xbar_ptp_1_23_0_m_axi_6_WREADY),
          .M_AXI_6_WSTRB(xbar_ptp_1_23_0_m_axi_6_WSTRB),
          .M_AXI_6_WVALID(xbar_ptp_1_23_0_m_axi_6_WVALID),
          .M_AXI_7_ARADDR(xbar_ptp_1_23_0_m_axi_7_ARADDR),
          .M_AXI_7_ARPROT(xbar_ptp_1_23_0_m_axi_7_ARPROT),
          .M_AXI_7_ARREADY(xbar_ptp_1_23_0_m_axi_7_ARREADY),
          .M_AXI_7_ARVALID(xbar_ptp_1_23_0_m_axi_7_ARVALID),
          .M_AXI_7_AWADDR(xbar_ptp_1_23_0_m_axi_7_AWADDR),
          .M_AXI_7_AWPROT(xbar_ptp_1_23_0_m_axi_7_AWPROT),
          .M_AXI_7_AWREADY(xbar_ptp_1_23_0_m_axi_7_AWREADY),
          .M_AXI_7_AWVALID(xbar_ptp_1_23_0_m_axi_7_AWVALID),
          .M_AXI_7_BREADY(xbar_ptp_1_23_0_m_axi_7_BREADY),
          .M_AXI_7_BRESP(xbar_ptp_1_23_0_m_axi_7_BRESP),
          .M_AXI_7_BVALID(xbar_ptp_1_23_0_m_axi_7_BVALID),
          .M_AXI_7_RDATA(xbar_ptp_1_23_0_m_axi_7_RDATA),
          .M_AXI_7_RREADY(xbar_ptp_1_23_0_m_axi_7_RREADY),
          .M_AXI_7_RRESP(xbar_ptp_1_23_0_m_axi_7_RRESP),
          .M_AXI_7_RVALID(xbar_ptp_1_23_0_m_axi_7_RVALID),
          .M_AXI_7_WDATA(xbar_ptp_1_23_0_m_axi_7_WDATA),
          .M_AXI_7_WREADY(xbar_ptp_1_23_0_m_axi_7_WREADY),
          .M_AXI_7_WSTRB(xbar_ptp_1_23_0_m_axi_7_WSTRB),
          .M_AXI_7_WVALID(xbar_ptp_1_23_0_m_axi_7_WVALID),
          .M_AXI_8_ARADDR(xbar_ptp_1_23_0_m_axi_8_ARADDR),
          .M_AXI_8_ARPROT(xbar_ptp_1_23_0_m_axi_8_ARPROT),
          .M_AXI_8_ARREADY(xbar_ptp_1_23_0_m_axi_8_ARREADY),
          .M_AXI_8_ARVALID(xbar_ptp_1_23_0_m_axi_8_ARVALID),
          .M_AXI_8_AWADDR(xbar_ptp_1_23_0_m_axi_8_AWADDR),
          .M_AXI_8_AWPROT(xbar_ptp_1_23_0_m_axi_8_AWPROT),
          .M_AXI_8_AWREADY(xbar_ptp_1_23_0_m_axi_8_AWREADY),
          .M_AXI_8_AWVALID(xbar_ptp_1_23_0_m_axi_8_AWVALID),
          .M_AXI_8_BREADY(xbar_ptp_1_23_0_m_axi_8_BREADY),
          .M_AXI_8_BRESP(xbar_ptp_1_23_0_m_axi_8_BRESP),
          .M_AXI_8_BVALID(xbar_ptp_1_23_0_m_axi_8_BVALID),
          .M_AXI_8_RDATA(xbar_ptp_1_23_0_m_axi_8_RDATA),
          .M_AXI_8_RREADY(xbar_ptp_1_23_0_m_axi_8_RREADY),
          .M_AXI_8_RRESP(xbar_ptp_1_23_0_m_axi_8_RRESP),
          .M_AXI_8_RVALID(xbar_ptp_1_23_0_m_axi_8_RVALID),
          .M_AXI_8_WDATA(xbar_ptp_1_23_0_m_axi_8_WDATA),
          .M_AXI_8_WREADY(xbar_ptp_1_23_0_m_axi_8_WREADY),
          .M_AXI_8_WSTRB(xbar_ptp_1_23_0_m_axi_8_WSTRB),
          .M_AXI_8_WVALID(xbar_ptp_1_23_0_m_axi_8_WVALID),
          .M_AXI_9_ARADDR(xbar_ptp_1_23_0_m_axi_9_ARADDR),
          .M_AXI_9_ARPROT(xbar_ptp_1_23_0_m_axi_9_ARPROT),
          .M_AXI_9_ARREADY(xbar_ptp_1_23_0_m_axi_9_ARREADY),
          .M_AXI_9_ARVALID(xbar_ptp_1_23_0_m_axi_9_ARVALID),
          .M_AXI_9_AWADDR(xbar_ptp_1_23_0_m_axi_9_AWADDR),
          .M_AXI_9_AWPROT(xbar_ptp_1_23_0_m_axi_9_AWPROT),
          .M_AXI_9_AWREADY(xbar_ptp_1_23_0_m_axi_9_AWREADY),
          .M_AXI_9_AWVALID(xbar_ptp_1_23_0_m_axi_9_AWVALID),
          .M_AXI_9_BREADY(xbar_ptp_1_23_0_m_axi_9_BREADY),
          .M_AXI_9_BRESP(xbar_ptp_1_23_0_m_axi_9_BRESP),
          .M_AXI_9_BVALID(xbar_ptp_1_23_0_m_axi_9_BVALID),
          .M_AXI_9_RDATA(xbar_ptp_1_23_0_m_axi_9_RDATA),
          .M_AXI_9_RREADY(xbar_ptp_1_23_0_m_axi_9_RREADY),
          .M_AXI_9_RRESP(xbar_ptp_1_23_0_m_axi_9_RRESP),
          .M_AXI_9_RVALID(xbar_ptp_1_23_0_m_axi_9_RVALID),
          .M_AXI_9_WDATA(xbar_ptp_1_23_0_m_axi_9_WDATA),
          .M_AXI_9_WREADY(xbar_ptp_1_23_0_m_axi_9_WREADY),
          .M_AXI_9_WSTRB(xbar_ptp_1_23_0_m_axi_9_WSTRB),
          .M_AXI_9_WVALID(xbar_ptp_1_23_0_m_axi_9_WVALID),
          .M_AXI_10_ARADDR(xbar_ptp_1_23_0_m_axi_10_ARADDR),
          .M_AXI_10_ARPROT(xbar_ptp_1_23_0_m_axi_10_ARPROT),
          .M_AXI_10_ARREADY(xbar_ptp_1_23_0_m_axi_10_ARREADY),
          .M_AXI_10_ARVALID(xbar_ptp_1_23_0_m_axi_10_ARVALID),
          .M_AXI_10_AWADDR(xbar_ptp_1_23_0_m_axi_10_AWADDR),
          .M_AXI_10_AWPROT(xbar_ptp_1_23_0_m_axi_10_AWPROT),
          .M_AXI_10_AWREADY(xbar_ptp_1_23_0_m_axi_10_AWREADY),
          .M_AXI_10_AWVALID(xbar_ptp_1_23_0_m_axi_10_AWVALID),
          .M_AXI_10_BREADY(xbar_ptp_1_23_0_m_axi_10_BREADY),
          .M_AXI_10_BRESP(xbar_ptp_1_23_0_m_axi_10_BRESP),
          .M_AXI_10_BVALID(xbar_ptp_1_23_0_m_axi_10_BVALID),
          .M_AXI_10_RDATA(xbar_ptp_1_23_0_m_axi_10_RDATA),
          .M_AXI_10_RREADY(xbar_ptp_1_23_0_m_axi_10_RREADY),
          .M_AXI_10_RRESP(xbar_ptp_1_23_0_m_axi_10_RRESP),
          .M_AXI_10_RVALID(xbar_ptp_1_23_0_m_axi_10_RVALID),
          .M_AXI_10_WDATA(xbar_ptp_1_23_0_m_axi_10_WDATA),
          .M_AXI_10_WREADY(xbar_ptp_1_23_0_m_axi_10_WREADY),
          .M_AXI_10_WSTRB(xbar_ptp_1_23_0_m_axi_10_WSTRB),
          .M_AXI_10_WVALID(xbar_ptp_1_23_0_m_axi_10_WVALID),
          .M_AXI_11_ARADDR(xbar_ptp_1_23_0_m_axi_11_ARADDR),
          .M_AXI_11_ARPROT(xbar_ptp_1_23_0_m_axi_11_ARPROT),
          .M_AXI_11_ARREADY(xbar_ptp_1_23_0_m_axi_11_ARREADY),
          .M_AXI_11_ARVALID(xbar_ptp_1_23_0_m_axi_11_ARVALID),
          .M_AXI_11_AWADDR(xbar_ptp_1_23_0_m_axi_11_AWADDR),
          .M_AXI_11_AWPROT(xbar_ptp_1_23_0_m_axi_11_AWPROT),
          .M_AXI_11_AWREADY(xbar_ptp_1_23_0_m_axi_11_AWREADY),
          .M_AXI_11_AWVALID(xbar_ptp_1_23_0_m_axi_11_AWVALID),
          .M_AXI_11_BREADY(xbar_ptp_1_23_0_m_axi_11_BREADY),
          .M_AXI_11_BRESP(xbar_ptp_1_23_0_m_axi_11_BRESP),
          .M_AXI_11_BVALID(xbar_ptp_1_23_0_m_axi_11_BVALID),
          .M_AXI_11_RDATA(xbar_ptp_1_23_0_m_axi_11_RDATA),
          .M_AXI_11_RREADY(xbar_ptp_1_23_0_m_axi_11_RREADY),
          .M_AXI_11_RRESP(xbar_ptp_1_23_0_m_axi_11_RRESP),
          .M_AXI_11_RVALID(xbar_ptp_1_23_0_m_axi_11_RVALID),
          .M_AXI_11_WDATA(xbar_ptp_1_23_0_m_axi_11_WDATA),
          .M_AXI_11_WREADY(xbar_ptp_1_23_0_m_axi_11_WREADY),
          .M_AXI_11_WSTRB(xbar_ptp_1_23_0_m_axi_11_WSTRB),
          .M_AXI_11_WVALID(xbar_ptp_1_23_0_m_axi_11_WVALID),
          .M_AXI_12_ARADDR(xbar_ptp_1_23_0_m_axi_12_ARADDR),
          .M_AXI_12_ARPROT(xbar_ptp_1_23_0_m_axi_12_ARPROT),
          .M_AXI_12_ARREADY(xbar_ptp_1_23_0_m_axi_12_ARREADY),
          .M_AXI_12_ARVALID(xbar_ptp_1_23_0_m_axi_12_ARVALID),
          .M_AXI_12_AWADDR(xbar_ptp_1_23_0_m_axi_12_AWADDR),
          .M_AXI_12_AWPROT(xbar_ptp_1_23_0_m_axi_12_AWPROT),
          .M_AXI_12_AWREADY(xbar_ptp_1_23_0_m_axi_12_AWREADY),
          .M_AXI_12_AWVALID(xbar_ptp_1_23_0_m_axi_12_AWVALID),
          .M_AXI_12_BREADY(xbar_ptp_1_23_0_m_axi_12_BREADY),
          .M_AXI_12_BRESP(xbar_ptp_1_23_0_m_axi_12_BRESP),
          .M_AXI_12_BVALID(xbar_ptp_1_23_0_m_axi_12_BVALID),
          .M_AXI_12_RDATA(xbar_ptp_1_23_0_m_axi_12_RDATA),
          .M_AXI_12_RREADY(xbar_ptp_1_23_0_m_axi_12_RREADY),
          .M_AXI_12_RRESP(xbar_ptp_1_23_0_m_axi_12_RRESP),
          .M_AXI_12_RVALID(xbar_ptp_1_23_0_m_axi_12_RVALID),
          .M_AXI_12_WDATA(xbar_ptp_1_23_0_m_axi_12_WDATA),
          .M_AXI_12_WREADY(xbar_ptp_1_23_0_m_axi_12_WREADY),
          .M_AXI_12_WSTRB(xbar_ptp_1_23_0_m_axi_12_WSTRB),
          .M_AXI_12_WVALID(xbar_ptp_1_23_0_m_axi_12_WVALID),
          .M_AXI_13_ARADDR(xbar_ptp_1_23_0_m_axi_13_ARADDR),
          .M_AXI_13_ARPROT(xbar_ptp_1_23_0_m_axi_13_ARPROT),
          .M_AXI_13_ARREADY(xbar_ptp_1_23_0_m_axi_13_ARREADY),
          .M_AXI_13_ARVALID(xbar_ptp_1_23_0_m_axi_13_ARVALID),
          .M_AXI_13_AWADDR(xbar_ptp_1_23_0_m_axi_13_AWADDR),
          .M_AXI_13_AWPROT(xbar_ptp_1_23_0_m_axi_13_AWPROT),
          .M_AXI_13_AWREADY(xbar_ptp_1_23_0_m_axi_13_AWREADY),
          .M_AXI_13_AWVALID(xbar_ptp_1_23_0_m_axi_13_AWVALID),
          .M_AXI_13_BREADY(xbar_ptp_1_23_0_m_axi_13_BREADY),
          .M_AXI_13_BRESP(xbar_ptp_1_23_0_m_axi_13_BRESP),
          .M_AXI_13_BVALID(xbar_ptp_1_23_0_m_axi_13_BVALID),
          .M_AXI_13_RDATA(xbar_ptp_1_23_0_m_axi_13_RDATA),
          .M_AXI_13_RREADY(xbar_ptp_1_23_0_m_axi_13_RREADY),
          .M_AXI_13_RRESP(xbar_ptp_1_23_0_m_axi_13_RRESP),
          .M_AXI_13_RVALID(xbar_ptp_1_23_0_m_axi_13_RVALID),
          .M_AXI_13_WDATA(xbar_ptp_1_23_0_m_axi_13_WDATA),
          .M_AXI_13_WREADY(xbar_ptp_1_23_0_m_axi_13_WREADY),
          .M_AXI_13_WSTRB(xbar_ptp_1_23_0_m_axi_13_WSTRB),
          .M_AXI_13_WVALID(xbar_ptp_1_23_0_m_axi_13_WVALID),
          .M_AXI_14_ARADDR(xbar_ptp_1_23_0_m_axi_14_ARADDR),
          .M_AXI_14_ARPROT(xbar_ptp_1_23_0_m_axi_14_ARPROT),
          .M_AXI_14_ARREADY(xbar_ptp_1_23_0_m_axi_14_ARREADY),
          .M_AXI_14_ARVALID(xbar_ptp_1_23_0_m_axi_14_ARVALID),
          .M_AXI_14_AWADDR(xbar_ptp_1_23_0_m_axi_14_AWADDR),
          .M_AXI_14_AWPROT(xbar_ptp_1_23_0_m_axi_14_AWPROT),
          .M_AXI_14_AWREADY(xbar_ptp_1_23_0_m_axi_14_AWREADY),
          .M_AXI_14_AWVALID(xbar_ptp_1_23_0_m_axi_14_AWVALID),
          .M_AXI_14_BREADY(xbar_ptp_1_23_0_m_axi_14_BREADY),
          .M_AXI_14_BRESP(xbar_ptp_1_23_0_m_axi_14_BRESP),
          .M_AXI_14_BVALID(xbar_ptp_1_23_0_m_axi_14_BVALID),
          .M_AXI_14_RDATA(xbar_ptp_1_23_0_m_axi_14_RDATA),
          .M_AXI_14_RREADY(xbar_ptp_1_23_0_m_axi_14_RREADY),
          .M_AXI_14_RRESP(xbar_ptp_1_23_0_m_axi_14_RRESP),
          .M_AXI_14_RVALID(xbar_ptp_1_23_0_m_axi_14_RVALID),
          .M_AXI_14_WDATA(xbar_ptp_1_23_0_m_axi_14_WDATA),
          .M_AXI_14_WREADY(xbar_ptp_1_23_0_m_axi_14_WREADY),
          .M_AXI_14_WSTRB(xbar_ptp_1_23_0_m_axi_14_WSTRB),
          .M_AXI_14_WVALID(xbar_ptp_1_23_0_m_axi_14_WVALID),
          .M_AXI_15_ARADDR(xbar_ptp_1_23_0_m_axi_15_ARADDR),
          .M_AXI_15_ARPROT(xbar_ptp_1_23_0_m_axi_15_ARPROT),
          .M_AXI_15_ARREADY(xbar_ptp_1_23_0_m_axi_15_ARREADY),
          .M_AXI_15_ARVALID(xbar_ptp_1_23_0_m_axi_15_ARVALID),
          .M_AXI_15_AWADDR(xbar_ptp_1_23_0_m_axi_15_AWADDR),
          .M_AXI_15_AWPROT(xbar_ptp_1_23_0_m_axi_15_AWPROT),
          .M_AXI_15_AWREADY(xbar_ptp_1_23_0_m_axi_15_AWREADY),
          .M_AXI_15_AWVALID(xbar_ptp_1_23_0_m_axi_15_AWVALID),
          .M_AXI_15_BREADY(xbar_ptp_1_23_0_m_axi_15_BREADY),
          .M_AXI_15_BRESP(xbar_ptp_1_23_0_m_axi_15_BRESP),
          .M_AXI_15_BVALID(xbar_ptp_1_23_0_m_axi_15_BVALID),
          .M_AXI_15_RDATA(xbar_ptp_1_23_0_m_axi_15_RDATA),
          .M_AXI_15_RREADY(xbar_ptp_1_23_0_m_axi_15_RREADY),
          .M_AXI_15_RRESP(xbar_ptp_1_23_0_m_axi_15_RRESP),
          .M_AXI_15_RVALID(xbar_ptp_1_23_0_m_axi_15_RVALID),
          .M_AXI_15_WDATA(xbar_ptp_1_23_0_m_axi_15_WDATA),
          .M_AXI_15_WREADY(xbar_ptp_1_23_0_m_axi_15_WREADY),
          .M_AXI_15_WSTRB(xbar_ptp_1_23_0_m_axi_15_WSTRB),
          .M_AXI_15_WVALID(xbar_ptp_1_23_0_m_axi_15_WVALID),
          .M_AXI_16_ARADDR(xbar_ptp_1_23_0_m_axi_16_ARADDR),
          .M_AXI_16_ARPROT(xbar_ptp_1_23_0_m_axi_16_ARPROT),
          .M_AXI_16_ARREADY(xbar_ptp_1_23_0_m_axi_16_ARREADY),
          .M_AXI_16_ARVALID(xbar_ptp_1_23_0_m_axi_16_ARVALID),
          .M_AXI_16_AWADDR(xbar_ptp_1_23_0_m_axi_16_AWADDR),
          .M_AXI_16_AWPROT(xbar_ptp_1_23_0_m_axi_16_AWPROT),
          .M_AXI_16_AWREADY(xbar_ptp_1_23_0_m_axi_16_AWREADY),
          .M_AXI_16_AWVALID(xbar_ptp_1_23_0_m_axi_16_AWVALID),
          .M_AXI_16_BREADY(xbar_ptp_1_23_0_m_axi_16_BREADY),
          .M_AXI_16_BRESP(xbar_ptp_1_23_0_m_axi_16_BRESP),
          .M_AXI_16_BVALID(xbar_ptp_1_23_0_m_axi_16_BVALID),
          .M_AXI_16_RDATA(xbar_ptp_1_23_0_m_axi_16_RDATA),
          .M_AXI_16_RREADY(xbar_ptp_1_23_0_m_axi_16_RREADY),
          .M_AXI_16_RRESP(xbar_ptp_1_23_0_m_axi_16_RRESP),
          .M_AXI_16_RVALID(xbar_ptp_1_23_0_m_axi_16_RVALID),
          .M_AXI_16_WDATA(xbar_ptp_1_23_0_m_axi_16_WDATA),
          .M_AXI_16_WREADY(xbar_ptp_1_23_0_m_axi_16_WREADY),
          .M_AXI_16_WSTRB(xbar_ptp_1_23_0_m_axi_16_WSTRB),
          .M_AXI_16_WVALID(xbar_ptp_1_23_0_m_axi_16_WVALID),
          .M_AXI_17_ARADDR(xbar_ptp_1_23_0_m_axi_17_ARADDR),
          .M_AXI_17_ARPROT(xbar_ptp_1_23_0_m_axi_17_ARPROT),
          .M_AXI_17_ARREADY(xbar_ptp_1_23_0_m_axi_17_ARREADY),
          .M_AXI_17_ARVALID(xbar_ptp_1_23_0_m_axi_17_ARVALID),
          .M_AXI_17_AWADDR(xbar_ptp_1_23_0_m_axi_17_AWADDR),
          .M_AXI_17_AWPROT(xbar_ptp_1_23_0_m_axi_17_AWPROT),
          .M_AXI_17_AWREADY(xbar_ptp_1_23_0_m_axi_17_AWREADY),
          .M_AXI_17_AWVALID(xbar_ptp_1_23_0_m_axi_17_AWVALID),
          .M_AXI_17_BREADY(xbar_ptp_1_23_0_m_axi_17_BREADY),
          .M_AXI_17_BRESP(xbar_ptp_1_23_0_m_axi_17_BRESP),
          .M_AXI_17_BVALID(xbar_ptp_1_23_0_m_axi_17_BVALID),
          .M_AXI_17_RDATA(xbar_ptp_1_23_0_m_axi_17_RDATA),
          .M_AXI_17_RREADY(xbar_ptp_1_23_0_m_axi_17_RREADY),
          .M_AXI_17_RRESP(xbar_ptp_1_23_0_m_axi_17_RRESP),
          .M_AXI_17_RVALID(xbar_ptp_1_23_0_m_axi_17_RVALID),
          .M_AXI_17_WDATA(xbar_ptp_1_23_0_m_axi_17_WDATA),
          .M_AXI_17_WREADY(xbar_ptp_1_23_0_m_axi_17_WREADY),
          .M_AXI_17_WSTRB(xbar_ptp_1_23_0_m_axi_17_WSTRB),
          .M_AXI_17_WVALID(xbar_ptp_1_23_0_m_axi_17_WVALID),
          .M_AXI_18_ARADDR(xbar_ptp_1_23_0_m_axi_18_ARADDR),
          .M_AXI_18_ARPROT(xbar_ptp_1_23_0_m_axi_18_ARPROT),
          .M_AXI_18_ARREADY(xbar_ptp_1_23_0_m_axi_18_ARREADY),
          .M_AXI_18_ARVALID(xbar_ptp_1_23_0_m_axi_18_ARVALID),
          .M_AXI_18_AWADDR(xbar_ptp_1_23_0_m_axi_18_AWADDR),
          .M_AXI_18_AWPROT(xbar_ptp_1_23_0_m_axi_18_AWPROT),
          .M_AXI_18_AWREADY(xbar_ptp_1_23_0_m_axi_18_AWREADY),
          .M_AXI_18_AWVALID(xbar_ptp_1_23_0_m_axi_18_AWVALID),
          .M_AXI_18_BREADY(xbar_ptp_1_23_0_m_axi_18_BREADY),
          .M_AXI_18_BRESP(xbar_ptp_1_23_0_m_axi_18_BRESP),
          .M_AXI_18_BVALID(xbar_ptp_1_23_0_m_axi_18_BVALID),
          .M_AXI_18_RDATA(xbar_ptp_1_23_0_m_axi_18_RDATA),
          .M_AXI_18_RREADY(xbar_ptp_1_23_0_m_axi_18_RREADY),
          .M_AXI_18_RRESP(xbar_ptp_1_23_0_m_axi_18_RRESP),
          .M_AXI_18_RVALID(xbar_ptp_1_23_0_m_axi_18_RVALID),
          .M_AXI_18_WDATA(xbar_ptp_1_23_0_m_axi_18_WDATA),
          .M_AXI_18_WREADY(xbar_ptp_1_23_0_m_axi_18_WREADY),
          .M_AXI_18_WSTRB(xbar_ptp_1_23_0_m_axi_18_WSTRB),
          .M_AXI_18_WVALID(xbar_ptp_1_23_0_m_axi_18_WVALID),
          .M_AXI_19_ARADDR(xbar_ptp_1_23_0_m_axi_19_ARADDR),
          .M_AXI_19_ARPROT(xbar_ptp_1_23_0_m_axi_19_ARPROT),
          .M_AXI_19_ARREADY(xbar_ptp_1_23_0_m_axi_19_ARREADY),
          .M_AXI_19_ARVALID(xbar_ptp_1_23_0_m_axi_19_ARVALID),
          .M_AXI_19_AWADDR(xbar_ptp_1_23_0_m_axi_19_AWADDR),
          .M_AXI_19_AWPROT(xbar_ptp_1_23_0_m_axi_19_AWPROT),
          .M_AXI_19_AWREADY(xbar_ptp_1_23_0_m_axi_19_AWREADY),
          .M_AXI_19_AWVALID(xbar_ptp_1_23_0_m_axi_19_AWVALID),
          .M_AXI_19_BREADY(xbar_ptp_1_23_0_m_axi_19_BREADY),
          .M_AXI_19_BRESP(xbar_ptp_1_23_0_m_axi_19_BRESP),
          .M_AXI_19_BVALID(xbar_ptp_1_23_0_m_axi_19_BVALID),
          .M_AXI_19_RDATA(xbar_ptp_1_23_0_m_axi_19_RDATA),
          .M_AXI_19_RREADY(xbar_ptp_1_23_0_m_axi_19_RREADY),
          .M_AXI_19_RRESP(xbar_ptp_1_23_0_m_axi_19_RRESP),
          .M_AXI_19_RVALID(xbar_ptp_1_23_0_m_axi_19_RVALID),
          .M_AXI_19_WDATA(xbar_ptp_1_23_0_m_axi_19_WDATA),
          .M_AXI_19_WREADY(xbar_ptp_1_23_0_m_axi_19_WREADY),
          .M_AXI_19_WSTRB(xbar_ptp_1_23_0_m_axi_19_WSTRB),
          .M_AXI_19_WVALID(xbar_ptp_1_23_0_m_axi_19_WVALID),
          .M_AXI_20_ARADDR(xbar_ptp_1_23_0_m_axi_20_ARADDR),
          .M_AXI_20_ARPROT(xbar_ptp_1_23_0_m_axi_20_ARPROT),
          .M_AXI_20_ARREADY(xbar_ptp_1_23_0_m_axi_20_ARREADY),
          .M_AXI_20_ARVALID(xbar_ptp_1_23_0_m_axi_20_ARVALID),
          .M_AXI_20_AWADDR(xbar_ptp_1_23_0_m_axi_20_AWADDR),
          .M_AXI_20_AWPROT(xbar_ptp_1_23_0_m_axi_20_AWPROT),
          .M_AXI_20_AWREADY(xbar_ptp_1_23_0_m_axi_20_AWREADY),
          .M_AXI_20_AWVALID(xbar_ptp_1_23_0_m_axi_20_AWVALID),
          .M_AXI_20_BREADY(xbar_ptp_1_23_0_m_axi_20_BREADY),
          .M_AXI_20_BRESP(xbar_ptp_1_23_0_m_axi_20_BRESP),
          .M_AXI_20_BVALID(xbar_ptp_1_23_0_m_axi_20_BVALID),
          .M_AXI_20_RDATA(xbar_ptp_1_23_0_m_axi_20_RDATA),
          .M_AXI_20_RREADY(xbar_ptp_1_23_0_m_axi_20_RREADY),
          .M_AXI_20_RRESP(xbar_ptp_1_23_0_m_axi_20_RRESP),
          .M_AXI_20_RVALID(xbar_ptp_1_23_0_m_axi_20_RVALID),
          .M_AXI_20_WDATA(xbar_ptp_1_23_0_m_axi_20_WDATA),
          .M_AXI_20_WREADY(xbar_ptp_1_23_0_m_axi_20_WREADY),
          .M_AXI_20_WSTRB(xbar_ptp_1_23_0_m_axi_20_WSTRB),
          .M_AXI_20_WVALID(xbar_ptp_1_23_0_m_axi_20_WVALID),
          .M_AXI_21_ARADDR(xbar_ptp_1_23_0_m_axi_21_ARADDR),
          .M_AXI_21_ARPROT(xbar_ptp_1_23_0_m_axi_21_ARPROT),
          .M_AXI_21_ARREADY(xbar_ptp_1_23_0_m_axi_21_ARREADY),
          .M_AXI_21_ARVALID(xbar_ptp_1_23_0_m_axi_21_ARVALID),
          .M_AXI_21_AWADDR(xbar_ptp_1_23_0_m_axi_21_AWADDR),
          .M_AXI_21_AWPROT(xbar_ptp_1_23_0_m_axi_21_AWPROT),
          .M_AXI_21_AWREADY(xbar_ptp_1_23_0_m_axi_21_AWREADY),
          .M_AXI_21_AWVALID(xbar_ptp_1_23_0_m_axi_21_AWVALID),
          .M_AXI_21_BREADY(xbar_ptp_1_23_0_m_axi_21_BREADY),
          .M_AXI_21_BRESP(xbar_ptp_1_23_0_m_axi_21_BRESP),
          .M_AXI_21_BVALID(xbar_ptp_1_23_0_m_axi_21_BVALID),
          .M_AXI_21_RDATA(xbar_ptp_1_23_0_m_axi_21_RDATA),
          .M_AXI_21_RREADY(xbar_ptp_1_23_0_m_axi_21_RREADY),
          .M_AXI_21_RRESP(xbar_ptp_1_23_0_m_axi_21_RRESP),
          .M_AXI_21_RVALID(xbar_ptp_1_23_0_m_axi_21_RVALID),
          .M_AXI_21_WDATA(xbar_ptp_1_23_0_m_axi_21_WDATA),
          .M_AXI_21_WREADY(xbar_ptp_1_23_0_m_axi_21_WREADY),
          .M_AXI_21_WSTRB(xbar_ptp_1_23_0_m_axi_21_WSTRB),
          .M_AXI_21_WVALID(xbar_ptp_1_23_0_m_axi_21_WVALID),
          .M_AXI_22_ARADDR(xbar_ptp_1_23_0_m_axi_22_ARADDR),
          .M_AXI_22_ARPROT(xbar_ptp_1_23_0_m_axi_22_ARPROT),
          .M_AXI_22_ARREADY(xbar_ptp_1_23_0_m_axi_22_ARREADY),
          .M_AXI_22_ARVALID(xbar_ptp_1_23_0_m_axi_22_ARVALID),
          .M_AXI_22_AWADDR(xbar_ptp_1_23_0_m_axi_22_AWADDR),
          .M_AXI_22_AWPROT(xbar_ptp_1_23_0_m_axi_22_AWPROT),
          .M_AXI_22_AWREADY(xbar_ptp_1_23_0_m_axi_22_AWREADY),
          .M_AXI_22_AWVALID(xbar_ptp_1_23_0_m_axi_22_AWVALID),
          .M_AXI_22_BREADY(xbar_ptp_1_23_0_m_axi_22_BREADY),
          .M_AXI_22_BRESP(xbar_ptp_1_23_0_m_axi_22_BRESP),
          .M_AXI_22_BVALID(xbar_ptp_1_23_0_m_axi_22_BVALID),
          .M_AXI_22_RDATA(xbar_ptp_1_23_0_m_axi_22_RDATA),
          .M_AXI_22_RREADY(xbar_ptp_1_23_0_m_axi_22_RREADY),
          .M_AXI_22_RRESP(xbar_ptp_1_23_0_m_axi_22_RRESP),
          .M_AXI_22_RVALID(xbar_ptp_1_23_0_m_axi_22_RVALID),
          .M_AXI_22_WDATA(xbar_ptp_1_23_0_m_axi_22_WDATA),
          .M_AXI_22_WREADY(xbar_ptp_1_23_0_m_axi_22_WREADY),
          .M_AXI_22_WSTRB(xbar_ptp_1_23_0_m_axi_22_WSTRB),
          .M_AXI_22_WVALID(xbar_ptp_1_23_0_m_axi_22_WVALID),
          .M_AXI_23_ARADDR(xbar_ptp_1_23_0_m_axi_23_ARADDR),
          .M_AXI_23_ARPROT(xbar_ptp_1_23_0_m_axi_23_ARPROT),
          .M_AXI_23_ARREADY(xbar_ptp_1_23_0_m_axi_23_ARREADY),
          .M_AXI_23_ARVALID(xbar_ptp_1_23_0_m_axi_23_ARVALID),
          .M_AXI_23_AWADDR(xbar_ptp_1_23_0_m_axi_23_AWADDR),
          .M_AXI_23_AWPROT(xbar_ptp_1_23_0_m_axi_23_AWPROT),
          .M_AXI_23_AWREADY(xbar_ptp_1_23_0_m_axi_23_AWREADY),
          .M_AXI_23_AWVALID(xbar_ptp_1_23_0_m_axi_23_AWVALID),
          .M_AXI_23_BREADY(xbar_ptp_1_23_0_m_axi_23_BREADY),
          .M_AXI_23_BRESP(xbar_ptp_1_23_0_m_axi_23_BRESP),
          .M_AXI_23_BVALID(xbar_ptp_1_23_0_m_axi_23_BVALID),
          .M_AXI_23_RDATA(xbar_ptp_1_23_0_m_axi_23_RDATA),
          .M_AXI_23_RREADY(xbar_ptp_1_23_0_m_axi_23_RREADY),
          .M_AXI_23_RRESP(xbar_ptp_1_23_0_m_axi_23_RRESP),
          .M_AXI_23_RVALID(xbar_ptp_1_23_0_m_axi_23_RVALID),
          .M_AXI_23_WDATA(xbar_ptp_1_23_0_m_axi_23_WDATA),
          .M_AXI_23_WREADY(xbar_ptp_1_23_0_m_axi_23_WREADY),
          .M_AXI_23_WSTRB(xbar_ptp_1_23_0_m_axi_23_WSTRB),
          .M_AXI_23_WVALID(xbar_ptp_1_23_0_m_axi_23_WVALID));
     wire [31:0]xbar_sys_1_15_0_m_axi_11_ARADDR;
     wire xbar_sys_1_15_0_m_axi_11_ARREADY;
     wire xbar_sys_1_15_0_m_axi_11_ARVALID;
     wire [31:0]xbar_sys_1_15_0_m_axi_11_AWADDR;
     wire xbar_sys_1_15_0_m_axi_11_AWREADY;
     wire xbar_sys_1_15_0_m_axi_11_AWVALID;
     wire xbar_sys_1_15_0_m_axi_11_BREADY;
     wire [1:0]xbar_sys_1_15_0_m_axi_11_BRESP;
     wire xbar_sys_1_15_0_m_axi_11_BVALID;
     wire [31:0]xbar_sys_1_15_0_m_axi_11_RDATA;
     wire xbar_sys_1_15_0_m_axi_11_RREADY;
     wire [1:0]xbar_sys_1_15_0_m_axi_11_RRESP;
     wire xbar_sys_1_15_0_m_axi_11_RVALID;
     wire [31:0]xbar_sys_1_15_0_m_axi_11_WDATA;
     wire xbar_sys_1_15_0_m_axi_11_WREADY;
     wire [3:0]xbar_sys_1_15_0_m_axi_11_WSTRB;
     wire xbar_sys_1_15_0_m_axi_11_WVALID;
     wire [31:0]xbar_sys_1_15_0_m_axi_12_ARADDR;
     wire xbar_sys_1_15_0_m_axi_12_ARREADY;
     wire xbar_sys_1_15_0_m_axi_12_ARVALID;
     wire [31:0]xbar_sys_1_15_0_m_axi_12_AWADDR;
     wire xbar_sys_1_15_0_m_axi_12_AWREADY;
     wire xbar_sys_1_15_0_m_axi_12_AWVALID;
     wire xbar_sys_1_15_0_m_axi_12_BREADY;
     wire [1:0]xbar_sys_1_15_0_m_axi_12_BRESP;
     wire xbar_sys_1_15_0_m_axi_12_BVALID;
     wire [31:0]xbar_sys_1_15_0_m_axi_12_RDATA;
     wire xbar_sys_1_15_0_m_axi_12_RREADY;
     wire [1:0]xbar_sys_1_15_0_m_axi_12_RRESP;
     wire xbar_sys_1_15_0_m_axi_12_RVALID;
     wire [31:0]xbar_sys_1_15_0_m_axi_12_WDATA;
     wire xbar_sys_1_15_0_m_axi_12_WREADY;
     wire [3:0]xbar_sys_1_15_0_m_axi_12_WSTRB;
     wire xbar_sys_1_15_0_m_axi_12_WVALID;
     wire [31:0]xbar_sys_1_15_0_m_axi_13_ARADDR;
     wire [2:0]xbar_sys_1_15_0_m_axi_13_ARPROT;
     wire xbar_sys_1_15_0_m_axi_13_ARREADY;
     wire xbar_sys_1_15_0_m_axi_13_ARVALID;
     wire [31:0]xbar_sys_1_15_0_m_axi_13_AWADDR;
     wire [2:0]xbar_sys_1_15_0_m_axi_13_AWPROT;
     wire xbar_sys_1_15_0_m_axi_13_AWREADY;
     wire xbar_sys_1_15_0_m_axi_13_AWVALID;
     wire xbar_sys_1_15_0_m_axi_13_BREADY;
     wire [1:0]xbar_sys_1_15_0_m_axi_13_BRESP;
     wire xbar_sys_1_15_0_m_axi_13_BVALID;
     wire [31:0]xbar_sys_1_15_0_m_axi_13_RDATA;
     wire xbar_sys_1_15_0_m_axi_13_RREADY;
     wire [1:0]xbar_sys_1_15_0_m_axi_13_RRESP;
     wire xbar_sys_1_15_0_m_axi_13_RVALID;
     wire [31:0]xbar_sys_1_15_0_m_axi_13_WDATA;
     wire xbar_sys_1_15_0_m_axi_13_WREADY;
     wire [3:0]xbar_sys_1_15_0_m_axi_13_WSTRB;
     wire xbar_sys_1_15_0_m_axi_13_WVALID;
     wire [31:0]xbar_sys_1_15_0_m_axi_15_ARADDR;
     wire xbar_sys_1_15_0_m_axi_15_ARREADY;
     wire xbar_sys_1_15_0_m_axi_15_ARVALID;
     wire [31:0]xbar_sys_1_15_0_m_axi_15_AWADDR;
     wire xbar_sys_1_15_0_m_axi_15_AWREADY;
     wire xbar_sys_1_15_0_m_axi_15_AWVALID;
     wire xbar_sys_1_15_0_m_axi_15_BREADY;
     wire [1:0]xbar_sys_1_15_0_m_axi_15_BRESP;
     wire xbar_sys_1_15_0_m_axi_15_BVALID;
     wire [31:0]xbar_sys_1_15_0_m_axi_15_RDATA;
     wire xbar_sys_1_15_0_m_axi_15_RREADY;
     wire [1:0]xbar_sys_1_15_0_m_axi_15_RRESP;
     wire xbar_sys_1_15_0_m_axi_15_RVALID;
     wire [31:0]xbar_sys_1_15_0_m_axi_15_WDATA;
     wire xbar_sys_1_15_0_m_axi_15_WREADY;
     wire [3:0]xbar_sys_1_15_0_m_axi_15_WSTRB;
     wire xbar_sys_1_15_0_m_axi_15_WVALID;
     wire [31:0]xbar_sys_1_15_0_m_axi_1_ARADDR;
     wire [2:0]xbar_sys_1_15_0_m_axi_1_ARPROT;
     wire xbar_sys_1_15_0_m_axi_1_ARREADY;
     wire xbar_sys_1_15_0_m_axi_1_ARVALID;
     wire [31:0]xbar_sys_1_15_0_m_axi_1_AWADDR;
     wire [2:0]xbar_sys_1_15_0_m_axi_1_AWPROT;
     wire xbar_sys_1_15_0_m_axi_1_AWREADY;
     wire xbar_sys_1_15_0_m_axi_1_AWVALID;
     wire xbar_sys_1_15_0_m_axi_1_BREADY;
     wire [1:0]xbar_sys_1_15_0_m_axi_1_BRESP;
     wire xbar_sys_1_15_0_m_axi_1_BVALID;
     wire [31:0]xbar_sys_1_15_0_m_axi_1_RDATA;
     wire xbar_sys_1_15_0_m_axi_1_RREADY;
     wire [1:0]xbar_sys_1_15_0_m_axi_1_RRESP;
     wire xbar_sys_1_15_0_m_axi_1_RVALID;
     wire [31:0]xbar_sys_1_15_0_m_axi_1_WDATA;
     wire xbar_sys_1_15_0_m_axi_1_WREADY;
     wire [3:0]xbar_sys_1_15_0_m_axi_1_WSTRB;
     wire xbar_sys_1_15_0_m_axi_1_WVALID;
     wire [31:0]xbar_sys_1_15_0_m_axi_2_ARADDR;
     wire xbar_sys_1_15_0_m_axi_2_ARREADY;
     wire xbar_sys_1_15_0_m_axi_2_ARVALID;
     wire [31:0]xbar_sys_1_15_0_m_axi_2_AWADDR;
     wire xbar_sys_1_15_0_m_axi_2_AWREADY;
     wire xbar_sys_1_15_0_m_axi_2_AWVALID;
     wire xbar_sys_1_15_0_m_axi_2_BREADY;
     wire [1:0]xbar_sys_1_15_0_m_axi_2_BRESP;
     wire xbar_sys_1_15_0_m_axi_2_BVALID;
     wire [31:0]xbar_sys_1_15_0_m_axi_2_RDATA;
     wire xbar_sys_1_15_0_m_axi_2_RREADY;
     wire [1:0]xbar_sys_1_15_0_m_axi_2_RRESP;
     wire xbar_sys_1_15_0_m_axi_2_RVALID;
     wire [31:0]xbar_sys_1_15_0_m_axi_2_WDATA;
     wire xbar_sys_1_15_0_m_axi_2_WREADY;
     wire [3:0]xbar_sys_1_15_0_m_axi_2_WSTRB;
     wire xbar_sys_1_15_0_m_axi_2_WVALID;
     wire [31:0]xbar_sys_1_15_0_m_axi_3_ARADDR;
     wire xbar_sys_1_15_0_m_axi_3_ARREADY;
     wire xbar_sys_1_15_0_m_axi_3_ARVALID;
     wire [31:0]xbar_sys_1_15_0_m_axi_3_AWADDR;
     wire xbar_sys_1_15_0_m_axi_3_AWREADY;
     wire xbar_sys_1_15_0_m_axi_3_AWVALID;
     wire xbar_sys_1_15_0_m_axi_3_BREADY;
     wire [1:0]xbar_sys_1_15_0_m_axi_3_BRESP;
     wire xbar_sys_1_15_0_m_axi_3_BVALID;
     wire [31:0]xbar_sys_1_15_0_m_axi_3_RDATA;
     wire xbar_sys_1_15_0_m_axi_3_RREADY;
     wire [1:0]xbar_sys_1_15_0_m_axi_3_RRESP;
     wire xbar_sys_1_15_0_m_axi_3_RVALID;
     wire [31:0]xbar_sys_1_15_0_m_axi_3_WDATA;
     wire xbar_sys_1_15_0_m_axi_3_WREADY;
     wire [3:0]xbar_sys_1_15_0_m_axi_3_WSTRB;
     wire xbar_sys_1_15_0_m_axi_3_WVALID;
     wire [31:0]xbar_sys_1_15_0_m_axi_4_ARADDR;
     wire [2:0]xbar_sys_1_15_0_m_axi_4_ARPROT;
     wire xbar_sys_1_15_0_m_axi_4_ARREADY;
     wire xbar_sys_1_15_0_m_axi_4_ARVALID;
     wire [31:0]xbar_sys_1_15_0_m_axi_4_AWADDR;
     wire [2:0]xbar_sys_1_15_0_m_axi_4_AWPROT;
     wire xbar_sys_1_15_0_m_axi_4_AWREADY;
     wire xbar_sys_1_15_0_m_axi_4_AWVALID;
     wire xbar_sys_1_15_0_m_axi_4_BREADY;
     wire [1:0]xbar_sys_1_15_0_m_axi_4_BRESP;
     wire xbar_sys_1_15_0_m_axi_4_BVALID;
     wire [31:0]xbar_sys_1_15_0_m_axi_4_RDATA;
     wire xbar_sys_1_15_0_m_axi_4_RREADY;
     wire [1:0]xbar_sys_1_15_0_m_axi_4_RRESP;
     wire xbar_sys_1_15_0_m_axi_4_RVALID;
     wire [31:0]xbar_sys_1_15_0_m_axi_4_WDATA;
     wire xbar_sys_1_15_0_m_axi_4_WREADY;
     wire [3:0]xbar_sys_1_15_0_m_axi_4_WSTRB;
     wire xbar_sys_1_15_0_m_axi_4_WVALID;
     wire [31:0]xbar_sys_1_15_0_m_axi_5_ARADDR;
     wire [2:0]xbar_sys_1_15_0_m_axi_5_ARPROT;
     wire xbar_sys_1_15_0_m_axi_5_ARREADY;
     wire xbar_sys_1_15_0_m_axi_5_ARVALID;
     wire [31:0]xbar_sys_1_15_0_m_axi_5_AWADDR;
     wire [2:0]xbar_sys_1_15_0_m_axi_5_AWPROT;
     wire xbar_sys_1_15_0_m_axi_5_AWREADY;
     wire xbar_sys_1_15_0_m_axi_5_AWVALID;
     wire xbar_sys_1_15_0_m_axi_5_BREADY;
     wire [1:0]xbar_sys_1_15_0_m_axi_5_BRESP;
     wire xbar_sys_1_15_0_m_axi_5_BVALID;
     wire [31:0]xbar_sys_1_15_0_m_axi_5_RDATA;
     wire xbar_sys_1_15_0_m_axi_5_RREADY;
     wire [1:0]xbar_sys_1_15_0_m_axi_5_RRESP;
     wire xbar_sys_1_15_0_m_axi_5_RVALID;
     wire [31:0]xbar_sys_1_15_0_m_axi_5_WDATA;
     wire xbar_sys_1_15_0_m_axi_5_WREADY;
     wire [3:0]xbar_sys_1_15_0_m_axi_5_WSTRB;
     wire xbar_sys_1_15_0_m_axi_5_WVALID;
     wire [31:0]xbar_sys_1_15_0_m_axi_6_ARADDR;
     wire xbar_sys_1_15_0_m_axi_6_ARREADY;
     wire xbar_sys_1_15_0_m_axi_6_ARVALID;
     wire [31:0]xbar_sys_1_15_0_m_axi_6_AWADDR;
     wire xbar_sys_1_15_0_m_axi_6_AWREADY;
     wire xbar_sys_1_15_0_m_axi_6_AWVALID;
     wire xbar_sys_1_15_0_m_axi_6_BREADY;
     wire [1:0]xbar_sys_1_15_0_m_axi_6_BRESP;
     wire xbar_sys_1_15_0_m_axi_6_BVALID;
     wire [31:0]xbar_sys_1_15_0_m_axi_6_RDATA;
     wire xbar_sys_1_15_0_m_axi_6_RREADY;
     wire [1:0]xbar_sys_1_15_0_m_axi_6_RRESP;
     wire xbar_sys_1_15_0_m_axi_6_RVALID;
     wire [31:0]xbar_sys_1_15_0_m_axi_6_WDATA;
     wire xbar_sys_1_15_0_m_axi_6_WREADY;
     wire [3:0]xbar_sys_1_15_0_m_axi_6_WSTRB;
     wire xbar_sys_1_15_0_m_axi_6_WVALID;
     wire [31:0]xbar_sys_1_15_0_m_axi_7_ARADDR;
     wire xbar_sys_1_15_0_m_axi_7_ARREADY;
     wire xbar_sys_1_15_0_m_axi_7_ARVALID;
     wire [31:0]xbar_sys_1_15_0_m_axi_7_AWADDR;
     wire xbar_sys_1_15_0_m_axi_7_AWREADY;
     wire xbar_sys_1_15_0_m_axi_7_AWVALID;
     wire xbar_sys_1_15_0_m_axi_7_BREADY;
     wire [1:0]xbar_sys_1_15_0_m_axi_7_BRESP;
     wire xbar_sys_1_15_0_m_axi_7_BVALID;
     wire [31:0]xbar_sys_1_15_0_m_axi_7_RDATA;
     wire xbar_sys_1_15_0_m_axi_7_RREADY;
     wire [1:0]xbar_sys_1_15_0_m_axi_7_RRESP;
     wire xbar_sys_1_15_0_m_axi_7_RVALID;
     wire [31:0]xbar_sys_1_15_0_m_axi_7_WDATA;
     wire xbar_sys_1_15_0_m_axi_7_WREADY;
     wire [3:0]xbar_sys_1_15_0_m_axi_7_WSTRB;
     wire xbar_sys_1_15_0_m_axi_7_WVALID;
     wire [31:0]xbar_sys_1_15_0_m_axi_8_ARADDR;
     wire xbar_sys_1_15_0_m_axi_8_ARREADY;
     wire xbar_sys_1_15_0_m_axi_8_ARVALID;
     wire [31:0]xbar_sys_1_15_0_m_axi_8_AWADDR;
     wire xbar_sys_1_15_0_m_axi_8_AWREADY;
     wire xbar_sys_1_15_0_m_axi_8_AWVALID;
     wire xbar_sys_1_15_0_m_axi_8_BREADY;
     wire [1:0]xbar_sys_1_15_0_m_axi_8_BRESP;
     wire xbar_sys_1_15_0_m_axi_8_BVALID;
     wire [31:0]xbar_sys_1_15_0_m_axi_8_RDATA;
     wire xbar_sys_1_15_0_m_axi_8_RREADY;
     wire [1:0]xbar_sys_1_15_0_m_axi_8_RRESP;
     wire xbar_sys_1_15_0_m_axi_8_RVALID;
     wire [31:0]xbar_sys_1_15_0_m_axi_8_WDATA;
     wire xbar_sys_1_15_0_m_axi_8_WREADY;
     wire [3:0]xbar_sys_1_15_0_m_axi_8_WSTRB;
     wire xbar_sys_1_15_0_m_axi_8_WVALID;
     wire [31:0]xbar_sys_1_15_0_m_axi_9_ARADDR;
     wire xbar_sys_1_15_0_m_axi_9_ARREADY;
     wire xbar_sys_1_15_0_m_axi_9_ARVALID;
     wire [31:0]xbar_sys_1_15_0_m_axi_9_AWADDR;
     wire xbar_sys_1_15_0_m_axi_9_AWREADY;
     wire xbar_sys_1_15_0_m_axi_9_AWVALID;
     wire xbar_sys_1_15_0_m_axi_9_BREADY;
     wire [1:0]xbar_sys_1_15_0_m_axi_9_BRESP;
     wire xbar_sys_1_15_0_m_axi_9_BVALID;
     wire [31:0]xbar_sys_1_15_0_m_axi_9_RDATA;
     wire xbar_sys_1_15_0_m_axi_9_RREADY;
     wire [1:0]xbar_sys_1_15_0_m_axi_9_RRESP;
     wire xbar_sys_1_15_0_m_axi_9_RVALID;
     wire [31:0]xbar_sys_1_15_0_m_axi_9_WDATA;
     wire xbar_sys_1_15_0_m_axi_9_WREADY;
     wire [3:0]xbar_sys_1_15_0_m_axi_9_WSTRB;
     wire xbar_sys_1_15_0_m_axi_9_WVALID;
     xbar_sys_1_15 xbar_sys_1_15_0 (
          .S_AXI_ACLK(SYS_M_AXI_ACLK),
          .S_AXI_ARESETN(axixclk_al2al_0_M_AXI_ARESETN),
          .S_AXI_0_ARADDR(axixclk_al2al_0_M_AXI_ARADDR),
          .S_AXI_0_ARPROT(axixclk_al2al_0_M_AXI_ARPROT),
          .S_AXI_0_ARREADY(axixclk_al2al_0_M_AXI_ARREADY),
          .S_AXI_0_ARVALID(axixclk_al2al_0_M_AXI_ARVALID),
          .S_AXI_0_AWADDR(axixclk_al2al_0_M_AXI_AWADDR),
          .S_AXI_0_AWPROT(axixclk_al2al_0_M_AXI_AWPROT),
          .S_AXI_0_AWREADY(axixclk_al2al_0_M_AXI_AWREADY),
          .S_AXI_0_AWVALID(axixclk_al2al_0_M_AXI_AWVALID),
          .S_AXI_0_BREADY(axixclk_al2al_0_M_AXI_BREADY),
          .S_AXI_0_BRESP(axixclk_al2al_0_M_AXI_BRESP),
          .S_AXI_0_BVALID(axixclk_al2al_0_M_AXI_BVALID),
          .S_AXI_0_RDATA(axixclk_al2al_0_M_AXI_RDATA),
          .S_AXI_0_RREADY(axixclk_al2al_0_M_AXI_RREADY),
          .S_AXI_0_RRESP(axixclk_al2al_0_M_AXI_RRESP),
          .S_AXI_0_RVALID(axixclk_al2al_0_M_AXI_RVALID),
          .S_AXI_0_WDATA(axixclk_al2al_0_M_AXI_WDATA),
          .S_AXI_0_WREADY(axixclk_al2al_0_M_AXI_WREADY),
          .S_AXI_0_WSTRB(axixclk_al2al_0_M_AXI_WSTRB),
          .S_AXI_0_WVALID(axixclk_al2al_0_M_AXI_WVALID),
          .M_AXI_0_ARREADY(1'b1),
          .M_AXI_0_AWREADY(1'b1),
          .M_AXI_0_BRESP(2'b0),
          .M_AXI_0_BVALID(1'b1),
          .M_AXI_0_RDATA(32'hdead0000),
          .M_AXI_0_RRESP(2'b0),
          .M_AXI_0_RVALID(1'b1),
          .M_AXI_0_WREADY(1'b1),
          .M_AXI_1_ARADDR(xbar_sys_1_15_0_m_axi_1_ARADDR),
          .M_AXI_1_ARPROT(xbar_sys_1_15_0_m_axi_1_ARPROT),
          .M_AXI_1_ARREADY(xbar_sys_1_15_0_m_axi_1_ARREADY),
          .M_AXI_1_ARVALID(xbar_sys_1_15_0_m_axi_1_ARVALID),
          .M_AXI_1_AWADDR(xbar_sys_1_15_0_m_axi_1_AWADDR),
          .M_AXI_1_AWPROT(xbar_sys_1_15_0_m_axi_1_AWPROT),
          .M_AXI_1_AWREADY(xbar_sys_1_15_0_m_axi_1_AWREADY),
          .M_AXI_1_AWVALID(xbar_sys_1_15_0_m_axi_1_AWVALID),
          .M_AXI_1_BREADY(xbar_sys_1_15_0_m_axi_1_BREADY),
          .M_AXI_1_BRESP(xbar_sys_1_15_0_m_axi_1_BRESP),
          .M_AXI_1_BVALID(xbar_sys_1_15_0_m_axi_1_BVALID),
          .M_AXI_1_RDATA(xbar_sys_1_15_0_m_axi_1_RDATA),
          .M_AXI_1_RREADY(xbar_sys_1_15_0_m_axi_1_RREADY),
          .M_AXI_1_RRESP(xbar_sys_1_15_0_m_axi_1_RRESP),
          .M_AXI_1_RVALID(xbar_sys_1_15_0_m_axi_1_RVALID),
          .M_AXI_1_WDATA(xbar_sys_1_15_0_m_axi_1_WDATA),
          .M_AXI_1_WREADY(xbar_sys_1_15_0_m_axi_1_WREADY),
          .M_AXI_1_WSTRB(xbar_sys_1_15_0_m_axi_1_WSTRB),
          .M_AXI_1_WVALID(xbar_sys_1_15_0_m_axi_1_WVALID),
          .M_AXI_2_ARADDR(xbar_sys_1_15_0_m_axi_2_ARADDR),
          .M_AXI_2_ARREADY(xbar_sys_1_15_0_m_axi_2_ARREADY),
          .M_AXI_2_ARVALID(xbar_sys_1_15_0_m_axi_2_ARVALID),
          .M_AXI_2_AWADDR(xbar_sys_1_15_0_m_axi_2_AWADDR),
          .M_AXI_2_AWREADY(xbar_sys_1_15_0_m_axi_2_AWREADY),
          .M_AXI_2_AWVALID(xbar_sys_1_15_0_m_axi_2_AWVALID),
          .M_AXI_2_BREADY(xbar_sys_1_15_0_m_axi_2_BREADY),
          .M_AXI_2_BRESP(xbar_sys_1_15_0_m_axi_2_BRESP),
          .M_AXI_2_BVALID(xbar_sys_1_15_0_m_axi_2_BVALID),
          .M_AXI_2_RDATA(xbar_sys_1_15_0_m_axi_2_RDATA),
          .M_AXI_2_RREADY(xbar_sys_1_15_0_m_axi_2_RREADY),
          .M_AXI_2_RRESP(xbar_sys_1_15_0_m_axi_2_RRESP),
          .M_AXI_2_RVALID(xbar_sys_1_15_0_m_axi_2_RVALID),
          .M_AXI_2_WDATA(xbar_sys_1_15_0_m_axi_2_WDATA),
          .M_AXI_2_WREADY(xbar_sys_1_15_0_m_axi_2_WREADY),
          .M_AXI_2_WSTRB(xbar_sys_1_15_0_m_axi_2_WSTRB),
          .M_AXI_2_WVALID(xbar_sys_1_15_0_m_axi_2_WVALID),
          .M_AXI_3_ARADDR(xbar_sys_1_15_0_m_axi_3_ARADDR),
          .M_AXI_3_ARREADY(xbar_sys_1_15_0_m_axi_3_ARREADY),
          .M_AXI_3_ARVALID(xbar_sys_1_15_0_m_axi_3_ARVALID),
          .M_AXI_3_AWADDR(xbar_sys_1_15_0_m_axi_3_AWADDR),
          .M_AXI_3_AWREADY(xbar_sys_1_15_0_m_axi_3_AWREADY),
          .M_AXI_3_AWVALID(xbar_sys_1_15_0_m_axi_3_AWVALID),
          .M_AXI_3_BREADY(xbar_sys_1_15_0_m_axi_3_BREADY),
          .M_AXI_3_BRESP(xbar_sys_1_15_0_m_axi_3_BRESP),
          .M_AXI_3_BVALID(xbar_sys_1_15_0_m_axi_3_BVALID),
          .M_AXI_3_RDATA(xbar_sys_1_15_0_m_axi_3_RDATA),
          .M_AXI_3_RREADY(xbar_sys_1_15_0_m_axi_3_RREADY),
          .M_AXI_3_RRESP(xbar_sys_1_15_0_m_axi_3_RRESP),
          .M_AXI_3_RVALID(xbar_sys_1_15_0_m_axi_3_RVALID),
          .M_AXI_3_WDATA(xbar_sys_1_15_0_m_axi_3_WDATA),
          .M_AXI_3_WREADY(xbar_sys_1_15_0_m_axi_3_WREADY),
          .M_AXI_3_WSTRB(xbar_sys_1_15_0_m_axi_3_WSTRB),
          .M_AXI_3_WVALID(xbar_sys_1_15_0_m_axi_3_WVALID),
          .M_AXI_4_ARADDR(xbar_sys_1_15_0_m_axi_4_ARADDR),
          .M_AXI_4_ARPROT(xbar_sys_1_15_0_m_axi_4_ARPROT),
          .M_AXI_4_ARREADY(xbar_sys_1_15_0_m_axi_4_ARREADY),
          .M_AXI_4_ARVALID(xbar_sys_1_15_0_m_axi_4_ARVALID),
          .M_AXI_4_AWADDR(xbar_sys_1_15_0_m_axi_4_AWADDR),
          .M_AXI_4_AWPROT(xbar_sys_1_15_0_m_axi_4_AWPROT),
          .M_AXI_4_AWREADY(xbar_sys_1_15_0_m_axi_4_AWREADY),
          .M_AXI_4_AWVALID(xbar_sys_1_15_0_m_axi_4_AWVALID),
          .M_AXI_4_BREADY(xbar_sys_1_15_0_m_axi_4_BREADY),
          .M_AXI_4_BRESP(xbar_sys_1_15_0_m_axi_4_BRESP),
          .M_AXI_4_BVALID(xbar_sys_1_15_0_m_axi_4_BVALID),
          .M_AXI_4_RDATA(xbar_sys_1_15_0_m_axi_4_RDATA),
          .M_AXI_4_RREADY(xbar_sys_1_15_0_m_axi_4_RREADY),
          .M_AXI_4_RRESP(xbar_sys_1_15_0_m_axi_4_RRESP),
          .M_AXI_4_RVALID(xbar_sys_1_15_0_m_axi_4_RVALID),
          .M_AXI_4_WDATA(xbar_sys_1_15_0_m_axi_4_WDATA),
          .M_AXI_4_WREADY(xbar_sys_1_15_0_m_axi_4_WREADY),
          .M_AXI_4_WSTRB(xbar_sys_1_15_0_m_axi_4_WSTRB),
          .M_AXI_4_WVALID(xbar_sys_1_15_0_m_axi_4_WVALID),
          .M_AXI_5_ARADDR(xbar_sys_1_15_0_m_axi_5_ARADDR),
          .M_AXI_5_ARPROT(xbar_sys_1_15_0_m_axi_5_ARPROT),
          .M_AXI_5_ARREADY(xbar_sys_1_15_0_m_axi_5_ARREADY),
          .M_AXI_5_ARVALID(xbar_sys_1_15_0_m_axi_5_ARVALID),
          .M_AXI_5_AWADDR(xbar_sys_1_15_0_m_axi_5_AWADDR),
          .M_AXI_5_AWPROT(xbar_sys_1_15_0_m_axi_5_AWPROT),
          .M_AXI_5_AWREADY(xbar_sys_1_15_0_m_axi_5_AWREADY),
          .M_AXI_5_AWVALID(xbar_sys_1_15_0_m_axi_5_AWVALID),
          .M_AXI_5_BREADY(xbar_sys_1_15_0_m_axi_5_BREADY),
          .M_AXI_5_BRESP(xbar_sys_1_15_0_m_axi_5_BRESP),
          .M_AXI_5_BVALID(xbar_sys_1_15_0_m_axi_5_BVALID),
          .M_AXI_5_RDATA(xbar_sys_1_15_0_m_axi_5_RDATA),
          .M_AXI_5_RREADY(xbar_sys_1_15_0_m_axi_5_RREADY),
          .M_AXI_5_RRESP(xbar_sys_1_15_0_m_axi_5_RRESP),
          .M_AXI_5_RVALID(xbar_sys_1_15_0_m_axi_5_RVALID),
          .M_AXI_5_WDATA(xbar_sys_1_15_0_m_axi_5_WDATA),
          .M_AXI_5_WREADY(xbar_sys_1_15_0_m_axi_5_WREADY),
          .M_AXI_5_WSTRB(xbar_sys_1_15_0_m_axi_5_WSTRB),
          .M_AXI_5_WVALID(xbar_sys_1_15_0_m_axi_5_WVALID),
          .M_AXI_6_ARADDR(xbar_sys_1_15_0_m_axi_6_ARADDR),
          .M_AXI_6_ARREADY(xbar_sys_1_15_0_m_axi_6_ARREADY),
          .M_AXI_6_ARVALID(xbar_sys_1_15_0_m_axi_6_ARVALID),
          .M_AXI_6_AWADDR(xbar_sys_1_15_0_m_axi_6_AWADDR),
          .M_AXI_6_AWREADY(xbar_sys_1_15_0_m_axi_6_AWREADY),
          .M_AXI_6_AWVALID(xbar_sys_1_15_0_m_axi_6_AWVALID),
          .M_AXI_6_BREADY(xbar_sys_1_15_0_m_axi_6_BREADY),
          .M_AXI_6_BRESP(xbar_sys_1_15_0_m_axi_6_BRESP),
          .M_AXI_6_BVALID(xbar_sys_1_15_0_m_axi_6_BVALID),
          .M_AXI_6_RDATA(xbar_sys_1_15_0_m_axi_6_RDATA),
          .M_AXI_6_RREADY(xbar_sys_1_15_0_m_axi_6_RREADY),
          .M_AXI_6_RRESP(xbar_sys_1_15_0_m_axi_6_RRESP),
          .M_AXI_6_RVALID(xbar_sys_1_15_0_m_axi_6_RVALID),
          .M_AXI_6_WDATA(xbar_sys_1_15_0_m_axi_6_WDATA),
          .M_AXI_6_WREADY(xbar_sys_1_15_0_m_axi_6_WREADY),
          .M_AXI_6_WSTRB(xbar_sys_1_15_0_m_axi_6_WSTRB),
          .M_AXI_6_WVALID(xbar_sys_1_15_0_m_axi_6_WVALID),
          .M_AXI_7_ARADDR(xbar_sys_1_15_0_m_axi_7_ARADDR),
          .M_AXI_7_ARREADY(xbar_sys_1_15_0_m_axi_7_ARREADY),
          .M_AXI_7_ARVALID(xbar_sys_1_15_0_m_axi_7_ARVALID),
          .M_AXI_7_AWADDR(xbar_sys_1_15_0_m_axi_7_AWADDR),
          .M_AXI_7_AWREADY(xbar_sys_1_15_0_m_axi_7_AWREADY),
          .M_AXI_7_AWVALID(xbar_sys_1_15_0_m_axi_7_AWVALID),
          .M_AXI_7_BREADY(xbar_sys_1_15_0_m_axi_7_BREADY),
          .M_AXI_7_BRESP(xbar_sys_1_15_0_m_axi_7_BRESP),
          .M_AXI_7_BVALID(xbar_sys_1_15_0_m_axi_7_BVALID),
          .M_AXI_7_RDATA(xbar_sys_1_15_0_m_axi_7_RDATA),
          .M_AXI_7_RREADY(xbar_sys_1_15_0_m_axi_7_RREADY),
          .M_AXI_7_RRESP(xbar_sys_1_15_0_m_axi_7_RRESP),
          .M_AXI_7_RVALID(xbar_sys_1_15_0_m_axi_7_RVALID),
          .M_AXI_7_WDATA(xbar_sys_1_15_0_m_axi_7_WDATA),
          .M_AXI_7_WREADY(xbar_sys_1_15_0_m_axi_7_WREADY),
          .M_AXI_7_WSTRB(xbar_sys_1_15_0_m_axi_7_WSTRB),
          .M_AXI_7_WVALID(xbar_sys_1_15_0_m_axi_7_WVALID),
          .M_AXI_8_ARADDR(xbar_sys_1_15_0_m_axi_8_ARADDR),
          .M_AXI_8_ARREADY(xbar_sys_1_15_0_m_axi_8_ARREADY),
          .M_AXI_8_ARVALID(xbar_sys_1_15_0_m_axi_8_ARVALID),
          .M_AXI_8_AWADDR(xbar_sys_1_15_0_m_axi_8_AWADDR),
          .M_AXI_8_AWREADY(xbar_sys_1_15_0_m_axi_8_AWREADY),
          .M_AXI_8_AWVALID(xbar_sys_1_15_0_m_axi_8_AWVALID),
          .M_AXI_8_BREADY(xbar_sys_1_15_0_m_axi_8_BREADY),
          .M_AXI_8_BRESP(xbar_sys_1_15_0_m_axi_8_BRESP),
          .M_AXI_8_BVALID(xbar_sys_1_15_0_m_axi_8_BVALID),
          .M_AXI_8_RDATA(xbar_sys_1_15_0_m_axi_8_RDATA),
          .M_AXI_8_RREADY(xbar_sys_1_15_0_m_axi_8_RREADY),
          .M_AXI_8_RRESP(xbar_sys_1_15_0_m_axi_8_RRESP),
          .M_AXI_8_RVALID(xbar_sys_1_15_0_m_axi_8_RVALID),
          .M_AXI_8_WDATA(xbar_sys_1_15_0_m_axi_8_WDATA),
          .M_AXI_8_WREADY(xbar_sys_1_15_0_m_axi_8_WREADY),
          .M_AXI_8_WSTRB(xbar_sys_1_15_0_m_axi_8_WSTRB),
          .M_AXI_8_WVALID(xbar_sys_1_15_0_m_axi_8_WVALID),
          .M_AXI_9_ARADDR(xbar_sys_1_15_0_m_axi_9_ARADDR),
          .M_AXI_9_ARREADY(xbar_sys_1_15_0_m_axi_9_ARREADY),
          .M_AXI_9_ARVALID(xbar_sys_1_15_0_m_axi_9_ARVALID),
          .M_AXI_9_AWADDR(xbar_sys_1_15_0_m_axi_9_AWADDR),
          .M_AXI_9_AWREADY(xbar_sys_1_15_0_m_axi_9_AWREADY),
          .M_AXI_9_AWVALID(xbar_sys_1_15_0_m_axi_9_AWVALID),
          .M_AXI_9_BREADY(xbar_sys_1_15_0_m_axi_9_BREADY),
          .M_AXI_9_BRESP(xbar_sys_1_15_0_m_axi_9_BRESP),
          .M_AXI_9_BVALID(xbar_sys_1_15_0_m_axi_9_BVALID),
          .M_AXI_9_RDATA(xbar_sys_1_15_0_m_axi_9_RDATA),
          .M_AXI_9_RREADY(xbar_sys_1_15_0_m_axi_9_RREADY),
          .M_AXI_9_RRESP(xbar_sys_1_15_0_m_axi_9_RRESP),
          .M_AXI_9_RVALID(xbar_sys_1_15_0_m_axi_9_RVALID),
          .M_AXI_9_WDATA(xbar_sys_1_15_0_m_axi_9_WDATA),
          .M_AXI_9_WREADY(xbar_sys_1_15_0_m_axi_9_WREADY),
          .M_AXI_9_WSTRB(xbar_sys_1_15_0_m_axi_9_WSTRB),
          .M_AXI_9_WVALID(xbar_sys_1_15_0_m_axi_9_WVALID),
          .M_AXI_10_ARREADY(1'b1), // REAL DummyAxiSlave
          .M_AXI_10_AWREADY(1'b1),
          .M_AXI_10_BRESP(2'b0),
          .M_AXI_10_BVALID(1'b0),
          .M_AXI_10_RDATA(32'hdead000a),
          .M_AXI_10_RRESP(2'b0),
          .M_AXI_10_RVALID(1'b1),
          .M_AXI_10_WREADY(1'b1),
          .M_AXI_11_ARADDR(xbar_sys_1_15_0_m_axi_11_ARADDR),
          .M_AXI_11_ARREADY(xbar_sys_1_15_0_m_axi_11_ARREADY),
          .M_AXI_11_ARVALID(xbar_sys_1_15_0_m_axi_11_ARVALID),
          .M_AXI_11_AWADDR(xbar_sys_1_15_0_m_axi_11_AWADDR),
          .M_AXI_11_AWREADY(xbar_sys_1_15_0_m_axi_11_AWREADY),
          .M_AXI_11_AWVALID(xbar_sys_1_15_0_m_axi_11_AWVALID),
          .M_AXI_11_BREADY(xbar_sys_1_15_0_m_axi_11_BREADY),
          .M_AXI_11_BRESP(xbar_sys_1_15_0_m_axi_11_BRESP),
          .M_AXI_11_BVALID(xbar_sys_1_15_0_m_axi_11_BVALID),
          .M_AXI_11_RDATA(xbar_sys_1_15_0_m_axi_11_RDATA),
          .M_AXI_11_RREADY(xbar_sys_1_15_0_m_axi_11_RREADY),
          .M_AXI_11_RRESP(xbar_sys_1_15_0_m_axi_11_RRESP),
          .M_AXI_11_RVALID(xbar_sys_1_15_0_m_axi_11_RVALID),
          .M_AXI_11_WDATA(xbar_sys_1_15_0_m_axi_11_WDATA),
          .M_AXI_11_WREADY(xbar_sys_1_15_0_m_axi_11_WREADY),
          .M_AXI_11_WSTRB(xbar_sys_1_15_0_m_axi_11_WSTRB),
          .M_AXI_11_WVALID(xbar_sys_1_15_0_m_axi_11_WVALID),
          .M_AXI_12_ARADDR(xbar_sys_1_15_0_m_axi_12_ARADDR),
          .M_AXI_12_ARREADY(xbar_sys_1_15_0_m_axi_12_ARREADY),
          .M_AXI_12_ARVALID(xbar_sys_1_15_0_m_axi_12_ARVALID),
          .M_AXI_12_AWADDR(xbar_sys_1_15_0_m_axi_12_AWADDR),
          .M_AXI_12_AWREADY(xbar_sys_1_15_0_m_axi_12_AWREADY),
          .M_AXI_12_AWVALID(xbar_sys_1_15_0_m_axi_12_AWVALID),
          .M_AXI_12_BREADY(xbar_sys_1_15_0_m_axi_12_BREADY),
          .M_AXI_12_BRESP(xbar_sys_1_15_0_m_axi_12_BRESP),
          .M_AXI_12_BVALID(xbar_sys_1_15_0_m_axi_12_BVALID),
          .M_AXI_12_RDATA(xbar_sys_1_15_0_m_axi_12_RDATA),
          .M_AXI_12_RREADY(xbar_sys_1_15_0_m_axi_12_RREADY),
          .M_AXI_12_RRESP(xbar_sys_1_15_0_m_axi_12_RRESP),
          .M_AXI_12_RVALID(xbar_sys_1_15_0_m_axi_12_RVALID),
          .M_AXI_12_WDATA(xbar_sys_1_15_0_m_axi_12_WDATA),
          .M_AXI_12_WREADY(xbar_sys_1_15_0_m_axi_12_WREADY),
          .M_AXI_12_WSTRB(xbar_sys_1_15_0_m_axi_12_WSTRB),
          .M_AXI_12_WVALID(xbar_sys_1_15_0_m_axi_12_WVALID),
          .M_AXI_13_ARADDR(xbar_sys_1_15_0_m_axi_13_ARADDR),
          .M_AXI_13_ARPROT(xbar_sys_1_15_0_m_axi_13_ARPROT),
          .M_AXI_13_ARREADY(xbar_sys_1_15_0_m_axi_13_ARREADY),
          .M_AXI_13_ARVALID(xbar_sys_1_15_0_m_axi_13_ARVALID),
          .M_AXI_13_AWADDR(xbar_sys_1_15_0_m_axi_13_AWADDR),
          .M_AXI_13_AWPROT(xbar_sys_1_15_0_m_axi_13_AWPROT),
          .M_AXI_13_AWREADY(xbar_sys_1_15_0_m_axi_13_AWREADY),
          .M_AXI_13_AWVALID(xbar_sys_1_15_0_m_axi_13_AWVALID),
          .M_AXI_13_BREADY(xbar_sys_1_15_0_m_axi_13_BREADY),
          .M_AXI_13_BRESP(xbar_sys_1_15_0_m_axi_13_BRESP),
          .M_AXI_13_BVALID(xbar_sys_1_15_0_m_axi_13_BVALID),
          .M_AXI_13_RDATA(xbar_sys_1_15_0_m_axi_13_RDATA),
          .M_AXI_13_RREADY(xbar_sys_1_15_0_m_axi_13_RREADY),
          .M_AXI_13_RRESP(xbar_sys_1_15_0_m_axi_13_RRESP),
          .M_AXI_13_RVALID(xbar_sys_1_15_0_m_axi_13_RVALID),
          .M_AXI_13_WDATA(xbar_sys_1_15_0_m_axi_13_WDATA),
          .M_AXI_13_WREADY(xbar_sys_1_15_0_m_axi_13_WREADY),
          .M_AXI_13_WSTRB(xbar_sys_1_15_0_m_axi_13_WSTRB),
          .M_AXI_13_WVALID(xbar_sys_1_15_0_m_axi_13_WVALID),
          .M_AXI_14_ARREADY(1'b1),
          .M_AXI_14_AWREADY(1'b1),
          .M_AXI_14_BRESP(2'b0),
          .M_AXI_14_BVALID(1'b1),
          .M_AXI_14_RDATA(32'hdead000e),
          .M_AXI_14_RRESP(2'b0),
          .M_AXI_14_RVALID(1'b1),
          .M_AXI_14_WREADY(1'b1),
          .M_AXI_15_ARADDR(xbar_sys_1_15_0_m_axi_15_ARADDR),
          .M_AXI_15_ARREADY(xbar_sys_1_15_0_m_axi_15_ARREADY),
          .M_AXI_15_ARVALID(xbar_sys_1_15_0_m_axi_15_ARVALID),
          .M_AXI_15_AWADDR(xbar_sys_1_15_0_m_axi_15_AWADDR),
          .M_AXI_15_AWREADY(xbar_sys_1_15_0_m_axi_15_AWREADY),
          .M_AXI_15_AWVALID(xbar_sys_1_15_0_m_axi_15_AWVALID),
          .M_AXI_15_BREADY(xbar_sys_1_15_0_m_axi_15_BREADY),
          .M_AXI_15_BRESP(xbar_sys_1_15_0_m_axi_15_BRESP),
          .M_AXI_15_BVALID(xbar_sys_1_15_0_m_axi_15_BVALID),
          .M_AXI_15_RDATA(xbar_sys_1_15_0_m_axi_15_RDATA),
          .M_AXI_15_RREADY(xbar_sys_1_15_0_m_axi_15_RREADY),
          .M_AXI_15_RRESP(xbar_sys_1_15_0_m_axi_15_RRESP),
          .M_AXI_15_RVALID(xbar_sys_1_15_0_m_axi_15_RVALID),
          .M_AXI_15_WDATA(xbar_sys_1_15_0_m_axi_15_WDATA),
          .M_AXI_15_WREADY(xbar_sys_1_15_0_m_axi_15_WREADY),
          .M_AXI_15_WSTRB(xbar_sys_1_15_0_m_axi_15_WSTRB),
          .M_AXI_15_WVALID(xbar_sys_1_15_0_m_axi_15_WVALID));
endmodule
