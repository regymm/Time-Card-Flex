// SPDX-License-Identifier: GPL-3.0
module ConfMaster_v #(
parameter ConfigListSize = 14,
parameter RomAddrWidth_Con = 4,
parameter [31:0] AxiTimeout_Gen=0,
parameter ConfigFile_Processed="/dev/null",
parameter [31:0] ClockPeriod_Gen=20
)(
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME m_axi_clk, ASSOCIATED_BUSIF m_axi, ASSOCIATED_RESET m_axi_aresetn" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 m_axi_clk CLK" *)
input wire SysClk_ClkIn,
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 m_axi_aresetn RST" *)
input wire SysRstN_RstIn,
output wire ConfigDone_ValOut,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi AWVALID" *)
output wire AxiWriteAddrValid_ValOut,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi AWREADY" *)
input wire AxiWriteAddrReady_RdyIn,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi AWADDR" *)
output wire [31:0] AxiWriteAddrAddress_AdrOut,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi AWPROT" *)
output wire [2:0] AxiWriteAddrProt_DatOut,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi WVALID" *)
output wire AxiWriteDataValid_ValOut,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi WREADY" *)
input wire AxiWriteDataReady_RdyIn,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi WDATA" *)
output wire [31:0] AxiWriteDataData_DatOut,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi WSTRB" *)
output wire [3:0] AxiWriteDataStrobe_DatOut,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi BVALID" *)
input wire AxiWriteRespValid_ValIn,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi BREADY" *)
output wire AxiWriteRespReady_RdyOut,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi BRESP" *)
input wire [1:0] AxiWriteRespResponse_DatIn,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi ARVALID" *)
output wire AxiReadAddrValid_ValOut,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi ARREADY" *)
input wire AxiReadAddrReady_RdyIn,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi ARADDR" *)
output wire [31:0] AxiReadAddrAddress_AdrOut,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi ARPROT" *)
output wire [2:0] AxiReadAddrProt_DatOut,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi RVALID" *)
input wire AxiReadDataValid_ValIn,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi RREADY" *)
output wire AxiReadDataReady_RdyOut,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi RRESP" *)
input wire [1:0] AxiReadDataResponse_DatIn,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi RDATA" *)
input wire [31:0] AxiReadDataData_DatIn
);
ConfMaster #(
.ConfigListSize(ConfigListSize),
.RomAddrWidth_Con(RomAddrWidth_Con),
.AxiTimeout_Gen(AxiTimeout_Gen),
.ConfigFile_Processed(ConfigFile_Processed),
.ClockPeriod_Gen(ClockPeriod_Gen)
) ConfMaster_inst (
.SysClk_ClkIn(SysClk_ClkIn),
.SysRstN_RstIn(SysRstN_RstIn),
.ConfigDone_ValOut(ConfigDone_ValOut),
.AxiWriteAddrValid_ValOut(AxiWriteAddrValid_ValOut),
.AxiWriteAddrReady_RdyIn(AxiWriteAddrReady_RdyIn),
.AxiWriteAddrAddress_AdrOut(AxiWriteAddrAddress_AdrOut),
.AxiWriteAddrProt_DatOut(AxiWriteAddrProt_DatOut),
.AxiWriteDataValid_ValOut(AxiWriteDataValid_ValOut),
.AxiWriteDataReady_RdyIn(AxiWriteDataReady_RdyIn),
.AxiWriteDataData_DatOut(AxiWriteDataData_DatOut),
.AxiWriteDataStrobe_DatOut(AxiWriteDataStrobe_DatOut),
.AxiWriteRespValid_ValIn(AxiWriteRespValid_ValIn),
.AxiWriteRespReady_RdyOut(AxiWriteRespReady_RdyOut),
.AxiWriteRespResponse_DatIn(AxiWriteRespResponse_DatIn),
.AxiReadAddrValid_ValOut(AxiReadAddrValid_ValOut),
.AxiReadAddrReady_RdyIn(AxiReadAddrReady_RdyIn),
.AxiReadAddrAddress_AdrOut(AxiReadAddrAddress_AdrOut),
.AxiReadAddrProt_DatOut(AxiReadAddrProt_DatOut),
.AxiReadDataValid_ValIn(AxiReadDataValid_ValIn),
.AxiReadDataReady_RdyOut(AxiReadDataReady_RdyOut),
.AxiReadDataResponse_DatIn(AxiReadDataResponse_DatIn),
.AxiReadDataData_DatIn(AxiReadDataData_DatIn)
);
endmodule
