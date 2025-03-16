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

// The MSI IRQ receives single interrupts of the FPGA cores and puts them into a         --
// message for the Xilinx AXI-PCIe bridge core. Once a message is ready a request is set --
// and it waits until the grant signal from the Xilinx Core.                             --
// If there are several interrupts pending the messages are sent with the round-robin    --
// principle. It supports up to 32 Interrupt Requests                                    --

module MsiIrq #(
  parameter [31:0]NumberOfInterrupts_Gen = 20,
  parameter [31:0]LevelInterrupt_Gen = 32'h000E05B8
)(
// System           
input wire SysClk_ClkIn,
input wire SysRstN_RstIn,
// Interrupt inputs                     
input wire IrqIn0_DatIn,
input wire IrqIn1_DatIn,
input wire IrqIn2_DatIn,
input wire IrqIn3_DatIn,
input wire IrqIn4_DatIn,
input wire IrqIn5_DatIn,
input wire IrqIn6_DatIn,
input wire IrqIn7_DatIn,
input wire IrqIn8_DatIn,
input wire IrqIn9_DatIn,
input wire IrqIn10_DatIn,
input wire IrqIn11_DatIn,
input wire IrqIn12_DatIn,
input wire IrqIn13_DatIn,
input wire IrqIn14_DatIn,
input wire IrqIn15_DatIn,
input wire IrqIn16_DatIn,
input wire IrqIn17_DatIn,
input wire IrqIn18_DatIn,
input wire IrqIn19_DatIn,
input wire IrqIn20_DatIn,
input wire IrqIn21_DatIn,
input wire IrqIn22_DatIn,
input wire IrqIn23_DatIn,
input wire IrqIn24_DatIn,
input wire IrqIn25_DatIn,
input wire IrqIn26_DatIn,
input wire IrqIn27_DatIn,
input wire IrqIn28_DatIn,
input wire IrqIn29_DatIn,
input wire IrqIn30_DatIn,
input wire IrqIn31_DatIn,
// MSI Interface            
input wire MsiIrqEnable_EnIn,
input wire MsiGrant_ValIn,
output wire MsiReq_ValOut,
input wire [2:0] MsiVectorWidth_DatIn, // unused
output wire [4:0] MsiVectorNum_DatOut
);
parameter [2:0]
  Idle_St = 0,
  SelectIrq_St = 1,
  SendIrq_St = 2,
  WaitGrant_St = 3,
  End_St = 4;
reg [2:0] Msi_State_StReg;
reg MsiReq_ValReg = 1'b0;
reg [4:0] MsiVectorNum_DatReg = 1'b0;
wire [31:0] IrqInMax_Dat;  // max number of interrupts is 32
wire [NumberOfInterrupts_Gen - 1:0] IrqIn_Dat;
(* ASYNC_REG = "TRUE" *)reg [NumberOfInterrupts_Gen - 1:0] IrqIn_DatReg = 1'b0;
reg [NumberOfInterrupts_Gen - 1:0] IrqIn_Dat_ff = 1'b0;
reg [NumberOfInterrupts_Gen - 1:0] IrqDetected_Reg = 1'b0;
reg [31:0] IrqNumber = 0; 

  integer i;

  assign MsiReq_ValOut = MsiReq_ValReg;
  assign MsiVectorNum_DatOut = MsiVectorNum_DatReg;
  // assign the irq signals to vector of max size
  assign IrqInMax_Dat[31] = NumberOfInterrupts_Gen == 32 ? IrqIn31_DatIn : 1'b0;
  assign IrqInMax_Dat[30] = NumberOfInterrupts_Gen >= 31 ? IrqIn30_DatIn : 1'b0;
  assign IrqInMax_Dat[29] = NumberOfInterrupts_Gen >= 30 ? IrqIn29_DatIn : 1'b0;
  assign IrqInMax_Dat[28] = NumberOfInterrupts_Gen >= 29 ? IrqIn28_DatIn : 1'b0;
  assign IrqInMax_Dat[27] = NumberOfInterrupts_Gen >= 28 ? IrqIn27_DatIn : 1'b0;
  assign IrqInMax_Dat[26] = NumberOfInterrupts_Gen >= 27 ? IrqIn26_DatIn : 1'b0;
  assign IrqInMax_Dat[25] = NumberOfInterrupts_Gen >= 26 ? IrqIn25_DatIn : 1'b0;
  assign IrqInMax_Dat[24] = NumberOfInterrupts_Gen >= 25 ? IrqIn24_DatIn : 1'b0;
  assign IrqInMax_Dat[23] = NumberOfInterrupts_Gen >= 24 ? IrqIn23_DatIn : 1'b0;
  assign IrqInMax_Dat[22] = NumberOfInterrupts_Gen >= 23 ? IrqIn22_DatIn : 1'b0;
  assign IrqInMax_Dat[21] = NumberOfInterrupts_Gen >= 22 ? IrqIn21_DatIn : 1'b0;
  assign IrqInMax_Dat[20] = NumberOfInterrupts_Gen >= 21 ? IrqIn20_DatIn : 1'b0;
  assign IrqInMax_Dat[19] = NumberOfInterrupts_Gen >= 20 ? IrqIn19_DatIn : 1'b0;
  assign IrqInMax_Dat[18] = NumberOfInterrupts_Gen >= 19 ? IrqIn18_DatIn : 1'b0;
  assign IrqInMax_Dat[17] = NumberOfInterrupts_Gen >= 18 ? IrqIn17_DatIn : 1'b0;
  assign IrqInMax_Dat[16] = NumberOfInterrupts_Gen >= 17 ? IrqIn16_DatIn : 1'b0;
  assign IrqInMax_Dat[15] = NumberOfInterrupts_Gen >= 16 ? IrqIn15_DatIn : 1'b0;
  assign IrqInMax_Dat[14] = NumberOfInterrupts_Gen >= 15 ? IrqIn14_DatIn : 1'b0;
  assign IrqInMax_Dat[13] = NumberOfInterrupts_Gen >= 14 ? IrqIn13_DatIn : 1'b0;
  assign IrqInMax_Dat[12] = NumberOfInterrupts_Gen >= 13 ? IrqIn12_DatIn : 1'b0;
  assign IrqInMax_Dat[11] = NumberOfInterrupts_Gen >= 12 ? IrqIn11_DatIn : 1'b0;
  assign IrqInMax_Dat[10] = NumberOfInterrupts_Gen >= 11 ? IrqIn10_DatIn : 1'b0;
  assign IrqInMax_Dat[9] = NumberOfInterrupts_Gen >= 10 ? IrqIn9_DatIn : 1'b0;
  assign IrqInMax_Dat[8] = NumberOfInterrupts_Gen >= 9 ? IrqIn8_DatIn : 1'b0;
  assign IrqInMax_Dat[7] = NumberOfInterrupts_Gen >= 8 ? IrqIn7_DatIn : 1'b0;
  assign IrqInMax_Dat[6] = NumberOfInterrupts_Gen >= 7 ? IrqIn6_DatIn : 1'b0;
  assign IrqInMax_Dat[5] = NumberOfInterrupts_Gen >= 6 ? IrqIn5_DatIn : 1'b0;
  assign IrqInMax_Dat[4] = NumberOfInterrupts_Gen >= 5 ? IrqIn4_DatIn : 1'b0;
  assign IrqInMax_Dat[3] = NumberOfInterrupts_Gen >= 4 ? IrqIn3_DatIn : 1'b0;
  assign IrqInMax_Dat[2] = NumberOfInterrupts_Gen >= 3 ? IrqIn2_DatIn : 1'b0;
  assign IrqInMax_Dat[1] = NumberOfInterrupts_Gen >= 2 ? IrqIn1_DatIn : 1'b0;
  assign IrqInMax_Dat[0] = NumberOfInterrupts_Gen >= 1 ? IrqIn0_DatIn : 1'b0;
  // scale the irq max vector down to proper size
  assign IrqIn_Dat = IrqInMax_Dat[NumberOfInterrupts_Gen - 1:0];
  // Send the interrupt requests one by one to the output (AXI-MSI bridge) and wait until the request is granted.
  always @(posedge SysClk_ClkIn, posedge SysRstN_RstIn) begin
    if((SysRstN_RstIn == 1'b0)) begin
      Msi_State_StReg <= Idle_St;
      IrqIn_DatReg <= {((NumberOfInterrupts_Gen - 1)-(0)+1){1'b0}};
      IrqIn_Dat_ff <= {((NumberOfInterrupts_Gen - 1)-(0)+1){1'b0}};
      IrqDetected_Reg <= {((NumberOfInterrupts_Gen - 1)-(0)+1){1'b0}};
      MsiReq_ValReg <= 1'b0;
      MsiVectorNum_DatReg <= {5{1'b0}};
      IrqNumber <= 0;
    end else begin
      if((MsiIrqEnable_EnIn == 1'b1)) begin
        IrqIn_DatReg <= IrqIn_Dat;
        IrqIn_Dat_ff <= IrqIn_DatReg;
        // provide the next interrupt
        case(Msi_State_StReg)
        Idle_St : begin
          if(((IrqDetected_Reg) != 0)) begin
            Msi_State_StReg <= SelectIrq_St;
          end
          else begin
            // no more IRQ pending restart from 0
            IrqNumber <= 0;
          end
        end
        SelectIrq_St : begin
          if((IrqDetected_Reg[IrqNumber] != 1'b0)) begin
            Msi_State_StReg <= SendIrq_St;
          end
          else begin
            if((IrqNumber >= (NumberOfInterrupts_Gen - 1))) begin
              IrqNumber <= 0;
            end
            else begin
              IrqNumber <= IrqNumber + 1;
            end
          end
        end
        SendIrq_St : begin
          MsiReq_ValReg <= 1'b1;
          MsiVectorNum_DatReg <= IrqNumber;
          Msi_State_StReg <= WaitGrant_St;
        end
        WaitGrant_St : begin
          MsiReq_ValReg <= 1'b0;
          if((MsiGrant_ValIn == 1'b1)) begin
            // Clear IrqEdge if no edge in this cycle
            IrqDetected_Reg[IrqNumber] <= 1'b0;
            Msi_State_StReg <= End_St;
          end
        end
        End_St : begin
          if((IrqNumber >= (NumberOfInterrupts_Gen - 1))) begin
            IrqNumber <= 0;
          end
          else begin
            IrqNumber <= IrqNumber + 1;
          end
          Msi_State_StReg <= Idle_St;
        end
        default : begin
          Msi_State_StReg <= Idle_St;
        end
        endcase
        // scan for a new interrupt
        for (i=0; i <= NumberOfInterrupts_Gen - 1; i = i + 1) begin
          if((IrqIn_Dat_ff[i] == 1'b0 && IrqIn_DatReg[i] == 1'b1) || (IrqIn_Dat_ff[i] == 1'b1 && LevelInterrupt_Gen[i] == 1'b1)) begin
            IrqDetected_Reg[i] <= 1'b1;
          end
        end
      end
      else begin
        Msi_State_StReg <= Idle_St;
        IrqIn_DatReg <= {((NumberOfInterrupts_Gen - 1)-(0)+1){1'b0}};
        IrqDetected_Reg <= {((NumberOfInterrupts_Gen - 1)-(0)+1){1'b0}};
      end
    end
  end
endmodule
