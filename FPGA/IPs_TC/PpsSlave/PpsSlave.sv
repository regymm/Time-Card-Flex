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
//*****************************************************************************************

// Timestamp the incoming event and evaluate its period and pulse width, If it is        --
// accepted as PPS input, calculate its offset and drift, which are sent to the          --
// corresponding PI servos.                                                              --
`include "TimeCard_Package.svh"

module PpsSlave #(
parameter [31:0] ClockPeriod_Gen=20,
parameter CableDelay_Gen="false",
parameter [31:0] InputDelay_Gen=0,
parameter InputPolarity_Gen="true",
parameter [31:0] HighResFreqMultiply_Gen=5,
parameter [31:0] DriftMulP_Gen=3,
parameter [31:0] DriftDivP_Gen=4,
parameter [31:0] DriftMulI_Gen=3,
parameter [31:0] DriftDivI_Gen=16,
parameter [31:0] OffsetMulP_Gen=3,
parameter [31:0] OffsetDivP_Gen=4,
parameter [31:0] OffsetMulI_Gen=3,
parameter [31:0] OffsetDivI_Gen=16,
parameter Sim_Gen="false"
)(
// System
input wire SysClk_ClkIn,
input wire SysClkNx_ClkIn,
input wire SysRstN_RstIn,
// Time Input
input wire [SecondWidth_Con - 1:0] ClockTime_Second_DatIn,
input wire [NanosecondWidth_Con - 1:0] ClockTime_Nanosecond_DatIn,
input wire ClockTime_TimeJump_DatIn,
input wire ClockTime_ValIn,
// Pps Input
input wire Pps_EvtIn,
// Servo Parameters
input wire Servo_ValIn,
input wire [31:0] ServoOffsetFactorP_DatIn,
input wire [31:0] ServoOffsetFactorI_DatIn,
input wire [31:0] ServoDriftFactorP_DatIn,
input wire [31:0] ServoDriftFactorI_DatIn,
// Offset Adjustment Output
output wire [SecondWidth_Con - 1:0] OffsetAdjustment_Second_DatOut,
output wire [NanosecondWidth_Con - 1:0] OffsetAdjustment_Nanosecond_DatOut,
output wire OffsetAdjustment_Sign_DatOut,
output wire [AdjustmentIntervalWidth_Con - 1:0] OffsetAdjustment_Interval_DatOut,
output wire OffsetAdjustment_ValOut,
// Drift Adjustment Output
output wire [NanosecondWidth_Con - 1:0] DriftAdjustment_Nanosecond_DatOut,
output wire DriftAdjustment_Sign_DatOut,
output wire [AdjustmentIntervalWidth_Con - 1:0] DriftAdjustment_Interval_DatOut,
output wire DriftAdjustment_ValOut,
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
integer i;

parameter ClkCyclesInMillisecond_Con = 1000000 / ClockPeriod_Gen;
parameter PeriodWindow_Con = 100;  // in milliseconds
parameter PulseWidthMin_Con = 1;  // in milliseconds
parameter PulseWidthMax_Con = 999;  // in milliseconds
parameter WaitTimer_Con = 16;
parameter ClkCyclesInSecond_Con = SecondNanoseconds_Con / ClockPeriod_Gen; 
// Offset and Drift factors
parameter FactorSize_Con = AdjustmentIntervalWidth_Con + 12;
parameter OffsetFactorP_Con = (OffsetMulP_Gen * (2 ** 16)) / OffsetDivP_Gen;
parameter OffsetFactorI_Con = (OffsetMulI_Gen * (2 ** 16)) / OffsetDivI_Gen;
parameter DriftFactorP_Con = (DriftMulP_Gen * (2 ** 16)) / DriftDivP_Gen;
parameter DriftFactorI_Con = (DriftMulI_Gen * (2 ** 16)) / DriftDivI_Gen;
parameter IntegralMax_Con = 1'b1; 
// PPS Slave version
parameter [7:0]PpsSlaveMajorVersion_Con = 0;
parameter [7:0]PpsSlaveMinorVersion_Con = 1;
parameter [15:0]PpsSlaveBuildVersion_Con = 0;
parameter [31:0]PpsSlaveVersion_Con = { PpsSlaveMajorVersion_Con,PpsSlaveMinorVersion_Con,PpsSlaveBuildVersion_Con }; 
// AXI registers
//constant PpsSlaveControl_Reg_Con                : Axi_Reg_Type:= (x"00000000", x"00000003", Rw_E, x"00000000");
Axi_Reg_Type PpsSlaveControl_Reg_Con                = '{Addr:32'h00000000, Mask:32'h00000003, RegType: Rw_E, Reset:32'h00000000};
//constant PpsSlaveStatus_Reg_Con                 : Axi_Reg_Type:= (x"00000004", x"00000003", Wc_E, x"00000000");
Axi_Reg_Type PpsSlaveStatus_Reg_Con                 = '{Addr:32'h00000004, Mask:32'h00000003, RegType: Wc_E, Reset:32'h00000000};
//constant PpsSlavePolarity_Reg_Con               : Axi_Reg_Type:= (x"00000008", x"00000001", Rw_E, x"00000000");
Axi_Reg_Type PpsSlavePolarity_Reg_Con               = '{Addr:32'h00000008, Mask:32'h00000001, RegType: Rw_E, Reset:32'h00000000};
//constant PpsSlaveVersion_Reg_Con                : Axi_Reg_Type:= (x"0000000C", x"FFFFFFFF", Ro_E, PpsSlaveVersion_Con);
Axi_Reg_Type PpsSlaveVersion_Reg_Con                = '{Addr:32'h0000000C, Mask:32'hFFFFFFFF, RegType: Ro_E, Reset:PpsSlaveVersion_Con};
//constant PpsSlavePulseWidth_Reg_Con             : Axi_Reg_Type:= (x"00000010", x"000003FF", Ro_E, x"00000000");
Axi_Reg_Type PpsSlavePulseWidth_Reg_Con             = '{Addr:32'h00000010, Mask:32'h000003FF, RegType: Ro_E, Reset:32'h00000000};
//constant PpsSlaveCableDelay_Reg_Con             : Axi_Reg_Type:= (x"00000020", x"0000FFFF", Rw_E, x"00000000");
Axi_Reg_Type PpsSlaveCableDelay_Reg_Con             = '{Addr:32'h00000020, Mask:32'h0000FFFF, RegType: Rw_E, Reset:32'h00000000};
parameter PpsSlaveControl_EnableBit_Con = 0;
parameter PpsSlaveStatus_PeriodErrorBit_Con = 0;
parameter PpsSlaveStatus_PulseWidthErrorBit_Con = 1;
parameter PpsSlavePolarity_PolarityBit_Con = 0; 
parameter [0:0]
  WaitTimestamp_St_nul = 0,
  WaitDrift_St = 1;

parameter [2:0]
  WaitTimestamp_St = 0,
  SubOffsetOld_St = 1,
  Diff_St = 2,
  Normalize_Step1_St = 3,
  Normalize_Step2_St = 4,
  Normalize_Step3_St = 5;

parameter [1:0]
  Idle_St = 0,
  P_St = 1,
  I_St = 2,
  Check_St = 3;

// configuration 
wire Enable_Ena;
wire [15:0] CableDelay_Dat;
wire Polarity_Dat; 
// Timestamp
wire Timestamper_Evt;
reg [SecondWidth_Con - 1:0] Timestamp_Second_DatReg;
reg [NanosecondWidth_Con - 1:0] Timestamp_Nanosecond_DatReg;
reg Timestamp_ValReg;
reg [31:0] RegisterDelay_DatReg; 
// Time Input           
reg [SecondWidth_Con - 1:0] ClockTime_Second_DatReg;
reg [NanosecondWidth_Con - 1:0] ClockTime_Nanosecond_DatReg;
reg ClockTime_ValReg; 
// High resolution timestamp
reg TimestampSysClkNx1_EvtReg = 1'b0;
reg TimestampSysClkNx2_EvtReg = 1'b0;
reg [HighResFreqMultiply_Gen * 2 - 1:0] TimestampSysClkNx_EvtShiftReg = 1'b0;
reg TimestampSysClk1_EvtReg = 1'b0;
reg TimestampSysClk2_EvtReg = 1'b0;
reg TimestampSysClk3_EvtReg = 1'b0;
reg TimestampSysClk4_EvtReg = 1'b0;
reg [HighResFreqMultiply_Gen * 2 - 1:0] TimestampSysClk_EvtShiftReg = 1'b0;  // Pulse width and period count in milliseconds
reg [31:0] MillisecondCounter_CntReg = 0;
reg NewMillisecond_DatReg = 1'b0;
reg [31:0] PulseWidthTimer_CntReg = 0;
reg [9:0] PulseWidth_DatReg;
reg [31:0] PeriodTimer_CntReg = 0; 
// Pulse validation flags
reg [1:0] PulseStarted_ValReg = 1'b0;
reg PeriodIsOk_ValReg = 1'b0;
reg PeriodError_DatReg = 1'b0;
reg PulseWidthError_DatReg = 1'b0; 
// Offset calculation
reg OffsetCalcState_StaReg;
reg OffsetCalcActive_ValReg;
reg [SecondWidth_Con - 1:0] OffsetAdjustment_Second_DatReg = 1'b0;
reg [NanosecondWidth_Con - 1:0] OffsetAdjustment_Nanosecond_DatReg = 1'b0;
reg OffsetAdjustment_Sign_DatReg = 1'b0;
reg [AdjustmentIntervalWidth_Con - 1:0] OffsetAdjustment_Interval_DatReg = 1'b0;
reg OffsetAdjustment_ValReg = 1'b0;
reg OffsetAdjustment_ValOldReg = 1'b0;
reg OffsetAdjustmentInvalid_ValReg = 1'b0;
reg [31:0] WaitTimer_CntReg = 0;  // in milliseconds
// Drift calculation                            
reg [2:0] DriftCalcState_StaReg;
reg DriftCalcActive_ValReg;
reg [NanosecondWidth_Con - 1:0] DriftAdjustment_Nanosecond_DatReg = 1'b0;
reg DriftAdjustment_Sign_DatReg = 1'b0;
reg [AdjustmentIntervalWidth_Con - 1:0] DriftAdjustment_Interval_DatReg = 1'b0;
reg DriftAdjustment_ValReg = 1'b0;
reg DriftAdjustment_ValOldReg = 1'b0;
reg DriftAdjustmentInvalid_ValReg = 1'b0;
reg [SecondWidth_Con - 1:0] DriftAdjustmentDelta_Second_DatReg = 1'b0;
reg [NanosecondWidth_Con - 1:0] DriftAdjustmentDelta_Nanosecond_DatReg = 1'b0;
reg DriftAdjustmentDelta_Sign_DatReg = 1'b0;
reg [AdjustmentIntervalWidth_Con - 1:0] DriftAdjustmentDelta_Interval_DatReg = 1'b0;
reg [SecondWidth_Con - 1:0] Timestamp_Second_DatOldReg;
reg [NanosecondWidth_Con - 1:0] Timestamp_Nanosecond_DatOldReg;  // Drift Normalizer 
reg [2 * AdjustmentIntervalWidth_Con - 1:0] Normalizer1_DatReg;
reg [2 * AdjustmentIntervalWidth_Con - 1:0] Normalizer1_Result_DatReg;
reg NormalizeActive1_ValReg;
reg NormalizeActive2_ValReg;
reg [31:0] Step_CntReg;
reg [(2 * 2 * AdjustmentIntervalWidth_Con) - 1:0] NormalizeProduct_DatReg;
reg [2 * 2 * AdjustmentIntervalWidth_Con - 1:0] Normalizer2_DatReg;
reg [2 * AdjustmentIntervalWidth_Con - 1:0] Normalizer2_Result_DatReg;  // PI Servo factors
reg [FactorSize_Con - 1:0] OffsetFactorP_DatReg;
reg [FactorSize_Con - 1:0] OffsetFactorI_DatReg;
reg [FactorSize_Con - 1:0] DriftFactorP_DatReg;
reg [FactorSize_Con - 1:0] DriftFactorI_DatReg;  // PI Offset Adjustment 
reg [SecondWidth_Con - 1:0] PI_OffsetAdjustment_Second_DatReg = 1'b0;
reg [NanosecondWidth_Con - 1:0] PI_OffsetAdjustment_Nanosecond_DatReg = 1'b0;
reg PI_OffsetAdjustment_Sign_DatReg = 1'b0;
reg [AdjustmentIntervalWidth_Con - 1:0] PI_OffsetAdjustment_Interval_DatReg = 1'b0;
reg PI_OffsetAdjustment_ValReg = 1'b0;
reg [SecondWidth_Con - 1:0] PI_OffsetAdjustRetain_Second_DatReg = 1'b0;
reg [NanosecondWidth_Con - 1:0] PI_OffsetAdjustRetain_Nanosecond_DatReg = 1'b0;
reg PI_OffsetAdjustRetain_Sign_DatReg = 1'b0;
reg [AdjustmentIntervalWidth_Con - 1:0] PI_OffsetAdjustRetain_Interval_DatReg = 1'b0;
reg PI_OffsetAdjustRetain_ValReg = 1'b0;  // PI Servo offset calculation 
reg [1:0] PI_OffsetState_StaReg;
reg [FactorSize_Con - 1:0] PI_OffsetIntegral_DatReg;
reg PI_OffsetIntegralSign_DatReg;
reg [(2 * FactorSize_Con) - 1:0] PI_OffsetMul_DatReg;  // PI Drift Adjustment 
reg [NanosecondWidth_Con - 1:0] PI_DriftAdjustment_Nanosecond_DatReg = 1'b0;
reg PI_DriftAdjustment_Sign_DatReg = 1'b0;
reg [AdjustmentIntervalWidth_Con - 1:0] PI_DriftAdjustment_Interval_DatReg = 1'b0;
reg PI_DriftAdjustment_ValReg = 1'b0;  // PI Servo Drift calculation                  
reg [1:0] PI_DriftState_StaReg;
reg [FactorSize_Con - 1:0] PI_DriftIntegral_DatReg;
reg PI_DriftIntegralSign_DatReg;
reg [(2 * FactorSize_Con) - 1:0] PI_DriftMul_DatReg; 
// Axi Regs
reg [1:0] Axi_AccessState_StaReg = Axi_AccessState_Type_Rst_Con;
reg AxiWriteAddrReady_RdyReg;
reg AxiWriteDataReady_RdyReg;
reg AxiWriteRespValid_ValReg;
reg [1:0] AxiWriteRespResponse_DatReg;
reg AxiReadAddrReady_RdyReg;
reg AxiReadDataValid_ValReg;
reg [1:0] AxiReadDataResponse_DatReg;
reg [31:0] AxiReadDataData_DatReg;
reg [31:0] PpsSlaveControl_DatReg;
reg [31:0] PpsSlaveStatus_DatReg;
reg [31:0] PpsSlavePolarity_DatReg;
reg [31:0] PpsSlaveVersion_DatReg;
reg [31:0] PpsSlavePulseWidth_DatReg;
reg [31:0] PpsSlaveCableDelay_DatReg; 
// configuration from AXI
  assign Enable_Ena = PpsSlaveControl_DatReg[PpsSlaveControl_EnableBit_Con];
  assign Polarity_Dat = PpsSlavePolarity_DatReg[PpsSlavePolarity_PolarityBit_Con];
  assign CableDelay_Dat = (CableDelay_Gen == "true") ? PpsSlaveCableDelay_DatReg[15:0] : {16{1'b0}};
  // Fix to active-high polarity 
  assign Timestamper_Evt = (Polarity_Dat == 1'b1) ? Pps_EvtIn :  ~Pps_EvtIn;
  // PI result assignments
  assign OffsetAdjustment_Second_DatOut = PI_OffsetAdjustment_Second_DatReg;
  assign OffsetAdjustment_Nanosecond_DatOut = PI_OffsetAdjustment_Nanosecond_DatReg;
  assign OffsetAdjustment_Sign_DatOut = PI_OffsetAdjustment_Sign_DatReg;
  assign OffsetAdjustment_Interval_DatOut = PI_OffsetAdjustment_Interval_DatReg;
  assign OffsetAdjustment_ValOut = PI_OffsetAdjustment_ValReg;
  assign DriftAdjustment_Nanosecond_DatOut = PI_DriftAdjustment_Nanosecond_DatReg;
  assign DriftAdjustment_Sign_DatOut = PI_DriftAdjustment_Sign_DatReg;
  assign DriftAdjustment_Interval_DatOut = PI_DriftAdjustment_Interval_DatReg;
  assign DriftAdjustment_ValOut = PI_DriftAdjustment_ValReg;
  // AXI assignments
  assign AxiWriteAddrReady_RdyOut = AxiWriteAddrReady_RdyReg;
  assign AxiWriteDataReady_RdyOut = AxiWriteDataReady_RdyReg;
  assign AxiWriteRespValid_ValOut = AxiWriteRespValid_ValReg;
  assign AxiWriteRespResponse_DatOut = AxiWriteRespResponse_DatReg;
  assign AxiReadAddrReady_RdyOut = AxiReadAddrReady_RdyReg;
  assign AxiReadDataValid_ValOut = AxiReadDataValid_ValReg;
  assign AxiReadDataResponse_DatOut = AxiReadDataResponse_DatReg;
  assign AxiReadDataData_DatOut = AxiReadDataData_DatReg;

  // Mark an input event at the shift register of the high resolution clock domain
  always @(posedge SysClkNx_ClkIn) begin
    TimestampSysClkNx1_EvtReg <= Timestamper_Evt;
    TimestampSysClkNx2_EvtReg <= TimestampSysClkNx1_EvtReg;
    TimestampSysClkNx_EvtShiftReg <= {TimestampSysClkNx_EvtShiftReg[HighResFreqMultiply_Gen * 2 - 2:0],TimestampSysClkNx2_EvtReg};
  end

  // Copy the event shift register of the high resolution clock domain to the system clock domain
  always @(posedge SysClk_ClkIn) begin
    TimestampSysClk1_EvtReg <= Timestamper_Evt;
    TimestampSysClk2_EvtReg <= TimestampSysClk1_EvtReg;
    TimestampSysClk3_EvtReg <= TimestampSysClk2_EvtReg;
    TimestampSysClk4_EvtReg <= TimestampSysClk3_EvtReg;
    TimestampSysClk_EvtShiftReg <= TimestampSysClkNx_EvtShiftReg;
  end

  // Calculate the timestamp by compensating for the delays:
  //    - the timestamping at the high resolution clock domain and the corresponding register delays for switching the clock domains
  //    - the input delay, which is provided as generic input
  //    - the cable delay, which is received by the AXI register (and enabled by a generic input)
  // Validate the input pulse's period and width by counting their duration in milliseconds.
  always @(posedge SysClk_ClkIn, negedge SysRstN_RstIn) begin
    if(SysRstN_RstIn == 1'b0) begin
      Timestamp_ValReg <= 1'b0;
      Timestamp_Second_DatReg <= {((SecondWidth_Con - 1)-(0)+1){1'b0}};
      Timestamp_Nanosecond_DatReg <= {((NanosecondWidth_Con - 1)-(0)+1){1'b0}};
      RegisterDelay_DatReg <= 0;
      ClockTime_Second_DatReg <= {((SecondWidth_Con - 1)-(0)+1){1'b0}};
      ClockTime_Nanosecond_DatReg <= {((NanosecondWidth_Con - 1)-(0)+1){1'b0}};
      ClockTime_ValReg <= 1'b0;
      NewMillisecond_DatReg <= 1'b0;
      MillisecondCounter_CntReg <= 0;
      PeriodTimer_CntReg <= 0;
      PulseWidthTimer_CntReg <= 0;
      PulseWidth_DatReg <= {10{1'b1}};
      PulseStarted_ValReg <= {2{1'b0}};
      PeriodIsOk_ValReg <= 1'b0;
    end else begin
      PulseStarted_ValReg[1] <= PulseStarted_ValReg[0];
      // single pulse
      Timestamp_ValReg <= 1'b0;
      NewMillisecond_DatReg <= 1'b0;
      PeriodError_DatReg <= 1'b0;
      PulseWidthError_DatReg <= 1'b0;
      // calculate the delay of the high resolution timestamping which consists of 
      //     - the fixed offset of the clock domain crossing 
      //     - the number of high res. clock periods, from the event until the next rising edge of the system clock
      if(TimestampSysClk2_EvtReg == 1'b1 && TimestampSysClk3_EvtReg == 1'b0) begin
        // store the current time 
        ClockTime_Second_DatReg <= ClockTime_Second_DatIn;
        ClockTime_Nanosecond_DatReg <= ClockTime_Nanosecond_DatIn;
        ClockTime_ValReg <= ClockTime_ValIn;
        for (i=(HighResFreqMultiply_Gen * 2) - 1; i >= 0; i = i - 1) begin: for_loop
          if(i >= (HighResFreqMultiply_Gen * 2 - 3)) begin
            if(TimestampSysClk_EvtShiftReg[i] == 1'b1) begin
              RegisterDelay_DatReg <= 3 * ClockPeriod_Gen;
              disable for_loop;
            end
          end else if(i >= (HighResFreqMultiply_Gen - 3)) begin
            if(TimestampSysClk_EvtShiftReg[i] == 1'b1) begin
              RegisterDelay_DatReg <= 2 * ClockPeriod_Gen + (int'( (ClockPeriod_Gen / (2 * HighResFreqMultiply_Gen)) + (((i - (HighResFreqMultiply_Gen - 3)) * ClockPeriod_Gen) / (HighResFreqMultiply_Gen)) ));
              disable for_loop;
            end
          end else begin
            RegisterDelay_DatReg <= 2 * ClockPeriod_Gen;
          end
        end
      end
      // Compensate the timestamp delays. Ensure that the Nanosecond field does not underflow and the pulse period is in the expected window. 
      if(PeriodIsOk_ValReg == 1'b1 && TimestampSysClk3_EvtReg == 1'b1 && TimestampSysClk4_EvtReg == 1'b0) begin
        Timestamp_ValReg <= 1'b1;
        if(ClockTime_ValReg == 1'b0) begin
          Timestamp_ValReg <= 1'b0;
          Timestamp_Second_DatReg <= {((SecondWidth_Con - 1)-(0)+1){1'b0}};
          Timestamp_Nanosecond_DatReg <= {((NanosecondWidth_Con - 1)-(0)+1){1'b0}};
        end else begin
          if(ClockTime_Nanosecond_DatReg < (InputDelay_Gen + RegisterDelay_DatReg + CableDelay_Dat)) begin
            // smaller than 0
            Timestamp_Nanosecond_DatReg <= SecondNanoseconds_Con + ClockTime_Nanosecond_DatReg - (InputDelay_Gen + RegisterDelay_DatReg + CableDelay_Dat);
            Timestamp_Second_DatReg <= ClockTime_Second_DatReg - 1;
          end else begin
            // larger than/equal to 0
            Timestamp_Nanosecond_DatReg <= ClockTime_Nanosecond_DatReg - (InputDelay_Gen + RegisterDelay_DatReg + CableDelay_Dat);
            Timestamp_Second_DatReg <= ClockTime_Second_DatReg;
          end
        end
      end
      // Millisecond flag
      if(TimestampSysClk2_EvtReg == 1'b1 && TimestampSysClk3_EvtReg == 1'b0) begin
        MillisecondCounter_CntReg <= 0;
      end
      else if((Sim_Gen == "false" && (MillisecondCounter_CntReg < (ClkCyclesInMillisecond_Con - 1))) || (Sim_Gen == "true" && (MillisecondCounter_CntReg < ((ClkCyclesInMillisecond_Con / 1000) - 1)))) begin
        MillisecondCounter_CntReg <= MillisecondCounter_CntReg + 1;
      end else begin
        MillisecondCounter_CntReg <= 0;
        NewMillisecond_DatReg <= 1'b1;
      end
      // Count period
      if(PulseStarted_ValReg[1] == 1'b1 && NewMillisecond_DatReg == 1'b1) begin
        if((Sim_Gen == "false" && ((PeriodTimer_CntReg < (1000 + PeriodWindow_Con)))) || (Sim_Gen == "true" && ((PeriodTimer_CntReg < ((1000 + PeriodWindow_Con) / 10))))) begin
          PeriodTimer_CntReg <= PeriodTimer_CntReg + 1;
          // when the period's upper limit is exceeded, report an error  
        end
        else if((Sim_Gen == "false" && (PeriodTimer_CntReg == (1000 + PeriodWindow_Con))) || (Sim_Gen == "true" && (PeriodTimer_CntReg == ((1000 + PeriodWindow_Con) / 10)))) begin
          PeriodTimer_CntReg <= PeriodTimer_CntReg + 1;
          // set to an invalid value until a next pulse begins
          PeriodError_DatReg <= 1'b1;
        end
      end
      // if the new pulse comes check the min. period limit 
      if(PulseStarted_ValReg[1] == 1'b1 && TimestampSysClk2_EvtReg == 1'b1 && TimestampSysClk3_EvtReg == 1'b0) begin
        if((Sim_Gen == "false" && ((PeriodTimer_CntReg < (1000 - PeriodWindow_Con)))) || (Sim_Gen == "true" && ((PeriodTimer_CntReg < ((1000 - PeriodWindow_Con) / 10))))) begin
          PeriodError_DatReg <= 1'b1;
        end
      end
      // Validate period
      if((Sim_Gen == "false" && ((PeriodTimer_CntReg < (1000 + PeriodWindow_Con)) && (PeriodTimer_CntReg >= (1000 - PeriodWindow_Con)))) || (Sim_Gen == "true" && ((PeriodTimer_CntReg < ((1000 + PeriodWindow_Con) / 10)) && (PeriodTimer_CntReg >= ((1000 - PeriodWindow_Con) / 10))))) begin
        PeriodIsOk_ValReg <= 1'b1;
      end else begin
        PeriodIsOk_ValReg <= 1'b0;
      end
      // Count pulse width
      if(TimestampSysClk2_EvtReg == 1'b1 && NewMillisecond_DatReg == 1'b1) begin
        if((Sim_Gen == "false" && PulseWidthTimer_CntReg < PulseWidthMax_Con) || (Sim_Gen == "true" && PulseWidthTimer_CntReg < PulseWidthMax_Con)) begin
          PulseWidthTimer_CntReg <= PulseWidthTimer_CntReg + 1;
        end
      end else if(TimestampSysClk2_EvtReg == 1'b0) begin
        PulseWidthTimer_CntReg <= 0;
      end
      // At the falling edge check the min. pulse width limit 
      if(PulseStarted_ValReg[1] == 1'b1 && TimestampSysClk2_EvtReg == 1'b0 && TimestampSysClk3_EvtReg == 1'b1) begin
        PulseWidth_DatReg <= PulseWidthTimer_CntReg;
        if((Sim_Gen == "false" && (PulseWidthTimer_CntReg < PulseWidthMin_Con)) || (Sim_Gen == "true" && PulseWidthTimer_CntReg < $ceil( PulseWidthMin_Con / 10 ))) begin
          // this could be 0 if not ceiled
          PulseWidthError_DatReg <= 1'b1;
          PulseWidth_DatReg <= {10{1'b1}};
          // width unknown or out-of-bounds
        end
      end
      // Check the max. pulse width limit 
      if((PulseStarted_ValReg[1] == 1'b1 && TimestampSysClk2_EvtReg == 1'b1 && NewMillisecond_DatReg == 1'b1)) begin
        if((Sim_Gen == "false" && (PulseWidthTimer_CntReg == PulseWidthMax_Con)) || (Sim_Gen == "true" && (PulseWidthTimer_CntReg == (PulseWidthMax_Con / 10)))) begin
          PulseWidthTimer_CntReg <= PulseWidthTimer_CntReg + 1;
          // set to an invalid value until a next pulse begins
          PulseWidthError_DatReg <= 1'b1;
          PulseWidth_DatReg <= {10{1'b1}};
          // width unknown or out-of-bounds
        end
      end
      // At a new event restart the counters
      if(TimestampSysClk2_EvtReg == 1'b1 && TimestampSysClk3_EvtReg == 1'b0) begin
        PeriodTimer_CntReg <= 0;
        PulseWidthTimer_CntReg <= 0;
        PulseStarted_ValReg[0] <= 1'b1;
      end
      if(Enable_Ena == 1'b0) begin
        Timestamp_ValReg <= 1'b0;
        Timestamp_Second_DatReg <= {((SecondWidth_Con - 1)-(0)+1){1'b0}};
        Timestamp_Nanosecond_DatReg <= {((NanosecondWidth_Con - 1)-(0)+1){1'b0}};
        PeriodTimer_CntReg <= 0;
        PulseWidthTimer_CntReg <= 0;
        PulseWidth_DatReg <= {10{1'b1}};
        PulseStarted_ValReg <= {2{1'b0}};
      end
    end
  end

  // Calculate the new offset
  always @(posedge SysClk_ClkIn, negedge SysRstN_RstIn) begin
    if(SysRstN_RstIn == 1'b0) begin
      OffsetCalcState_StaReg <= WaitTimestamp_St;
      OffsetCalcActive_ValReg <= 1'b0;
      OffsetAdjustment_Second_DatReg <= {((SecondWidth_Con - 1)-(0)+1){1'b0}};
      OffsetAdjustment_Nanosecond_DatReg <= {((NanosecondWidth_Con - 1)-(0)+1){1'b0}};
      OffsetAdjustment_Sign_DatReg <= 1'b0;
      OffsetAdjustment_Interval_DatReg <= {((AdjustmentIntervalWidth_Con - 1)-(0)+1){1'b0}};
      OffsetAdjustment_ValReg <= 1'b0;
      OffsetAdjustment_ValOldReg <= 1'b0;
      OffsetAdjustmentInvalid_ValReg <= 1'b0;
      WaitTimer_CntReg <= 0;
    end else begin
      OffsetAdjustment_ValOldReg <= OffsetAdjustment_ValReg;
      OffsetAdjustment_ValReg <= 1'b0;
      OffsetAdjustmentInvalid_ValReg <= 1'b0;
      if(Enable_Ena == 1'b0 || PulseWidthError_DatReg == 1'b1 || PeriodError_DatReg == 1'b1) begin
        OffsetCalcActive_ValReg <= 1'b0;
      end
      case(OffsetCalcState_StaReg)
      WaitTimestamp_St : begin
        WaitTimer_CntReg <= 0;
        if(Timestamp_ValReg == 1'b1) begin
          // single pulse
          if(OffsetCalcActive_ValReg == 1'b0) begin
            // initialize calculation
            OffsetCalcState_StaReg <= WaitTimestamp_St;
            OffsetCalcActive_ValReg <= 1'b1;
            // Error
            OffsetAdjustment_Second_DatReg <= {((SecondWidth_Con - 1)-(0)+1){1'b0}};
            OffsetAdjustment_Nanosecond_DatReg <= {((NanosecondWidth_Con - 1)-(0)+1){1'b0}};
            OffsetAdjustment_Sign_DatReg <= 1'b0;
            OffsetAdjustment_Interval_DatReg <= {((AdjustmentIntervalWidth_Con - 1)-(0)+1){1'b0}};
            OffsetAdjustment_ValReg <= 1'b1;
            // trigger calculation
            OffsetAdjustmentInvalid_ValReg <= 1'b1;
          end
          else begin
            OffsetCalcState_StaReg <= WaitDrift_St;
            if((Sim_Gen == "true")) begin
              if((((Timestamp_Nanosecond_DatReg) % (SecondNanoseconds_Con / 10000)) >= ((SecondNanoseconds_Con / 10000) / 2))) begin
                // correct in negative direction
                OffsetAdjustment_Second_DatReg <= 0;
                // always zero
                OffsetAdjustment_Nanosecond_DatReg <= (SecondNanoseconds_Con / 10000) - ((Timestamp_Nanosecond_DatReg) % (SecondNanoseconds_Con / 10000));
                OffsetAdjustment_Sign_DatReg <= 1'b0;
              end else begin
                // correct in positive direction
                OffsetAdjustment_Second_DatReg <= 0;
                // always zero
                OffsetAdjustment_Nanosecond_DatReg <= (Timestamp_Nanosecond_DatReg) % (SecondNanoseconds_Con / 10000);
                OffsetAdjustment_Sign_DatReg <= 1'b1;
              end
            end else begin
              if(((Timestamp_Nanosecond_DatReg) >= (SecondNanoseconds_Con / 2))) begin
                // correct in negative direction
                OffsetAdjustment_Second_DatReg <= 0;
                // always zero
                OffsetAdjustment_Nanosecond_DatReg <= (SecondNanoseconds_Con) - (Timestamp_Nanosecond_DatReg);
                OffsetAdjustment_Sign_DatReg <= 1'b0;
              end else begin
                // correct in positive direction
                OffsetAdjustment_Second_DatReg <= 0;
                // always zero
                OffsetAdjustment_Nanosecond_DatReg <= Timestamp_Nanosecond_DatReg;
                OffsetAdjustment_Sign_DatReg <= 1'b1;
              end
            end
          end
        end
      end
      WaitDrift_St : begin
        if((PI_DriftAdjustment_ValReg == 1'b1)) begin
          OffsetCalcState_StaReg <= WaitTimestamp_St;
          OffsetAdjustment_ValReg <= 1'b1;
          // trigger calculation
          // subtract drift adjustment from offset adjustment, as it will be corrected in the next interval 
          if((Sim_Gen == "false")) begin
            if((OffsetAdjustment_Sign_DatReg == PI_DriftAdjustment_Sign_DatReg)) begin
              // same signs of adjustments
              OffsetAdjustment_Second_DatReg <= {((SecondWidth_Con - 1)-(0)+1){1'b0}};
              if(((OffsetAdjustment_Nanosecond_DatReg) < (PI_DriftAdjustment_Nanosecond_DatReg))) begin
                OffsetAdjustment_Nanosecond_DatReg <= (PI_DriftAdjustment_Nanosecond_DatReg) - (OffsetAdjustment_Nanosecond_DatReg);
                if((OffsetAdjustment_Sign_DatReg == 1'b1)) begin
                  // offset and drift negative 
                  OffsetAdjustment_Sign_DatReg <= 1'b0;
                end else begin
                  // offset and drift positive 
                  OffsetAdjustment_Sign_DatReg <= 1'b1;
                end
              end else begin
                OffsetAdjustment_Nanosecond_DatReg <= (OffsetAdjustment_Nanosecond_DatReg) - (PI_DriftAdjustment_Nanosecond_DatReg);
                if((OffsetAdjustment_Sign_DatReg == 1'b1)) begin
                  // offset and drift negative 
                  OffsetAdjustment_Sign_DatReg <= 1'b1;
                end else begin
                  // offset and drift positive 
                  OffsetAdjustment_Sign_DatReg <= 1'b0;
                end
              end
            end
            else if((OffsetAdjustment_Sign_DatReg != PI_DriftAdjustment_Sign_DatReg)) begin
              // different signs of adjustments 
              if((((OffsetAdjustment_Nanosecond_DatReg) + (PI_DriftAdjustment_Nanosecond_DatReg)) >= (SecondNanoseconds_Con))) begin
                OffsetAdjustment_Nanosecond_DatReg <= ((OffsetAdjustment_Nanosecond_DatReg) + (PI_DriftAdjustment_Nanosecond_DatReg)) - (SecondNanoseconds_Con);
                OffsetAdjustment_Second_DatReg <= 1;
              end else begin
                OffsetAdjustment_Nanosecond_DatReg <= (OffsetAdjustment_Nanosecond_DatReg) + (PI_DriftAdjustment_Nanosecond_DatReg);
                OffsetAdjustment_Second_DatReg <= {((SecondWidth_Con - 1)-(0)+1){1'b0}};
              end
              if((OffsetAdjustment_Sign_DatReg == 1'b1)) begin
                // offset negative/drift positive 
                OffsetAdjustment_Sign_DatReg <= 1'b1;
              end else begin
                // offset positive/drift negative 
                OffsetAdjustment_Sign_DatReg <= 1'b0;
              end
            end
          end
          else begin
            if((OffsetAdjustment_Sign_DatReg == PI_DriftAdjustment_Sign_DatReg)) begin
              // same signs of adjustments
              OffsetAdjustment_Second_DatReg <= {((SecondWidth_Con - 1)-(0)+1){1'b0}};
              if(((OffsetAdjustment_Nanosecond_DatReg) < ((PI_DriftAdjustment_Nanosecond_DatReg) / 10000))) begin
                OffsetAdjustment_Nanosecond_DatReg <= ((PI_DriftAdjustment_Nanosecond_DatReg) / 10000) - (OffsetAdjustment_Nanosecond_DatReg);
                if((OffsetAdjustment_Sign_DatReg == 1'b1)) begin
                  // offset and drift negative 
                  OffsetAdjustment_Sign_DatReg <= 1'b0;
                end else begin
                  // offset and drift positive 
                  OffsetAdjustment_Sign_DatReg <= 1'b1;
                end
              end else begin
                OffsetAdjustment_Nanosecond_DatReg <= (OffsetAdjustment_Nanosecond_DatReg) - ((PI_DriftAdjustment_Nanosecond_DatReg) / 10000);
                if((OffsetAdjustment_Sign_DatReg == 1'b1)) begin
                  // offset and drift negative 
                  OffsetAdjustment_Sign_DatReg <= 1'b1;
                end else begin
                  // offset and drift positive 
                  OffsetAdjustment_Sign_DatReg <= 1'b0;
                end
              end
            end
            else if((OffsetAdjustment_Sign_DatReg != PI_DriftAdjustment_Sign_DatReg)) begin
              // different signs of adjustments 
              if((((OffsetAdjustment_Nanosecond_DatReg) + ((PI_DriftAdjustment_Nanosecond_DatReg) / 10000)) >= (SecondNanoseconds_Con))) begin
                OffsetAdjustment_Nanosecond_DatReg <= (OffsetAdjustment_Nanosecond_DatReg) + ((PI_DriftAdjustment_Nanosecond_DatReg) / 10000) - (SecondNanoseconds_Con);
                OffsetAdjustment_Second_DatReg <= 1;
              end else begin
                OffsetAdjustment_Nanosecond_DatReg <= (OffsetAdjustment_Nanosecond_DatReg) + ((PI_DriftAdjustment_Nanosecond_DatReg) / 10000);
                OffsetAdjustment_Second_DatReg <= {((SecondWidth_Con - 1)-(0)+1){1'b0}};
              end if((OffsetAdjustment_Sign_DatReg == 1'b1)) begin
                // offset negative/drift positive 
                OffsetAdjustment_Sign_DatReg <= 1'b1;
              end else begin
                // offset positive/drift negative 
                OffsetAdjustment_Sign_DatReg <= 1'b0;
              end
            end
          end
          // assign the pps interval
          if((Sim_Gen == "false")) begin
            OffsetAdjustment_Interval_DatReg <= 6 * (SecondNanoseconds_Con / 10);
            // 60% of a pps interval which means that this is the maximum rate
          end else begin
            OffsetAdjustment_Interval_DatReg <= 6 * (SecondNanoseconds_Con / 100000);
            // correct in 60% pps interval
          end
        end
        else if((NewMillisecond_DatReg == 1'b1)) begin
          if((WaitTimer_CntReg < WaitTimer_Con)) begin
            WaitTimer_CntReg <= WaitTimer_CntReg + 1;
          end else begin
            // wait drift timeout 
            OffsetCalcState_StaReg <= WaitTimestamp_St;
            // Error
            OffsetAdjustment_Second_DatReg <= {((SecondWidth_Con - 1)-(0)+1){1'b0}};
            OffsetAdjustment_Nanosecond_DatReg <= {((NanosecondWidth_Con - 1)-(0)+1){1'b0}};
            OffsetAdjustment_Sign_DatReg <= 1'b0;
            OffsetAdjustment_Interval_DatReg <= {((AdjustmentIntervalWidth_Con - 1)-(0)+1){1'b0}};
            OffsetAdjustment_ValReg <= 1'b1;
            // trigger calculation
            OffsetAdjustmentInvalid_ValReg <= 1'b1;
          end
        end
      end
      default : begin
        OffsetCalcState_StaReg <= WaitTimestamp_St;
      end
      endcase
    end
  end

  // Calculate the new drift
  always @(posedge SysClk_ClkIn, negedge SysRstN_RstIn) begin
    if((SysRstN_RstIn == 1'b0)) begin
      DriftCalcState_StaReg <= WaitTimestamp_St;
      DriftCalcActive_ValReg <= 1'b0;
      DriftAdjustment_Nanosecond_DatReg <= {((NanosecondWidth_Con - 1)-(0)+1){1'b0}};
      DriftAdjustment_Sign_DatReg <= 1'b0;
      DriftAdjustment_Interval_DatReg <= {((AdjustmentIntervalWidth_Con - 1)-(0)+1){1'b0}};
      DriftAdjustment_ValReg <= 1'b0;
      DriftAdjustment_ValOldReg <= 1'b0;
      DriftAdjustmentInvalid_ValReg <= 1'b0;
      DriftAdjustmentDelta_Second_DatReg <= {((SecondWidth_Con - 1)-(0)+1){1'b0}};
      DriftAdjustmentDelta_Nanosecond_DatReg <= {((NanosecondWidth_Con - 1)-(0)+1){1'b0}};
      DriftAdjustmentDelta_Sign_DatReg <= 1'b0;
      DriftAdjustmentDelta_Interval_DatReg <= {((AdjustmentIntervalWidth_Con - 1)-(0)+1){1'b0}};
      PI_OffsetAdjustRetain_Second_DatReg <= {((SecondWidth_Con - 1)-(0)+1){1'b0}};
      PI_OffsetAdjustRetain_Nanosecond_DatReg <= {((NanosecondWidth_Con - 1)-(0)+1){1'b0}};
      PI_OffsetAdjustRetain_Sign_DatReg <= 1'b0;
      PI_OffsetAdjustRetain_Interval_DatReg <= {((AdjustmentIntervalWidth_Con - 1)-(0)+1){1'b0}};
      PI_OffsetAdjustRetain_ValReg <= 1'b0;
      Timestamp_Second_DatOldReg <= {((SecondWidth_Con - 1)-(0)+1){1'b0}};
      Timestamp_Nanosecond_DatOldReg <= {((NanosecondWidth_Con - 1)-(0)+1){1'b0}};
      Normalizer1_DatReg <= {((2 * AdjustmentIntervalWidth_Con - 1)-(0)+1){1'b0}};
      Normalizer1_Result_DatReg <= {((2 * AdjustmentIntervalWidth_Con - 1)-(0)+1){1'b0}};
      NormalizeActive1_ValReg <= 1'b0;
      NormalizeActive2_ValReg <= 1'b0;
      Step_CntReg <= 0;
      NormalizeProduct_DatReg <= {(((2 * 2 * AdjustmentIntervalWidth_Con) - 1)-(0)+1){1'b0}};
      Normalizer2_DatReg <= {((2 * 2 * AdjustmentIntervalWidth_Con - 1)-(0)+1){1'b0}};
      Normalizer2_Result_DatReg <= {((2 * AdjustmentIntervalWidth_Con - 1)-(0)+1){1'b0}};
    end else begin
      DriftAdjustment_ValOldReg <= DriftAdjustment_ValReg;
      DriftAdjustmentInvalid_ValReg <= 1'b0;
      DriftAdjustment_ValReg <= 1'b0;
      // active for 1 clk cycle
      if((Enable_Ena == 1'b0 || PulseWidthError_DatReg == 1'b1 || PeriodError_DatReg == 1'b1)) begin
        DriftCalcActive_ValReg <= 1'b0;
      end
      case(DriftCalcState_StaReg)
      WaitTimestamp_St : begin
        Normalizer1_DatReg <= {((2 * AdjustmentIntervalWidth_Con - 1)-(0)+1){1'b0}};
        Normalizer1_Result_DatReg <= {((2 * AdjustmentIntervalWidth_Con - 1)-(0)+1){1'b0}};
        NormalizeActive1_ValReg <= 1'b0;
        NormalizeActive2_ValReg <= 1'b0;
        Step_CntReg <= 0;
        NormalizeProduct_DatReg <= {(((2 * 2 * AdjustmentIntervalWidth_Con) - 1)-(0)+1){1'b0}};
        Normalizer2_DatReg <= {((2 * 2 * AdjustmentIntervalWidth_Con - 1)-(0)+1){1'b0}};
        Normalizer2_Result_DatReg <= {((2 * AdjustmentIntervalWidth_Con - 1)-(0)+1){1'b0}};
        if((PI_OffsetAdjustment_ValReg == 1'b1)) begin
          PI_OffsetAdjustRetain_Second_DatReg <= PI_OffsetAdjustment_Second_DatReg;
          PI_OffsetAdjustRetain_Nanosecond_DatReg <= PI_OffsetAdjustment_Nanosecond_DatReg;
          PI_OffsetAdjustRetain_Sign_DatReg <= PI_OffsetAdjustment_Sign_DatReg;
          PI_OffsetAdjustRetain_Interval_DatReg <= PI_OffsetAdjustment_Interval_DatReg;
          PI_OffsetAdjustRetain_ValReg <= PI_OffsetAdjustment_ValReg;
          if(((PI_OffsetAdjustRetain_Second_DatReg) != 0)) begin
            DriftCalcActive_ValReg <= 1'b0;
          end
        end
        if(Timestamp_ValReg == 1'b1) begin
          // single pulse
          DriftCalcState_StaReg <= SubOffsetOld_St;
          Timestamp_Second_DatOldReg <= Timestamp_Second_DatReg;
          Timestamp_Nanosecond_DatOldReg <= Timestamp_Nanosecond_DatReg;
          // subtract the old TS from the new TS
          if(Timestamp_Second_DatReg > Timestamp_Second_DatOldReg) begin
            DriftAdjustmentDelta_Sign_DatReg <= 1'b0;
            if(Timestamp_Nanosecond_DatReg >= Timestamp_Nanosecond_DatOldReg) begin
              DriftAdjustmentDelta_Nanosecond_DatReg <= Timestamp_Nanosecond_DatReg - Timestamp_Nanosecond_DatOldReg;
              DriftAdjustmentDelta_Second_DatReg <= Timestamp_Second_DatReg - Timestamp_Second_DatOldReg;
            end
            else begin
              DriftAdjustmentDelta_Nanosecond_DatReg <= SecondNanoseconds_Con + Timestamp_Nanosecond_DatReg - Timestamp_Nanosecond_DatOldReg;
              DriftAdjustmentDelta_Second_DatReg <= Timestamp_Second_DatReg - Timestamp_Second_DatOldReg - 1;
            end
          end
          else if(Timestamp_Second_DatReg == Timestamp_Second_DatOldReg) begin
            if(Timestamp_Nanosecond_DatReg >= Timestamp_Nanosecond_DatOldReg) begin
              DriftAdjustmentDelta_Second_DatReg <= {((SecondWidth_Con - 1)-(0)+1){1'b0}};
              DriftAdjustmentDelta_Sign_DatReg <= 1'b0;
              DriftAdjustmentDelta_Nanosecond_DatReg <= Timestamp_Nanosecond_DatReg - Timestamp_Nanosecond_DatOldReg;
            end else begin
              DriftAdjustmentDelta_Sign_DatReg <= 1'b1;
              DriftAdjustmentDelta_Nanosecond_DatReg <= Timestamp_Nanosecond_DatOldReg - Timestamp_Nanosecond_DatReg;
            end
          end
          else begin
            DriftAdjustmentDelta_Sign_DatReg <= 1'b1;
            if(Timestamp_Nanosecond_DatOldReg >= Timestamp_Nanosecond_DatReg) begin
              DriftAdjustmentDelta_Nanosecond_DatReg <= Timestamp_Nanosecond_DatOldReg - Timestamp_Nanosecond_DatReg;
              DriftAdjustmentDelta_Second_DatReg <= Timestamp_Second_DatOldReg - Timestamp_Second_DatReg;
            end else begin
              DriftAdjustmentDelta_Nanosecond_DatReg <= (SecondNanoseconds_Con + Timestamp_Nanosecond_DatOldReg) - Timestamp_Nanosecond_DatReg;
              DriftAdjustmentDelta_Second_DatReg <= Timestamp_Second_DatOldReg - Timestamp_Second_DatReg - 1;
            end
          end
        end
      end
      SubOffsetOld_St : begin
        if((DriftCalcActive_ValReg == 1'b0)) begin
          DriftCalcState_StaReg <= WaitTimestamp_St;
          DriftCalcActive_ValReg <= 1'b1;
          // Error                                                                              
          DriftAdjustment_Nanosecond_DatReg <= {((NanosecondWidth_Con - 1)-(0)+1){1'b0}}; // no new drift
          DriftAdjustment_Sign_DatReg <= 1'b0;
          DriftAdjustment_Interval_DatReg <= {((AdjustmentIntervalWidth_Con - 1)-(0)+1){1'b0}};
          DriftAdjustment_ValReg <= 1'b1; // trigger calculation
          DriftAdjustmentInvalid_ValReg <= 1'b1;
        end
        else begin
          // substract the offset which was corrected in the last sync interval
          DriftCalcState_StaReg <= Diff_St;
          if(((DriftAdjustmentDelta_Sign_DatReg == 1'b0) && (PI_OffsetAdjustRetain_Sign_DatReg == 1'b0))) begin
            if(((DriftAdjustmentDelta_Second_DatReg) > (PI_OffsetAdjustRetain_Second_DatReg))) begin
              DriftAdjustmentDelta_Sign_DatReg <= 1'b0;
              if(((DriftAdjustmentDelta_Nanosecond_DatReg) >= (PI_OffsetAdjustRetain_Nanosecond_DatReg))) begin
                DriftAdjustmentDelta_Nanosecond_DatReg <= (DriftAdjustmentDelta_Nanosecond_DatReg) - (PI_OffsetAdjustRetain_Nanosecond_DatReg);
                DriftAdjustmentDelta_Second_DatReg <= (DriftAdjustmentDelta_Second_DatReg) - (PI_OffsetAdjustRetain_Second_DatReg);
              end else begin
                DriftAdjustmentDelta_Nanosecond_DatReg <= ((SecondNanoseconds_Con) + (DriftAdjustmentDelta_Nanosecond_DatReg)) - (PI_OffsetAdjustRetain_Nanosecond_DatReg);
                DriftAdjustmentDelta_Second_DatReg <= (DriftAdjustmentDelta_Second_DatReg) - (PI_OffsetAdjustRetain_Second_DatReg) - (1);
              end
            end else if((DriftAdjustmentDelta_Second_DatReg == PI_OffsetAdjustRetain_Second_DatReg)) begin
              if(((DriftAdjustmentDelta_Nanosecond_DatReg) >= (PI_OffsetAdjustRetain_Nanosecond_DatReg))) begin
                DriftAdjustmentDelta_Second_DatReg <= {((SecondWidth_Con - 1)-(0)+1){1'b0}};
                DriftAdjustmentDelta_Sign_DatReg <= 1'b0;
                DriftAdjustmentDelta_Nanosecond_DatReg <= (DriftAdjustmentDelta_Nanosecond_DatReg) - (PI_OffsetAdjustRetain_Nanosecond_DatReg);
              end else begin
                DriftAdjustmentDelta_Sign_DatReg <= 1'b1;
                DriftAdjustmentDelta_Nanosecond_DatReg <= (PI_OffsetAdjustRetain_Nanosecond_DatReg) - (DriftAdjustmentDelta_Nanosecond_DatReg);
              end
            end
            else begin
              DriftAdjustmentDelta_Sign_DatReg <= 1'b1;
              if(((PI_OffsetAdjustRetain_Nanosecond_DatReg) >= (DriftAdjustmentDelta_Nanosecond_DatReg))) begin
                DriftAdjustmentDelta_Nanosecond_DatReg <= (PI_OffsetAdjustRetain_Nanosecond_DatReg) - (DriftAdjustmentDelta_Nanosecond_DatReg);
                DriftAdjustmentDelta_Second_DatReg <= (PI_OffsetAdjustRetain_Second_DatReg) - (DriftAdjustmentDelta_Second_DatReg);
              end else begin
                DriftAdjustmentDelta_Nanosecond_DatReg <= ((SecondNanoseconds_Con) + (PI_OffsetAdjustRetain_Nanosecond_DatReg)) - (DriftAdjustmentDelta_Nanosecond_DatReg);
                DriftAdjustmentDelta_Second_DatReg <= (PI_OffsetAdjustRetain_Second_DatReg) - (DriftAdjustmentDelta_Second_DatReg) - (1);
              end
            end
          end
          else if((DriftAdjustmentDelta_Sign_DatReg != PI_OffsetAdjustRetain_Sign_DatReg)) begin
            if((DriftAdjustmentDelta_Sign_DatReg == 1'b1 && PI_OffsetAdjustRetain_Sign_DatReg == 1'b0)) begin
              DriftAdjustmentDelta_Sign_DatReg <= 1'b1;
            end else begin
              DriftAdjustmentDelta_Sign_DatReg <= 1'b0;
            end
            if((((DriftAdjustmentDelta_Nanosecond_DatReg) + (PI_OffsetAdjustRetain_Nanosecond_DatReg)) >= (SecondNanoseconds_Con))) begin
              DriftAdjustmentDelta_Nanosecond_DatReg <= (DriftAdjustmentDelta_Nanosecond_DatReg) + (PI_OffsetAdjustRetain_Nanosecond_DatReg) - (SecondNanoseconds_Con);
              DriftAdjustmentDelta_Second_DatReg <= (DriftAdjustmentDelta_Second_DatReg) + (PI_OffsetAdjustRetain_Second_DatReg) + (1);
            end else begin
              DriftAdjustmentDelta_Nanosecond_DatReg <= (DriftAdjustmentDelta_Nanosecond_DatReg) + (PI_OffsetAdjustRetain_Nanosecond_DatReg);
              DriftAdjustmentDelta_Second_DatReg <= (DriftAdjustmentDelta_Second_DatReg) + (PI_OffsetAdjustRetain_Second_DatReg);
            end
          end
          else if(((DriftAdjustmentDelta_Sign_DatReg == 1'b1) && (PI_OffsetAdjustRetain_Sign_DatReg == 1'b1))) begin
            if(((DriftAdjustmentDelta_Second_DatReg) > (PI_OffsetAdjustRetain_Second_DatReg))) begin
              DriftAdjustmentDelta_Sign_DatReg <= 1'b1;
              if(((DriftAdjustmentDelta_Nanosecond_DatReg) >= (PI_OffsetAdjustRetain_Nanosecond_DatReg))) begin
                DriftAdjustmentDelta_Nanosecond_DatReg <= (DriftAdjustmentDelta_Nanosecond_DatReg) - (PI_OffsetAdjustRetain_Nanosecond_DatReg);
                DriftAdjustmentDelta_Second_DatReg <= (DriftAdjustmentDelta_Second_DatReg) - (PI_OffsetAdjustRetain_Second_DatReg);
              end else begin
                DriftAdjustmentDelta_Nanosecond_DatReg <= ((SecondNanoseconds_Con) + (DriftAdjustmentDelta_Nanosecond_DatReg)) - (PI_OffsetAdjustRetain_Nanosecond_DatReg);
                DriftAdjustmentDelta_Second_DatReg <= (DriftAdjustmentDelta_Second_DatReg) - (PI_OffsetAdjustRetain_Second_DatReg) - (1);
              end
            end else if((DriftAdjustmentDelta_Second_DatReg == PI_OffsetAdjustRetain_Second_DatReg)) begin
              if(((DriftAdjustmentDelta_Nanosecond_DatReg) >= (PI_OffsetAdjustRetain_Nanosecond_DatReg))) begin
                DriftAdjustmentDelta_Second_DatReg <= {((SecondWidth_Con - 1)-(0)+1){1'b0}};
                DriftAdjustmentDelta_Sign_DatReg <= 1'b1;
                DriftAdjustmentDelta_Nanosecond_DatReg <= (DriftAdjustmentDelta_Nanosecond_DatReg) - (PI_OffsetAdjustRetain_Nanosecond_DatReg);
              end else begin
                DriftAdjustmentDelta_Sign_DatReg <= 1'b0;
                DriftAdjustmentDelta_Nanosecond_DatReg <= (PI_OffsetAdjustRetain_Nanosecond_DatReg) - (DriftAdjustmentDelta_Nanosecond_DatReg);
              end
            end else begin
              DriftAdjustmentDelta_Sign_DatReg <= 1'b0;
              if(((PI_OffsetAdjustRetain_Nanosecond_DatReg) >= (DriftAdjustmentDelta_Nanosecond_DatReg))) begin
                DriftAdjustmentDelta_Nanosecond_DatReg <= (PI_OffsetAdjustRetain_Nanosecond_DatReg) - (DriftAdjustmentDelta_Nanosecond_DatReg);
                DriftAdjustmentDelta_Second_DatReg <= (PI_OffsetAdjustRetain_Second_DatReg) - (DriftAdjustmentDelta_Second_DatReg);
              end else begin
                DriftAdjustmentDelta_Nanosecond_DatReg <= ((SecondNanoseconds_Con) + (PI_OffsetAdjustRetain_Nanosecond_DatReg)) - (DriftAdjustmentDelta_Nanosecond_DatReg);
                DriftAdjustmentDelta_Second_DatReg <= (PI_OffsetAdjustRetain_Second_DatReg) - (DriftAdjustmentDelta_Second_DatReg) - (1);
              end
            end
          end
        end
      end
      Diff_St : begin
        // diff to the norm second
        if((((Sim_Gen == "false") && ((DriftAdjustmentDelta_Second_DatReg) == 1) && (DriftAdjustmentDelta_Sign_DatReg == 1'b0)) || // larger than one second
            ((Sim_Gen == "true") && ((DriftAdjustmentDelta_Second_DatReg) == 0) && (DriftAdjustmentDelta_Sign_DatReg == 1'b0) && ((DriftAdjustmentDelta_Nanosecond_DatReg) >= (SecondNanoseconds_Con / 10000))))) begin
          DriftCalcState_StaReg <= Normalize_Step1_St;
          if((Sim_Gen == "false")) begin
            DriftAdjustment_Interval_DatReg <= (SecondNanoseconds_Con) + (DriftAdjustmentDelta_Nanosecond_DatReg);
            DriftAdjustment_Nanosecond_DatReg <= DriftAdjustmentDelta_Nanosecond_DatReg;
            // the drift "second" should be always '0'
          end else begin
            DriftAdjustment_Interval_DatReg <= DriftAdjustmentDelta_Nanosecond_DatReg;
            DriftAdjustment_Nanosecond_DatReg <= (DriftAdjustmentDelta_Nanosecond_DatReg) - (SecondNanoseconds_Con / 10000);
          end
          DriftAdjustment_Sign_DatReg <= 1'b1;
        end
        else if((Sim_Gen == "false" && DriftAdjustmentDelta_Second_DatReg == 0 && DriftAdjustmentDelta_Sign_DatReg == 1'b0) || // smaller than one second
            (Sim_Gen == "true" && DriftAdjustmentDelta_Second_DatReg == 0 && DriftAdjustmentDelta_Sign_DatReg == 1'b0 && (DriftAdjustmentDelta_Nanosecond_DatReg < (SecondNanoseconds_Con / 10000)))) begin
          DriftCalcState_StaReg <= Normalize_Step1_St;
          if(Sim_Gen == "false") begin
            DriftAdjustment_Nanosecond_DatReg <= SecondNanoseconds_Con - DriftAdjustmentDelta_Nanosecond_DatReg;
          end else begin
            DriftAdjustment_Nanosecond_DatReg <= (SecondNanoseconds_Con / 10000) - DriftAdjustmentDelta_Nanosecond_DatReg;
          end
          DriftAdjustment_Interval_DatReg <= DriftAdjustmentDelta_Nanosecond_DatReg;
          DriftAdjustment_Sign_DatReg <= 1'b0;
        end else begin
          DriftCalcState_StaReg <= WaitTimestamp_St;
          // Error                                                                              
          DriftAdjustment_Nanosecond_DatReg <= {((NanosecondWidth_Con - 1)-(0)+1){1'b0}};
          // no new drift
          DriftAdjustment_Interval_DatReg <= {((AdjustmentIntervalWidth_Con - 1)-(0)+1){1'b0}};
          DriftAdjustment_Sign_DatReg <= 1'b0;
          DriftAdjustment_ValReg <= 1'b1;
          // trigger calculation
          DriftAdjustmentInvalid_ValReg <= 1'b1;
        end
        // Drift Normalization
        Normalizer1_DatReg[2 * AdjustmentIntervalWidth_Con - 1:AdjustmentIntervalWidth_Con] <= {((2 * AdjustmentIntervalWidth_Con - 1)-AdjustmentIntervalWidth_Con+1){1'b0}};
        if(Sim_Gen == "false") begin
          Normalizer1_DatReg[AdjustmentIntervalWidth_Con - 1:0] <= SecondNanoseconds_Con;
        end else begin
          Normalizer1_DatReg[AdjustmentIntervalWidth_Con - 1:0] <= SecondNanoseconds_Con / 10000;
        end
        Step_CntReg <= AdjustmentIntervalWidth_Con - 1;
        Normalizer1_Result_DatReg <= {((2 * AdjustmentIntervalWidth_Con - 1)-(0)+1){1'b0}};
        NormalizeActive1_ValReg <= 1'b1;
      end
      Normalize_Step1_St : begin
        if(NormalizeActive1_ValReg == 1'b1) begin
          if(DriftAdjustment_Nanosecond_DatReg[(AdjustmentIntervalWidth_Con - 1) - Step_CntReg] == 1'b1) begin
            Normalizer1_DatReg <= {Normalizer1_DatReg[(2 * AdjustmentIntervalWidth_Con) - 2:0],1'b0};
            Normalizer1_Result_DatReg <= Normalizer1_Result_DatReg + Normalizer1_DatReg;
          end else begin
            Normalizer1_DatReg <= {Normalizer1_DatReg[(2 * AdjustmentIntervalWidth_Con) - 2:0],1'b0};
          end
        end
        else begin
          DriftCalcState_StaReg <= Normalize_Step2_St;
          NormalizeProduct_DatReg[(2 * 2 * AdjustmentIntervalWidth_Con) - 1:2 * AdjustmentIntervalWidth_Con] <= {(((2 * 2 * AdjustmentIntervalWidth_Con) - 1)-(2 * AdjustmentIntervalWidth_Con)+1){1'b0}};
          NormalizeProduct_DatReg[(2 * AdjustmentIntervalWidth_Con) - 1:0] <= Normalizer1_Result_DatReg;
          Normalizer2_DatReg[(2 * 2 * AdjustmentIntervalWidth_Con) - 1:2 * AdjustmentIntervalWidth_Con] <= DriftAdjustment_Interval_DatReg;
          Normalizer2_DatReg[(2 * AdjustmentIntervalWidth_Con) - 1:0] <= {(((2 * AdjustmentIntervalWidth_Con) - 1)-(0)+1){1'b0}};
          Normalizer2_Result_DatReg <= {((2 * AdjustmentIntervalWidth_Con - 1)-(0)+1){1'b0}};
          Step_CntReg <= (2 * AdjustmentIntervalWidth_Con) - 1;
          NormalizeActive2_ValReg <= 1'b1;
        end
        if(Step_CntReg > 0) begin
          Step_CntReg <= Step_CntReg - 1;
        end else begin
          NormalizeActive1_ValReg <= 1'b0;
        end
      end
      Normalize_Step2_St : begin
        if(NormalizeActive2_ValReg == 1'b1) begin
          if(({NormalizeProduct_DatReg[(2 * 2 * AdjustmentIntervalWidth_Con) - 2:0],1'b0}) >= Normalizer2_DatReg) begin
            NormalizeProduct_DatReg <= ({NormalizeProduct_DatReg[(2 * 2 * AdjustmentIntervalWidth_Con) - 2:0],1'b0}) - Normalizer2_DatReg;
            Normalizer2_Result_DatReg[Step_CntReg] <= 1'b1;
          end else begin
            NormalizeProduct_DatReg <= {NormalizeProduct_DatReg[(2 * 2 * AdjustmentIntervalWidth_Con) - 2:0],1'b0};
            Normalizer2_Result_DatReg[Step_CntReg] <= 1'b0;
          end
        end else begin
          DriftCalcState_StaReg <= Normalize_Step3_St;
        end
        if(Step_CntReg > 0) begin
          Step_CntReg <= Step_CntReg - 1;
        end else begin
          NormalizeActive2_ValReg <= 1'b0;
        end
      end
      Normalize_Step3_St : begin
        if(Sim_Gen == "false") begin
          DriftAdjustment_Interval_DatReg <= SecondNanoseconds_Con;
        end else begin
          DriftAdjustment_Interval_DatReg <= SecondNanoseconds_Con / 10000;
        end
        DriftAdjustment_Nanosecond_DatReg <= Normalizer2_Result_DatReg[NanosecondWidth_Con - 1:0];
        DriftAdjustment_ValReg <= 1'b1;
        // trigger calculation
        DriftCalcState_StaReg <= WaitTimestamp_St;
      end
      default : begin
        DriftCalcState_StaReg <= WaitTimestamp_St;
      end
      endcase
    end
  end

  // Assign the PI factors if they are set dynamically. Otherwise, use the default values.
  always @(posedge SysClk_ClkIn, negedge SysRstN_RstIn) begin
    if(SysRstN_RstIn == 1'b0) begin
      OffsetFactorP_DatReg <= OffsetFactorP_Con;
      OffsetFactorI_DatReg <= OffsetFactorI_Con;
      DriftFactorP_DatReg <= DriftFactorP_Con;
      DriftFactorI_DatReg <= DriftFactorI_Con;
    end else begin if(Servo_ValIn == 1'b1) begin
        OffsetFactorP_DatReg <= ServoOffsetFactorP_DatIn;
        OffsetFactorI_DatReg <= ServoOffsetFactorI_DatIn;
        DriftFactorP_DatReg <= ServoDriftFactorP_DatIn;
        DriftFactorI_DatReg <= ServoDriftFactorI_DatIn;
      end
    end
  end

  // Calculate the PI servo offset correction
  always @(posedge SysClk_ClkIn, negedge SysRstN_RstIn) begin
    if(SysRstN_RstIn == 1'b0) begin
      PI_OffsetState_StaReg <= Idle_St;
      PI_OffsetAdjustment_Second_DatReg <= {((SecondWidth_Con - 1)-(0)+1){1'b0}};
      PI_OffsetAdjustment_Nanosecond_DatReg <= {((NanosecondWidth_Con - 1)-(0)+1){1'b0}};
      PI_OffsetAdjustment_Sign_DatReg <= 1'b0;
      PI_OffsetAdjustment_Interval_DatReg <= {((AdjustmentIntervalWidth_Con - 1)-(0)+1){1'b0}};
      PI_OffsetAdjustment_ValReg <= 1'b0;
      PI_OffsetIntegral_DatReg <= {((FactorSize_Con - 1)-(0)+1){1'b0}};
      PI_OffsetIntegralSign_DatReg <= 1'b0;
      PI_OffsetMul_DatReg <= {(((2 * FactorSize_Con) - 1)-(0)+1){1'b0}};
    end else begin
      PI_OffsetAdjustment_ValReg <= 1'b0;
      // triggered for 1 clock cycle
      if(Enable_Ena == 1'b1) begin
        case(PI_OffsetState_StaReg)
        Idle_St : begin
          if(OffsetAdjustment_ValReg == 1'b1 && OffsetAdjustment_ValOldReg == 1'b0) begin
            if(OffsetAdjustmentInvalid_ValReg == 1'b1) begin
              // error case during offset calculation
              PI_OffsetAdjustment_Second_DatReg <= {((SecondWidth_Con - 1)-(0)+1){1'b0}};
              PI_OffsetAdjustment_Nanosecond_DatReg <= {((NanosecondWidth_Con - 1)-(0)+1){1'b0}};
              PI_OffsetAdjustment_Sign_DatReg <= 1'b0;
              PI_OffsetAdjustment_ValReg <= 1'b1;
              // trigger correction
            end else if(OffsetAdjustment_Second_DatReg != 0) begin
              // too big offset will trigger a jump
              PI_OffsetAdjustment_Second_DatReg <= OffsetAdjustment_Second_DatReg;
              PI_OffsetAdjustment_Nanosecond_DatReg <= OffsetAdjustment_Nanosecond_DatReg;
              PI_OffsetAdjustment_Sign_DatReg <= OffsetAdjustment_Sign_DatReg;
              PI_OffsetAdjustment_Interval_DatReg <= OffsetAdjustment_Interval_DatReg;
              PI_OffsetAdjustment_ValReg <= 1'b1;
              // trigger correction
              PI_OffsetIntegralSign_DatReg <= 1'b0;
              PI_OffsetIntegral_DatReg <= {((FactorSize_Con - 1)-(0)+1){1'b0}};
            end else begin
              PI_OffsetAdjustment_Second_DatReg <= OffsetAdjustment_Second_DatReg;
              PI_OffsetAdjustment_Nanosecond_DatReg <= OffsetAdjustment_Nanosecond_DatReg;
              PI_OffsetAdjustment_Sign_DatReg <= OffsetAdjustment_Sign_DatReg;
              PI_OffsetAdjustment_Interval_DatReg <= OffsetAdjustment_Interval_DatReg;
              PI_OffsetMul_DatReg <= (OffsetAdjustment_Nanosecond_DatReg) * OffsetFactorP_DatReg;
              PI_OffsetState_StaReg <= P_St;
              // Add the calculated new offset to the PI offset integral 
              if(OffsetAdjustment_Sign_DatReg == 1'b1 && PI_OffsetIntegralSign_DatReg == 1'b1) begin
                // both negative
                if(OffsetAdjustment_Nanosecond_DatReg + PI_OffsetIntegral_DatReg >= IntegralMax_Con) begin
                  PI_OffsetIntegral_DatReg <= IntegralMax_Con;
                end else begin
                  PI_OffsetIntegral_DatReg <= OffsetAdjustment_Nanosecond_DatReg + PI_OffsetIntegral_DatReg;
                end
                PI_OffsetIntegralSign_DatReg <= 1'b1;
              end else if(OffsetAdjustment_Sign_DatReg == 1'b1 && PI_OffsetIntegralSign_DatReg == 1'b0) begin
                // inversed
                if(PI_OffsetIntegral_DatReg >= OffsetAdjustment_Nanosecond_DatReg) begin
                  PI_OffsetIntegral_DatReg <= PI_OffsetIntegral_DatReg - OffsetAdjustment_Nanosecond_DatReg;
                  PI_OffsetIntegralSign_DatReg <= 1'b0;
                end else begin
                  PI_OffsetIntegral_DatReg <= OffsetAdjustment_Nanosecond_DatReg - PI_OffsetIntegral_DatReg;
                  PI_OffsetIntegralSign_DatReg <= 1'b1;
                end
              end else if(OffsetAdjustment_Sign_DatReg == 1'b0 && PI_OffsetIntegralSign_DatReg == 1'b1) begin
                // inversed
                if(OffsetAdjustment_Nanosecond_DatReg >= PI_OffsetIntegral_DatReg) begin
                  PI_OffsetIntegral_DatReg <= OffsetAdjustment_Nanosecond_DatReg - PI_OffsetIntegral_DatReg;
                  PI_OffsetIntegralSign_DatReg <= 1'b0;
                end else begin
                  PI_OffsetIntegral_DatReg <= PI_OffsetIntegral_DatReg - OffsetAdjustment_Nanosecond_DatReg;
                  PI_OffsetIntegralSign_DatReg <= 1'b1;
                end
              end else if(OffsetAdjustment_Sign_DatReg == 1'b0 && PI_OffsetIntegralSign_DatReg == 1'b0) begin
                // both positive
                if(PI_OffsetIntegral_DatReg + OffsetAdjustment_Nanosecond_DatReg >= IntegralMax_Con) begin
                  PI_OffsetIntegral_DatReg <= IntegralMax_Con;
                end else begin
                  PI_OffsetIntegral_DatReg <= PI_OffsetIntegral_DatReg + OffsetAdjustment_Nanosecond_DatReg;
                end
                PI_OffsetIntegralSign_DatReg <= 1'b0;
              end
            end
          end
        end
        P_St : begin
          PI_OffsetAdjustment_Nanosecond_DatReg <= PI_OffsetMul_DatReg[(NanosecondWidth_Con + 16) - 1:16];
          PI_OffsetMul_DatReg <= PI_OffsetIntegral_DatReg * OffsetFactorI_DatReg;
          PI_OffsetState_StaReg <= I_St;
        end
        I_St : begin
          if(PI_OffsetIntegralSign_DatReg == 1'b1 && PI_OffsetAdjustment_Sign_DatReg == 1'b1) begin
            // both negative
            PI_OffsetAdjustment_Nanosecond_DatReg <= PI_OffsetAdjustment_Nanosecond_DatReg + PI_OffsetMul_DatReg[(NanosecondWidth_Con + 16) - 1:16];
            PI_OffsetAdjustment_Sign_DatReg <= 1'b1;
          end else if(PI_OffsetIntegralSign_DatReg == 1'b1 && PI_OffsetAdjustment_Sign_DatReg == 1'b0) begin
            // inversed
            if(PI_OffsetAdjustment_Nanosecond_DatReg >= PI_OffsetMul_DatReg[(NanosecondWidth_Con + 16) - 1:16]) begin
              PI_OffsetAdjustment_Nanosecond_DatReg <= PI_OffsetAdjustment_Nanosecond_DatReg - (PI_OffsetMul_DatReg[(NanosecondWidth_Con + 16) - 1:16]);
              PI_OffsetAdjustment_Sign_DatReg <= 1'b0;
            end else begin
              PI_OffsetAdjustment_Nanosecond_DatReg <= PI_OffsetMul_DatReg[(NanosecondWidth_Con + 16) - 1:16] - PI_OffsetAdjustment_Nanosecond_DatReg;
              PI_OffsetAdjustment_Sign_DatReg <= 1'b1;
            end
          end else if(PI_OffsetIntegralSign_DatReg == 1'b0 && PI_OffsetAdjustment_Sign_DatReg == 1'b1) begin
            // inversed
            if(PI_OffsetMul_DatReg[(NanosecondWidth_Con + 16) - 1:16] >= PI_OffsetAdjustment_Nanosecond_DatReg) begin
              PI_OffsetAdjustment_Nanosecond_DatReg <= (PI_OffsetMul_DatReg[(NanosecondWidth_Con + 16) - 1:16]) - PI_OffsetAdjustment_Nanosecond_DatReg;
              PI_OffsetAdjustment_Sign_DatReg <= 1'b0;
            end else begin
              PI_OffsetAdjustment_Nanosecond_DatReg <= PI_OffsetAdjustment_Nanosecond_DatReg - PI_OffsetMul_DatReg[(NanosecondWidth_Con + 16) - 1:16];
              PI_OffsetAdjustment_Sign_DatReg <= 1'b1;
            end
          end else if(PI_OffsetIntegralSign_DatReg == 1'b0 && PI_OffsetAdjustment_Sign_DatReg == 1'b0) begin
            // both positive
            PI_OffsetAdjustment_Nanosecond_DatReg <= PI_OffsetAdjustment_Nanosecond_DatReg + PI_OffsetMul_DatReg[(NanosecondWidth_Con + 16) - 1:16];
            PI_OffsetAdjustment_Sign_DatReg <= 1'b0;
          end
          PI_OffsetAdjustment_ValReg <= 1'b1;
          PI_OffsetState_StaReg <= Idle_St;
        end
        default : begin
          PI_OffsetState_StaReg <= Idle_St;
        end
        endcase
      end
      else begin
        PI_OffsetIntegral_DatReg <= {((FactorSize_Con - 1)-(0)+1){1'b0}};
        PI_OffsetIntegralSign_DatReg <= 1'b0;
        PI_OffsetAdjustment_Nanosecond_DatReg <= {((NanosecondWidth_Con - 1)-(0)+1){1'b0}};
        PI_OffsetAdjustment_Sign_DatReg <= 1'b0;
        PI_OffsetAdjustment_ValReg <= 1'b1;
        PI_OffsetState_StaReg <= Idle_St;
      end
    end
  end

  // Calculate the PI servo drift correction
  always @(posedge SysClk_ClkIn, negedge SysRstN_RstIn) begin
    if(SysRstN_RstIn == 1'b0) begin
      PI_DriftState_StaReg <= Idle_St;
      PI_DriftAdjustment_Nanosecond_DatReg <= {((NanosecondWidth_Con - 1)-(0)+1){1'b0}};
      PI_DriftAdjustment_Sign_DatReg <= 1'b0;
      PI_DriftAdjustment_Interval_DatReg <= {((AdjustmentIntervalWidth_Con - 1)-(0)+1){1'b0}};
      PI_DriftAdjustment_ValReg <= 1'b0;
      PI_DriftIntegral_DatReg <= {((FactorSize_Con - 1)-(0)+1){1'b0}};
      PI_DriftIntegralSign_DatReg <= 1'b0;
      PI_DriftMul_DatReg <= {(((2 * FactorSize_Con) - 1)-(0)+1){1'b0}};
    end else begin
      PI_DriftAdjustment_ValReg <= 1'b0;
      if(Enable_Ena == 1'b1) begin
        case(PI_DriftState_StaReg)
        Idle_St : begin
          if(DriftAdjustment_ValReg == 1'b1 && DriftAdjustment_ValOldReg == 1'b0) begin
            if(DriftAdjustmentInvalid_ValReg == 1'b1) begin
              // error case during drift calculation
              // retain the old adjustments
              PI_DriftState_StaReg <= Check_St;
            end
            else begin
              PI_DriftAdjustment_Nanosecond_DatReg <= DriftAdjustment_Nanosecond_DatReg;
              PI_DriftAdjustment_Sign_DatReg <= DriftAdjustment_Sign_DatReg;
              PI_DriftAdjustment_Interval_DatReg <= DriftAdjustment_Interval_DatReg;
              PI_DriftMul_DatReg <= (DriftAdjustment_Nanosecond_DatReg) * DriftFactorP_DatReg;
              PI_DriftState_StaReg <= P_St;
              // Add the calculated drift to the drift integral 
              if(DriftAdjustment_Sign_DatReg == 1'b1 && PI_DriftIntegralSign_DatReg == 1'b1) begin
                // both negative
                if(PI_DriftIntegral_DatReg + DriftAdjustment_Nanosecond_DatReg >= IntegralMax_Con) begin
                  PI_DriftIntegral_DatReg <= IntegralMax_Con;
                end else begin
                  PI_DriftIntegral_DatReg <= PI_DriftIntegral_DatReg + DriftAdjustment_Nanosecond_DatReg;
                end
                PI_DriftIntegralSign_DatReg <= 1'b1;
              end
              else if(DriftAdjustment_Sign_DatReg == 1'b1 && PI_DriftIntegralSign_DatReg == 1'b0) begin
                // inversed
                if(PI_DriftIntegral_DatReg >= DriftAdjustment_Nanosecond_DatReg) begin
                  PI_DriftIntegral_DatReg <= PI_DriftIntegral_DatReg - DriftAdjustment_Nanosecond_DatReg;
                  PI_DriftIntegralSign_DatReg <= 1'b0;
                end else begin
                  PI_DriftIntegral_DatReg <= DriftAdjustment_Nanosecond_DatReg - PI_DriftIntegral_DatReg;
                  PI_DriftIntegralSign_DatReg <= 1'b1;
                end
              end
              else if(DriftAdjustment_Sign_DatReg == 1'b0 && PI_DriftIntegralSign_DatReg == 1'b1) begin
                // inversed
                if(DriftAdjustment_Nanosecond_DatReg >= PI_DriftIntegral_DatReg) begin
                  PI_DriftIntegral_DatReg <= DriftAdjustment_Nanosecond_DatReg - PI_DriftIntegral_DatReg;
                  PI_DriftIntegralSign_DatReg <= 1'b0;
                end else begin
                  PI_DriftIntegral_DatReg <= PI_DriftIntegral_DatReg - DriftAdjustment_Nanosecond_DatReg;
                  PI_DriftIntegralSign_DatReg <= 1'b1;
                end
              end
              else if(DriftAdjustment_Sign_DatReg == 1'b0 && PI_DriftIntegralSign_DatReg == 1'b0) begin
                // both positive
                if(PI_DriftIntegral_DatReg + DriftAdjustment_Nanosecond_DatReg >= IntegralMax_Con) begin
                  PI_DriftIntegral_DatReg <= IntegralMax_Con;
                end else begin
                  PI_DriftIntegral_DatReg <= PI_DriftIntegral_DatReg + (DriftAdjustment_Nanosecond_DatReg);
                end
                PI_DriftIntegralSign_DatReg <= 1'b0;
              end
            end
          end
        end
        P_St : begin
          PI_DriftAdjustment_Nanosecond_DatReg <= PI_DriftMul_DatReg[(NanosecondWidth_Con + 16) - 1:16];
          PI_DriftMul_DatReg <= PI_DriftIntegral_DatReg * DriftFactorI_DatReg;
          PI_DriftState_StaReg <= I_St;
        end
        I_St : begin
          if(PI_DriftIntegralSign_DatReg == 1'b1 && PI_DriftAdjustment_Sign_DatReg == 1'b1) begin
            // both negative
            PI_DriftAdjustment_Nanosecond_DatReg <= PI_DriftAdjustment_Nanosecond_DatReg + PI_DriftMul_DatReg[(NanosecondWidth_Con + 16) - 1:16];
            PI_DriftAdjustment_Sign_DatReg <= 1'b1;
          end
          else if(PI_DriftIntegralSign_DatReg == 1'b1 && PI_DriftAdjustment_Sign_DatReg == 1'b0) begin
            // inversed
            if(PI_DriftAdjustment_Nanosecond_DatReg >= PI_DriftMul_DatReg[(NanosecondWidth_Con + 16) - 1:16]) begin
              PI_DriftAdjustment_Nanosecond_DatReg <= PI_DriftAdjustment_Nanosecond_DatReg - PI_DriftMul_DatReg[(NanosecondWidth_Con + 16) - 1:16];
              PI_DriftAdjustment_Sign_DatReg <= 1'b0;
            end else begin
              PI_DriftAdjustment_Nanosecond_DatReg <= PI_DriftMul_DatReg[(NanosecondWidth_Con + 16) - 1:16] - PI_DriftAdjustment_Nanosecond_DatReg;
              PI_DriftAdjustment_Sign_DatReg <= 1'b1;
            end
          end
          else if(PI_DriftIntegralSign_DatReg == 1'b0 && PI_DriftAdjustment_Sign_DatReg == 1'b1) begin
            // inversed
            if((PI_DriftMul_DatReg[(NanosecondWidth_Con + 16) - 1:16]) >= PI_DriftAdjustment_Nanosecond_DatReg) begin
              PI_DriftAdjustment_Nanosecond_DatReg <= PI_DriftMul_DatReg[(NanosecondWidth_Con + 16) - 1:16] - PI_DriftAdjustment_Nanosecond_DatReg;
              PI_DriftAdjustment_Sign_DatReg <= 1'b0;
            end else begin
              PI_DriftAdjustment_Nanosecond_DatReg <= PI_DriftAdjustment_Nanosecond_DatReg - PI_DriftMul_DatReg[(NanosecondWidth_Con + 16) - 1:16];
              PI_DriftAdjustment_Sign_DatReg <= 1'b1;
            end
          end
          else if(PI_DriftIntegralSign_DatReg == 1'b0 && PI_DriftAdjustment_Sign_DatReg == 1'b0) begin
            // both positive
            PI_DriftAdjustment_Nanosecond_DatReg <= PI_DriftAdjustment_Nanosecond_DatReg + PI_DriftMul_DatReg[(NanosecondWidth_Con + 16) - 1:16];
            PI_DriftAdjustment_Sign_DatReg <= 1'b0;
          end
          PI_DriftState_StaReg <= Check_St;
        end
        Check_St : begin
          if(Sim_Gen == "false" && PI_DriftAdjustment_Nanosecond_DatReg > ClkCyclesInSecond_Con) begin
            PI_DriftAdjustment_Nanosecond_DatReg <= ClkCyclesInSecond_Con;
            // max possible
            // reset Servo
            PI_DriftIntegral_DatReg <= {((FactorSize_Con - 1)-(0)+1){1'b0}};
            PI_DriftIntegralSign_DatReg <= 1'b0;
          end
          else if(Sim_Gen == "true" && (PI_DriftAdjustment_Nanosecond_DatReg > ((SecondNanoseconds_Con / 10000) / ClockPeriod_Gen))) begin
            PI_DriftAdjustment_Nanosecond_DatReg <= (SecondNanoseconds_Con / 10000) / ClockPeriod_Gen;
            // max possible
            // reset Servo
            PI_DriftIntegral_DatReg <= {((FactorSize_Con - 1)-(0)+1){1'b0}};
            PI_DriftIntegralSign_DatReg <= 1'b0;
          end
          PI_DriftAdjustment_ValReg <= 1'b1;
          PI_DriftState_StaReg <= Idle_St;
        end
        default : begin
          PI_DriftState_StaReg <= Idle_St;
        end
        endcase
      end
      else begin
        // reset Servo
        PI_DriftIntegral_DatReg <= {((FactorSize_Con - 1)-(0)+1){1'b0}};
        PI_DriftIntegralSign_DatReg <= 1'b0;
        PI_DriftAdjustment_Nanosecond_DatReg <= {((NanosecondWidth_Con - 1)-(0)+1){1'b0}};
        PI_DriftAdjustment_Sign_DatReg <= 1'b0;
        PI_DriftAdjustment_ValReg <= 1'b1;
      end
    end
  end

  // Access configuration and monitoring registers via an AXI4L slave
  always @(posedge SysClk_ClkIn, negedge SysRstN_RstIn) begin
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
      `Axi_Init_Proc(PpsSlaveControl_Reg_Con, PpsSlaveControl_DatReg);
      `Axi_Init_Proc(PpsSlaveStatus_Reg_Con, PpsSlaveStatus_DatReg);
      `Axi_Init_Proc(PpsSlavePolarity_Reg_Con, PpsSlavePolarity_DatReg);
      `Axi_Init_Proc(PpsSlaveVersion_Reg_Con, PpsSlaveVersion_DatReg);
      `Axi_Init_Proc(PpsSlavePulseWidth_Reg_Con, PpsSlavePulseWidth_DatReg);
      `Axi_Init_Proc(PpsSlaveCableDelay_Reg_Con, PpsSlaveCableDelay_DatReg);
      if(InputPolarity_Gen == "true") begin
        PpsSlavePolarity_DatReg[PpsSlavePolarity_PolarityBit_Con] <= 1'b1;
      end else begin
        PpsSlavePolarity_DatReg[PpsSlavePolarity_PolarityBit_Con] <= 1'b0;
      end
    end else begin
      if(AxiWriteAddrValid_ValIn == 1'b1 && AxiWriteAddrReady_RdyReg == 1'b1) 
        AxiWriteAddrReady_RdyReg <= 1'b0;
      
      if(AxiWriteDataValid_ValIn == 1'b1 && AxiWriteDataReady_RdyReg == 1'b1) 
        AxiWriteDataReady_RdyReg <= 1'b0;
      
      if(AxiWriteRespValid_ValReg == 1'b1 && AxiWriteRespReady_RdyIn == 1'b1) 
        AxiWriteRespValid_ValReg <= 1'b0;
      
      if(AxiReadAddrValid_ValIn == 1'b1 && AxiReadAddrReady_RdyReg == 1'b1) 
        AxiReadAddrReady_RdyReg <= 1'b0;
      
      if(AxiReadDataValid_ValReg == 1'b1 && AxiReadDataReady_RdyIn == 1'b1) 
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
          `Axi_Read_Proc(PpsSlaveControl_Reg_Con, PpsSlaveControl_DatReg, AxiReadAddrAddress_AdrIn, AxiReadDataData_DatReg, AxiReadDataResponse_DatReg);
          `Axi_Read_Proc(PpsSlaveStatus_Reg_Con, PpsSlaveStatus_DatReg, AxiReadAddrAddress_AdrIn, AxiReadDataData_DatReg, AxiReadDataResponse_DatReg);
          `Axi_Read_Proc(PpsSlavePolarity_Reg_Con, PpsSlavePolarity_DatReg, AxiReadAddrAddress_AdrIn, AxiReadDataData_DatReg, AxiReadDataResponse_DatReg);
          `Axi_Read_Proc(PpsSlaveVersion_Reg_Con, PpsSlaveVersion_DatReg, AxiReadAddrAddress_AdrIn, AxiReadDataData_DatReg, AxiReadDataResponse_DatReg);
          `Axi_Read_Proc(PpsSlavePulseWidth_Reg_Con, PpsSlavePulseWidth_DatReg, AxiReadAddrAddress_AdrIn, AxiReadDataData_DatReg, AxiReadDataResponse_DatReg);
          `Axi_Read_Proc(PpsSlaveCableDelay_Reg_Con, PpsSlaveCableDelay_DatReg, AxiReadAddrAddress_AdrIn, AxiReadDataData_DatReg, AxiReadDataResponse_DatReg);
          Axi_AccessState_StaReg <= Resp_St;
        end
      end
      Write_St : begin
        if(AxiWriteAddrValid_ValIn == 1'b1 && AxiWriteAddrReady_RdyReg == 1'b1 && AxiWriteDataValid_ValIn == 1'b1 && AxiWriteDataReady_RdyReg == 1'b1) begin
          AxiWriteRespValid_ValReg <= 1'b1;
          AxiWriteRespResponse_DatReg <= Axi_RespSlvErr_Con;
          `Axi_Write_Proc(PpsSlaveControl_Reg_Con, PpsSlaveControl_DatReg, AxiWriteAddrAddress_AdrIn, AxiWriteDataData_DatIn, AxiWriteRespResponse_DatReg);
          `Axi_Write_Proc(PpsSlaveStatus_Reg_Con, PpsSlaveStatus_DatReg, AxiWriteAddrAddress_AdrIn, AxiWriteDataData_DatIn, AxiWriteRespResponse_DatReg);
          `Axi_Write_Proc(PpsSlavePolarity_Reg_Con, PpsSlavePolarity_DatReg, AxiWriteAddrAddress_AdrIn, AxiWriteDataData_DatIn, AxiWriteRespResponse_DatReg);
          `Axi_Write_Proc(PpsSlaveVersion_Reg_Con, PpsSlaveVersion_DatReg, AxiWriteAddrAddress_AdrIn, AxiWriteDataData_DatIn, AxiWriteRespResponse_DatReg);
          `Axi_Write_Proc(PpsSlavePulseWidth_Reg_Con, PpsSlavePulseWidth_DatReg, AxiWriteAddrAddress_AdrIn, AxiWriteDataData_DatIn, AxiWriteRespResponse_DatReg);
          `Axi_Write_Proc(PpsSlaveCableDelay_Reg_Con, PpsSlaveCableDelay_DatReg, AxiWriteAddrAddress_AdrIn, AxiWriteDataData_DatIn, AxiWriteRespResponse_DatReg);
          Axi_AccessState_StaReg <= Resp_St;
        end
      end
      Resp_St : begin
        if((AxiWriteRespValid_ValReg == 1'b1 && AxiWriteRespReady_RdyIn == 1'b1) || (AxiReadDataValid_ValReg == 1'b1 && AxiReadDataReady_RdyIn == 1'b1)) begin
          Axi_AccessState_StaReg <= Idle_St;
        end
      end
      endcase
      if(PpsSlaveControl_DatReg[PpsSlaveControl_EnableBit_Con] == 1'b1) begin
        if(PeriodError_DatReg == 1'b1) begin
          // make it sticky
          PpsSlaveStatus_DatReg[PpsSlaveStatus_PeriodErrorBit_Con] <= 1'b1;
        end if(PulseWidthError_DatReg == 1'b1) begin
          // make it sticky
          PpsSlaveStatus_DatReg[PpsSlaveStatus_PulseWidthErrorBit_Con] <= 1'b1;
        end
      end else begin
        PpsSlaveStatus_DatReg[PpsSlaveStatus_PeriodErrorBit_Con] <= 1'b0;
        PpsSlaveStatus_DatReg[PpsSlaveStatus_PulseWidthErrorBit_Con] <= 1'b0;
      end
      PpsSlavePulseWidth_DatReg[9:0] <= PulseWidth_DatReg;
    end
  end
endmodule
