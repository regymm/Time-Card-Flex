// SPDX-License-Identifier: GPL-3.0
module PpsGenerator_v #(
parameter [31:0] ClockPeriod_Gen=20,
parameter CableDelay_Gen="true",
parameter [31:0] OutputDelay_Gen=0,
parameter OutputPolarity_Gen="true",
parameter [31:0] HighResFreqMultiply_Gen=4,
parameter Sim_Gen="false"
)(
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME s_axi_clk, ASSOCIATED_BUSIF s_axi, ASSOCIATED_RESET s_axi_aresetn" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 s_axi_clk CLK" *)
input wire SysClk_ClkIn,
input wire SysClkNx_ClkIn,
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 s_axi_aresetn RST" *)
input wire SysRstN_RstIn,
(* X_INTERFACE_MODE = "monitor" *)
(* X_INTERFACE_INFO = "NetTimeLogic:TimeCardLib:TC_Time:1.0 time_in Second" *)
input wire [32 - 1:0] ClockTime_Second_DatIn, // do not include the svh here
(* X_INTERFACE_INFO = "NetTimeLogic:TimeCardLib:TC_Time:1.0 time_in Nanosecond" *)
input wire [32 - 1:0] ClockTime_Nanosecond_DatIn,
(* X_INTERFACE_INFO = "NetTimeLogic:TimeCardLib:TC_Time:1.0 time_in TimeJump" *)
input wire ClockTime_TimeJump_DatIn,
(* X_INTERFACE_INFO = "NetTimeLogic:TimeCardLib:TC_Time:1.0 time_in Valid" *)
input wire ClockTime_ValIn,
output wire Pps_EvtOut,
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
PpsGenerator#(
.OutputPolarity_Gen(OutputPolarity_Gen)
)PpsGenerator_inst(
.SysClk_ClkIn(SysClk_ClkIn),
.SysClkNx_ClkIn(SysClkNx_ClkIn),
.SysRstN_RstIn(SysRstN_RstIn),
.ClockTime_Second_DatIn(ClockTime_Second_DatIn),
.ClockTime_Nanosecond_DatIn(ClockTime_Nanosecond_DatIn),
.ClockTime_TimeJump_DatIn(ClockTime_TimeJump_DatIn),
.ClockTime_ValIn(ClockTime_ValIn),
.Pps_EvtOut(Pps_EvtOut),
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
