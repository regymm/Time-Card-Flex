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
`include "TimeCard_Package.svh"
module DummyAxiSlave #(
	parameter [31:0] ClockPeriod_Gen=20,
	parameter [31:0] RamAddrWidth_Gen=10
) (
	input wire SysClk_ClkIn,
	input wire SysRstN_RstIn,
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
    typedef enum bit[1:0] {RamWait_St, RamDone_St} RamState_Type;

	// Memory read signals 
	reg RamState_StaReg;
	reg [RamAddrWidth_Gen - 1:0] RamAddress_AdrReg;
	reg [31:0] RamRead_DatReg = 1'b0;
	reg [31:0] RamWrite_DatReg = 1'b0;
	reg RamWriteEn_EnaReg; 
	// memory instantiation
	reg [31:0] Memory_Ram[RamAddrWidth_Gen**2-1:0] = '{default: 32'b0};
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
	assign AxiWriteAddrReady_RdyOut = AxiWriteAddrReady_RdyReg;
	assign AxiWriteDataReady_RdyOut = AxiWriteDataReady_RdyReg;
	assign AxiWriteRespValid_ValOut = AxiWriteRespValid_ValReg;
	assign AxiWriteRespResponse_DatOut = AxiWriteRespResponse_DatReg;
	assign AxiReadAddrReady_RdyOut = AxiReadAddrReady_RdyReg;
	assign AxiReadDataValid_ValOut = AxiReadDataValid_ValReg;
	assign AxiReadDataResponse_DatOut = AxiReadDataResponse_DatReg;
	assign AxiReadDataData_DatOut = AxiReadDataData_DatReg;

  // Axi process for reading and writing the register addresses
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
      RamAddress_AdrReg <= {((RamAddrWidth_Gen - 1)-(0)+1){1'b0}};
      RamState_StaReg <= RamWait_St;
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
        RamState_StaReg <= RamWait_St;
      end
      Read_St : begin
        if(AxiReadAddrValid_ValIn == 1'b1 && AxiReadAddrReady_RdyReg == 1'b1) begin
          RamAddress_AdrReg <= {2'b00,AxiReadAddrAddress_AdrIn[RamAddrWidth_Gen - 1:2]};
          // 32-bit data per address 
          RamState_StaReg <= RamWait_St;
        end
        else begin
          case(RamState_StaReg)
          RamWait_St : begin
            RamState_StaReg <= RamDone_St;
          end
          RamDone_St : begin
            AxiReadDataValid_ValReg <= 1'b1;
            AxiReadDataResponse_DatReg <= Axi_RespOk_Con;
            AxiReadDataData_DatReg <= RamRead_DatReg;
            Axi_AccessState_StaReg <= Resp_St;
            RamState_StaReg <= RamWait_St;
          end
          endcase
        end
      end
      Write_St : begin
        if((AxiWriteAddrValid_ValIn == 1'b1 && AxiWriteAddrReady_RdyReg == 1'b1) && (AxiWriteDataValid_ValIn == 1'b1 && AxiWriteDataReady_RdyReg == 1'b1)) begin
          RamAddress_AdrReg <= {2'b00,AxiWriteAddrAddress_AdrIn[RamAddrWidth_Gen - 1:2]};
          // 32-bit data per address
          RamWrite_DatReg <= AxiWriteDataData_DatIn;
          RamWriteEn_EnaReg <= 1'b1;
          RamState_StaReg <= RamWait_St;
        end
        else begin
          case(RamState_StaReg)
          RamWait_St : begin
            RamWriteEn_EnaReg <= 1'b0;
            RamState_StaReg <= RamDone_St;
          end
          RamDone_St : begin
            AxiWriteRespValid_ValReg <= 1'b1;
            AxiWriteRespResponse_DatReg <= Axi_RespOk_Con;
            Axi_AccessState_StaReg <= Resp_St;
            RamState_StaReg <= RamWait_St;
          end
          endcase
        end
      end
      Resp_St : begin
        if((AxiWriteRespValid_ValReg == 1'b1 && AxiWriteRespReady_RdyIn == 1'b1) || (AxiReadDataValid_ValReg == 1'b1 && AxiReadDataReady_RdyIn == 1'b1)) begin
          Axi_AccessState_StaReg <= Idle_St;
        end
      end
      endcase
    end
  end

  // Separate the process to infer a block ram implementation of the memory
  always @(posedge SysClk_ClkIn) begin
    if((RamWriteEn_EnaReg == 1'b1)) 
      Memory_Ram[RamAddress_AdrReg] <= RamWrite_DatReg;
    RamRead_DatReg <= Memory_Ram[RamAddress_AdrReg];
  end
endmodule
