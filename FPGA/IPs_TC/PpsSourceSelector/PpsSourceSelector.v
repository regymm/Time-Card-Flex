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

// The PPS Source Selector detects the available PPS sources and selects the PPS source --
// according to a priority scheme and a configuration.                                  --
// The configuration and monitoring of the core is optional and it is done by an        --
// external interface (e.g. an AXI slave interface of Clock Detector). If the           --
// configuration is not provided, then the PPS selection is done by a priority scheme   --
// of the available PPS inputs.                                                         --

module PpsSourceSelector(
// System
input wire SysClk_ClkIn,
input wire SysRstN_RstIn,
// Selection
input wire [1:0] PpsSourceSelect_DatIn,
// PPS Available    
output wire [3:0] PpsSourceAvailable_DatOut,
// PPS Inputs 
input wire SmaPps_EvtIn,
input wire MacPps_EvtIn,
input wire GnssPps_EvtIn,
// PPS Outputs
output reg SlavePps_EvtOut,
output reg MacPps_EvtOut
);

parameter [31:0] ClockClkPeriodNanosecond_Gen=20;
parameter [31:0] PpsAvailableThreshold_Gen=3;
reg [2:0] PpsSourceAvailable_DatReg = 1'b0;
reg SmaPps_EvtReg;
reg SmaPps_EvtFF;
reg MacPps_EvtReg;
reg MacPps_EvtFF;
reg GnssPps_EvtReg;
reg GnssPps_EvtFF;
reg [31:0] SmaPpsPulse_CntReg;
reg [31:0] SmaPpsPeriod_CntReg;
reg [31:0] MacPpsPulse_CntReg;
reg [31:0] MacPpsPeriod_CntReg;
reg [31:0] GnssPpsPulse_CntReg;
reg [31:0] GnssPpsPeriod_CntReg;
reg [1:0] PpsSlaveSourceSelect_DatReg = 1'b0;
reg [1:0] MacSourceSelect_DatReg = 1'b0; 

  assign PpsSourceAvailable_DatOut = {1'b0,PpsSourceAvailable_DatReg};
  always @(*) begin
    case(PpsSlaveSourceSelect_DatReg)
      2'b00 : SlavePps_EvtOut <= SmaPps_EvtIn;
      2'b01 : SlavePps_EvtOut <= MacPps_EvtIn;
      2'b10 : SlavePps_EvtOut <= GnssPps_EvtIn;
      default : SlavePps_EvtOut <= GnssPps_EvtIn;
    endcase
  end

  always @(*) begin
    case(MacSourceSelect_DatReg)
      2'b00 : MacPps_EvtOut <= SmaPps_EvtIn;
      2'b10 : MacPps_EvtOut <= GnssPps_EvtIn;
      default : MacPps_EvtOut <= GnssPps_EvtIn;
    endcase
  end

  // Check that each PPS input has a frequency of ~1 Hz for at least PpsAvailableThreshold_Gen seconds in sequence
  always @(posedge SysClk_ClkIn, posedge SysRstN_RstIn) begin
    if(SysRstN_RstIn == 1'b0) begin
      PpsSourceAvailable_DatReg <= {3{1'b0}};
      SmaPps_EvtReg <= 1'b0;
      SmaPps_EvtFF <= 1'b0;
      MacPps_EvtReg <= 1'b0;
      MacPps_EvtFF <= 1'b0;
      GnssPps_EvtReg <= 1'b0;
      GnssPps_EvtFF <= 1'b0;
      SmaPpsPulse_CntReg <= 0;
      SmaPpsPeriod_CntReg <= 0;
      MacPpsPulse_CntReg <= 0;
      MacPpsPeriod_CntReg <= 0;
      GnssPpsPulse_CntReg <= 0;
      GnssPpsPeriod_CntReg <= 0;
    end else begin
      SmaPps_EvtReg <= SmaPps_EvtIn;
      SmaPps_EvtFF <= SmaPps_EvtReg;
      MacPps_EvtReg <= MacPps_EvtIn;
      MacPps_EvtFF <= MacPps_EvtReg;
      GnssPps_EvtReg <= GnssPps_EvtIn;
      GnssPps_EvtFF <= GnssPps_EvtReg;
      if(SmaPpsPulse_CntReg == 0) begin
        PpsSourceAvailable_DatReg[0] <= 1'b0;
      end
      else if(SmaPpsPulse_CntReg >= PpsAvailableThreshold_Gen) begin
        PpsSourceAvailable_DatReg[0] <= 1'b1;
      end
      if(MacPpsPulse_CntReg == 0) begin
        PpsSourceAvailable_DatReg[1] <= 1'b0;
      end
      else if(MacPpsPulse_CntReg >= PpsAvailableThreshold_Gen) begin
        PpsSourceAvailable_DatReg[1] <= 1'b1;
      end
      if(GnssPpsPulse_CntReg == 0) begin
        PpsSourceAvailable_DatReg[2] <= 1'b0;
      end
      else if(GnssPpsPulse_CntReg >= PpsAvailableThreshold_Gen) begin
        PpsSourceAvailable_DatReg[2] <= 1'b1;
      end
      // SMA PPS
      if(SmaPps_EvtReg == 1'b1 && SmaPps_EvtFF == 1'b0) begin
        // rising
        SmaPpsPeriod_CntReg <= 0;
        if(SmaPpsPeriod_CntReg < 900000000) begin
          // too short -10%
          if(SmaPpsPulse_CntReg > 0) begin
            SmaPpsPulse_CntReg <= SmaPpsPulse_CntReg - 1;
          end
        end
        else if(SmaPpsPeriod_CntReg >= 1100000000) begin
          // too long + 10%
          if(SmaPpsPulse_CntReg > 0) begin
            SmaPpsPulse_CntReg <= SmaPpsPulse_CntReg - 1;
          end
        end
        else begin
          if(SmaPpsPulse_CntReg < PpsAvailableThreshold_Gen) begin
            SmaPpsPulse_CntReg <= SmaPpsPulse_CntReg + 1;
          end
        end
      end
      else begin
        if(SmaPpsPeriod_CntReg < 1100000000) begin
          SmaPpsPeriod_CntReg <= SmaPpsPeriod_CntReg + ClockClkPeriodNanosecond_Gen;
        end
        else begin
          SmaPpsPeriod_CntReg <= 0;
          if(SmaPpsPulse_CntReg > 0) begin
            SmaPpsPulse_CntReg <= SmaPpsPulse_CntReg - 1;
          end
        end
      end
      // MAC PPS
      if(MacPps_EvtReg == 1'b1 && MacPps_EvtFF == 1'b0) begin
        // rising
        MacPpsPeriod_CntReg <= 0;
        if((MacPpsPeriod_CntReg < 900000000)) begin
          // too short -10%
          if(MacPpsPulse_CntReg > 0) begin
            MacPpsPulse_CntReg <= MacPpsPulse_CntReg - 1;
          end
        end
        else if(MacPpsPeriod_CntReg >= 1100000000) begin
          // too long + 10%
          if(MacPpsPulse_CntReg > 0) begin
            MacPpsPulse_CntReg <= MacPpsPulse_CntReg - 1;
          end
        end
        else begin
          if(MacPpsPulse_CntReg < PpsAvailableThreshold_Gen) begin
            MacPpsPulse_CntReg <= MacPpsPulse_CntReg + 1;
          end
        end
      end
      else begin
        if(MacPpsPeriod_CntReg < 1100000000) begin
          MacPpsPeriod_CntReg <= MacPpsPeriod_CntReg + ClockClkPeriodNanosecond_Gen;
        end
        else begin
          MacPpsPeriod_CntReg <= 0;
          if(MacPpsPulse_CntReg > 0) begin
            MacPpsPulse_CntReg <= MacPpsPulse_CntReg - 1;
          end
        end
      end
      // Gnss PPS
      if(GnssPps_EvtReg == 1'b1 && GnssPps_EvtFF == 1'b0) begin
        // rising
        GnssPpsPeriod_CntReg <= 0;
        if(GnssPpsPeriod_CntReg < 900000000) begin
          // too short -10%
          if(GnssPpsPulse_CntReg > 0) begin
            GnssPpsPulse_CntReg <= GnssPpsPulse_CntReg - 1;
          end
        end
        else if(GnssPpsPeriod_CntReg >= 1100000000) begin
          // too long + 10%
          if(GnssPpsPulse_CntReg > 0) begin
            GnssPpsPulse_CntReg <= GnssPpsPulse_CntReg - 1;
          end
        end
        else begin
          if(GnssPpsPulse_CntReg < PpsAvailableThreshold_Gen) begin
            GnssPpsPulse_CntReg <= GnssPpsPulse_CntReg + 1;
          end
        end
      end
      else begin
        if(GnssPpsPeriod_CntReg < 1100000000) begin
          GnssPpsPeriod_CntReg <= GnssPpsPeriod_CntReg + ClockClkPeriodNanosecond_Gen;
        end
        else begin
          GnssPpsPeriod_CntReg <= 0;
          if(GnssPpsPulse_CntReg > 0) begin
            GnssPpsPulse_CntReg <= GnssPpsPulse_CntReg - 1;
          end
        end
      end
    end
  end

  // Select the Slave PPS and MAC PPS sources according to configuration
  always @(posedge SysClk_ClkIn, posedge SysRstN_RstIn) begin
    if(SysRstN_RstIn == 1'b0) begin
      PpsSlaveSourceSelect_DatReg <= {2{1'b0}};
      MacSourceSelect_DatReg <= {2{1'b0}};
    end else begin
      case(PpsSourceSelect_DatIn)
            // Auto select
      2'b00 : begin
        // 1. SMA
        if(PpsSourceAvailable_DatReg[0] == 1'b1) begin
          if(SmaPps_EvtIn == 1'b0) begin
            PpsSlaveSourceSelect_DatReg <= 2'b00;
            // SMA
            MacSourceSelect_DatReg <= 2'b00;
            // SMA
          end
          // 2. MAC
        end
        else if(PpsSourceAvailable_DatReg[1] == 1'b1) begin
          if(MacPps_EvtIn == 1'b0) begin
            PpsSlaveSourceSelect_DatReg <= 2'b01;
            // MAC
            if(GnssPps_EvtIn == 1'b0) begin
              MacSourceSelect_DatReg <= 2'b10;
              // GNSS
            end
          end
          // 3. GNSS
        end
        else if(PpsSourceAvailable_DatReg[2] == 1'b1) begin
          if(GnssPps_EvtIn == 1'b0) begin
            PpsSlaveSourceSelect_DatReg <= 2'b10;
            // GNSS
            MacSourceSelect_DatReg <= 2'b10;
            // GNSS
          end
        end
        else begin
          if(GnssPps_EvtIn == 1'b0) begin
            PpsSlaveSourceSelect_DatReg <= 2'b10;
            // GNSS
            MacSourceSelect_DatReg <= 2'b10;
            // GNSS
          end
        end
        // Force SMA
      end
      2'b01 : begin
        if(SmaPps_EvtIn == 1'b0) begin
          PpsSlaveSourceSelect_DatReg <= 2'b00;
          // SMA
          MacSourceSelect_DatReg <= 2'b00;
          // SMA
        end
        // Force MAC
      end
      2'b10 : begin
        if(MacPps_EvtIn == 1'b0) begin
          PpsSlaveSourceSelect_DatReg <= 2'b01;
          // MAC
          if(GnssPps_EvtIn == 1'b0) begin
            MacSourceSelect_DatReg <= 2'b10;
            // GNSS
          end
        end
        // Force GNSS
      end
      2'b11 : begin
        if(GnssPps_EvtIn == 1'b0) begin
          PpsSlaveSourceSelect_DatReg <= 2'b10;
          // GNSS
          MacSourceSelect_DatReg <= 2'b10;
          // GNSS
        end
      end
      default : begin
        if(GnssPps_EvtIn == 1'b0) begin
          PpsSlaveSourceSelect_DatReg <= 2'b10;
          // GNSS
          MacSourceSelect_DatReg <= 2'b10;
          // GNSS
        end
      end
      endcase
    end
  end
endmodule
