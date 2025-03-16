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

// Configure UART or I2C communication based on a selection input.                       --

module CommunicationSelector(
	// '0' UART; '1' I2C
	input wire SelIn_DatIn,
	// IO Pins 
	input wire TxScl_DatIn,
	output wire TxScl_DatOut,
	output wire TxSclT_EnaOut,
	input wire RxSda_DatIn,
	output wire RxSda_DatOut,
	output wire RxSdaT_EnaOut,
	output wire Irq_DatOut,
	// UART Interface to IP
	input wire UartTx_DatIn,
	output wire UartRx_DatOut,
	input wire UartIrq_DatIn,
	// I2C Interface to IP
	output wire I2cSclIn_DatOut,
	input wire I2cSclOut_DatIn,
	input wire I2cSclT_EnaIn,
	output wire I2cSdaIn_DatOut,
	input wire I2cSdaOut_DatIn,
	input wire I2cSdaT_EnaIn,
	input wire I2cIrq_DatIn
);
	wire TxSclOut_Dat;
	wire TxSclIn_Dat;
	wire TxSclT_Ena;
	wire RxSdaOut_Dat;
	wire RxSdaIn_Dat;
	wire RxSdaT_Ena;

  assign TxScl_DatOut = TxSclOut_Dat;
  assign TxSclIn_Dat = TxScl_DatIn;
  assign TxSclT_EnaOut = TxSclT_Ena;
  assign RxSda_DatOut = RxSdaOut_Dat;
  assign RxSdaIn_Dat = RxSda_DatIn;
  assign RxSdaT_EnaOut = RxSdaT_Ena;
  // MUX
  // Irq Mapping
  assign Irq_DatOut = (SelIn_DatIn == 1'b0) ? UartIrq_DatIn : I2cIrq_DatIn;
  // Tx and SCL  Mapping
  assign TxSclOut_Dat = (SelIn_DatIn == 1'b0) ? UartTx_DatIn : I2cSclOut_DatIn;
  assign I2cSclIn_DatOut = (SelIn_DatIn == 1'b0) ? 1'b0 : TxSclIn_Dat;
  // Tristate = 0 --> I = I; IO = I; O = I
  assign TxSclT_Ena = (SelIn_DatIn == 1'b0) ? 1'b0 : I2cSclT_EnaIn;
  // Rx and SDA Mapping
  assign RxSdaOut_Dat = (SelIn_DatIn == 1'b0) ? 1'b0 : I2cSdaOut_DatIn;
  assign I2cSdaIn_DatOut = (SelIn_DatIn == 1'b0) ? 1'b0 : RxSdaIn_Dat;
  // Tristate = 1 --> I = X; IO = Z; O = IO
  assign RxSdaT_Ena = (SelIn_DatIn == 1'b0) ? 1'b1 : I2cSdaT_EnaIn;
  assign UartRx_DatOut = (SelIn_DatIn == 1'b0) ? RxSdaIn_Dat : 1'b0;

endmodule
