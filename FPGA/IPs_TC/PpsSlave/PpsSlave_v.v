module PpsSlave_v #(
parameter [31:0] ClockPeriod_Gen=20,
parameter CableDelay_Gen="false",
parameter [31:0] InputDelay_Gen=0,
parameter InputPolarity_Gen="true",
parameter [31:0] HighResFreqMultiply_Gen=4,
parameter [31:0] DriftMulP_Gen=3,
parameter [31:0] DriftDivP_Gen=4,
parameter [31:0] DriftMulI_Gen=3,
parameter [31:0] DriftDivI_Gen=16,
parameter [31:0] OffsetMulP_Gen=3,
parameter [31:0] OffsetDivP_Gen=4,
parameter [31:0] OffsetMulI_Gen=3,
parameter [31:0] OffsetDivI_Gen=16,
parameter Sim_Gen="false"
)(
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME s_axi_clk, ASSOCIATED_BUSIF s_axi, ASSOCIATED_RESET s_axi_aresetn" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 s_axi_clk CLK" *)
input wire SysClk_ClkIn,
input wire SysClkNx_ClkIn,
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 s_axi_aresetn RST" *)
input wire SysRstN_RstIn,
//(* X_INTERFACE_MODE = "monitor" *)
(* X_INTERFACE_INFO = "NetTimeLogic:TimeCardLib:TC_Time:1.0 time_in Second" *)
input wire [32 - 1:0] ClockTime_Second_DatIn, // do not include the svh here
(* X_INTERFACE_INFO = "NetTimeLogic:TimeCardLib:TC_Time:1.0 time_in Nanosecond" *)
input wire [32 - 1:0] ClockTime_Nanosecond_DatIn,
(* X_INTERFACE_INFO = "NetTimeLogic:TimeCardLib:TC_Time:1.0 time_in TimeJump" *)
input wire ClockTime_TimeJump_DatIn,
(* X_INTERFACE_INFO = "NetTimeLogic:TimeCardLib:TC_Time:1.0 time_in Valid" *)
input wire ClockTime_ValIn,
input wire Pps_EvtIn,
input wire Servo_ValIn,
(* X_INTERFACE_INFO = "NetTimeLogic:TimeCardLib:TC_Servo:1.0 servo_offset_factor_in FactorP" *)
input wire [31:0] ServoOffsetFactorP_DatIn,
(* X_INTERFACE_INFO = "NetTimeLogic:TimeCardLib:TC_Servo:1.0 servo_offset_factor_in FactorI" *)
input wire [31:0] ServoOffsetFactorI_DatIn,
(* X_INTERFACE_INFO = "NetTimeLogic:TimeCardLib:TC_Servo:1.0 servo_drift_factor_in FactorP" *)
input wire [31:0] ServoDriftFactorP_DatIn,
(* X_INTERFACE_INFO = "NetTimeLogic:TimeCardLib:TC_Servo:1.0 servo_drift_factor_in FactorI" *)
input wire [31:0] ServoDriftFactorI_DatIn,
(* X_INTERFACE_INFO = "NetTimeLogic:TimeCardLib:TC_ClockAdjustment:1.0 offset_adjustment_out Second" *)
output wire [31:0] OffsetAdjustment_Second_DatOut,
(* X_INTERFACE_INFO = "NetTimeLogic:TimeCardLib:TC_ClockAdjustment:1.0 offset_adjustment_out Nanosecond" *)
output wire [31:0] OffsetAdjustment_Nanosecond_DatOut,
(* X_INTERFACE_INFO = "NetTimeLogic:TimeCardLib:TC_ClockAdjustment:1.0 offset_adjustment_out Sign" *)
output wire OffsetAdjustment_Sign_DatOut,
(* X_INTERFACE_INFO = "NetTimeLogic:TimeCardLib:TC_ClockAdjustment:1.0 offset_adjustment_out Interval" *)
output wire [31:0] OffsetAdjustment_Interval_DatOut,
(* X_INTERFACE_INFO = "NetTimeLogic:TimeCardLib:TC_ClockAdjustment:1.0 offset_adjustment_out Valid" *)
output wire OffsetAdjustment_ValOut,
(* X_INTERFACE_INFO = "NetTimeLogic:TimeCardLib:TC_ClockAdjustment:1.0 drift_adjustment_out Nanosecond" *)
output wire [31:0] DriftAdjustment_Nanosecond_DatOut,
(* X_INTERFACE_INFO = "NetTimeLogic:TimeCardLib:TC_ClockAdjustment:1.0 drift_adjustment_out Sign" *)
output wire DriftAdjustment_Sign_DatOut,
(* X_INTERFACE_INFO = "NetTimeLogic:TimeCardLib:TC_ClockAdjustment:1.0 drift_adjustment_out Interval" *)
output wire [31:0] DriftAdjustment_Interval_DatOut,
(* X_INTERFACE_INFO = "NetTimeLogic:TimeCardLib:TC_ClockAdjustment:1.0 drift_adjustment_out Valid" *)
output wire DriftAdjustment_ValOut,
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
PpsSlave #(
.ClockPeriod_Gen(ClockPeriod_Gen),
.CableDelay_Gen(CableDelay_Gen),
.InputDelay_Gen(InputDelay_Gen),
.InputPolarity_Gen(InputPolarity_Gen),
.HighResFreqMultiply_Gen(HighResFreqMultiply_Gen),
.DriftMulP_Gen(DriftMulP_Gen),
.DriftDivP_Gen(DriftDivP_Gen),
.DriftMulI_Gen(DriftMulI_Gen),
.DriftDivI_Gen(DriftDivI_Gen),
.OffsetMulP_Gen(OffsetMulP_Gen),
.OffsetDivP_Gen(OffsetDivP_Gen),
.OffsetMulI_Gen(OffsetMulI_Gen),
.OffsetDivI_Gen(OffsetDivI_Gen),
.Sim_Gen(Sim_Gen)
) PpsSlave_inst (
.SysClk_ClkIn(SysClk_ClkIn),
.SysClkNx_ClkIn(SysClkNx_ClkIn),
.SysRstN_RstIn(SysRstN_RstIn),
.ClockTime_Second_DatIn(ClockTime_Second_DatIn),
.ClockTime_Nanosecond_DatIn(ClockTime_Nanosecond_DatIn),
.ClockTime_TimeJump_DatIn(ClockTime_TimeJump_DatIn),
.ClockTime_ValIn(ClockTime_ValIn),
.Pps_EvtIn(Pps_EvtIn),
.Servo_ValIn(Servo_ValIn),
.ServoOffsetFactorP_DatIn(ServoOffsetFactorP_DatIn),
.ServoOffsetFactorI_DatIn(ServoOffsetFactorI_DatIn),
.ServoDriftFactorP_DatIn(ServoDriftFactorP_DatIn),
.ServoDriftFactorI_DatIn(ServoDriftFactorI_DatIn),
.OffsetAdjustment_Second_DatOut(OffsetAdjustment_Second_DatOut),
.OffsetAdjustment_Nanosecond_DatOut(OffsetAdjustment_Nanosecond_DatOut),
.OffsetAdjustment_Sign_DatOut(OffsetAdjustment_Sign_DatOut),
.OffsetAdjustment_Interval_DatOut(OffsetAdjustment_Interval_DatOut),
.OffsetAdjustment_ValOut(OffsetAdjustment_ValOut),
.DriftAdjustment_Nanosecond_DatOut(DriftAdjustment_Nanosecond_DatOut),
.DriftAdjustment_Sign_DatOut(DriftAdjustment_Sign_DatOut),
.DriftAdjustment_Interval_DatOut(DriftAdjustment_Interval_DatOut),
.DriftAdjustment_ValOut(DriftAdjustment_ValOut),
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
