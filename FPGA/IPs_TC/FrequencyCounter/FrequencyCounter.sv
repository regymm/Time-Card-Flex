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

// The Frequency Counter measures the frequency of an input signal over a period of time.--
// The counter calculates non-fractional frequencies of range [0 Hz - 10'000'000 Hz]     --
// and it is aligned to the local clock's new second.                                    --
// The core can be configured by an AXI4Light-Slave Register interface.                  --
`include "TimeCard_Package.svh"

module FrequencyCounter#(
//parameter Sim_Gen="false",
parameter OutputPolarity_Gen="true"
)(
// System           
input wire SysClk_ClkIn,
input wire SysRstN_RstIn,
// Time Input           
input wire [SecondWidth_Con - 1:0] ClockTime_Second_DatIn,
input wire [NanosecondWidth_Con - 1:0] ClockTime_Nanosecond_DatIn,
input wire ClockTime_TimeJump_DatIn,
input wire ClockTime_ValIn,
// Frequency input          
input wire Frequency_EvtIn,
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

// Frequency Counter Version
localparam [7:0]FreqCntMajorVersion_Con = 0;
localparam [7:0]FreqCntMinorVersion_Con = 1;
localparam [15:0]FreqCntBuildVersion_Con = 0;
localparam [31:0]FreqCntVersion_Con = {FreqCntMajorVersion_Con,FreqCntMinorVersion_Con,FreqCntBuildVersion_Con}; 
// AXI registers    
//constant FreqCntControl_Reg_Con                 : Axi_Reg_Type:= (x"00000000", x"0000FF01", Rw_E, x"00000100");
//constant FreqCntFrequency_Reg_Con               : Axi_Reg_Type:= (x"00000004", x"E0FFFFFF", Ro_E, x"00000000");
//constant FreqCntPolarity_Reg_Con                : Axi_Reg_Type:= (x"00000008", x"00000001", Rw_E, x"00000000");
//constant FreqCntVersion_Reg_Con                 : Axi_Reg_Type:= (x"0000000C", x"FFFFFFFF", Ro_E, FreqCntVersion_Con);
Axi_Reg_Type FreqCntControl_Reg_Con = '{Addr:32'h0, Mask:32'h0000FF01, RegType:Rw_E, Reset:32'h100};
Axi_Reg_Type FreqCntFrequency_Reg_Con = '{Addr:32'h4, Mask:32'hE0FFFFFF, RegType:Ro_E, Reset:32'h0};
Axi_Reg_Type FreqCntPolarity_Reg_Con = '{Addr:32'h8, Mask:32'h00000001, RegType:Rw_E, Reset:32'h0};
Axi_Reg_Type FreqCntVersion_Reg_Con = '{Addr:32'hC, Mask:32'hFFFFFFFF, RegType:Ro_E, Reset:FreqCntVersion_Con};
localparam FreqCntControl_EnableBit_Con = 0;
localparam FreqCntPolarity_PolarityBit_Con = 0; 

wire Enable_Ena;
wire [7:0] MeasurePeriod_Dat;
reg [63:0] FrequencyCounter_CntReg;
reg [7:0] FrequencyPeriodCounter_CntReg;
reg [7:0] FrequencyTempPeriod_DatReg;
reg [63:0] FrequencyCount_DatReg;
reg [7:0] FrequencyPeriod_DatReg;
reg Frequency_ValReg;
reg Frequency_ValOldReg;
reg [63:0] FrequencyExtend_DatReg;
reg [127:0] FrequencyCountExtend_DatReg;
reg [127:0] FrequencyPeriodExtend_DatReg;
reg CalcFrequency_ValReg;
reg [31:0] CalcStep_CntReg;
reg CalcFrequencyDone_ValReg;
wire Polarity_Dat;  // Time Input           
reg [SecondWidth_Con - 1:0] ClockTime_Second_DatReg;
reg [NanosecondWidth_Con - 1:0] ClockTime_Nanosecond_DatReg;
reg ClockTime_TimeJump_DatReg;
reg ClockTime_ValReg;
reg FrequencySysClk1_EvtReg = 1'b0;
reg FrequencySysClk2_EvtReg = 1'b0;
reg FrequencySysClk3_EvtReg = 1'b0; 
// Axi Signals                                  
reg [1:0]Axi_AccessState_StaReg = Axi_AccessState_Type_Rst_Con;
reg AxiWriteAddrReady_RdyReg;
reg AxiWriteDataReady_RdyReg;
reg AxiWriteRespValid_ValReg;
reg [1:0] AxiWriteRespResponse_DatReg;
reg AxiReadAddrReady_RdyReg;
reg AxiReadDataValid_ValReg;
reg [1:0] AxiReadDataResponse_DatReg;
reg [31:0] AxiReadDataData_DatReg;
reg [31:0] FreqCntControl_DatReg;
reg [31:0] FreqCntFrequency_DatReg;
reg [31:0] FreqCntPolarity_DatReg;
reg [31:0] FreqCntVersion_DatReg; 
  assign Enable_Ena = FreqCntControl_DatReg[FreqCntControl_EnableBit_Con];
  assign MeasurePeriod_Dat = FreqCntControl_DatReg[15:8];
  assign Polarity_Dat = FreqCntPolarity_DatReg[FreqCntPolarity_PolarityBit_Con];
  assign AxiWriteAddrReady_RdyOut = AxiWriteAddrReady_RdyReg;
  assign AxiWriteDataReady_RdyOut = AxiWriteDataReady_RdyReg;
  assign AxiWriteRespValid_ValOut = AxiWriteRespValid_ValReg;
  assign AxiWriteRespResponse_DatOut = AxiWriteRespResponse_DatReg;
  assign AxiReadAddrReady_RdyOut = AxiReadAddrReady_RdyReg;
  assign AxiReadDataValid_ValOut = AxiReadDataValid_ValReg;
  assign AxiReadDataResponse_DatOut = AxiReadDataResponse_DatReg;
  assign AxiReadDataData_DatOut = AxiReadDataData_DatReg;
  // Metastability registers of the input signal
  always @(posedge SysClk_ClkIn) begin
    FrequencySysClk1_EvtReg <= Frequency_EvtIn;
    FrequencySysClk2_EvtReg <= FrequencySysClk1_EvtReg;
    FrequencySysClk3_EvtReg <= FrequencySysClk2_EvtReg;
  end

  // When the core is enabled by configuration and the input time is valid
  // the measurement of the frequency will start at the beginning of the next second.
  // At the rising edge of the input signal, the frequency counter increases 
  // At the beginning of a new second the period counter (i.e. the number of seconds over which the frequency is measured) is updated.
  // When a measurement period has completed, a flag is raised and the measurement starts over.
  wire [63:0]CntRegPlus = ((FrequencySysClk3_EvtReg == 1'b0 && FrequencySysClk2_EvtReg == 1'b1 && Polarity_Dat == 1'b1) || (FrequencySysClk3_EvtReg == 1'b1 && FrequencySysClk2_EvtReg == 1'b0 && Polarity_Dat == 1'b0)) ? FrequencyCounter_CntReg + 1 : FrequencyCounter_CntReg;
  always @(posedge SysClk_ClkIn, posedge SysRstN_RstIn) begin
    if((SysRstN_RstIn == 1'b0)) begin
      ClockTime_Second_DatReg <= {((SecondWidth_Con - 1)-(0)+1){1'b0}};
      ClockTime_Nanosecond_DatReg <= {((NanosecondWidth_Con - 1)-(0)+1){1'b0}};
      ClockTime_TimeJump_DatReg <= 1'b0;
      ClockTime_ValReg <= 1'b0;
      FrequencyCounter_CntReg <= 0;
      FrequencyPeriodCounter_CntReg <= 0;
      FrequencyTempPeriod_DatReg <= {8{1'b0}};
      FrequencyCount_DatReg <= {64{1'b0}};
      FrequencyPeriod_DatReg <= {8{1'b0}};
      Frequency_ValReg <= 1'b0;
    end else begin
      //integer FrequencyCounter_CntVar;
      ClockTime_Second_DatReg <= ClockTime_Second_DatIn;
      ClockTime_Nanosecond_DatReg <= ClockTime_Nanosecond_DatIn;
      ClockTime_TimeJump_DatReg <= ClockTime_TimeJump_DatIn;
      ClockTime_ValReg <= ClockTime_ValIn;
      Frequency_ValReg <= 1'b0;

      //if((FrequencySysClk3_EvtReg == 1'b0 && FrequencySysClk2_EvtReg == 1'b1 && Polarity_Dat == 1'b1) || (FrequencySysClk3_EvtReg == 1'b1 && FrequencySysClk2_EvtReg == 1'b0 && Polarity_Dat == 1'b0))
          //FrequencyCounter_CntVar = FrequencyCounter_CntReg + 1;
      //else FrequencyCounter_CntVar = FrequencyCounter_CntReg;

      if(ClockTime_ValIn == 1'b0 || ClockTime_TimeJump_DatIn == 1'b1) begin
        FrequencyCounter_CntReg <= 0;
        FrequencyPeriodCounter_CntReg <= 0;
      end else if(
          //(Sim_Gen == "true" && (ClockTime_Nanosecond_DatReg % 1000000) > (ClockTime_Nanosecond_DatIn % 1000000)) || (Sim_Gen == "false" &&
          ClockTime_Second_DatReg != ClockTime_Second_DatIn
          //)
          ) begin // at the beginning of a new second, assign the configuration, update the period counter 
        if(FrequencyPeriodCounter_CntReg == 0 || Enable_Ena == 1'b0) begin // not valid
          FrequencyCounter_CntReg <= 0;
          FrequencyPeriodCounter_CntReg <= MeasurePeriod_Dat;
          FrequencyTempPeriod_DatReg <= MeasurePeriod_Dat; // this is needed for the division
        end else if(FrequencyPeriodCounter_CntReg == 1) begin
          if(Enable_Ena == 1'b1) begin
            //if(Sim_Gen == "true") FrequencyCounter_CntVar = FrequencyCounter_CntVar * 1000;
            FrequencyCount_DatReg <= CntRegPlus;
            FrequencyPeriod_DatReg <= FrequencyTempPeriod_DatReg; // this is the one that we had for the current measurement
            Frequency_ValReg <= 1'b1;
          end
          FrequencyCounter_CntReg <= 0;
          FrequencyPeriodCounter_CntReg <= MeasurePeriod_Dat;
          FrequencyTempPeriod_DatReg <= MeasurePeriod_Dat; // this is needed for the division
        end else begin
          FrequencyCounter_CntReg <= CntRegPlus;
          FrequencyPeriodCounter_CntReg <= FrequencyPeriodCounter_CntReg - 1;
        end
      end
      FrequencyCounter_CntReg <= CntRegPlus;
      //FrequencyCounter_CntReg <= FrequencyCounter_CntVar;
    end
  end

  // AXI slave for configuring and supervising the core
  // Enable the core and provide the measurement period
  // Divide the frequency counter by the measurement period and store the result to the register
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
      `Axi_Init_Proc(FreqCntControl_Reg_Con, FreqCntControl_DatReg);
      `Axi_Init_Proc(FreqCntFrequency_Reg_Con, FreqCntFrequency_DatReg);
      `Axi_Init_Proc(FreqCntPolarity_Reg_Con, FreqCntPolarity_DatReg);
      `Axi_Init_Proc(FreqCntVersion_Reg_Con, FreqCntVersion_DatReg);
      if(OutputPolarity_Gen == "true") begin
        FreqCntPolarity_DatReg[FreqCntPolarity_PolarityBit_Con] <= 1'b1;
      end else begin
        FreqCntPolarity_DatReg[FreqCntPolarity_PolarityBit_Con] <= 1'b0;
      end
      CalcFrequency_ValReg <= 1'b0;
      CalcStep_CntReg <= 0;
      Frequency_ValOldReg <= 1'b0;
      FrequencyCountExtend_DatReg <= {128{1'b0}};
      FrequencyPeriodExtend_DatReg <= {128{1'b0}};
      FrequencyExtend_DatReg <= {64{1'b0}};
      CalcFrequencyDone_ValReg <= 1'b0;
    end else begin
      Frequency_ValOldReg <= Frequency_ValReg;
      CalcFrequencyDone_ValReg <= 1'b0;
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
        if((AxiReadAddrValid_ValIn == 1'b1 && AxiReadAddrReady_RdyReg == 1'b1)) begin
          AxiReadDataValid_ValReg <= 1'b1;
          AxiReadDataResponse_DatReg <= Axi_RespSlvErr_Con;
          `Axi_Read_Proc(FreqCntControl_Reg_Con, FreqCntControl_DatReg, AxiReadAddrAddress_AdrIn, AxiReadDataData_DatReg, AxiReadDataResponse_DatReg);
          `Axi_Read_Proc(FreqCntFrequency_Reg_Con, FreqCntFrequency_DatReg, AxiReadAddrAddress_AdrIn, AxiReadDataData_DatReg, AxiReadDataResponse_DatReg);
          `Axi_Read_Proc(FreqCntPolarity_Reg_Con, FreqCntPolarity_DatReg, AxiReadAddrAddress_AdrIn, AxiReadDataData_DatReg, AxiReadDataResponse_DatReg);
          `Axi_Read_Proc(FreqCntVersion_Reg_Con, FreqCntVersion_DatReg, AxiReadAddrAddress_AdrIn, AxiReadDataData_DatReg, AxiReadDataResponse_DatReg);
          Axi_AccessState_StaReg <= Resp_St;
        end
      end
      Write_St : begin
        if(AxiWriteAddrValid_ValIn == 1'b1 && AxiWriteAddrReady_RdyReg == 1'b1 && AxiWriteDataValid_ValIn == 1'b1 && AxiWriteDataReady_RdyReg == 1'b1) begin
          AxiWriteRespValid_ValReg <= 1'b1;
          AxiWriteRespResponse_DatReg <= Axi_RespSlvErr_Con;
          `Axi_Write_Proc(FreqCntControl_Reg_Con, FreqCntControl_DatReg, AxiWriteAddrAddress_AdrIn, AxiWriteDataData_DatIn, AxiWriteRespResponse_DatReg);
          `Axi_Write_Proc(FreqCntFrequency_Reg_Con, FreqCntFrequency_DatReg, AxiWriteAddrAddress_AdrIn, AxiWriteDataData_DatIn, AxiWriteRespResponse_DatReg);
          `Axi_Write_Proc(FreqCntPolarity_Reg_Con, FreqCntPolarity_DatReg, AxiWriteAddrAddress_AdrIn, AxiWriteDataData_DatIn, AxiWriteRespResponse_DatReg);
          `Axi_Write_Proc(FreqCntVersion_Reg_Con, FreqCntVersion_DatReg, AxiWriteAddrAddress_AdrIn, AxiWriteDataData_DatIn, AxiWriteRespResponse_DatReg);
          Axi_AccessState_StaReg <= Resp_St;
        end
      end
      Resp_St : begin
        if(AxiWriteRespValid_ValReg == 1'b1 && AxiWriteRespReady_RdyIn == 1'b1 || AxiReadDataValid_ValReg == 1'b1 && AxiReadDataReady_RdyIn == 1'b1) begin
          Axi_AccessState_StaReg <= Idle_St;
        end
      end
      endcase
      if(Frequency_ValReg == 1'b1 && Frequency_ValOldReg == 1'b0) begin
        FrequencyCountExtend_DatReg[127:64] <= {64{1'b0}};
        FrequencyCountExtend_DatReg[63:0] <= FrequencyCount_DatReg;
        FrequencyPeriodExtend_DatReg[127:64] <= {56'h00000000000000,FrequencyPeriod_DatReg};
        FrequencyPeriodExtend_DatReg[63:0] <= {64{1'b0}};
        FrequencyExtend_DatReg <= {64{1'b0}};
        CalcStep_CntReg <= 63;
        if(FrequencyPeriod_DatReg == 0) begin
          // no division by 0
          FreqCntFrequency_DatReg[31] <= 1'b0;
          FreqCntFrequency_DatReg[30] <= 1'b1;
          FreqCntFrequency_DatReg[29] <= 1'b0;
          FreqCntFrequency_DatReg[23:0] <= {24{1'b0}};
        end else begin
          // only calculate if ok so we know that in case of an error we cleared the reg
          CalcFrequency_ValReg <= 1'b1;
        end
      end else if(CalcFrequency_ValReg == 1'b1) begin
        if({FrequencyCountExtend_DatReg[126:0],1'b0} >= FrequencyPeriodExtend_DatReg) begin
          FrequencyCountExtend_DatReg <= {FrequencyCountExtend_DatReg[126:0],1'b0} - FrequencyPeriodExtend_DatReg;
          FrequencyExtend_DatReg[CalcStep_CntReg] <= 1'b1;
        end else begin
          FrequencyCountExtend_DatReg <= {FrequencyCountExtend_DatReg[126:0],1'b0};
          FrequencyExtend_DatReg[CalcStep_CntReg] <= 1'b0;
        end if(CalcStep_CntReg > 0) begin
          CalcStep_CntReg <= CalcStep_CntReg - 1;
        end else begin
          CalcFrequency_ValReg <= 1'b0;
          CalcFrequencyDone_ValReg <= 1'b1;
        end
      end
      if(CalcFrequencyDone_ValReg == 1'b1) begin
        if(FrequencyExtend_DatReg > 10000000) begin
          FreqCntFrequency_DatReg[31] <= 1'b0;
          FreqCntFrequency_DatReg[30] <= 1'b1;
          // this is also an error
          FreqCntFrequency_DatReg[29] <= 1'b1;
          FreqCntFrequency_DatReg[23:0] <= {24{1'b0}};
        end else begin
          FreqCntFrequency_DatReg[31] <= 1'b1;
          FreqCntFrequency_DatReg[30] <= 1'b0;
          FreqCntFrequency_DatReg[29] <= 1'b0;
          FreqCntFrequency_DatReg[23:0] <= FrequencyExtend_DatReg[23:0];
        end
      end
      if(Enable_Ena == 1'b0) begin
        `Axi_Init_Proc(FreqCntFrequency_Reg_Con, FreqCntFrequency_DatReg);
      end
    end
  end
endmodule
