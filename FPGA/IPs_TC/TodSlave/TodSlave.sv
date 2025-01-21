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

// The Time-Of-Day (ToD) slave provides adjustment to a Clock of the "seconds" field.    --
// From a GNSS receiver, it receives, via a UART interface, messages that include the    --
// ToD. The messages are detected and decoded in order to extract the time infrmation.   --
// The extracted time is converted to Unix Epoch format (32bit seconds and 32bit         --
// nanonseconds)and then the TAI is calculated, by adding the received UTC offset. The   --
// calculated time is compared with the time received from the connected Clock. If the   --
// "seconds" field is not the equal, then a time adjustment is applied to the Clock at   --
// at the change of second.                                                              --
// This core is expected to be connected to an Adjustable Clock together with a PPS      --
// slave. The TOD slave forces the Clock to jump to the correct "second", while the PPS  --
// slave fine-tunes the Clock by providing offset and drift adjustments.                 --
`include "TimeCard_Package.svh"

module TodSlave #(
parameter [31:0] ClockPeriod_Gen=20,
parameter [31:0] UartDefaultBaudRate_Gen=2,
parameter UartPolarity_Gen="true",
parameter ReceiveCurrentTime_Gen="true",
parameter Sim_Gen="false"
)(
// System
input wire SysClk_ClkIn,
input wire SysRstN_RstIn,
// Time Input
input wire [SecondWidth_Con - 1:0] ClockTime_Second_DatIn,
input wire [NanosecondWidth_Con - 1:0] ClockTime_Nanosecond_DatIn,
input wire ClockTime_TimeJump_DatIn,
input wire ClockTime_ValIn,
// Tod Input
input wire RxUart_DatIn,
// Time Adjustment Output                    
output wire [SecondWidth_Con - 1:0] TimeAdjustment_Second_DatOut,
output wire [NanosecondWidth_Con - 1:0] TimeAdjustment_Nanosecond_DatOut,
output wire TimeAdjustment_ValOut,
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
int i;

// these are also types -- but since they are used only as state machine names,
// it doens't matter to have same value, use repeated names, etc. 
parameter [1:0]
  Idle_St = 0,
  Start_St = 1,
  Data_St = 2,
  Stop_St = 3;

parameter [3:0]
  UbxHeader_Sync_St = 1,
  UbxHeader_Class_St = 2,
  UbxHeader_MonId_St = 3,
  UbxHeader_NavId_St = 4,
  UbxMonHw_CheckPayload_St = 5,
  UbxNavSat_CheckPayload_St = 6,
  UbxNavStatus_CheckPayload_St = 7,
  UbxNavTimeLs_CheckPayload_St = 8,
  UbxNavTimeUtc_CheckPayload_St = 9,
  UbxChecksum_ChecksumA_St = 10,
  UbxChecksum_ChecksumB_St = 11;

parameter [3:0]
  TsipPacket_Id_St = 1,
  TsipPacket_SubId_St = 2,
  TsipLength1_St = 3,
  TsipLength2_St = 4,
  TsipMode_St = 5,
  TsipTiming_Data_St = 6,
  TsipPosition_Data_St = 7,
  TsipSatellite_Data_St = 8,
  TsipAlarms_Data_St = 9,
  TsipReceiver_Data_St = 10,
  TsipChecksum_St = 11,
  TsipEof1_St = 12,
  TsipEof2_St = 13;

parameter [2:0]
  ConvertYears_St = 1,
  ConvertMonths_St = 2,
  ConvertDays_St = 3,
  ConvertHours_St = 4,
  ConvertMinutes_St = 5,
  CalcTai_St = 6,
  TimeAdjust_St = 7;

typedef struct packed {
    logic Leap59;                    
    logic Leap61;                    
    logic LeapAnnouncement;          
    logic LeapChangeValid;           
    logic [7:0] SrcOfCurLeapSecond;  
    logic [31:0] TimeToLeapSecond;   
    logic TimeToLeapSecondValid;     
    logic [7:0] CurrentUtcOffset;    
    logic CurrentUtcOffsetValid;     
    logic [7:0] CurrentTaiGnssOffset;
    logic CurrentTaiGnssOffsetValid; 
} UtcOffsetInfo_Type;

typedef struct packed {
    logic [11:0] Year;    //Year range 1999-2099
    logic [3:0]  Month;   //Month range 1-12
    logic [4:0]  Day;     //Day range 1-31
    logic [4:0]  Hour;    //Hour range 1-24
    logic [5:0]  Minute;  //Minute range 0-59
    logic [5:0]  Second;  //Second range 0-60
    logic        Valid;   
} ToD_Type;

typedef struct packed {
    logic [7:0] NumberOfSeenSats;   
    logic [7:0] NumberOfLockedSats; // the Satellite is counted in if it has flags: (QualityInd>=4 and Health==1)
} SatInfo_Type;

typedef struct packed {
    logic [2:0] Status;   //  0=INIT, 1=DONTKNOW, 2=OK, 3=SHORT, 4=OPEN
    logic [1:0] JamState; 
    logic [7:0] JamInd;   
} AntennaInfo_Type;

typedef struct packed {
    logic [7:0] GnssFix;      
    logic       GnssFixOk;    
    logic [1:0] SpoofDetState;
} AntennaFix_Type;

typedef int ClksPerUartBit_Array_Type [2:9];
localparam ClksPerUartBit_Array_Type ClksPerUartBit_Array_Con = '{
    2: (1000000000 / 4800) / ClockPeriod_Gen,  
    3: (1000000000 / 9600) / ClockPeriod_Gen,  
    4: (1000000000 / 19200) / ClockPeriod_Gen, 
    5: (1000000000 / 38400) / ClockPeriod_Gen, 
    6: (1000000000 / 57600) / ClockPeriod_Gen, 
    7: (1000000000 / 115200) / ClockPeriod_Gen,
    8: (1000000000 / 230400) / ClockPeriod_Gen,
    9: (1000000000 / 460800) / ClockPeriod_Gen 
};

// RX UART 
//parameter [31:0] ClksPerUartBit_Array_Con[10] = '{0, 0, 
	//(1000000000 / 4800) / ClockPeriod_Gen,   // 2
    //(1000000000 / 9600) / ClockPeriod_Gen,   // 3
    //(1000000000 / 19200) / ClockPeriod_Gen,  // 4
    //(1000000000 / 38400) / ClockPeriod_Gen,  // 5
    //(1000000000 / 57600) / ClockPeriod_Gen,  // 6
    //(1000000000 / 115200) / ClockPeriod_Gen, // 7
    //(1000000000 / 230400) / ClockPeriod_Gen, // 8
    //(1000000000 / 460800) / ClockPeriod_Gen  // 9
//};
// UBX Messages
parameter Ubx_Sync_Con = 16'h62B5;  // received in little endian
parameter UbxMon_Class_Con = 8'h0A;
parameter UbxNav_Class_Con = 8'h01;
parameter UbxMonHw_Id_Con = 8'h09;
parameter UbxMonHw_Length_Con = 16'h003C;  // received in little endian
parameter UbxMonHw_OffsetAntStatus_Con = 16'h0014;
parameter UbxMonHw_OffsetJamState_Con = 16'h0016;
parameter UbxMonHw_OffsetJamInd_Con = 16'h002D;
parameter UbxNavSat_Id_Con = 8'h35;
parameter UbxNavSat_OffsetSatNr_Con = 16'h0005;
parameter UbxNavSat_OffsetLoopStart_Con = 16'h0008;  // loop starts at 8th Byte of the message
parameter UbxNavSat_OffsetLoopLength_Con = 4'hC;  // each loop is 12 Bytes
parameter UbxNavSat_OffsetQualInd_Con = 4'h8;  // offset of QualInd at each 12-byte loop 
parameter UbxNavStatus_Id_Con = 8'h03;
parameter UbxNavStatus_Length_Con = 16'h0010;  // received in little endian
parameter UbxNavStatus_OffsetGnssFix_Con = 16'h0004;
parameter UbxNavStatus_OffsetGnssFixOk_Con = 16'h0005;
parameter UbxNavStatus_OffsetSpoofDet_Con = 16'h0007;
parameter UbxNavTimeLs_Id_Con = 8'h26;
parameter UbxNavTimeLs_Length_Con = 16'h0018;  // received in little endian
parameter UbxNavTimeLs_OffsetSrcCurrLs_Con = 16'h0008;
parameter UbxNavTimeLs_OffsetCurrLs_Con = 16'h0009;
parameter UbxNavTimeLs_SrcLsChange_Con = 16'h000A;
parameter UbxNavTimeLs_OffsetLsChange_Con = 16'h000B;
parameter UbxNavTimeLs_OffsetTimeToLs_Con = 16'h000C;
parameter UbxNavTimeLs_OffsetValidLs_Con = 16'h0017;
parameter UbxNavTimeUtc_Id_Con = 8'h21;
parameter UbxNavTimeUtc_Length_Con = 16'h0014;  // received in little endian
parameter UbxNavTimeUtc_OffsetYear_Con = 16'h000C;
parameter UbxNavTimeUtc_OffsetMonth_Con = 16'h000E;
parameter UbxNavTimeUtc_OffsetDay_Con = 16'h000F;
parameter UbxNavTimeUtc_OffsetHour_Con = 16'h0010;
parameter UbxNavTimeUtc_OffsetMinute_Con = 16'h0011;
parameter UbxNavTimeUtc_OffsetSecond_Con = 16'h0012;
parameter UbxNavTimeUtc_OffsetUtcValid_Con = 16'h0013;
parameter MsgTimeoutMillisecond_Con = 3000;  // message reception timeout of 3s
parameter NanosInMillisecond_Con = 1000000;
localparam UtcOffsetInfo_Type UtcOffsetInfo_Type_Reset = '{
    Leap59: 1'b0,
    Leap61: 1'b0,
    LeapAnnouncement: 1'b0,
    LeapChangeValid: 1'b0,
    SrcOfCurLeapSecond: 8'b0,
    TimeToLeapSecond: 32'b0, 
    TimeToLeapSecondValid: 1'b0,
    CurrentUtcOffset: 8'b0,
    CurrentUtcOffsetValid: 1'b0,
    CurrentTaiGnssOffset: 8'b0,
    CurrentTaiGnssOffsetValid: 1'b0
};
localparam ToD_Type ToD_Type_Reset = '{
    Year: 12'h7B2, // 1970
    Month: 4'b1,
    Day: 5'b1, 
    Hour: 5'b0, 
    Minute: 6'b0, 
    Second: 6'b0,
    Valid: 1'b0
};
localparam SatInfo_Type SatInfo_Type_Reset = '{
    NumberOfSeenSats: 8'b0, 
    NumberOfLockedSats: 8'b0
};
localparam AntennaInfo_Type AntennaInfo_Type_Reset = '{
    Status: 3'b001,     
    JamState: 2'b00,    
    JamInd: 8'b0
};
localparam AntennaFix_Type AntennaFix_Type_Reset = '{
    GnssFix: 8'b0, 
    GnssFixOk: 1'b0,      
    SpoofDetState: 2'b00  
};

// TOD Slave version
parameter [7:0]TodSlaveMajorVersion_Con = 0;
parameter [7:0]TodSlaveMinorVersion_Con = 2;
parameter [15:0]TodSlaveBuildVersion_Con = 3;
parameter [31:0]TodSlaveVersion_Con = { TodSlaveMajorVersion_Con,TodSlaveMinorVersion_Con,TodSlaveBuildVersion_Con }; 
// TAI conversion 
parameter [31:0]SecondsPerMinute_Con = 60;
parameter [31:0]SecondsPerHour_Con = 60 * SecondsPerMinute_Con;
parameter [31:0]SecondsPerDay_Con = 24 * SecondsPerHour_Con;
parameter [31:0] SecondsPerMonthArray_Con[13] = '{0, 
	31 * SecondsPerDay_Con,
	28 * SecondsPerDay_Con,
	31 * SecondsPerDay_Con,
	30 * SecondsPerDay_Con,
	31 * SecondsPerDay_Con,
	30 * SecondsPerDay_Con,
	31 * SecondsPerDay_Con,
	31 * SecondsPerDay_Con,
	30 * SecondsPerDay_Con,
	31 * SecondsPerDay_Con,
	30 * SecondsPerDay_Con,
	31 * SecondsPerDay_Con }; // January to December
parameter SecondsPerYear_Con = 365 * SecondsPerDay_Con; 
// TSIPv1 constants
parameter Tsip_Delimiter1_Con = 8'h10;
parameter Tsip_Delimiter2_Con = 8'h03;
parameter TsipTiming_ID_Con = 16'hA100;
parameter TsipPosition_ID_Con = 16'hA111;
parameter TsipSatellite_ID_Con = 16'hA200;
parameter TsipAlarms_ID_Con = 16'hA300;
parameter TsipReceiver_ID_Con = 16'hA311;
parameter TsipModeResponse_Con = 8'h02;  // Tsip message offsets
parameter TsipLengthOffset_Con = 16'h0003;  // offset of payload counter to length counter
parameter TsipPosition_OffsetFixType_Con = 16'h0007;
parameter TsipReceiver_OffsetMode_Con = 16'h0006;
parameter TsipReceiver_OffsetStatus_Con = 16'h0007;
parameter TsipTiming_OffsetHours_Con = 16'h000C;
parameter TsipTiming_OffsetMinutes_Con = 16'h000D;
parameter TsipTiming_OffsetSeconds_Con = 16'h000E;
parameter TsipTiming_OffsetMonth_Con = 16'h000F;
parameter TsipTiming_OffsetDay_Con = 16'h0010;
parameter TsipTiming_OffsetYearHigh_Con = 16'h0011;
parameter TsipTiming_OffsetYearLow_Con = 16'h0012;
parameter TsipTiming_OffsetTimebase_Con = 16'h0013;
parameter TsipTiming_OffsetFlags_Con = 16'h0015;
parameter TsipTiming_OffsetUtcOffsetHigh_Con = 16'h0016;
parameter TsipTiming_OffsetUtcOffsetLow_Con = 16'h0017;
parameter TsipTiming_OffsetMinorAlarmsHigh_Con = 16'h0008;
parameter TsipTiming_OffsetMinorAlarmsLow_Con = 16'h0009;
parameter TsipTiming_OffsetMajorAlarmsHigh_Con = 16'h0010;
parameter TsipTiming_OffsetMajorAlarmsLow_Con = 16'h0011;
parameter TsipSatellite_OffsetId_Con = 16'h0008;
parameter TsipSatellite_OffsetFlags_Con = 16'h0018;
parameter TsipReceiver_ModeODC_Con = 8'h06;  // overdetermined clock
parameter TsipReceiver_SatusGnssFix_Con = 8'hFF;  // Gnss time fix in overdetermined mode
// AXI registers                                                  Addr       , Mask       , RW  , Reset
Axi_Reg_Type TodSlaveControl_Reg_Con          = '{Addr:32'h00000000, Mask:32'h3F1FF801, RegType:Rw_E, Reset:32'h00000000};
Axi_Reg_Type TodSlaveStatus_Reg_Con           = '{Addr:32'h00000004, Mask:32'h00000007, RegType:Wc_E, Reset:32'h00000000};
Axi_Reg_Type TodSlaveUartPolarity_Reg_Con     = '{Addr:32'h00000008, Mask:32'h00000001, RegType:Rw_E, Reset:32'h00000000};
Axi_Reg_Type TodSlaveVersion_Reg_Con          = '{Addr:32'h0000000C, Mask:32'hFFFFFFFF, RegType:Ro_E, Reset:TodSlaveVersion_Con};
Axi_Reg_Type TodSlaveCorrection_Reg_Con       = '{Addr:32'h00000010, Mask:32'hFFFFFFFF, RegType:Ro_E, Reset:32'h00000000}; // unused!
Axi_Reg_Type TodSlaveUartBaudRate_Reg_Con     = '{Addr:32'h00000020, Mask:32'h0000000F, RegType:Rw_E, Reset:32'h00000002}; // UBX allowed baudrate: 2=>4800 3=>9600 4=>19200 5=>38400 6=>57600 7=>115200 8=>230400 9=>460800
Axi_Reg_Type TodSlaveUtcStatus_Reg_Con        = '{Addr:32'h00000030, Mask:32'h000171FF, RegType:Ro_E, Reset:32'h00000000};
Axi_Reg_Type TodSlaveTimeToLeapSecond_Reg_Con = '{Addr:32'h00000034, Mask:32'hFFFFFFFF, RegType:Ro_E, Reset:32'h00000000};
Axi_Reg_Type TodSlaveAntennaStatus_Reg_Con    = '{Addr:32'h00000040, Mask:32'h37FF1FFF, RegType:Ro_E, Reset:32'h00000000}; 
Axi_Reg_Type TodSlaveSatNumber_Reg_Con        = '{Addr:32'h00000044, Mask:32'h0001FFFF, RegType:Ro_E, Reset:32'h00000000};
parameter TodSlaveControl_EnTsipBit_Con = 29;
parameter TodSlaveControl_EnUbxBit_Con = 28;
parameter TodSlaveControl_DisUbxNavSatBit_Con = 20;
parameter TodSlaveControl_DisUbxHwMonBit_Con = 19;
parameter TodSlaveControl_DisUbxNavStatusBit_Con = 18;
parameter TodSlaveControl_DisUbxNavTimeUtcBit_Con = 17;
parameter TodSlaveControl_DisUbxNavTimeLsBit_Con = 16;
parameter TodSlaveControl_DisTsipSatelliteBit_Con = 20;
parameter TodSlaveControl_DisTsipPositionBit_Con = 19;
parameter TodSlaveControl_DisTsipReceiverBit_Con = 18;
parameter TodSlaveControl_DisTsipTimingBit_Con = 17;
parameter TodSlaveControl_DisTsipAlarmsBit_Con = 16;
parameter TodSlaveControl_EnableBit_Con = 0;
parameter TodSlaveStatus_ParserErrorBit_Con = 0;
parameter TodSlaveStatus_ChecksumErrorBit_Con = 1;
parameter TodSlaveStatus_UartErrorBit_Con = 2;
parameter TodSlaveUartPolarity_PolarityBit_Con = 0;
parameter TodSlaveUtcStatus_UtcOffsetValidBit_Con = 8;
parameter TodSlaveUtcStatus_LeapAnnounceBit_Con = 12;
parameter TodSlaveUtcStatus_Leap59Bit_Con = 13;
parameter TodSlaveUtcStatus_Leap61Bit_Con = 14;
parameter TodSlaveUtcStatus_LeapInfoValidBit_Con = 16; 

// Rx Uart converted to Msg byte with valid flag
(* mark_debug = "true" *) wire [31:0] ClksPerUartBit_Dat;
(* mark_debug = "true" *) reg [31:0] ClksPerUartBitCounter_CntReg = 0;
(* mark_debug = "true" *) reg [31:0] BitsPerMsgDataCounter_CntReg = 0;
reg [7:0] MsgData_DatReg;
reg MsgDataValid_ValReg;
(* mark_debug = "true" *) reg [1:0] RxUart_ShiftReg;
(* mark_debug = "true" *) reg RxUart_DatReg;
reg RxUart_DatOldReg;
(* mark_debug = "true" *) reg [1:0] UartRxState_StaReg;
wire UartPolarity_Dat;
(* mark_debug = "true" *) reg UartError_DatReg; 
// ToD control
wire Enable_Ena;
wire Enable_Ubx_Ena;
wire Disable_UbxNavSat_Ena;
wire Disable_UbxHwMon_Ena;
wire Disable_UbxNavStatus_Ena;
wire Disable_UbxNavTimeUtc_Ena;
wire Disable_UbxNavTimeLs_Ena; 
// Decode msg 
reg [3:0] DetectUbxMsgState = Idle_St;
reg [15:0] UbxPayloadCount_CntReg = 16'h0000;
reg UbxParseError_DatReg;
reg UbxChecksumError_DatReg;
reg UbxCheckLengthFlag_DatReg;
reg [7:0] UbxChecksumA_DatReg = 1'b0;
reg [7:0] UbxChecksumB_DatReg = 1'b0;
reg CheckMsg_UbxMonHw_DatReg = 1'b0;
reg CheckMsg_UbxNavSat_DatReg = 1'b0;
reg CheckMsg_UbxNavStatus_DatReg = 1'b0;
reg CheckMsg_UbxNavTimeLs_DatReg = 1'b0;
reg CheckMsg_UbxNavTimeUtc_DatReg = 1'b0; 
AntennaInfo_Type AntennaInfo_DatReg = AntennaInfo_Type_Reset; 
reg AntennaInfoValid_ValReg = 1'b0;
reg AntennaInfoValid_ValOldReg = 1'b0; 
AntennaFix_Type AntennaFix_DatReg = AntennaFix_Type_Reset;
reg AntennaFixValid_ValReg = 1'b0;
reg AntennaFixValid_ValOldReg = 1'b0; 
SatInfo_Type SatInfo_DatReg = SatInfo_Type_Reset;
reg SatInfoValid_ValReg = 1'b0;
reg SatInfoValid_ValOldReg = 1'b0;
reg [15:0] UbxNavSat_Length_DatReg = 1'b0;
reg [7:0] UbxNavSat_SatCounter_DatReg = 1'b0;  // UBX-NAV-SAT has a dynamic length depending on the number of the seen Sats
reg [3:0] UbxNavSat_InLoopCounter_DatReg = 1'b0;  // UBX-NAV-SAT has a dynamic length , for each seen Sat there is info of 12 bytes 
reg UbxNavSat_Loop_DatReg = 1'b0; 
UtcOffsetInfo_Type UtcOffsetInfo_DatReg = UtcOffsetInfo_Type_Reset;
reg UtcOffsetInfoValid_ValReg;
reg UtcOffsetInfoValid_ValOldReg; 
ToD_Type RxToD_DatReg = ToD_Type_Reset;
reg RxToDValid_ValReg;
reg RxToDValid_ValOldReg; 
// Message timeout
reg [31:0] UbxNavSat_TimeoutCounter_CntReg = 0;
reg [31:0] UbxHwMon_TimeoutCounter_CntReg = 0;
reg [31:0] UbxNavStatus_TimeoutCounter_CntReg = 0;
reg [31:0] UbxNavTimeUtc_TimeoutCounter_CntReg = 0;
reg [31:0] UbxNavTimeLs_TimeoutCounter_CntReg = 0;
reg [31:0] MillisecondCounter_CntReg = 0;
reg MillisecondFlag_EvtReg = 1'b0;
reg UbxNavSat_Timeout_EvtReg = 1'b0;
reg UbxHwMon_Timeout_EvtReg = 1'b0;
reg UbxNavStatus_Timeout_EvtReg = 1'b0;
reg UbxNavTimeUtc_Timeout_EvtReg = 1'b0;
reg UbxNavTimeLs_Timeout_EvtReg = 1'b0;
reg [NanosecondWidth_Con - 1:0] ClockTime_Nanosecond_DatReg;
reg [NanosecondWidth_Con - 1:0] ClockTime_Nanosecond_OldDatReg; 
// TAI conversion
reg [SecondWidth_Con - 1:0] ClockTime_Second_DatReg = 1'b0;
reg [SecondWidth_Con - 1:0] TimeAdjustment_Second_DatReg = 1'b0;
reg [NanosecondWidth_Con - 1:0] TimeAdjustment_Nanosecond_DatReg = 1'b0;
reg TimeAdjustment_ValReg;
reg [SecondWidth_Con - 1:0] GnssTime_Second_DatReg = 1'b0;
reg [2:0] TaiConversionState_StaReg = Idle_St;
reg LeapYear_DatReg;
reg SkipTaiConversion_ValReg;
reg [31:0] TimeCounter_CntReg = 0;
reg [31:0] Year_004_Counter_CntReg = 0;  // leap year every 4 years 
reg [31:0] Year_100_Counter_CntReg = 0;  // no leap year every 100 years
reg [31:0] Year_400_Counter_CntReg = 0;  // leap year every 400 years
ToD_Type ToD_DatReg = ToD_Type_Reset;
reg ToDValid_ValReg; 
// Trimble Standatd Interface Protocol v1 (TSIPv1) related signals
wire Enable_Tsip_Ena; 
reg [3:0] DetectTsipMsgState;
reg [7:0] MsgDataOld_DatReg;
reg MsgDataOldValid_ValReg;
reg [7:0] TsipMsgData_DatReg;
reg TsipMsgDataValid_ValReg;
reg TsipPaddingSkipped_DatReg;
reg [7:0] TsipChecksum_DatReg;
reg TsipEoF_DatReg = 1'b0;
reg TsipMsg_A1_DatReg = 1'b0;
reg TsipMsg_A2_DatReg = 1'b0;
reg TsipMsg_A3_DatReg = 1'b0;
reg TsipTiming_DatReg = 1'b0;
reg TsipPosition_DatReg = 1'b0;
reg TsipSatellite_DatReg = 1'b0;
reg TsipAlarms_DatReg = 1'b0;
reg TsipReceiver_DatReg = 1'b0;
reg [15:0] TsipLength_DatReg = 1'b0;
reg [15:0] TsipPayloadCount_CntReg = 1'b0;
reg TsipParseError_DatReg = 1'b0;
reg TsipChecksumError_DatReg = 1'b0;
reg TsipPosition_MsgVal_ValReg = 1'b0;
reg TsipPosition_MsgValOld_ValReg = 1'b0;
reg TsipReceiver_MsgVal_ValReg = 1'b0;
reg TsipReceiver_MsgValOld_ValReg = 1'b0;
reg TsipTiming_MsgVal_ValReg = 1'b0;
reg TsipTiming_MsgValOld_ValReg = 1'b0;
reg TsipAlarms_MsgVal_ValReg = 1'b0;
reg TsipAlarms_MsgValOld_ValReg = 1'b0;
reg TsipSatellite_MsgVal_ValReg = 1'b0;
reg TsipSatellite_MsgValOld_ValReg = 1'b0;
reg TsipReceiver_ODC_DatReg = 1'b0;
reg TsipAlarms_NoSatellites_DatReg = 1'b0;
reg TsipAlarms_ClearSatellites_DatReg = 1'b0;
reg TsipAlarms_NoPps_DatReg = 1'b0;
reg TsipAlarms_BadPps_DatReg = 1'b0; 
SatInfo_Type TsipSatellite_CntSatellites_DatReg = SatInfo_Type_Reset; // temp store of the satellite counters until a same satellite is seen again (a 'round' has completed)
reg TsipSatellite_IncreaseSeenSat_DatReg = 1'b0;  // temp mark a satellite as seen, until the message is validated 
reg TsipSatellite_IncreaseLockSat_DatReg = 1'b0;  // temp mark a satellite as locked, until the message is validated
wire Disable_TsipTiming_Ena;
wire Disable_TsipPosition_Ena;
wire Disable_TsipReceiver_Ena;
wire Disable_TsipAlarms_Ena;
wire Disable_TsipSatellite_Ena;
reg [31:0] TsipTiming_TimeoutCounter_CntReg = 0;
reg [31:0] TsipAlarms_TimeoutCounter_CntReg = 0;
reg [31:0] TsipReceiver_TimeoutCounter_CntReg = 0;
reg [31:0] TsipPosition_TimeoutCounter_CntReg = 0;
reg [31:0] TsipSatellite_TimeoutCounter_CntReg = 0;
reg TsipTiming_Timeout_EvtReg = 1'b0;
reg TsipAlarms_Timeout_EvtReg = 1'b0;
reg TsipReceiver_Timeout_EvtReg = 1'b0;
reg TsipPosition_Timeout_EvtReg = 1'b0;
reg TsipSatellite_Timeout_EvtReg = 1'b0; 
// Axi Regs
reg [1:0] Axi_AccessState_StaReg = Axi_AccessState_Type_Rst_Con;
reg AxiWriteAddrReady_RdyReg;
reg AxiWriteDataReady_RdyReg;
reg AxiWriteRespValid_ValReg;
reg [1:0] AxiWriteRespResponse_DatReg;
reg AxiReadAddrReady_RdyReg;
reg AxiReadDataValid_ValReg;
reg [1:0] AxiReadDataResponse_DatReg;
reg [31:0] AxiReadDataData_DatReg;
reg [31:0] TodSlaveControl_DatReg;
reg [31:0] TodSlaveStatus_DatReg;
reg [31:0] TodSlaveUartPolarity_DatReg;
reg [31:0] TodSlaveVersion_DatReg;
reg [31:0] TodSlaveCorrection_DatReg;
reg [31:0] TodSlaveUartBaudRate_DatReg;
reg [31:0] TodSlaveUtcStatus_DatReg;
reg [31:0] TodSlaveTimeToLeapSecond_DatReg;
reg [31:0] TodSlaveAntennaStatus_DatReg;
reg [31:0] TodSlaveSatNumber_DatReg; 

  assign Enable_Ena = TodSlaveControl_DatReg[TodSlaveControl_EnableBit_Con];
  assign Enable_Ubx_Ena = TodSlaveControl_DatReg[TodSlaveControl_EnUbxBit_Con];
  assign Enable_Tsip_Ena = (TodSlaveControl_DatReg[TodSlaveControl_EnTsipBit_Con]) & ( ~TodSlaveControl_DatReg[TodSlaveControl_EnUbxBit_Con]);
  // Ensure UBX is disabled , if TSIPv1 is enabled. Else, select UBX 
  assign Disable_UbxNavSat_Ena = (TodSlaveControl_DatReg[TodSlaveControl_DisUbxNavSatBit_Con]) | ( ~TodSlaveControl_DatReg[TodSlaveControl_EnUbxBit_Con]);
  assign Disable_UbxHwMon_Ena = (TodSlaveControl_DatReg[TodSlaveControl_DisUbxHwMonBit_Con]) | ( ~TodSlaveControl_DatReg[TodSlaveControl_EnUbxBit_Con]);
  assign Disable_UbxNavStatus_Ena = (TodSlaveControl_DatReg[TodSlaveControl_DisUbxNavStatusBit_Con]) | ( ~TodSlaveControl_DatReg[TodSlaveControl_EnUbxBit_Con]);
  assign Disable_UbxNavTimeUtc_Ena = (TodSlaveControl_DatReg[TodSlaveControl_DisUbxNavTimeUtcBit_Con]) | ( ~TodSlaveControl_DatReg[TodSlaveControl_EnUbxBit_Con]);
  assign Disable_UbxNavTimeLs_Ena = (TodSlaveControl_DatReg[TodSlaveControl_DisUbxNavTimeLsBit_Con]) | ( ~TodSlaveControl_DatReg[TodSlaveControl_EnUbxBit_Con]);
  assign Disable_TsipTiming_Ena = (TodSlaveControl_DatReg[TodSlaveControl_DisTsipTimingBit_Con]) | ( ~TodSlaveControl_DatReg[TodSlaveControl_EnTsipBit_Con]);
  assign Disable_TsipPosition_Ena = (TodSlaveControl_DatReg[TodSlaveControl_DisTsipPositionBit_Con]) | ( ~TodSlaveControl_DatReg[TodSlaveControl_EnTsipBit_Con]);
  assign Disable_TsipReceiver_Ena = (TodSlaveControl_DatReg[TodSlaveControl_DisTsipReceiverBit_Con]) | ( ~TodSlaveControl_DatReg[TodSlaveControl_EnTsipBit_Con]);
  assign Disable_TsipAlarms_Ena = (TodSlaveControl_DatReg[TodSlaveControl_DisTsipAlarmsBit_Con]) | ( ~TodSlaveControl_DatReg[TodSlaveControl_EnTsipBit_Con]);
  assign Disable_TsipSatellite_Ena = (TodSlaveControl_DatReg[TodSlaveControl_DisTsipSatelliteBit_Con]) | ( ~TodSlaveControl_DatReg[TodSlaveControl_EnTsipBit_Con]);
  assign UartPolarity_Dat = TodSlaveUartPolarity_DatReg[TodSlaveUartPolarity_PolarityBit_Con];
  assign ClksPerUartBit_Dat = (TodSlaveUartBaudRate_DatReg[3:0] == (2)) ? ClksPerUartBit_Array_Con[2] : (TodSlaveUartBaudRate_DatReg[3:0] == (3)) ? ClksPerUartBit_Array_Con[3] : (TodSlaveUartBaudRate_DatReg[3:0] == (4)) ? ClksPerUartBit_Array_Con[4] : (TodSlaveUartBaudRate_DatReg[3:0] == (5)) ? ClksPerUartBit_Array_Con[5] : (TodSlaveUartBaudRate_DatReg[3:0] == (6)) ? ClksPerUartBit_Array_Con[6] : (TodSlaveUartBaudRate_DatReg[3:0] == (7)) ? ClksPerUartBit_Array_Con[7] : (TodSlaveUartBaudRate_DatReg[3:0] == (8)) ? ClksPerUartBit_Array_Con[8] : (TodSlaveUartBaudRate_DatReg[3:0] == (9)) ? ClksPerUartBit_Array_Con[9] : ClksPerUartBit_Array_Con[UartDefaultBaudRate_Gen];
  initial begin
	  $display(ClksPerUartBit_Array_Con);
  end
  // Default BaudRate 
  assign AxiWriteAddrReady_RdyOut = AxiWriteAddrReady_RdyReg;
  assign AxiWriteDataReady_RdyOut = AxiWriteDataReady_RdyReg;
  assign AxiWriteRespValid_ValOut = AxiWriteRespValid_ValReg;
  assign AxiWriteRespResponse_DatOut = AxiWriteRespResponse_DatReg;
  assign AxiReadAddrReady_RdyOut = AxiReadAddrReady_RdyReg;
  assign AxiReadDataValid_ValOut = AxiReadDataValid_ValReg;
  assign AxiReadDataResponse_DatOut = AxiReadDataResponse_DatReg;
  assign AxiReadDataData_DatOut = AxiReadDataData_DatReg;
  assign TimeAdjustment_Second_DatOut = TimeAdjustment_Second_DatReg;
  assign TimeAdjustment_Nanosecond_DatOut = TimeAdjustment_Nanosecond_DatReg;
  assign TimeAdjustment_ValOut = TimeAdjustment_ValReg;

  // metastability registers
  always @(posedge SysClk_ClkIn, posedge SysRstN_RstIn) begin
    if(SysRstN_RstIn == 1'b0) begin
      RxUart_ShiftReg <= {2{1'b0}};
      RxUart_DatReg <= 1'b0;
    end else begin
      RxUart_ShiftReg[1] <= RxUart_ShiftReg[0];
      RxUart_ShiftReg[0] <= RxUart_DatIn;
      if(UartPolarity_Dat) begin
        // use the input value or its inversion depending on the polarity configuration 
        RxUart_DatReg <= RxUart_ShiftReg[1];
      end else begin
        RxUart_DatReg <=  ~RxUart_ShiftReg[1];
      end
    end
  end

  // RxUart FSM. The UART message sequence is Start(1bit)=>Data(8bits)=>Stop(1bit) (no parity)
  always @(posedge SysClk_ClkIn, posedge SysRstN_RstIn) begin
    if(SysRstN_RstIn == 1'b0) begin
      UartRxState_StaReg <= Idle_St;
      MsgDataValid_ValReg <= 1'b0;
      MsgData_DatReg <= {8{1'b0}};
      RxUart_DatOldReg <= 1'b0;
      ClksPerUartBitCounter_CntReg <= 0;
      BitsPerMsgDataCounter_CntReg <= 0;
      UartError_DatReg <= 1'b0;
    end else begin
      RxUart_DatOldReg <= RxUart_DatReg;
      MsgDataValid_ValReg <= 1'b0;
      UartError_DatReg <= 1'b0;
      case(UartRxState_StaReg)
      Idle_St : begin
        MsgData_DatReg <= {8{1'b0}};
        ClksPerUartBitCounter_CntReg <= 0;
        BitsPerMsgDataCounter_CntReg <= 0;
        if(RxUart_DatReg == 1'b0 && RxUart_DatOldReg == 1'b1) begin
          // it could be a Start bit
          ClksPerUartBitCounter_CntReg <= ((ClksPerUartBit_Dat) >> 1) - 1;
          // count down to the middle of the bit-reception cycle
          UartRxState_StaReg <= Start_St;
        end
      end
      Start_St : begin
        if(ClksPerUartBitCounter_CntReg > 0) begin
          ClksPerUartBitCounter_CntReg <= ClksPerUartBitCounter_CntReg - 1;
        end else begin
          if(RxUart_DatReg == 1'b0) begin
            // verify that the Start bit is as expected
            ClksPerUartBitCounter_CntReg <= ClksPerUartBit_Dat - 1;
            // count down to the middle of the next bit-reception cycle
            UartRxState_StaReg <= Data_St;
          end else begin
            UartError_DatReg <= 1'b1;
            // raise an error when the byte-read was incomplete
            UartRxState_StaReg <= Idle_St;
          end
        end
      end
      Data_St : begin
        if(ClksPerUartBitCounter_CntReg > 0) begin
          ClksPerUartBitCounter_CntReg <= ClksPerUartBitCounter_CntReg - 1;
        end else begin
          MsgData_DatReg[BitsPerMsgDataCounter_CntReg] <= RxUart_DatReg;
          // assign the uart bit to the byte data
          ClksPerUartBitCounter_CntReg <= ClksPerUartBit_Dat - 1;
          // count down to the middle of the next bit-reception cycle
          if(BitsPerMsgDataCounter_CntReg < 7) begin
            // if not all of the data have been read, stay here
            BitsPerMsgDataCounter_CntReg <= BitsPerMsgDataCounter_CntReg + 1;
            // prepare for the next bit of the byte
          end else begin
            // the whole byte has been read
            UartRxState_StaReg <= Stop_St;
          end
        end
      end
      Stop_St : begin
        if(ClksPerUartBitCounter_CntReg > 0) begin
          ClksPerUartBitCounter_CntReg <= ClksPerUartBitCounter_CntReg - 1;
        end else begin
          UartRxState_StaReg <= Idle_St;
          if(RxUart_DatReg == 1'b1) begin
            // verify that the Stop bit is as expected
            MsgDataValid_ValReg <= 1'b1;
            // active for 1 clk
          end else begin
            UartError_DatReg <= 1'b1;
            // raise an error when the byte-read was incomplete
          end
        end
      end
      endcase
    end
  end

  // Detect and decode UBX messages. Extract the following information:  
  //   - from MON-HW      => Antenna status and Jamming status
  //   - from NAV-SAT     => Sats Number and Locked Sats
  //   - from NAV-STATUS  => GPS fix
  //   - from NAV-TIMELS  => the current LS, the TimeToLsEvent, if there is LS change coming and to which direction
  //   - from NAV-TIMEUTC => ToD in format YYYYMMDDHHmmSS
  // Detect and decode TSIP messages. Extract the following information:  
  //   - from Timing Info         => ToD in format YYYYMMDDHHmmSS and UTC offset
  //   - from Satellite Info      => Sats Number and Locked Sats (one message per satellite, each sat can be acquired, or acquired and used in time lock)
  //   - from Alarms Info         => pending Leap Second, Jam Indication, Spoof Indication, Antenna Status
  //   - from Position Info       => Gnss fix of the antenna
  //   - from Receiver Info       => Gnss fix OK of the antenna
  always @(posedge SysClk_ClkIn, posedge SysRstN_RstIn) begin
    if(SysRstN_RstIn == 1'b0) begin
      UbxPayloadCount_CntReg <= 16'h0000;
      UbxNavSat_Length_DatReg <= 16'h0000;
      AntennaInfo_DatReg <= AntennaInfo_Type_Reset;
      AntennaInfoValid_ValReg <= 1'b0;
      AntennaFix_DatReg <= AntennaFix_Type_Reset;
      AntennaFixValid_ValReg <= 1'b0;
      UtcOffsetInfo_DatReg <= UtcOffsetInfo_Type_Reset;
      UtcOffsetInfoValid_ValReg <= 1'b0;
      RxToD_DatReg <= ToD_Type_Reset;
      RxToDValid_ValReg <= 1'b0;
      SatInfo_DatReg <= SatInfo_Type_Reset;
      SatInfoValid_ValReg <= 1'b0;
      UbxNavSat_SatCounter_DatReg <= {8{1'b0}};
      UbxNavSat_InLoopCounter_DatReg <= {4{1'b0}};
      UbxNavSat_Loop_DatReg <= 1'b0;
      DetectUbxMsgState <= Idle_St;
      UbxParseError_DatReg <= 1'b0;
      UbxChecksumError_DatReg <= 1'b0;
      UbxCheckLengthFlag_DatReg <= 1'b0;
      UbxChecksumA_DatReg <= {8{1'b0}};
      UbxChecksumB_DatReg <= {8{1'b0}};
      CheckMsg_UbxMonHw_DatReg <= 1'b0;
      CheckMsg_UbxNavSat_DatReg <= 1'b0;
      CheckMsg_UbxNavStatus_DatReg <= 1'b0;
      CheckMsg_UbxNavTimeLs_DatReg <= 1'b0;
      CheckMsg_UbxNavTimeUtc_DatReg <= 1'b0;
      // TSIP decoding signals
      MsgDataOld_DatReg <= {8{1'b0}};
      MsgDataOldValid_ValReg <= 1'b0;
      TsipMsgData_DatReg <= {8{1'b0}};
      TsipMsgDataValid_ValReg <= 1'b0;
      TsipEoF_DatReg <= 1'b0;
      TsipPaddingSkipped_DatReg <= 1'b0;
      TsipChecksum_DatReg <= {8{1'b0}};
      TsipPosition_MsgVal_ValReg <= 1'b0;
      TsipPosition_MsgValOld_ValReg <= 1'b0;
      TsipReceiver_MsgVal_ValReg <= 1'b0;
      TsipReceiver_MsgValOld_ValReg <= 1'b0;
      TsipTiming_MsgVal_ValReg <= 1'b0;
      TsipTiming_MsgValOld_ValReg <= 1'b0;
      TsipAlarms_MsgVal_ValReg <= 1'b0;
      TsipAlarms_MsgValOld_ValReg <= 1'b0;
      TsipSatellite_MsgVal_ValReg <= 1'b0;
      TsipSatellite_MsgValOld_ValReg <= 1'b0;
      TsipReceiver_ODC_DatReg <= 1'b0;
      TsipAlarms_NoSatellites_DatReg <= 1'b0;
      TsipAlarms_ClearSatellites_DatReg <= 1'b0;
      TsipAlarms_NoPps_DatReg <= 1'b0;
      TsipAlarms_BadPps_DatReg <= 1'b0;
      TsipSatellite_CntSatellites_DatReg <= SatInfo_Type_Reset;
      TsipSatellite_IncreaseSeenSat_DatReg <= 1'b0;
      TsipSatellite_IncreaseLockSat_DatReg <= 1'b0;
      TsipParseError_DatReg <= 1'b0;
      TsipChecksumError_DatReg <= 1'b0;
      ClockTime_Nanosecond_DatReg <= {((NanosecondWidth_Con - 1)-(0)+1){1'b0}};
      ClockTime_Nanosecond_OldDatReg <= {((NanosecondWidth_Con - 1)-(0)+1){1'b0}};
    end else begin
      UbxParseError_DatReg <= 1'b0;
      UbxChecksumError_DatReg <= 1'b0;
      ClockTime_Nanosecond_DatReg <= ClockTime_Nanosecond_DatIn;
      ClockTime_Nanosecond_OldDatReg <= ClockTime_Nanosecond_DatReg;
      // Decoding of the UBX messages
      // The data valid flag is active for 1 clk per byte data 
      if(MsgDataValid_ValReg == 1'b1) begin
        case(DetectUbxMsgState)
        Idle_St : begin
          CheckMsg_UbxMonHw_DatReg <= 1'b0;
          CheckMsg_UbxNavSat_DatReg <= 1'b0;
          CheckMsg_UbxNavStatus_DatReg <= 1'b0;
          CheckMsg_UbxNavTimeLs_DatReg <= 1'b0;
          CheckMsg_UbxNavTimeUtc_DatReg <= 1'b0;
          UbxPayloadCount_CntReg <= 16'h0000;
          UbxCheckLengthFlag_DatReg <= 1'b0;
          UbxChecksumA_DatReg <= {8{1'b0}};
          UbxChecksumB_DatReg <= {8{1'b0}};
          UbxNavSat_SatCounter_DatReg <= {8{1'b0}};
          UbxNavSat_InLoopCounter_DatReg <= {4{1'b0}};
          UbxNavSat_Loop_DatReg <= 1'b0;
          // Start decoding only if the UBX messages are enabled
          if(Enable_Ubx_Ena == 1'b1) begin
            if(MsgData_DatReg == Ubx_Sync_Con[7:0]) begin
              DetectUbxMsgState <= UbxHeader_Sync_St;
            end
          end
        end
        UbxHeader_Sync_St : begin
          if(MsgData_DatReg == Ubx_Sync_Con[15:8]) begin
            DetectUbxMsgState <= UbxHeader_Class_St;
          end
          else begin
            DetectUbxMsgState <= Idle_St;
            UbxParseError_DatReg <= 1'b1;
            // invalid frame
          end
        end
        UbxHeader_Class_St : begin
          UbxChecksumA_DatReg <= UbxChecksumA_DatReg + MsgData_DatReg;
          UbxChecksumB_DatReg <= UbxChecksumB_DatReg + UbxChecksumA_DatReg;
          // ChecksumB gets now the previous value of ChecksumA. Its latest value will be added later.
          if(MsgData_DatReg == UbxMon_Class_Con) begin
            DetectUbxMsgState <= UbxHeader_MonId_St;
          end
          else if(MsgData_DatReg == UbxNav_Class_Con) begin
            DetectUbxMsgState <= UbxHeader_NavId_St;
          end
          else begin
            DetectUbxMsgState <= Idle_St;
            // not supported message 
          end
        end
        UbxHeader_MonId_St : begin
          UbxChecksumA_DatReg <= UbxChecksumA_DatReg + (MsgData_DatReg);
          UbxChecksumB_DatReg <= UbxChecksumB_DatReg + UbxChecksumA_DatReg;
          // ChecksumB gets now the previous value of ChecksumA. Its latest value will be added later.
          if(CheckMsg_UbxMonHw_DatReg == 1'b0 && MsgData_DatReg == UbxMonHw_Id_Con) begin
            CheckMsg_UbxMonHw_DatReg <= 1'b1;
          end else if(CheckMsg_UbxMonHw_DatReg == 1'b1) begin
            if(UbxCheckLengthFlag_DatReg == 1'b0 && MsgData_DatReg == UbxMonHw_Length_Con[7:0]) begin
              UbxCheckLengthFlag_DatReg <= 1'b1;
            end else if(UbxCheckLengthFlag_DatReg == 1'b1 && MsgData_DatReg == UbxMonHw_Length_Con[15:8]) begin
              DetectUbxMsgState <= UbxMonHw_CheckPayload_St;
              AntennaInfoValid_ValReg <= 1'b0;
              // invalidate the data when new updated data will be received until the checksum is veirifed
            end else begin
              UbxParseError_DatReg <= 1'b1;
              // the ID has been detected but the length is wrong
              DetectUbxMsgState <= Idle_St;
            end
          end else begin
            DetectUbxMsgState <= Idle_St;
            // not supported message
          end
        end
        UbxHeader_NavId_St : begin
          UbxChecksumA_DatReg <= UbxChecksumA_DatReg + (MsgData_DatReg);
          UbxChecksumB_DatReg <= UbxChecksumB_DatReg + UbxChecksumA_DatReg;
          // ChecksumB gets now the previous value of ChecksumA. Its latest value will be added later.
          if(CheckMsg_UbxNavSat_DatReg == 1'b0 && CheckMsg_UbxNavStatus_DatReg == 1'b0 && CheckMsg_UbxNavTimeLs_DatReg == 1'b0 && CheckMsg_UbxNavTimeUtc_DatReg == 1'b0) begin
            if((MsgData_DatReg == UbxNavSat_Id_Con)) begin
              CheckMsg_UbxNavSat_DatReg <= 1'b1;
            end else if(MsgData_DatReg == UbxNavStatus_Id_Con) begin
              CheckMsg_UbxNavStatus_DatReg <= 1'b1;
            end else if(MsgData_DatReg == UbxNavTimeLs_Id_Con) begin
              CheckMsg_UbxNavTimeLs_DatReg <= 1'b1;
            end else if(MsgData_DatReg == UbxNavTimeUtc_Id_Con) begin
              CheckMsg_UbxNavTimeUtc_DatReg <= 1'b1;
            end else begin
              DetectUbxMsgState <= Idle_St;
              // not supported message
            end
          end else if(CheckMsg_UbxNavSat_DatReg == 1'b1) begin
            if(UbxCheckLengthFlag_DatReg == 1'b0) begin
              UbxNavSat_Length_DatReg[7:0] <= MsgData_DatReg;
              UbxCheckLengthFlag_DatReg <= 1'b1;
            end else begin
              DetectUbxMsgState <= UbxNavSat_CheckPayload_St;
              UbxNavSat_Length_DatReg[15:8] <= MsgData_DatReg;
              SatInfoValid_ValReg <= 1'b0;
              // invalidate the data when new updated data will be received until the checksum is verified
            end
          end else if(CheckMsg_UbxNavStatus_DatReg == 1'b1) begin
            if(UbxCheckLengthFlag_DatReg == 1'b0 && MsgData_DatReg == UbxNavStatus_Length_Con[7:0]) begin
              UbxCheckLengthFlag_DatReg <= 1'b1;
            end else if(UbxCheckLengthFlag_DatReg == 1'b1 && MsgData_DatReg == UbxNavStatus_Length_Con[15:8]) begin
              DetectUbxMsgState <= UbxNavStatus_CheckPayload_St;
              AntennaFixValid_ValReg <= 1'b0;
              // invalidate the data when new updated data will be received until the checksum is verified
            end else begin
              UbxParseError_DatReg <= 1'b1;
              // the ID has been detected but the length is wrong
              DetectUbxMsgState <= Idle_St;
            end
          end
          else if(CheckMsg_UbxNavTimeLs_DatReg == 1'b1) begin
            if(UbxCheckLengthFlag_DatReg == 1'b0 && MsgData_DatReg == UbxNavTimeLs_Length_Con[7:0]) begin
              UbxCheckLengthFlag_DatReg <= 1'b1;
            end else if(UbxCheckLengthFlag_DatReg == 1'b1 && MsgData_DatReg == UbxNavTimeLs_Length_Con[15:8]) begin
              DetectUbxMsgState <= UbxNavTimeLs_CheckPayload_St;
              UtcOffsetInfoValid_ValReg <= 1'b0;
              // invalidate the data when new updated data will be received until the checksum is verified
            end else begin
              UbxParseError_DatReg <= 1'b1;
              // the ID has been detected but the length is wrong
              DetectUbxMsgState <= Idle_St;
            end
          end else if(CheckMsg_UbxNavTimeUtc_DatReg == 1'b1) begin
            if(UbxCheckLengthFlag_DatReg == 1'b0 && MsgData_DatReg == UbxNavTimeUtc_Length_Con[7:0]) begin
              UbxCheckLengthFlag_DatReg <= 1'b1;
            end else if(UbxCheckLengthFlag_DatReg == 1'b1 && MsgData_DatReg == UbxNavTimeUtc_Length_Con[15:8]) begin
              DetectUbxMsgState <= UbxNavTimeUtc_CheckPayload_St;
              RxToDValid_ValReg <= 1'b0;
              // invalidate the data when new updated data will be received until the checksum is verified
            end else begin
              UbxParseError_DatReg <= 1'b1;
              // the ID has been detected but the length is wrong
              DetectUbxMsgState <= Idle_St;
            end
          end else begin
            DetectUbxMsgState <= Idle_St;
            // not supported message
            UbxParseError_DatReg <= 1'b1;
            // the ID has been detected but the length is wrong
          end
          // Extract info from Payload of UBX-MON-HW
        end
        UbxMonHw_CheckPayload_St : begin
          UbxChecksumA_DatReg <= UbxChecksumA_DatReg + (MsgData_DatReg);
          UbxChecksumB_DatReg <= UbxChecksumB_DatReg + UbxChecksumA_DatReg;
          // ChecksumB gets now the previous value of ChecksumA. Its latest value will be added later.
          if(UbxPayloadCount_CntReg == UbxMonHw_OffsetAntStatus_Con) begin
            AntennaInfo_DatReg.Status <= MsgData_DatReg[2:0];
          end else if(UbxPayloadCount_CntReg == UbxMonHw_OffsetJamState_Con) begin
            AntennaInfo_DatReg.JamState <= MsgData_DatReg[3:2];
          end else if(UbxPayloadCount_CntReg == UbxMonHw_OffsetJamInd_Con) begin
            AntennaInfo_DatReg.JamInd <= MsgData_DatReg;
          end if(UbxPayloadCount_CntReg < (UbxMonHw_Length_Con - 1)) begin
            UbxPayloadCount_CntReg <= UbxPayloadCount_CntReg + 1;
          end else begin
            DetectUbxMsgState <= UbxChecksum_ChecksumA_St;
          end
          // Extract info from Payload of UBX-NAV-Sat
        end
        UbxNavSat_CheckPayload_St : begin
          UbxChecksumA_DatReg <= UbxChecksumA_DatReg + MsgData_DatReg;
          UbxChecksumB_DatReg <= UbxChecksumB_DatReg + UbxChecksumA_DatReg;
          // ChecksumB gets now the previous value of ChecksumA. Its latest value will be added later.
          UbxPayloadCount_CntReg <= UbxPayloadCount_CntReg + 1;
          if(UbxPayloadCount_CntReg == UbxNavSat_OffsetSatNr_Con) begin
            SatInfo_DatReg.NumberOfSeenSats <= MsgData_DatReg;
            SatInfo_DatReg.NumberOfLockedSats <= {1{1'b0}};
          end
          else if(UbxPayloadCount_CntReg == (UbxNavSat_OffsetLoopStart_Con - 1)) begin
            UbxNavSat_Loop_DatReg <= 1'b1;
            // at the next valid byte, the loop starts
          end
          // 12-bytes-loop for the number of Sats
          if(UbxNavSat_Loop_DatReg == 1'b1 && (UbxNavSat_SatCounter_DatReg < SatInfo_DatReg.NumberOfSeenSats)) begin
            if(UbxNavSat_InLoopCounter_DatReg < (UbxNavSat_OffsetLoopLength_Con - 1)) begin
              // this is not the last byte of the loop
              UbxNavSat_InLoopCounter_DatReg <= (UbxNavSat_InLoopCounter_DatReg) + 1;
              if(UbxNavSat_InLoopCounter_DatReg == UbxNavSat_OffsetQualInd_Con[3:0]) begin
                if(MsgData_DatReg[2:0] >= 4 && MsgData_DatReg[5:4] == 2'b01) begin
                  // if Signal QualInd (bits 2-0) is locked, and signal health (bits 5-4) is good
                  SatInfo_DatReg.NumberOfLockedSats <= SatInfo_DatReg.NumberOfLockedSats + 1;
                  // consider the receiver locked to the Sat
                end
              end
            end
            else begin
              // this is the last byte of the loop
              if(UbxNavSat_SatCounter_DatReg == (SatInfo_DatReg.NumberOfSeenSats - 1)) begin
                // this is the last byte of the last loop
                DetectUbxMsgState <= UbxChecksum_ChecksumA_St;
              end
              UbxNavSat_InLoopCounter_DatReg <= {4{1'b0}};
              UbxNavSat_SatCounter_DatReg <= UbxNavSat_SatCounter_DatReg + 1;
            end
          end
          else if(UbxNavSat_Loop_DatReg == 1'b1) begin
            DetectUbxMsgState <= Idle_St;
            // parsing error 
            UbxParseError_DatReg <= 1'b1;
          end
          // Extract info from Payload of UBX-NAV-Status
        end
        UbxNavStatus_CheckPayload_St : begin
          UbxChecksumA_DatReg <= UbxChecksumA_DatReg + (MsgData_DatReg);
          UbxChecksumB_DatReg <= UbxChecksumB_DatReg + UbxChecksumA_DatReg;
          // ChecksumB gets now the previous value of ChecksumA. Its latest value will be added later.
          if(UbxPayloadCount_CntReg == UbxNavStatus_OffsetGnssFix_Con) begin
            AntennaFix_DatReg.GnssFix <= MsgData_DatReg;
          end
          else if(UbxPayloadCount_CntReg == UbxNavStatus_OffsetGnssFixOk_Con) begin
            AntennaFix_DatReg.GnssFixOk <= MsgData_DatReg[0];
          end
          else if(UbxPayloadCount_CntReg == UbxNavStatus_OffsetSpoofDet_Con) begin
            AntennaFix_DatReg.SpoofDetState <= MsgData_DatReg[4:3];
          end
          if(UbxPayloadCount_CntReg < (UbxNavStatus_Length_Con - 1)) begin
            UbxPayloadCount_CntReg <= (UbxPayloadCount_CntReg) + 1;
          end
          else begin
            DetectUbxMsgState <= UbxChecksum_ChecksumA_St;
          end
          // Extract info from Payload of UBX-NAV-TimeLs
        end
        UbxNavTimeLs_CheckPayload_St : begin
          UbxChecksumA_DatReg <= UbxChecksumA_DatReg + (MsgData_DatReg);
          UbxChecksumB_DatReg <= UbxChecksumB_DatReg + UbxChecksumA_DatReg;
          // ChecksumB gets now the previous value of ChecksumA. Its latest value will be added later.
          if(UbxPayloadCount_CntReg == UbxNavTimeLs_OffsetSrcCurrLs_Con) begin
            UtcOffsetInfo_DatReg.SrcOfCurLeapSecond <= MsgData_DatReg;
            // offset of the Sat system to UTC
            // get the TAI-UTC offset, since TAI is used by the adjustable clock 
          end
          else if(UbxPayloadCount_CntReg == UbxNavTimeLs_OffsetCurrLs_Con) begin
            //if (UtcOffsetInfo_DatReg.SrcOfCurLeapSecond = x"01" or        -- derived from dif GPS to Glonass
            //UtcOffsetInfo_DatReg.SrcOfCurLeapSecond = x"02" or        -- GPS
            //UtcOffsetInfo_DatReg.SrcOfCurLeapSecond = x"04" or        -- Beidou
            //UtcOffsetInfo_DatReg.SrcOfCurLeapSecond = x"05" or        -- Galileo
            //UtcOffsetInfo_DatReg.SrcOfCurLeapSecond = x"FF") then     -- Unknown
            if(UtcOffsetInfo_DatReg.SrcOfCurLeapSecond == 8'h01 || UtcOffsetInfo_DatReg.SrcOfCurLeapSecond == 8'h02 || UtcOffsetInfo_DatReg.SrcOfCurLeapSecond == 8'h04 || UtcOffsetInfo_DatReg.SrcOfCurLeapSecond == 8'h05 || UtcOffsetInfo_DatReg.SrcOfCurLeapSecond == 8'hFF) begin
              UtcOffsetInfo_DatReg.CurrentUtcOffset <= (MsgData_DatReg) + 19;
              // add the GPS-TAI offset to UTC-GPS offset
              UtcOffsetInfo_DatReg.CurrentTaiGnssOffset <= (MsgData_DatReg) + 19;
              // add the GPS-TAI offset to UTC-GPS offset
            end
            // else retain the last value which was accepted, valid is taken from the receiver directly
          end else if(UbxPayloadCount_CntReg == UbxNavTimeLs_SrcLsChange_Con) begin
            // if the src of the leap second change is GPS, GAL, GLO, or Beidou, then we can trust the leap second info
            if(MsgData_DatReg == 8'h02 || MsgData_DatReg == 8'h04 || MsgData_DatReg == 8'h05 || MsgData_DatReg == 8'h06) begin
              UtcOffsetInfo_DatReg.LeapChangeValid <= 1'b1;
            end else begin
              UtcOffsetInfo_DatReg.LeapChangeValid <= 1'b0;
            end
          end else if(UbxPayloadCount_CntReg == UbxNavTimeLs_OffsetLsChange_Con) begin
            if(MsgData_DatReg == 8'h00) begin
              // no leap second scheduled
              UtcOffsetInfo_DatReg.LeapAnnouncement <= 1'b0;
              UtcOffsetInfo_DatReg.Leap59 <= 1'b0;
              UtcOffsetInfo_DatReg.Leap61 <= 1'b0;
            end else if(MsgData_DatReg == 8'h01) begin
              // leap second 61
              UtcOffsetInfo_DatReg.LeapAnnouncement <= 1'b1;
              UtcOffsetInfo_DatReg.Leap59 <= 1'b0;
              UtcOffsetInfo_DatReg.Leap61 <= 1'b1;
            end else if(MsgData_DatReg == 8'hFF) begin
              // leap second 59
              UtcOffsetInfo_DatReg.LeapAnnouncement <= 1'b1;
              UtcOffsetInfo_DatReg.Leap59 <= 1'b1;
              UtcOffsetInfo_DatReg.Leap61 <= 1'b0;
            end else begin
              UtcOffsetInfo_DatReg.LeapAnnouncement <= 1'b0;
              UtcOffsetInfo_DatReg.Leap59 <= 1'b0;
              UtcOffsetInfo_DatReg.Leap61 <= 1'b0;
            end
          end else if(UbxPayloadCount_CntReg == UbxNavTimeLs_OffsetTimeToLs_Con) begin
            UtcOffsetInfo_DatReg.TimeToLeapSecond[7:0] <= MsgData_DatReg;
          end else if(UbxPayloadCount_CntReg == (UbxNavTimeLs_OffsetTimeToLs_Con + 1)) begin
            UtcOffsetInfo_DatReg.TimeToLeapSecond[15:8] <= MsgData_DatReg;
          end else if(UbxPayloadCount_CntReg == (UbxNavTimeLs_OffsetTimeToLs_Con + 2)) begin
            UtcOffsetInfo_DatReg.TimeToLeapSecond[23:16] <= MsgData_DatReg;
          end else if(UbxPayloadCount_CntReg == (UbxNavTimeLs_OffsetTimeToLs_Con + 3)) begin
            UtcOffsetInfo_DatReg.TimeToLeapSecond[31:24] <= MsgData_DatReg;
          end else if(UbxPayloadCount_CntReg == UbxNavTimeLs_OffsetValidLs_Con) begin
            UtcOffsetInfo_DatReg.CurrentUtcOffsetValid <= MsgData_DatReg[0];
            UtcOffsetInfo_DatReg.TimeToLeapSecondValid <= MsgData_DatReg[1];
            UtcOffsetInfo_DatReg.CurrentTaiGnssOffsetValid <= MsgData_DatReg[0];
          end
          if(UbxPayloadCount_CntReg < (UbxNavTimeLs_Length_Con - 1)) begin
            UbxPayloadCount_CntReg <= (UbxPayloadCount_CntReg) + 1;
          end else begin
            DetectUbxMsgState <= UbxChecksum_ChecksumA_St;
          end
          // Extract info from Payload of UBX-NAV-TimeUtc
        end
        UbxNavTimeUtc_CheckPayload_St : begin
          UbxChecksumA_DatReg <= UbxChecksumA_DatReg + (MsgData_DatReg);
          UbxChecksumB_DatReg <= UbxChecksumB_DatReg + UbxChecksumA_DatReg;
          // ChecksumB gets now the previous value of ChecksumA. Its latest value will be added later.
          if(UbxPayloadCount_CntReg == UbxNavTimeUtc_OffsetYear_Con) begin
            RxToD_DatReg.Year[7:0] <= MsgData_DatReg;
          end
          else if(UbxPayloadCount_CntReg == (UbxNavTimeUtc_OffsetYear_Con + 1)) begin
            RxToD_DatReg.Year[11:8] <= MsgData_DatReg[3:0];
          end
          else if(UbxPayloadCount_CntReg == UbxNavTimeUtc_OffsetMonth_Con) begin
            RxToD_DatReg.Month <= MsgData_DatReg[3:0];
          end
          else if(UbxPayloadCount_CntReg == UbxNavTimeUtc_OffsetDay_Con) begin
            RxToD_DatReg.Day <= MsgData_DatReg[4:0];
          end
          else if(UbxPayloadCount_CntReg == UbxNavTimeUtc_OffsetHour_Con) begin
            RxToD_DatReg.Hour <= MsgData_DatReg[4:0];
          end
          else if(UbxPayloadCount_CntReg == UbxNavTimeUtc_OffsetMinute_Con) begin
            RxToD_DatReg.Minute <= MsgData_DatReg[5:0];
          end
          else if(UbxPayloadCount_CntReg == UbxNavTimeUtc_OffsetSecond_Con) begin
            RxToD_DatReg.Second <= MsgData_DatReg[5:0];
          end
          else if(UbxPayloadCount_CntReg == UbxNavTimeUtc_OffsetUtcValid_Con) begin
            RxToD_DatReg.Valid <= MsgData_DatReg[2];
          end
          if(UbxPayloadCount_CntReg < (UbxNavTimeUtc_Length_Con - 1)) begin
            UbxPayloadCount_CntReg <= UbxPayloadCount_CntReg + 1;
          end
          else begin
            DetectUbxMsgState <= UbxChecksum_ChecksumA_St;
          end
        end
        UbxChecksum_ChecksumA_St : begin
          UbxChecksumB_DatReg <= UbxChecksumB_DatReg + UbxChecksumA_DatReg;
          // The latest value of ChecksumA is added now.
          if(MsgData_DatReg == UbxChecksumA_DatReg) begin
            DetectUbxMsgState <= UbxChecksum_ChecksumB_St;
          end
          else begin
            UbxChecksumError_DatReg <= 1'b1;
            DetectUbxMsgState <= Idle_St;
          end
        end
        UbxChecksum_ChecksumB_St : begin
          if(MsgData_DatReg == UbxChecksumB_DatReg) begin
            // The Format and Checksum of the received message is valid. Activate the valid flag of the extracted info.
            if(CheckMsg_UbxMonHw_DatReg == 1'b1) begin
              AntennaInfoValid_ValReg <= 1'b1;
            end
            else if(CheckMsg_UbxNavSat_DatReg == 1'b1) begin
              SatInfoValid_ValReg <= 1'b1;
            end
            else if(CheckMsg_UbxNavStatus_DatReg == 1'b1) begin
              AntennaFixValid_ValReg <= 1'b1;
            end
            else if(CheckMsg_UbxNavTimeLs_DatReg == 1'b1) begin
              UtcOffsetInfoValid_ValReg <= 1'b1;
            end
            else if(CheckMsg_UbxNavTimeUtc_DatReg == 1'b1) begin
              RxToDValid_ValReg <= 1'b1;
            end
          end
          else begin
            UbxChecksumError_DatReg <= 1'b1;
          end
          DetectUbxMsgState <= Idle_St;
        end
        endcase
      end
      // If TSIPv1 is enabled, first remove the padded Delimiter1 bytes
      TsipEoF_DatReg <= 1'b0;
      TsipMsgDataValid_ValReg <= 1'b0;
      if((Enable_Tsip_Ena == 1'b1)) begin
        MsgDataOldValid_ValReg <= MsgDataValid_ValReg;
        if((MsgDataValid_ValReg == 1'b1)) begin
          MsgDataOld_DatReg <= MsgData_DatReg;
          if(((MsgDataOld_DatReg == Tsip_Delimiter1_Con) && (MsgData_DatReg == Tsip_Delimiter1_Con) && (TsipPaddingSkipped_DatReg == 1'b0))) begin
            TsipPaddingSkipped_DatReg <= 1'b1;
            // when 2 Delimiter1 bytes are in sequence, skip the 2nd byte. A 3rd Delimiter1 byte in sequence is accepted, a 4th is skipped and so on...
          end
          else begin
            TsipMsgData_DatReg <= MsgDataOld_DatReg;
            TsipMsgDataValid_ValReg <= 1'b1;
            TsipPaddingSkipped_DatReg <= 1'b0;
            // clear the flag, when there is no skipping of delimiter 
          end
          // when Delimiter2 follows a Delimiter1 byte which was not skipped, it is the end of frame
          if(((MsgDataOld_DatReg == Tsip_Delimiter1_Con) && (MsgData_DatReg == Tsip_Delimiter2_Con) && (TsipPaddingSkipped_DatReg == 1'b0))) begin
            TsipEoF_DatReg <= 1'b1;
          end
        end
        else if((TsipEoF_DatReg == 1'b1)) begin
          // at the end of the msg, send also the last character to tsip msg and clear the buffer
          TsipMsgData_DatReg <= MsgDataOld_DatReg;
          TsipMsgDataValid_ValReg <= 1'b1;
          TsipPaddingSkipped_DatReg <= 1'b0;
          // clear the flag, when there is no skipping of delimiter 
          MsgDataOld_DatReg <= {8{1'b0}};
        end
      end
      else begin
        MsgDataOld_DatReg <= {8{1'b0}};
        MsgDataOldValid_ValReg <= 1'b0;
        TsipMsgData_DatReg <= {8{1'b0}};
        TsipPaddingSkipped_DatReg <= 1'b0;
      end
      // Decoding of the TSIPv1 messages             
      TsipParseError_DatReg <= 1'b0;
      TsipChecksumError_DatReg <= 1'b0;
      TsipPosition_MsgValOld_ValReg <= TsipPosition_MsgVal_ValReg;
      TsipReceiver_MsgValOld_ValReg <= TsipReceiver_MsgVal_ValReg;
      TsipTiming_MsgValOld_ValReg <= TsipTiming_MsgVal_ValReg;
      TsipAlarms_MsgValOld_ValReg <= TsipAlarms_MsgVal_ValReg;
      TsipSatellite_MsgValOld_ValReg <= TsipSatellite_MsgVal_ValReg;
      if((TsipMsgDataValid_ValReg == 1'b1)) begin
        case(DetectTsipMsgState)
        Idle_St : begin
          TsipChecksum_DatReg <= {8{1'b0}};
          TsipMsg_A1_DatReg <= 1'b0;
          TsipMsg_A2_DatReg <= 1'b0;
          TsipMsg_A3_DatReg <= 1'b0;
          TsipTiming_DatReg <= 1'b0;
          TsipPosition_DatReg <= 1'b0;
          TsipSatellite_DatReg <= 1'b0;
          TsipAlarms_DatReg <= 1'b0;
          TsipReceiver_DatReg <= 1'b0;
          TsipLength_DatReg <= {16{1'b0}};
          TsipPayloadCount_CntReg <= {16{1'b0}};
          TsipReceiver_ODC_DatReg <= 1'b0;
          // Start decoding only if the TSIP messages are enabled
          if((Enable_Tsip_Ena == 1'b1)) begin
            if(((TsipMsgData_DatReg == Tsip_Delimiter1_Con) && (TsipEoF_DatReg != 1'b1))) begin
              // Frame start byte
              DetectTsipMsgState <= TsipPacket_Id_St;
              TsipPayloadCount_CntReg <= 1;
            end
          end
        end
        TsipPacket_Id_St : begin
          TsipChecksum_DatReg <= TsipMsgData_DatReg;
          TsipPayloadCount_CntReg <= (TsipPayloadCount_CntReg) + 1;
          DetectTsipMsgState <= TsipPacket_SubId_St;
          if((TsipEoF_DatReg == 1'b1)) begin
            DetectTsipMsgState <= Idle_St;
            TsipParseError_DatReg <= 1'b1;
          end
          else if((TsipMsgData_DatReg == TsipTiming_ID_Con[15:8])) begin
            // A1 packet
            TsipMsg_A1_DatReg <= 1'b1;
          end
          else if((TsipMsgData_DatReg == TsipSatellite_ID_Con[15:8])) begin
            // A2 packet
            TsipMsg_A2_DatReg <= 1'b1;
          end
          else if((TsipMsgData_DatReg == TsipAlarms_ID_Con[15:8])) begin
            // A3 packet
            TsipMsg_A3_DatReg <= 1'b1;
          end
          else begin
            DetectTsipMsgState <= Idle_St;
            // not supported message
          end
        end
        TsipPacket_SubId_St : begin
          for (i=7; i >= 0; i = i - 1) begin
            TsipChecksum_DatReg[i] <= TsipChecksum_DatReg[i] ^ TsipMsgData_DatReg[i];
          end
          TsipPayloadCount_CntReg <= (TsipPayloadCount_CntReg) + 1;
          DetectTsipMsgState <= TsipLength1_St;
          if((TsipEoF_DatReg == 1'b1)) begin
            DetectTsipMsgState <= Idle_St;
            TsipParseError_DatReg <= 1'b1;
          end
          else if(((TsipMsg_A1_DatReg == 1'b1) && (TsipMsgData_DatReg == TsipTiming_ID_Con[7:0]))) begin
            // Timing Info
            TsipTiming_DatReg <= 1'b1;
          end
          else if(((TsipMsg_A1_DatReg == 1'b1) && (TsipMsgData_DatReg == TsipPosition_ID_Con[7:0]))) begin
            // Position Info
            TsipPosition_DatReg <= 1'b1;
          end
          else if(((TsipMsg_A2_DatReg == 1'b1) && (TsipMsgData_DatReg == TsipSatellite_ID_Con[7:0]))) begin
            // Satellite Info
            TsipSatellite_DatReg <= 1'b1;
          end
          else if(((TsipMsg_A3_DatReg == 1'b1) && (TsipMsgData_DatReg == TsipAlarms_ID_Con[7:0]))) begin
            // System Alarms
            TsipAlarms_DatReg <= 1'b1;
          end
          else if(((TsipMsg_A3_DatReg == 1'b1) && (TsipMsgData_DatReg == TsipReceiver_ID_Con[7:0]))) begin
            // Receiver Status
            TsipReceiver_DatReg <= 1'b1;
          end
          else begin
            DetectTsipMsgState <= Idle_St;
            // not supported message
          end
        end
        TsipLength1_St : begin
          for (i=7; i >= 0; i = i - 1) begin
            TsipChecksum_DatReg[i] <= TsipChecksum_DatReg[i] ^ TsipMsgData_DatReg[i];
          end
          TsipPayloadCount_CntReg <= (TsipPayloadCount_CntReg) + 1;
          TsipLength_DatReg[15:8] <= TsipMsgData_DatReg;
          if((TsipEoF_DatReg == 1'b1)) begin
            DetectTsipMsgState <= Idle_St;
            TsipParseError_DatReg <= 1'b1;
          end
          else begin
            DetectTsipMsgState <= TsipLength2_St;
          end
        end
        TsipLength2_St : begin
          for (i=7; i >= 0; i = i - 1) begin
            TsipChecksum_DatReg[i] <= TsipChecksum_DatReg[i] ^ TsipMsgData_DatReg[i];
          end
          TsipPayloadCount_CntReg <= (TsipPayloadCount_CntReg) + 1;
          TsipLength_DatReg[7:0] <= TsipMsgData_DatReg;
          if((TsipEoF_DatReg == 1'b1)) begin
            DetectTsipMsgState <= Idle_St;
            TsipParseError_DatReg <= 1'b1;
          end
          else begin
            DetectTsipMsgState <= TsipMode_St;
          end
        end
        TsipMode_St : begin
          for (i=7; i >= 0; i = i - 1) begin
            TsipChecksum_DatReg[i] <= TsipChecksum_DatReg[i] ^ TsipMsgData_DatReg[i];
          end
          TsipPayloadCount_CntReg <= (TsipPayloadCount_CntReg) + 1;
          if((TsipEoF_DatReg == 1'b1)) begin
            DetectTsipMsgState <= Idle_St;
            TsipParseError_DatReg <= 1'b1;
          end
          else if((TsipMsgData_DatReg == TsipModeResponse_Con)) begin
            // assure that this is a response message
            if((TsipTiming_DatReg == 1'b1)) begin
              TsipTiming_MsgVal_ValReg <= 1'b0;
              // invalidate msg flag until verifying that the frame is valid
              DetectTsipMsgState <= TsipTiming_Data_St;
            end
            else if((TsipPosition_DatReg == 1'b1)) begin
              TsipPosition_MsgVal_ValReg <= 1'b0;
              // invalidate msg flag until verifying that the frame is valid
              DetectTsipMsgState <= TsipPosition_Data_St;
            end
            else if((TsipSatellite_DatReg == 1'b1)) begin
              TsipSatellite_MsgVal_ValReg <= 1'b0;
              // invalidate msg flag until verifying that the frame is valid
              TsipSatellite_IncreaseSeenSat_DatReg <= 1'b0;
              TsipSatellite_IncreaseLockSat_DatReg <= 1'b0;
              DetectTsipMsgState <= TsipSatellite_Data_St;
            end
            else if((TsipAlarms_DatReg == 1'b1)) begin
              TsipAlarms_MsgVal_ValReg <= 1'b0;
              // invalidate msg flag until verifying that the frame is valid
              DetectTsipMsgState <= TsipAlarms_Data_St;
            end
            else if((TsipReceiver_DatReg == 1'b1)) begin
              TsipReceiver_MsgVal_ValReg <= 1'b0;
              // invalidate msg flag until verifying that the frame is valid
              DetectTsipMsgState <= TsipReceiver_Data_St;
            end
            else begin
              // it should  never happen
              DetectTsipMsgState <= Idle_St;
            end
          end
          else begin
            DetectTsipMsgState <= Idle_St;
            // not supported message
          end
        end
        TsipTiming_Data_St : begin
          for (i=7; i >= 0; i = i - 1) begin
            TsipChecksum_DatReg[i] <= TsipChecksum_DatReg[i] ^ TsipMsgData_DatReg[i];
          end
          TsipPayloadCount_CntReg <= (TsipPayloadCount_CntReg) + 1;
          if((TsipPayloadCount_CntReg == TsipTiming_OffsetHours_Con)) begin
            RxToD_DatReg.Hour <= TsipMsgData_DatReg[4:0];
          end
          else if((TsipPayloadCount_CntReg == TsipTiming_OffsetMinutes_Con)) begin
            RxToD_DatReg.Minute <= TsipMsgData_DatReg[5:0];
          end
          else if((TsipPayloadCount_CntReg == TsipTiming_OffsetSeconds_Con)) begin
            RxToD_DatReg.Second <= TsipMsgData_DatReg[5:0];
          end
          else if((TsipPayloadCount_CntReg == TsipTiming_OffsetMonth_Con)) begin
            RxToD_DatReg.Month <= TsipMsgData_DatReg[3:0];
          end
          else if((TsipPayloadCount_CntReg == TsipTiming_OffsetDay_Con)) begin
            RxToD_DatReg.Day <= TsipMsgData_DatReg[4:0];
          end
          else if((TsipPayloadCount_CntReg == TsipTiming_OffsetYearHigh_Con)) begin
            RxToD_DatReg.Year[11:8] <= TsipMsgData_DatReg[3:0];
          end
          else if((TsipPayloadCount_CntReg == TsipTiming_OffsetYearLow_Con)) begin
            RxToD_DatReg.Year[7:0] <= TsipMsgData_DatReg;
          end
          else if((TsipPayloadCount_CntReg == TsipTiming_OffsetTimebase_Con)) begin
            UtcOffsetInfo_DatReg.SrcOfCurLeapSecond <= TsipMsgData_DatReg;
          end
          else if((TsipPayloadCount_CntReg == TsipTiming_OffsetFlags_Con)) begin
            RxToD_DatReg.Valid <= TsipMsgData_DatReg[1];
            UtcOffsetInfo_DatReg.CurrentUtcOffsetValid <= TsipMsgData_DatReg[0];
            UtcOffsetInfo_DatReg.CurrentTaiGnssOffsetValid <= TsipMsgData_DatReg[0];
          end
          else if((TsipPayloadCount_CntReg == TsipTiming_OffsetUtcOffsetHigh_Con)) begin
            if((TsipMsgData_DatReg != 8'h00)) begin
              // utc offset should be positive and less than 256
              UtcOffsetInfo_DatReg.CurrentUtcOffsetValid <= 1'b0;
              UtcOffsetInfo_DatReg.CurrentTaiGnssOffsetValid <= 1'b0;
            end
          end
          else if((TsipPayloadCount_CntReg == TsipTiming_OffsetUtcOffsetLow_Con)) begin
            if(((UtcOffsetInfo_DatReg.SrcOfCurLeapSecond[3:0] == 4'b0000) || (UtcOffsetInfo_DatReg.SrcOfCurLeapSecond[3:0] == 4'b0010) || (UtcOffsetInfo_DatReg.SrcOfCurLeapSecond[3:0] == 4'b0011))) begin
              // for GPS, Beidou or GAL
              UtcOffsetInfo_DatReg.CurrentUtcOffset <= (TsipMsgData_DatReg) + 19;
              // add the GPS-TAI offset to UTC-GPS offset
              UtcOffsetInfo_DatReg.CurrentTaiGnssOffset <= 19;
              // the GPS-TAI offset will be added to GPS time to calculate the TAI 
            end
            else begin
              UtcOffsetInfo_DatReg.CurrentUtcOffsetValid <= 1'b0;
              // else invalidate the utc offset
              UtcOffsetInfo_DatReg.CurrentTaiGnssOffsetValid <= 1'b0;
              // else invalidate the utc offset
            end
          end
          if((TsipEoF_DatReg == 1'b1)) begin
            TsipParseError_DatReg <= 1'b1;
            DetectTsipMsgState <= Idle_St;
          end
          else if((TsipPayloadCount_CntReg == ((TsipLength_DatReg) + (TsipLengthOffset_Con)))) begin
            DetectTsipMsgState <= TsipChecksum_St;
          end
        end
        TsipPosition_Data_St : begin
          for (i=7; i >= 0; i = i - 1) begin
            TsipChecksum_DatReg[i] <= TsipChecksum_DatReg[i] ^ TsipMsgData_DatReg[i];
          end
          TsipPayloadCount_CntReg <= (TsipPayloadCount_CntReg) + 1;
          if((TsipPayloadCount_CntReg == TsipPosition_OffsetFixType_Con)) begin
            // TSIP AntennaFix: 0:No/1:2D/2:3D
            // Reg AntennaFix : 0:No/2:2D/3:3D
            if((TsipMsgData_DatReg == 8'h01)) begin
              AntennaFix_DatReg.GnssFix <= 8'h02;
              //2D
            end
            else if((TsipMsgData_DatReg == 8'h02)) begin
              AntennaFix_DatReg.GnssFix <= 8'h03;
              //3D
            end
            else begin
              AntennaFix_DatReg.GnssFix <= 8'h00;
              // no fix
            end
          end
          if((TsipEoF_DatReg == 1'b1)) begin
            TsipParseError_DatReg <= 1'b1;
            DetectTsipMsgState <= Idle_St;
          end
          else if((TsipPayloadCount_CntReg == ((TsipLength_DatReg) + (TsipLengthOffset_Con)))) begin
            DetectTsipMsgState <= TsipChecksum_St;
          end
        end
        TsipSatellite_Data_St : begin
          for (i=7; i >= 0; i = i - 1) begin
            TsipChecksum_DatReg[i] <= TsipChecksum_DatReg[i] ^ TsipMsgData_DatReg[i];
          end
          TsipPayloadCount_CntReg <= (TsipPayloadCount_CntReg) + 1;
          if((TsipPayloadCount_CntReg == TsipSatellite_OffsetId_Con)) begin
            if(((TsipMsgData_DatReg) > 99)) begin
              // invalid ID, mark parse error
              TsipParseError_DatReg <= 1'b1;
              DetectTsipMsgState <= Idle_St;
            end
          end
          else if((TsipPayloadCount_CntReg == TsipSatellite_OffsetFlags_Con)) begin
            if((TsipMsgData_DatReg[0] == 1'b1)) begin
              // satellite acquired
              TsipSatellite_IncreaseSeenSat_DatReg <= 1'b1;
              // flag that the satellite should be considered "seen"
            end
            if((TsipMsgData_DatReg[2] == 1'b1)) begin
              // satellite used in time fix
              TsipSatellite_IncreaseLockSat_DatReg <= 1'b1;
              // flag that the satellite should be considered "locked"
            end
          end
          if((TsipEoF_DatReg == 1'b1)) begin
            TsipParseError_DatReg <= 1'b1;
            DetectTsipMsgState <= Idle_St;
          end
          else if((TsipPayloadCount_CntReg == ((TsipLength_DatReg) + (TsipLengthOffset_Con)))) begin
            DetectTsipMsgState <= TsipChecksum_St;
          end
        end
        TsipAlarms_Data_St : begin
          for (i=7; i >= 0; i = i - 1) begin
            TsipChecksum_DatReg[i] <= TsipChecksum_DatReg[i] ^ TsipMsgData_DatReg[i];
          end
          TsipPayloadCount_CntReg <= (TsipPayloadCount_CntReg) + 1;
          if((TsipPayloadCount_CntReg == TsipTiming_OffsetMinorAlarmsHigh_Con)) begin
            UtcOffsetInfo_DatReg.Leap59 <= TsipMsgData_DatReg[2];
            UtcOffsetInfo_DatReg.Leap61 <= TsipMsgData_DatReg[1];
          end
          else if((TsipPayloadCount_CntReg == TsipTiming_OffsetMinorAlarmsLow_Con)) begin
            UtcOffsetInfo_DatReg.LeapAnnouncement <= TsipMsgData_DatReg[2];
            if((TsipMsgData_DatReg[0] == 1'b1)) begin
              AntennaInfo_DatReg.Status <= 3'b100;
              // antenna open
            end
            else if((TsipMsgData_DatReg[1] == 1'b1)) begin
              AntennaInfo_DatReg.Status <= 3'b011;
              // antenna shorted
            end
            else begin
              AntennaInfo_DatReg.Status <= 3'b010;
              // if no alarms, antenna ok
            end
          end
          else if((TsipPayloadCount_CntReg == TsipTiming_OffsetMajorAlarmsHigh_Con)) begin
            if((TsipMsgData_DatReg[0] == 1'b1)) begin
              // if there is a jamming alarm
              AntennaInfo_DatReg.JamInd <= 8'hFF;
              // indicate strong jamming
              AntennaInfo_DatReg.JamState <= 2'b11;
              // indicate critical state
            end
            else begin
              AntennaInfo_DatReg.JamInd <= 8'h00;
              // indicate no jamming
              AntennaInfo_DatReg.JamState <= 2'b01;
              // indicate OK state
            end
          end
          else if((TsipPayloadCount_CntReg == TsipTiming_OffsetMajorAlarmsLow_Con)) begin
            TsipAlarms_NoSatellites_DatReg <= TsipMsgData_DatReg[0];
            // not tracking satelites
            TsipAlarms_BadPps_DatReg <= TsipMsgData_DatReg[1];
            // bad PPS
            TsipAlarms_NoPps_DatReg <= TsipMsgData_DatReg[2];
            // no PPS
            if((TsipMsgData_DatReg[7] == 1'b1)) begin
              // spoofing alarm
              AntennaFix_DatReg.SpoofDetState <= 2'b10;
            end
            else begin
              AntennaFix_DatReg.SpoofDetState <= 2'b01;
            end
          end
          if((TsipEoF_DatReg == 1'b1)) begin
            TsipParseError_DatReg <= 1'b1;
            DetectTsipMsgState <= Idle_St;
          end
          else if((TsipPayloadCount_CntReg == ((TsipLength_DatReg) + (TsipLengthOffset_Con)))) begin
            DetectTsipMsgState <= TsipChecksum_St;
          end
        end
        TsipReceiver_Data_St : begin
          for (i=7; i >= 0; i = i - 1) begin
            TsipChecksum_DatReg[i] <= TsipChecksum_DatReg[i] ^ TsipMsgData_DatReg[i];
          end
          TsipPayloadCount_CntReg <= (TsipPayloadCount_CntReg) + 1;
          if((TsipPayloadCount_CntReg == TsipReceiver_OffsetMode_Con)) begin
            if((TsipMsgData_DatReg == TsipReceiver_ModeODC_Con)) begin
              TsipReceiver_ODC_DatReg <= 1'b1;
            end
          end
          else if((TsipPayloadCount_CntReg == TsipReceiver_OffsetStatus_Con)) begin
            if(((TsipReceiver_ODC_DatReg == 1'b1) && (TsipMsgData_DatReg == TsipReceiver_SatusGnssFix_Con))) begin
              // overdetermined clock with fix time
              AntennaFix_DatReg.GnssFixOk <= 1'b1;
            end
            else begin
              AntennaFix_DatReg.GnssFixOk <= 1'b0;
            end
          end
          if((TsipEoF_DatReg == 1'b1)) begin
            TsipParseError_DatReg <= 1'b1;
            DetectTsipMsgState <= Idle_St;
          end
          else if((TsipPayloadCount_CntReg == ((TsipLength_DatReg) + (TsipLengthOffset_Con)))) begin
            DetectTsipMsgState <= TsipChecksum_St;
          end
        end
        TsipChecksum_St : begin
          if((TsipEoF_DatReg == 1'b1)) begin
            DetectTsipMsgState <= Idle_St;
            TsipParseError_DatReg <= 1'b1;
          end
          else if((TsipMsgData_DatReg != TsipChecksum_DatReg)) begin
            DetectTsipMsgState <= Idle_St;
            TsipChecksumError_DatReg <= 1'b1;
          end
          else begin
            DetectTsipMsgState <= TsipEof1_St;
          end
        end
        TsipEof1_St : begin
          // verify that the end of the frame matches with the expected length 
          if((TsipEoF_DatReg == 1'b1)) begin
            // the frame has valid format=> activate the validity flags
            if((TsipTiming_DatReg == 1'b1)) begin
              TsipTiming_MsgVal_ValReg <= 1'b1;
            end
            else if((TsipPosition_DatReg == 1'b1)) begin
              TsipPosition_MsgVal_ValReg <= 1'b1;
            end
            else if((TsipSatellite_DatReg == 1'b1)) begin
              TsipSatellite_MsgVal_ValReg <= 1'b1;
              if((TsipSatellite_IncreaseSeenSat_DatReg == 1'b1)) begin
                TsipSatellite_CntSatellites_DatReg.NumberOfSeenSats <= (TsipSatellite_CntSatellites_DatReg.NumberOfSeenSats) + 1;
              end
              if((TsipSatellite_IncreaseLockSat_DatReg == 1'b1)) begin
                TsipSatellite_CntSatellites_DatReg.NumberOfLockedSats <= (TsipSatellite_CntSatellites_DatReg.NumberOfLockedSats) + 1;
              end
            end
            else if((TsipAlarms_DatReg == 1'b1)) begin
              TsipAlarms_MsgVal_ValReg <= 1'b1;
              TsipAlarms_ClearSatellites_DatReg <= TsipAlarms_NoSatellites_DatReg;
              // the msg is valid. store the alarm if the satellite numbers should be cleared. 
              UtcOffsetInfo_DatReg.TimeToLeapSecondValid <= UtcOffsetInfo_DatReg.CurrentUtcOffsetValid;
              // the alarms msg is valid, so the leap second info is valid if the UTC offset is valid.
            end
            else if((TsipReceiver_DatReg == 1'b1)) begin
              TsipReceiver_MsgVal_ValReg <= 1'b1;
            end
            DetectTsipMsgState <= TsipEof2_St;
          end
          else begin
            DetectTsipMsgState <= Idle_St;
            TsipParseError_DatReg <= 1'b1;
          end
        end
        TsipEof2_St : begin
          // the end of character has been already checked. 
          DetectTsipMsgState <= Idle_St;
        end
        endcase
      end
      if(((Disable_UbxNavTimeUtc_Ena == 1'b1) && (Enable_Ubx_Ena == 1'b1))) begin
        RxToD_DatReg <= ToD_Type_Reset;
        RxToDValid_ValReg <= 1'b0;
      end
      else if(((Disable_TsipTiming_Ena == 1'b1) && (Enable_Tsip_Ena == 1'b1))) begin
        RxToD_DatReg <= ToD_Type_Reset;
        TsipTiming_MsgVal_ValReg <= 1'b0;
      end
      if(((ClockTime_Nanosecond_DatIn[29] == 1'b0 && ClockTime_Nanosecond_DatReg[29] == 1'b1) && (Enable_Tsip_Ena == 1'b1))) begin
        // a new second begins, store and clear the TSIP satellite counters
        SatInfo_DatReg.NumberOfSeenSats <= TsipSatellite_CntSatellites_DatReg.NumberOfSeenSats;
        // store the seen satellites
        SatInfo_DatReg.NumberOfLockedSats <= TsipSatellite_CntSatellites_DatReg.NumberOfLockedSats;
        // store the locked satellites
        TsipSatellite_CntSatellites_DatReg <= SatInfo_Type_Reset;
        // clear the counting 
      end
      if(((Disable_UbxNavSat_Ena == 1'b1) && (Enable_Ubx_Ena == 1'b1))) begin
        SatInfo_DatReg <= SatInfo_Type_Reset;
        SatInfoValid_ValReg <= 1'b0;
      end
      else if(((Disable_TsipSatellite_Ena == 1'b1) && (Enable_Tsip_Ena == 1'b1))) begin
        SatInfo_DatReg <= SatInfo_Type_Reset;
        TsipSatellite_MsgVal_ValReg <= 1'b0;
      end
      if(((Disable_UbxHwMon_Ena == 1'b1) && (Enable_Ubx_Ena == 1'b1))) begin
        AntennaInfo_DatReg <= AntennaInfo_Type_Reset;
        AntennaInfoValid_ValReg <= 1'b0;
        // reset all records that the message contributes to 
      end
      else if(((Disable_TsipAlarms_Ena == 1'b1) && (Enable_Tsip_Ena == 1'b1))) begin
        AntennaFix_DatReg <= AntennaFix_Type_Reset;
        AntennaInfo_DatReg <= AntennaInfo_Type_Reset;
        UtcOffsetInfo_DatReg <= UtcOffsetInfo_Type_Reset;
        TsipAlarms_MsgVal_ValReg <= 1'b0;
      end
      if(((Disable_UbxNavStatus_Ena == 1'b1) && (Enable_Ubx_Ena == 1'b1))) begin
        AntennaFix_DatReg <= AntennaFix_Type_Reset;
        AntennaFixValid_ValReg <= 1'b0;
        // if one of the msgs that contribute are disabled, then invalidate all the corresponding records
      end
      else if(((Disable_TsipPosition_Ena == 1'b1) && (Enable_Tsip_Ena == 1'b1))) begin
        AntennaFix_DatReg <= AntennaFix_Type_Reset;
        TsipPosition_MsgVal_ValReg <= 1'b0;
      end
      else if(((Disable_TsipReceiver_Ena == 1'b1) && (Enable_Tsip_Ena == 1'b1))) begin
        AntennaFix_DatReg <= AntennaFix_Type_Reset;
        TsipReceiver_MsgVal_ValReg <= 1'b0;
      end
      if(((Disable_UbxNavTimeLs_Ena == 1'b1) && (Enable_Ubx_Ena == 1'b1))) begin
        UtcOffsetInfo_DatReg <= UtcOffsetInfo_Type_Reset;
        UtcOffsetInfoValid_ValReg <= 1'b0;
      end
      if((Enable_Ena == 1'b0)) begin
        AntennaInfo_DatReg <= AntennaInfo_Type_Reset;
        AntennaInfoValid_ValReg <= 1'b0;
        AntennaFix_DatReg <= AntennaFix_Type_Reset;
        AntennaFixValid_ValReg <= 1'b0;
        SatInfo_DatReg <= SatInfo_Type_Reset;
        SatInfoValid_ValReg <= 1'b0;
        UtcOffsetInfo_DatReg <= UtcOffsetInfo_Type_Reset;
        UtcOffsetInfoValid_ValReg <= 1'b0;
        RxToD_DatReg <= ToD_Type_Reset;
        RxToDValid_ValReg <= 1'b0;
        TsipReceiver_MsgVal_ValReg <= 1'b0;
        TsipPosition_MsgVal_ValReg <= 1'b0;
        TsipAlarms_MsgVal_ValReg <= 1'b0;
        TsipSatellite_MsgVal_ValReg <= 1'b0;
        TsipTiming_MsgVal_ValReg <= 1'b0;
        DetectUbxMsgState <= Idle_St;
        DetectTsipMsgState <= Idle_St;
      end
    end
  end

  // Each supported message type is expected to be received once per second. 
  // If a valid message type is not received for 3 seconds, then the valid flag of its corresponding register will be deactivated.
  always @(posedge SysClk_ClkIn, posedge SysRstN_RstIn) begin
    if((SysRstN_RstIn == 1'b0)) begin
      UbxNavSat_TimeoutCounter_CntReg <= 0;
      UbxHwMon_TimeoutCounter_CntReg <= 0;
      UbxNavStatus_TimeoutCounter_CntReg <= 0;
      UbxNavTimeUtc_TimeoutCounter_CntReg <= 0;
      UbxNavTimeLs_TimeoutCounter_CntReg <= 0;
      MillisecondCounter_CntReg <= 0;
      MillisecondFlag_EvtReg <= 1'b0;
      UbxNavSat_Timeout_EvtReg <= 1'b0;
      UbxHwMon_Timeout_EvtReg <= 1'b0;
      UbxNavStatus_Timeout_EvtReg <= 1'b0;
      UbxNavTimeUtc_Timeout_EvtReg <= 1'b0;
      UbxNavTimeLs_Timeout_EvtReg <= 1'b0;
      TsipTiming_Timeout_EvtReg <= 1'b0;
      TsipReceiver_Timeout_EvtReg <= 1'b0;
      TsipAlarms_Timeout_EvtReg <= 1'b0;
      TsipPosition_Timeout_EvtReg <= 1'b0;
      TsipSatellite_Timeout_EvtReg <= 1'b0;
      TsipTiming_TimeoutCounter_CntReg <= 0;
      TsipReceiver_TimeoutCounter_CntReg <= 0;
      TsipAlarms_TimeoutCounter_CntReg <= 0;
      TsipPosition_TimeoutCounter_CntReg <= 0;
      TsipSatellite_TimeoutCounter_CntReg <= 0;
    end else begin
      MillisecondFlag_EvtReg <= 1'b0;
      UbxNavSat_Timeout_EvtReg <= 1'b0;
      UbxHwMon_Timeout_EvtReg <= 1'b0;
      UbxNavStatus_Timeout_EvtReg <= 1'b0;
      UbxNavTimeUtc_Timeout_EvtReg <= 1'b0;
      UbxNavTimeLs_Timeout_EvtReg <= 1'b0;
      TsipTiming_Timeout_EvtReg <= 1'b0;
      TsipReceiver_Timeout_EvtReg <= 1'b0;
      TsipAlarms_Timeout_EvtReg <= 1'b0;
      TsipPosition_Timeout_EvtReg <= 1'b0;
      TsipSatellite_Timeout_EvtReg <= 1'b0;
      // count millisecond
      if((MillisecondCounter_CntReg < (NanosInMillisecond_Con - ClockPeriod_Gen))) begin
        MillisecondCounter_CntReg <= MillisecondCounter_CntReg + ClockPeriod_Gen;
      end
      else begin
        MillisecondCounter_CntReg <= 0;
        MillisecondFlag_EvtReg <= 1'b1;
      end
      // UbxNavSat timeout check 
      if(((SatInfoValid_ValReg == 1'b1) && (SatInfoValid_ValOldReg == 1'b0))) begin
        // a new message has just been validated
        UbxNavSat_TimeoutCounter_CntReg <= 0;
      end
      else if((UbxNavSat_TimeoutCounter_CntReg < MsgTimeoutMillisecond_Con)) begin
        // timeout count 
        if((MillisecondFlag_EvtReg == 1'b1)) begin
          UbxNavSat_TimeoutCounter_CntReg <= UbxNavSat_TimeoutCounter_CntReg + 1;
        end
      end
      else begin
        // timeout reached
        UbxNavSat_Timeout_EvtReg <= 1'b1;
      end
      // UbxHwMon timeout check 
      if(((AntennaInfoValid_ValReg == 1'b1) && (AntennaInfoValid_ValOldReg == 1'b0))) begin
        // a new message has just been validated
        UbxHwMon_TimeoutCounter_CntReg <= 0;
      end
      else if((UbxHwMon_TimeoutCounter_CntReg < MsgTimeoutMillisecond_Con)) begin
        // timeout count 
        if((MillisecondFlag_EvtReg == 1'b1)) begin
          UbxHwMon_TimeoutCounter_CntReg <= UbxHwMon_TimeoutCounter_CntReg + 1;
        end
      end
      else begin
        // timeout reached
        UbxHwMon_Timeout_EvtReg <= 1'b1;
      end
      // UbxNavStatus timeout check 
      if(((AntennaFixValid_ValReg == 1'b1) && (AntennaFixValid_ValOldReg == 1'b0))) begin
        // a new message has just been validated
        UbxNavStatus_TimeoutCounter_CntReg <= 0;
      end
      else if((UbxNavStatus_TimeoutCounter_CntReg < MsgTimeoutMillisecond_Con)) begin
        // timeout count 
        if((MillisecondFlag_EvtReg == 1'b1)) begin
          UbxNavStatus_TimeoutCounter_CntReg <= UbxNavStatus_TimeoutCounter_CntReg + 1;
        end
      end
      else begin
        // timeout reached
        UbxNavStatus_Timeout_EvtReg <= 1'b1;
      end
      // UbxNavTimeUtc timeout check 
      if(((RxToDValid_ValReg == 1'b1) && (RxToDValid_ValOldReg == 1'b0))) begin
        // a new message has just been validated
        UbxNavTimeUtc_TimeoutCounter_CntReg <= 0;
      end
      else if((UbxNavTimeUtc_TimeoutCounter_CntReg < MsgTimeoutMillisecond_Con)) begin
        // timeout count 
        if((MillisecondFlag_EvtReg == 1'b1)) begin
          UbxNavTimeUtc_TimeoutCounter_CntReg <= UbxNavTimeUtc_TimeoutCounter_CntReg + 1;
        end
      end
      else begin
        // timeout reached
        UbxNavTimeUtc_Timeout_EvtReg <= 1'b1;
      end
      // UbxNavTimeLs timeout check 
      if(((UtcOffsetInfoValid_ValReg == 1'b1) && (UtcOffsetInfoValid_ValOldReg == 1'b0))) begin
        // a new message has just been validated
        UbxNavTimeLs_TimeoutCounter_CntReg <= 0;
      end
      else if((UbxNavTimeLs_TimeoutCounter_CntReg < MsgTimeoutMillisecond_Con)) begin
        // timeout count 
        if((MillisecondFlag_EvtReg == 1'b1)) begin
          UbxNavTimeLs_TimeoutCounter_CntReg <= UbxNavTimeLs_TimeoutCounter_CntReg + 1;
        end
      end
      else begin
        // timeout reached
        UbxNavTimeLs_Timeout_EvtReg <= 1'b1;
      end
      // Tsip timing timeout check 
      if(((TsipTiming_MsgVal_ValReg == 1'b1) && (TsipTiming_MsgValOld_ValReg == 1'b0))) begin
        // a new message has just been validated
        TsipTiming_TimeoutCounter_CntReg <= 0;
      end
      else if((TsipTiming_TimeoutCounter_CntReg < MsgTimeoutMillisecond_Con)) begin
        // timeout count 
        if((MillisecondFlag_EvtReg == 1'b1)) begin
          TsipTiming_TimeoutCounter_CntReg <= TsipTiming_TimeoutCounter_CntReg + 1;
        end
      end
      else begin
        // timeout reached
        TsipTiming_Timeout_EvtReg <= 1'b1;
      end
      // Tsip Position timeout check 
      if(((TsipPosition_MsgVal_ValReg == 1'b1) && (TsipPosition_MsgValOld_ValReg == 1'b0))) begin
        // a new message has just been validated
        TsipPosition_TimeoutCounter_CntReg <= 0;
      end
      else if((TsipPosition_TimeoutCounter_CntReg < MsgTimeoutMillisecond_Con)) begin
        // timeout count 
        if((MillisecondFlag_EvtReg == 1'b1)) begin
          TsipPosition_TimeoutCounter_CntReg <= TsipPosition_TimeoutCounter_CntReg + 1;
        end
      end
      else begin
        // timeout reached
        TsipPosition_Timeout_EvtReg <= 1'b1;
      end
      // Tsip Receiver timeout check 
      if(((TsipReceiver_MsgVal_ValReg == 1'b1) && (TsipReceiver_MsgValOld_ValReg == 1'b0))) begin
        // a new message has just been validated
        TsipReceiver_TimeoutCounter_CntReg <= 0;
      end
      else if((TsipReceiver_TimeoutCounter_CntReg < MsgTimeoutMillisecond_Con)) begin
        // timeout count 
        if((MillisecondFlag_EvtReg == 1'b1)) begin
          TsipReceiver_TimeoutCounter_CntReg <= TsipReceiver_TimeoutCounter_CntReg + 1;
        end
      end
      else begin
        // timeout reached
        TsipReceiver_Timeout_EvtReg <= 1'b1;
      end
      // Tsip Alarms timeout check 
      if(((TsipAlarms_MsgVal_ValReg == 1'b1) && (TsipAlarms_MsgValOld_ValReg == 1'b0))) begin
        // a new message has just been validated
        TsipAlarms_TimeoutCounter_CntReg <= 0;
      end
      else if((TsipAlarms_TimeoutCounter_CntReg < MsgTimeoutMillisecond_Con)) begin
        // timeout count 
        if((MillisecondFlag_EvtReg == 1'b1)) begin
          TsipAlarms_TimeoutCounter_CntReg <= TsipAlarms_TimeoutCounter_CntReg + 1;
        end
      end
      else begin
        // timeout reached
        TsipAlarms_Timeout_EvtReg <= 1'b1;
      end
      // Tsip Satellite timeout check 
      if(((TsipSatellite_MsgVal_ValReg == 1'b1) && (TsipSatellite_MsgValOld_ValReg == 1'b0))) begin
        // a new message has just been validated
        TsipSatellite_TimeoutCounter_CntReg <= 0;
      end
      else if((TsipSatellite_TimeoutCounter_CntReg < MsgTimeoutMillisecond_Con)) begin
        // timeout count 
        if((MillisecondFlag_EvtReg == 1'b1)) begin
          TsipSatellite_TimeoutCounter_CntReg <= TsipSatellite_TimeoutCounter_CntReg + 1;
        end
      end
      else begin
        // timeout reached
        TsipSatellite_Timeout_EvtReg <= 1'b1;
      end
    end
  end

  // Convert the UTC to TAI and change the time format from 0xYYYYMMDDHHmmSS to 0xSSSSSSSS
  // The TAI is generated happens if a new valid time is received and the last received UTC offset is also valid
  // The TAI is not generated if the timestamp is right before or after a potential leap second update
  always @(posedge SysClk_ClkIn, posedge SysRstN_RstIn) begin
    if((SysRstN_RstIn == 1'b0)) begin
      ClockTime_Second_DatReg <= {((SecondWidth_Con - 1)-(0)+1){1'b0}};
      TimeAdjustment_Second_DatReg <= {((SecondWidth_Con - 1)-(0)+1){1'b0}};
      TimeAdjustment_Nanosecond_DatReg <= {((NanosecondWidth_Con - 1)-(0)+1){1'b0}};
      TimeAdjustment_ValReg <= 1'b0;
      GnssTime_Second_DatReg <= {((SecondWidth_Con - 1)-(0)+1){1'b0}};
      TaiConversionState_StaReg <= Idle_St;
      LeapYear_DatReg <= 1'b0;
      SkipTaiConversion_ValReg <= 1'b0;
      TimeCounter_CntReg <= 0;
      Year_004_Counter_CntReg <= 0;
      // leap year every 4 years 
      Year_100_Counter_CntReg <= 0;
      // no leap year every 100 years
      Year_400_Counter_CntReg <= 0;
      // leap year every 400 years
      ToD_DatReg <= ToD_Type_Reset;
      ToDValid_ValReg <= 1'b0;
    end else begin
      ClockTime_Second_DatReg <= ClockTime_Second_DatIn;
      TimeAdjustment_Second_DatReg <= {((SecondWidth_Con - 1)-(0)+1){1'b0}};
      TimeAdjustment_Nanosecond_DatReg <= {((NanosecondWidth_Con - 1)-(0)+1){1'b0}};
      // jump exactly at a new second
      TimeAdjustment_ValReg <= 1'b0;
      SkipTaiConversion_ValReg <= 1'b0;
      case(TaiConversionState_StaReg)
      Idle_St : begin
        // if the time has been updated from the GNSS receiver  
        if(((RxToDValid_ValReg == 1'b1 && RxToDValid_ValOldReg == 1'b0 && Enable_Ubx_Ena == 1'b1) || (TsipTiming_MsgVal_ValReg == 1'b1 && TsipTiming_MsgValOld_ValReg == 1'b0 && Enable_Tsip_Ena == 1'b1))) begin
          // if the latest time and UTC offset are valid (a valid Time LS message with valid UTC offset needs to be received first)
          if((RxToD_DatReg.Valid == 1'b1 && UtcOffsetInfo_DatReg.CurrentTaiGnssOffsetValid == 1'b1 && ClockTime_ValIn == 1'b1)) begin
            // if the timestamp is right before or right after a potential leap second, do not convert to a new TAI 
            if(((((RxToD_DatReg.Hour) == 23) && ((RxToD_DatReg.Minute) == 59) && ((RxToD_DatReg.Second) >= 57) && ((((RxToD_DatReg.Month) == 12) && ((RxToD_DatReg.Day) == 31)) || (((RxToD_DatReg.Month) == 6) && ((RxToD_DatReg.Day) == 30)) || (((RxToD_DatReg.Month) == 3) && ((RxToD_DatReg.Day) == 31)) || (((RxToD_DatReg.Month) == 9) && ((RxToD_DatReg.Day) == 30)))) || (((RxToD_DatReg.Hour) == 0) && ((RxToD_DatReg.Minute) == 0) && ((RxToD_DatReg.Second) <= 3) && ((((RxToD_DatReg.Month) == 1) && ((RxToD_DatReg.Day) == 1)) || (((RxToD_DatReg.Month) == 7) && ((RxToD_DatReg.Day) == 1)) || (((RxToD_DatReg.Month) == 4) && ((RxToD_DatReg.Day) == 1)) || (((RxToD_DatReg.Month) == 10) && ((RxToD_DatReg.Day) == 1)))))) begin
              //if (((unsigned(RxToD_DatReg.Hour) = 23) and (unsigned(RxToD_DatReg.Minute) = 59) and (unsigned(RxToD_DatReg.Second) >= 57) and -- at the end of a day 
              //(((unsigned(RxToD_DatReg.Month) = 12) and (unsigned(RxToD_DatReg.Day) = 31)) or -- at the end of december 
              //((unsigned(RxToD_DatReg.Month) = 6) and (unsigned(RxToD_DatReg.Day) = 30)) or -- at the end of june  
              //((unsigned(RxToD_DatReg.Month) = 3) and (unsigned(RxToD_DatReg.Day) = 31)) or -- at the end of march 
              //((unsigned(RxToD_DatReg.Month) = 9) and (unsigned(RxToD_DatReg.Day) = 30)))) or -- at the end of september  
              //((unsigned(RxToD_DatReg.Hour) = 0) and (unsigned(RxToD_DatReg.Minute) = 0) and (unsigned(RxToD_DatReg.Second) <= 3) and -- at the beginning of a day 
              //(((unsigned(RxToD_DatReg.Month) = 1) and (unsigned(RxToD_DatReg.Day) = 1)) or -- at the beginning of January 
              //((unsigned(RxToD_DatReg.Month) = 7) and (unsigned(RxToD_DatReg.Day) = 1)) or -- at the beginning of July  
              //((unsigned(RxToD_DatReg.Month) = 4) and (unsigned(RxToD_DatReg.Day) = 1)) or -- at the beginning of April
              //((unsigned(RxToD_DatReg.Month) = 10) and (unsigned(RxToD_DatReg.Day) = 1))))) then  -- at the beginning of October
              SkipTaiConversion_ValReg <= 1'b1;
            end
            else begin
              TaiConversionState_StaReg <= ConvertYears_St;
              GnssTime_Second_DatReg <= {((SecondWidth_Con - 1)-(0)+1){1'b0}};
              TimeCounter_CntReg <= 1970;
              // count the years since the beginning of TAI
              Year_004_Counter_CntReg <= 2;
              Year_100_Counter_CntReg <= 70;
              Year_400_Counter_CntReg <= 370;
              ToD_DatReg <= RxToD_DatReg;
              ToDValid_ValReg <= ToDValid_ValReg;
              LeapYear_DatReg <= 1'b0;
            end
          end
        end
      end
      ConvertYears_St : begin
        if((TimeCounter_CntReg < (ToD_DatReg.Year))) begin
          TimeCounter_CntReg <= TimeCounter_CntReg + 1;
          Year_400_Counter_CntReg <= Year_400_Counter_CntReg + 1;
          Year_100_Counter_CntReg <= Year_100_Counter_CntReg + 1;
          Year_004_Counter_CntReg <= Year_004_Counter_CntReg + 1;
          if((Year_400_Counter_CntReg == 400)) begin
            // leap year every 400 years
            GnssTime_Second_DatReg <= (GnssTime_Second_DatReg) + SecondsPerYear_Con + SecondsPerDay_Con;
            Year_400_Counter_CntReg <= 1;
            if((Year_100_Counter_CntReg == 100)) begin
              // clear the other counters
              Year_100_Counter_CntReg <= 1;
            end
            if((Year_004_Counter_CntReg == 4)) begin
              // clear the other counters
              Year_004_Counter_CntReg <= 1;
            end
          end
          else if((Year_100_Counter_CntReg == 100)) begin
            // no leap year every 100 years
            GnssTime_Second_DatReg <= (GnssTime_Second_DatReg) + SecondsPerYear_Con;
            Year_100_Counter_CntReg <= 1;
            if((Year_004_Counter_CntReg == 4)) begin
              // clear the other counters
              Year_004_Counter_CntReg <= 1;
            end
          end
          else if((Year_004_Counter_CntReg == 4)) begin
            // leap year every 4 years
            GnssTime_Second_DatReg <= (GnssTime_Second_DatReg) + SecondsPerYear_Con + SecondsPerDay_Con;
            Year_004_Counter_CntReg <= 1;
          end
          else begin
            // no leap year 
            GnssTime_Second_DatReg <= (GnssTime_Second_DatReg) + SecondsPerYear_Con;
          end
        end
        else begin
          // reached the current year
          if((Year_400_Counter_CntReg == 400)) begin
            // leap year every 400 years
            LeapYear_DatReg <= 1'b1;
          end
          else if((Year_100_Counter_CntReg == 100)) begin
            // no leap year every 100 years
            LeapYear_DatReg <= 1'b0;
          end
          else if((Year_004_Counter_CntReg == 4)) begin
            // leap year every 4 years
            LeapYear_DatReg <= 1'b1;
          end
          else begin
            // no leap year 
            LeapYear_DatReg <= 1'b0;
          end
          TimeCounter_CntReg <= 1;
          TaiConversionState_StaReg <= ConvertMonths_St;
        end
      end
      ConvertMonths_St : begin
        if((TimeCounter_CntReg < (ToD_DatReg.Month))) begin
          TimeCounter_CntReg <= TimeCounter_CntReg + 1;
          if(((TimeCounter_CntReg == 2) && (LeapYear_DatReg == 1'b1))) begin
            // at February check if this is a leap year
            GnssTime_Second_DatReg <= (GnssTime_Second_DatReg) + SecondsPerMonthArray_Con[TimeCounter_CntReg] + SecondsPerDay_Con;
          end
          else begin
            GnssTime_Second_DatReg <= (GnssTime_Second_DatReg) + SecondsPerMonthArray_Con[TimeCounter_CntReg];
          end
        end
        else begin
          TimeCounter_CntReg <= 1;
          TaiConversionState_StaReg <= ConvertDays_St;
        end
      end
      ConvertDays_St : begin
        if((TimeCounter_CntReg < (ToD_DatReg.Day))) begin
          TimeCounter_CntReg <= TimeCounter_CntReg + 1;
          GnssTime_Second_DatReg <= (GnssTime_Second_DatReg) + SecondsPerDay_Con;
        end
        else begin
          TimeCounter_CntReg <= 0;
          TaiConversionState_StaReg <= ConvertHours_St;
        end
      end
      ConvertHours_St : begin
        if((TimeCounter_CntReg < (ToD_DatReg.Hour))) begin
          TimeCounter_CntReg <= TimeCounter_CntReg + 1;
          GnssTime_Second_DatReg <= (GnssTime_Second_DatReg) + SecondsPerHour_Con;
        end
        else begin
          TimeCounter_CntReg <= 0;
          TaiConversionState_StaReg <= ConvertMinutes_St;
        end
      end
      ConvertMinutes_St : begin
        if((TimeCounter_CntReg < (ToD_DatReg.Minute))) begin
          TimeCounter_CntReg <= TimeCounter_CntReg + 1;
          GnssTime_Second_DatReg <= (GnssTime_Second_DatReg) + SecondsPerMinute_Con;
        end
        else begin
          TimeCounter_CntReg <= 0;
          TaiConversionState_StaReg <= CalcTai_St;
        end
      end
      CalcTai_St : begin
        // finally add the second field and the utc offset and depending which second we received an extra second
        if((ReceiveCurrentTime_Gen == "true")) begin
          GnssTime_Second_DatReg <= (GnssTime_Second_DatReg) + (UtcOffsetInfo_DatReg.CurrentTaiGnssOffset) + (ToD_DatReg.Second) + 1;
        end
        else begin
          // then next second is provided in advance
          GnssTime_Second_DatReg <= (GnssTime_Second_DatReg) + (UtcOffsetInfo_DatReg.CurrentTaiGnssOffset) + (ToD_DatReg.Second);
        end
        TaiConversionState_StaReg <= TimeAdjust_St;
      end
      TimeAdjust_St : begin
        // wait for the next seconds to change
        // or if a time jump happened we wait again for the next measurements for our adjustments
        if((ClockTime_TimeJump_DatIn == 1'b1)) begin
          TaiConversionState_StaReg <= Idle_St;
        end
        else if((ClockTime_Second_DatIn != ClockTime_Second_DatReg)) begin
          // if we need to adjust
          if((ClockTime_Second_DatIn != GnssTime_Second_DatReg)) begin
            TimeAdjustment_Second_DatReg <= GnssTime_Second_DatReg;
            TimeAdjustment_Nanosecond_DatReg <= ClockPeriod_Gen * 3;
            // it takes 3 clock cycles until clock is set
            TimeAdjustment_ValReg <= 1'b1;
          end
          TaiConversionState_StaReg <= Idle_St;
        end
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
      `Axi_Init_Proc(TodSlaveControl_Reg_Con, TodSlaveControl_DatReg);
      `Axi_Init_Proc(TodSlaveStatus_Reg_Con, TodSlaveStatus_DatReg);
      `Axi_Init_Proc(TodSlaveUartPolarity_Reg_Con, TodSlaveUartPolarity_DatReg);
      `Axi_Init_Proc(TodSlaveVersion_Reg_Con, TodSlaveVersion_DatReg);
      `Axi_Init_Proc(TodSlaveCorrection_Reg_Con, TodSlaveCorrection_DatReg);
      `Axi_Init_Proc(TodSlaveUartBaudRate_Reg_Con, TodSlaveUartBaudRate_DatReg);
      `Axi_Init_Proc(TodSlaveUtcStatus_Reg_Con, TodSlaveUtcStatus_DatReg);
      `Axi_Init_Proc(TodSlaveTimeToLeapSecond_Reg_Con, TodSlaveTimeToLeapSecond_DatReg);
      `Axi_Init_Proc(TodSlaveAntennaStatus_Reg_Con, TodSlaveAntennaStatus_DatReg);
      `Axi_Init_Proc(TodSlaveSatNumber_Reg_Con, TodSlaveSatNumber_DatReg);
      if(UartPolarity_Gen == "true") begin
        TodSlaveUartPolarity_DatReg[TodSlaveUartPolarity_PolarityBit_Con] <= 1'b1;
      end else begin
        TodSlaveUartPolarity_DatReg[TodSlaveUartPolarity_PolarityBit_Con] <= 1'b0;
      end
      TodSlaveUartBaudRate_DatReg[3:0] <= UartDefaultBaudRate_Gen;
      AntennaInfoValid_ValOldReg <= 1'b0;
      SatInfoValid_ValOldReg <= 1'b0;
      AntennaFixValid_ValOldReg <= 1'b0;
      UtcOffsetInfoValid_ValOldReg <= 1'b0;
      RxToDValid_ValOldReg <= 1'b0;
    end else begin
      AntennaInfoValid_ValOldReg <= AntennaInfoValid_ValReg;
      SatInfoValid_ValOldReg <= SatInfoValid_ValReg;
      AntennaFixValid_ValOldReg <= AntennaFixValid_ValReg;
      UtcOffsetInfoValid_ValOldReg <= UtcOffsetInfoValid_ValReg;
      RxToDValid_ValOldReg <= RxToDValid_ValReg;
      if((AxiWriteAddrValid_ValIn == 1'b1 && AxiWriteAddrReady_RdyReg == 1'b1)) 
        AxiWriteAddrReady_RdyReg <= 1'b0;
      
      if((AxiWriteDataValid_ValIn == 1'b1 && AxiWriteDataReady_RdyReg == 1'b1)) 
        AxiWriteDataReady_RdyReg <= 1'b0;
      
      if((AxiWriteRespValid_ValReg == 1'b1 && AxiWriteRespReady_RdyIn == 1'b1)) 
        AxiWriteRespValid_ValReg <= 1'b0;
      
      if((AxiReadAddrValid_ValIn == 1'b1 && AxiReadAddrReady_RdyReg == 1'b1)) 
        AxiReadAddrReady_RdyReg <= 1'b0;
      
      if((AxiReadDataValid_ValReg == 1'b1 && AxiReadDataReady_RdyIn == 1'b1)) 
        AxiReadDataValid_ValReg <= 1'b0;
      
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
        if(((AxiReadAddrValid_ValIn == 1'b1) && (AxiReadAddrReady_RdyReg == 1'b1))) begin
          AxiReadDataValid_ValReg <= 1'b1;
          AxiReadDataResponse_DatReg <= Axi_RespSlvErr_Con;
          `Axi_Read_Proc(TodSlaveControl_Reg_Con, TodSlaveControl_DatReg, AxiReadAddrAddress_AdrIn, AxiReadDataData_DatReg, AxiReadDataResponse_DatReg);
          `Axi_Read_Proc(TodSlaveStatus_Reg_Con, TodSlaveStatus_DatReg, AxiReadAddrAddress_AdrIn, AxiReadDataData_DatReg, AxiReadDataResponse_DatReg);
          `Axi_Read_Proc(TodSlaveUartPolarity_Reg_Con, TodSlaveUartPolarity_DatReg, AxiReadAddrAddress_AdrIn, AxiReadDataData_DatReg, AxiReadDataResponse_DatReg);
          `Axi_Read_Proc(TodSlaveVersion_Reg_Con, TodSlaveVersion_DatReg, AxiReadAddrAddress_AdrIn, AxiReadDataData_DatReg, AxiReadDataResponse_DatReg);
          `Axi_Read_Proc(TodSlaveCorrection_Reg_Con, TodSlaveCorrection_DatReg, AxiReadAddrAddress_AdrIn, AxiReadDataData_DatReg, AxiReadDataResponse_DatReg);
          `Axi_Read_Proc(TodSlaveUartBaudRate_Reg_Con, TodSlaveUartBaudRate_DatReg, AxiReadAddrAddress_AdrIn, AxiReadDataData_DatReg, AxiReadDataResponse_DatReg);
          `Axi_Read_Proc(TodSlaveUtcStatus_Reg_Con, TodSlaveUtcStatus_DatReg, AxiReadAddrAddress_AdrIn, AxiReadDataData_DatReg, AxiReadDataResponse_DatReg);
          `Axi_Read_Proc(TodSlaveTimeToLeapSecond_Reg_Con, TodSlaveTimeToLeapSecond_DatReg, AxiReadAddrAddress_AdrIn, AxiReadDataData_DatReg, AxiReadDataResponse_DatReg);
          `Axi_Read_Proc(TodSlaveAntennaStatus_Reg_Con, TodSlaveAntennaStatus_DatReg, AxiReadAddrAddress_AdrIn, AxiReadDataData_DatReg, AxiReadDataResponse_DatReg);
          `Axi_Read_Proc(TodSlaveSatNumber_Reg_Con, TodSlaveSatNumber_DatReg, AxiReadAddrAddress_AdrIn, AxiReadDataData_DatReg, AxiReadDataResponse_DatReg);
          Axi_AccessState_StaReg <= Resp_St;
        end
      end
      Write_St : begin
        if((((AxiWriteAddrValid_ValIn == 1'b1) && (AxiWriteAddrReady_RdyReg == 1'b1)) && ((AxiWriteDataValid_ValIn == 1'b1) && (AxiWriteDataReady_RdyReg == 1'b1)))) begin
          AxiWriteRespValid_ValReg <= 1'b1;
          AxiWriteRespResponse_DatReg <= Axi_RespSlvErr_Con;
          `Axi_Write_Proc(TodSlaveControl_Reg_Con, TodSlaveControl_DatReg, AxiWriteAddrAddress_AdrIn, AxiWriteDataData_DatIn, AxiWriteRespResponse_DatReg);
          `Axi_Write_Proc(TodSlaveStatus_Reg_Con, TodSlaveStatus_DatReg, AxiWriteAddrAddress_AdrIn, AxiWriteDataData_DatIn, AxiWriteRespResponse_DatReg);
          `Axi_Write_Proc(TodSlaveUartPolarity_Reg_Con, TodSlaveUartPolarity_DatReg, AxiWriteAddrAddress_AdrIn, AxiWriteDataData_DatIn, AxiWriteRespResponse_DatReg);
          `Axi_Write_Proc(TodSlaveVersion_Reg_Con, TodSlaveVersion_DatReg, AxiWriteAddrAddress_AdrIn, AxiWriteDataData_DatIn, AxiWriteRespResponse_DatReg);
          `Axi_Write_Proc(TodSlaveCorrection_Reg_Con, TodSlaveCorrection_DatReg, AxiWriteAddrAddress_AdrIn, AxiWriteDataData_DatIn, AxiWriteRespResponse_DatReg);
          `Axi_Write_Proc(TodSlaveUartBaudRate_Reg_Con, TodSlaveUartBaudRate_DatReg, AxiWriteAddrAddress_AdrIn, AxiWriteDataData_DatIn, AxiWriteRespResponse_DatReg);
          `Axi_Write_Proc(TodSlaveUtcStatus_Reg_Con, TodSlaveUtcStatus_DatReg, AxiWriteAddrAddress_AdrIn, AxiWriteDataData_DatIn, AxiWriteRespResponse_DatReg);
          `Axi_Write_Proc(TodSlaveTimeToLeapSecond_Reg_Con, TodSlaveTimeToLeapSecond_DatReg, AxiWriteAddrAddress_AdrIn, AxiWriteDataData_DatIn, AxiWriteRespResponse_DatReg);
          `Axi_Write_Proc(TodSlaveAntennaStatus_Reg_Con, TodSlaveAntennaStatus_DatReg, AxiWriteAddrAddress_AdrIn, AxiWriteDataData_DatIn, AxiWriteRespResponse_DatReg);
          `Axi_Write_Proc(TodSlaveSatNumber_Reg_Con, TodSlaveSatNumber_DatReg, AxiWriteAddrAddress_AdrIn, AxiWriteDataData_DatIn, AxiWriteRespResponse_DatReg);
          Axi_AccessState_StaReg <= Resp_St;
        end
      end
      Resp_St : begin
        if((((AxiWriteRespValid_ValReg == 1'b1) && (AxiWriteRespReady_RdyIn == 1'b1)) || ((AxiReadDataValid_ValReg == 1'b1) && (AxiReadDataReady_RdyIn == 1'b1)))) begin
          Axi_AccessState_StaReg <= Idle_St;
        end
      end
      default : begin
      end
      endcase
      TodSlaveCorrection_DatReg <= {32{1'b0}}; // unused!
      if((Enable_Ena == 1'b1)) begin
        if(((UbxParseError_DatReg == 1'b1) || (TsipParseError_DatReg == 1'b1))) begin
          TodSlaveStatus_DatReg[0] <= 1'b1;
        end
        if(((UbxChecksumError_DatReg == 1'b1) || (TsipChecksumError_DatReg == 1'b1))) begin
          TodSlaveStatus_DatReg[1] <= 1'b1;
        end
        if((UartError_DatReg == 1'b1)) begin
          TodSlaveStatus_DatReg[2] <= 1'b1;
        end
        if(((UbxNavTimeLs_Timeout_EvtReg == 1'b1) && (Enable_Ubx_Ena == 1'b1))) begin
          TodSlaveUtcStatus_DatReg[TodSlaveUtcStatus_UtcOffsetValidBit_Con] <= 1'b0;
          TodSlaveUtcStatus_DatReg[TodSlaveUtcStatus_LeapInfoValidBit_Con] <= 1'b0;
        end
        else if(((UtcOffsetInfoValid_ValReg == 1'b1) && (UtcOffsetInfoValid_ValOldReg == 1'b0) && (Enable_Ubx_Ena == 1'b1))) begin
          TodSlaveUtcStatus_DatReg[7:0] <= UtcOffsetInfo_DatReg.CurrentUtcOffset;
          TodSlaveUtcStatus_DatReg[TodSlaveUtcStatus_UtcOffsetValidBit_Con] <= UtcOffsetInfo_DatReg.CurrentUtcOffsetValid;
          TodSlaveUtcStatus_DatReg[TodSlaveUtcStatus_LeapAnnounceBit_Con] <= UtcOffsetInfo_DatReg.LeapAnnouncement;
          TodSlaveUtcStatus_DatReg[TodSlaveUtcStatus_Leap59Bit_Con] <= UtcOffsetInfo_DatReg.Leap59;
          TodSlaveUtcStatus_DatReg[TodSlaveUtcStatus_Leap61Bit_Con] <= UtcOffsetInfo_DatReg.Leap61;
          TodSlaveUtcStatus_DatReg[TodSlaveUtcStatus_LeapInfoValidBit_Con] <= UtcOffsetInfo_DatReg.LeapChangeValid;
          TodSlaveTimeToLeapSecond_DatReg <= UtcOffsetInfo_DatReg.TimeToLeapSecond;
        end
        else if(((TsipTiming_Timeout_EvtReg == 1'b1) && (Enable_Tsip_Ena == 1'b1))) begin
          TodSlaveUtcStatus_DatReg[TodSlaveUtcStatus_UtcOffsetValidBit_Con] <= 1'b0;
          TodSlaveUtcStatus_DatReg[TodSlaveUtcStatus_LeapInfoValidBit_Con] <= 1'b0;
        end
        else if(((TsipAlarms_Timeout_EvtReg == 1'b1) && (Enable_Tsip_Ena == 1'b1))) begin
          TodSlaveUtcStatus_DatReg[TodSlaveUtcStatus_LeapInfoValidBit_Con] <= 1'b0;
          //elsif ((((TsipTiming_MsgVal_ValReg = '1') and (TsipTiming_MsgValOld_ValReg = '0') and ( TsipAlarms_MsgVal_ValReg = '1')) -- if a new timing message is just received and alarms is already received
          //or (TsipAlarms_MsgVal_ValReg = '1' and TsipAlarms_MsgValOld_ValReg = '0' and  TsipTiming_MsgVal_ValReg = '1')) -- if a new alarms message is just received and timing is already received
        end
        else if(((((TsipTiming_MsgVal_ValReg == 1'b1) && (TsipTiming_MsgValOld_ValReg == 1'b0) && (TsipAlarms_MsgVal_ValReg == 1'b1)) || (TsipAlarms_MsgVal_ValReg == 1'b1 && TsipAlarms_MsgValOld_ValReg == 1'b0 && TsipTiming_MsgVal_ValReg == 1'b1)) && (Enable_Tsip_Ena == 1'b1))) begin
          TodSlaveUtcStatus_DatReg[7:0] <= UtcOffsetInfo_DatReg.CurrentUtcOffset;
          TodSlaveUtcStatus_DatReg[TodSlaveUtcStatus_UtcOffsetValidBit_Con] <= UtcOffsetInfo_DatReg.CurrentUtcOffsetValid;
          TodSlaveUtcStatus_DatReg[TodSlaveUtcStatus_LeapAnnounceBit_Con] <= UtcOffsetInfo_DatReg.LeapAnnouncement;
          TodSlaveUtcStatus_DatReg[TodSlaveUtcStatus_Leap59Bit_Con] <= UtcOffsetInfo_DatReg.Leap59;
          TodSlaveUtcStatus_DatReg[TodSlaveUtcStatus_Leap61Bit_Con] <= UtcOffsetInfo_DatReg.Leap61;
          TodSlaveUtcStatus_DatReg[TodSlaveUtcStatus_LeapInfoValidBit_Con] <= UtcOffsetInfo_DatReg.TimeToLeapSecondValid;
          TodSlaveTimeToLeapSecond_DatReg <= UtcOffsetInfo_DatReg.TimeToLeapSecond;
        end
        if(((UbxHwMon_Timeout_EvtReg == 1'b1) && (Enable_Ubx_Ena == 1'b1))) begin
          TodSlaveAntennaStatus_DatReg[29] <= 1'b0;
        end
        else if(((AntennaInfoValid_ValReg == 1'b1) && (AntennaInfoValid_ValOldReg == 1'b0) && (Enable_Ubx_Ena == 1'b1))) begin
          TodSlaveAntennaStatus_DatReg[2:0] <= AntennaInfo_DatReg.Status;
          TodSlaveAntennaStatus_DatReg[4:3] <= AntennaInfo_DatReg.JamState;
          TodSlaveAntennaStatus_DatReg[12:5] <= AntennaInfo_DatReg.JamInd;
          TodSlaveAntennaStatus_DatReg[29] <= 1'b1;
        end
        else if(((TsipAlarms_Timeout_EvtReg == 1'b1) && (Enable_Tsip_Ena == 1'b1))) begin
          TodSlaveAntennaStatus_DatReg[29] <= 1'b0;
        end
        else if(((TsipAlarms_MsgVal_ValReg == 1'b1) && (TsipAlarms_MsgValOld_ValReg == 1'b0) && (Enable_Tsip_Ena == 1'b1))) begin
          TodSlaveAntennaStatus_DatReg[2:0] <= AntennaInfo_DatReg.Status;
          TodSlaveAntennaStatus_DatReg[4:3] <= AntennaInfo_DatReg.JamState;
          TodSlaveAntennaStatus_DatReg[12:5] <= AntennaInfo_DatReg.JamInd;
          TodSlaveAntennaStatus_DatReg[29] <= 1'b1;
        end
        if(((UbxNavStatus_Timeout_EvtReg == 1'b1) && (Enable_Ubx_Ena == 1'b1))) begin
          TodSlaveAntennaStatus_DatReg[28] <= 1'b0;
        end
        else if(((AntennaFixValid_ValReg == 1'b1) && (AntennaFixValid_ValOldReg == 1'b0) && (Enable_Ubx_Ena == 1'b1))) begin
          TodSlaveAntennaStatus_DatReg[16] <= AntennaFix_DatReg.GnssFixOk;
          TodSlaveAntennaStatus_DatReg[24:17] <= AntennaFix_DatReg.GnssFix;
          TodSlaveAntennaStatus_DatReg[26:25] <= AntennaFix_DatReg.SpoofDetState;
          TodSlaveAntennaStatus_DatReg[28] <= 1'b1;
          // if any of the messages that contribute to the record timeouts, invalidate the record
        end
        else if((((TsipReceiver_Timeout_EvtReg == 1'b1) || (TsipPosition_Timeout_EvtReg == 1'b1) || (TsipAlarms_Timeout_EvtReg == 1'b1)) && (Enable_Tsip_Ena == 1'b1))) begin
          TodSlaveAntennaStatus_DatReg[28] <= 1'b0;
          //elsif ((((TsipReceiver_MsgVal_ValReg = '1') and (TsipReceiver_MsgValOld_ValReg = '0') and (TsipAlarms_MsgVal_ValReg = '1') and (TsipPosition_MsgVal_ValReg = '1')) -- if a new Receiver message is just received and Alarms and Position are already received
          //or (((TsipAlarms_MsgVal_ValReg = '1') and (TsipAlarms_MsgValOld_ValReg = '0') and (TsipReceiver_MsgVal_ValReg = '1') and (TsipPosition_MsgVal_ValReg = '1')))  -- if a new Alarms message is just received and Receiver and Position are already received
          //or (((TsipPosition_MsgVal_ValReg = '1') and (TsipPosition_MsgValOld_ValReg = '0') and (TsipReceiver_MsgVal_ValReg = '1') and (TsipAlarms_MsgVal_ValReg = '1')))) -- if a new Position message is just received and Receiver and Alarms are already received
        end
        else if(((TsipReceiver_MsgVal_ValReg == 1'b1 && TsipReceiver_MsgValOld_ValReg == 1'b0 && TsipAlarms_MsgVal_ValReg == 1'b1 && TsipPosition_MsgVal_ValReg == 1'b1) || (TsipAlarms_MsgVal_ValReg == 1'b1 && TsipAlarms_MsgValOld_ValReg == 1'b0 && TsipReceiver_MsgVal_ValReg == 1'b1 && TsipPosition_MsgVal_ValReg == 1'b1) || (TsipPosition_MsgVal_ValReg == 1'b1 && TsipPosition_MsgValOld_ValReg == 1'b0 && TsipReceiver_MsgVal_ValReg == 1'b1 && TsipAlarms_MsgVal_ValReg == 1'b1)) && Enable_Tsip_Ena == 1'b1) begin
          TodSlaveAntennaStatus_DatReg[16] <= AntennaFix_DatReg.GnssFixOk;
          TodSlaveAntennaStatus_DatReg[24:17] <= AntennaFix_DatReg.GnssFix;
          TodSlaveAntennaStatus_DatReg[26:25] <= AntennaFix_DatReg.SpoofDetState;
          TodSlaveAntennaStatus_DatReg[28] <= 1'b1;
        end
        if(UbxNavSat_Timeout_EvtReg == 1'b1 && Enable_Ubx_Ena == 1'b1) begin
          TodSlaveSatNumber_DatReg[16] <= 1'b0;
        end
        else if(SatInfoValid_ValReg == 1'b1 && SatInfoValid_ValOldReg == 1'b0 && Enable_Ubx_Ena == 1'b1) begin
          TodSlaveSatNumber_DatReg[7:0] <= SatInfo_DatReg.NumberOfSeenSats;
          TodSlaveSatNumber_DatReg[15:8] <= SatInfo_DatReg.NumberOfLockedSats;
          TodSlaveSatNumber_DatReg[16] <= 1'b1;
        end
        else if((((TsipSatellite_Timeout_EvtReg == 1'b1) || (TsipAlarms_ClearSatellites_DatReg == 1'b1)) && (Enable_Tsip_Ena == 1'b1))) begin
          TodSlaveSatNumber_DatReg[16] <= 1'b0;
        end
        else if(ClockTime_Nanosecond_DatReg[29] == 1'b0 && ClockTime_Nanosecond_OldDatReg[29] == 1'b1 && Enable_Tsip_Ena == 1'b1) begin
          // a new second begins, store the TSIP satellite counters
          TodSlaveSatNumber_DatReg[7:0] <= SatInfo_DatReg.NumberOfSeenSats;
          TodSlaveSatNumber_DatReg[15:8] <= SatInfo_DatReg.NumberOfLockedSats;
          TodSlaveSatNumber_DatReg[16] <= 1'b1;
        end
      end
      else begin
        TodSlaveStatus_DatReg <= {32{1'b0}};
        TodSlaveUtcStatus_DatReg <= {32{1'b0}};
        TodSlaveTimeToLeapSecond_DatReg <= {32{1'b0}};
        TodSlaveAntennaStatus_DatReg <= {32{1'b0}};
        TodSlaveSatNumber_DatReg <= {32{1'b0}};
      end
    end
  end
endmodule
