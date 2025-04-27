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

// The Signal Generator is a full hardware (FPGA) only implementation that allows to     --
// generate pulse width modulated (PWM) signals of configurable polarity aligned with    --
// the local clock. The Signal Generator takes a start time, a pulse width and period as --
// well as a repeat count as input and generates the signal accordingly. The settings    --
// are configurable by an AXI4Light-Slave Register interface.                            --
`include "TimeCard_Package.svh"

module SignalGenerator #(
parameter [31:0] ClockPeriod_Gen=20,
parameter CableDelay_Gen="false",
parameter [31:0] OutputDelay_Gen=100,
parameter OutputPolarity_Gen="true",
parameter [31:0] HighResFreqMultiply_Gen=5
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
// Signal Output            
output reg SignalGenerator_EvtOut,
// Interrupt Output         
output wire Irq_EvtOut,
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
int i;

// High resolution constants
parameter HighResClockPeriod_Con = ClockPeriod_Gen / HighResFreqMultiply_Gen;
parameter RegOutputDelay_Con = (3 * ClockPeriod_Gen) + HighResClockPeriod_Con;  // The total output delay consists of 
//     - the configurable output delay compensation(generic input), due to output registers
//     - the cable delay compensation, provided by AXI reg, if enabled by the generic input
//     - the internal register delay compensation for the clock domain crossing
parameter OutputDelaySum_Con = OutputDelay_Gen + (ClockPeriod_Gen / 2) + RegOutputDelay_Con;  // Signal Generator version
parameter [7:0]SigGenMajorVersion_Con = 0;
parameter [7:0]SigGenMinorVersion_Con = 1;
parameter [15:0]SigGenBuildVersion_Con = 0;
parameter [31:0]SigGenVersion_Con = { SigGenMajorVersion_Con,SigGenMinorVersion_Con,SigGenBuildVersion_Con };  // AXI registers    
//constant SigGenControl_Reg_Con                  : Axi_Reg_Type:= (x"00000000", x"00000003", Rw_E, x"00000000");
Axi_Reg_Type SigGenControl_Reg_Con = '{Addr:32'h00000000, Mask:32'h00000003, RegType:Rw_E, Reset:32'h00000000};
//constant SigGenStatus_Reg_Con                   : Axi_Reg_Type:= (x"00000004", x"00000003", Wc_E, 32'h00000000");
Axi_Reg_Type SigGenStatus_Reg_Con = '{Addr:32'h00000004, Mask:32'h00000003, RegType:Wc_E, Reset:32'h00000000};
//constant SigGenPolarity_Reg_Con                 : Axi_Reg_Type:= (x"00000008", x"00000001", Rw_E, 32'h00000000");
Axi_Reg_Type SigGenPolarity_Reg_Con = '{Addr:32'h00000008, Mask:32'h00000001, RegType:Rw_E, Reset:32'h00000000};
//constant SigGenVersion_Reg_Con                  : Axi_Reg_Type:= (x"0000000C", x"FFFFFFFF", Ro_E, SigGenVersion_Con);
Axi_Reg_Type SigGenVersion_Reg_Con = '{Addr:32'h0000000C, Mask:32'hFFFFFFFF, RegType:Ro_E, Reset:SigGenVersion_Con};
//constant SigGenCableDelay_Reg_Con               : Axi_Reg_Type:= (x"00000020", x"0000FFFF", Rw_E, 32'h00000000");
Axi_Reg_Type SigGenCableDelay_Reg_Con = '{Addr:32'h00000020, Mask:32'h0000FFFF, RegType:Rw_E, Reset:32'h00000000};
//constant SigGenIrq_Reg_Con                      : Axi_Reg_Type:= (x"00000030", x"00000001", Wc_E, 32'h00000000");
Axi_Reg_Type SigGenIrq_Reg_Con = '{Addr:32'h00000030, Mask:32'h00000001, RegType:Wc_E, Reset:32'h00000000};
//constant SigGenIrqMask_Reg_Con                  : Axi_Reg_Type:= (x"00000034", x"00000001", Rw_E, 32'h00000000");
Axi_Reg_Type SigGenIrqMask_Reg_Con = '{Addr:32'h00000034, Mask:32'h00000001, RegType:Rw_E, Reset:32'h00000000};
//constant SigGenStartTimeValueL_Reg_Con          : Axi_Reg_Type:= (x"00000040", x"FFFFFFFF", Rw_E, 32'h00000000");
Axi_Reg_Type SigGenStartTimeValueL_Reg_Con = '{Addr:32'h00000040, Mask:32'hFFFFFFFF, RegType:Rw_E, Reset:32'h00000000};
//constant SigGenStartTimeValueH_Reg_Con          : Axi_Reg_Type:= (x"00000044", x"FFFFFFFF", Rw_E, 32'h00000000");
Axi_Reg_Type SigGenStartTimeValueH_Reg_Con = '{Addr:32'h00000044, Mask:32'hFFFFFFFF, RegType:Rw_E, Reset:32'h00000000};
//constant SigGenPulseWidthValueL_Reg_Con         : Axi_Reg_Type:= (x"00000048", x"FFFFFFFF", Rw_E, 32'h00000000");
Axi_Reg_Type SigGenPulseWidthValueL_Reg_Con = '{Addr:32'h00000048, Mask:32'hFFFFFFFF, RegType:Rw_E, Reset:32'h00000000};
//constant SigGenPulseWidthValueH_Reg_Con         : Axi_Reg_Type:= (x"0000004C", x"FFFFFFFF", Rw_E, 32'h00000000");
Axi_Reg_Type SigGenPulseWidthValueH_Reg_Con = '{Addr:32'h0000004C, Mask:32'hFFFFFFFF, RegType:Rw_E, Reset:32'h00000000};
//constant SigGenPeriodValueL_Reg_Con             : Axi_Reg_Type:= (x"00000050", x"FFFFFFFF", Rw_E, 32'h00000000");
Axi_Reg_Type SigGenPeriodValueL_Reg_Con = '{Addr:32'h00000050, Mask:32'hFFFFFFFF, RegType:Rw_E, Reset:32'h00000000};
//constant SigGenPeriodValueH_Reg_Con             : Axi_Reg_Type:= (x"00000054", x"FFFFFFFF", Rw_E, 32'h00000000");
Axi_Reg_Type SigGenPeriodValueH_Reg_Con = '{Addr:32'h00000054, Mask:32'hFFFFFFFF, RegType:Rw_E, Reset:32'h00000000};
//constant SigGenRepeatCount_Reg_Con              : Axi_Reg_Type:= (x"00000058", x"FFFFFFFF", Rw_E, 32'h00000000");
Axi_Reg_Type SigGenRepeatCount_Reg_Con = '{Addr:32'h00000058, Mask:32'hFFFFFFFF, RegType:Rw_E, Reset:32'h00000000};
parameter SigGenControl_EnableBit_Con = 0;
parameter SigGenControl_SignalValBit_Con = 1;
parameter SigGenStatus_Error_Con = 0;
parameter SigGenStatus_TimeJumpBit_Con = 1;
parameter SigGenPolarity_PolarityBit_Con = 0;
parameter SigGenIrq_RefInvalidBit_Con = 0;
parameter SigGenIrqMask_RefInvalidBit_Con = 0; 

parameter [1:0]
  Idle_St = 0,
  CheckTime_St = 1,
  Generate_St = 2;

// control and data signals
wire Enable_Ena;
wire Signal_Val;
wire Polarity_Dat;
reg Error_EvtReg;
wire [SecondWidth_Con - 1:0] StartTime_Second_Dat;
wire [NanosecondWidth_Con - 1:0] StartTime_Nanosecond_Dat;
wire [SecondWidth_Con - 1:0] PulseWidth_Second_Dat;
wire [NanosecondWidth_Con - 1:0] PulseWidth_Nanosecond_Dat;
wire [SecondWidth_Con - 1:0] Period_Second_Dat;
wire [NanosecondWidth_Con - 1:0] Period_Nanosecond_Dat;
wire [31:0] RepeatCount_Dat;
wire [15:0] CableDelay_Dat; 
// Time Input           
reg [SecondWidth_Con - 1:0] ClockTime_Second_DatReg;
reg [NanosecondWidth_Con - 1:0] ClockTime_Nanosecond_DatReg;
reg ClockTime_TimeJump_DatReg;
reg ClockTime_ValReg; 
// count the high resolution ticks
reg [HighResFreqMultiply_Gen - 1:0] SignalShiftSysClk_DatReg;
reg [HighResFreqMultiply_Gen - 1:0] SignalShiftSysClk1_DatReg;
reg [2 * HighResFreqMultiply_Gen - 1:0] SignalShiftSysClkNx_DatReg;
reg Polarity_DatReg;
reg [SecondWidth_Con - 1:0] StartTime_Second_DatReg;
reg [NanosecondWidth_Con - 1:0] StartTime_Nanosecond_DatReg;
reg [SecondWidth_Con - 1:0] StopTime_Second_DatReg;
reg [NanosecondWidth_Con - 1:0] StopTime_Nanosecond_DatReg;
reg [SecondWidth_Con - 1:0] PulseWidth_Second_DatReg;
reg [NanosecondWidth_Con - 1:0] PulseWidth_Nanosecond_DatReg;
reg [SecondWidth_Con - 1:0] Period_Second_DatReg;
reg [NanosecondWidth_Con - 1:0] Period_Nanosecond_DatReg;
reg [31:0] RepeatCount_DatReg; 
// number of generated pulses 
reg [31:0] PulseCount_CntReg; 
// signal activated
reg SignalActive_DatReg;
reg [1:0] SigGenState_StaReg; 
// Axi signals
reg [1:0] Axi_AccessState_StaReg = Axi_AccessState_Type_Rst_Con;
reg AxiWriteAddrReady_RdyReg;
reg AxiWriteDataReady_RdyReg;
reg AxiWriteRespValid_ValReg;
reg [1:0] AxiWriteRespResponse_DatReg;
reg AxiReadAddrReady_RdyReg;
reg AxiReadDataValid_ValReg;
reg [1:0] AxiReadDataResponse_DatReg;
reg [31:0] AxiReadDataData_DatReg;
reg [31:0] SigGenControl_DatReg;
reg [31:0] SigGenStatus_DatReg;
reg [31:0] SigGenPolarity_DatReg;
reg [31:0] SigGenVersion_DatReg;
reg [31:0] SigGenCableDelay_DatReg;
reg [31:0] SigGenIrq_DatReg;
reg [31:0] SigGenIrqMask_DatReg;
reg [31:0] SigGenStartTimeValueL_DatReg;
reg [31:0] SigGenStartTimeValueH_DatReg;
reg [31:0] SigGenPulseWidthValueL_DatReg;
reg [31:0] SigGenPulseWidthValueH_DatReg;
reg [31:0] SigGenPeriodValueL_DatReg;
reg [31:0] SigGenPeriodValueH_DatReg;
reg [31:0] SigGenRepeatCount_DatReg; 

  assign StartTime_Nanosecond_Dat = SigGenStartTimeValueL_DatReg;
  assign StartTime_Second_Dat = SigGenStartTimeValueH_DatReg;
  assign PulseWidth_Nanosecond_Dat = SigGenPulseWidthValueL_DatReg;
  assign PulseWidth_Second_Dat = SigGenPulseWidthValueH_DatReg;
  assign Period_Nanosecond_Dat = SigGenPeriodValueL_DatReg;
  assign Period_Second_Dat = SigGenPeriodValueH_DatReg;
  assign RepeatCount_Dat = SigGenRepeatCount_DatReg;
  assign Signal_Val = SigGenControl_DatReg[SigGenControl_SignalValBit_Con];
  assign Polarity_Dat = SigGenPolarity_DatReg[SigGenPolarity_PolarityBit_Con];
  assign CableDelay_Dat = CableDelay_Gen == "true" ? SigGenCableDelay_DatReg[15:0] : {16{1'b0}};
  assign Irq_EvtOut = SigGenIrq_DatReg[SigGenIrq_RefInvalidBit_Con] & SigGenIrqMask_DatReg[SigGenIrqMask_RefInvalidBit_Con];
  assign AxiWriteAddrReady_RdyOut = AxiWriteAddrReady_RdyReg;
  assign AxiWriteDataReady_RdyOut = AxiWriteDataReady_RdyReg;
  assign AxiWriteRespValid_ValOut = AxiWriteRespValid_ValReg;
  assign AxiWriteRespResponse_DatOut = AxiWriteRespResponse_DatReg;
  assign AxiReadAddrReady_RdyOut = AxiReadAddrReady_RdyReg;
  assign AxiReadDataValid_ValOut = AxiReadDataValid_ValReg;
  assign AxiReadDataResponse_DatOut = AxiReadDataResponse_DatReg;
  assign AxiReadDataData_DatOut = AxiReadDataData_DatReg;
  assign Enable_Ena = SigGenControl_DatReg[SigGenControl_EnableBit_Con];

  // The shift register that indicates how many high resolution clock periods could 'fit' between the start/stop time and the current time is passed to the high resolution clock domain
  // Generate the signal based on the compensated delays of the shift register
  always @(posedge SysClkNx_ClkIn) begin
    SignalShiftSysClk1_DatReg <= SignalShiftSysClk_DatReg;
    if(SignalShiftSysClk_DatReg != SignalShiftSysClk1_DatReg) begin
      SignalShiftSysClkNx_DatReg <= {SignalShiftSysClkNx_DatReg[(HighResFreqMultiply_Gen * 2) - 2:HighResFreqMultiply_Gen - 1],SignalShiftSysClk_DatReg};
      // copy the high resolution clock periods
    end else begin
      SignalShiftSysClkNx_DatReg <= {SignalShiftSysClkNx_DatReg[(HighResFreqMultiply_Gen * 2) - 2:0],SignalShiftSysClkNx_DatReg[0]};
      // retain the last value
    end
    if(Polarity_DatReg == 1'b1) begin
      SignalGenerator_EvtOut <= SignalShiftSysClkNx_DatReg[(HighResFreqMultiply_Gen * 2) - 1];
    end else begin
      SignalGenerator_EvtOut <=  ~SignalShiftSysClkNx_DatReg[(HighResFreqMultiply_Gen * 2) - 1];
    end
  end

  // When the Signal Generator is enabled and the new configuration registers are set, the StartTime and StopTime are calculated, as: 
  // StartTime<= StartTime-Delays and StopTime=StartTime+PulseWidth. 
  // If the StartTime is reached (equal or bigger) the pulse is asserted to the configured polarity and a new start time is calculated by adding to the current start time the signal period. 
  // If the stop time is reached (equal or bigger) the pulse is asserted to the inverse of the configured polarity, the new stop time is calculated by adding the period and a pulse counter gets incremented. 
  // This start/stop procedure is repeated until the pulse count is reached (continuously repetition if the pulse count is '0'). 
  // The pulse generation is disabled if a) the repetition limit is reached b)a time jump happens, c)the initial start time is set to the past (no signal generation) d)the input clock is not active
  // Additionally, in order to increase the accuracy of the generation, when the start/stop time is reached, a shift register indicates how many high resolution clock periods could 'fit' between the start/stop time and the current time.
  always @(posedge SysClk_ClkIn, negedge SysRstN_RstIn) begin
    if(SysRstN_RstIn == 1'b0) begin
      SigGenState_StaReg <= Idle_St;
      ClockTime_Second_DatReg <= {((SecondWidth_Con - 1)-(0)+1){1'b0}};
      ClockTime_Nanosecond_DatReg <= {((NanosecondWidth_Con - 1)-(0)+1){1'b0}};
      ClockTime_TimeJump_DatReg <= 1'b0;
      ClockTime_ValReg <= 1'b0;
      Error_EvtReg <= 1'b0;
      SignalActive_DatReg <= 1'b0;
      Polarity_DatReg <= 1'b1;
      PulseCount_CntReg <= {32{1'b0}};
      StartTime_Second_DatReg <= {((SecondWidth_Con - 1)-(0)+1){1'b0}};
      StartTime_Nanosecond_DatReg <= {((NanosecondWidth_Con - 1)-(0)+1){1'b0}};
      PulseWidth_Second_DatReg <= {((SecondWidth_Con - 1)-(0)+1){1'b0}};
      PulseWidth_Nanosecond_DatReg <= {((NanosecondWidth_Con - 1)-(0)+1){1'b0}};
      Period_Second_DatReg <= {((SecondWidth_Con - 1)-(0)+1){1'b0}};
      Period_Nanosecond_DatReg <= {((NanosecondWidth_Con - 1)-(0)+1){1'b0}};
      RepeatCount_DatReg <= {32{1'b0}};
      SignalShiftSysClk_DatReg <= {((HighResFreqMultiply_Gen - 1)-(0)+1){1'b0}};
    end else begin
      Error_EvtReg <= 1'b0;
      ClockTime_TimeJump_DatReg <= ClockTime_TimeJump_DatIn;
      ClockTime_ValReg <= ClockTime_ValIn;
      if(CableDelay_Gen == "false") begin
        ClockTime_Second_DatReg <= ClockTime_Second_DatIn;
        ClockTime_Nanosecond_DatReg <= ClockTime_Nanosecond_DatIn;
      end else begin
        if(ClockTime_Nanosecond_DatIn + CableDelay_Dat < SecondNanoseconds_Con) begin
          ClockTime_Second_DatReg <= ClockTime_Second_DatIn;
          ClockTime_Nanosecond_DatReg <= (ClockTime_Nanosecond_DatIn) + (CableDelay_Dat);
        end else begin
          ClockTime_Second_DatReg <= (ClockTime_Second_DatIn) + 1;
          ClockTime_Nanosecond_DatReg <= ((ClockTime_Nanosecond_DatIn) + (CableDelay_Dat)) - SecondNanoseconds_Con;
        end
      end
      if(Enable_Ena == 1'b1) begin
        if(Signal_Val == 1'b1) begin
          // update the configuration immediately
          if(StartTime_Nanosecond_Dat >= OutputDelaySum_Con) begin
            StartTime_Nanosecond_DatReg <= (StartTime_Nanosecond_Dat) - (OutputDelaySum_Con);
            StartTime_Second_DatReg <= StartTime_Second_Dat;
          end else begin
            StartTime_Nanosecond_DatReg <= ((StartTime_Nanosecond_Dat) + SecondNanoseconds_Con) - (OutputDelaySum_Con);
            StartTime_Second_DatReg <= (StartTime_Second_Dat) - 1;
          end
          Polarity_DatReg <= Polarity_Dat;
          PulseCount_CntReg <= {32{1'b0}};
          PulseWidth_Second_DatReg <= PulseWidth_Second_Dat;
          PulseWidth_Nanosecond_DatReg <= PulseWidth_Nanosecond_Dat;
          Period_Second_DatReg <= Period_Second_Dat;
          Period_Nanosecond_DatReg <= Period_Nanosecond_Dat;
          RepeatCount_DatReg <= RepeatCount_Dat;
          SignalActive_DatReg <= 1'b0;
          SignalShiftSysClk_DatReg <= {((HighResFreqMultiply_Gen - 1)-(0)+1){1'b0}};
          SigGenState_StaReg <= CheckTime_St;
        end else begin
          case(SigGenState_StaReg)
          Idle_St : begin
            // wait for a new configuration
            Polarity_DatReg <= 1'b1;
            PulseCount_CntReg <= {32{1'b0}};
            StartTime_Second_DatReg <= {((SecondWidth_Con - 1)-(0)+1){1'b0}};
            StartTime_Nanosecond_DatReg <= {((NanosecondWidth_Con - 1)-(0)+1){1'b0}};
            PulseWidth_Second_DatReg <= {((SecondWidth_Con - 1)-(0)+1){1'b0}};
            PulseWidth_Nanosecond_DatReg <= {((NanosecondWidth_Con - 1)-(0)+1){1'b0}};
            Period_Second_DatReg <= {((SecondWidth_Con - 1)-(0)+1){1'b0}};
            Period_Nanosecond_DatReg <= {((NanosecondWidth_Con - 1)-(0)+1){1'b0}};
            RepeatCount_DatReg <= {32{1'b0}};
            SignalActive_DatReg <= 1'b0;
            SignalShiftSysClk_DatReg <= {((HighResFreqMultiply_Gen - 1)-(0)+1){1'b0}};
            SigGenState_StaReg <= Idle_St;
          end
          CheckTime_St : begin
            // validate the new configuration
            if(ClockTime_TimeJump_DatReg == 1'b0 && ClockTime_ValReg == 1'b1 && ((StartTime_Second_DatReg > ClockTime_Second_DatReg) || ((StartTime_Second_DatReg == ClockTime_Second_DatReg) && (StartTime_Nanosecond_DatReg > ClockTime_Nanosecond_DatReg)))) begin
              if(StartTime_Nanosecond_DatReg + PulseWidth_Nanosecond_DatReg < SecondNanoseconds_Con) begin
                StopTime_Nanosecond_DatReg <= (StartTime_Nanosecond_DatReg) + (PulseWidth_Nanosecond_DatReg);
                StopTime_Second_DatReg <= (StartTime_Second_DatReg) + (PulseWidth_Second_DatReg);
              end else begin
                StopTime_Nanosecond_DatReg <= (StartTime_Nanosecond_DatReg) + (PulseWidth_Nanosecond_DatReg) - SecondNanoseconds_Con;
                StopTime_Second_DatReg <= (StartTime_Second_DatReg) + (PulseWidth_Second_DatReg) + 1;
              end
              SigGenState_StaReg <= Generate_St;
            end else begin
              Error_EvtReg <= 1'b1;
              SignalShiftSysClk_DatReg <= {((HighResFreqMultiply_Gen - 1)-(0)+1){1'b0}};
              SigGenState_StaReg <= Idle_St;
            end
          end
          Generate_St : begin
            // generate the configured signal
            if(ClockTime_TimeJump_DatReg == 1'b0 && ClockTime_ValReg == 1'b1) begin
              if(RepeatCount_DatReg == 0 || (PulseCount_CntReg < RepeatCount_DatReg)) begin
                // if current time >= start time
                if((((ClockTime_Second_DatReg) > (StartTime_Second_DatReg)) || ((ClockTime_Second_DatReg == StartTime_Second_DatReg) && ((ClockTime_Nanosecond_DatReg) >= (StartTime_Nanosecond_DatReg))))) begin
                  // calculate next start point
                  if((((StartTime_Nanosecond_DatReg) + (Period_Nanosecond_DatReg)) < SecondNanoseconds_Con)) begin
                    StartTime_Nanosecond_DatReg <= (StartTime_Nanosecond_DatReg) + (Period_Nanosecond_DatReg);
                    StartTime_Second_DatReg <= (StartTime_Second_DatReg) + (Period_Second_DatReg);
                  end else begin
                    StartTime_Nanosecond_DatReg <= (StartTime_Nanosecond_DatReg) + (Period_Nanosecond_DatReg) - SecondNanoseconds_Con;
                    StartTime_Second_DatReg <= (StartTime_Second_DatReg) + (Period_Second_DatReg) + 1;
                  end
                  SignalActive_DatReg <= 1'b1;
                  if((SignalActive_DatReg != 1'b1)) begin
                    SignalShiftSysClk_DatReg <= {((HighResFreqMultiply_Gen - 1)-(0)+1){1'b0}};
                    for (i=0; i <= HighResFreqMultiply_Gen - 1; i = i + 1) begin
                      // if we are at the point where we need to provide the shift register pattern
                      if((((StartTime_Nanosecond_DatReg) + (i * HighResClockPeriod_Con)) < SecondNanoseconds_Con)) begin
                        if((((ClockTime_Second_DatReg) > (StartTime_Second_DatReg)) || (((ClockTime_Second_DatReg) == (StartTime_Second_DatReg)) && ((ClockTime_Nanosecond_DatReg) >= ((StartTime_Nanosecond_DatReg) + (i * HighResClockPeriod_Con)))))) begin
                          SignalShiftSysClk_DatReg[i] <= 1'b1;
                        end
                      end else begin
                        if((((ClockTime_Second_DatReg) > ((StartTime_Second_DatReg) + 1)) || (((ClockTime_Second_DatReg) == ((StartTime_Second_DatReg) + 1)) && ((ClockTime_Nanosecond_DatReg) >= (((StartTime_Nanosecond_DatReg) + (i * HighResClockPeriod_Con)) - SecondNanoseconds_Con))))) begin
                          SignalShiftSysClk_DatReg[i] <= 1'b1;
                        end
                      end
                    end
                  end else begin
                    SignalShiftSysClk_DatReg <= {((HighResFreqMultiply_Gen - 1)-(0)+1){1'b0}};
                  end
                  // if current time >= stop time
                end else if((((ClockTime_Second_DatReg) > (StopTime_Second_DatReg)) || ((ClockTime_Second_DatReg == StopTime_Second_DatReg) && ((ClockTime_Nanosecond_DatReg) >= (StopTime_Nanosecond_DatReg))))) begin
                  if(((RepeatCount_DatReg) != 0)) begin
                    PulseCount_CntReg <= (PulseCount_CntReg) + 1;
                  end
                  // calculate next stop point
                  if((((StopTime_Nanosecond_DatReg) + (Period_Nanosecond_DatReg)) < SecondNanoseconds_Con)) begin
                    StopTime_Nanosecond_DatReg <= (StopTime_Nanosecond_DatReg) + (Period_Nanosecond_DatReg);
                    StopTime_Second_DatReg <= (StopTime_Second_DatReg) + (Period_Second_DatReg);
                  end else begin
                    StopTime_Nanosecond_DatReg <= (StopTime_Nanosecond_DatReg) + (Period_Nanosecond_DatReg) - SecondNanoseconds_Con;
                    StopTime_Second_DatReg <= (StopTime_Second_DatReg) + (Period_Second_DatReg) + 1;
                  end
                  SignalActive_DatReg <= 1'b0;
                  if((SignalActive_DatReg == 1'b1)) begin
                    SignalShiftSysClk_DatReg <= {((HighResFreqMultiply_Gen - 1)-(0)+1){1'b1}};
                    for (i=0; i <= HighResFreqMultiply_Gen - 1; i = i + 1) begin
                      // if we are at the point where we need to provide the shift register pattern
                      if((((StopTime_Nanosecond_DatReg) + (i * HighResClockPeriod_Con)) < SecondNanoseconds_Con)) begin
                        if((((ClockTime_Second_DatReg) > (StopTime_Second_DatReg)) || (((ClockTime_Second_DatReg) == (StopTime_Second_DatReg)) && ((ClockTime_Nanosecond_DatReg) >= ((StopTime_Nanosecond_DatReg) + (i * HighResClockPeriod_Con)))))) begin
                          SignalShiftSysClk_DatReg[i] <= 1'b0;
                        end
                      end else begin
                        if((((ClockTime_Second_DatReg) > ((StopTime_Second_DatReg) + 1)) || (((ClockTime_Second_DatReg) == ((StopTime_Second_DatReg) + 1)) && ((ClockTime_Nanosecond_DatReg) >= (((StopTime_Nanosecond_DatReg) + (i * HighResClockPeriod_Con)) - SecondNanoseconds_Con))))) begin
                          SignalShiftSysClk_DatReg[i] <= 1'b0;
                        end
                      end
                    end
                  end else begin
                    SignalShiftSysClk_DatReg <= {((HighResFreqMultiply_Gen - 1)-(0)+1){1'b0}};
                  end
                end
              end else begin
                SignalShiftSysClk_DatReg <= {((HighResFreqMultiply_Gen - 1)-(0)+1){1'b0}};
                SigGenState_StaReg <= Idle_St;
              end
            end else begin
              Error_EvtReg <= 1'b1;
              SignalShiftSysClk_DatReg <= {((HighResFreqMultiply_Gen - 1)-(0)+1){1'b0}};
              SigGenState_StaReg <= Idle_St;
            end
          end
          default : begin
            SigGenState_StaReg <= Idle_St;
          end
          endcase
        end
      end else begin
        SignalActive_DatReg <= 1'b0;
        SignalShiftSysClk_DatReg <= {((HighResFreqMultiply_Gen - 1)-(0)+1){1'b0}};
        SigGenState_StaReg <= Idle_St;
      end
    end
  end

  // AXI register access
  always @(posedge SysClk_ClkIn, negedge SysRstN_RstIn) begin
    if((SysRstN_RstIn == 1'b0)) begin
      AxiWriteAddrReady_RdyReg <= 1'b0;
      AxiWriteDataReady_RdyReg <= 1'b0;
      AxiWriteRespValid_ValReg <= 1'b0;
      AxiWriteRespResponse_DatReg <= {2{1'b0}};
      AxiReadAddrReady_RdyReg <= 1'b0;
      AxiReadDataValid_ValReg <= 1'b0;
      AxiReadDataResponse_DatReg <= {2{1'b0}};
      AxiReadDataData_DatReg <= {32{1'b0}};
      Axi_AccessState_StaReg <= Axi_AccessState_Type_Rst_Con;
      `Axi_Init_Proc(SigGenControl_Reg_Con, SigGenControl_DatReg);
      `Axi_Init_Proc(SigGenStatus_Reg_Con, SigGenStatus_DatReg);
      `Axi_Init_Proc(SigGenPolarity_Reg_Con, SigGenPolarity_DatReg);
      if(OutputPolarity_Gen == "true") begin
        SigGenPolarity_DatReg[SigGenPolarity_PolarityBit_Con] <= 1'b1;
      end else begin
        SigGenPolarity_DatReg[SigGenPolarity_PolarityBit_Con] <= 1'b0;
      end
      `Axi_Init_Proc(SigGenCableDelay_Reg_Con, SigGenCableDelay_DatReg);
      `Axi_Init_Proc(SigGenVersion_Reg_Con, SigGenVersion_DatReg);
      `Axi_Init_Proc(SigGenIrq_Reg_Con, SigGenIrq_DatReg);
      `Axi_Init_Proc(SigGenIrqMask_Reg_Con, SigGenIrqMask_DatReg);
      `Axi_Init_Proc(SigGenStartTimeValueL_Reg_Con, SigGenStartTimeValueL_DatReg);
      `Axi_Init_Proc(SigGenStartTimeValueH_Reg_Con, SigGenStartTimeValueH_DatReg);
      `Axi_Init_Proc(SigGenPulseWidthValueL_Reg_Con, SigGenPulseWidthValueL_DatReg);
      `Axi_Init_Proc(SigGenPulseWidthValueH_Reg_Con, SigGenPulseWidthValueH_DatReg);
      `Axi_Init_Proc(SigGenPeriodValueL_Reg_Con, SigGenPeriodValueL_DatReg);
      `Axi_Init_Proc(SigGenPeriodValueH_Reg_Con, SigGenPeriodValueH_DatReg);
      `Axi_Init_Proc(SigGenRepeatCount_Reg_Con, SigGenRepeatCount_DatReg);
    end else begin
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
          `Axi_Read_Proc(SigGenControl_Reg_Con, SigGenControl_DatReg, AxiReadAddrAddress_AdrIn, AxiReadDataData_DatReg, AxiReadDataResponse_DatReg);
          `Axi_Read_Proc(SigGenStatus_Reg_Con, SigGenStatus_DatReg, AxiReadAddrAddress_AdrIn, AxiReadDataData_DatReg, AxiReadDataResponse_DatReg);
          `Axi_Read_Proc(SigGenPolarity_Reg_Con, SigGenPolarity_DatReg, AxiReadAddrAddress_AdrIn, AxiReadDataData_DatReg, AxiReadDataResponse_DatReg);
          if(CableDelay_Gen == "true") begin
            `Axi_Read_Proc(SigGenCableDelay_Reg_Con, SigGenCableDelay_DatReg, AxiReadAddrAddress_AdrIn, AxiReadDataData_DatReg, AxiReadDataResponse_DatReg);
          end
          `Axi_Read_Proc(SigGenVersion_Reg_Con, SigGenVersion_DatReg, AxiReadAddrAddress_AdrIn, AxiReadDataData_DatReg, AxiReadDataResponse_DatReg);
          `Axi_Read_Proc(SigGenIrq_Reg_Con, SigGenIrq_DatReg, AxiReadAddrAddress_AdrIn, AxiReadDataData_DatReg, AxiReadDataResponse_DatReg);
          `Axi_Read_Proc(SigGenIrqMask_Reg_Con, SigGenIrqMask_DatReg, AxiReadAddrAddress_AdrIn, AxiReadDataData_DatReg, AxiReadDataResponse_DatReg);
          `Axi_Read_Proc(SigGenStartTimeValueL_Reg_Con, SigGenStartTimeValueL_DatReg, AxiReadAddrAddress_AdrIn, AxiReadDataData_DatReg, AxiReadDataResponse_DatReg);
          `Axi_Read_Proc(SigGenStartTimeValueH_Reg_Con, SigGenStartTimeValueH_DatReg, AxiReadAddrAddress_AdrIn, AxiReadDataData_DatReg, AxiReadDataResponse_DatReg);
          `Axi_Read_Proc(SigGenPulseWidthValueL_Reg_Con, SigGenPulseWidthValueL_DatReg, AxiReadAddrAddress_AdrIn, AxiReadDataData_DatReg, AxiReadDataResponse_DatReg);
          `Axi_Read_Proc(SigGenPulseWidthValueH_Reg_Con, SigGenPulseWidthValueH_DatReg, AxiReadAddrAddress_AdrIn, AxiReadDataData_DatReg, AxiReadDataResponse_DatReg);
          `Axi_Read_Proc(SigGenPeriodValueL_Reg_Con, SigGenPeriodValueL_DatReg, AxiReadAddrAddress_AdrIn, AxiReadDataData_DatReg, AxiReadDataResponse_DatReg);
          `Axi_Read_Proc(SigGenPeriodValueH_Reg_Con, SigGenPeriodValueH_DatReg, AxiReadAddrAddress_AdrIn, AxiReadDataData_DatReg, AxiReadDataResponse_DatReg);
          `Axi_Read_Proc(SigGenRepeatCount_Reg_Con, SigGenRepeatCount_DatReg, AxiReadAddrAddress_AdrIn, AxiReadDataData_DatReg, AxiReadDataResponse_DatReg);
          Axi_AccessState_StaReg <= Resp_St;
        end
      end
      Write_St : begin
        if(AxiWriteAddrValid_ValIn == 1'b1 && AxiWriteAddrReady_RdyReg == 1'b1 && AxiWriteDataValid_ValIn == 1'b1 && AxiWriteDataReady_RdyReg == 1'b1) begin
          AxiWriteRespValid_ValReg <= 1'b1;
          AxiWriteRespResponse_DatReg <= Axi_RespSlvErr_Con;
          `Axi_Write_Proc(SigGenControl_Reg_Con, SigGenControl_DatReg, AxiWriteAddrAddress_AdrIn, AxiWriteDataData_DatIn, AxiWriteRespResponse_DatReg);
          `Axi_Write_Proc(SigGenStatus_Reg_Con, SigGenStatus_DatReg, AxiWriteAddrAddress_AdrIn, AxiWriteDataData_DatIn, AxiWriteRespResponse_DatReg);
          `Axi_Write_Proc(SigGenPolarity_Reg_Con, SigGenPolarity_DatReg, AxiWriteAddrAddress_AdrIn, AxiWriteDataData_DatIn, AxiWriteRespResponse_DatReg);
          if(CableDelay_Gen == "true") begin
            `Axi_Write_Proc(SigGenCableDelay_Reg_Con, SigGenCableDelay_DatReg, AxiWriteAddrAddress_AdrIn, AxiWriteDataData_DatIn, AxiWriteRespResponse_DatReg);
          end
          `Axi_Write_Proc(SigGenVersion_Reg_Con, SigGenVersion_DatReg, AxiWriteAddrAddress_AdrIn, AxiWriteDataData_DatIn, AxiWriteRespResponse_DatReg);
          `Axi_Write_Proc(SigGenIrq_Reg_Con, SigGenIrq_DatReg, AxiWriteAddrAddress_AdrIn, AxiWriteDataData_DatIn, AxiWriteRespResponse_DatReg);
          `Axi_Write_Proc(SigGenIrqMask_Reg_Con, SigGenIrqMask_DatReg, AxiWriteAddrAddress_AdrIn, AxiWriteDataData_DatIn, AxiWriteRespResponse_DatReg);
          `Axi_Write_Proc(SigGenStartTimeValueL_Reg_Con, SigGenStartTimeValueL_DatReg, AxiWriteAddrAddress_AdrIn, AxiWriteDataData_DatIn, AxiWriteRespResponse_DatReg);
          `Axi_Write_Proc(SigGenStartTimeValueH_Reg_Con, SigGenStartTimeValueH_DatReg, AxiWriteAddrAddress_AdrIn, AxiWriteDataData_DatIn, AxiWriteRespResponse_DatReg);
          `Axi_Write_Proc(SigGenPulseWidthValueL_Reg_Con, SigGenPulseWidthValueL_DatReg, AxiWriteAddrAddress_AdrIn, AxiWriteDataData_DatIn, AxiWriteRespResponse_DatReg);
          `Axi_Write_Proc(SigGenPulseWidthValueH_Reg_Con, SigGenPulseWidthValueH_DatReg, AxiWriteAddrAddress_AdrIn, AxiWriteDataData_DatIn, AxiWriteRespResponse_DatReg);
          `Axi_Write_Proc(SigGenPeriodValueL_Reg_Con, SigGenPeriodValueL_DatReg, AxiWriteAddrAddress_AdrIn, AxiWriteDataData_DatIn, AxiWriteRespResponse_DatReg);
          `Axi_Write_Proc(SigGenPeriodValueH_Reg_Con, SigGenPeriodValueH_DatReg, AxiWriteAddrAddress_AdrIn, AxiWriteDataData_DatIn, AxiWriteRespResponse_DatReg);
          `Axi_Write_Proc(SigGenRepeatCount_Reg_Con, SigGenRepeatCount_DatReg, AxiWriteAddrAddress_AdrIn, AxiWriteDataData_DatIn, AxiWriteRespResponse_DatReg);
          Axi_AccessState_StaReg <= Resp_St;
        end
      end
      Resp_St : begin
        if(((AxiWriteRespValid_ValReg == 1'b1 && AxiWriteRespReady_RdyIn == 1'b1) || ((AxiReadDataValid_ValReg == 1'b1) && AxiReadDataReady_RdyIn == 1'b1))) begin
          Axi_AccessState_StaReg <= Idle_St;
        end
      end
      endcase
      if(SigGenControl_DatReg[SigGenControl_EnableBit_Con] == 1'b1) begin
        if(Error_EvtReg == 1'b1) begin
          SigGenStatus_DatReg[SigGenStatus_Error_Con] <= 1'b1;
        end
        if(ClockTime_TimeJump_DatIn == 1'b1 || ClockTime_ValIn == 1'b0) begin
          SigGenStatus_DatReg[SigGenStatus_TimeJumpBit_Con] <= 1'b1;
        end
      end else begin
        SigGenStatus_DatReg[SigGenStatus_Error_Con] <= 1'b0;
        SigGenStatus_DatReg[SigGenStatus_TimeJumpBit_Con] <= 1'b0;
      end
      if(SigGenControl_DatReg[SigGenControl_SignalValBit_Con] == 1'b1) begin
        SigGenControl_DatReg[SigGenControl_SignalValBit_Con] <= 1'b0;
      end
      if(CableDelay_Gen == "false") begin
        `Axi_Init_Proc(SigGenCableDelay_Reg_Con, SigGenCableDelay_DatReg);
      end
      if((SigGenControl_DatReg[SigGenControl_EnableBit_Con] == 1'b1) && (SigGenIrq_DatReg[SigGenIrq_RefInvalidBit_Con] == 1'b0) && (SigGenIrqMask_DatReg[SigGenIrqMask_RefInvalidBit_Con] == 1'b1) && ((ClockTime_TimeJump_DatIn == 1'b1) || (ClockTime_ValReg != ClockTime_ValIn) || (Error_EvtReg == 1'b1))) begin
        SigGenIrq_DatReg[SigGenIrq_RefInvalidBit_Con] <= 1'b1;
      end
    end
  end
endmodule
