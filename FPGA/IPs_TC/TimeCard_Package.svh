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

package timecard_package;

typedef enum bit[1:0] {Idle_St, Read_St, Write_St, Resp_St} Axi_AccessState_Type;

typedef enum bit[2:0] { Ro_E, Rw_E, Wo_E, Wc_E, Rc_E, None_E } Axi_RegType_Type;

parameter SecondWidth_Con = 32;
parameter NanosecondWidth_Con = 32;
parameter AdjustmentIntervalWidth_Con = 32;
parameter AdjustmentCountWidth_Con = 8;
parameter SecondNanoseconds_Con = 1000000000;
parameter DriftMulP_Con = 3;
parameter DriftDivP_Con = 4;
parameter DriftMulI_Con = 3;
parameter DriftDivI_Con = 16;
parameter OffsetMulP_Con = 3;
parameter OffsetDivP_Con = 4;
parameter OffsetMulI_Con = 3;
parameter OffsetDivI_Con = 16;
parameter OffsetFactorP_Con = (OffsetMulP_Con * (2 ** 16)) / OffsetDivP_Con;
parameter OffsetFactorI_Con = (OffsetMulI_Con * (2 ** 16)) / OffsetDivI_Con;
parameter DriftFactorP_Con = (DriftMulP_Con * (2 ** 16)) / DriftDivP_Con;
parameter DriftFactorI_Con = (DriftMulI_Con * (2 ** 16)) / DriftDivI_Con;  // AXI related constants
parameter Axi_AddrSize_Con = 32;
parameter Axi_DataSize_Con = 32;
parameter Axi_RespOk_Con = 2'b00;
parameter Axi_RespExOk_Con = 2'b01;
parameter Axi_RespSlvErr_Con = 2'b10;
parameter Axi_RespDecErr_Con = 2'b11;

parameter Axi_AccessState_Type_Rst_Con = Idle_St;
parameter Axi_RegType_Type_Rst_Con = None_E;

typedef struct packed {
	logic [Axi_AddrSize_Con-1:0] Addr;
	logic [Axi_DataSize_Con-1:0] Mask;
	Axi_RegType_Type RegType;
	logic [Axi_DataSize_Con-1:0] Reset;
} Axi_Reg_Type;

`define Axi_Init_Proc(RegDef, Reg) \
	Reg <= RegDef.Reset & RegDef.Mask;

`define Axi_Read_Proc(RegDef, Reg, Address, Data, Result) \
	if (RegDef.Addr == Address) begin \
		Data <= RegDef.Mask & Reg; \
		$display("Eq ", RegDef.Mask, Reg, Data); \
		$display("AXI_READ_PROC2 ", RegDef, Reg, Address, Data, Result); \
		// Read and clear if Rc, not masked bits return 0 \
		if (RegDef.RegType == Rc_E) begin \
			//$display("Rc_E case 1"); \
			Reg <= Reg & ~RegDef.Mask; // If Mask[i] is 1, the Reg[i] bit is set to 0 \
			Result <= Axi_RespOk_Con; \
		end else if (RegDef.RegType == Rw_E || RegDef.RegType == Wc_E || RegDef.RegType == Ro_E || RegDef.RegType == Rc_E) begin \
			Result <= Axi_RespOk_Con; \
			//$display(RegDef.RegType, " case 2 ", Result); \
		end \
		else Result <= Axi_RespSlvErr_Con; \
	end

`define Axi_Write_Proc(RegDef, Reg, Address, Data, Result) \
	if (RegDef.Addr == Address) begin \
		// Write or clear if Wc, not masked bits unchanged \
		if (RegDef.RegType == Wc_E) \
			Reg <= (Reg & ~RegDef.Mask)|(Reg & RegDef.Mask & (~Data)); \
		else if (RegDef.RegType == Rw_E || RegDef.RegType == Wo_E) \
			Reg <= (Reg & ~RegDef.Mask)|(Data & RegDef.Mask); \
		// Result \
		if (RegDef.RegType == Rw_E || RegDef.RegType == Wo_E || RegDef.RegType == Wc_E) \
			Result <= Axi_RespOk_Con; \
		else Result <= Axi_RespSlvErr_Con; \
	end
endpackage
