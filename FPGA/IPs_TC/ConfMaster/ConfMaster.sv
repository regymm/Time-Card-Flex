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

// The ConfMaster initializes a ROM with the contents of file ConfigFile_Gen. The        -- 
// contents are commands for accessing the AXI registers of the other cores.             --
// A basic configuration of the design's cores can be applied.                           --
// When all the commands have been processed, the ConfigDone_ValOut is activated.        --
`include "TimeCard_Package.svh"

module ConfMaster#(
parameter ConfigListSize = 0,
parameter RomAddrWidth_Con = 0,
parameter [31:0] AxiTimeout_Gen=0,
parameter ConfigFile_Processed="/dev/null",
parameter [31:0] ClockPeriod_Gen=20
)(
// System clock 50MHz. Clock period in nanoseconds
input wire SysClk_ClkIn,
input wire SysRstN_RstIn,
// Configuration Output             
output reg ConfigDone_ValOut,
// Axi              
output wire AxiWriteAddrValid_ValOut,
input wire AxiWriteAddrReady_RdyIn,
output wire [31:0] AxiWriteAddrAddress_AdrOut,
output wire [2:0] AxiWriteAddrProt_DatOut,
output wire AxiWriteDataValid_ValOut,
input wire AxiWriteDataReady_RdyIn,
output wire [31:0] AxiWriteDataData_DatOut,
output wire [3:0] AxiWriteDataStrobe_DatOut,
input wire AxiWriteRespValid_ValIn,
output wire AxiWriteRespReady_RdyOut,
input wire [1:0] AxiWriteRespResponse_DatIn,
output wire AxiReadAddrValid_ValOut,
input wire AxiReadAddrReady_RdyIn,
output wire [31:0] AxiReadAddrAddress_AdrOut,
output wire [2:0] AxiReadAddrProt_DatOut,
input wire AxiReadDataValid_ValIn,
output wire AxiReadDataReady_RdyOut,
input wire [1:0] AxiReadDataResponse_DatIn,
input wire [31:0] AxiReadDataData_DatIn
);
import timecard_package::*;

parameter MaxEntries_Con = 2 ** 12;  // change this if you need more than 2**12 entries in the list

parameter [2:0]
  Unknown_E = 0,
  Skip_E = 1,
  Wait_E = 2,
  Read_E = 3,
  Write_E = 4;

parameter [3:0]
  Idle_St = 0,
  WaitConfig_St = 1,
  FetchConfig_St = 2,
  Skip_St = 3,
  Wait_St = 4,
  StartReadWrite_St = 5,
  WaitToRead_St = 6,
  WaitToWrite_St = 7,
  End_St = 8;

// ROM
wire [31:0] RomAddress_AdrReg;
reg [127:0] RomRead_DatReg = 1'b0; 
reg [127:0] RomData_Rom [2**RomAddrWidth_Con - 1:0];
initial $readmemh(ConfigFile_Processed, RomData_Rom);
// TODO
//signal RomData_Rom                              : Rom_Type(((2**RomAddrWidth_Con)-1) downto 0) := MemoryConfigList_Con.ConfigListData(((2**RomAddrWidth_Con)-1) downto 0);
// to enforce usage of a Ramblock
//attribute ram_style                             : string;
//attribute ram_style                             : string;
//attribute ram_style of RomData_Rom              : signal is "block";
// control ROM read
reg [31:0] ConfigIndex_CntReg;
reg [3:0] ConfigState_StaReg;
reg [2:0] ConfigCommand_DatReg;
reg [31:0] ConfigBaseAddr_DatReg;
reg [31:0] ConfigRegAddr_DatReg;
reg [31:0] ConfigData_DatReg; 
// Axi info
reg [31:0] AxiTimeout_CntReg;
reg [31:0] AxiReadData_DatReg;  // unused
reg [2:0] AxiResponse_DatReg;  // unused
// Axi
reg AxiWriteAddrValid_ValReg;
reg [31:0] AxiWriteAddrAddress_AdrReg;
reg [2:0] AxiWriteAddrProt_DatReg;
reg AxiWriteDataValid_ValReg;
reg [31:0] AxiWriteDataData_DatReg;
reg [3:0] AxiWriteDataStrobe_DatReg;
reg AxiWriteRespReady_RdyReg;
reg AxiReadAddrValid_ValReg;
reg [31:0] AxiReadAddrAddress_AdrReg;
reg [2:0] AxiReadAddrProt_DatReg;
reg AxiReadDataReady_RdyReg; 

  assign AxiWriteAddrValid_ValOut = AxiWriteAddrValid_ValReg;
  assign AxiWriteAddrAddress_AdrOut = AxiWriteAddrAddress_AdrReg;
  assign AxiWriteAddrProt_DatOut = AxiWriteAddrProt_DatReg;
  assign AxiWriteDataValid_ValOut = AxiWriteDataValid_ValReg;
  assign AxiWriteDataData_DatOut = AxiWriteDataData_DatReg;
  assign AxiWriteDataStrobe_DatOut = AxiWriteDataStrobe_DatReg;
  assign AxiWriteRespReady_RdyOut = AxiWriteRespReady_RdyReg;
  assign AxiReadAddrValid_ValOut = AxiReadAddrValid_ValReg;
  assign AxiReadAddrAddress_AdrOut = AxiReadAddrAddress_AdrReg;
  assign AxiReadAddrProt_DatOut = AxiReadAddrProt_DatReg;
  assign AxiReadDataReady_RdyOut = AxiReadDataReady_RdyReg;
  // this is done this way to have no warning of truncation if the ConfigIndex reaches exactly 2**RomAddrWidth_Con
  // e.g. we have 4 entries, the address is 0 to 3 then, but after all of them are handled ConfigIndex_CntReg will be 4
  //         since it counts the number entries handled as well as being the index before increment that and
  //         entry has been handled
  assign RomAddress_AdrReg = ConfigIndex_CntReg;
  //*************************************************************************************
  // Procedural Statements
  //*************************************************************************************
  // Axi master for accessing the design's cores registers or waiting for time in ns
  // The commands are stored in a Rom. Each address stores 128 bits of data:
  // Bits  31 - 0 : Command type (0/1/>4 = Skip, 2 = Wait, 3 = Read, 4 = Write)
  // Bits  63 - 32: Base Address (for read/write commands, else 0)
  // Bits  95 - 64: Reg Address (for read/write commands, else 0)
  // Bits 127 - 96: Data (for write command) or time (in ns, for wait command)
  always @(posedge SysClk_ClkIn, negedge SysRstN_RstIn) begin
    if(SysRstN_RstIn == 1'b0) begin
      ConfigState_StaReg <= Idle_St;
      ConfigIndex_CntReg <= 0;
      ConfigCommand_DatReg <= Unknown_E;
      ConfigBaseAddr_DatReg <= {32{1'b0}};
      ConfigRegAddr_DatReg <= {32{1'b0}};
      ConfigData_DatReg <= {32{1'b0}};
      AxiReadData_DatReg <= {32{1'b0}};
      AxiResponse_DatReg <= {3{1'b0}};
      AxiWriteAddrValid_ValReg <= 1'b0;
      AxiWriteAddrAddress_AdrReg <= {32{1'b0}};
      AxiWriteAddrProt_DatReg <= {3{1'b0}};
      AxiWriteDataValid_ValReg <= 1'b0;
      AxiWriteDataData_DatReg <= {32{1'b0}};
      AxiWriteDataStrobe_DatReg <= {4{1'b0}};
      AxiWriteRespReady_RdyReg <= 1'b0;
      AxiReadAddrValid_ValReg <= 1'b0;
      AxiReadAddrAddress_AdrReg <= {32{1'b0}};
      AxiReadAddrProt_DatReg <= {3{1'b0}};
      AxiReadDataReady_RdyReg <= 1'b0;
      AxiTimeout_CntReg <= 0;
      ConfigDone_ValOut <= 1'b0;
    end else begin
      ConfigDone_ValOut <= 1'b0;
      if(AxiWriteAddrValid_ValReg == 1'b1 && AxiWriteAddrReady_RdyIn == 1'b1) 
        AxiWriteAddrValid_ValReg <= 1'b0;
      
      if(AxiWriteDataValid_ValReg == 1'b1 && AxiWriteDataReady_RdyIn == 1'b1) 
        AxiWriteDataValid_ValReg <= 1'b0;
      
      if(AxiWriteRespValid_ValIn == 1'b1 && AxiWriteRespReady_RdyReg == 1'b1) 
        AxiWriteRespReady_RdyReg <= 1'b0;
      
      if(AxiReadAddrValid_ValReg == 1'b1 && AxiReadAddrReady_RdyIn == 1'b1) 
        AxiReadAddrValid_ValReg <= 1'b0;
      
      if(AxiReadDataValid_ValIn == 1'b1 && AxiReadDataReady_RdyReg == 1'b1) 
        AxiReadDataReady_RdyReg <= 1'b0;
      
      case(ConfigState_StaReg)
      Idle_St : begin
        if(ConfigIndex_CntReg < ConfigListSize) begin
          ConfigState_StaReg <= WaitConfig_St;
          // make sure that data is valid independent of the state we were
        end else begin
          ConfigState_StaReg <= End_St;
        end
      end
      WaitConfig_St : begin
        ConfigState_StaReg <= FetchConfig_St;
      end
      FetchConfig_St : begin
        case(RomRead_DatReg[31:0])
        1 : begin
          ConfigCommand_DatReg <= Skip_E;
          ConfigState_StaReg <= Skip_St;
        end
        2 : begin
          ConfigCommand_DatReg <= Wait_E;
          ConfigState_StaReg <= Wait_St;
        end
        3 : begin
          ConfigCommand_DatReg <= Read_E;
          ConfigState_StaReg <= StartReadWrite_St;
        end
        4 : begin
          ConfigCommand_DatReg <= Write_E;
          ConfigState_StaReg <= StartReadWrite_St;
        end
        default : begin
          ConfigCommand_DatReg <= Unknown_E;
          ConfigState_StaReg <= Skip_St;
        end
        endcase
        ConfigBaseAddr_DatReg <= RomRead_DatReg[63:32];
        ConfigRegAddr_DatReg <= RomRead_DatReg[95:64];
        ConfigData_DatReg <= RomRead_DatReg[127:96];
        ConfigIndex_CntReg <= ConfigIndex_CntReg + 1;
      end
      Skip_St : begin
        ConfigState_StaReg <= Idle_St;
      end
      Wait_St : begin
        if(ConfigData_DatReg >= ClockPeriod_Gen) begin
          ConfigData_DatReg <= ConfigData_DatReg - ClockPeriod_Gen;
        end
        else begin
          ConfigState_StaReg <= Idle_St;
        end
      end
      StartReadWrite_St : begin
        if(ConfigCommand_DatReg == Read_E) begin
          AxiReadAddrValid_ValReg <= 1'b1;
          AxiReadAddrAddress_AdrReg <= ConfigBaseAddr_DatReg + ConfigRegAddr_DatReg;
          AxiReadAddrProt_DatReg <= 3'b000;
          AxiReadDataReady_RdyReg <= 1'b1;
          ConfigState_StaReg <= WaitToRead_St;
        end
        else begin
          AxiWriteAddrValid_ValReg <= 1'b1;
          AxiWriteAddrAddress_AdrReg <= ConfigBaseAddr_DatReg + ConfigRegAddr_DatReg;
          AxiWriteAddrProt_DatReg <= 3'b000;
          AxiWriteDataValid_ValReg <= 1'b1;
          AxiWriteDataStrobe_DatReg <= 4'b1111;
          AxiWriteDataData_DatReg <= ConfigData_DatReg;
          AxiWriteRespReady_RdyReg <= 1'b1;
          ConfigState_StaReg <= WaitToWrite_St;
        end
        AxiTimeout_CntReg <= 0;
      end
      WaitToRead_St : begin
        if((AxiTimeout_Gen > 0) && (AxiTimeout_CntReg < (AxiTimeout_Gen - 1))) begin
          AxiTimeout_CntReg <= AxiTimeout_CntReg + 1;
        end
        if(AxiReadDataValid_ValIn == 1'b1 && AxiReadDataReady_RdyReg == 1'b1) begin
          AxiReadData_DatReg <= AxiReadDataData_DatIn;
          AxiResponse_DatReg[2] <= 1'b0;
          // no timeout
          AxiResponse_DatReg[1:0] <= AxiReadDataResponse_DatIn;
          ConfigState_StaReg <= Idle_St;
        end
        else if((AxiTimeout_Gen > 0) && (AxiTimeout_CntReg >= (AxiTimeout_Gen - 1))) begin
          AxiReadData_DatReg <= {32{1'b0}};
          AxiResponse_DatReg[2] <= 1'b1;
          // timeout
          AxiResponse_DatReg[1:0] <= 2'b00;
          ConfigState_StaReg <= Idle_St;
          // this is a violation of the bus spec but better than blocking the bus forever
          AxiReadAddrValid_ValReg <= 1'b0;
          AxiReadAddrAddress_AdrReg <= {32{1'b0}};
          AxiReadAddrProt_DatReg <= {3{1'b0}};
          AxiReadDataReady_RdyReg <= 1'b0;
        end
      end
      WaitToWrite_St : begin
        if((AxiTimeout_Gen > 0) && (AxiTimeout_CntReg < (AxiTimeout_Gen - 1))) begin
          AxiTimeout_CntReg <= AxiTimeout_CntReg + 1;
        end
        if(AxiWriteRespValid_ValIn == 1'b1 && AxiWriteRespReady_RdyReg == 1'b1) begin
          AxiReadData_DatReg <= {32{1'b0}};
          AxiResponse_DatReg[2] <= 1'b0;
          // no timeout
          AxiResponse_DatReg[1:0] <= AxiWriteRespResponse_DatIn;
          ConfigState_StaReg <= Idle_St;
        end
        else if((AxiTimeout_Gen > 0) && (AxiTimeout_CntReg >= (AxiTimeout_Gen - 1))) begin
          AxiReadData_DatReg <= {32{1'b0}};
          AxiResponse_DatReg[2] <= 1'b1;
          // timeout
          AxiResponse_DatReg[1:0] <= 2'b00;
          ConfigState_StaReg <= Idle_St;
          // this is a violation of the bus spec but better than blocking the bus forever
          AxiWriteAddrValid_ValReg <= 1'b0;
          AxiWriteAddrAddress_AdrReg <= {32{1'b0}};
          AxiWriteAddrProt_DatReg <= {3{1'b0}};
          AxiWriteDataValid_ValReg <= 1'b0;
          AxiWriteDataData_DatReg <= {32{1'b0}};
          AxiWriteDataStrobe_DatReg <= {4{1'b0}};
          AxiWriteRespReady_RdyReg <= 1'b0;
        end
      end
      End_St : begin
        ConfigState_StaReg <= End_St;
        ConfigDone_ValOut <= 1'b1;
      end
      default : begin
        ConfigState_StaReg <= Idle_St;
      end
      endcase
    end
  end

  // Separate the process to infer a block ram implementation of the Core List memory
  always @(posedge SysClk_ClkIn) begin
    RomRead_DatReg <= RomData_Rom[RomAddress_AdrReg];
  end

endmodule
