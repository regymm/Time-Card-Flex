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

// The CoreList initializes a ROM with the core contents of CoreListFile_Gen and         -- 
// provides them to the CPU via an AXI slave. When an invalid core type nr is read       --
// (0x00000000), the CoreListReadCompleted_DatOut is activated                           --

`include "TimeCard_Package.svh"
module CoreList #(
	parameter CoreListBytes_Con = 0,
	parameter RomAddrWidth_Con = 0,
	parameter CoreListFile_Processed = "/dev/null",
    // System clock 50MHz. Clock period in nanoseconds
    parameter [31:0]ClockPeriod_Gen = 20
)(
    // System                   
    input wire SysClk_ClkIn,
    input wire SysRstN_RstIn,
    // Core List Read                   
    output wire CoreListReadCompleted_DatOut,
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
parameter MaxEntries_Con = 2 ** 12;  // change this if you need more than 2**12 entries in the list
parameter AddrWidth_Con = $ceil($clog2(MaxEntries_Con));
parameter TextWordWidth_Con = 9;  // in ascii characters, the text length should be 4 byte aligned   
parameter TextCharWidth_Con = 4 * TextWordWidth_Con;  // in ascii characters, the text length should be 4 byte aligned, up to 36 characters
parameter LineCharWidth_Con = (8 * 7) + 7 + TextCharWidth_Con;  // line length in ascii characters, including the 7 8-digit values, the 7 'space' delimiters and the text  
parameter BytesPerLine_Con = (4 * 7) + TextCharWidth_Con;  // line length in bytes
parameter integer WordsPerLine_Con = $ceil(BytesPerLine_Con/4);
// Core List version    
parameter [7:0]CoreListMajorVersion_Con = 0;
parameter [7:0]CoreListMinorVersion_Con = 1;
parameter [15:0]CoreListBuildVersion_Con = 0;
parameter [31:0]CoreListVersion_Con = {CoreListMajorVersion_Con,CoreListMinorVersion_Con,CoreListBuildVersion_Con};
parameter [0:0]
  ReadWait_St = 0,
  ReadDone_St = 1;

reg CoreListReadCompleted_DatReg; 
// Memory read signals 
reg RomReadState_StaReg;
reg [31:0] RomAddress_AdrReg;
reg [31:0] RomRead_DatReg = 1'b0;
reg [31:0] RomData_Rom [2**RomAddrWidth_Con-1:0];
initial $readmemh(CoreListFile_Processed, RomData_Rom);
// Axi signals
reg [1:0]Axi_AccessState_StaReg = Axi_AccessState_Type_Rst_Con;
reg AxiWriteAddrReady_RdyReg;
reg AxiWriteDataReady_RdyReg;
reg AxiWriteRespValid_ValReg;
reg [1:0] AxiWriteRespResponse_DatReg;
reg AxiReadAddrReady_RdyReg;
reg AxiReadDataValid_ValReg;
reg [1:0] AxiReadDataResponse_DatReg;
reg [31:0] AxiReadDataData_DatReg;
reg AxiReadDone_ValReg; 
  assign AxiWriteAddrReady_RdyOut = AxiWriteAddrReady_RdyReg;
  assign AxiWriteDataReady_RdyOut = AxiWriteDataReady_RdyReg;
  assign AxiWriteRespValid_ValOut = AxiWriteRespValid_ValReg;
  assign AxiWriteRespResponse_DatOut = AxiWriteRespResponse_DatReg;
  assign AxiReadAddrReady_RdyOut = AxiReadAddrReady_RdyReg;
  assign AxiReadDataValid_ValOut = AxiReadDataValid_ValReg;
  assign AxiReadDataResponse_DatOut = AxiReadDataResponse_DatReg;
  assign AxiReadDataData_DatOut = AxiReadDataData_DatReg;
  assign CoreListReadCompleted_DatOut = CoreListReadCompleted_DatReg;

  // Axi slave for accessing the Core List registers 
  // The format of the core list ROM which is provided via AXI is 
  // - each core is described by a set of 64 8-bit registers (512 bits):
  // - the format of each core in bits is:
  //      - ByteAddr[03-00]: 31 - 0  CoreTypeNr(4B) 
  //      - ByteAddr[07-04]: 63 - 32 CoreInstNr(4B)
  //      - ByteAddr[0B-08]: 95 - 64 Version(4B)
  //      - ByteAddr[0F-0C]: 127- 96 AddressRangeLow(4B)
  //      - ByteAddr[13-10]: 159-128 AddressRangeHigh(4B)
  //      - ByteAddr[17-14]: 191-160 InterruptMask(4B) 
  //      - ByteAddr[1B-18]: 223-192 Sensitivity(4B) 
  //      - ByteAddr[3F-1C]: 511-224 Magic word(max 36B of  ascii chars) 
  // Only word-aligned addresses are accessing the ROM 
  always @(posedge SysClk_ClkIn, posedge SysRstN_RstIn) begin
    if(SysRstN_RstIn == 1'b0) begin
      CoreListReadCompleted_DatReg <= 1'b0;
      AxiWriteAddrReady_RdyReg <= 1'b0;
      AxiWriteDataReady_RdyReg <= 1'b0;
      AxiWriteRespValid_ValReg <= 1'b0;
      AxiWriteRespResponse_DatReg <= {2{1'b0}};
      AxiReadAddrReady_RdyReg <= 1'b0;
      AxiReadDataValid_ValReg <= 1'b0;
      AxiReadDataResponse_DatReg <= {2{1'b0}};
      AxiReadDataData_DatReg <= {32{1'b0}};
      Axi_AccessState_StaReg <= Axi_AccessState_Type_Rst_Con;
      AxiReadDone_ValReg <= 1'b0;
      RomAddress_AdrReg <= {((RomAddrWidth_Con - 1)-(0)+1){1'b0}};
      RomReadState_StaReg <= ReadWait_St;
    end else begin
      // just a pulse
      AxiReadDone_ValReg <= 1'b0;
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
        RomReadState_StaReg <= ReadWait_St;
      end
      Read_St : begin
        if(AxiReadAddrValid_ValIn == 1'b1 && AxiReadAddrReady_RdyReg == 1'b1) begin
          if(AxiReadAddrAddress_AdrIn >= (CoreListBytes_Con - 1)) begin
            // larger than the CoreList size (Lines*BytesPerLine)
            AxiReadDataValid_ValReg <= 1'b1;
            AxiReadDataResponse_DatReg <= Axi_RespOk_Con;
            AxiReadDataData_DatReg <= {32{1'b0}};
            Axi_AccessState_StaReg <= Resp_St;
          end else begin
            RomAddress_AdrReg <= AxiReadAddrAddress_AdrIn[(2 + RomAddrWidth_Con) - 1:2];
            // divide the AXI address by 4, to get the ROM address
            RomReadState_StaReg <= ReadWait_St;
          end
        end else begin
          case(RomReadState_StaReg)
          ReadWait_St : begin
            RomReadState_StaReg <= ReadDone_St;
          end
          ReadDone_St : begin
            AxiReadDataValid_ValReg <= 1'b1;
            AxiReadDataResponse_DatReg <= Axi_RespOk_Con;
            AxiReadDataData_DatReg <= RomRead_DatReg;
            Axi_AccessState_StaReg <= Resp_St;
            AxiReadDone_ValReg <= 1'b1;
            RomReadState_StaReg <= ReadWait_St;
          end
          default : begin
            RomReadState_StaReg <= ReadWait_St;
          end
          endcase
        end
      end
      Write_St : begin
        if(AxiWriteAddrValid_ValIn == 1'b1 && AxiWriteAddrReady_RdyReg == 1'b1 && AxiWriteDataValid_ValIn == 1'b1 && AxiWriteDataReady_RdyReg == 1'b1) begin
          AxiWriteRespValid_ValReg <= 1'b1;
          AxiWriteRespResponse_DatReg <= Axi_RespSlvErr_Con;
          Axi_AccessState_StaReg <= Resp_St;
        end
      end
      Resp_St : begin
        if((AxiWriteRespValid_ValReg == 1'b1 && AxiWriteRespReady_RdyIn == 1'b1) || (AxiReadDataValid_ValReg == 1'b1 && AxiReadDataReady_RdyIn == 1'b1)) begin
          Axi_AccessState_StaReg <= Idle_St;
        end
        // if a Core Type '0' is read, assume that the whole list has been read
        if(AxiReadDataData_DatReg == 0 && RomAddress_AdrReg[5:0] == 0 && AxiReadDone_ValReg == 1'b1) begin
          CoreListReadCompleted_DatReg <= 1'b1; // sticky bit
        end
      end
      default : begin
        Axi_AccessState_StaReg <= Idle_St;
      end
      endcase
    end
  end

  // Separate the process to infer a block ram implementation of the Core List memory
  always @(posedge SysClk_ClkIn) begin
    RomRead_DatReg <= RomData_Rom[RomAddress_AdrReg];
  end
endmodule
