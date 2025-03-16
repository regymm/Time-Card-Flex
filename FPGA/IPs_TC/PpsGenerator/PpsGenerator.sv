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

// The PPS Generator generates a Pulse Per Second (PPS) aligned to the local clock's     --
// new second. The local clock is provided as input. The core can be configured by an    --
// AXI4Light-Slave Register interface. A high resolution clock is used for the pulse     --
// generation to reduce the jitter.                                                      --
`include "TimeCard_Package.svh"

module PpsGenerator #(
parameter [31:0] ClockPeriod_Gen=20,
parameter CableDelay_Gen="false",
parameter [31:0] OutputDelay_Gen=0,
parameter OutputPolarity_Gen="true",
parameter [31:0] HighResFreqMultiply_Gen=5,
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
// Pps Output                       
output reg Pps_EvtOut,
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
// High resolution constants
parameter HighResClockPeriod_Con = ClockPeriod_Gen / HighResFreqMultiply_Gen;
parameter RegOutputDelay_Con = (3 * ClockPeriod_Gen) + HighResClockPeriod_Con; 
// The total output delay consists of 
//     - the configurable output delay compensation(generic input), due to output registers
//     - the cable delay compensation, provided by AXI reg, if enabled by the generic input
//     - the internal register delay compensation for the clock domain crossing
parameter OutputDelaySum_Con = OutputDelay_Gen + (ClockPeriod_Gen / 2) + RegOutputDelay_Con;
parameter OutputPulseWidthMillsecond_Con = 500; 
// PPS Generator version
parameter [7:0]PpsGenMajorVersion_Con = 0;
parameter [7:0]PpsGenMinorVersion_Con = 1;
parameter [16:0]PpsGenBuildVersion_Con = 0;
parameter [31:0]PpsGenVersion_Con = {PpsGenMajorVersion_Con,PpsGenMinorVersion_Con,PpsGenBuildVersion_Con}; 
// AXI regs                                                       Addr       , Mask       , RW  , Reset
//constant PpsGenControl_Reg_Con                  : Axi_Reg_Type:= (x"00000000", x"00000001", Rw_E, x"00000000");
Axi_Reg_Type PpsGenControl_Reg_Con                  = '{Addr:32'h00000000, Mask:32'h00000001, RegType:Rw_E, Reset:32'h00000000};
//constant PpsGenStatus_Reg_Con                   : Axi_Reg_Type:= (x"00000004", x"00000001", Wc_E, x"00000000");
Axi_Reg_Type PpsGenStatus_Reg_Con                   = '{Addr:32'h00000004, Mask:32'h00000001, RegType:Wc_E, Reset:32'h00000000};
//constant PpsGenPolarity_Reg_Con                 : Axi_Reg_Type:= (x"00000008", x"00000001", Rw_E, x"00000000");
Axi_Reg_Type PpsGenPolarity_Reg_Con                 = '{Addr:32'h00000008, Mask:32'h00000001, RegType:Rw_E, Reset:32'h00000000};
//constant PpsGenVersion_Reg_Con                  : Axi_Reg_Type:= (x"0000000C", x"FFFFFFFF", Ro_E, PpsGenVersion_Con);
Axi_Reg_Type PpsGenVersion_Reg_Con                  = '{Addr:32'h0000000C, Mask:32'hFFFFFFFF, RegType:Ro_E, Reset:PpsGenVersion_Con};
//constant PpsGenPulseWidth_Reg_Con               : Axi_Reg_Type:= (x"00000010", x"000003FF", Rw_E, x"00000000"); -- unused
Axi_Reg_Type PpsGenPulseWidth_Reg_Con               = '{Addr:32'h00000010, Mask:32'h000003FF, RegType:Rw_E, Reset:32'h00000000}; // unused
//constant PpsGenCableDelay_Reg_Con               : Axi_Reg_Type:= (x"00000020", x"0000FFFF", Rw_E, x"00000000");
Axi_Reg_Type PpsGenCableDelay_Reg_Con               = '{Addr:32'h00000020, Mask:32'h0000FFFF, RegType:Rw_E, Reset:32'h00000000};
parameter PpsGenControl_EnableBit_Con = 0;
parameter PpsGenStatus_ErrorBit_Con = 0;
parameter PpsGenPolarity_PolarityBit_Con = 0;

wire Enable_Ena;
wire Polarity_Dat;
wire [9:0] PulseWidth_Dat;
wire [15:0] CableDelay_Dat; 
// Time Input           
reg [SecondWidth_Con - 1:0] ClockTime_Second_DatReg;
reg [NanosecondWidth_Con - 1:0] ClockTime_Nanosecond_DatReg;
reg ClockTime_TimeJump_DatReg;
reg ClockTime_ValReg; 
// count the high resolution ticks
reg [HighResFreqMultiply_Gen - 1:0] PpsShiftSysClk_DatReg;
reg [HighResFreqMultiply_Gen - 1:0] PpsShiftSysClk1_DatReg = 1'b0;
reg [(HighResFreqMultiply_Gen * 2) - 1:0] PpsShiftSysClkNx_DatReg = 1'b0;
reg PpsError_Reg;
reg Pps_Reg;
reg [31:0] PulseWidthCounter_CntReg; 
// AXI signals and regs
reg [1:0]Axi_AccessState_StaReg = Axi_AccessState_Type_Rst_Con;
reg AxiWriteAddrReady_RdyReg;
reg AxiWriteDataReady_RdyReg;
reg AxiWriteRespValid_ValReg;
reg [1:0] AxiWriteRespResponse_DatReg;
reg AxiReadAddrReady_RdyReg;
reg AxiReadDataValid_ValReg;
reg [1:0] AxiReadDataResponse_DatReg;
reg [31:0] AxiReadDataData_DatReg;
reg [31:0] PpsGenControl_DatReg;
reg [31:0] PpsGenPolarity_DatReg;
reg [31:0] PpsGenStatus_DatReg;
reg [31:0] PpsGenVersion_DatReg;
reg [31:0] PpsGenPulseWidth_DatReg;  // unused
reg [31:0] PpsGenCableDelay_DatReg; 
  assign AxiWriteAddrReady_RdyOut = AxiWriteAddrReady_RdyReg;
  assign AxiWriteDataReady_RdyOut = AxiWriteDataReady_RdyReg;
  assign AxiWriteRespValid_ValOut = AxiWriteRespValid_ValReg;
  assign AxiWriteRespResponse_DatOut = AxiWriteRespResponse_DatReg;
  assign AxiReadAddrReady_RdyOut = AxiReadAddrReady_RdyReg;
  assign AxiReadDataValid_ValOut = AxiReadDataValid_ValReg;
  assign AxiReadDataResponse_DatOut = AxiReadDataResponse_DatReg;
  assign AxiReadDataData_DatOut = AxiReadDataData_DatReg;
  assign Polarity_Dat = PpsGenPolarity_DatReg[PpsGenPolarity_PolarityBit_Con];
  assign Enable_Ena = PpsGenControl_DatReg[PpsGenControl_EnableBit_Con];
  assign PulseWidth_Dat = PpsGenPulseWidth_DatReg[9:0];
  assign CableDelay_Dat = PpsGenCableDelay_DatReg[15:0];
  // Pulse generation on the clock domain of the high frequency clock
  always @(posedge SysClkNx_ClkIn) begin
    PpsShiftSysClk1_DatReg <= PpsShiftSysClk_DatReg;
    if(PpsShiftSysClk_DatReg != PpsShiftSysClk1_DatReg) begin
      PpsShiftSysClkNx_DatReg <= {PpsShiftSysClkNx_DatReg[(HighResFreqMultiply_Gen * 2) - 2:HighResFreqMultiply_Gen - 1],PpsShiftSysClk_DatReg}; // copy the high resolution clock periods
    end else begin
      PpsShiftSysClkNx_DatReg <= {PpsShiftSysClkNx_DatReg[(HighResFreqMultiply_Gen * 2) - 2:0],PpsShiftSysClkNx_DatReg[0]}; // retain the last value
    end if(Polarity_Dat == 1'b1) begin
      Pps_EvtOut <= PpsShiftSysClkNx_DatReg[(HighResFreqMultiply_Gen * 2) - 1];
    end else begin
      Pps_EvtOut <=  ~PpsShiftSysClkNx_DatReg[(HighResFreqMultiply_Gen * 2) - 1];
    end
  end

  // The process sets the activation and deactivation of the PPS, based on the system
  // clock. It also marks the pulse-activation in a shift register, which will
  // be later used by the high-resolution clock to set a motre accurate activation time.
  // The deactivation of the pulse is calculated by a free-running counter (i.e. not aligned 
  // to the local time).
  always @(posedge SysClk_ClkIn, posedge SysRstN_RstIn) begin
    if(SysRstN_RstIn == 1'b0) begin
      PpsError_Reg <= 1'b0;
      Pps_Reg <= 1'b0;
      PpsShiftSysClk_DatReg <= {((HighResFreqMultiply_Gen - 1)-0+1){1'b0}};
      ClockTime_Second_DatReg <= {((SecondWidth_Con - 1)-0+1){1'b0}};
      ClockTime_Nanosecond_DatReg <= {((NanosecondWidth_Con - 1)-0+1){1'b0}};
      ClockTime_TimeJump_DatReg <= 1'b0;
      ClockTime_ValReg <= 1'b0;
      PulseWidthCounter_CntReg <= 0;
    end else begin
      ClockTime_TimeJump_DatReg <= ClockTime_TimeJump_DatIn;
      ClockTime_ValReg <= ClockTime_ValIn;
      if(CableDelay_Gen == "false") begin
        ClockTime_Second_DatReg <= ClockTime_Second_DatIn;
        ClockTime_Nanosecond_DatReg <= ClockTime_Nanosecond_DatIn;
      end else begin
        if(ClockTime_Nanosecond_DatIn + CableDelay_Dat < SecondNanoseconds_Con) begin
          ClockTime_Second_DatReg <= ClockTime_Second_DatIn;
          ClockTime_Nanosecond_DatReg <= ClockTime_Nanosecond_DatIn + CableDelay_Dat;
        end else begin
          ClockTime_Second_DatReg <= ClockTime_Second_DatIn + 1;
          ClockTime_Nanosecond_DatReg <= ClockTime_Nanosecond_DatIn + CableDelay_Dat - SecondNanoseconds_Con;
        end
      end
      if(Enable_Ena == 1'b1) begin
        if(ClockTime_ValReg == 1'b0 || ClockTime_TimeJump_DatReg == 1'b1) begin
          // do nothing, this may cause a loss of a PPS. If overflow happens, better than a wrong PPS          
          PpsError_Reg <= 1'b1;
        end else begin
          // the pulse activation time is when a new second starts minus the total output delay
          if(Pps_Reg == 1'b0 && ((Sim_Gen == "true" && ((ClockTime_Nanosecond_DatReg % (SecondNanoseconds_Con / (1000 * 10))) >= ((SecondNanoseconds_Con / (1000 * 10)) - OutputDelaySum_Con))) || (Sim_Gen == "false" && (ClockTime_Nanosecond_DatReg >= (SecondNanoseconds_Con - OutputDelaySum_Con))))) begin
            // overflow in first half
            PpsError_Reg <= 1'b0;
            // clear the error on the next PPS
            Pps_Reg <= 1'b1;
            // this we need to do the edge detection
            PpsShiftSysClk_DatReg <= {((HighResFreqMultiply_Gen - 1)-0+1){1'b0}};
            // Mark in a shift-register how many high-resolution clock periods 'fit' between the current time and the compensated pulse-activation time.                         
            for (i=0; i <= HighResFreqMultiply_Gen - 1; i = i + 1) begin
              if(Sim_Gen == "true") begin
                if((ClockTime_Nanosecond_DatReg % (SecondNanoseconds_Con / (1000 * 10))) >= ((SecondNanoseconds_Con / (1000 * 10)) - OutputDelaySum_Con + i * HighResClockPeriod_Con)) begin
                  PpsShiftSysClk_DatReg[i] <= 1'b1;
                end
              end else begin
                if(ClockTime_Nanosecond_DatReg >= (SecondNanoseconds_Con - OutputDelaySum_Con + i * HighResClockPeriod_Con)) begin
                  PpsShiftSysClk_DatReg[i] <= 1'b1;
                end
              end
            end if(Sim_Gen == "true") begin
              PulseWidthCounter_CntReg <= PulseWidth_Dat * (SecondNanoseconds_Con / 1000) / (1000 * 10);
            end else begin
              PulseWidthCounter_CntReg <= PulseWidth_Dat * (SecondNanoseconds_Con / 1000);
            end
            // the pulse deactivation time is when a free-running counter counts down to 0
          end else begin
            if(Pps_Reg == 1'b1) begin
              PpsShiftSysClk_DatReg <= {((HighResFreqMultiply_Gen - 1)-0+1){1'b1}};
              // now set the level
            end if(PulseWidthCounter_CntReg > ClockPeriod_Gen) begin
              // pulse done (not aligned with the input clock)
              PulseWidthCounter_CntReg <= PulseWidthCounter_CntReg - ClockPeriod_Gen;
            end else begin
              Pps_Reg <= 1'b0;
              PpsShiftSysClk_DatReg <= {((HighResFreqMultiply_Gen - 1)-0+1){1'b0}};
            end
          end
        end
      end else begin
        Pps_Reg <= 1'b0;
        PpsShiftSysClk_DatReg <= {((HighResFreqMultiply_Gen - 1)-0+1){1'b0}};
        if(Sim_Gen == "true") begin
          PulseWidthCounter_CntReg <= (PulseWidth_Dat) / (1000 * 10);
        end else begin
          PulseWidthCounter_CntReg <= PulseWidth_Dat;
        end
      end
    end
  end

  // Access configuration and monitoring registers via an AXI4L slave
  //variable TempAddress                            : std_logic_vector(31 downto 0) := (others => '0');    
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
      `Axi_Init_Proc(PpsGenControl_Reg_Con, PpsGenControl_DatReg);
      `Axi_Init_Proc(PpsGenStatus_Reg_Con, PpsGenStatus_DatReg);
      `Axi_Init_Proc(PpsGenPolarity_Reg_Con, PpsGenPolarity_DatReg);
      `Axi_Init_Proc(PpsGenVersion_Reg_Con, PpsGenVersion_DatReg);
      `Axi_Init_Proc(PpsGenPulseWidth_Reg_Con, PpsGenPulseWidth_DatReg); // unused
      `Axi_Init_Proc(PpsGenCableDelay_Reg_Con, PpsGenCableDelay_DatReg);
      if(OutputPolarity_Gen == "true")
        PpsGenPolarity_DatReg[PpsGenPolarity_PolarityBit_Con] <= 1'b1;
      else
        PpsGenPolarity_DatReg[PpsGenPolarity_PolarityBit_Con] <= 1'b0;
      PpsGenPulseWidth_DatReg[9:0] <= OutputPulseWidthMillsecond_Con;
      // overwrite with constant
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
        end
        else if(AxiReadAddrValid_ValIn == 1'b1) begin
          AxiReadAddrReady_RdyReg <= 1'b1;
          Axi_AccessState_StaReg <= Read_St;
        end
      end
      Read_St : begin
        if(AxiReadAddrValid_ValIn == 1'b1 && AxiReadAddrReady_RdyReg == 1'b1) begin
          AxiReadDataValid_ValReg <= 1'b1;
          AxiReadDataResponse_DatReg <= Axi_RespSlvErr_Con;
          `Axi_Read_Proc(PpsGenControl_Reg_Con, PpsGenControl_DatReg, AxiReadAddrAddress_AdrIn, AxiReadDataData_DatReg, AxiReadDataResponse_DatReg);
          `Axi_Read_Proc(PpsGenStatus_Reg_Con, PpsGenStatus_DatReg, AxiReadAddrAddress_AdrIn, AxiReadDataData_DatReg, AxiReadDataResponse_DatReg);
          `Axi_Read_Proc(PpsGenPolarity_Reg_Con, PpsGenPolarity_DatReg, AxiReadAddrAddress_AdrIn, AxiReadDataData_DatReg, AxiReadDataResponse_DatReg);
          `Axi_Read_Proc(PpsGenVersion_Reg_Con, PpsGenVersion_DatReg, AxiReadAddrAddress_AdrIn, AxiReadDataData_DatReg, AxiReadDataResponse_DatReg);
          `Axi_Read_Proc(PpsGenPulseWidth_Reg_Con, PpsGenPulseWidth_DatReg, AxiReadAddrAddress_AdrIn, AxiReadDataData_DatReg, AxiReadDataResponse_DatReg); // unused
          if(CableDelay_Gen == "true") begin
            `Axi_Read_Proc(PpsGenCableDelay_Reg_Con, PpsGenCableDelay_DatReg, AxiReadAddrAddress_AdrIn, AxiReadDataData_DatReg, AxiReadDataResponse_DatReg);
          end
          Axi_AccessState_StaReg <= Resp_St;
        end
      end
      Write_St : begin
        if(AxiWriteAddrValid_ValIn == 1'b1 && AxiWriteAddrReady_RdyReg == 1'b1 && AxiWriteDataValid_ValIn == 1'b1 && AxiWriteDataReady_RdyReg == 1'b1) begin
          AxiWriteRespValid_ValReg <= 1'b1;
          AxiWriteRespResponse_DatReg <= Axi_RespSlvErr_Con;
          `Axi_Write_Proc(PpsGenControl_Reg_Con, PpsGenControl_DatReg, AxiWriteAddrAddress_AdrIn, AxiWriteDataData_DatIn, AxiWriteRespResponse_DatReg);
          `Axi_Write_Proc(PpsGenStatus_Reg_Con, PpsGenStatus_DatReg, AxiWriteAddrAddress_AdrIn, AxiWriteDataData_DatIn, AxiWriteRespResponse_DatReg);
          `Axi_Write_Proc(PpsGenPolarity_Reg_Con, PpsGenPolarity_DatReg, AxiWriteAddrAddress_AdrIn, AxiWriteDataData_DatIn, AxiWriteRespResponse_DatReg);
          `Axi_Write_Proc(PpsGenVersion_Reg_Con, PpsGenVersion_DatReg, AxiWriteAddrAddress_AdrIn, AxiWriteDataData_DatIn, AxiWriteRespResponse_DatReg);
          `Axi_Write_Proc(PpsGenPulseWidth_Reg_Con, PpsGenPulseWidth_DatReg, AxiWriteAddrAddress_AdrIn, AxiWriteDataData_DatIn, AxiWriteRespResponse_DatReg); // unused
          if(CableDelay_Gen == "true") begin
            `Axi_Write_Proc(PpsGenCableDelay_Reg_Con, PpsGenCableDelay_DatReg, AxiWriteAddrAddress_AdrIn, AxiWriteDataData_DatIn, AxiWriteRespResponse_DatReg);
          end
          Axi_AccessState_StaReg <= Resp_St;
        end
      end
      Resp_St : begin
        if((((AxiWriteRespValid_ValReg == 1'b1) && (AxiWriteRespReady_RdyIn == 1'b1)) || ((AxiReadDataValid_ValReg == 1'b1) && (AxiReadDataReady_RdyIn == 1'b1))))
          Axi_AccessState_StaReg <= Idle_St;
      end
      endcase
      if(PpsGenControl_DatReg[PpsGenControl_EnableBit_Con] == 1'b1) begin
        if(PpsError_Reg == 1'b1) // make it sticky
          PpsGenStatus_DatReg[PpsGenStatus_ErrorBit_Con] <= 1'b1;
      end else
        PpsGenStatus_DatReg[PpsGenStatus_ErrorBit_Con] <= 1'b0;

      PpsGenPulseWidth_DatReg[9:0] <= OutputPulseWidthMillsecond_Con;
      // overwrite with generic
      if(CableDelay_Gen == "false") begin
        `Axi_Init_Proc(PpsGenCableDelay_Reg_Con, PpsGenCableDelay_DatReg);
      end
    end
  end
endmodule
