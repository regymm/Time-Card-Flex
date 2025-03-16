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

// The SignalTimestamper timestamps an event signal of configurable polarity.            --
// Timestamps are taken on the configured edge of the signal and optional interrupts     -- 
// are generated. The reference time for the timestamp is provided as input and the      --
// delays of the timestamps are compensated. The Signal Timestamper is intended to be    --
// connected to a CPU or any other AXI master that can read out the timestamps. The      --
// settings are configured by an AXI4Light-Slave Register interface.                     -- 
`include "TimeCard_Package.svh"

module SignalTimestamper #(
parameter [31:0] ClockPeriod_Gen=20,
parameter CableDelay_Gen="false",
parameter [31:0] InputDelay_Gen=100,
parameter InputPolarity_Gen="true",
parameter [31:0] HighResFreqMultiply_Gen=5
    )(
// System           
input wire SysClk_ClkIn,
input wire SysClkNx_ClkIn,
input wire SysRstN_RstIn,
// Time Input           
input wire [SecondWidth_Con - 1:0] ClockTime_Second_DatIn,
input wire [NanosecondWidth_Con - 1:0] ClockTime_Nanosecond_DatIn,
input wire ClockTime_TimeJump_DatIn, // unused
input wire ClockTime_ValIn,
// Timestamp Event Input            
input wire SignalTimestamper_EvtIn,
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
// Timestamper Version 
parameter [7:0]TimestamperMajorVersion_Con = 0;
parameter [7:0]TimestamperMinorVersion_Con = 1;
parameter [15:0]TimestamperBuildVersion_Con = 0;
parameter [31:0]TimestamperVersion_Con = { TimestamperMajorVersion_Con,TimestamperMinorVersion_Con,TimestamperBuildVersion_Con }; 
// AXI Registers        
//constant TimestamperControl_Reg_Con             : Axi_Reg_Type:= (x"00000000", x"00000001", Rw_E, x"00000000");
Axi_Reg_Type TimestamperControl_Reg_Con = '{Addr:32'h00000000, Mask:32'h00000001, RegType:Rw_E, Reset:32'h00000000};
//constant TimestamperStatus_Reg_Con              : Axi_Reg_Type:= (x"00000004", x"00000003", Wc_E, x"00000000");
Axi_Reg_Type TimestamperStatus_Reg_Con = '{Addr:32'h00000004, Mask:32'h00000003, RegType:Wc_E, Reset:32'h00000000};
//constant TimestamperPolarity_Reg_Con            : Axi_Reg_Type:= (x"00000008", x"00000001", Rw_E, x"00000000");
Axi_Reg_Type TimestamperPolarity_Reg_Con = '{Addr:32'h00000008, Mask:32'h00000001, RegType:Rw_E, Reset:32'h00000000};
//constant TimestamperVersion_Reg_Con             : Axi_Reg_Type:= (x"0000000C", x"FFFFFFFF", Ro_E, TimestamperVersion_Con);
Axi_Reg_Type TimestamperVersion_Reg_Con = '{Addr:32'h0000000C, Mask:32'hFFFFFFFF, RegType:Ro_E, Reset:TimestamperVersion_Con};
//constant TimestamperCableDelay_Reg_Con          : Axi_Reg_Type:= (x"00000020", x"0000FFFF", Rw_E, x"00000000");
Axi_Reg_Type TimestamperCableDelay_Reg_Con = '{Addr:32'h00000020, Mask:32'h0000FFFF, RegType:Rw_E, Reset:32'h00000000};
//constant TimestamperIrq_Reg_Con                 : Axi_Reg_Type:= (x"00000030", x"00000001", Wc_E, x"00000000");
Axi_Reg_Type TimestamperIrq_Reg_Con = '{Addr:32'h00000030, Mask:32'h00000001, RegType:Wc_E, Reset:32'h00000000};
//constant TimestamperIrqMask_Reg_Con             : Axi_Reg_Type:= (x"00000034", x"00000001", Rw_E, x"00000000");
Axi_Reg_Type TimestamperIrqMask_Reg_Con = '{Addr:32'h00000034, Mask:32'h00000001, RegType:Rw_E, Reset:32'h00000000};
//constant TimestamperEvtCount_Reg_Con            : Axi_Reg_Type:= (x"00000038", x"FFFFFFFF", Ro_E, x"00000000");
Axi_Reg_Type TimestamperEvtCount_Reg_Con = '{Addr:32'h00000038, Mask:32'hFFFFFFFF, RegType:Ro_E, Reset:32'h00000000};
//constant TimestamperCount_Reg_Con               : Axi_Reg_Type:= (x"00000040", x"FFFFFFFF", Ro_E, x"00000000");
Axi_Reg_Type TimestamperCount_Reg_Con = '{Addr:32'h00000040, Mask:32'hFFFFFFFF, RegType:Ro_E, Reset:32'h00000000};
//constant TimestamperTimeValueL_Reg_Con          : Axi_Reg_Type:= (x"00000044", x"FFFFFFFF", Ro_E, x"00000000");
Axi_Reg_Type TimestamperTimeValueL_Reg_Con = '{Addr:32'h00000044, Mask:32'hFFFFFFFF, RegType:Ro_E, Reset:32'h00000000};
//constant TimestamperTimeValueH_Reg_Con          : Axi_Reg_Type:= (x"00000048", x"FFFFFFFF", Ro_E, x"00000000");
Axi_Reg_Type TimestamperTimeValueH_Reg_Con = '{Addr:32'h00000048, Mask:32'hFFFFFFFF, RegType:Ro_E, Reset:32'h00000000};
//constant TimestamperDataWidth_Reg_Con           : Axi_Reg_Type:= (x"0000004C", x"FFFFFFFF", Ro_E, x"00000000"); -- unused
Axi_Reg_Type TimestamperDataWidth_Reg_Con = '{Addr:32'h0000004C, Mask:32'hFFFFFFFF, RegType:Ro_E, Reset:32'h00000000}; // unused
//constant TimestamperData_Reg_Con                : Axi_Reg_Type:= (x"00000050", x"FFFFFFFF", Ro_E, x"00000000"); -- unused
Axi_Reg_Type TimestamperData_Reg_Con = '{Addr:32'h00000050, Mask:32'hFFFFFFFF, RegType:Ro_E, Reset:32'h00000000}; // unused
parameter TimestamperControl_EnableBit_Con = 0;
parameter TimestamperStatus_DropBit_Con = 0;
parameter TimestamperPolarity_PolarityBit_Con = 0;
parameter TimestamperIrq_TimestampBit_Con = 0;
parameter TimestamperIrqMask_TimestampBit_Con = 0; 

wire Enable_Ena;
wire SignalTimestamper_Evt;
reg [SecondWidth_Con - 1:0] Timestamp_Second_DatReg;
reg [NanosecondWidth_Con - 1:0] Timestamp_Nanosecond_DatReg;
reg Timestamp_ValReg;
wire [15:0] SignalCableDelay_Dat;
wire SignalPolarity_Dat;
reg [31:0] RegisterDelay_DatReg;
reg [31:0] Count_CntReg;  // Time Input           
reg [SecondWidth_Con - 1:0] ClockTime_Second_DatReg;
reg [NanosecondWidth_Con - 1:0] ClockTime_Nanosecond_DatReg;
reg ClockTime_ValReg;
reg TimestampSysClkNx1_EvtReg = 1'b0;
reg TimestampSysClkNx2_EvtReg = 1'b0;
reg [HighResFreqMultiply_Gen * 2 - 1:0] TimestampSysClkNx_EvtShiftReg = 1'b0;
reg TimestampSysClk1_EvtReg = 1'b0;
reg TimestampSysClk2_EvtReg = 1'b0;
reg TimestampSysClk3_EvtReg = 1'b0;
reg TimestampSysClk4_EvtReg = 1'b0;
reg [HighResFreqMultiply_Gen * 2 - 1:0] TimestampSysClk_EvtShiftReg = 1'b0; 
// Axi Signals                                  
reg [1:0] Axi_AccessState_StaReg = Axi_AccessState_Type_Rst_Con;
reg AxiWriteAddrReady_RdyReg;
reg AxiWriteDataReady_RdyReg;
reg AxiWriteRespValid_ValReg;
reg [1:0] AxiWriteRespResponse_DatReg;
reg AxiReadAddrReady_RdyReg;
reg AxiReadDataValid_ValReg;
reg [1:0] AxiReadDataResponse_DatReg;
reg [31:0] AxiReadDataData_DatReg;
reg [31:0] TimestamperControl_DatReg;
reg [31:0] TimestamperStatus_DatReg;
reg [31:0] TimestamperPolarity_DatReg;
reg [31:0] TimestamperVersion_DatReg;
reg [31:0] TimestamperCableDelay_DatReg;
reg [31:0] TimestamperIrq_DatReg;
reg [31:0] TimestamperIrqMask_DatReg;
reg [31:0] TimestamperEvtCount_DatReg;
reg [31:0] TimestamperCount_DatReg;
reg [31:0] TimestamperTimeValueL_DatReg;
reg [31:0] TimestamperTimeValueH_DatReg;
reg [31:0] TimestamperDataWidth_DatReg;  // unused
reg [31:0] TimestamperData_DatReg;  // unused

  assign Irq_EvtOut = TimestamperIrq_DatReg[TimestamperIrq_TimestampBit_Con] & TimestamperIrqMask_DatReg[TimestamperIrqMask_TimestampBit_Con];
  assign Enable_Ena = TimestamperControl_DatReg[TimestamperControl_EnableBit_Con];
  assign SignalCableDelay_Dat = (CableDelay_Gen == "true") ? TimestamperCableDelay_DatReg[15:0] : {16{1'b0}};
  assign SignalPolarity_Dat = TimestamperPolarity_DatReg[TimestamperPolarity_PolarityBit_Con];
  assign SignalTimestamper_Evt = (SignalPolarity_Dat == 1'b1) ? SignalTimestamper_EvtIn :  ~SignalTimestamper_EvtIn;
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
    TimestampSysClkNx1_EvtReg <= SignalTimestamper_Evt;
    TimestampSysClkNx2_EvtReg <= TimestampSysClkNx1_EvtReg;
    TimestampSysClkNx_EvtShiftReg <= {TimestampSysClkNx_EvtShiftReg[HighResFreqMultiply_Gen * 2 - 2:0],TimestampSysClkNx2_EvtReg};
  end

  // Copy the event shift register of the high resolution clock domain to the system clock domain
  always @(posedge SysClk_ClkIn) begin
    TimestampSysClk1_EvtReg <= SignalTimestamper_Evt;
    TimestampSysClk2_EvtReg <= TimestampSysClk1_EvtReg;
    TimestampSysClk3_EvtReg <= TimestampSysClk2_EvtReg;
    TimestampSysClk4_EvtReg <= TimestampSysClk3_EvtReg;
    TimestampSysClk_EvtShiftReg <= TimestampSysClkNx_EvtShiftReg;
  end

  // Calculate the timestamp by compensating for the delays:
  //    - the timestamping at the high resolution clock domain and the corresponding register delays for switching the clock domains
  //    - the input delay, which is provided as generic input
  //    - the cable delay, which is received by the AXI register (and enabled by a generic input)
  always @(posedge SysClk_ClkIn, posedge SysRstN_RstIn) begin
    if(SysRstN_RstIn == 1'b0) begin
      Timestamp_ValReg <= 1'b0;
      Timestamp_Second_DatReg <= {((SecondWidth_Con - 1)-(0)+1){1'b0}};
      Timestamp_Nanosecond_DatReg <= {((NanosecondWidth_Con - 1)-(0)+1){1'b0}};
      RegisterDelay_DatReg <= 0;
      Count_CntReg <= {32{1'b0}};
      ClockTime_Second_DatReg <= {((SecondWidth_Con - 1)-(0)+1){1'b0}};
      ClockTime_Nanosecond_DatReg <= {((NanosecondWidth_Con - 1)-(0)+1){1'b0}};
      ClockTime_ValReg <= 1'b0;
    end else begin
      // single pulse
      Timestamp_ValReg <= 1'b0;
      // calculate the delay of the high resolution timestamping which consists of 
      //     - the fixed offset of the clock domain crossing 
      //     - the number of high res. clock periods, from the event until the next rising edge of the system clock
      if(TimestampSysClk2_EvtReg == 1'b1 && TimestampSysClk3_EvtReg == 1'b0) begin
        // store the current time 
        ClockTime_Second_DatReg <= ClockTime_Second_DatIn;
        ClockTime_Nanosecond_DatReg <= ClockTime_Nanosecond_DatIn;
        ClockTime_ValReg <= ClockTime_ValIn;
        for (i=(HighResFreqMultiply_Gen * 2) - 1; i >= 0; i = i - 1) begin: loop_1
          if((i >= (HighResFreqMultiply_Gen * 2 - 3))) begin
            if((TimestampSysClk_EvtShiftReg[i] == 1'b1)) begin
              RegisterDelay_DatReg <= 3 * ClockPeriod_Gen;
              disable loop_1;
            end
          end else if((i >= (HighResFreqMultiply_Gen - 3))) begin
            if((TimestampSysClk_EvtShiftReg[i] == 1'b1)) begin
              RegisterDelay_DatReg <= 2 * ClockPeriod_Gen + $round((ClockPeriod_Gen / (2 * HighResFreqMultiply_Gen)) + ((i - (HighResFreqMultiply_Gen - 3)) * ClockPeriod_Gen / HighResFreqMultiply_Gen));
              disable loop_1;
            end
          end else begin
            RegisterDelay_DatReg <= 2 * ClockPeriod_Gen;
          end
        end
      end
      // Compensate the timestamp delays. Ensure that the Nanosecond field does not underflow.
      if((TimestampSysClk3_EvtReg == 1'b1 && TimestampSysClk4_EvtReg == 1'b0)) begin
        Count_CntReg <= (Count_CntReg) + 1;
        Timestamp_ValReg <= 1'b1;
        if((ClockTime_ValReg == 1'b0)) begin
          Timestamp_ValReg <= 1'b0;
          Timestamp_Second_DatReg <= {((SecondWidth_Con - 1)-(0)+1){1'b0}};
          Timestamp_Nanosecond_DatReg <= {((NanosecondWidth_Con - 1)-(0)+1){1'b0}};
        end else begin
          if(((ClockTime_Nanosecond_DatReg) < (InputDelay_Gen + RegisterDelay_DatReg + (SignalCableDelay_Dat)))) begin
            // smaller than 0
            Timestamp_Nanosecond_DatReg <= SecondNanoseconds_Con + (ClockTime_Nanosecond_DatReg) - (InputDelay_Gen + RegisterDelay_DatReg + (SignalCableDelay_Dat));
            Timestamp_Second_DatReg <= (ClockTime_Second_DatReg) - 1;
          end else begin
            // larger than/equal to 0
            Timestamp_Nanosecond_DatReg <= (ClockTime_Nanosecond_DatReg) - (InputDelay_Gen + RegisterDelay_DatReg + (SignalCableDelay_Dat));
            Timestamp_Second_DatReg <= ClockTime_Second_DatReg;
          end
        end
      end
      if((Enable_Ena == 1'b0)) begin
        Timestamp_ValReg <= 1'b0;
        Timestamp_Second_DatReg <= {((SecondWidth_Con - 1)-(0)+1){1'b0}};
        Timestamp_Nanosecond_DatReg <= {((NanosecondWidth_Con - 1)-(0)+1){1'b0}};
        Count_CntReg <= {32{1'b0}};
      end
    end
  end

  // AXI register access
  always @(posedge SysClk_ClkIn, posedge SysRstN_RstIn) begin
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
      `Axi_Init_Proc(TimestamperControl_Reg_Con, TimestamperControl_DatReg);
      `Axi_Init_Proc(TimestamperStatus_Reg_Con, TimestamperStatus_DatReg); // unused
      `Axi_Init_Proc(TimestamperPolarity_Reg_Con, TimestamperPolarity_DatReg);
      if((InputPolarity_Gen == "true")) begin
        TimestamperPolarity_DatReg[TimestamperPolarity_PolarityBit_Con] <= 1'b1;
      end else begin
        TimestamperPolarity_DatReg[TimestamperPolarity_PolarityBit_Con] <= 1'b0;
      end
      `Axi_Init_Proc(TimestamperCableDelay_Reg_Con, TimestamperCableDelay_DatReg);
      `Axi_Init_Proc(TimestamperVersion_Reg_Con, TimestamperVersion_DatReg);
      `Axi_Init_Proc(TimestamperIrq_Reg_Con, TimestamperIrq_DatReg);
      `Axi_Init_Proc(TimestamperIrqMask_Reg_Con, TimestamperIrqMask_DatReg);
      `Axi_Init_Proc(TimestamperEvtCount_Reg_Con, TimestamperEvtCount_DatReg);
      `Axi_Init_Proc(TimestamperCount_Reg_Con, TimestamperCount_DatReg);
      `Axi_Init_Proc(TimestamperTimeValueL_Reg_Con, TimestamperTimeValueL_DatReg);
      `Axi_Init_Proc(TimestamperTimeValueH_Reg_Con, TimestamperTimeValueH_DatReg);
      `Axi_Init_Proc(TimestamperData_Reg_Con, TimestamperData_DatReg); // unused
      `Axi_Init_Proc(TimestamperDataWidth_Reg_Con, TimestamperDataWidth_DatReg); // unused
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
        if(((AxiWriteAddrValid_ValIn == 1'b1) && (AxiWriteDataValid_ValIn == 1'b1))) begin
          AxiWriteAddrReady_RdyReg <= 1'b1;
          AxiWriteDataReady_RdyReg <= 1'b1;
          Axi_AccessState_StaReg <= Write_St;
        end else if((AxiReadAddrValid_ValIn == 1'b1)) begin
          AxiReadAddrReady_RdyReg <= 1'b1;
          Axi_AccessState_StaReg <= Read_St;
        end
      end
      Read_St : begin
        if(((AxiReadAddrValid_ValIn == 1'b1) && (AxiReadAddrReady_RdyReg == 1'b1))) begin
          AxiReadDataValid_ValReg <= 1'b1;
          AxiReadDataResponse_DatReg <= Axi_RespSlvErr_Con;
          `Axi_Read_Proc(TimestamperControl_Reg_Con, TimestamperControl_DatReg, AxiReadAddrAddress_AdrIn, AxiReadDataData_DatReg, AxiReadDataResponse_DatReg);
          `Axi_Read_Proc(TimestamperStatus_Reg_Con, TimestamperStatus_DatReg, AxiReadAddrAddress_AdrIn, AxiReadDataData_DatReg, AxiReadDataResponse_DatReg); // unused
          `Axi_Read_Proc(TimestamperPolarity_Reg_Con, TimestamperPolarity_DatReg, AxiReadAddrAddress_AdrIn, AxiReadDataData_DatReg, AxiReadDataResponse_DatReg);
          if((CableDelay_Gen == "true")) begin
            `Axi_Read_Proc(TimestamperCableDelay_Reg_Con, TimestamperCableDelay_DatReg, AxiReadAddrAddress_AdrIn, AxiReadDataData_DatReg, AxiReadDataResponse_DatReg);
          end
          `Axi_Read_Proc(TimestamperVersion_Reg_Con, TimestamperVersion_DatReg, AxiReadAddrAddress_AdrIn, AxiReadDataData_DatReg, AxiReadDataResponse_DatReg);
          `Axi_Read_Proc(TimestamperIrq_Reg_Con, TimestamperIrq_DatReg, AxiReadAddrAddress_AdrIn, AxiReadDataData_DatReg, AxiReadDataResponse_DatReg);
          `Axi_Read_Proc(TimestamperIrqMask_Reg_Con, TimestamperIrqMask_DatReg, AxiReadAddrAddress_AdrIn, AxiReadDataData_DatReg, AxiReadDataResponse_DatReg);
          `Axi_Read_Proc(TimestamperEvtCount_Reg_Con, TimestamperEvtCount_DatReg, AxiReadAddrAddress_AdrIn, AxiReadDataData_DatReg, AxiReadDataResponse_DatReg);
          `Axi_Read_Proc(TimestamperCount_Reg_Con, TimestamperCount_DatReg, AxiReadAddrAddress_AdrIn, AxiReadDataData_DatReg, AxiReadDataResponse_DatReg);
          `Axi_Read_Proc(TimestamperTimeValueL_Reg_Con, TimestamperTimeValueL_DatReg, AxiReadAddrAddress_AdrIn, AxiReadDataData_DatReg, AxiReadDataResponse_DatReg);
          `Axi_Read_Proc(TimestamperTimeValueH_Reg_Con, TimestamperTimeValueH_DatReg, AxiReadAddrAddress_AdrIn, AxiReadDataData_DatReg, AxiReadDataResponse_DatReg);
          `Axi_Read_Proc(TimestamperDataWidth_Reg_Con, TimestamperDataWidth_DatReg, AxiReadAddrAddress_AdrIn, AxiReadDataData_DatReg, AxiReadDataResponse_DatReg); // unused
          `Axi_Read_Proc(TimestamperData_Reg_Con, TimestamperData_DatReg, AxiReadAddrAddress_AdrIn, AxiReadDataData_DatReg, AxiReadDataResponse_DatReg); // unused
          Axi_AccessState_StaReg <= Resp_St;
        end
      end
      Write_St : begin
        if(AxiWriteAddrValid_ValIn == 1'b1 && AxiWriteAddrReady_RdyReg == 1'b1 && AxiWriteDataValid_ValIn == 1'b1 && AxiWriteDataReady_RdyReg == 1'b1) begin
          AxiWriteRespValid_ValReg <= 1'b1;
          AxiWriteRespResponse_DatReg <= Axi_RespSlvErr_Con;
          `Axi_Write_Proc(TimestamperControl_Reg_Con, TimestamperControl_DatReg, AxiWriteAddrAddress_AdrIn, AxiWriteDataData_DatIn, AxiWriteRespResponse_DatReg);
          `Axi_Write_Proc(TimestamperStatus_Reg_Con, TimestamperStatus_DatReg, AxiWriteAddrAddress_AdrIn, AxiWriteDataData_DatIn, AxiWriteRespResponse_DatReg); // unused
          `Axi_Write_Proc(TimestamperPolarity_Reg_Con, TimestamperPolarity_DatReg, AxiWriteAddrAddress_AdrIn, AxiWriteDataData_DatIn, AxiWriteRespResponse_DatReg);
          if(CableDelay_Gen == "true") begin
            `Axi_Write_Proc(TimestamperCableDelay_Reg_Con, TimestamperCableDelay_DatReg, AxiWriteAddrAddress_AdrIn, AxiWriteDataData_DatIn, AxiWriteRespResponse_DatReg);
          end
          `Axi_Write_Proc(TimestamperVersion_Reg_Con, TimestamperVersion_DatReg, AxiWriteAddrAddress_AdrIn, AxiWriteDataData_DatIn, AxiWriteRespResponse_DatReg);
          `Axi_Write_Proc(TimestamperIrq_Reg_Con, TimestamperIrq_DatReg, AxiWriteAddrAddress_AdrIn, AxiWriteDataData_DatIn, AxiWriteRespResponse_DatReg);
          `Axi_Write_Proc(TimestamperIrqMask_Reg_Con, TimestamperIrqMask_DatReg, AxiWriteAddrAddress_AdrIn, AxiWriteDataData_DatIn, AxiWriteRespResponse_DatReg);
          `Axi_Write_Proc(TimestamperEvtCount_Reg_Con, TimestamperEvtCount_DatReg, AxiWriteAddrAddress_AdrIn, AxiWriteDataData_DatIn, AxiWriteRespResponse_DatReg);
          `Axi_Write_Proc(TimestamperCount_Reg_Con, TimestamperCount_DatReg, AxiWriteAddrAddress_AdrIn, AxiWriteDataData_DatIn, AxiWriteRespResponse_DatReg);
          `Axi_Write_Proc(TimestamperTimeValueL_Reg_Con, TimestamperTimeValueL_DatReg, AxiWriteAddrAddress_AdrIn, AxiWriteDataData_DatIn, AxiWriteRespResponse_DatReg);
          `Axi_Write_Proc(TimestamperTimeValueH_Reg_Con, TimestamperTimeValueH_DatReg, AxiWriteAddrAddress_AdrIn, AxiWriteDataData_DatIn, AxiWriteRespResponse_DatReg);
          `Axi_Write_Proc(TimestamperDataWidth_Reg_Con, TimestamperDataWidth_DatReg, AxiWriteAddrAddress_AdrIn, AxiWriteDataData_DatIn, AxiWriteRespResponse_DatReg); // unused
          `Axi_Write_Proc(TimestamperData_Reg_Con, TimestamperData_DatReg, AxiWriteAddrAddress_AdrIn, AxiWriteDataData_DatIn, AxiWriteRespResponse_DatReg); // unused
          Axi_AccessState_StaReg <= Resp_St;
        end
      end
      Resp_St : begin
        if((AxiWriteRespValid_ValReg == 1'b1 && AxiWriteRespReady_RdyIn == 1'b1) || (AxiReadDataValid_ValReg == 1'b1 && AxiReadDataReady_RdyIn == 1'b1)) begin
          Axi_AccessState_StaReg <= Idle_St;
        end
      end
      endcase
      if(CableDelay_Gen == "false") begin
        `Axi_Init_Proc(TimestamperCableDelay_Reg_Con, TimestamperCableDelay_DatReg);
      end
      if(Enable_Ena == 1'b1) begin
        // counter counts all events 
        if(Timestamp_ValReg == 1'b1) begin
          TimestamperEvtCount_DatReg <= TimestamperEvtCount_DatReg + 1;
        end
      end else begin
        TimestamperIrq_DatReg[TimestamperIrq_TimestampBit_Con] <= 1'b0;
        // when disabled we also clear that we had one pending
        TimestamperEvtCount_DatReg <= {32{1'b0}};
        TimestamperCount_DatReg <= {32{1'b0}};
        TimestamperStatus_DatReg[TimestamperStatus_DropBit_Con] <= 1'b0;
      end
      if(Enable_Ena == 1'b1 && TimestamperIrq_DatReg[TimestamperIrq_TimestampBit_Con] == 1'b0 && Timestamp_ValReg == 1'b1) begin
        // counter counts the handled events
        TimestamperIrq_DatReg[TimestamperIrq_TimestampBit_Con] <= 1'b1;
        TimestamperCount_DatReg <= Count_CntReg;
        TimestamperTimeValueL_DatReg <= Timestamp_Nanosecond_DatReg;
        TimestamperTimeValueH_DatReg <= Timestamp_Second_DatReg;
      end else if(Enable_Ena == 1'b1 && TimestamperIrq_DatReg[TimestamperIrq_TimestampBit_Con] == 1'b1 && Timestamp_ValReg == 1'b1) begin
        // we still have a timestamp which was not handled, so we will drop that
        TimestamperStatus_DatReg[TimestamperStatus_DropBit_Con] <= 1'b1;
        // make an event drop sticky
      end
      TimestamperDataWidth_DatReg <= 0; // unused
      TimestamperData_DatReg <= 0; // unused
    end
  end
endmodule
