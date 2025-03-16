// SPDX-License-Identifier: GPL-3.0
module AdjustableClock_v #(
parameter [31:0] ClockPeriod_Gen=20, // 50MHz system clock, period in nanoseconds
parameter [31:0] ClockInSyncThreshold_Gen=500, // threshold in nanosecond
parameter [31:0] ClockInHoldoverTimeoutSecond_Gen=3 // holdover in seconds
)(
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME s_axi_clk, ASSOCIATED_BUSIF s_axi, ASSOCIATED_RESET s_axi_aresetn" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 s_axi_clk CLK" *)
input wire SysClk_ClkIn,
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 s_axi_aresetn RST" *)
input wire SysRstN_RstIn,
// Input 1  
// Time Adjustment Input    
(* X_INTERFACE_INFO = "NetTimeLogic:TimeCardLib:TC_ClockAdjustment:1.0 time_adjustment_1 Second" *)
input wire [31:0] TimeAdjustmentIn1_Second_DatIn,
(* X_INTERFACE_INFO = "NetTimeLogic:TimeCardLib:TC_ClockAdjustment:1.0 time_adjustment_1 Nanosecond" *)
input wire [31:0] TimeAdjustmentIn1_Nanosecond_DatIn,
(* X_INTERFACE_INFO = "NetTimeLogic:TimeCardLib:TC_ClockAdjustment:1.0 time_adjustment_1 Valid" *)
input wire TimeAdjustmentIn1_ValIn,
// Offset Adjustment Input  
(* X_INTERFACE_INFO = "NetTimeLogic:TimeCardLib:TC_ClockAdjustment:1.0 offset_adjustment_1 Second" *)
input wire [31:0] OffsetAdjustmentIn1_Second_DatIn,
(* X_INTERFACE_INFO = "NetTimeLogic:TimeCardLib:TC_ClockAdjustment:1.0 offset_adjustment_1 Nanosecond" *)
input wire [31:0] OffsetAdjustmentIn1_Nanosecond_DatIn,
(* X_INTERFACE_INFO = "NetTimeLogic:TimeCardLib:TC_ClockAdjustment:1.0 offset_adjustment_1 Sign" *)
input wire OffsetAdjustmentIn1_Sign_DatIn,
(* X_INTERFACE_INFO = "NetTimeLogic:TimeCardLib:TC_ClockAdjustment:1.0 offset_adjustment_1 Interval" *)
input wire [31:0] OffsetAdjustmentIn1_Interval_DatIn,
(* X_INTERFACE_INFO = "NetTimeLogic:TimeCardLib:TC_ClockAdjustment:1.0 offset_adjustment_1 Valid" *)
input wire OffsetAdjustmentIn1_ValIn,
// Drift Adjustment Input   
(* X_INTERFACE_INFO = "NetTimeLogic:TimeCardLib:TC_ClockAdjustment:1.0 drift_adjustment_1 Nanosecond" *)
input wire [31:0] DriftAdjustmentIn1_Nanosecond_DatIn,
(* X_INTERFACE_INFO = "NetTimeLogic:TimeCardLib:TC_ClockAdjustment:1.0 drift_adjustment_1 Sign" *)
input wire DriftAdjustmentIn1_Sign_DatIn,
(* X_INTERFACE_INFO = "NetTimeLogic:TimeCardLib:TC_ClockAdjustment:1.0 drift_adjustment_1 Interval" *)
input wire [31:0] DriftAdjustmentIn1_Interval_DatIn,
(* X_INTERFACE_INFO = "NetTimeLogic:TimeCardLib:TC_ClockAdjustment:1.0 drift_adjustment_1 Valid" *)
input wire DriftAdjustmentIn1_ValIn,
// Input 2  
// Time Adjustment Input    
(* X_INTERFACE_INFO = "NetTimeLogic:TimeCardLib:TC_ClockAdjustment:1.0 time_adjustment_2 Second" *)
input wire [31:0] TimeAdjustmentIn2_Second_DatIn,
(* X_INTERFACE_INFO = "NetTimeLogic:TimeCardLib:TC_ClockAdjustment:1.0 time_adjustment_2 Nanosecond" *)
input wire [31:0] TimeAdjustmentIn2_Nanosecond_DatIn,
(* X_INTERFACE_INFO = "NetTimeLogic:TimeCardLib:TC_ClockAdjustment:1.0 time_adjustment_2 Valid" *)
input wire TimeAdjustmentIn2_ValIn,
// Offset Adjustment Input  
(* X_INTERFACE_INFO = "NetTimeLogic:TimeCardLib:TC_ClockAdjustment:1.0 offset_adjustment_2 Second" *)
input wire [31:0] OffsetAdjustmentIn2_Second_DatIn,
(* X_INTERFACE_INFO = "NetTimeLogic:TimeCardLib:TC_ClockAdjustment:1.0 offset_adjustment_2 Nanosecond" *)
input wire [31:0] OffsetAdjustmentIn2_Nanosecond_DatIn,
(* X_INTERFACE_INFO = "NetTimeLogic:TimeCardLib:TC_ClockAdjustment:1.0 offset_adjustment_2 Sign" *)
input wire OffsetAdjustmentIn2_Sign_DatIn,
(* X_INTERFACE_INFO = "NetTimeLogic:TimeCardLib:TC_ClockAdjustment:1.0 offset_adjustment_2 Interval" *)
input wire [31:0] OffsetAdjustmentIn2_Interval_DatIn,
(* X_INTERFACE_INFO = "NetTimeLogic:TimeCardLib:TC_ClockAdjustment:1.0 offset_adjustment_2 Valid" *)
input wire OffsetAdjustmentIn2_ValIn,
// Drift Adjustment Input   
(* X_INTERFACE_INFO = "NetTimeLogic:TimeCardLib:TC_ClockAdjustment:1.0 drift_adjustment_2 Nanosecond" *)
input wire [31:0] DriftAdjustmentIn2_Nanosecond_DatIn,
(* X_INTERFACE_INFO = "NetTimeLogic:TimeCardLib:TC_ClockAdjustment:1.0 drift_adjustment_2 Sign" *)
input wire DriftAdjustmentIn2_Sign_DatIn,
(* X_INTERFACE_INFO = "NetTimeLogic:TimeCardLib:TC_ClockAdjustment:1.0 drift_adjustment_2 Interval" *)
input wire [31:0] DriftAdjustmentIn2_Interval_DatIn,
(* X_INTERFACE_INFO = "NetTimeLogic:TimeCardLib:TC_ClockAdjustment:1.0 drift_adjustment_2 Valid" *)
input wire DriftAdjustmentIn2_ValIn,
// Input 3  
// Time Adjustment Input    
(* X_INTERFACE_INFO = "NetTimeLogic:TimeCardLib:TC_ClockAdjustment:1.0 time_adjustment_3 Second" *)
input wire [31:0] TimeAdjustmentIn3_Second_DatIn,
(* X_INTERFACE_INFO = "NetTimeLogic:TimeCardLib:TC_ClockAdjustment:1.0 time_adjustment_3 Nanosecond" *)
input wire [31:0] TimeAdjustmentIn3_Nanosecond_DatIn,
(* X_INTERFACE_INFO = "NetTimeLogic:TimeCardLib:TC_ClockAdjustment:1.0 time_adjustment_3 Valid" *)
input wire TimeAdjustmentIn3_ValIn,
// Offset Adjustment Input  
(* X_INTERFACE_INFO = "NetTimeLogic:TimeCardLib:TC_ClockAdjustment:1.0 offset_adjustment_3 Second" *)
input wire [31:0] OffsetAdjustmentIn3_Second_DatIn,
(* X_INTERFACE_INFO = "NetTimeLogic:TimeCardLib:TC_ClockAdjustment:1.0 offset_adjustment_3 Nanosecond" *)
input wire [31:0] OffsetAdjustmentIn3_Nanosecond_DatIn,
(* X_INTERFACE_INFO = "NetTimeLogic:TimeCardLib:TC_ClockAdjustment:1.0 offset_adjustment_3 Sign" *)
input wire OffsetAdjustmentIn3_Sign_DatIn,
(* X_INTERFACE_INFO = "NetTimeLogic:TimeCardLib:TC_ClockAdjustment:1.0 offset_adjustment_3 Interval" *)
input wire [31:0] OffsetAdjustmentIn3_Interval_DatIn,
(* X_INTERFACE_INFO = "NetTimeLogic:TimeCardLib:TC_ClockAdjustment:1.0 offset_adjustment_3 Valid" *)
input wire OffsetAdjustmentIn3_ValIn,
// Drift Adjustment Input   
(* X_INTERFACE_INFO = "NetTimeLogic:TimeCardLib:TC_ClockAdjustment:1.0 drift_adjustment_3 Nanosecond" *)
input wire [31:0] DriftAdjustmentIn3_Nanosecond_DatIn,
(* X_INTERFACE_INFO = "NetTimeLogic:TimeCardLib:TC_ClockAdjustment:1.0 drift_adjustment_3 Sign" *)
input wire DriftAdjustmentIn3_Sign_DatIn,
(* X_INTERFACE_INFO = "NetTimeLogic:TimeCardLib:TC_ClockAdjustment:1.0 drift_adjustment_3 Interval" *)
input wire [31:0] DriftAdjustmentIn3_Interval_DatIn,
(* X_INTERFACE_INFO = "NetTimeLogic:TimeCardLib:TC_ClockAdjustment:1.0 drift_adjustment_3 Valid" *)
input wire DriftAdjustmentIn3_ValIn,
// Input 4  
// Time Adjustment Input    
(* X_INTERFACE_INFO = "NetTimeLogic:TimeCardLib:TC_ClockAdjustment:1.0 time_adjustment_4 Second" *)
input wire [31:0] TimeAdjustmentIn4_Second_DatIn,
(* X_INTERFACE_INFO = "NetTimeLogic:TimeCardLib:TC_ClockAdjustment:1.0 time_adjustment_4 Nanosecond" *)
input wire [31:0] TimeAdjustmentIn4_Nanosecond_DatIn,
(* X_INTERFACE_INFO = "NetTimeLogic:TimeCardLib:TC_ClockAdjustment:1.0 time_adjustment_4 Valid" *)
input wire TimeAdjustmentIn4_ValIn,
// Offset Adjustment Input  
(* X_INTERFACE_INFO = "NetTimeLogic:TimeCardLib:TC_ClockAdjustment:1.0 offset_adjustment_4 Second" *)
input wire [31:0] OffsetAdjustmentIn4_Second_DatIn,
(* X_INTERFACE_INFO = "NetTimeLogic:TimeCardLib:TC_ClockAdjustment:1.0 offset_adjustment_4 Nanosecond" *)
input wire [31:0] OffsetAdjustmentIn4_Nanosecond_DatIn,
(* X_INTERFACE_INFO = "NetTimeLogic:TimeCardLib:TC_ClockAdjustment:1.0 offset_adjustment_4 Sign" *)
input wire OffsetAdjustmentIn4_Sign_DatIn,
(* X_INTERFACE_INFO = "NetTimeLogic:TimeCardLib:TC_ClockAdjustment:1.0 offset_adjustment_4 Interval" *)
input wire [31:0] OffsetAdjustmentIn4_Interval_DatIn,
(* X_INTERFACE_INFO = "NetTimeLogic:TimeCardLib:TC_ClockAdjustment:1.0 offset_adjustment_4 Valid" *)
input wire OffsetAdjustmentIn4_ValIn,
// Drift Adjustment Input   
(* X_INTERFACE_INFO = "NetTimeLogic:TimeCardLib:TC_ClockAdjustment:1.0 drift_adjustment_4 Nanosecond" *)
input wire [31:0] DriftAdjustmentIn4_Nanosecond_DatIn,
(* X_INTERFACE_INFO = "NetTimeLogic:TimeCardLib:TC_ClockAdjustment:1.0 drift_adjustment_4 Sign" *)
input wire DriftAdjustmentIn4_Sign_DatIn,
(* X_INTERFACE_INFO = "NetTimeLogic:TimeCardLib:TC_ClockAdjustment:1.0 drift_adjustment_4 Interval" *)
input wire [31:0] DriftAdjustmentIn4_Interval_DatIn,
(* X_INTERFACE_INFO = "NetTimeLogic:TimeCardLib:TC_ClockAdjustment:1.0 drift_adjustment_4 Valid" *)
input wire DriftAdjustmentIn4_ValIn,
// Input 5  
// Time Adjustment Input    
(* X_INTERFACE_INFO = "NetTimeLogic:TimeCardLib:TC_ClockAdjustment:1.0 time_adjustment_5 Second" *)
input wire [31:0] TimeAdjustmentIn5_Second_DatIn,
(* X_INTERFACE_INFO = "NetTimeLogic:TimeCardLib:TC_ClockAdjustment:1.0 time_adjustment_5 Nanosecond" *)
input wire [31:0] TimeAdjustmentIn5_Nanosecond_DatIn,
(* X_INTERFACE_INFO = "NetTimeLogic:TimeCardLib:TC_ClockAdjustment:1.0 time_adjustment_5 Valid" *)
input wire TimeAdjustmentIn5_ValIn,
// Offset Adjustment Input  
(* X_INTERFACE_INFO = "NetTimeLogic:TimeCardLib:TC_ClockAdjustment:1.0 offset_adjustment_5 Second" *)
input wire [31:0] OffsetAdjustmentIn5_Second_DatIn,
(* X_INTERFACE_INFO = "NetTimeLogic:TimeCardLib:TC_ClockAdjustment:1.0 offset_adjustment_5 Nanosecond" *)
input wire [31:0] OffsetAdjustmentIn5_Nanosecond_DatIn,
(* X_INTERFACE_INFO = "NetTimeLogic:TimeCardLib:TC_ClockAdjustment:1.0 offset_adjustment_5 Sign" *)
input wire OffsetAdjustmentIn5_Sign_DatIn,
(* X_INTERFACE_INFO = "NetTimeLogic:TimeCardLib:TC_ClockAdjustment:1.0 offset_adjustment_5 Interval" *)
input wire [31:0] OffsetAdjustmentIn5_Interval_DatIn,
(* X_INTERFACE_INFO = "NetTimeLogic:TimeCardLib:TC_ClockAdjustment:1.0 offset_adjustment_5 Valid" *)
input wire OffsetAdjustmentIn5_ValIn,
// Drift Adjustment Input   
(* X_INTERFACE_INFO = "NetTimeLogic:TimeCardLib:TC_ClockAdjustment:1.0 drift_adjustment_5 Nanosecond" *)
input wire [31:0] DriftAdjustmentIn5_Nanosecond_DatIn,
(* X_INTERFACE_INFO = "NetTimeLogic:TimeCardLib:TC_ClockAdjustment:1.0 drift_adjustment_5 Sign" *)
input wire DriftAdjustmentIn5_Sign_DatIn,
(* X_INTERFACE_INFO = "NetTimeLogic:TimeCardLib:TC_ClockAdjustment:1.0 drift_adjustment_5 Interval" *)
input wire [31:0] DriftAdjustmentIn5_Interval_DatIn,
(* X_INTERFACE_INFO = "NetTimeLogic:TimeCardLib:TC_ClockAdjustment:1.0 drift_adjustment_5 Valid" *)
input wire DriftAdjustmentIn5_ValIn,
// Time Output  
(* X_INTERFACE_INFO = "NetTimeLogic:TimeCardLib:TC_Time:1.0 time_out Second" *)
output wire [31:0] ClockTime_Second_DatOut,
(* X_INTERFACE_INFO = "NetTimeLogic:TimeCardLib:TC_Time:1.0 time_out Nanosecond" *)
output wire [31:0] ClockTime_Nanosecond_DatOut,
(* X_INTERFACE_INFO = "NetTimeLogic:TimeCardLib:TC_Time:1.0 time_out TimeJump" *)
output wire ClockTime_TimeJump_DatOut,
(* X_INTERFACE_INFO = "NetTimeLogic:TimeCardLib:TC_Time:1.0 time_out Valid" *)
output wire ClockTime_ValOut,
// In Sync Output   
output wire InSync_DatOut,
output wire InHoldover_DatOut,
// Servo Output 
output wire ServoFactorsValid_ValOut,
(* X_INTERFACE_INFO = "NetTimeLogic:TimeCardLib:TC_Servo:1.0 servo_offset FactorP" *)
output wire [31:0] ServoOffsetFactorP_DatOut,
(* X_INTERFACE_INFO = "NetTimeLogic:TimeCardLib:TC_Servo:1.0 servo_offset FactorI" *)
output wire [31:0] ServoOffsetFactorI_DatOut,
(* X_INTERFACE_INFO = "NetTimeLogic:TimeCardLib:TC_Servo:1.0 servo_drift FactorP" *)
output wire [31:0] ServoDriftFactorP_DatOut,
(* X_INTERFACE_INFO = "NetTimeLogic:TimeCardLib:TC_Servo:1.0 servo_drift FactorI" *)
output wire [31:0] ServoDriftFactorI_DatOut,

(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi AWVALID" *)
input wire AxiWriteAddrValid_ValIn,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi AWREADY" *)
output wire AxiWriteAddrReady_RdyOut,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi AWADDR" *)
input wire [15:0] AxiWriteAddrAddress_AdrIn,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi AWPROT" *)
input wire [2:0] AxiWriteAddrProt_DatIn,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi WVALID" *)
input wire AxiWriteDataValid_ValIn,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi WREADY" *)
output wire AxiWriteDataReady_RdyOut,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi WDATA" *)
input wire [31:0] AxiWriteDataData_DatIn,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi WSTRB" *)
input wire [3:0] AxiWriteDataStrobe_DatIn,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi BVALID" *)
output wire AxiWriteRespValid_ValOut,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi BREADY" *)
input wire AxiWriteRespReady_RdyIn,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi BRESP" *)
output wire [1:0] AxiWriteRespResponse_DatOut,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi ARVALID" *)
input wire AxiReadAddrValid_ValIn,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi ARREADY" *)
output wire AxiReadAddrReady_RdyOut,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi ARADDR" *)
input wire [15:0] AxiReadAddrAddress_AdrIn,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi ARPROT" *)
input wire [2:0] AxiReadAddrProt_DatIn,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi RVALID" *)
output wire AxiReadDataValid_ValOut,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi RREADY" *)
input wire AxiReadDataReady_RdyIn,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi RRESP" *)
output wire [1:0] AxiReadDataResponse_DatOut,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi RDATA" *)
output wire [31:0] AxiReadDataData_DatOut
);
AdjustableClock #(
.ClockPeriod_Gen(ClockPeriod_Gen),
.ClockInSyncThreshold_Gen(ClockInSyncThreshold_Gen),
.ClockInHoldoverTimeoutSecond_Gen(ClockInHoldoverTimeoutSecond_Gen)
) AdjustableClock_inst (
.SysClk_ClkIn(SysClk_ClkIn),
.SysRstN_RstIn(SysRstN_RstIn),

.TimeAdjustmentIn1_Second_DatIn(TimeAdjustmentIn1_Second_DatIn),
.TimeAdjustmentIn1_Nanosecond_DatIn(TimeAdjustmentIn1_Nanosecond_DatIn),
.TimeAdjustmentIn1_ValIn(TimeAdjustmentIn1_ValIn),
.OffsetAdjustmentIn1_Second_DatIn(OffsetAdjustmentIn1_Second_DatIn),
.OffsetAdjustmentIn1_Nanosecond_DatIn(OffsetAdjustmentIn1_Nanosecond_DatIn),
.OffsetAdjustmentIn1_Sign_DatIn(OffsetAdjustmentIn1_Sign_DatIn),
.OffsetAdjustmentIn1_Interval_DatIn(OffsetAdjustmentIn1_Interval_DatIn),
.OffsetAdjustmentIn1_ValIn(OffsetAdjustmentIn1_ValIn),
.DriftAdjustmentIn1_Nanosecond_DatIn(DriftAdjustmentIn1_Nanosecond_DatIn),
.DriftAdjustmentIn1_Sign_DatIn(DriftAdjustmentIn1_Sign_DatIn),
.DriftAdjustmentIn1_Interval_DatIn(DriftAdjustmentIn1_Interval_DatIn),
.DriftAdjustmentIn1_ValIn(DriftAdjustmentIn1_ValIn),
.TimeAdjustmentIn2_Second_DatIn(TimeAdjustmentIn2_Second_DatIn),
.TimeAdjustmentIn2_Nanosecond_DatIn(TimeAdjustmentIn2_Nanosecond_DatIn),
.TimeAdjustmentIn2_ValIn(TimeAdjustmentIn2_ValIn),
.OffsetAdjustmentIn2_Second_DatIn(OffsetAdjustmentIn2_Second_DatIn),
.OffsetAdjustmentIn2_Nanosecond_DatIn(OffsetAdjustmentIn2_Nanosecond_DatIn),
.OffsetAdjustmentIn2_Sign_DatIn(OffsetAdjustmentIn2_Sign_DatIn),
.OffsetAdjustmentIn2_Interval_DatIn(OffsetAdjustmentIn2_Interval_DatIn),
.OffsetAdjustmentIn2_ValIn(OffsetAdjustmentIn2_ValIn),
.DriftAdjustmentIn2_Nanosecond_DatIn(DriftAdjustmentIn2_Nanosecond_DatIn),
.DriftAdjustmentIn2_Sign_DatIn(DriftAdjustmentIn2_Sign_DatIn),
.DriftAdjustmentIn2_Interval_DatIn(DriftAdjustmentIn2_Interval_DatIn),
.DriftAdjustmentIn2_ValIn(DriftAdjustmentIn2_ValIn),
.TimeAdjustmentIn3_Second_DatIn(TimeAdjustmentIn3_Second_DatIn),
.TimeAdjustmentIn3_Nanosecond_DatIn(TimeAdjustmentIn3_Nanosecond_DatIn),
.TimeAdjustmentIn3_ValIn(TimeAdjustmentIn3_ValIn),
.OffsetAdjustmentIn3_Second_DatIn(OffsetAdjustmentIn3_Second_DatIn),
.OffsetAdjustmentIn3_Nanosecond_DatIn(OffsetAdjustmentIn3_Nanosecond_DatIn),
.OffsetAdjustmentIn3_Sign_DatIn(OffsetAdjustmentIn3_Sign_DatIn),
.OffsetAdjustmentIn3_Interval_DatIn(OffsetAdjustmentIn3_Interval_DatIn),
.OffsetAdjustmentIn3_ValIn(OffsetAdjustmentIn3_ValIn),
.DriftAdjustmentIn3_Nanosecond_DatIn(DriftAdjustmentIn3_Nanosecond_DatIn),
.DriftAdjustmentIn3_Sign_DatIn(DriftAdjustmentIn3_Sign_DatIn),
.DriftAdjustmentIn3_Interval_DatIn(DriftAdjustmentIn3_Interval_DatIn),
.DriftAdjustmentIn3_ValIn(DriftAdjustmentIn3_ValIn),
.TimeAdjustmentIn4_Second_DatIn(TimeAdjustmentIn4_Second_DatIn),
.TimeAdjustmentIn4_Nanosecond_DatIn(TimeAdjustmentIn4_Nanosecond_DatIn),
.TimeAdjustmentIn4_ValIn(TimeAdjustmentIn4_ValIn),
.OffsetAdjustmentIn4_Second_DatIn(OffsetAdjustmentIn4_Second_DatIn),
.OffsetAdjustmentIn4_Nanosecond_DatIn(OffsetAdjustmentIn4_Nanosecond_DatIn),
.OffsetAdjustmentIn4_Sign_DatIn(OffsetAdjustmentIn4_Sign_DatIn),
.OffsetAdjustmentIn4_Interval_DatIn(OffsetAdjustmentIn4_Interval_DatIn),
.OffsetAdjustmentIn4_ValIn(OffsetAdjustmentIn4_ValIn),
.DriftAdjustmentIn4_Nanosecond_DatIn(DriftAdjustmentIn4_Nanosecond_DatIn),
.DriftAdjustmentIn4_Sign_DatIn(DriftAdjustmentIn4_Sign_DatIn),
.DriftAdjustmentIn4_Interval_DatIn(DriftAdjustmentIn4_Interval_DatIn),
.DriftAdjustmentIn4_ValIn(DriftAdjustmentIn4_ValIn),
.TimeAdjustmentIn5_Second_DatIn(TimeAdjustmentIn5_Second_DatIn),
.TimeAdjustmentIn5_Nanosecond_DatIn(TimeAdjustmentIn5_Nanosecond_DatIn),
.TimeAdjustmentIn5_ValIn(TimeAdjustmentIn5_ValIn),
.OffsetAdjustmentIn5_Second_DatIn(OffsetAdjustmentIn5_Second_DatIn),
.OffsetAdjustmentIn5_Nanosecond_DatIn(OffsetAdjustmentIn5_Nanosecond_DatIn),
.OffsetAdjustmentIn5_Sign_DatIn(OffsetAdjustmentIn5_Sign_DatIn),
.OffsetAdjustmentIn5_Interval_DatIn(OffsetAdjustmentIn5_Interval_DatIn),
.OffsetAdjustmentIn5_ValIn(OffsetAdjustmentIn5_ValIn),
.DriftAdjustmentIn5_Nanosecond_DatIn(DriftAdjustmentIn5_Nanosecond_DatIn),
.DriftAdjustmentIn5_Sign_DatIn(DriftAdjustmentIn5_Sign_DatIn),
.DriftAdjustmentIn5_Interval_DatIn(DriftAdjustmentIn5_Interval_DatIn),
.DriftAdjustmentIn5_ValIn(DriftAdjustmentIn5_ValIn),
.ClockTime_Second_DatOut(ClockTime_Second_DatOut),
.ClockTime_Nanosecond_DatOut(ClockTime_Nanosecond_DatOut),
.ClockTime_TimeJump_DatOut(ClockTime_TimeJump_DatOut),
.ClockTime_ValOut(ClockTime_ValOut),
.InSync_DatOut(InSync_DatOut),
.InHoldover_DatOut(InHoldover_DatOut),
.ServoFactorsValid_ValOut(ServoFactorsValid_ValOut),
.ServoOffsetFactorP_DatOut(ServoOffsetFactorP_DatOut),
.ServoOffsetFactorI_DatOut(ServoOffsetFactorI_DatOut),
.ServoDriftFactorP_DatOut(ServoDriftFactorP_DatOut),
.ServoDriftFactorI_DatOut(ServoDriftFactorI_DatOut),

.AxiWriteAddrValid_ValIn(AxiWriteAddrValid_ValIn),
.AxiWriteAddrReady_RdyOut(AxiWriteAddrReady_RdyOut),
.AxiWriteAddrAddress_AdrIn(AxiWriteAddrAddress_AdrIn),
.AxiWriteAddrProt_DatIn(AxiWriteAddrProt_DatIn),
.AxiWriteDataValid_ValIn(AxiWriteDataValid_ValIn),
.AxiWriteDataReady_RdyOut(AxiWriteDataReady_RdyOut),
.AxiWriteDataData_DatIn(AxiWriteDataData_DatIn),
.AxiWriteDataStrobe_DatIn(AxiWriteDataStrobe_DatIn),
.AxiWriteRespValid_ValOut(AxiWriteRespValid_ValOut),
.AxiWriteRespReady_RdyIn(AxiWriteRespReady_RdyIn),
.AxiWriteRespResponse_DatOut(AxiWriteRespResponse_DatOut),
.AxiReadAddrValid_ValIn(AxiReadAddrValid_ValIn),
.AxiReadAddrReady_RdyOut(AxiReadAddrReady_RdyOut),
.AxiReadAddrAddress_AdrIn(AxiReadAddrAddress_AdrIn),
.AxiReadAddrProt_DatIn(AxiReadAddrProt_DatIn),
.AxiReadDataValid_ValOut(AxiReadDataValid_ValOut),
.AxiReadDataReady_RdyIn(AxiReadDataReady_RdyIn),
.AxiReadDataResponse_DatOut(AxiReadDataResponse_DatOut),
.AxiReadDataData_DatOut(AxiReadDataData_DatOut)
);
endmodule
