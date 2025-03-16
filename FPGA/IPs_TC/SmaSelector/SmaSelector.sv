// SPDX-License-Identifier: GPL-3.0
// This file is written with the help of vhd2vl 3.0 VHDL to Verilog RTL translator
// vhd2vl is Free (libre) Software:
//   Copyright (C) 2001-2023 Vincenzo Liguori - Ocean Logic Pty Ltd
//     http://www.ocean-logic.com
//   Modifications Copyright (C) 2006 Mark Gonzales - PMC Sierra Inc
//   Modifications (C) 2010 Shankar Giri
//   Modifications Copyright (C) 2002-2023 Larry Doolittle
//     http://doolittle.icarus.com/~larry/vhd2vl/
//   Modifications (C) 2017 Rodrigo A. Melo

//*****************************************************************************************
// Project: Time Card
//
// Author: Thomas Schaub, NetTimeLogic GmbH
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

// The SMA Selector multiplexes the output and demultiplexes the inputs of the 4 SMA     --
// connectors of the Timecard. Each connector can be configured as input or output,      --
// depending on the configured mapping. The configured mapping is done via 2 AXI4L slave --
// interfaces. Each slave interface controls one mapping option.                         --
`include "TimeCard_Package.svh"

module SmaSelector #(
parameter [15:0] SmaInput1SourceSelect_Gen=16'h8000,
parameter [15:0] SmaInput2SourceSelect_Gen=16'h8001,
parameter [15:0] SmaInput3SourceSelect_Gen=16'h0000,
parameter [15:0] SmaInput4SourceSelect_Gen=16'h0000,
parameter [15:0] SmaOutput1SourceSelect_Gen=16'h0000,
parameter [15:0] SmaOutput2SourceSelect_Gen=16'h0000,
parameter [15:0] SmaOutput3SourceSelect_Gen=16'h8000,
parameter [15:0] SmaOutput4SourceSelect_Gen=16'h8001
)(
// System
input wire SysClk_ClkIn,
input wire SysRstN_RstIn,
// Sma Input Sources                
output wire Sma10MHzSourceEnable_EnOut,
output wire SmaExtPpsSource1_EvtOut,
output wire SmaExtPpsSource2_EvtOut,
output wire SmaTs1Source_EvtOut,
output wire SmaTs2Source_EvtOut,
output wire SmaTs3Source_EvtOut,
output wire SmaTs4Source_EvtOut,
output wire SmaFreqCnt1Source_EvtOut,
output wire SmaFreqCnt2Source_EvtOut,
output wire SmaFreqCnt3Source_EvtOut,
output wire SmaFreqCnt4Source_EvtOut,
output wire SmaIrigSlaveSource_DatOut,
output wire SmaDcfSlaveSource_DatOut,
output wire SmaUartExtSource_DatOut,
// Sma Output Sources           
input wire Sma10MHzSource_ClkIn,
input wire SmaFpgaPpsSource_EvtIn,
input wire SmaMacPpsSource_EvtIn,
input wire SmaGnss1PpsSource_EvtIn,
input wire SmaGnss2PpsSource_EvtIn,
input wire SmaIrigMasterSource_DatIn,
input wire SmaDcfMasterSource_DatIn,
input wire SmaSignalGen1Source_DatIn,
input wire SmaSignalGen2Source_DatIn,
input wire SmaSignalGen3Source_DatIn,
input wire SmaSignalGen4Source_DatIn,
input wire SmaUartGnss1Source_DatIn,
input wire SmaUartGnss2Source_DatIn,
input wire SmaUartExtSource_DatIn,
// Sma Input            
input wire SmaIn1_DatIn,
input wire SmaIn2_DatIn,
input wire SmaIn3_DatIn,
input wire SmaIn4_DatIn,
// Sma Output            
output reg SmaOut1_DatOut,
output reg SmaOut2_DatOut,
output reg SmaOut3_DatOut,
output reg SmaOut4_DatOut,
// Buffer enable            
output wire SmaIn1_EnOut,
output wire SmaIn2_EnOut,
output wire SmaIn3_EnOut,
output wire SmaIn4_EnOut,
output wire SmaOut1_EnOut,
output wire SmaOut2_EnOut,
output wire SmaOut3_EnOut,
output wire SmaOut4_EnOut,
// Axi 1
input wire Axi1WriteAddrValid_ValIn,
output wire Axi1WriteAddrReady_RdyOut,
input wire [15:0] Axi1WriteAddrAddress_AdrIn,
input wire [2:0] Axi1WriteAddrProt_DatIn,
input wire Axi1WriteDataValid_ValIn,
output wire Axi1WriteDataReady_RdyOut,
input wire [31:0] Axi1WriteDataData_DatIn,
input wire [3:0] Axi1WriteDataStrobe_DatIn,
output wire Axi1WriteRespValid_ValOut,
input wire Axi1WriteRespReady_RdyIn,
output wire [1:0] Axi1WriteRespResponse_DatOut,
input wire Axi1ReadAddrValid_ValIn,
output wire Axi1ReadAddrReady_RdyOut,
input wire [15:0] Axi1ReadAddrAddress_AdrIn,
input wire [2:0] Axi1ReadAddrProt_DatIn,
output wire Axi1ReadDataValid_ValOut,
input wire Axi1ReadDataReady_RdyIn,
output wire [1:0] Axi1ReadDataResponse_DatOut,
output wire [31:0] Axi1ReadDataData_DatOut,
// Axi 2                                    
input wire Axi2WriteAddrValid_ValIn,
output wire Axi2WriteAddrReady_RdyOut,
input wire [15:0] Axi2WriteAddrAddress_AdrIn,
input wire [2:0] Axi2WriteAddrProt_DatIn,
input wire Axi2WriteDataValid_ValIn,
output wire Axi2WriteDataReady_RdyOut,
input wire [31:0] Axi2WriteDataData_DatIn,
input wire [3:0] Axi2WriteDataStrobe_DatIn,
output wire Axi2WriteRespValid_ValOut,
input wire Axi2WriteRespReady_RdyIn,
output wire [1:0] Axi2WriteRespResponse_DatOut,
input wire Axi2ReadAddrValid_ValIn,
output wire Axi2ReadAddrReady_RdyOut,
input wire [15:0] Axi2ReadAddrAddress_AdrIn,
input wire [2:0] Axi2ReadAddrProt_DatIn,
output wire Axi2ReadDataValid_ValOut,
input wire Axi2ReadDataReady_RdyIn,
output wire [1:0] Axi2ReadDataResponse_DatOut,
output wire [31:0] Axi2ReadDataData_DatOut
);
import timecard_package::*;

parameter [14:0]SmaOutputSource10Mhz_Con       = 0; 
parameter [14:0]SmaOutputSourceFpgaPps_Con     = 1 << 0;
parameter [14:0]SmaOutputSourceMacPps_Con      = 1 << 1;
parameter [14:0]SmaOutputSourceGnss1Pps_Con    = 1 << 2;
parameter [14:0]SmaOutputSourceGnss2Pps_Con    = 1 << 3;
parameter [14:0]SmaOutputSourceIrigMaster_Con  = 1 << 4;
parameter [14:0]SmaOutputSourceDcfMaster_Con   = 1 << 5;
parameter [14:0]SmaOutputSourceSignalGen1_Con  = 1 << 6;
parameter [14:0]SmaOutputSourceSignalGen2_Con  = 1 << 7;
parameter [14:0]SmaOutputSourceSignalGen3_Con  = 1 << 8;
parameter [14:0]SmaOutputSourceSignalGen4_Con  = 1 << 9;
parameter [14:0]SmaOutputSourceUartGnss1_Con   = 1 << 10;
parameter [14:0]SmaOutputSourceUartGnss2_Con   = 1 << 11;
parameter [14:0]SmaOutputSourceUartExt_Con     = 1 << 12;
parameter [14:0]SmaOutputSourceGnd_Con         = 1 << 13;
parameter [14:0]SmaOutputSourceVcc_Con         = 1 << 14;
// SMA Selector version
parameter [7:0]SmaSelectorMajorVersion_Con = 0;
parameter [7:0]SmaSelectorMinorVersion_Con = 1;
parameter [15:0]SmaSelectorBuildVersion_Con = 1;
parameter [31:0]SmaSelectorVersion_Con = { SmaSelectorMajorVersion_Con,SmaSelectorMinorVersion_Con,SmaSelectorBuildVersion_Con }; 
// AXI 1 regs                                                     Addr       , Mask       , RW  , Reset
//constant SmaInputSelect1_Reg_Con                : Axi_Reg_Type:= (x"00000000", x"FFFFFFFF", Rw_E, (SmaInput2SourceSelect_Gen & SmaInput1SourceSelect_Gen));
Axi_Reg_Type SmaInputSelect1_Reg_Con                = '{Addr:32'h00000000,Mask:32'hFFFFFFFF, RegType: Rw_E,Reset:{ SmaInput2SourceSelect_Gen , SmaInput1SourceSelect_Gen }};
//constant SmaOutputSelect1_Reg_Con               : Axi_Reg_Type:= (x"00000008", x"FFFFFFFF", Rw_E, (SmaOutput4SourceSelect_Gen & SmaOutput3SourceSelect_Gen));
Axi_Reg_Type SmaOutputSelect1_Reg_Con               = '{Addr:32'h00000008,Mask:32'hFFFFFFFF, RegType: Rw_E,Reset:{ SmaOutput4SourceSelect_Gen , SmaOutput3SourceSelect_Gen }};
//constant SmaSelectorVersion1_Reg_Con            : Axi_Reg_Type:= (x"00000010", x"FFFFFFFF", Ro_E, SmaSelectorVersion_Con);
Axi_Reg_Type SmaSelectorVersion1_Reg_Con            = '{Addr:32'h00000010,Mask:32'hFFFFFFFF, RegType: Ro_E,Reset:SmaSelectorVersion_Con};
//constant SmaInputStatus_Reg_Con                 : Axi_Reg_Type:= (x"00002000", x"00003333", Ro_E, x"00000000");
Axi_Reg_Type SmaInputStatus_Reg_Con                 = '{Addr:32'h00002000,Mask:32'h00003333, RegType: Ro_E,Reset:32'h00000000};
// AXI 2 regs                                                     Addr       , Mask       , RW  , Reset
//constant SmaInputSelect2_Reg_Con                : Axi_Reg_Type:= (x"00000000", x"FFFFFFFF", Rw_E, (SmaInput4SourceSelect_Gen & SmaInput3SourceSelect_Gen));
Axi_Reg_Type SmaInputSelect2_Reg_Con                = '{Addr:32'h00000000,Mask:32'hFFFFFFFF, RegType: Rw_E,Reset:{ SmaInput4SourceSelect_Gen , SmaInput3SourceSelect_Gen }};
//constant SmaOutputSelect2_Reg_Con               : Axi_Reg_Type:= (x"00000008", x"FFFFFFFF", Rw_E, (SmaOutput2SourceSelect_Gen & SmaOutput1SourceSelect_Gen));
Axi_Reg_Type SmaOutputSelect2_Reg_Con               = '{Addr:32'h00000008,Mask:32'hFFFFFFFF, RegType: Rw_E,Reset:{ SmaOutput2SourceSelect_Gen , SmaOutput1SourceSelect_Gen }};
//constant SmaSelectorVersion2_Reg_Con            : Axi_Reg_Type:= (x"00000010", x"FFFFFFFF", Ro_E, SmaSelectorVersion_Con);
Axi_Reg_Type SmaSelectorVersion2_Reg_Con            = '{Addr:32'h00000010,Mask:32'hFFFFFFFF, RegType: Ro_E,Reset:SmaSelectorVersion_Con};

reg Sma10MHzSourceEnable_EnReg; 
// SMA status                   
wire [31:0] SmaInputStatus_Dat;
reg [31:0] SmaInputStatus_DatReg = 1'b0; 
// Selection Map1       
reg [15:0] SmaInput1SourceSelect_DatReg;
reg [15:0] SmaInput2SourceSelect_DatReg;
reg [15:0] SmaOutput3SourceSelect_DatReg;
reg [15:0] SmaOutput4SourceSelect_DatReg; 
// Selection Map2       
reg [15:0] SmaInput3SourceSelect_DatReg;
reg [15:0] SmaInput4SourceSelect_DatReg;
reg [15:0] SmaOutput1SourceSelect_DatReg;
reg [15:0] SmaOutput2SourceSelect_DatReg; 
// AXI4L slave 1 signals and regs
reg [1:0] Axi1_AccessState_StaReg = Axi_AccessState_Type_Rst_Con;
reg Axi1WriteAddrReady_RdyReg;
reg Axi1WriteDataReady_RdyReg;
reg Axi1WriteRespValid_ValReg;
reg [1:0] Axi1WriteRespResponse_DatReg;
reg Axi1ReadAddrReady_RdyReg;
reg Axi1ReadDataValid_ValReg;
reg [1:0] Axi1ReadDataResponse_DatReg;
reg [31:0] Axi1ReadDataData_DatReg;
reg [31:0] SmaInputSelect1_DatReg;
reg [31:0] SmaOutputSelect1_DatReg;
reg [31:0] SmaSelectorVersion1_DatReg; 
// AXI4L slave 2 signals and regs
reg [1:0] Axi2_AccessState_StaReg = Axi_AccessState_Type_Rst_Con;
reg Axi2WriteAddrReady_RdyReg;
reg Axi2WriteDataReady_RdyReg;
reg Axi2WriteRespValid_ValReg;
reg [1:0] Axi2WriteRespResponse_DatReg;
reg Axi2ReadAddrReady_RdyReg;
reg Axi2ReadDataValid_ValReg;
reg [1:0] Axi2ReadDataResponse_DatReg;
reg [31:0] Axi2ReadDataData_DatReg;
reg [31:0] SmaInputSelect2_DatReg;
reg [31:0] SmaOutputSelect2_DatReg;
reg [31:0] SmaSelectorVersion2_DatReg; 
  // SMA status 
  assign SmaInputStatus_Dat[1:0] = {SmaIn1_DatIn,SmaInput1SourceSelect_DatReg[15]};
  assign SmaInputStatus_Dat[5:4] = {SmaIn2_DatIn,SmaInput2SourceSelect_DatReg[15]};
  assign SmaInputStatus_Dat[9:8] = {SmaIn3_DatIn,SmaInput3SourceSelect_DatReg[15]};
  assign SmaInputStatus_Dat[13:12] = {SmaIn4_DatIn,SmaInput4SourceSelect_DatReg[15]};
  // Clock only supported via Sma Input 0 and must be enabled
  assign Sma10MHzSourceEnable_EnOut = Sma10MHzSourceEnable_EnReg;
  assign SmaIn1_EnOut = SmaInput1SourceSelect_DatReg[15];
  assign SmaIn2_EnOut = SmaInput2SourceSelect_DatReg[15];
  assign SmaIn3_EnOut = SmaInput3SourceSelect_DatReg[15];
  assign SmaIn4_EnOut = SmaInput4SourceSelect_DatReg[15];
  assign SmaOut1_EnOut = SmaOutput1SourceSelect_DatReg[15];
  assign SmaOut2_EnOut = SmaOutput2SourceSelect_DatReg[15];
  assign SmaOut3_EnOut = SmaOutput3SourceSelect_DatReg[15];
  assign SmaOut4_EnOut = SmaOutput4SourceSelect_DatReg[15];
  // Demultiplex the SMA inputs according to configuration
  assign SmaExtPpsSource1_EvtOut = SmaInput1SourceSelect_DatReg[0] == 1'b1 ? SmaIn1_DatIn : SmaInput2SourceSelect_DatReg[0] == 1'b1 ? SmaIn2_DatIn : SmaInput3SourceSelect_DatReg[0] == 1'b1 ? SmaIn3_DatIn : SmaInput4SourceSelect_DatReg[0] == 1'b1 ? SmaIn4_DatIn : 1'b0;
  assign SmaExtPpsSource2_EvtOut = SmaInput1SourceSelect_DatReg[1] == 1'b1 ? SmaIn1_DatIn : SmaInput2SourceSelect_DatReg[1] == 1'b1 ? SmaIn2_DatIn : SmaInput3SourceSelect_DatReg[1] == 1'b1 ? SmaIn3_DatIn : SmaInput4SourceSelect_DatReg[1] == 1'b1 ? SmaIn4_DatIn : 1'b0;
  assign SmaTs1Source_EvtOut = SmaInput1SourceSelect_DatReg[2] == 1'b1 ? SmaIn1_DatIn : SmaInput2SourceSelect_DatReg[2] == 1'b1 ? SmaIn2_DatIn : SmaInput3SourceSelect_DatReg[2] == 1'b1 ? SmaIn3_DatIn : SmaInput4SourceSelect_DatReg[2] == 1'b1 ? SmaIn4_DatIn : 1'b0;
  assign SmaTs2Source_EvtOut = SmaInput1SourceSelect_DatReg[3] == 1'b1 ? SmaIn1_DatIn : SmaInput2SourceSelect_DatReg[3] == 1'b1 ? SmaIn2_DatIn : SmaInput3SourceSelect_DatReg[3] == 1'b1 ? SmaIn3_DatIn : SmaInput4SourceSelect_DatReg[3] == 1'b1 ? SmaIn4_DatIn : 1'b0;
  assign SmaIrigSlaveSource_DatOut = SmaInput1SourceSelect_DatReg[4] == 1'b1 ? SmaIn1_DatIn : SmaInput2SourceSelect_DatReg[4] == 1'b1 ? SmaIn2_DatIn : SmaInput3SourceSelect_DatReg[4] == 1'b1 ? SmaIn3_DatIn : SmaInput4SourceSelect_DatReg[4] == 1'b1 ? SmaIn4_DatIn : 1'b0;
  assign SmaDcfSlaveSource_DatOut = SmaInput1SourceSelect_DatReg[5] == 1'b1 ? SmaIn1_DatIn : SmaInput2SourceSelect_DatReg[5] == 1'b1 ? SmaIn2_DatIn : SmaInput3SourceSelect_DatReg[5] == 1'b1 ? SmaIn3_DatIn : SmaInput4SourceSelect_DatReg[5] == 1'b1 ? SmaIn4_DatIn : 1'b0;
  assign SmaTs3Source_EvtOut = SmaInput1SourceSelect_DatReg[6] == 1'b1 ? SmaIn1_DatIn : SmaInput2SourceSelect_DatReg[6] == 1'b1 ? SmaIn2_DatIn : SmaInput3SourceSelect_DatReg[6] == 1'b1 ? SmaIn3_DatIn : SmaInput4SourceSelect_DatReg[6] == 1'b1 ? SmaIn4_DatIn : 1'b0;
  assign SmaTs4Source_EvtOut = SmaInput1SourceSelect_DatReg[7] == 1'b1 ? SmaIn1_DatIn : SmaInput2SourceSelect_DatReg[7] == 1'b1 ? SmaIn2_DatIn : SmaInput3SourceSelect_DatReg[7] == 1'b1 ? SmaIn3_DatIn : SmaInput4SourceSelect_DatReg[7] == 1'b1 ? SmaIn4_DatIn : 1'b0;
  assign SmaFreqCnt1Source_EvtOut = SmaInput1SourceSelect_DatReg[8] == 1'b1 ? SmaIn1_DatIn : SmaInput2SourceSelect_DatReg[8] == 1'b1 ? SmaIn2_DatIn : SmaInput3SourceSelect_DatReg[8] == 1'b1 ? SmaIn3_DatIn : SmaInput4SourceSelect_DatReg[8] == 1'b1 ? SmaIn4_DatIn : 1'b0;
  assign SmaFreqCnt2Source_EvtOut = SmaInput1SourceSelect_DatReg[9] == 1'b1 ? SmaIn1_DatIn : SmaInput2SourceSelect_DatReg[9] == 1'b1 ? SmaIn2_DatIn : SmaInput3SourceSelect_DatReg[9] == 1'b1 ? SmaIn3_DatIn : SmaInput4SourceSelect_DatReg[9] == 1'b1 ? SmaIn4_DatIn : 1'b0;
  assign SmaFreqCnt3Source_EvtOut = SmaInput1SourceSelect_DatReg[10] == 1'b1 ? SmaIn1_DatIn : SmaInput2SourceSelect_DatReg[10] == 1'b1 ? SmaIn2_DatIn : SmaInput3SourceSelect_DatReg[10] == 1'b1 ? SmaIn3_DatIn : SmaInput4SourceSelect_DatReg[10] == 1'b1 ? SmaIn4_DatIn : 1'b0;
  assign SmaFreqCnt4Source_EvtOut = SmaInput1SourceSelect_DatReg[11] == 1'b1 ? SmaIn1_DatIn : SmaInput2SourceSelect_DatReg[11] == 1'b1 ? SmaIn2_DatIn : SmaInput3SourceSelect_DatReg[11] == 1'b1 ? SmaIn3_DatIn : SmaInput4SourceSelect_DatReg[11] == 1'b1 ? SmaIn4_DatIn : 1'b0;
  assign SmaUartExtSource_DatOut = SmaInput1SourceSelect_DatReg[12] == 1'b1 ? SmaIn1_DatIn : SmaInput2SourceSelect_DatReg[12] == 1'b1 ? SmaIn2_DatIn : SmaInput3SourceSelect_DatReg[12] == 1'b1 ? SmaIn3_DatIn : SmaInput4SourceSelect_DatReg[12] == 1'b1 ? SmaIn4_DatIn : 1'b0;
  // Multiplex the SMA outputs according to configuration
  always @(*) begin
    case(SmaOutput1SourceSelect_DatReg[14:0])
      SmaOutputSource10Mhz_Con : SmaOut1_DatOut = Sma10MHzSource_ClkIn;
      SmaOutputSourceFpgaPps_Con : SmaOut1_DatOut = SmaFpgaPpsSource_EvtIn;
      SmaOutputSourceMacPps_Con : SmaOut1_DatOut = SmaMacPpsSource_EvtIn;
      SmaOutputSourceGnss1Pps_Con : SmaOut1_DatOut = SmaGnss1PpsSource_EvtIn;
      SmaOutputSourceGnss2Pps_Con : SmaOut1_DatOut = SmaGnss2PpsSource_EvtIn;
      SmaOutputSourceIrigMaster_Con : SmaOut1_DatOut = SmaIrigMasterSource_DatIn;
      SmaOutputSourceDcfMaster_Con : SmaOut1_DatOut = SmaDcfMasterSource_DatIn;
      SmaOutputSourceSignalGen1_Con : SmaOut1_DatOut = SmaSignalGen1Source_DatIn;
      SmaOutputSourceSignalGen2_Con : SmaOut1_DatOut = SmaSignalGen2Source_DatIn;
      SmaOutputSourceSignalGen3_Con : SmaOut1_DatOut = SmaSignalGen3Source_DatIn;
      SmaOutputSourceSignalGen4_Con : SmaOut1_DatOut = SmaSignalGen4Source_DatIn;
      SmaOutputSourceUartGnss1_Con : SmaOut1_DatOut = SmaUartGnss1Source_DatIn;
      SmaOutputSourceUartGnss2_Con : SmaOut1_DatOut = SmaUartGnss2Source_DatIn;
      SmaOutputSourceUartExt_Con : SmaOut1_DatOut = SmaUartExtSource_DatIn;
      SmaOutputSourceGnd_Con : SmaOut1_DatOut = 1'b0;
      SmaOutputSourceVcc_Con : SmaOut1_DatOut = 1'b1;
      default : SmaOut1_DatOut = Sma10MHzSource_ClkIn;
    endcase
  end

  always @(*) begin
    case(SmaOutput2SourceSelect_DatReg[14:0])
      SmaOutputSource10Mhz_Con : SmaOut2_DatOut = Sma10MHzSource_ClkIn;
      SmaOutputSourceFpgaPps_Con : SmaOut2_DatOut = SmaFpgaPpsSource_EvtIn;
      SmaOutputSourceMacPps_Con : SmaOut2_DatOut = SmaMacPpsSource_EvtIn;
      SmaOutputSourceGnss1Pps_Con : SmaOut2_DatOut = SmaGnss1PpsSource_EvtIn;
      SmaOutputSourceGnss2Pps_Con : SmaOut2_DatOut = SmaGnss2PpsSource_EvtIn;
      SmaOutputSourceIrigMaster_Con : SmaOut2_DatOut = SmaIrigMasterSource_DatIn;
      SmaOutputSourceDcfMaster_Con : SmaOut2_DatOut = SmaDcfMasterSource_DatIn;
      SmaOutputSourceSignalGen1_Con : SmaOut2_DatOut = SmaSignalGen1Source_DatIn;
      SmaOutputSourceSignalGen2_Con : SmaOut2_DatOut = SmaSignalGen2Source_DatIn;
      SmaOutputSourceSignalGen3_Con : SmaOut2_DatOut = SmaSignalGen3Source_DatIn;
      SmaOutputSourceSignalGen4_Con : SmaOut2_DatOut = SmaSignalGen4Source_DatIn;
      SmaOutputSourceUartGnss1_Con : SmaOut2_DatOut = SmaUartGnss1Source_DatIn;
      SmaOutputSourceUartGnss2_Con : SmaOut2_DatOut = SmaUartGnss2Source_DatIn;
      SmaOutputSourceUartExt_Con : SmaOut2_DatOut = SmaUartExtSource_DatIn;
      SmaOutputSourceGnd_Con : SmaOut2_DatOut = 1'b0;
      SmaOutputSourceVcc_Con : SmaOut2_DatOut = 1'b1;
      default : SmaOut2_DatOut = SmaFpgaPpsSource_EvtIn;
    endcase
  end

  always @(*) begin
    case(SmaOutput3SourceSelect_DatReg[14:0])
      SmaOutputSource10Mhz_Con : SmaOut3_DatOut = Sma10MHzSource_ClkIn;
      SmaOutputSourceFpgaPps_Con : SmaOut3_DatOut = SmaFpgaPpsSource_EvtIn;
      SmaOutputSourceMacPps_Con : SmaOut3_DatOut = SmaMacPpsSource_EvtIn;
      SmaOutputSourceGnss1Pps_Con : SmaOut3_DatOut = SmaGnss1PpsSource_EvtIn;
      SmaOutputSourceGnss2Pps_Con : SmaOut3_DatOut = SmaGnss2PpsSource_EvtIn;
      SmaOutputSourceIrigMaster_Con : SmaOut3_DatOut = SmaIrigMasterSource_DatIn;
      SmaOutputSourceDcfMaster_Con : SmaOut3_DatOut = SmaDcfMasterSource_DatIn;
      SmaOutputSourceSignalGen1_Con : SmaOut3_DatOut = SmaSignalGen1Source_DatIn;
      SmaOutputSourceSignalGen2_Con : SmaOut3_DatOut = SmaSignalGen2Source_DatIn;
      SmaOutputSourceSignalGen3_Con : SmaOut3_DatOut = SmaSignalGen3Source_DatIn;
      SmaOutputSourceSignalGen4_Con : SmaOut3_DatOut = SmaSignalGen4Source_DatIn;
      SmaOutputSourceUartGnss1_Con : SmaOut3_DatOut = SmaUartGnss1Source_DatIn;
      SmaOutputSourceUartGnss2_Con : SmaOut3_DatOut = SmaUartGnss2Source_DatIn;
      SmaOutputSourceUartExt_Con : SmaOut3_DatOut = SmaUartExtSource_DatIn;
      SmaOutputSourceGnd_Con : SmaOut3_DatOut = 1'b0;
      SmaOutputSourceVcc_Con : SmaOut3_DatOut = 1'b1;
      default : SmaOut3_DatOut = Sma10MHzSource_ClkIn;
    endcase
  end

  always @(*) begin
    case(SmaOutput4SourceSelect_DatReg[14:0])
      SmaOutputSource10Mhz_Con : SmaOut4_DatOut = Sma10MHzSource_ClkIn;
      SmaOutputSourceFpgaPps_Con : SmaOut4_DatOut = SmaFpgaPpsSource_EvtIn;
      SmaOutputSourceMacPps_Con : SmaOut4_DatOut = SmaMacPpsSource_EvtIn;
      SmaOutputSourceGnss1Pps_Con : SmaOut4_DatOut = SmaGnss1PpsSource_EvtIn;
      SmaOutputSourceGnss2Pps_Con : SmaOut4_DatOut = SmaGnss2PpsSource_EvtIn;
      SmaOutputSourceIrigMaster_Con : SmaOut4_DatOut = SmaIrigMasterSource_DatIn;
      SmaOutputSourceDcfMaster_Con : SmaOut4_DatOut = SmaDcfMasterSource_DatIn;
      SmaOutputSourceSignalGen1_Con : SmaOut4_DatOut = SmaSignalGen1Source_DatIn;
      SmaOutputSourceSignalGen2_Con : SmaOut4_DatOut = SmaSignalGen2Source_DatIn;
      SmaOutputSourceSignalGen3_Con : SmaOut4_DatOut = SmaSignalGen3Source_DatIn;
      SmaOutputSourceSignalGen4_Con : SmaOut4_DatOut = SmaSignalGen4Source_DatIn;
      SmaOutputSourceUartGnss1_Con : SmaOut4_DatOut = SmaUartGnss1Source_DatIn;
      SmaOutputSourceUartGnss2_Con : SmaOut4_DatOut = SmaUartGnss2Source_DatIn;
      SmaOutputSourceUartExt_Con : SmaOut4_DatOut = SmaUartExtSource_DatIn;
      SmaOutputSourceGnd_Con : SmaOut4_DatOut = 1'b0;
      SmaOutputSourceVcc_Con : SmaOut4_DatOut = 1'b1;
      default : SmaOut4_DatOut = SmaFpgaPpsSource_EvtIn;
    endcase
  end

  // AXI assignments
  assign Axi1WriteAddrReady_RdyOut = Axi1WriteAddrReady_RdyReg;
  assign Axi1WriteDataReady_RdyOut = Axi1WriteDataReady_RdyReg;
  assign Axi1WriteRespValid_ValOut = Axi1WriteRespValid_ValReg;
  assign Axi1WriteRespResponse_DatOut = Axi1WriteRespResponse_DatReg;
  assign Axi1ReadAddrReady_RdyOut = Axi1ReadAddrReady_RdyReg;
  assign Axi1ReadDataValid_ValOut = Axi1ReadDataValid_ValReg;
  assign Axi1ReadDataResponse_DatOut = Axi1ReadDataResponse_DatReg;
  assign Axi1ReadDataData_DatOut = Axi1ReadDataData_DatReg;
  assign Axi2WriteAddrReady_RdyOut = Axi2WriteAddrReady_RdyReg;
  assign Axi2WriteDataReady_RdyOut = Axi2WriteDataReady_RdyReg;
  assign Axi2WriteRespValid_ValOut = Axi2WriteRespValid_ValReg;
  assign Axi2WriteRespResponse_DatOut = Axi2WriteRespResponse_DatReg;
  assign Axi2ReadAddrReady_RdyOut = Axi2ReadAddrReady_RdyReg;
  assign Axi2ReadDataValid_ValOut = Axi2ReadDataValid_ValReg;
  assign Axi2ReadDataResponse_DatOut = Axi2ReadDataResponse_DatReg;
  assign Axi2ReadDataData_DatOut = Axi2ReadDataData_DatReg;

  // Process to enable the 10 MHz clock
  always @(posedge SysClk_ClkIn, posedge SysRstN_RstIn) begin
    if(SysRstN_RstIn == 1'b0) begin
      Sma10MHzSourceEnable_EnReg <= 1'b0;
    end else begin
      // Clock only supported via Sma Input 0 and must be enabled
      if(SmaInput1SourceSelect_DatReg[14:0] == 0) begin
        Sma10MHzSourceEnable_EnReg <= 1'b1;
      end else begin
        Sma10MHzSourceEnable_EnReg <= 1'b0;
      end
    end
  end

  // Access configuration and monitoring registers via the AXI4L slave 1
  // Set the SMA Input 1/2 and SMA Output 3/4
  always @(posedge SysClk_ClkIn, posedge SysRstN_RstIn) begin
    if(SysRstN_RstIn == 1'b0) begin
      Axi1WriteAddrReady_RdyReg <= 1'b0;
      Axi1WriteDataReady_RdyReg <= 1'b0;
      Axi1WriteRespValid_ValReg <= 1'b0;
      Axi1WriteRespResponse_DatReg <= {2{1'b0}};
      Axi1ReadAddrReady_RdyReg <= 1'b0;
      Axi1ReadDataValid_ValReg <= 1'b0;
      Axi1ReadDataResponse_DatReg <= {2{1'b0}};
      Axi1ReadDataData_DatReg <= {32{1'b0}};
      Axi1_AccessState_StaReg <= Axi_AccessState_Type_Rst_Con;
      `Axi_Init_Proc(SmaInputSelect1_Reg_Con, SmaInputSelect1_DatReg);
      `Axi_Init_Proc(SmaOutputSelect1_Reg_Con, SmaOutputSelect1_DatReg);
      `Axi_Init_Proc(SmaSelectorVersion1_Reg_Con, SmaSelectorVersion1_DatReg);
      `Axi_Init_Proc(SmaInputStatus_Reg_Con, SmaInputStatus_DatReg);
      SmaInput1SourceSelect_DatReg <= {16{1'b0}};
      SmaInput2SourceSelect_DatReg <= {16{1'b0}};
      SmaOutput3SourceSelect_DatReg <= {16{1'b0}};
      SmaOutput4SourceSelect_DatReg <= {16{1'b0}};
      SmaInputStatus_DatReg <= {32{1'b0}};
    end else begin
      if(Axi1WriteAddrValid_ValIn == 1'b1 && Axi1WriteAddrReady_RdyReg == 1'b1) 
        Axi1WriteAddrReady_RdyReg <= 1'b0;
      
      if(Axi1WriteDataValid_ValIn == 1'b1 && Axi1WriteDataReady_RdyReg == 1'b1) 
        Axi1WriteDataReady_RdyReg <= 1'b0;
      
      if(Axi1WriteRespValid_ValReg == 1'b1 && Axi1WriteRespReady_RdyIn == 1'b1) 
        Axi1WriteRespValid_ValReg <= 1'b0;
      
      if(Axi1ReadAddrValid_ValIn == 1'b1 && Axi1ReadAddrReady_RdyReg == 1'b1) 
        Axi1ReadAddrReady_RdyReg <= 1'b0;
      
      if(Axi1ReadDataValid_ValReg == 1'b1 && Axi1ReadDataReady_RdyIn == 1'b1) 
        Axi1ReadDataValid_ValReg <= 1'b0;
      
      case(Axi1_AccessState_StaReg)
      Idle_St : begin
        if(Axi1WriteAddrValid_ValIn == 1'b1 && Axi1WriteDataValid_ValIn == 1'b1) begin
          Axi1WriteAddrReady_RdyReg <= 1'b1;
          Axi1WriteDataReady_RdyReg <= 1'b1;
          Axi1_AccessState_StaReg <= Write_St;
        end
        else if(Axi1ReadAddrValid_ValIn == 1'b1) begin
          Axi1ReadAddrReady_RdyReg <= 1'b1;
          Axi1_AccessState_StaReg <= Read_St;
        end
      end
      Read_St : begin
        if(Axi1ReadAddrValid_ValIn == 1'b1 && Axi1ReadAddrReady_RdyReg == 1'b1) begin
          Axi1ReadDataValid_ValReg <= 1'b1;
          Axi1ReadDataResponse_DatReg <= Axi_RespSlvErr_Con;
          `Axi_Read_Proc(SmaInputSelect1_Reg_Con, SmaInputSelect1_DatReg, Axi1ReadAddrAddress_AdrIn, Axi1ReadDataData_DatReg, Axi1ReadDataResponse_DatReg);
          `Axi_Read_Proc(SmaOutputSelect1_Reg_Con, SmaOutputSelect1_DatReg, Axi1ReadAddrAddress_AdrIn, Axi1ReadDataData_DatReg, Axi1ReadDataResponse_DatReg);
          `Axi_Read_Proc(SmaSelectorVersion1_Reg_Con, SmaSelectorVersion1_DatReg, Axi1ReadAddrAddress_AdrIn, Axi1ReadDataData_DatReg, Axi1ReadDataResponse_DatReg);
          `Axi_Read_Proc(SmaInputStatus_Reg_Con, SmaInputStatus_DatReg, Axi1ReadAddrAddress_AdrIn, Axi1ReadDataData_DatReg, Axi1ReadDataResponse_DatReg);
          Axi1_AccessState_StaReg <= Resp_St;
        end
      end
      Write_St : begin
        if(Axi1WriteAddrValid_ValIn == 1'b1 && Axi1WriteAddrReady_RdyReg == 1'b1 && Axi1WriteDataValid_ValIn == 1'b1 && Axi1WriteDataReady_RdyReg == 1'b1) begin
          Axi1WriteRespValid_ValReg <= 1'b1;
          Axi1WriteRespResponse_DatReg <= Axi_RespSlvErr_Con;
          `Axi_Write_Proc(SmaInputSelect1_Reg_Con, SmaInputSelect1_DatReg, Axi1WriteAddrAddress_AdrIn, Axi1WriteDataData_DatIn, Axi1WriteRespResponse_DatReg);
          `Axi_Write_Proc(SmaOutputSelect1_Reg_Con, SmaOutputSelect1_DatReg, Axi1WriteAddrAddress_AdrIn, Axi1WriteDataData_DatIn, Axi1WriteRespResponse_DatReg);
          `Axi_Write_Proc(SmaSelectorVersion1_Reg_Con, SmaSelectorVersion1_DatReg, Axi1WriteAddrAddress_AdrIn, Axi1WriteDataData_DatIn, Axi1WriteRespResponse_DatReg);
          `Axi_Write_Proc(SmaInputStatus_Reg_Con, SmaInputStatus_DatReg, Axi1WriteAddrAddress_AdrIn, Axi1WriteDataData_DatIn, Axi1WriteRespResponse_DatReg);
          Axi1_AccessState_StaReg <= Resp_St;
        end
      end
      Resp_St : begin
        if((Axi1WriteRespValid_ValReg == 1'b1 && Axi1WriteRespReady_RdyIn == 1'b1) || (Axi1ReadDataValid_ValReg == 1'b1 && Axi1ReadDataReady_RdyIn == 1'b1)) begin
          Axi1_AccessState_StaReg <= Idle_St;
        end
      end
      endcase
      SmaInput1SourceSelect_DatReg <= SmaInputSelect1_DatReg[15:0];
      SmaInput2SourceSelect_DatReg <= SmaInputSelect1_DatReg[31:16];
      SmaOutput3SourceSelect_DatReg <= SmaOutputSelect1_DatReg[15:0];
      SmaOutput4SourceSelect_DatReg <= SmaOutputSelect1_DatReg[31:16];
      SmaInputStatus_DatReg <= SmaInputStatus_Dat;
    end
  end

  // Access configuration and monitoring registers via the AXI4L slave 2
  // Set the SMA Input 3/4 and SMA Output 1/2
  always @(posedge SysClk_ClkIn, posedge SysRstN_RstIn) begin
    if(SysRstN_RstIn == 1'b0) begin
      Axi2WriteAddrReady_RdyReg <= 1'b0;
      Axi2WriteDataReady_RdyReg <= 1'b0;
      Axi2WriteRespValid_ValReg <= 1'b0;
      Axi2WriteRespResponse_DatReg <= {2{1'b0}};
      Axi2ReadAddrReady_RdyReg <= 1'b0;
      Axi2ReadDataValid_ValReg <= 1'b0;
      Axi2ReadDataResponse_DatReg <= {2{1'b0}};
      Axi2ReadDataData_DatReg <= {32{1'b0}};
      Axi2_AccessState_StaReg <= Axi_AccessState_Type_Rst_Con;
      `Axi_Init_Proc(SmaInputSelect2_Reg_Con, SmaInputSelect2_DatReg);
      `Axi_Init_Proc(SmaOutputSelect2_Reg_Con, SmaOutputSelect2_DatReg);
      `Axi_Init_Proc(SmaSelectorVersion2_Reg_Con, SmaSelectorVersion2_DatReg);
      SmaInput3SourceSelect_DatReg <= {16{1'b0}};
      SmaInput4SourceSelect_DatReg <= {16{1'b0}};
      SmaOutput1SourceSelect_DatReg <= {16{1'b0}};
      SmaOutput2SourceSelect_DatReg <= {16{1'b0}};
    end else begin
      if(Axi2WriteAddrValid_ValIn == 1'b1 && Axi2WriteAddrReady_RdyReg == 1'b1) 
        Axi2WriteAddrReady_RdyReg <= 1'b0;
      
      if(Axi2WriteDataValid_ValIn == 1'b1 && Axi2WriteDataReady_RdyReg == 1'b1) 
        Axi2WriteDataReady_RdyReg <= 1'b0;
      
      if(Axi2WriteRespValid_ValReg == 1'b1 && Axi2WriteRespReady_RdyIn == 1'b1) 
        Axi2WriteRespValid_ValReg <= 1'b0;
      
      if(Axi2ReadAddrValid_ValIn == 1'b1 && Axi2ReadAddrReady_RdyReg == 1'b1) 
        Axi2ReadAddrReady_RdyReg <= 1'b0;
      
      if(Axi2ReadDataValid_ValReg == 1'b1 && Axi2ReadDataReady_RdyIn == 1'b1) 
        Axi2ReadDataValid_ValReg <= 1'b0;
      
      case(Axi2_AccessState_StaReg)
      Idle_St : begin
        if(Axi2WriteAddrValid_ValIn == 1'b1 && Axi2WriteDataValid_ValIn == 1'b1) begin
          Axi2WriteAddrReady_RdyReg <= 1'b1;
          Axi2WriteDataReady_RdyReg <= 1'b1;
          Axi2_AccessState_StaReg <= Write_St;
        end
        else if(Axi2ReadAddrValid_ValIn == 1'b1) begin
          Axi2ReadAddrReady_RdyReg <= 1'b1;
          Axi2_AccessState_StaReg <= Read_St;
        end
      end
      Read_St : begin
        if(Axi2ReadAddrValid_ValIn == 1'b1 && Axi2ReadAddrReady_RdyReg == 1'b1) begin
          Axi2ReadDataValid_ValReg <= 1'b1;
          Axi2ReadDataResponse_DatReg <= Axi_RespSlvErr_Con;
          `Axi_Read_Proc(SmaInputSelect2_Reg_Con, SmaInputSelect2_DatReg, Axi2ReadAddrAddress_AdrIn, Axi2ReadDataData_DatReg, Axi2ReadDataResponse_DatReg);
          `Axi_Read_Proc(SmaOutputSelect2_Reg_Con, SmaOutputSelect2_DatReg, Axi2ReadAddrAddress_AdrIn, Axi2ReadDataData_DatReg, Axi2ReadDataResponse_DatReg);
          `Axi_Read_Proc(SmaSelectorVersion2_Reg_Con, SmaSelectorVersion2_DatReg, Axi2ReadAddrAddress_AdrIn, Axi2ReadDataData_DatReg, Axi2ReadDataResponse_DatReg);
          Axi2_AccessState_StaReg <= Resp_St;
        end
      end
      Write_St : begin
        if(Axi2WriteAddrValid_ValIn == 1'b1 && Axi2WriteAddrReady_RdyReg == 1'b1 && Axi2WriteDataValid_ValIn == 1'b1 && Axi2WriteDataReady_RdyReg == 1'b1) begin
          Axi2WriteRespValid_ValReg <= 1'b1;
          Axi2WriteRespResponse_DatReg <= Axi_RespSlvErr_Con;
          `Axi_Write_Proc(SmaInputSelect2_Reg_Con, SmaInputSelect2_DatReg, Axi2WriteAddrAddress_AdrIn, Axi2WriteDataData_DatIn, Axi2WriteRespResponse_DatReg);
          `Axi_Write_Proc(SmaOutputSelect2_Reg_Con, SmaOutputSelect2_DatReg, Axi2WriteAddrAddress_AdrIn, Axi2WriteDataData_DatIn, Axi2WriteRespResponse_DatReg);
          `Axi_Write_Proc(SmaSelectorVersion2_Reg_Con, SmaSelectorVersion2_DatReg, Axi2WriteAddrAddress_AdrIn, Axi2WriteDataData_DatIn, Axi2WriteRespResponse_DatReg);
          Axi2_AccessState_StaReg <= Resp_St;
        end
      end
      Resp_St : begin
        if((Axi2WriteRespValid_ValReg == 1'b1 && Axi2WriteRespReady_RdyIn == 1'b1) || (Axi2ReadDataValid_ValReg == 1'b1 && Axi2ReadDataReady_RdyIn == 1'b1)) begin
          Axi2_AccessState_StaReg <= Idle_St;
        end
      end
      endcase
      SmaInput3SourceSelect_DatReg <= SmaInputSelect2_DatReg[15:0];
      SmaInput4SourceSelect_DatReg <= SmaInputSelect2_DatReg[31:16];
      SmaOutput1SourceSelect_DatReg <= SmaOutputSelect2_DatReg[15:0];
      SmaOutput2SourceSelect_DatReg <= SmaOutputSelect2_DatReg[31:16];
    end
  end
endmodule
