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

//*****************************************************************************************
// The FPGA Version is a single 32bit register AXI slave that includes the FPGA and the  --
// Golden FPGA version. Depending on the input, the corresponding 2-byte version is      --
// provided (the  2 MSB contain the FPGA golden version and the 2 LSB contain the        --
// FPGA version.                                                                         --
//-----------------------------------------------------------------------------------------
  `include "TimeCard_Package.svh"
module FpgaVersion #(
	parameter [15:0] VersionNumber_Gen=16'h0000,
	parameter [15:0] VersionNumber_Golden_Gen=16'h0000
)(
	input wire SysClk_ClkIn,
	input wire SysRstN_RstIn,
	input wire GoldenImageN_EnaIn,
	input wire AxiWriteAddrValid_ValIn,
	output wire AxiWriteAddrReady_RdyOut,
	input wire [11:0] AxiWriteAddrAddress_AdrIn,
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
	input wire [11:0] AxiReadAddrAddress_AdrIn,
	input wire [2:0] AxiReadAddrProt_DatIn,
	output wire AxiReadDataValid_ValOut,
	input wire AxiReadDataReady_RdyIn,
	output wire [1:0] AxiReadDataResponse_DatOut,
	output wire [31:0] AxiReadDataData_DatOut
);

  import timecard_package::*;
  
  // Fpga Version 
  parameter FpgaMajorVersion_Golden_Con = VersionNumber_Golden_Gen[15:8];
  parameter FpgaMinorVersion_Golden_Con = VersionNumber_Golden_Gen[7:0];
  parameter FpgaMajorVersion_Con = VersionNumber_Gen[15:8];
  parameter FpgaMinorVersion_Con = VersionNumber_Gen[7:0];
  parameter FpgaVersion_Con = {FpgaMajorVersion_Golden_Con,FpgaMinorVersion_Golden_Con,FpgaMajorVersion_Con,FpgaMinorVersion_Con};
  // AXI Registers        
  //Axi_Reg_Type FpgaVersion_Reg_Con; assign FpgaVersion_Reg_Con = '{Addr:32'h0, Mask:32'hFFFFFFFF, RegType:Ro_E, Reset:FpgaVersion_Con};
  Axi_Reg_Type FpgaVersion_Reg_Con = '{Addr:32'h0, Mask:32'hF, RegType:Ro_E, Reset:FpgaVersion_Con};
  wire [31:0] FpgaVersion_Dat;
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
  reg [31:0] FpgaVersion_DatReg;
  assign FpgaVersion_Dat = GoldenImageN_EnaIn == 1'b1 ? {16'h0000,VersionNumber_Gen} : {VersionNumber_Golden_Gen,16'h0000};
  assign AxiWriteAddrReady_RdyOut = AxiWriteAddrReady_RdyReg;
  assign AxiWriteDataReady_RdyOut = AxiWriteDataReady_RdyReg;
  assign AxiWriteRespValid_ValOut = AxiWriteRespValid_ValReg;
  assign AxiWriteRespResponse_DatOut = AxiWriteRespResponse_DatReg;
  assign AxiReadAddrReady_RdyOut = AxiReadAddrReady_RdyReg;
  assign AxiReadDataValid_ValOut = AxiReadDataValid_ValReg;
  assign AxiReadDataResponse_DatOut = AxiReadDataResponse_DatReg;
  assign AxiReadDataData_DatOut = AxiReadDataData_DatReg;
  // AXI register access
  always @(posedge SysClk_ClkIn, posedge SysRstN_RstIn) begin : P1
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
	  `Axi_Init_Proc(FpgaVersion_Reg_Con, FpgaVersion_DatReg);
      FpgaVersion_DatReg <= FpgaVersion_Dat;
    end else begin
      if(((AxiWriteAddrValid_ValIn == 1'b1) && (AxiWriteAddrReady_RdyReg == 1'b1))) begin
        AxiWriteAddrReady_RdyReg <= 1'b0;
      end
      if(((AxiWriteDataValid_ValIn == 1'b1) && (AxiWriteDataReady_RdyReg == 1'b1))) begin
        AxiWriteDataReady_RdyReg <= 1'b0;
      end
      if(((AxiWriteRespValid_ValReg == 1'b1) && (AxiWriteRespReady_RdyIn == 1'b1))) begin
        AxiWriteRespValid_ValReg <= 1'b0;
      end
      if(((AxiReadAddrValid_ValIn == 1'b1) && (AxiReadAddrReady_RdyReg == 1'b1))) begin
        AxiReadAddrReady_RdyReg <= 1'b0;
      end
      if(((AxiReadDataValid_ValReg == 1'b1) && (AxiReadDataReady_RdyIn == 1'b1))) begin
        AxiReadDataValid_ValReg <= 1'b0;
      end
      case(Axi_AccessState_StaReg)
      Idle_St : begin
        if(((AxiWriteAddrValid_ValIn == 1'b1) && (AxiWriteDataValid_ValIn == 1'b1))) begin
          AxiWriteAddrReady_RdyReg <= 1'b1;
          AxiWriteDataReady_RdyReg <= 1'b1;
          Axi_AccessState_StaReg <= Write_St;
        end
        else if((AxiReadAddrValid_ValIn == 1'b1)) begin
          AxiReadAddrReady_RdyReg <= 1'b1;
          Axi_AccessState_StaReg <= Read_St;
        end
      end
      Read_St : begin
        if((AxiReadAddrValid_ValIn == 1'b1 && AxiReadAddrReady_RdyReg == 1'b1)) begin
			$display("Read_St");
          AxiReadDataValid_ValReg <= 1'b1;
          AxiReadDataResponse_DatReg <= Axi_RespSlvErr_Con;
		  $display("BEFORE, ", FpgaVersion_Reg_Con, " o ", FpgaVersion_DatReg, " o ", AxiReadAddrAddress_AdrIn, " o ", AxiReadDataData_DatReg, " o ", AxiReadDataResponse_DatReg, " o ");
		  `Axi_Read_Proc(FpgaVersion_Reg_Con, FpgaVersion_DatReg, AxiReadAddrAddress_AdrIn, AxiReadDataData_DatReg, AxiReadDataResponse_DatReg);
		  $display("AFTER , ", FpgaVersion_Reg_Con, " o ", FpgaVersion_DatReg, " o ", AxiReadAddrAddress_AdrIn, " o ", AxiReadDataData_DatReg, " o ", AxiReadDataResponse_DatReg, " o ");
          Axi_AccessState_StaReg <= Resp_St;
        end
      end
      Write_St : begin
        if(((AxiWriteAddrValid_ValIn == 1'b1 && AxiWriteAddrReady_RdyReg == 1'b1) && (AxiWriteDataValid_ValIn == 1'b1 && AxiWriteDataReady_RdyReg == 1'b1))) begin
          AxiWriteRespValid_ValReg <= 1'b1;
          AxiWriteRespResponse_DatReg <= Axi_RespSlvErr_Con;
		  `Axi_Write_Proc(FpgaVersion_Reg_Con, FpgaVersion_DatReg, AxiWriteAddrAddress_AdrIn, AxiWriteDataData_DatIn, AxiWriteRespResponse_DatReg);
          Axi_AccessState_StaReg <= Resp_St;
        end
      end
      Resp_St : begin
        if((((AxiWriteRespValid_ValReg == 1'b1) && (AxiWriteRespReady_RdyIn == 1'b1)) || ((AxiReadDataValid_ValReg == 1'b1) && (AxiReadDataReady_RdyIn == 1'b1)))) begin
          Axi_AccessState_StaReg <= Idle_St;
        end
      end
      endcase
	  FpgaVersion_DatReg <= FpgaVersion_Dat;
    end
  end
endmodule
