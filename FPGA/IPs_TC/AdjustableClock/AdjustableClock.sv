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
// Author: Ioannis Sotiropoulos, NetTimeLogic GmbH
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

// The Adjustable Clock is a time counter that can set its value directly or adjust its  --
// phase and frequency smoothly based on input adjustments. The component supports up to --
// 5 external adjustments, plus a register adjustment, which is provided by the CPU via  --
// the AXI slave. Each adjustment input can provide a direct time set to the time counter--
// (TimeAdjustment), or a phase correction (OffsetAdjustment), or a frequency correction --
// (DriftAdjustment). The component provides to the output the adjustable clock ClockTime--
// and its status flags InSync and InHoldover. Also, the PI servo coefficients which are --
// received by the AXI registers are forwarded to the output.                            --

`include "TimeCard_Package.svh"

module AdjustableClock #(
parameter [31:0] ClockPeriod_Gen=20, // 50MHz system clock, period in nanoseconds
parameter [31:0] ClockInSyncThreshold_Gen=20, // threshold in nanosecond
parameter [31:0] ClockInHoldoverTimeoutSecond_Gen=3 // holdover in seconds
)(
// System   
input wire SysClk_ClkIn,
input wire SysRstN_RstIn,
// Input 1  
// Time Adjustment Input    
input wire [SecondWidth_Con - 1:0] TimeAdjustmentIn1_Second_DatIn,
input wire [NanosecondWidth_Con - 1:0] TimeAdjustmentIn1_Nanosecond_DatIn,
input wire TimeAdjustmentIn1_ValIn,
// Offset Adjustment Input  
input wire [SecondWidth_Con - 1:0] OffsetAdjustmentIn1_Second_DatIn,
input wire [NanosecondWidth_Con - 1:0] OffsetAdjustmentIn1_Nanosecond_DatIn,
input wire OffsetAdjustmentIn1_Sign_DatIn,
input wire [AdjustmentIntervalWidth_Con - 1:0] OffsetAdjustmentIn1_Interval_DatIn,
input wire OffsetAdjustmentIn1_ValIn,
// Drift Adjustment Input   
input wire [NanosecondWidth_Con - 1:0] DriftAdjustmentIn1_Nanosecond_DatIn,
input wire DriftAdjustmentIn1_Sign_DatIn,
input wire [AdjustmentIntervalWidth_Con - 1:0] DriftAdjustmentIn1_Interval_DatIn,
input wire DriftAdjustmentIn1_ValIn,
// Input 2  
// Time Adjustment Input    
input wire [SecondWidth_Con - 1:0] TimeAdjustmentIn2_Second_DatIn,
input wire [NanosecondWidth_Con - 1:0] TimeAdjustmentIn2_Nanosecond_DatIn,
input wire TimeAdjustmentIn2_ValIn,
// Offset Adjustment Input  
input wire [SecondWidth_Con - 1:0] OffsetAdjustmentIn2_Second_DatIn,
input wire [NanosecondWidth_Con - 1:0] OffsetAdjustmentIn2_Nanosecond_DatIn,
input wire OffsetAdjustmentIn2_Sign_DatIn,
input wire [AdjustmentIntervalWidth_Con - 1:0] OffsetAdjustmentIn2_Interval_DatIn,
input wire OffsetAdjustmentIn2_ValIn,
// Drift Adjustment Input   
input wire [NanosecondWidth_Con - 1:0] DriftAdjustmentIn2_Nanosecond_DatIn,
input wire DriftAdjustmentIn2_Sign_DatIn,
input wire [AdjustmentIntervalWidth_Con - 1:0] DriftAdjustmentIn2_Interval_DatIn,
input wire DriftAdjustmentIn2_ValIn,
// Input 3  
// Time Adjustment Input    
input wire [SecondWidth_Con - 1:0] TimeAdjustmentIn3_Second_DatIn,
input wire [NanosecondWidth_Con - 1:0] TimeAdjustmentIn3_Nanosecond_DatIn,
input wire TimeAdjustmentIn3_ValIn,
// Offset Adjustment Input  
input wire [SecondWidth_Con - 1:0] OffsetAdjustmentIn3_Second_DatIn,
input wire [NanosecondWidth_Con - 1:0] OffsetAdjustmentIn3_Nanosecond_DatIn,
input wire OffsetAdjustmentIn3_Sign_DatIn,
input wire [AdjustmentIntervalWidth_Con - 1:0] OffsetAdjustmentIn3_Interval_DatIn,
input wire OffsetAdjustmentIn3_ValIn,
// Drift Adjustment Input   
input wire [NanosecondWidth_Con - 1:0] DriftAdjustmentIn3_Nanosecond_DatIn,
input wire DriftAdjustmentIn3_Sign_DatIn,
input wire [AdjustmentIntervalWidth_Con - 1:0] DriftAdjustmentIn3_Interval_DatIn,
input wire DriftAdjustmentIn3_ValIn,
// Input 4  
// Time Adjustment Input    
input wire [SecondWidth_Con - 1:0] TimeAdjustmentIn4_Second_DatIn,
input wire [NanosecondWidth_Con - 1:0] TimeAdjustmentIn4_Nanosecond_DatIn,
input wire TimeAdjustmentIn4_ValIn,
// Offset Adjustment Input  
input wire [SecondWidth_Con - 1:0] OffsetAdjustmentIn4_Second_DatIn,
input wire [NanosecondWidth_Con - 1:0] OffsetAdjustmentIn4_Nanosecond_DatIn,
input wire OffsetAdjustmentIn4_Sign_DatIn,
input wire [AdjustmentIntervalWidth_Con - 1:0] OffsetAdjustmentIn4_Interval_DatIn,
input wire OffsetAdjustmentIn4_ValIn,
// Drift Adjustment Input   
input wire [NanosecondWidth_Con - 1:0] DriftAdjustmentIn4_Nanosecond_DatIn,
input wire DriftAdjustmentIn4_Sign_DatIn,
input wire [AdjustmentIntervalWidth_Con - 1:0] DriftAdjustmentIn4_Interval_DatIn,
input wire DriftAdjustmentIn4_ValIn,
// Input 5  
// Time Adjustment Input    
input wire [SecondWidth_Con - 1:0] TimeAdjustmentIn5_Second_DatIn,
input wire [NanosecondWidth_Con - 1:0] TimeAdjustmentIn5_Nanosecond_DatIn,
input wire TimeAdjustmentIn5_ValIn,
// Offset Adjustment Input  
input wire [SecondWidth_Con - 1:0] OffsetAdjustmentIn5_Second_DatIn,
input wire [NanosecondWidth_Con - 1:0] OffsetAdjustmentIn5_Nanosecond_DatIn,
input wire OffsetAdjustmentIn5_Sign_DatIn,
input wire [AdjustmentIntervalWidth_Con - 1:0] OffsetAdjustmentIn5_Interval_DatIn,
input wire OffsetAdjustmentIn5_ValIn,
// Drift Adjustment Input   
input wire [NanosecondWidth_Con - 1:0] DriftAdjustmentIn5_Nanosecond_DatIn,
input wire DriftAdjustmentIn5_Sign_DatIn,
input wire [AdjustmentIntervalWidth_Con - 1:0] DriftAdjustmentIn5_Interval_DatIn,
input wire DriftAdjustmentIn5_ValIn,
// Time Output  
output wire [SecondWidth_Con - 1:0] ClockTime_Second_DatOut,
output wire [NanosecondWidth_Con - 1:0] ClockTime_Nanosecond_DatOut,
output wire ClockTime_TimeJump_DatOut,
output wire ClockTime_ValOut,
// In Sync Output   
output wire InSync_DatOut,
output wire InHoldover_DatOut,
// Servo Output 
output wire ServoFactorsValid_ValOut,
output wire [31:0] ServoOffsetFactorP_DatOut,
output wire [31:0] ServoOffsetFactorI_DatOut,
output wire [31:0] ServoDriftFactorP_DatOut,
output wire [31:0] ServoDriftFactorI_DatOut,
// Axi  
input wire AxiWriteAddrValid_ValIn,
output wire AxiWriteAddrReady_RdyOut,
input wire [15:0] AxiWriteAddrAddress_AdrIn,
input wire [2:0] AxiWriteAddrProt_DatIn,
input wire AxiWriteDataValid_ValIn,
output wire AxiWriteDataReady_RdyOut,
input wire [31:0] AxiWriteDataData_DatIn,
input wire [3:0] AxiWriteDataStrobe_DatIn,
output wire AxiWriteRespValid_ValOut,
input wire AxiWriteRespReady_RdyIn,
output wire [1:0] AxiWriteRespResponse_DatOut,
input wire AxiReadAddrValid_ValIn,
output wire AxiReadAddrReady_RdyOut,
input wire [15:0] AxiReadAddrAddress_AdrIn,
input wire [2:0] AxiReadAddrProt_DatIn,
output wire AxiReadDataValid_ValOut,
input wire AxiReadDataReady_RdyIn,
output wire [1:0] AxiReadDataResponse_DatOut,
output wire [31:0] AxiReadDataData_DatOut
);
import timecard_package::*;

parameter [7:0]ClockMajorVersion_Con = 0;
parameter [7:0]ClockMinorVersion_Con = 1;
parameter [15:0]ClockBuildVersion_Con = 0;
parameter [31:0]ClockVersion_Con = { ClockMajorVersion_Con,ClockMinorVersion_Con,ClockBuildVersion_Con }; 
// AXI registers    
//constant ClockControl_Reg_Con                   : Axi_Reg_Type:= (x"00000000", x"C000010F", Rw_E, x"00000000");
Axi_Reg_Type ClockControl_Reg_Con = '{Addr:32'h00000000, Mask:32'hC000010F, RegType:Rw_E, Reset:32'h00000000};
//constant ClockStatus_Reg_Con                    : Axi_Reg_Type:= (x"00000004", x"00000003", Ro_E, x"00000000");
Axi_Reg_Type ClockStatus_Reg_Con = '{Addr:32'h00000004, Mask:32'h00000003, RegType:Ro_E, Reset:32'h00000000};
//constant ClockSelect_Reg_Con                    : Axi_Reg_Type:= (x"00000008", x"00FF00FF", Rw_E, x"00000000");
Axi_Reg_Type ClockSelect_Reg_Con = '{Addr:32'h00000008, Mask:32'h00FF00FF, RegType:Rw_E, Reset:32'h00000000};
//constant ClockVersion_Reg_Con                   : Axi_Reg_Type:= (x"0000000C", x"FFFFFFFF", Ro_E, ClockVersion_Con);
Axi_Reg_Type ClockVersion_Reg_Con = '{Addr:32'h0000000C, Mask:32'hFFFFFFFF, RegType:Ro_E, Reset:ClockVersion_Con};
//constant ClockTimeValueL_Reg_Con                : Axi_Reg_Type:= (x"00000010", x"FFFFFFFF", Ro_E, x"00000000");
Axi_Reg_Type ClockTimeValueL_Reg_Con = '{Addr:32'h00000010, Mask:32'hFFFFFFFF, RegType:Ro_E, Reset:32'h00000000};
//constant ClockTimeValueH_Reg_Con                : Axi_Reg_Type:= (x"00000014", x"FFFFFFFF", Ro_E, x"00000000");
Axi_Reg_Type ClockTimeValueH_Reg_Con = '{Addr:32'h00000014, Mask:32'hFFFFFFFF, RegType:Ro_E, Reset:32'h00000000};
//constant ClockTimeAdjValueL_Reg_Con             : Axi_Reg_Type:= (x"00000020", x"FFFFFFFF", Rw_E, x"00000000");
Axi_Reg_Type ClockTimeAdjValueL_Reg_Con = '{Addr:32'h00000020, Mask:32'hFFFFFFFF, RegType:Rw_E, Reset:32'h00000000};
//constant ClockTimeAdjValueH_Reg_Con             : Axi_Reg_Type:= (x"00000024", x"FFFFFFFF", Rw_E, x"00000000");
Axi_Reg_Type ClockTimeAdjValueH_Reg_Con = '{Addr:32'h00000024, Mask:32'hFFFFFFFF, RegType:Rw_E, Reset:32'h00000000};
//constant ClockOffsetAdjValue_Reg_Con            : Axi_Reg_Type:= (x"00000030", x"FFFFFFFF", Rw_E, x"00000000");
Axi_Reg_Type ClockOffsetAdjValue_Reg_Con = '{Addr:32'h00000030, Mask:32'hFFFFFFFF, RegType:Rw_E, Reset:32'h00000000};
//constant ClockOffsetAdjInterval_Reg_Con         : Axi_Reg_Type:= (x"00000034", x"FFFFFFFF", Rw_E, x"00000000");
Axi_Reg_Type ClockOffsetAdjInterval_Reg_Con = '{Addr:32'h00000034, Mask:32'hFFFFFFFF, RegType:Rw_E, Reset:32'h00000000};
//constant ClockDriftAdjValue_Reg_Con             : Axi_Reg_Type:= (x"00000040", x"FFFFFFFF", Rw_E, x"00000000");
Axi_Reg_Type ClockDriftAdjValue_Reg_Con = '{Addr:32'h00000040, Mask:32'hFFFFFFFF, RegType:Rw_E, Reset:32'h00000000};
//constant ClockDriftAdjInterval_Reg_Con          : Axi_Reg_Type:= (x"00000044", x"FFFFFFFF", Rw_E, x"00000000");
Axi_Reg_Type ClockDriftAdjInterval_Reg_Con = '{Addr:32'h00000044, Mask:32'hFFFFFFFF, RegType:Rw_E, Reset:32'h00000000};
//constant ClockInSyncThreshold_Reg_Con           : Axi_Reg_Type:= (x"00000050", x"FFFFFFFF", Rw_E, x"00000000");
Axi_Reg_Type ClockInSyncThreshold_Reg_Con = '{Addr:32'h00000050, Mask:32'hFFFFFFFF, RegType:Rw_E, Reset:32'h00000000};
//constant ClockServoOffsetFactorP_Reg_Con        : Axi_Reg_Type:= (x"00000060", x"FFFFFFFF", Rw_E, x"00000000");
Axi_Reg_Type ClockServoOffsetFactorP_Reg_Con = '{Addr:32'h00000060, Mask:32'hFFFFFFFF, RegType:Rw_E, Reset:32'h00000000};
//constant ClockServoOffsetFactorI_Reg_Con        : Axi_Reg_Type:= (x"00000064", x"FFFFFFFF", Rw_E, x"00000000");
Axi_Reg_Type ClockServoOffsetFactorI_Reg_Con = '{Addr:32'h00000064, Mask:32'hFFFFFFFF, RegType:Rw_E, Reset:32'h00000000};
//constant ClockServoDriftFactorP_Reg_Con         : Axi_Reg_Type:= (x"00000068", x"FFFFFFFF", Rw_E, x"00000000");
Axi_Reg_Type ClockServoDriftFactorP_Reg_Con = '{Addr:32'h00000068, Mask:32'hFFFFFFFF, RegType:Rw_E, Reset:32'h00000000};
//constant ClockServoDriftFactorI_Reg_Con         : Axi_Reg_Type:= (x"0000006C", x"FFFFFFFF", Rw_E, x"00000000");
Axi_Reg_Type ClockServoDriftFactorI_Reg_Con = '{Addr:32'h0000006C, Mask:32'hFFFFFFFF, RegType:Rw_E, Reset:32'h00000000};
//constant ClockStatusOffset_Reg_Con              : Axi_Reg_Type:= (x"00000070", x"FFFFFFFF", Ro_E, x"00000000");
Axi_Reg_Type ClockStatusOffset_Reg_Con = '{Addr:32'h00000070, Mask:32'hFFFFFFFF, RegType:Ro_E, Reset:32'h00000000};
//constant ClockStatusDrift_Reg_Con               : Axi_Reg_Type:= (x"00000074", x"FFFFFFFF", Ro_E, x"00000000");
Axi_Reg_Type ClockStatusDrift_Reg_Con = '{Addr:32'h00000074, Mask:32'hFFFFFFFF, RegType:Ro_E, Reset:32'h00000000};
// AXI reg bits 
parameter ClockControl_EnableBit_Con = 0;
parameter ClockControl_TimeAdjValBit_Con = 1;
parameter ClockControl_OffsetAdjValBit_Con = 2;
parameter ClockControl_DriftAdjValBit_Con = 3;
parameter ClockControl_ServoValBit_Con = 8;
parameter ClockControl_TimeReadValBit_Con = 30;
parameter ClockControl_TimeReadDValBit_Con = 31;
parameter ClockStatus_InSyncBit_Con = 0;
parameter ClockStatus_InHoldoverBit_Con = 1;  // max 2 ns extra per clock cycle   
parameter CountAdjustmentWidth_Con = $clog2(2 + 1);  // 3 possible corection values: 0,1,2
parameter ClockIncrementWidth_Con = $clog2((ClockPeriod_Gen + 2) + 1); 
// Enable clock
wire Enable_Ena;
wire [7:0] SelectInput_Dat; 
// Register Mapped Time Adjustment
wire [SecondWidth_Con - 1:0] TimeAdjustmentReg_Second_Dat;
wire [NanosecondWidth_Con - 1:0] TimeAdjustmentReg_Nanosecond_Dat;
wire TimeAdjustmentReg_Val; 
// Register Mapped Offset Adjustment
wire [SecondWidth_Con - 1:0] OffsetAdjustmentReg_Second_Dat;
wire [NanosecondWidth_Con - 1:0] OffsetAdjustmentReg_Nanosecond_Dat;
wire OffsetAdjustmentReg_Sign_Dat;
wire [AdjustmentIntervalWidth_Con - 1:0] OffsetAdjustmentReg_Interval_Dat;
wire OffsetAdjustmentReg_Val; 
// Register Mapped Adjustment
wire [NanosecondWidth_Con - 1:0] DriftAdjustmentReg_Nanosecond_Dat;
wire DriftAdjustmentReg_Sign_Dat;
wire [AdjustmentIntervalWidth_Con - 1:0] DriftAdjustmentReg_Interval_Dat;
wire DriftAdjustmentReg_Val; 
// Multiplexed Time Adjustment
wire [SecondWidth_Con - 1:0] TimeAdjustmentMux_Second_Dat;
wire [NanosecondWidth_Con - 1:0] TimeAdjustmentMux_Nanosecond_Dat;
wire TimeAdjustmentMux_Val; 
// Multiplexed Offset Adjustment
wire [SecondWidth_Con - 1:0] OffsetAdjustmentMux_Second_Dat;
wire [NanosecondWidth_Con - 1:0] OffsetAdjustmentMux_Nanosecond_Dat;
wire OffsetAdjustmentMux_Sign_Dat;
wire [AdjustmentIntervalWidth_Con - 1:0] OffsetAdjustmentMux_Interval_Dat;
wire OffsetAdjustmentMux_Val; 
// Multiplexed Drift Adjustment
wire [NanosecondWidth_Con - 1:0] DriftAdjustmentMux_Nanosecond_Dat;
wire DriftAdjustmentMux_Sign_Dat;
wire [AdjustmentIntervalWidth_Con - 1:0] DriftAdjustmentMux_Interval_Dat;
wire DriftAdjustmentMux_Val; 
// Calculate Drift Adjustment
reg DriftAdjustmentMux_ValReg;
reg [(2 * AdjustmentIntervalWidth_Con) - 1:0] DriftAdjustmentMux_IntervalExtend_DatReg;
reg [(2 * AdjustmentIntervalWidth_Con) - 1:0] DriftAdjustmentMux_PeriodExtend_DatReg;
reg [AdjustmentIntervalWidth_Con - 1:0] DriftAdjustmentMux_Nanosecond_DatReg;
reg [AdjustmentIntervalWidth_Con - 1:0] DriftAdjustmentMux_Interval_DatReg;
reg DriftAdjustmentMux_Sign_DatReg;
reg StartCalcDriftInterval_EvtReg;
reg CalcDriftInterval_StaReg;
reg [31:0] CalcDriftIntervalStep_CntReg;
reg [AdjustmentIntervalWidth_Con - 1:0] DriftAdjustmentOld_Nanosecond_DatReg;
reg DriftAdjustmentOld_Sign_DatReg;
reg [AdjustmentIntervalWidth_Con - 1:0] DriftCount_CntReg;
reg [AdjustmentIntervalWidth_Con - 1:0] DriftInterval_DatReg;
reg [AdjustmentIntervalWidth_Con - 1:0] DriftNanosecond_DatReg;
reg DriftSign_DatReg; 
// Calculate Offset Adjustment
reg OffsetAdjustmentMux_ValReg;
reg [SecondWidth_Con - 1:0] OffsetAdjustmentMux_Second_DatReg;
reg [AdjustmentIntervalWidth_Con - 1:0] OffsetAdjustmentMux_Nanosecond_DatReg;
reg OffsetAdjustmentMux_Sign_DatReg;
reg [AdjustmentIntervalWidth_Con - 1:0] OffsetAdjustmentMux_Interval_DatReg;
reg [(2 * AdjustmentIntervalWidth_Con) - 1:0] OffsetAdjustmentMux_IntervalExtend_DatReg;
reg [(2 * AdjustmentIntervalWidth_Con) - 1:0] OffsetAdjustmentMux_PeriodExtend_DatReg;
reg StartCalcOffsetInterval_EvtReg;
reg CalcOffsetInterval_StaReg;
reg [31:0] CalcOffsetIntervalStep_CntReg; // 4:0 actually, only holds 0 to 31
reg [AdjustmentIntervalWidth_Con - 1:0] OffsetCount_CntReg;
reg [AdjustmentIntervalWidth_Con - 1:0] OffsetInterval_DatReg;
reg [SecondWidth_Con - 1:0] OffsetSecond_DatReg;
reg [AdjustmentIntervalWidth_Con - 1:0] OffsetNanosecond_DatReg;
reg [AdjustmentIntervalWidth_Con - 1:0] OffsetNanosecondOrigin_DatReg;
reg OffsetSign_DatReg; 
// Reg Time Adjustment
reg TimeAdjustmentMux_ValReg; 
// Clock Time
reg [SecondWidth_Con - 1:0] ClockTime_Second_DatReg;
reg [NanosecondWidth_Con - 1:0] ClockTime_Nanosecond_DatReg;
reg ClockTime_TimeJump_DatReg;
reg ClockTime_ValReg; 
// clock increase per correction
reg [ClockIncrementWidth_Con - 1:0] ClockIncrement_DatReg; 
// time adjustment
reg [SecondWidth_Con - 1:0] TimeAdjust_Second_DatReg;
reg [NanosecondWidth_Con - 1:0] TimeAdjust_Nanosecond_DatReg;
reg TimeAdjust_ValReg; 
// counter adjustment
reg [CountAdjustmentWidth_Con - 1:0] CountAdjust_Nanosecond_DatReg;
reg CountAdjust_Sign_DatReg;
reg CountAdjust_ValReg; 
// in sync and in holdover
reg InSync_DatReg;
reg InHoldover_DatReg;
reg ClockTimeB0_DatReg;
reg [31:0] Holdover_CntReg;
reg [3:0] OffsetArray_DatReg; 
// Axi
reg [1:0] Axi_AccessState_StaReg = Axi_AccessState_Type_Rst_Con;
reg AxiWriteAddrReady_RdyReg;
reg AxiWriteDataReady_RdyReg;
reg AxiWriteRespValid_ValReg;
reg [1:0] AxiWriteRespResponse_DatReg;
reg AxiReadAddrReady_RdyReg;
reg AxiReadDataValid_ValReg;
reg [1:0] AxiReadDataResponse_DatReg;
reg [31:0] AxiReadDataData_DatReg;
reg [31:0] ClockSelect_DatReg;
reg [31:0] ClockStatus_DatReg;
reg [31:0] ClockControl_DatReg;
reg [31:0] ClockVersion_DatReg;
reg [31:0] ClockTimeValueL_DatReg;
reg [31:0] ClockTimeValueH_DatReg;
reg [31:0] ClockTimeAdjValueL_DatReg;
reg [31:0] ClockTimeAdjValueH_DatReg;
reg [31:0] ClockOffsetAdjValue_DatReg;
reg [31:0] ClockOffsetAdjInterval_DatReg;
reg [31:0] ClockDriftAdjValue_DatReg;
reg [31:0] ClockDriftAdjInterval_DatReg;
reg [31:0] ClockInSyncThreshold_DatReg = ClockInSyncThreshold_Gen;
reg [31:0] ClockServoOffsetFactorP_DatReg = OffsetFactorP_Con;
reg [31:0] ClockServoOffsetFactorI_DatReg = OffsetFactorI_Con;
reg [31:0] ClockServoDriftFactorP_DatReg = DriftFactorP_Con;
reg [31:0] ClockServoDriftFactorI_DatReg = DriftFactorI_Con;
reg [31:0] ClockStatusOffset_DatReg;
reg [31:0] ClockStatusDrift_DatReg; 

  assign ClockTime_Second_DatOut = ClockTime_Second_DatReg;
  assign ClockTime_Nanosecond_DatOut = ClockTime_Nanosecond_DatReg;
  assign ClockTime_TimeJump_DatOut = ClockTime_TimeJump_DatReg;
  assign ClockTime_ValOut = ClockTime_ValReg;
  assign InSync_DatOut = InSync_DatReg;
  assign InHoldover_DatOut = InHoldover_DatReg;
  assign ServoFactorsValid_ValOut = ClockControl_DatReg[ClockControl_ServoValBit_Con];
  assign ServoOffsetFactorP_DatOut = ClockServoOffsetFactorP_DatReg;
  assign ServoOffsetFactorI_DatOut = ClockServoOffsetFactorI_DatReg;
  assign ServoDriftFactorP_DatOut = ClockServoDriftFactorP_DatReg;
  assign ServoDriftFactorI_DatOut = ClockServoDriftFactorI_DatReg;
  assign Enable_Ena = ClockControl_DatReg[ClockControl_EnableBit_Con];
  assign SelectInput_Dat = ClockSelect_DatReg[7:0];
  // Clock Source Mux for Time, Offset and Drift adjustments
  assign TimeAdjustmentMux_Second_Dat = (SelectInput_Dat == 1) ? TimeAdjustmentIn1_Second_DatIn : (SelectInput_Dat == 2) ? TimeAdjustmentIn2_Second_DatIn : (SelectInput_Dat == 3) ? TimeAdjustmentIn3_Second_DatIn : (SelectInput_Dat == 4) ? TimeAdjustmentIn4_Second_DatIn : (SelectInput_Dat == 5) ? TimeAdjustmentIn5_Second_DatIn : (SelectInput_Dat == 254) ? TimeAdjustmentReg_Second_Dat : {((SecondWidth_Con - 1)-(0)+1){1'b0}};
  assign TimeAdjustmentMux_Nanosecond_Dat = (SelectInput_Dat == 1) ? TimeAdjustmentIn1_Nanosecond_DatIn : (SelectInput_Dat == 2) ? TimeAdjustmentIn2_Nanosecond_DatIn : (SelectInput_Dat == 3) ? TimeAdjustmentIn3_Nanosecond_DatIn : (SelectInput_Dat == 4) ? TimeAdjustmentIn4_Nanosecond_DatIn : (SelectInput_Dat == 5) ? TimeAdjustmentIn5_Nanosecond_DatIn : (SelectInput_Dat == 254) ? TimeAdjustmentReg_Nanosecond_Dat : {((NanosecondWidth_Con - 1)-(0)+1){1'b0}};
  assign TimeAdjustmentMux_Val = (SelectInput_Dat == 1) ? TimeAdjustmentIn1_ValIn : (SelectInput_Dat == 2) ? TimeAdjustmentIn2_ValIn : (SelectInput_Dat == 3) ? TimeAdjustmentIn3_ValIn : (SelectInput_Dat == 4) ? TimeAdjustmentIn4_ValIn : (SelectInput_Dat == 5) ? TimeAdjustmentIn5_ValIn : (SelectInput_Dat == 254) ? TimeAdjustmentReg_Val : 1'b0;
  assign OffsetAdjustmentMux_Second_Dat = (SelectInput_Dat == 1) ? OffsetAdjustmentIn1_Second_DatIn : (SelectInput_Dat == 2) ? OffsetAdjustmentIn2_Second_DatIn : (SelectInput_Dat == 3) ? OffsetAdjustmentIn3_Second_DatIn : (SelectInput_Dat == 4) ? OffsetAdjustmentIn4_Second_DatIn : (SelectInput_Dat == 5) ? OffsetAdjustmentIn5_Second_DatIn : (SelectInput_Dat == 254) ? OffsetAdjustmentReg_Second_Dat : {((SecondWidth_Con - 1)-(0)+1){1'b0}};
  assign OffsetAdjustmentMux_Nanosecond_Dat = (SelectInput_Dat == 1) ? OffsetAdjustmentIn1_Nanosecond_DatIn : (SelectInput_Dat == 2) ? OffsetAdjustmentIn2_Nanosecond_DatIn : (SelectInput_Dat == 3) ? OffsetAdjustmentIn3_Nanosecond_DatIn : (SelectInput_Dat == 4) ? OffsetAdjustmentIn4_Nanosecond_DatIn : (SelectInput_Dat == 5) ? OffsetAdjustmentIn5_Nanosecond_DatIn : (SelectInput_Dat == 254) ? OffsetAdjustmentReg_Nanosecond_Dat : {((NanosecondWidth_Con - 1)-(0)+1){1'b0}};
  assign OffsetAdjustmentMux_Sign_Dat = (SelectInput_Dat == 1) ? OffsetAdjustmentIn1_Sign_DatIn : (SelectInput_Dat == 2) ? OffsetAdjustmentIn2_Sign_DatIn : (SelectInput_Dat == 3) ? OffsetAdjustmentIn3_Sign_DatIn : (SelectInput_Dat == 4) ? OffsetAdjustmentIn4_Sign_DatIn : (SelectInput_Dat == 5) ? OffsetAdjustmentIn5_Sign_DatIn : (SelectInput_Dat == 254) ? OffsetAdjustmentReg_Sign_Dat : 1'b0;
  assign OffsetAdjustmentMux_Interval_Dat = (SelectInput_Dat == 1) ? OffsetAdjustmentIn1_Interval_DatIn : (SelectInput_Dat == 2) ? OffsetAdjustmentIn2_Interval_DatIn : (SelectInput_Dat == 3) ? OffsetAdjustmentIn3_Interval_DatIn : (SelectInput_Dat == 4) ? OffsetAdjustmentIn4_Interval_DatIn : (SelectInput_Dat == 5) ? OffsetAdjustmentIn5_Interval_DatIn : (SelectInput_Dat == 254) ? OffsetAdjustmentReg_Interval_Dat : {((AdjustmentIntervalWidth_Con - 1)-(0)+1){1'b0}};
  assign OffsetAdjustmentMux_Val = (SelectInput_Dat == 1) ? OffsetAdjustmentIn1_ValIn : (SelectInput_Dat == 2) ? OffsetAdjustmentIn2_ValIn : (SelectInput_Dat == 3) ? OffsetAdjustmentIn3_ValIn : (SelectInput_Dat == 4) ? OffsetAdjustmentIn4_ValIn : (SelectInput_Dat == 5) ? OffsetAdjustmentIn5_ValIn : (SelectInput_Dat == 254) ? OffsetAdjustmentReg_Val : 1'b0;
  assign DriftAdjustmentMux_Nanosecond_Dat = (SelectInput_Dat == 1) ? DriftAdjustmentIn1_Nanosecond_DatIn : (SelectInput_Dat == 2) ? DriftAdjustmentIn2_Nanosecond_DatIn : (SelectInput_Dat == 3) ? DriftAdjustmentIn3_Nanosecond_DatIn : (SelectInput_Dat == 4) ? DriftAdjustmentIn4_Nanosecond_DatIn : (SelectInput_Dat == 5) ? DriftAdjustmentIn5_Nanosecond_DatIn : (SelectInput_Dat == 254) ? DriftAdjustmentReg_Nanosecond_Dat : {((NanosecondWidth_Con - 1)-(0)+1){1'b0}};
  assign DriftAdjustmentMux_Sign_Dat = (SelectInput_Dat == 1) ? DriftAdjustmentIn1_Sign_DatIn : (SelectInput_Dat == 2) ? DriftAdjustmentIn2_Sign_DatIn : (SelectInput_Dat == 3) ? DriftAdjustmentIn3_Sign_DatIn : (SelectInput_Dat == 4) ? DriftAdjustmentIn4_Sign_DatIn : (SelectInput_Dat == 5) ? DriftAdjustmentIn5_Sign_DatIn : (SelectInput_Dat == 254) ? DriftAdjustmentReg_Sign_Dat : 1'b0;
  assign DriftAdjustmentMux_Interval_Dat = (SelectInput_Dat == 1) ? DriftAdjustmentIn1_Interval_DatIn : (SelectInput_Dat == 2) ? DriftAdjustmentIn2_Interval_DatIn : (SelectInput_Dat == 3) ? DriftAdjustmentIn3_Interval_DatIn : (SelectInput_Dat == 4) ? DriftAdjustmentIn4_Interval_DatIn : (SelectInput_Dat == 5) ? DriftAdjustmentIn5_Interval_DatIn : (SelectInput_Dat == 254) ? DriftAdjustmentReg_Interval_Dat : {((AdjustmentIntervalWidth_Con - 1)-(0)+1){1'b0}};
  assign DriftAdjustmentMux_Val = (SelectInput_Dat == 1) ? DriftAdjustmentIn1_ValIn : (SelectInput_Dat == 2) ? DriftAdjustmentIn2_ValIn : (SelectInput_Dat == 3) ? DriftAdjustmentIn3_ValIn : (SelectInput_Dat == 4) ? DriftAdjustmentIn4_ValIn : (SelectInput_Dat == 5) ? DriftAdjustmentIn5_ValIn : (SelectInput_Dat == 254) ? DriftAdjustmentReg_Val : 1'b0;
  // Register Mapped Adjustments  
  assign TimeAdjustmentReg_Second_Dat = ClockTimeAdjValueH_DatReg;
  assign TimeAdjustmentReg_Nanosecond_Dat = ClockTimeAdjValueL_DatReg;
  assign TimeAdjustmentReg_Val = ClockControl_DatReg[ClockControl_TimeAdjValBit_Con];
  assign OffsetAdjustmentReg_Second_Dat = {((SecondWidth_Con - 1)-(0)+1){1'b0}};
  assign OffsetAdjustmentReg_Nanosecond_Dat = {2'b00,ClockOffsetAdjValue_DatReg[29:0]};
  assign OffsetAdjustmentReg_Sign_Dat = ClockOffsetAdjValue_DatReg[31];
  assign OffsetAdjustmentReg_Interval_Dat = ClockOffsetAdjInterval_DatReg;
  assign OffsetAdjustmentReg_Val = ClockControl_DatReg[ClockControl_OffsetAdjValBit_Con];
  assign DriftAdjustmentReg_Nanosecond_Dat = {2'b00,ClockDriftAdjValue_DatReg[29:0]};
  assign DriftAdjustmentReg_Sign_Dat = ClockDriftAdjValue_DatReg[31];
  assign DriftAdjustmentReg_Interval_Dat = ClockDriftAdjInterval_DatReg;
  assign DriftAdjustmentReg_Val = ClockControl_DatReg[ClockControl_DriftAdjValBit_Con];
  assign AxiWriteAddrReady_RdyOut = AxiWriteAddrReady_RdyReg;
  assign AxiWriteDataReady_RdyOut = AxiWriteDataReady_RdyReg;
  assign AxiWriteRespValid_ValOut = AxiWriteRespValid_ValReg;
  assign AxiWriteRespResponse_DatOut = AxiWriteRespResponse_DatReg;
  assign AxiReadAddrReady_RdyOut = AxiReadAddrReady_RdyReg;
  assign AxiReadDataValid_ValOut = AxiReadDataValid_ValReg;
  assign AxiReadDataResponse_DatOut = AxiReadDataResponse_DatReg;
  assign AxiReadDataData_DatOut = AxiReadDataData_DatReg;
  // The process provides when and how big should be the clock adjustment.
  // A time adjustment indicates a direct time set of the adjustable clock.
  // The offset and drift adjustments indicate smooth corrections of the adjustable clock. The offset and drift adjustments shuold be applied over given intervals.
  // Exceptionally, if the offset adjustment is too large to adjust smoothly, then a direct time set will be applied.
  // The offset and drift adjustments are spread through the corresponding intervals as corrections of 1ns. Each adjustment corrects the period of the the system clock by 1ns.
  // Depending on the sign of the adjustment, the correction is added or subtracted to the period of the system clock.
  // Therefore, the period of the system clock is equal to:
  //      - "the original period", if no adjustment is applied at the current clock cycle
  //      - "the original period - 1ns", if an offset or a drift adjustment is applied at the current clock cycle, with negative sign
  //      - "the original period + 1ns", if an offset or a drift adjustment is applied at the current clock cycle, with positive sign
  //      - "the original period - 2ns", if an offset and a drift adjustment is applied at the current clock cycle, both with negative sign
  //      - "the original period + 2ns", if an offset and a drift adjustment is applied at the current clock cycle, both with positive sign
  //      - "the original period", if an offset and a drift adjustment is applied at the current clock cycle, with different signs
	//reg [AdjustmentIntervalWidth_Con-1:0]OffsetAdjustmentMux_IntervalTicks_DatVar;
	//reg [AdjustmentIntervalWidth_Con-1:0]DriftAdjustmentMux_IntervalTicks_DatVar;
  always @(posedge SysClk_ClkIn, posedge SysRstN_RstIn) begin
    int OffsetAdjustmentMux_IntervalTicks_DatVar;
    int DriftAdjustmentMux_IntervalTicks_DatVar;
    if(SysRstN_RstIn == 1'b0) begin
      DriftAdjustmentMux_ValReg <= 1'b0;
      DriftAdjustmentMux_Nanosecond_DatReg <= {((AdjustmentIntervalWidth_Con - 1)-(0)+1){1'b0}};
      DriftAdjustmentMux_Sign_DatReg <= 1'b0;
      DriftAdjustmentOld_Nanosecond_DatReg <= {((AdjustmentIntervalWidth_Con - 1)-(0)+1){1'b0}};
      DriftAdjustmentOld_Sign_DatReg <= 1'b0;
      DriftAdjustmentMux_Interval_DatReg <= {((AdjustmentIntervalWidth_Con - 1)-(0)+1){1'b0}};
      DriftAdjustmentMux_IntervalExtend_DatReg <= {(((2 * AdjustmentIntervalWidth_Con) - 1)-(0)+1){1'b0}};
      DriftAdjustmentMux_PeriodExtend_DatReg <= {(((2 * AdjustmentIntervalWidth_Con) - 1)-(0)+1){1'b0}};
      DriftAdjustmentMux_IntervalTicks_DatVar = {1{1'b0}};
      StartCalcDriftInterval_EvtReg <= 1'b0;
      CalcDriftInterval_StaReg <= 1'b0;
      CalcDriftIntervalStep_CntReg <= 0;
      DriftCount_CntReg <= {((AdjustmentIntervalWidth_Con - 1)-(0)+1){1'b0}};
      DriftInterval_DatReg <= SecondNanoseconds_Con / ClockPeriod_Gen;
      DriftNanosecond_DatReg <= {((AdjustmentIntervalWidth_Con - 1)-(0)+1){1'b0}};
      DriftSign_DatReg <= 1'b0;
      OffsetAdjustmentMux_ValReg <= 1'b0;
      OffsetAdjustmentMux_Second_DatReg <= {((SecondWidth_Con - 1)-(0)+1){1'b0}};
      OffsetAdjustmentMux_Nanosecond_DatReg <= {((AdjustmentIntervalWidth_Con - 1)-(0)+1){1'b0}};
      OffsetAdjustmentMux_Sign_DatReg <= 1'b0;
      OffsetAdjustmentMux_Interval_DatReg <= {((AdjustmentIntervalWidth_Con - 1)-(0)+1){1'b0}};
      OffsetAdjustmentMux_IntervalExtend_DatReg <= {(((2 * AdjustmentIntervalWidth_Con) - 1)-(0)+1){1'b0}};
      OffsetAdjustmentMux_PeriodExtend_DatReg <= {(((2 * AdjustmentIntervalWidth_Con) - 1)-(0)+1){1'b0}};
      OffsetAdjustmentMux_IntervalTicks_DatVar = {1{1'b0}};
      StartCalcOffsetInterval_EvtReg <= 1'b0;
      CalcOffsetInterval_StaReg <= 1'b0;
      CalcOffsetIntervalStep_CntReg <= 0;
      OffsetCount_CntReg <= {((AdjustmentIntervalWidth_Con - 1)-(0)+1){1'b0}};
      OffsetInterval_DatReg <= SecondNanoseconds_Con / ClockPeriod_Gen;
      OffsetSecond_DatReg <= {((SecondWidth_Con - 1)-(0)+1){1'b0}};
      OffsetNanosecond_DatReg <= {((AdjustmentIntervalWidth_Con - 1)-(0)+1){1'b0}};
      OffsetNanosecondOrigin_DatReg <= {((AdjustmentIntervalWidth_Con - 1)-(0)+1){1'b0}};
      OffsetSign_DatReg <= 1'b0;
      TimeAdjustmentMux_ValReg <= 1'b0;
      TimeAdjust_Second_DatReg <= {((SecondWidth_Con - 1)-(0)+1){1'b0}};
      TimeAdjust_Nanosecond_DatReg <= {((NanosecondWidth_Con - 1)-(0)+1){1'b0}};
      TimeAdjust_ValReg <= 1'b0;
      CountAdjust_Nanosecond_DatReg <= {((CountAdjustmentWidth_Con - 1)-(0)+1){1'b0}};
      CountAdjust_Sign_DatReg <= 1'b0;
      CountAdjust_ValReg <= 1'b0;
    end else begin
      TimeAdjust_ValReg <= 1'b0;
      // offset and drift correction
      CountAdjust_ValReg <= 1'b0;
      CountAdjust_Nanosecond_DatReg <= {((CountAdjustmentWidth_Con - 1)-(0)+1){1'b0}};
      CountAdjust_Sign_DatReg <= 1'b0;
      if(OffsetNanosecond_DatReg > 0 && OffsetSecond_DatReg == 0 && OffsetNanosecondOrigin_DatReg != 0 && OffsetInterval_DatReg != 0 && (OffsetCount_CntReg + OffsetNanosecondOrigin_DatReg >= OffsetInterval_DatReg) && DriftNanosecond_DatReg != 0 && DriftInterval_DatReg != 0 && (DriftCount_CntReg + DriftNanosecond_DatReg >= DriftInterval_DatReg)) begin
        if(OffsetSign_DatReg == 1'b1 && DriftSign_DatReg == 1'b1) begin
          // both negative
          CountAdjust_Nanosecond_DatReg <= 2;
          CountAdjust_Sign_DatReg <= 1'b1;
          CountAdjust_ValReg <= 1'b1;
        end else if(OffsetSign_DatReg != DriftSign_DatReg) begin
          // no correction
          CountAdjust_Nanosecond_DatReg <= 0;
          CountAdjust_Sign_DatReg <= OffsetSign_DatReg;
          CountAdjust_ValReg <= 1'b1;
        end else if(OffsetSign_DatReg == 1'b0 && DriftSign_DatReg == 1'b0) begin
          // both positive
          CountAdjust_Nanosecond_DatReg <= 2;
          CountAdjust_Sign_DatReg <= 1'b0;
          CountAdjust_ValReg <= 1'b1;
        end
      end
      else if(OffsetNanosecond_DatReg > 0 && OffsetSecond_DatReg == 0 && (OffsetNanosecondOrigin_DatReg != 0 && OffsetInterval_DatReg != 0) && (OffsetCount_CntReg + OffsetNanosecondOrigin_DatReg >= OffsetInterval_DatReg)) begin
        CountAdjust_Nanosecond_DatReg <= 1;
        CountAdjust_Sign_DatReg <= OffsetSign_DatReg;
        CountAdjust_ValReg <= 1'b1;
      end
      else if(DriftNanosecond_DatReg != 0 && DriftInterval_DatReg != 0 && (DriftCount_CntReg + DriftNanosecond_DatReg >= DriftInterval_DatReg)) begin
        CountAdjust_Nanosecond_DatReg <= 1;
        CountAdjust_Sign_DatReg <= DriftSign_DatReg;
        CountAdjust_ValReg <= 1'b1;
      end
      //calc offset count
      if(OffsetSecond_DatReg == 0 && OffsetNanosecond_DatReg == 0) begin
        // no adjustment
        OffsetCount_CntReg <= {((AdjustmentIntervalWidth_Con - 1)-(0)+1){1'b0}};
        OffsetInterval_DatReg <= SecondNanoseconds_Con / ClockPeriod_Gen;
        OffsetSecond_DatReg <= {((SecondWidth_Con - 1)-(0)+1){1'b0}};
        OffsetNanosecond_DatReg <= {((AdjustmentIntervalWidth_Con - 1)-(0)+1){1'b0}};
        OffsetNanosecondOrigin_DatReg <= {((AdjustmentIntervalWidth_Con - 1)-(0)+1){1'b0}};
        OffsetSign_DatReg <= 1'b0;
        TimeAdjust_Second_DatReg <= {((SecondWidth_Con - 1)-(0)+1){1'b0}};
        TimeAdjust_Nanosecond_DatReg <= {((NanosecondWidth_Con - 1)-(0)+1){1'b0}};
        TimeAdjust_ValReg <= 1'b0;
      end
      else if(OffsetSecond_DatReg != 0 || OffsetNanosecond_DatReg >= OffsetInterval_DatReg) begin
        // if the adjustment is too large to set smoothly or larger than one second, hard set time by adding the offset to the current time
        OffsetCount_CntReg <= {((AdjustmentIntervalWidth_Con - 1)-(0)+1){1'b0}};
        OffsetInterval_DatReg <= SecondNanoseconds_Con / ClockPeriod_Gen;
        OffsetSecond_DatReg <= {((SecondWidth_Con - 1)-(0)+1){1'b0}};
        OffsetNanosecond_DatReg <= {((AdjustmentIntervalWidth_Con - 1)-(0)+1){1'b0}};
        OffsetNanosecondOrigin_DatReg <= {((AdjustmentIntervalWidth_Con - 1)-(0)+1){1'b0}};
        OffsetSign_DatReg <= 1'b0;
        TimeAdjust_ValReg <= 1'b1;
        if(OffsetSign_DatReg == 1'b1) begin
          // negative offset
          if(ClockTime_Second_DatReg < OffsetSecond_DatReg) begin
            //error case
            TimeAdjust_Second_DatReg <= {((SecondWidth_Con - 1)-(0)+1){1'b0}};
            TimeAdjust_Nanosecond_DatReg <= {((NanosecondWidth_Con - 1)-(0)+1){1'b0}};
          end
          else begin
            if((ClockTime_Nanosecond_DatReg + 2 * ClockPeriod_Gen) < OffsetNanosecond_DatReg) begin
              if(ClockTime_Second_DatReg - OffsetSecond_DatReg >= 1) begin
                TimeAdjust_Second_DatReg <= ClockTime_Second_DatReg - OffsetSecond_DatReg - 1;
                TimeAdjust_Nanosecond_DatReg <= ClockTime_Nanosecond_DatReg + SecondNanoseconds_Con + 2 * ClockPeriod_Gen - OffsetNanosecond_DatReg;
              end
              else begin
                // error case
                TimeAdjust_Second_DatReg <= {((SecondWidth_Con - 1)-(0)+1){1'b0}};
                TimeAdjust_Nanosecond_DatReg <= {((NanosecondWidth_Con - 1)-(0)+1){1'b0}};
              end
            end
            else begin
              TimeAdjust_Second_DatReg <= (ClockTime_Second_DatReg) - (OffsetSecond_DatReg);
              TimeAdjust_Nanosecond_DatReg <= (ClockTime_Nanosecond_DatReg) + (2 * ClockPeriod_Gen) - (OffsetNanosecond_DatReg);
            end
          end
        end
        else begin
          // positive offset
          if((ClockTime_Nanosecond_DatReg + OffsetNanosecond_DatReg + 2 * ClockPeriod_Gen) >= SecondNanoseconds_Con) begin
            TimeAdjust_Second_DatReg <= ClockTime_Second_DatReg + OffsetSecond_DatReg + 1;
            TimeAdjust_Nanosecond_DatReg <= ClockTime_Nanosecond_DatReg + OffsetNanosecond_DatReg + 2 * ClockPeriod_Gen - SecondNanoseconds_Con;
          end
          else begin
            TimeAdjust_Second_DatReg <= ClockTime_Second_DatReg + OffsetSecond_DatReg;
            TimeAdjust_Nanosecond_DatReg <= ClockTime_Nanosecond_DatReg + OffsetNanosecond_DatReg + 2 * ClockPeriod_Gen;
          end
        end
      end
      else begin
        if(OffsetNanosecond_DatReg > 0) begin
          if(OffsetNanosecondOrigin_DatReg != 0 && OffsetInterval_DatReg != 0 && (OffsetCount_CntReg + OffsetNanosecondOrigin_DatReg >= OffsetInterval_DatReg)) begin
            OffsetCount_CntReg <= OffsetCount_CntReg + OffsetNanosecondOrigin_DatReg - OffsetInterval_DatReg;
            OffsetNanosecond_DatReg <= (OffsetNanosecond_DatReg) - 1;
          end
          else begin
            OffsetCount_CntReg <= OffsetCount_CntReg + OffsetNanosecondOrigin_DatReg;
          end
        end
        else begin
          OffsetCount_CntReg <= {((AdjustmentIntervalWidth_Con - 1)-(0)+1){1'b0}};
          OffsetInterval_DatReg <= SecondNanoseconds_Con / ClockPeriod_Gen;
          OffsetSecond_DatReg <= {((SecondWidth_Con - 1)-(0)+1){1'b0}};
          OffsetNanosecond_DatReg <= {((AdjustmentIntervalWidth_Con - 1)-(0)+1){1'b0}};
          OffsetNanosecondOrigin_DatReg <= {((AdjustmentIntervalWidth_Con - 1)-(0)+1){1'b0}};
          OffsetSign_DatReg <= 1'b0;
        end
      end
      //calc drift count
      if(DriftCount_CntReg + DriftNanosecond_DatReg >= DriftInterval_DatReg) begin
        DriftCount_CntReg <= DriftCount_CntReg + DriftNanosecond_DatReg - DriftInterval_DatReg;
      end
      else begin
        DriftCount_CntReg <= (DriftCount_CntReg) + (DriftNanosecond_DatReg);
      end
      // Calc Offset interval
      OffsetAdjustmentMux_ValReg <= OffsetAdjustmentMux_Val;
      StartCalcOffsetInterval_EvtReg <= 1'b0;
      if(OffsetAdjustmentMux_Val == 1'b1 && OffsetAdjustmentMux_ValReg == 1'b0) begin
        // edge triggered adjustment inputs
        OffsetAdjustmentMux_Second_DatReg <= OffsetAdjustmentMux_Second_Dat;
        OffsetAdjustmentMux_Nanosecond_DatReg <= OffsetAdjustmentMux_Nanosecond_Dat;
        OffsetAdjustmentMux_Sign_DatReg <= OffsetAdjustmentMux_Sign_Dat;
        OffsetAdjustmentMux_Interval_DatReg <= OffsetAdjustmentMux_Interval_Dat;
        StartCalcOffsetInterval_EvtReg <= 1'b1;
        CalcOffsetInterval_StaReg <= 1'b0;
      end else if(StartCalcOffsetInterval_EvtReg == 1'b1) begin
        OffsetAdjustmentMux_IntervalExtend_DatReg[(2 * AdjustmentIntervalWidth_Con) - 1:AdjustmentIntervalWidth_Con] <= {(((2 * AdjustmentIntervalWidth_Con) - 1)-(AdjustmentIntervalWidth_Con)+1){1'b0}};
        OffsetAdjustmentMux_IntervalExtend_DatReg[AdjustmentIntervalWidth_Con - 1:0] <= OffsetAdjustmentMux_Interval_DatReg;
        OffsetAdjustmentMux_PeriodExtend_DatReg[(2 * AdjustmentIntervalWidth_Con) - 1:AdjustmentIntervalWidth_Con] <= ClockPeriod_Gen;
        OffsetAdjustmentMux_PeriodExtend_DatReg[AdjustmentIntervalWidth_Con - 1:0] <= {((AdjustmentIntervalWidth_Con - 1)-(0)+1){1'b0}};
        OffsetAdjustmentMux_IntervalTicks_DatVar = {1{1'b0}};
        CalcOffsetIntervalStep_CntReg <= AdjustmentIntervalWidth_Con - 1;
        CalcOffsetInterval_StaReg <= 1'b1;
      end else if(CalcOffsetInterval_StaReg == 1'b1) begin
        if({OffsetAdjustmentMux_IntervalExtend_DatReg[2 * AdjustmentIntervalWidth_Con - 2:0],1'b0} >= OffsetAdjustmentMux_PeriodExtend_DatReg) begin
          OffsetAdjustmentMux_IntervalExtend_DatReg <= ({OffsetAdjustmentMux_IntervalExtend_DatReg[2 * AdjustmentIntervalWidth_Con - 2:0],1'b0}) - OffsetAdjustmentMux_PeriodExtend_DatReg;
          OffsetAdjustmentMux_IntervalTicks_DatVar[CalcOffsetIntervalStep_CntReg] = 1'b1;
        end else begin
          OffsetAdjustmentMux_IntervalExtend_DatReg <= {OffsetAdjustmentMux_IntervalExtend_DatReg[(2 * AdjustmentIntervalWidth_Con) - 2:0],1'b0};
          OffsetAdjustmentMux_IntervalTicks_DatVar[CalcOffsetIntervalStep_CntReg] = 1'b0;
        end
        if(CalcOffsetIntervalStep_CntReg > 0) begin
          CalcOffsetIntervalStep_CntReg <= CalcOffsetIntervalStep_CntReg - 1;
        end else begin
          CalcOffsetInterval_StaReg <= 1'b0;
          // recalculate offset interval only when a new offset is received
          OffsetSecond_DatReg <= OffsetAdjustmentMux_Second_DatReg;
          OffsetNanosecond_DatReg <= OffsetAdjustmentMux_Nanosecond_DatReg;
          OffsetSign_DatReg <= OffsetAdjustmentMux_Sign_DatReg;
          OffsetCount_CntReg <= {((AdjustmentIntervalWidth_Con - 1)-(0)+1){1'b0}};
          if((OffsetAdjustmentMux_Second_DatReg != 0) || (OffsetAdjustmentMux_Nanosecond_DatReg >= OffsetAdjustmentMux_IntervalTicks_DatVar)) begin
            // too big to be corrected smoothly
            OffsetInterval_DatReg <= {((AdjustmentIntervalWidth_Con - 1)-(0)+1){1'b0}};
            // so that we don't fall in the smooth correction
            OffsetNanosecondOrigin_DatReg <= {((AdjustmentIntervalWidth_Con - 1)-(0)+1){1'b0}};
          end else begin
            OffsetInterval_DatReg <= OffsetAdjustmentMux_IntervalTicks_DatVar;
            OffsetNanosecondOrigin_DatReg <= OffsetAdjustmentMux_Nanosecond_DatReg;
          end
        end
      end
      // Time Adjust register
      TimeAdjustmentMux_ValReg <= TimeAdjustmentMux_Val;
      if(TimeAdjustmentMux_Val == 1'b1 && TimeAdjustmentMux_ValReg == 1'b0) begin
        // edge triggered adjustment inputs
        TimeAdjust_Second_DatReg <= TimeAdjustmentMux_Second_Dat;
        TimeAdjust_Nanosecond_DatReg <= TimeAdjustmentMux_Nanosecond_Dat;
        TimeAdjust_ValReg <= 1'b1;
      end
      // Calc Drift interval
      DriftAdjustmentMux_ValReg <= DriftAdjustmentMux_Val;
      StartCalcDriftInterval_EvtReg <= 1'b0;
      if(DriftAdjustmentMux_Val == 1'b1 && DriftAdjustmentMux_ValReg == 1'b0) begin
        // edge triggered adjustment inputs
        if(SelectInput_Dat == 254) begin
          // bypass sum
          DriftAdjustmentMux_Nanosecond_DatReg <= DriftAdjustmentMux_Nanosecond_Dat;
          DriftAdjustmentMux_Sign_DatReg <= DriftAdjustmentMux_Sign_Dat;
        end else begin
          // continuously accumulate the drift
          if(DriftAdjustmentMux_Sign_Dat == DriftAdjustmentOld_Sign_DatReg) begin
            // both negative or both positive
            DriftAdjustmentMux_Sign_DatReg <= DriftAdjustmentMux_Sign_Dat;
            if(DriftAdjustmentMux_Nanosecond_Dat + DriftAdjustmentOld_Nanosecond_DatReg < SecondNanoseconds_Con) begin
              DriftAdjustmentMux_Nanosecond_DatReg <= DriftAdjustmentOld_Nanosecond_DatReg + DriftAdjustmentMux_Nanosecond_Dat;
            end else begin
              DriftAdjustmentMux_Nanosecond_DatReg <= SecondNanoseconds_Con - 1;
              //max value
            end
          end else if(DriftAdjustmentMux_Sign_Dat == 1'b1 && DriftAdjustmentOld_Sign_DatReg == 1'b0) begin
            if(DriftAdjustmentMux_Nanosecond_Dat >= DriftAdjustmentOld_Nanosecond_DatReg) begin
              DriftAdjustmentMux_Nanosecond_DatReg <= DriftAdjustmentMux_Nanosecond_Dat - DriftAdjustmentOld_Nanosecond_DatReg;
              DriftAdjustmentMux_Sign_DatReg <= 1'b1;
            end else begin
              DriftAdjustmentMux_Nanosecond_DatReg <= DriftAdjustmentOld_Nanosecond_DatReg - DriftAdjustmentMux_Nanosecond_Dat;
              DriftAdjustmentMux_Sign_DatReg <= 1'b0;
            end
          end else if(DriftAdjustmentMux_Sign_Dat == 1'b0 && DriftAdjustmentOld_Sign_DatReg == 1'b1) begin
            if(DriftAdjustmentMux_Nanosecond_Dat >= DriftAdjustmentOld_Nanosecond_DatReg) begin
              DriftAdjustmentMux_Nanosecond_DatReg <= DriftAdjustmentMux_Nanosecond_Dat - DriftAdjustmentOld_Nanosecond_DatReg;
              DriftAdjustmentMux_Sign_DatReg <= 1'b0;
            end else begin
              DriftAdjustmentMux_Nanosecond_DatReg <= DriftAdjustmentOld_Nanosecond_DatReg - DriftAdjustmentMux_Nanosecond_Dat;
              DriftAdjustmentMux_Sign_DatReg <= 1'b1;
            end
          end
        end
        DriftAdjustmentMux_Interval_DatReg <= DriftAdjustmentMux_Interval_Dat;
        StartCalcDriftInterval_EvtReg <= 1'b1;
        CalcDriftInterval_StaReg <= 1'b0;
      end else if(StartCalcDriftInterval_EvtReg == 1'b1) begin
        DriftAdjustmentOld_Nanosecond_DatReg <= DriftAdjustmentMux_Nanosecond_DatReg;
        //save the value
        DriftAdjustmentOld_Sign_DatReg <= DriftAdjustmentMux_Sign_DatReg;
        DriftAdjustmentMux_IntervalExtend_DatReg[(2 * AdjustmentIntervalWidth_Con) - 1:AdjustmentIntervalWidth_Con] <= {(((2 * AdjustmentIntervalWidth_Con) - 1)-(AdjustmentIntervalWidth_Con)+1){1'b0}};
        DriftAdjustmentMux_IntervalExtend_DatReg[AdjustmentIntervalWidth_Con - 1:0] <= DriftAdjustmentMux_Interval_DatReg;
        DriftAdjustmentMux_PeriodExtend_DatReg[(2 * AdjustmentIntervalWidth_Con) - 1:AdjustmentIntervalWidth_Con] <= ClockPeriod_Gen;
        DriftAdjustmentMux_PeriodExtend_DatReg[AdjustmentIntervalWidth_Con - 1:0] <= {((AdjustmentIntervalWidth_Con - 1)-(0)+1){1'b0}};
        DriftAdjustmentMux_IntervalTicks_DatVar = {1{1'b0}};
        CalcDriftIntervalStep_CntReg <= AdjustmentIntervalWidth_Con - 1;
        CalcDriftInterval_StaReg <= 1'b1;
      end else if(CalcDriftInterval_StaReg == 1'b1) begin
        if({DriftAdjustmentMux_IntervalExtend_DatReg[2 * AdjustmentIntervalWidth_Con - 2:0],1'b0} >= DriftAdjustmentMux_PeriodExtend_DatReg) begin
          DriftAdjustmentMux_IntervalExtend_DatReg <= ({DriftAdjustmentMux_IntervalExtend_DatReg[2 * AdjustmentIntervalWidth_Con - 2:0],1'b0}) - DriftAdjustmentMux_PeriodExtend_DatReg;
          DriftAdjustmentMux_IntervalTicks_DatVar[CalcDriftIntervalStep_CntReg] = 1'b1;
        end else begin
          DriftAdjustmentMux_IntervalExtend_DatReg <= {DriftAdjustmentMux_IntervalExtend_DatReg[2 * AdjustmentIntervalWidth_Con - 2:0],1'b0};
          DriftAdjustmentMux_IntervalTicks_DatVar[CalcDriftIntervalStep_CntReg] = 1'b0;
        end
        if((CalcDriftIntervalStep_CntReg > 0)) begin
          CalcDriftIntervalStep_CntReg <= CalcDriftIntervalStep_CntReg - 1;
        end else begin
          CalcDriftInterval_StaReg <= 1'b0;
          // recalculate drift interval only when a new drift is received
          DriftCount_CntReg <= {((AdjustmentIntervalWidth_Con - 1)-(0)+1){1'b0}};
          DriftInterval_DatReg <= DriftAdjustmentMux_IntervalTicks_DatVar;
          if(DriftAdjustmentMux_Nanosecond_DatReg > DriftAdjustmentMux_IntervalTicks_DatVar) begin
            // limit the correction to the max value
            DriftNanosecond_DatReg <= DriftAdjustmentMux_IntervalTicks_DatVar;
          end else begin
            DriftNanosecond_DatReg <= DriftAdjustmentMux_Nanosecond_DatReg;
          end
          DriftSign_DatReg <= DriftAdjustmentMux_Sign_DatReg;
        end
      end
      if(Enable_Ena == 1'b0) begin
        //equivalent to reset
        DriftAdjustmentMux_ValReg <= 1'b0;
        DriftAdjustmentMux_Nanosecond_DatReg <= {((AdjustmentIntervalWidth_Con - 1)-(0)+1){1'b0}};
        DriftAdjustmentMux_Sign_DatReg <= 1'b0;
        DriftAdjustmentOld_Nanosecond_DatReg <= {((AdjustmentIntervalWidth_Con - 1)-(0)+1){1'b0}};
        DriftAdjustmentOld_Sign_DatReg <= 1'b0;
        DriftAdjustmentMux_Interval_DatReg <= {((AdjustmentIntervalWidth_Con - 1)-(0)+1){1'b0}};
        DriftAdjustmentMux_IntervalExtend_DatReg <= {(((2 * AdjustmentIntervalWidth_Con) - 1)-(0)+1){1'b0}};
        DriftAdjustmentMux_PeriodExtend_DatReg <= {(((2 * AdjustmentIntervalWidth_Con) - 1)-(0)+1){1'b0}};
        DriftAdjustmentMux_IntervalTicks_DatVar = {1{1'b0}};
        StartCalcDriftInterval_EvtReg <= 1'b0;
        CalcDriftInterval_StaReg <= 1'b0;
        DriftCount_CntReg <= {((AdjustmentIntervalWidth_Con - 1)-(0)+1){1'b0}};
        DriftInterval_DatReg <= SecondNanoseconds_Con / ClockPeriod_Gen;
        DriftNanosecond_DatReg <= {((AdjustmentIntervalWidth_Con - 1)-(0)+1){1'b0}};
        DriftSign_DatReg <= 1'b0;
        TimeAdjustmentMux_ValReg <= 1'b0;
        OffsetAdjustmentMux_ValReg <= 1'b0;
        OffsetAdjustmentMux_Second_DatReg <= {((SecondWidth_Con - 1)-(0)+1){1'b0}};
        OffsetAdjustmentMux_Nanosecond_DatReg <= {((AdjustmentIntervalWidth_Con - 1)-(0)+1){1'b0}};
        OffsetAdjustmentMux_Sign_DatReg <= 1'b0;
        OffsetAdjustmentMux_Interval_DatReg <= {((AdjustmentIntervalWidth_Con - 1)-(0)+1){1'b0}};
        OffsetAdjustmentMux_IntervalExtend_DatReg <= {(((2 * AdjustmentIntervalWidth_Con) - 1)-(0)+1){1'b0}};
        OffsetAdjustmentMux_PeriodExtend_DatReg <= {(((2 * AdjustmentIntervalWidth_Con) - 1)-(0)+1){1'b0}};
        OffsetAdjustmentMux_IntervalTicks_DatVar = {1{1'b0}};
        StartCalcOffsetInterval_EvtReg <= 1'b0;
        CalcOffsetInterval_StaReg <= 1'b0;
        OffsetCount_CntReg <= {((AdjustmentIntervalWidth_Con - 1)-(0)+1){1'b0}};
        OffsetInterval_DatReg <= SecondNanoseconds_Con / ClockPeriod_Gen;
        OffsetSecond_DatReg <= {((SecondWidth_Con - 1)-(0)+1){1'b0}};
        OffsetNanosecond_DatReg <= {((AdjustmentIntervalWidth_Con - 1)-(0)+1){1'b0}};
        OffsetNanosecondOrigin_DatReg <= {((AdjustmentIntervalWidth_Con - 1)-(0)+1){1'b0}};
        OffsetSign_DatReg <= 1'b0;
        TimeAdjust_Second_DatReg <= {((SecondWidth_Con - 1)-(0)+1){1'b0}};
        TimeAdjust_Nanosecond_DatReg <= {((NanosecondWidth_Con - 1)-(0)+1){1'b0}};
        TimeAdjust_ValReg <= 1'b0;
        CountAdjust_Nanosecond_DatReg <= {((CountAdjustmentWidth_Con - 1)-(0)+1){1'b0}};
        CountAdjust_Sign_DatReg <= 1'b0;
        CountAdjust_ValReg <= 1'b0;
      end
    end
  end

  // The process provides the adjustable clock ClockTime. At each system clock cycle the time increases by the period of the system clock,
  // unless an adjustment has to be applied. In this case the time increases by the "adjusted" period of the system clock (max +/- 2ns).
  always @(posedge SysClk_ClkIn, posedge SysRstN_RstIn) begin
    if(SysRstN_RstIn == 1'b0) begin
      ClockTime_Second_DatReg <= {((SecondWidth_Con - 1)-(0)+1){1'b0}};
      ClockTime_Nanosecond_DatReg <= {((NanosecondWidth_Con - 1)-(0)+1){1'b0}};
      ClockTime_TimeJump_DatReg <= 1'b0;
      ClockTime_ValReg <= 1'b0;
      ClockIncrement_DatReg <= {((ClockIncrementWidth_Con - 1)-(0)+1){1'b0}};
    end else begin
      ClockTime_ValReg <= 1'b1;
      if(TimeAdjust_ValReg == 1'b1) begin
        // hard set time
        ClockTime_Second_DatReg <= TimeAdjust_Second_DatReg;
        ClockTime_Nanosecond_DatReg <= TimeAdjust_Nanosecond_DatReg;
        ClockTime_TimeJump_DatReg <= 1'b1;
      end else begin
        if(ClockTime_Nanosecond_DatReg + ClockIncrement_DatReg >= SecondNanoseconds_Con) begin
          ClockTime_Second_DatReg <= ClockTime_Second_DatReg + 1;
          ClockTime_Nanosecond_DatReg <= ClockTime_Nanosecond_DatReg + ClockIncrement_DatReg - SecondNanoseconds_Con;
        end else begin
          ClockTime_Nanosecond_DatReg <= ClockTime_Nanosecond_DatReg + ClockIncrement_DatReg;
        end
        ClockTime_TimeJump_DatReg <= 1'b0;
      end
      if(CountAdjust_ValReg == 1'b1) begin
        if(CountAdjust_Sign_DatReg == 1'b1) begin
          ClockIncrement_DatReg <= ClockPeriod_Gen - CountAdjust_Nanosecond_DatReg;
        end else begin
          ClockIncrement_DatReg <= ClockPeriod_Gen + CountAdjust_Nanosecond_DatReg;
        end
      end else begin
        ClockIncrement_DatReg <= ClockPeriod_Gen;
      end
      if(Enable_Ena == 1'b0) begin
        ClockTime_Second_DatReg <= {((SecondWidth_Con - 1)-(0)+1){1'b0}};
        ClockTime_Nanosecond_DatReg <= {((NanosecondWidth_Con - 1)-(0)+1){1'b0}};
        ClockTime_TimeJump_DatReg <= 1'b0;
        ClockTime_ValReg <= 1'b0;
        ClockIncrement_DatReg <= {((ClockIncrementWidth_Con - 1)-(0)+1){1'b0}};
      end
    end
  end

  // The process provides the status flags of the adjustable clock
  // The InSync flag is activated, if for 4 consecutive offset adjustments the corrections are less than a predefined threshold.
  // The Insync flag is deactivated, if an offset adjustment bigger than the threshold is received or if a time adjustment is applied (e.g. time jump) or if the clock is disabled.
  // The InHoldover flag is activated, if the adjustable clock has been InSync and an offset adjustment has not been received for a predefined threshold time
  // The InHoldover flag is deactivated, if the adjustable clock goes out of sync or if a time or offset adjustment is received or if the clock is disabled
  always @(posedge SysClk_ClkIn, posedge SysRstN_RstIn) begin
    if(SysRstN_RstIn == 1'b0) begin
      InSync_DatReg <= 1'b0;
      InHoldover_DatReg <= 1'b0;
      ClockTimeB0_DatReg <= 1'b0;
      Holdover_CntReg <= 0;
      OffsetArray_DatReg <= {4{1'b0}};
    end else begin
      ClockTimeB0_DatReg <= ClockTime_Second_DatReg[0];
      // count holdover, will be reset on every adjustment
      if(ClockTime_TimeJump_DatReg == 1'b1 || ClockTime_ValReg == 1'b0) begin
        Holdover_CntReg <= 0;
      end else if(ClockTimeB0_DatReg != ClockTime_Second_DatReg[0] && (Holdover_CntReg < ClockInHoldoverTimeoutSecond_Gen)) begin
        // on second overflow
        Holdover_CntReg <= Holdover_CntReg + 1;
      end
      if(((TimeAdjustmentMux_Val == 1'b1) && (TimeAdjustmentMux_ValReg == 1'b0))) begin
        OffsetArray_DatReg <= {OffsetArray_DatReg[2:0],1'b0};
        // this will make sure the in sync flag will go low
        Holdover_CntReg <= 0;
      end else if(OffsetAdjustmentMux_Val == 1'b1 && OffsetAdjustmentMux_ValReg == 1'b0) begin
        if(OffsetAdjustmentMux_Second_Dat == 0 && OffsetAdjustmentMux_Nanosecond_Dat <= ClockInSyncThreshold_DatReg) begin
          OffsetArray_DatReg <= {OffsetArray_DatReg[2:0],1'b1};
        end else begin
          OffsetArray_DatReg <= {OffsetArray_DatReg[2:0],1'b0};
        end
        Holdover_CntReg <= 0;
      end
      // check the last 4 offset calculations
      if(OffsetArray_DatReg == 4'b1111) begin
        InSync_DatReg <= 1'b1;
        if(Holdover_CntReg == ClockInHoldoverTimeoutSecond_Gen) begin
          // only if in sync we go to holdover
          InHoldover_DatReg <= 1'b1;
        end else begin
          InHoldover_DatReg <= 1'b0;
        end
      end else begin
        InSync_DatReg <= 1'b0;
        InHoldover_DatReg <= 1'b0;
      end
      if(Enable_Ena == 1'b0) begin
        InSync_DatReg <= 1'b0;
        InHoldover_DatReg <= 1'b0;
        OffsetArray_DatReg <= {4{1'b0}};
        Holdover_CntReg <= 0;
      end
    end
  end

  // Read and Write AXI access of the registers
  always @(posedge SysClk_ClkIn, posedge SysRstN_RstIn) begin
    if(SysRstN_RstIn == 1'b0) begin
      AxiWriteAddrReady_RdyReg <= 1'b0;
      AxiWriteDataReady_RdyReg <= 1'b0;
      AxiWriteRespValid_ValReg <= 1'b0;
      AxiWriteRespResponse_DatReg <= {2{1'b0}};
      AxiReadAddrReady_RdyReg <= 1'b0;
      AxiReadDataValid_ValReg <= 1'b0;
      AxiReadDataResponse_DatReg <= {2{1'b0}};
      AxiReadDataData_DatReg <= {32{1'b0}};
      Axi_AccessState_StaReg <= Axi_AccessState_Type_Rst_Con;
      `Axi_Init_Proc(ClockControl_Reg_Con, ClockControl_DatReg);
      `Axi_Init_Proc(ClockStatus_Reg_Con, ClockStatus_DatReg);
      ClockSelect_DatReg <= {32{1'b0}};
      `Axi_Init_Proc(ClockSelect_Reg_Con, ClockSelect_DatReg);
      ClockSelect_DatReg[31:0] <= {32{1'b0}};
      `Axi_Init_Proc(ClockVersion_Reg_Con, ClockVersion_DatReg);
      `Axi_Init_Proc(ClockTimeValueL_Reg_Con, ClockTimeValueL_DatReg);
      `Axi_Init_Proc(ClockTimeValueH_Reg_Con, ClockTimeValueH_DatReg);
      `Axi_Init_Proc(ClockTimeAdjValueL_Reg_Con, ClockTimeAdjValueL_DatReg);
      `Axi_Init_Proc(ClockTimeAdjValueH_Reg_Con, ClockTimeAdjValueH_DatReg);
      `Axi_Init_Proc(ClockOffsetAdjValue_Reg_Con, ClockOffsetAdjValue_DatReg);
      `Axi_Init_Proc(ClockOffsetAdjInterval_Reg_Con, ClockOffsetAdjInterval_DatReg);
      `Axi_Init_Proc(ClockDriftAdjValue_Reg_Con, ClockDriftAdjValue_DatReg);
      `Axi_Init_Proc(ClockDriftAdjInterval_Reg_Con, ClockDriftAdjInterval_DatReg);
      `Axi_Init_Proc(ClockInSyncThreshold_Reg_Con, ClockInSyncThreshold_DatReg);
      ClockInSyncThreshold_DatReg <= ClockInSyncThreshold_Gen;
      `Axi_Init_Proc(ClockServoOffsetFactorP_Reg_Con, ClockServoOffsetFactorP_DatReg);
      `Axi_Init_Proc(ClockServoOffsetFactorI_Reg_Con, ClockServoOffsetFactorI_DatReg);
      `Axi_Init_Proc(ClockServoDriftFactorP_Reg_Con, ClockServoDriftFactorP_DatReg);
      `Axi_Init_Proc(ClockServoDriftFactorI_Reg_Con, ClockServoDriftFactorI_DatReg);
      ClockServoOffsetFactorP_DatReg <= OffsetFactorP_Con;
      ClockServoOffsetFactorI_DatReg <= OffsetFactorI_Con;
      ClockServoDriftFactorP_DatReg <= DriftFactorP_Con;
      ClockServoDriftFactorI_DatReg <= DriftFactorI_Con;
      `Axi_Init_Proc(ClockStatusOffset_Reg_Con, ClockStatusOffset_DatReg);
      `Axi_Init_Proc(ClockStatusDrift_Reg_Con, ClockStatusDrift_DatReg);
    end else begin
      ClockSelect_DatReg[15:0] <= ClockSelect_DatReg[15:0] & ClockSelect_Reg_Con.Mask[15:0];
      // make sure it is in a defined range
      if(((AxiWriteAddrValid_ValIn == 1'b1) && (AxiWriteAddrReady_RdyReg == 1'b1))) 
        AxiWriteAddrReady_RdyReg <= 1'b0;
      
      if(((AxiWriteDataValid_ValIn == 1'b1) && (AxiWriteDataReady_RdyReg == 1'b1))) 
        AxiWriteDataReady_RdyReg <= 1'b0;
      
      if(((AxiWriteRespValid_ValReg == 1'b1) && (AxiWriteRespReady_RdyIn == 1'b1))) 
        AxiWriteRespValid_ValReg <= 1'b0;
      
      if(((AxiReadAddrValid_ValIn == 1'b1) && (AxiReadAddrReady_RdyReg == 1'b1))) 
        AxiReadAddrReady_RdyReg <= 1'b0;
      
      if(((AxiReadDataValid_ValReg == 1'b1) && (AxiReadDataReady_RdyIn == 1'b1))) 
        AxiReadDataValid_ValReg <= 1'b0;
      
      case(Axi_AccessState_StaReg)
      Idle_St : begin
        if(AxiWriteAddrValid_ValIn == 1'b1 && AxiWriteDataValid_ValIn == 1'b1) begin
          AxiWriteAddrReady_RdyReg <= 1'b1;
          AxiWriteDataReady_RdyReg <= 1'b1;
          Axi_AccessState_StaReg <= Write_St;
        end else if(AxiReadAddrValid_ValIn == 1'b1) begin
          AxiReadAddrReady_RdyReg <= 1'b1;
          Axi_AccessState_StaReg <= Read_St;
        end
      end
      Read_St : begin
        if(AxiReadAddrValid_ValIn == 1'b1 && AxiReadAddrReady_RdyReg == 1'b1) begin
          AxiReadDataValid_ValReg <= 1'b1;
          AxiReadDataResponse_DatReg <= Axi_RespSlvErr_Con;
        `Axi_Read_Proc(ClockControl_Reg_Con, ClockControl_DatReg, AxiReadAddrAddress_AdrIn, AxiReadDataData_DatReg, AxiReadDataResponse_DatReg);
        `Axi_Read_Proc(ClockStatus_Reg_Con, ClockStatus_DatReg, AxiReadAddrAddress_AdrIn, AxiReadDataData_DatReg, AxiReadDataResponse_DatReg);
        `Axi_Read_Proc(ClockSelect_Reg_Con, ClockSelect_DatReg, AxiReadAddrAddress_AdrIn, AxiReadDataData_DatReg, AxiReadDataResponse_DatReg);
        `Axi_Read_Proc(ClockVersion_Reg_Con, ClockVersion_DatReg, AxiReadAddrAddress_AdrIn, AxiReadDataData_DatReg, AxiReadDataResponse_DatReg);
        `Axi_Read_Proc(ClockTimeValueL_Reg_Con, ClockTimeValueL_DatReg, AxiReadAddrAddress_AdrIn, AxiReadDataData_DatReg, AxiReadDataResponse_DatReg);
        `Axi_Read_Proc(ClockTimeValueH_Reg_Con, ClockTimeValueH_DatReg, AxiReadAddrAddress_AdrIn, AxiReadDataData_DatReg, AxiReadDataResponse_DatReg);
        `Axi_Read_Proc(ClockTimeAdjValueL_Reg_Con, ClockTimeAdjValueL_DatReg, AxiReadAddrAddress_AdrIn, AxiReadDataData_DatReg, AxiReadDataResponse_DatReg);
        `Axi_Read_Proc(ClockTimeAdjValueH_Reg_Con, ClockTimeAdjValueH_DatReg, AxiReadAddrAddress_AdrIn, AxiReadDataData_DatReg, AxiReadDataResponse_DatReg);
        `Axi_Read_Proc(ClockOffsetAdjValue_Reg_Con, ClockOffsetAdjValue_DatReg, AxiReadAddrAddress_AdrIn, AxiReadDataData_DatReg, AxiReadDataResponse_DatReg);
        `Axi_Read_Proc(ClockOffsetAdjInterval_Reg_Con, ClockOffsetAdjInterval_DatReg, AxiReadAddrAddress_AdrIn, AxiReadDataData_DatReg, AxiReadDataResponse_DatReg);
        `Axi_Read_Proc(ClockDriftAdjValue_Reg_Con, ClockDriftAdjValue_DatReg, AxiReadAddrAddress_AdrIn, AxiReadDataData_DatReg, AxiReadDataResponse_DatReg);
        `Axi_Read_Proc(ClockDriftAdjInterval_Reg_Con, ClockDriftAdjInterval_DatReg, AxiReadAddrAddress_AdrIn, AxiReadDataData_DatReg, AxiReadDataResponse_DatReg);
        `Axi_Read_Proc(ClockInSyncThreshold_Reg_Con, ClockInSyncThreshold_DatReg, AxiReadAddrAddress_AdrIn, AxiReadDataData_DatReg, AxiReadDataResponse_DatReg);
        `Axi_Read_Proc(ClockServoOffsetFactorP_Reg_Con, ClockServoOffsetFactorP_DatReg, AxiReadAddrAddress_AdrIn, AxiReadDataData_DatReg, AxiReadDataResponse_DatReg);
        `Axi_Read_Proc(ClockServoOffsetFactorI_Reg_Con, ClockServoOffsetFactorI_DatReg, AxiReadAddrAddress_AdrIn, AxiReadDataData_DatReg, AxiReadDataResponse_DatReg);
        `Axi_Read_Proc(ClockServoDriftFactorP_Reg_Con, ClockServoDriftFactorP_DatReg, AxiReadAddrAddress_AdrIn, AxiReadDataData_DatReg, AxiReadDataResponse_DatReg);
        `Axi_Read_Proc(ClockServoDriftFactorI_Reg_Con, ClockServoDriftFactorI_DatReg, AxiReadAddrAddress_AdrIn, AxiReadDataData_DatReg, AxiReadDataResponse_DatReg);
        `Axi_Read_Proc(ClockStatusOffset_Reg_Con, ClockStatusOffset_DatReg, AxiReadAddrAddress_AdrIn, AxiReadDataData_DatReg, AxiReadDataResponse_DatReg);
        `Axi_Read_Proc(ClockStatusDrift_Reg_Con, ClockStatusDrift_DatReg, AxiReadAddrAddress_AdrIn, AxiReadDataData_DatReg, AxiReadDataResponse_DatReg);
          Axi_AccessState_StaReg <= Resp_St;
        end
      end
      Write_St : begin
        if(AxiWriteAddrValid_ValIn == 1'b1 && AxiWriteAddrReady_RdyReg == 1'b1 && AxiWriteDataValid_ValIn == 1'b1 && AxiWriteDataReady_RdyReg == 1'b1) begin
          AxiWriteRespValid_ValReg <= 1'b1;
          AxiWriteRespResponse_DatReg <= Axi_RespSlvErr_Con;
        `Axi_Write_Proc(ClockControl_Reg_Con, ClockControl_DatReg, AxiWriteAddrAddress_AdrIn, AxiWriteDataData_DatIn, AxiWriteRespResponse_DatReg);
        `Axi_Write_Proc(ClockStatus_Reg_Con, ClockStatus_DatReg, AxiWriteAddrAddress_AdrIn, AxiWriteDataData_DatIn, AxiWriteRespResponse_DatReg);
        `Axi_Write_Proc(ClockSelect_Reg_Con, ClockSelect_DatReg, AxiWriteAddrAddress_AdrIn, AxiWriteDataData_DatIn, AxiWriteRespResponse_DatReg);
        `Axi_Write_Proc(ClockVersion_Reg_Con, ClockVersion_DatReg, AxiWriteAddrAddress_AdrIn, AxiWriteDataData_DatIn, AxiWriteRespResponse_DatReg);
        `Axi_Write_Proc(ClockTimeValueL_Reg_Con, ClockTimeValueL_DatReg, AxiWriteAddrAddress_AdrIn, AxiWriteDataData_DatIn, AxiWriteRespResponse_DatReg);
        `Axi_Write_Proc(ClockTimeValueH_Reg_Con, ClockTimeValueH_DatReg, AxiWriteAddrAddress_AdrIn, AxiWriteDataData_DatIn, AxiWriteRespResponse_DatReg);
        `Axi_Write_Proc(ClockTimeAdjValueL_Reg_Con, ClockTimeAdjValueL_DatReg, AxiWriteAddrAddress_AdrIn, AxiWriteDataData_DatIn, AxiWriteRespResponse_DatReg);
        `Axi_Write_Proc(ClockTimeAdjValueH_Reg_Con, ClockTimeAdjValueH_DatReg, AxiWriteAddrAddress_AdrIn, AxiWriteDataData_DatIn, AxiWriteRespResponse_DatReg);
        `Axi_Write_Proc(ClockOffsetAdjValue_Reg_Con, ClockOffsetAdjValue_DatReg, AxiWriteAddrAddress_AdrIn, AxiWriteDataData_DatIn, AxiWriteRespResponse_DatReg);
        `Axi_Write_Proc(ClockOffsetAdjInterval_Reg_Con, ClockOffsetAdjInterval_DatReg, AxiWriteAddrAddress_AdrIn, AxiWriteDataData_DatIn, AxiWriteRespResponse_DatReg);
        `Axi_Write_Proc(ClockDriftAdjValue_Reg_Con, ClockDriftAdjValue_DatReg, AxiWriteAddrAddress_AdrIn, AxiWriteDataData_DatIn, AxiWriteRespResponse_DatReg);
        `Axi_Write_Proc(ClockDriftAdjInterval_Reg_Con, ClockDriftAdjInterval_DatReg, AxiWriteAddrAddress_AdrIn, AxiWriteDataData_DatIn, AxiWriteRespResponse_DatReg);
        `Axi_Write_Proc(ClockInSyncThreshold_Reg_Con, ClockInSyncThreshold_DatReg, AxiWriteAddrAddress_AdrIn, AxiWriteDataData_DatIn, AxiWriteRespResponse_DatReg);
        `Axi_Write_Proc(ClockServoOffsetFactorP_Reg_Con, ClockServoOffsetFactorP_DatReg, AxiWriteAddrAddress_AdrIn, AxiWriteDataData_DatIn, AxiWriteRespResponse_DatReg);
        `Axi_Write_Proc(ClockServoOffsetFactorI_Reg_Con, ClockServoOffsetFactorI_DatReg, AxiWriteAddrAddress_AdrIn, AxiWriteDataData_DatIn, AxiWriteRespResponse_DatReg);
        `Axi_Write_Proc(ClockServoDriftFactorP_Reg_Con, ClockServoDriftFactorP_DatReg, AxiWriteAddrAddress_AdrIn, AxiWriteDataData_DatIn, AxiWriteRespResponse_DatReg);
        `Axi_Write_Proc(ClockServoDriftFactorI_Reg_Con, ClockServoDriftFactorI_DatReg, AxiWriteAddrAddress_AdrIn, AxiWriteDataData_DatIn, AxiWriteRespResponse_DatReg);
        `Axi_Write_Proc(ClockStatusOffset_Reg_Con, ClockStatusOffset_DatReg, AxiWriteAddrAddress_AdrIn, AxiWriteDataData_DatIn, AxiWriteRespResponse_DatReg);
        `Axi_Write_Proc(ClockStatusDrift_Reg_Con, ClockStatusDrift_DatReg, AxiWriteAddrAddress_AdrIn, AxiWriteDataData_DatIn, AxiWriteRespResponse_DatReg);
          Axi_AccessState_StaReg <= Resp_St;
        end
      end
      Resp_St : begin
        if((AxiWriteRespValid_ValReg == 1'b1 && AxiWriteRespReady_RdyIn == 1'b1) || (AxiReadDataValid_ValReg == 1'b1 && AxiReadDataReady_RdyIn == 1'b1)) begin
          Axi_AccessState_StaReg <= Idle_St;
        end
      end
      endcase
      ClockStatus_DatReg[ClockStatus_InSyncBit_Con] <= InSync_DatReg;
      ClockStatus_DatReg[ClockStatus_InHoldoverBit_Con] <= InHoldover_DatReg;
      ClockSelect_DatReg[31:16] <= ClockSelect_DatReg[15:0] & ClockSelect_Reg_Con.Mask[31:16];
      // Autoclear
      if(ClockControl_DatReg[ClockControl_TimeAdjValBit_Con] == 1'b1) begin
        ClockControl_DatReg[ClockControl_TimeAdjValBit_Con] <= 1'b0;
      end
      if(ClockControl_DatReg[ClockControl_OffsetAdjValBit_Con] == 1'b1) begin
        ClockControl_DatReg[ClockControl_OffsetAdjValBit_Con] <= 1'b0;
      end
      if(ClockControl_DatReg[ClockControl_DriftAdjValBit_Con] == 1'b1) begin
        ClockControl_DatReg[ClockControl_DriftAdjValBit_Con] <= 1'b0;
      end
      if(ClockControl_DatReg[ClockControl_ServoValBit_Con] == 1'b1) begin
        ClockControl_DatReg[ClockControl_ServoValBit_Con] <= 1'b0;
      end
      if(ClockControl_DatReg[ClockControl_TimeReadValBit_Con] == 1'b1) begin
        ClockControl_DatReg[ClockControl_TimeReadValBit_Con] <= 1'b0;
        ClockControl_DatReg[ClockControl_TimeReadDValBit_Con] <= 1'b1;
        ClockTimeValueL_DatReg <= ClockTime_Nanosecond_DatReg;
        ClockTimeValueH_DatReg <= ClockTime_Second_DatReg;
      end
      if(OffsetAdjustmentMux_Val == 1'b1) begin
        ClockStatusOffset_DatReg[31] <= OffsetAdjustmentMux_Sign_Dat;
        ClockStatusOffset_DatReg[30:0] <= OffsetAdjustmentMux_Nanosecond_Dat[30:0];
      end
      if(DriftAdjustmentMux_ValReg == 1'b1) begin
        // provide the accumulated drift
        ClockStatusDrift_DatReg[31] <= DriftAdjustmentMux_Sign_DatReg;
        ClockStatusDrift_DatReg[30:0] <= DriftAdjustmentMux_Nanosecond_DatReg[30:0];
      end
    end
  end
endmodule
