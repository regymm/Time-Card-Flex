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
// The Clock Detector detects the available clock sources and selects the clocks to be   --
// used. The selection is done with different clock selector and clock enable outputs.   --
// The selection is according to a priority scheme and it can be overwritten via         --
// registers of the AXI slave interface                                                  --
//-----------------------------------------------------------------------------------------
`include "TimeCard_Package.svh"
module ClockDetector #(
parameter [3:0] ClockSelect_Gen=4'b0000,
parameter [1:0] PpsSelect_Gen=2'b00
)(
// System
input wire SysClk_ClkIn,
input wire SysRstN_RstIn,
// Clock Inputs
input wire Mhz10ClkSma_ClkIn,
input wire Mhz10ClkMac_ClkIn,
input wire Mhz10ClkDcxo1_ClkIn,
input wire Mhz10ClkDcxo2_ClkIn,
// Selected Clock output
output wire ClkMux1Select_EnOut,
output wire ClkMux2Select_EnOut,
output wire ClkMux3Select_EnOut,
output wire ClkWiz2Select_EnOut,
output wire ClockRstN_RstOut,
// Config interface to PPS source select
output wire [1:0] PpsSourceSelect_DatOut,
input wire [3:0] PpsSourceAvailable_DatIn,
// axi
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

localparam NumberOfClocks_Con = 4;
// PPS Generator version
localparam [7:0]ClkDetMajorVersion_Con = 0;
localparam [7:0]ClkDetMinorVersion_Con = 1;
localparam [15:0]ClkDetBuildVersion_Con = 0;
localparam [31:0]ClkDetVersion_Con = {ClkDetMajorVersion_Con,ClkDetMinorVersion_Con,ClkDetBuildVersion_Con};
// AXI regs                                                       Addr       , Mask       , RW  , Reset
//constant ClkDetSourceSelected_Reg_Con           : Axi_Reg_Type:= (x"00000000", x"000000FF", Ro_E, x"00000000");
//constant ClkDetSourceSelect_Reg_Con             : Axi_Reg_Type:= (x"00000008", x"000000FF", Rw_E, (x"000000" & ClockSelect_Gen & "00" & PpsSelect_Gen));
//constant ClkDetVersion_Reg_Con                  : Axi_Reg_Type:= (x"00000010", x"FFFFFFFF", Ro_E, ClkDetVersion_Con);
Axi_Reg_Type ClkDetSourceSelected_Reg_Con = '{Addr:32'h0, Mask:32'hFF, RegType:Ro_E, Reset:32'h0};
Axi_Reg_Type ClkDetSourceSelect_Reg_Con = '{Addr:32'h8, Mask:32'hFF, RegType:Rw_E, Reset:{24'h0, ClockSelect_Gen, 2'b0, PpsSelect_Gen}};
Axi_Reg_Type ClkDetVersion_Reg_Con = '{Addr:32'h10, Mask:32'hFFFFFFFF, RegType:Ro_E, Reset:ClkDetVersion_Con};

localparam [1:0]
  Idle_St = 0,
  SelectClk_St = 1,
  CheckClk_St = 2,
  End_St = 3;

wire [NumberOfClocks_Con - 1:0] MhzXClk_ClkIn;
reg [7:0] ClockCounter_DatReg [0:NumberOfClocks_Con-1] = '{default:'0};
reg [15:0] ClockAliveTimeOut_DatReg [0:NumberOfClocks_Con-1] = '{default:'0};
wire [NumberOfClocks_Con - 1:0] MhzSlowClk_Clk;
reg [NumberOfClocks_Con - 1:0] MhzSlowClk_Clk_FF = 1'b0;
reg [NumberOfClocks_Con - 1:0] MhzSlowClk_Clk_FFF = 1'b0;
reg [NumberOfClocks_Con - 1:0] ClockAvailable_Dat = 1'b0;
reg [NumberOfClocks_Con - 1:0] ClkSelected_Dat = 1'b0;
reg [NumberOfClocks_Con - 1:0] ClkSelected_DatReg = 1'b0;
reg [NumberOfClocks_Con - 1:0] ClkManualSelect_DatReg = 1'b0;
reg [7:0] ClockRst_ShiftReg = 1'b0;
reg [1:0] ClockSelection_StateStReg;  // Manual Clock selection
wire [NumberOfClocks_Con - 1:0] ClkManualSelect_Dat; 

// AXI signals and regs
reg Axi_AccessState_StaReg = Axi_AccessState_Type_Rst_Con;
reg AxiWriteAddrReady_RdyReg;
reg AxiWriteDataReady_RdyReg;
reg AxiWriteRespValid_ValReg;
reg [1:0] AxiWriteRespResponse_DatReg;
reg AxiReadAddrReady_RdyReg;
reg AxiReadDataValid_ValReg;
reg [1:0] AxiReadDataResponse_DatReg;
reg [31:0] AxiReadDataData_DatReg;
reg [31:0] ClkDetSourceSelected_DatReg;
reg [31:0] ClkDetSourceSelect_DatReg;
reg [31:0] ClkDetVersion_DatReg;

  // Stretch reset
  assign ClockRstN_RstOut = ClockRst_ShiftReg == 8'h00 ? 1'b1 : 1'b0;
  assign ClkManualSelect_Dat = ClkDetSourceSelect_DatReg[7:4];
  // manual clock selection
  assign PpsSourceSelect_DatOut = ClkDetSourceSelect_DatReg[1:0];
  //forward the source PPS source selection to the output
  //----------------------------------------------------------
  // Selected Clock
  //------------------------Mux1----Mux2----Mux3----Wiz2------
  // Mhz10ClkSma_ClkIn        0       x       0       0
  // Mhz10ClkMac_ClkIn        1       x       0       0
  // Mhz10ClkDcxo1_ClkIn      x       0       1       0
  // Mhz10ClkDcxo2_ClkIn      x       1       1       0
  // Ext                      x       x       x       1
  // PLL Select Logic
  assign ClkMux1Select_EnOut = ClkSelected_Dat[1] == 1'b1 ? 1'b1 : 1'b0;
  assign ClkMux2Select_EnOut = ClkSelected_Dat[3] == 1'b1 ? 1'b1 : 1'b0;
  assign ClkMux3Select_EnOut = ClkSelected_Dat[2] == 1'b1 || ClkSelected_Dat[3] == 1'b1 ? 1'b1 : 1'b0;
  assign ClkWiz2Select_EnOut = ClkSelected_Dat == 4'b0000 ? 1'b1 : 1'b0;
  assign MhzXClk_ClkIn[0] = Mhz10ClkSma_ClkIn;
  assign MhzXClk_ClkIn[1] = Mhz10ClkMac_ClkIn;
  assign MhzXClk_ClkIn[2] = Mhz10ClkDcxo1_ClkIn;
  assign MhzXClk_ClkIn[3] = Mhz10ClkDcxo2_ClkIn;
  // For each clock input create a slow clock (slower frequency by factor 128)
  genvar i;
  generate for (i=0; i <= NumberOfClocks_Con - 1; i = i + 1) begin: SlowClk_Generate
      assign MhzSlowClk_Clk[i] = ClockCounter_DatReg[i][7];
  end
  endgenerate
  // AXI assignements
  assign AxiWriteAddrReady_RdyOut = AxiWriteAddrReady_RdyReg;
  assign AxiWriteDataReady_RdyOut = AxiWriteDataReady_RdyReg;
  assign AxiWriteRespValid_ValOut = AxiWriteRespValid_ValReg;
  assign AxiWriteRespResponse_DatOut = AxiWriteRespResponse_DatReg;
  assign AxiReadAddrReady_RdyOut = AxiReadAddrReady_RdyReg;
  assign AxiReadDataValid_ValOut = AxiReadDataValid_ValReg;
  assign AxiReadDataResponse_DatOut = AxiReadDataResponse_DatReg;
  assign AxiReadDataData_DatOut = AxiReadDataData_DatReg;
  // 8-bit tick counter for each clock
  generate for (i=0; i <= NumberOfClocks_Con - 1; i = i + 1) begin: ClockCounter_Gen
      always @(posedge MhzXClk_ClkIn[i]) begin
        ClockCounter_DatReg[i] <= ClockCounter_DatReg[i] + 1;
      end
  end
  endgenerate
  // For each clock input, check its availability, based on the toggling of its slow clock
  generate for (i=0; i <= NumberOfClocks_Con - 1; i = i + 1) begin: ClockDetect_Gen
      always @(posedge SysClk_ClkIn, posedge SysRstN_RstIn) begin
      if(SysRstN_RstIn == 1'b0) begin
        MhzSlowClk_Clk_FF[i] <= 1'b0;
        MhzSlowClk_Clk_FFF[i] <= 1'b0;
        ClockAliveTimeOut_DatReg[i] <= 0;
        ClockAvailable_Dat[i] <= 1'b0;
      end else begin
        MhzSlowClk_Clk_FF[i] <= MhzSlowClk_Clk[i];
        MhzSlowClk_Clk_FFF[i] <= MhzSlowClk_Clk_FF[i];
        if(MhzSlowClk_Clk_FFF[i] != MhzSlowClk_Clk_FF[i]) begin
          ClockAliveTimeOut_DatReg[i] <= 10000;
          ClockAvailable_Dat[i] <= 1'b1;
        end else if(ClockAliveTimeOut_DatReg[i] > 0)
          ClockAliveTimeOut_DatReg[i] <= ClockAliveTimeOut_DatReg[i] - 1;
        else
          ClockAvailable_Dat[i] <= 1'b0;
      end
    end
  end
  endgenerate
  integer j;
  // Select the clock based on the availability, the default priority and, optionally, on a manual selection
  always @(posedge SysClk_ClkIn, posedge SysRstN_RstIn) begin
    if(SysRstN_RstIn == 1'b0) begin
      ClkSelected_Dat <= {((NumberOfClocks_Con - 1)-(0)+1){1'b0}};
      ClkSelected_DatReg <= {((NumberOfClocks_Con - 1)-(0)+1){1'b0}};
      ClkManualSelect_DatReg <= {((NumberOfClocks_Con - 1)-(0)+1){1'b0}};
      ClockRst_ShiftReg <= {8{1'b0}};
      ClockSelection_StateStReg <= Idle_St;
    end else begin
      ClkSelected_DatReg <= ClkSelected_Dat;
      //Reset after new selection
      if(ClkSelected_DatReg != ClkSelected_Dat)
        ClockRst_ShiftReg <= {ClockRst_ShiftReg[6:0],1'b1};
      else
        ClockRst_ShiftReg <= {ClockRst_ShiftReg[6:0],1'b0};
      case (ClockSelection_StateStReg)
      Idle_St : begin
        // Automatic Selection
        if(ClkManualSelect_Dat == 0) begin
          ClockSelection_StateStReg <= SelectClk_St;
        end else begin
          // Manual Selection
          ClkManualSelect_DatReg <= ClkManualSelect_Dat;
          ClockSelection_StateStReg <= CheckClk_St;
        end
      end
      SelectClk_St : begin
          // TODO
        for (j=0; j <= NumberOfClocks_Con - 1; j = j + 1) begin: for_loop_1
          if(ClockAvailable_Dat[j] == 1'b1) begin
            ClkSelected_Dat <= {((NumberOfClocks_Con - 1)-(0)+1){1'b0}};
            ClkSelected_Dat[j] <= 1'b1;
            disable for_loop_1;
          end
        end: for_loop_1
        ClockSelection_StateStReg <= Idle_St;
      end
      CheckClk_St : begin
        for (j=0; j <= NumberOfClocks_Con - 1; j = j + 1) begin: for_loop_2
          if(ClkManualSelect_DatReg[j] == 1'b1 && ClockAvailable_Dat[j] == 1'b1) begin
            ClkSelected_Dat <= {((NumberOfClocks_Con - 1)-(0)+1){1'b0}};
            ClkSelected_Dat[j] <= 1'b1;
            ClockSelection_StateStReg <= Idle_St;
            disable for_loop_2;
          end else if(ClkManualSelect_DatReg[j] == 1'b1 && ClockAvailable_Dat[j] == 1'b0) begin
            ClockSelection_StateStReg <= SelectClk_St;
            disable for_loop_2;
          end else begin
            ClockSelection_StateStReg <= Idle_St;
          end
        end: for_loop_2
      end
      default : begin
        ClockSelection_StateStReg <= Idle_St;
      end
      endcase
    end
  end

  // Access configuration and monitoring registers via an AXI4L slave
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
      `Axi_Init_Proc(ClkDetSourceSelected_Reg_Con, ClkDetSourceSelected_DatReg);
      `Axi_Init_Proc(ClkDetSourceSelect_Reg_Con, ClkDetSourceSelect_DatReg);
      `Axi_Init_Proc(ClkDetVersion_Reg_Con, ClkDetVersion_DatReg);
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
          `Axi_Read_Proc(ClkDetSourceSelected_Reg_Con, ClkDetSourceSelected_DatReg, AxiReadAddrAddress_AdrIn, AxiReadDataData_DatReg, AxiReadDataResponse_DatReg);
          `Axi_Read_Proc(ClkDetSourceSelect_Reg_Con, ClkDetSourceSelect_DatReg, AxiReadAddrAddress_AdrIn, AxiReadDataData_DatReg, AxiReadDataResponse_DatReg);
          `Axi_Read_Proc(ClkDetVersion_Reg_Con, ClkDetVersion_DatReg, AxiReadAddrAddress_AdrIn, AxiReadDataData_DatReg, AxiReadDataResponse_DatReg);
          Axi_AccessState_StaReg <= Resp_St;
        end
      end
      Write_St : begin
        if((AxiWriteAddrValid_ValIn == 1'b1 && AxiWriteAddrReady_RdyReg == 1'b1) && (AxiWriteDataValid_ValIn == 1'b1 && AxiWriteDataReady_RdyReg == 1'b1)) begin
          AxiWriteRespValid_ValReg <= 1'b1;
          AxiWriteRespResponse_DatReg <= Axi_RespSlvErr_Con;
          `Axi_Write_Proc(ClkDetSourceSelected_Reg_Con, ClkDetSourceSelected_DatReg, AxiWriteAddrAddress_AdrIn, AxiWriteDataData_DatIn, AxiWriteRespResponse_DatReg);
          `Axi_Write_Proc(ClkDetSourceSelect_Reg_Con, ClkDetSourceSelect_DatReg, AxiWriteAddrAddress_AdrIn, AxiWriteDataData_DatIn, AxiWriteRespResponse_DatReg);
          `Axi_Write_Proc(ClkDetVersion_Reg_Con, ClkDetVersion_DatReg, AxiWriteAddrAddress_AdrIn, AxiWriteDataData_DatIn, AxiWriteRespResponse_DatReg);
          Axi_AccessState_StaReg <= Resp_St;
        end
      end
      Resp_St : begin
        if((AxiWriteRespValid_ValReg == 1'b1 && AxiWriteRespReady_RdyIn == 1'b1) || (AxiReadDataValid_ValReg == 1'b1 && AxiReadDataReady_RdyIn == 1'b1)) begin
          Axi_AccessState_StaReg <= Idle_St;
        end
      end
      default : begin
      end
      endcase
      ClkDetSourceSelected_DatReg[7:4] <= ClkSelected_Dat; // report the selected clock
      ClkDetSourceSelected_DatReg[3:0] <= PpsSourceAvailable_DatIn; // receive the available PPS sources externally
    end
  end
endmodule
