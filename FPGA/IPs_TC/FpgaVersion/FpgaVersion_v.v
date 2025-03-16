// SPDX-License-Identifier: GPL-3.0
module FpgaVersion_v #(
parameter [15:0] VersionNumber_Gen=16'h000a,
parameter [15:0] VersionNumber_Golden_Gen=16'h000a
)(
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME s_axi_clk, ASSOCIATED_BUSIF s_axi, ASSOCIATED_RESET s_axi_aresetn" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 s_axi_clk CLK" *)
input wire SysClk_ClkIn,
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 s_axi_aresetn RST" *)
input wire SysRstN_RstIn,
input wire GoldenImageN_EnaIn,
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
FpgaVersion#(
.VersionNumber_Gen(VersionNumber_Gen),
.VersionNumber_Golden_Gen(VersionNumber_Golden_Gen)
)FpgaVersion_inst(
.SysClk_ClkIn(SysClk_ClkIn),
.SysRstN_RstIn(SysRstN_RstIn),
.GoldenImageN_EnaIn(GoldenImageN_EnaIn),
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
