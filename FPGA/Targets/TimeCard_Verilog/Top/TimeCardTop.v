// File TimeCardTop.vhd translated with vhd2vl 3.0 VHDL to Verilog RTL translator
// vhd2vl settings:
//  * Verilog Module Declaration Style: 2001

// vhd2vl is Free (libre) Software:
//   Copyright (C) 2001-2023 Vincenzo Liguori - Ocean Logic Pty Ltd
//     http://www.ocean-logic.com
//   Modifications Copyright (C) 2006 Mark Gonzales - PMC Sierra Inc
//   Modifications (C) 2010 Shankar Giri
//   Modifications Copyright (C) 2002-2023 Larry Doolittle
//     http://doolittle.icarus.com/~larry/vhd2vl/
//   Modifications (C) 2017 Rodrigo A. Melo
//
//   vhd2vl comes with ABSOLUTELY NO WARRANTY.  Always check the resulting
//   Verilog for correctness, ideally with a formal verification tool.
//
//   You are welcome to redistribute vhd2vl under certain conditions.
//   See the license (GPLv2) file included with the source for details.

// The result of translation follows.  Its copyright status should be
// considered unchanged from the original VHDL.

//*****************************************************************************************
// Project: Time Card
//
// Author: Sven Meier, NetTimeLogic GmbH
//
// License: Copyright (c) 2022, NetTimeLogic GmbH, Switzerland, <contact@nettimelogic.com>
// All rights reserved.
//
// THIS PROGRAM IS FREE SOFTWARE: YOU CAN REDISTRIBUTE IT AND/OR MODIFY
// IT UNDER THE TERMS OF THE GNU LESSER GENERAL PUBLIC LICENSE AS
// PUBLISHED BY THE FREE SOFTWARE FOUNDATION, VERSION 3.
//
// THIS PROGRAM IS DISTRIBUTED IN THE HOPE THAT IT WILL BE USEFUL, BUT
// WITHOUT ANY WARRANTY; WITHOUT EVEN THE IMPLIED WARRANTY OF
// MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. SEE THE GNU
// LESSER GENERAL LESSER PUBLIC LICENSE FOR MORE DETAILS.
//
// YOU SHOULD HAVE RECEIVED A COPY OF THE GNU LESSER GENERAL PUBLIC LICENSE
// ALONG WITH THIS PROGRAM. IF NOT, SEE <http://www.gnu.org/licenses/>.
//
//*****************************************************************************************

module TimeCardTop(
input wire Mhz10ClkDcxo1_ClkIn,
input wire RstN_RstIn,
input wire Mhz10Clk0_ClkIn,
input wire Mhz10Clk1_ClkIn,
input wire Mhz125ClkP_ClkIn,
input wire Mhz125ClkN_ClkIn,
input wire Mhz200ClkP_ClkIn,
input wire Mhz200ClkN_ClkIn,
output wire [3:0] Led_DatOut,
input wire [1:0] Key_DatIn,
output wire EepromWp_DatOut,
inout wire SpiFlashDq0_DatInOut,
inout wire SpiFlashDq1_DatInOut,
inout wire SpiFlashDq2_DatInOut,
inout wire SpiFlashDq3_DatInOut,
output wire SpiFlashCsN_EnaOut,
input wire SmaIn1_DatIn,
input wire SmaIn2_DatIn,
input wire SmaIn3_DatIn,
input wire SmaIn4_DatIn,
output wire SmaOut1_DatOut,
output wire SmaOut2_DatOut,
output wire SmaOut3_DatOut,
output wire SmaOut4_DatOut,
output wire Sma1InBufEnableN_EnOut,
output wire Sma2InBufEnableN_EnOut,
output wire Sma3InBufEnableN_EnOut,
output wire Sma4InBufEnableN_EnOut,
output wire Sma1OutBufEnableN_EnOut,
output wire Sma2OutBufEnableN_EnOut,
output wire Sma3OutBufEnableN_EnOut,
output wire Sma4OutBufEnableN_EnOut,
inout wire I2cScl_ClkInOut,
inout wire I2cSda_DatInOut,
output wire Uart1TxDat_DatOut,
input wire Uart1RxDat_DatIn,
output wire UartGnss1TxDat_DatOut,
input wire UartGnss1RxDat_DatIn,
input wire [1:0] Gnss1Tp_DatIn,
output wire Gnss1RstN_RstOut,
output wire UartGnss2TxDat_DatOut,
input wire UartGnss2RxDat_DatIn,
input wire [1:0] Gnss2Tp_DatIn,
output wire Gnss2RstN_RstOut,
inout wire MacTxDat_DatInOut,
inout wire MacRxDat_DatInOut,
output wire MacFreqControl_DatOut,
input wire MacAlarm_DatIn,
input wire MacBite_DatIn,
output wire MacUsbPower_EnOut,
output wire MacUsbP_DatOut,
output wire MacUsbN_DatOut,
input wire MacPps_EvtIn,
output wire MacPps0_EvtOut,
output wire MacPps1_EvtOut,
input wire PciePerst_RstIn,
input wire PcieRefClkP_ClkIn,
input wire PcieRefClkN_ClkIn,
input wire [0:0] pcie_7x_mgt_0_rxn,
input wire [0:0] pcie_7x_mgt_0_rxp,
output wire [0:0] pcie_7x_mgt_0_txn,
output wire [0:0] pcie_7x_mgt_0_txp
);

parameter GoldenImage_Gen = 0;

parameter ClkPeriodNanosecond_Con = 20;

// Rst & Clk
wire PciePerstN_Rst;
wire Mhz10Clk0_Clk;
wire Mhz10ClkDcxo1_Clk;
wire Mhz10ClkDcxo2_Clk;
wire Mhz50Clk_Clk;
wire Mhz50RstN_Rst;
wire Mhz50Clk_Clk_0;
wire Mhz50RstN_Rst_0;
wire Mhz62_5Clk_Clk;
wire Mhz62_5RstN_Rst;
reg [31:0] RstCount_CntReg = 0;  // Led
reg BlinkingLed_DatReg;
reg [31:0] BlinkingLedCount_CntReg;
reg BlinkingLed2_DatReg;
reg [31:0] BlinkingLed2Count_CntReg;
reg GnssDataOe_EnaReg;
wire [1:0] Ext_DatIn;
wire [6:0] Ext_DatOut;
wire Pps_EvtOut;
wire MacPps0_Evt;
wire MacPps1_Evt;
wire [1:0] GpioGnss_DatOut;
wire UartGnss1TxDat_Dat;
wire UartGnss2TxDat_Dat;
wire StartUpIo_cfgclk;
wire StartUpIo_cfgmclk;
wire StartUpIo_preq;  // SMA Connector / Buffers
wire SmaIn1_En;
wire SmaIn2_En;
wire SmaIn3_En;
wire SmaIn4_En;
wire SmaOut1_En;
wire SmaOut2_En;
wire SmaOut3_En;
wire SmaOut4_En;
wire SpiFlashCsN_Ena;
wire GoldenImageN_Ena;
wire Clk_RxSda_i;
wire Clk_RxSda_o;
wire Clk_RxSda_t;
wire Clk_TxScl_i;
wire Clk_TxScl_o;
wire Clk_TxScl_t;

  // CLK UART and CLK I2C share the same pins (it is configurable which interface is active)
  assign Clk_RxSda_i = MacRxDat_DatInOut;
  assign MacRxDat_DatInOut = (Clk_RxSda_t == 1'b0) ? Clk_RxSda_o : 1'bZ;
  assign Clk_TxScl_i = MacTxDat_DatInOut;
  assign MacTxDat_DatInOut = (Clk_TxScl_t == 1'b0) ? Clk_TxScl_o : 1'bZ;
  // SMA
  assign Sma1InBufEnableN_EnOut =  ~SmaIn1_En;
  assign Sma2InBufEnableN_EnOut =  ~SmaIn2_En;
  assign Sma3InBufEnableN_EnOut =  ~SmaIn3_En;
  assign Sma4InBufEnableN_EnOut =  ~SmaIn4_En;
  assign Sma1OutBufEnableN_EnOut =  ~SmaOut1_En;
  assign Sma2OutBufEnableN_EnOut =  ~SmaOut2_En;
  assign Sma3OutBufEnableN_EnOut =  ~SmaOut3_En;
  assign Sma4OutBufEnableN_EnOut =  ~SmaOut4_En;
  assign GoldenImageN_Ena = GoldenImage_Gen == 1 ? 1'b0 : 1'b1;
  assign PciePerstN_Rst = PciePerst_RstIn;
  assign Ext_DatIn = Key_DatIn;
  assign Led_DatOut[3] = MacPps_EvtIn;
  // Ext_DatOut(3);
  assign Led_DatOut[2] = Pps_EvtOut;
  // Ext_DatOut(2);
  assign Led_DatOut[1] = BlinkingLed2_DatReg;
  // Ext_DatOut(1);
  assign Led_DatOut[0] = BlinkingLed_DatReg;
  // Ext_DatOut(0);
  assign EepromWp_DatOut = Ext_DatOut[4];
  // GNSS Outputs
  assign Gnss1RstN_RstOut =  ~GpioGnss_DatOut[0];
  assign Gnss2RstN_RstOut =  ~GpioGnss_DatOut[1];
  // Wait 1s until enable Gnss Uart Tx Output
  assign UartGnss1TxDat_DatOut = GnssDataOe_EnaReg == 1'b0 ? 1'bZ : UartGnss1TxDat_Dat;
  assign UartGnss2TxDat_DatOut = GnssDataOe_EnaReg == 1'b0 ? 1'bZ : UartGnss2TxDat_Dat;
  // SPI Flash
  assign SpiFlashCsN_EnaOut = SpiFlashCsN_Ena;
  // MAC
  assign MacFreqControl_DatOut = 1'b0;
  assign MacUsbPower_EnOut = 1'b0;
  //! unused uart
  assign Uart1TxDat_DatOut = 1'b0;
  //! unused
  //*************************************************************************************
  // Procedural Statements
  //*************************************************************************************
  always @(posedge Mhz50RstN_Rst, posedge Mhz50Clk_Clk) begin
    if((Mhz50RstN_Rst == 1'b0)) begin
      BlinkingLed_DatReg <= 1'b0;
      BlinkingLedCount_CntReg <= 0;
    end else begin
      if((BlinkingLedCount_CntReg < 250000000)) begin
        BlinkingLedCount_CntReg <= BlinkingLedCount_CntReg + ClkPeriodNanosecond_Con;
      end
      else begin
        BlinkingLed_DatReg <=  ~BlinkingLed_DatReg;
        BlinkingLedCount_CntReg <= 0;
      end
    end
  end

  always @(posedge Mhz62_5RstN_Rst, posedge Mhz62_5Clk_Clk) begin
    if((Mhz62_5RstN_Rst == 1'b0)) begin
      BlinkingLed2_DatReg <= 1'b0;
      BlinkingLed2Count_CntReg <= 0;
    end else begin
      if((BlinkingLed2Count_CntReg < 200000000)) begin
        BlinkingLed2Count_CntReg <= BlinkingLed2Count_CntReg + ClkPeriodNanosecond_Con;
      end
      else begin
        BlinkingLed2_DatReg <=  ~BlinkingLed2_DatReg;
        BlinkingLed2Count_CntReg <= 0;
      end
    end
  end

  always @(posedge Mhz50RstN_Rst, posedge Mhz50Clk_Clk) begin
    if((Mhz50RstN_Rst == 1'b0)) begin
      GnssDataOe_EnaReg <= 1'b0;
      RstCount_CntReg <= 0;
    end else begin
      if((RstCount_CntReg < 2000000000)) begin
        RstCount_CntReg <= RstCount_CntReg + ClkPeriodNanosecond_Con;
        if((RstCount_CntReg < 1000000000)) begin
          // 1000ms
          GnssDataOe_EnaReg <= 1'b0;
        end
        else begin
          GnssDataOe_EnaReg <= 1'b1;
        end
      end
      else begin
        RstCount_CntReg <= RstCount_CntReg;
        GnssDataOe_EnaReg <= 1'b1;
      end
    end
  end

  //*************************************************************************************
  // Instantiation and Port mapping
  //*************************************************************************************
  assign MacPps0_EvtOut = MacPps0_Evt;
  assign MacPps1_EvtOut = MacPps1_Evt;
  // MacUsb_Inst: component Obufds 
  // port map(
  // o                           => MacUsbP_DatOut,
  // ob                          => MacUsbN_DatOut,
  // i                           => '0'
  // );
  assign MacUsbP_DatOut = 1'b0;
  assign MacUsbN_DatOut = 1'b0;
  BUFR BufrClk0_Inst(
    .CE(1'b1),
    .CLR(1'b0),
    .I(Mhz10Clk0_ClkIn),
    .O(Mhz10Clk0_Clk));

  BUFR BufrDcxo1_Inst(
    .CE(1'b1),
    .CLR(1'b0),
    .I(Mhz10ClkDcxo1_ClkIn),
    .O(Mhz10ClkDcxo1_Clk));

  // BufrDcxo2_Inst : Bufr   
  // port map (
  // ce                              => '1',
  // clr                             => '0',
  // i                               => Mhz10ClkDcxo2_ClkIn,
  // o                               => Mhz10ClkDcxo2_Clk
  // );      
  TimeCard_wrapper Bd_Inst(
      .Mhz200Clk_ClkIn_clk_n(Mhz200ClkN_ClkIn),
    .Mhz200Clk_ClkIn_clk_p(Mhz200ClkP_ClkIn),
    .Mhz10ClkMac_ClkIn(Mhz10Clk0_Clk),
    .Mhz10ClkSma_ClkIn(SmaIn1_DatIn),
    .Mhz10ClkDcxo1_ClkIn(Mhz10ClkDcxo1_Clk),
    .Mhz10ClkDcxo2_ClkIn(1'b0),
    .ResetN_RstIn(RstN_RstIn),
    .GoldenImageN_EnaIn(GoldenImageN_Ena),
    // Internal 50MHz (does no change on clock source switch)
    .Mhz50Clk_ClkOut_0(Mhz50Clk_Clk_0),
    .Reset50MhzN_RstOut_0(Mhz50RstN_Rst_0),
    .Mhz50Clk_ClkOut(Mhz50Clk_Clk),
    .Reset50MhzN_RstOut(Mhz50RstN_Rst),
    .Mhz62_5Clk_ClkOut(Mhz62_5Clk_Clk),
    .Reset62_5MhzN_RstOut(Mhz62_5RstN_Rst),
    .InHoldover_DatOut(/* open */),
    .InSync_DatOut(/* open */),
    .Ext_DatIn_tri_i(Ext_DatIn),
    .Ext_DatOut(Ext_DatOut),
    .I2c_scl_io(I2cScl_ClkInOut),
    .I2c_sda_io(I2cSda_DatInOut),
    .SpiFlash_io0_io(SpiFlashDq0_DatInOut),
    .SpiFlash_io1_io(SpiFlashDq1_DatInOut),
    .SpiFlash_io2_io(SpiFlashDq2_DatInOut),
    .SpiFlash_io3_io(SpiFlashDq3_DatInOut),
    .SpiFlash_ss_io(SpiFlashCsN_Ena),
    .StartUpIo_cfgclk(StartUpIo_cfgclk),
    .StartUpIo_cfgmclk(StartUpIo_cfgmclk),
    .StartUpIo_preq(StartUpIo_preq),
    .GpioGnss_DatOut_tri_o(GpioGnss_DatOut),
	.GpioMac_DatIn_tri_i({MacBite_DatIn, MacAlarm_DatIn}),
    // GpioMac_DatIn_tri_i(0)      => MacAlarm_DatIn,
    // GpioMac_DatIn_tri_i(1)      => MacBite_DatIn,
    .SmaIn1_DatIn(SmaIn1_DatIn),
    .SmaIn1_EnOut(SmaIn1_En),
    .SmaIn2_DatIn(SmaIn2_DatIn),
    .SmaIn2_EnOut(SmaIn2_En),
    .SmaIn3_DatIn(SmaIn3_DatIn),
    .SmaIn3_EnOut(SmaIn3_En),
    .SmaIn4_DatIn(SmaIn4_DatIn),
    .SmaIn4_EnOut(SmaIn4_En),
    .SmaOut1_DatOut(SmaOut1_DatOut),
    .SmaOut1_EnOut(SmaOut1_En),
    .SmaOut2_DatOut(SmaOut2_DatOut),
    .SmaOut2_EnOut(SmaOut2_En),
    .SmaOut3_DatOut(SmaOut3_DatOut),
    .SmaOut3_EnOut(SmaOut3_En),
    .SmaOut4_DatOut(SmaOut4_DatOut),
    .SmaOut4_EnOut(SmaOut4_En),
    .PpsGnss1_EvtIn(Gnss1Tp_DatIn[0]),
    .PpsGnss2_EvtIn(Gnss2Tp_DatIn[0]),
    .Pps_EvtOut(Pps_EvtOut),
    .MacPps_EvtIn(MacPps_EvtIn),
    .MacPps0_EvtOut(MacPps0_Evt),
    .MacPps1_EvtOut(MacPps1_Evt),
    .UartGnss1Rx_DatIn(UartGnss1RxDat_DatIn),
    .UartGnss1Tx_DatOut(UartGnss1TxDat_Dat),
    .UartGnss2Rx_DatIn(UartGnss2RxDat_DatIn),
    .UartGnss2Tx_DatOut(UartGnss2TxDat_Dat),
    .Clk_RxSda_DatIn(Clk_RxSda_i),
    .Clk_RxSda_DatOut(Clk_RxSda_o),
    .Clk_RxSdaT_EnaOut(Clk_RxSda_t),
    .Clk_TxSclT_EnaOut(Clk_TxScl_t),
    .Clk_TxScl_DatIn(Clk_TxScl_i),
    .Clk_TxScl_DatOut(Clk_TxScl_o),
    .PcieRefClockN(PcieRefClkN_ClkIn),
    .PcieRefClockP(PcieRefClkP_ClkIn),
    .PciePerstN_RstIn(PciePerstN_Rst),
    .pcie_7x_mgt_0_rxn(pcie_7x_mgt_0_rxn),
    .pcie_7x_mgt_0_rxp(pcie_7x_mgt_0_rxp),
    .pcie_7x_mgt_0_txn(pcie_7x_mgt_0_txn),
    .pcie_7x_mgt_0_txp(pcie_7x_mgt_0_txp));

endmodule
