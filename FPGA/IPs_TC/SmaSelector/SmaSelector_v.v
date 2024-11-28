/*
choice_pairs_2e41af12
"Disable Output" 0x0000
"10 MHz Clock" 0x8000
"FPGA PPS" 0x8001
"MAC PPS" 0x8002
"GNSS 1 PPS" 0x8004
"GNSS 2 PPS" 0x8008
"IRIG Master (unused)" 0x8010
"DCF Master (unused)" 0x8020
"Signal Generator 1" 0x8040
"Signal Generator 2" 0x8080
"Signal Generator 3" 0x8100
"Signal Generator 4" 0x8200
"GNSS 1 UART" 0x8400
"GNSS 2 UART" 0x8800
"External UART" 0x9000
"GND" 0xA000
"VCC" 0xC000
choice_pairs_48c3435f
"Disable Output" 0x0000
"10 MHz clock" 0x8000
"FPGA PPS" 0x8001
"MAC PPS" 0x8002
"GNSS 1 PPS" 0x8004
"GNSS 2 PPS" 0x8008
"IRIG Master (unused)" 0x8010
"DCF Master (unused)" 0x8020
"Signal Generator 1" 0x8040
"Signal Generator 2" 0x8080
"Signal Generator 3" 0x8100
"Signal Generator 4" 0x8200
"GNSS 1 UART" 0x8400
"GNSS 2 UART" 0x8800
"External UART" 0x9000
"GND" 0xA000
"VCC" 0xC000
choice_pairs_64c3054d
"Disable Output" 0x0000
"10 MHz clock" 0x8000
"FPGA PPS" 0x8001
"MAC PPS" 0x8002
"GNSS 1 PPS" 0x8004
"GNSS 2 PPS" 0x8008
"IRIG Master (unused)" 0x8010
"DCF Master (unused)" 0x8020
"Signal Generator 1 " 0x8040
"Signal Generator 2" 0x8080
"Signal Generator 3" 0x8100
"Signal Generator 4" 0x8200
"GNSS 1 UART" 0x8400
"GNSS 2 UART" 0x8800
"External UART" 0x9000
"GND" 0xA000
"VCC" 0xC000
choice_pairs_cc64e1a8
"Disable Input" 0x0000
"External PPS 1" 0x8001
"External PPS 2" 0x8002
"Signal Timestamper 1" 0x8004
"Signal Timestamper 2" 0x8008
"IRIG Slave (unused)" 0x8010
"DCF Slave (unused)" 0x8020
"Signal Timestamper 3" 0x8040
"Signal Timestamper 4" 0x8080
"Frequency Counter 1" 0x8100
"Frequency Counter 2" 0x8200
"Frequency Counter 3" 0x8400
"Frequency Counter 4" 0x8800
"External UART" 0x9000
choice_pairs_d9017ea1
"Disable Input" 0x0000
"Enable 10 MHz " 0x8000
"External PPS 1" 0x8001
"External PPS 2" 0x8002
"Signal Timestamper 1" 0x8004
"Signal Timestamper 2" 0x8008
"IRIG Slave (unused)" 0x8010
"DCF Slave (unused)" 0x8020
"Signal Timestamper 3" 0x8040
"Signal Timestamper 4" 0x8080
"Frequency Counter 1" 0x8100
"Frequency Counter 2" 0x8200
"Frequency Counter 3" 0x8400
"Frequency Counter 4" 0x8800
"External UART" 0x9000
*/
module SmaSelector_v #(
parameter [15:0] SmaInput1SourceSelect_Gen=16'h8000, // d901, enable 10 MHz
parameter [15:0] SmaInput2SourceSelect_Gen=16'h8001, // cc64, External PPS 1
parameter [15:0] SmaInput3SourceSelect_Gen=16'h0000, // cc64
parameter [15:0] SmaInput4SourceSelect_Gen=16'h0000, // cc64
parameter [15:0] SmaOutput1SourceSelect_Gen=16'h0000, // 64c3
parameter [15:0] SmaOutput2SourceSelect_Gen=16'h0000, // 48c3
parameter [15:0] SmaOutput3SourceSelect_Gen=16'h8000, // 2e41 10 MHz clock
parameter [15:0] SmaOutput4SourceSelect_Gen=16'h8001  // 48c3 FPGA PPS
)(
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME s_axi_clk, ASSOCIATED_BUSIF s_axi:s_axi_2, ASSOCIATED_RESET s_axi_aresetn" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 s_axi_clk CLK" *)
input wire SysClk_ClkIn,
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 s_axi_aresetn RST" *)
input wire SysRstN_RstIn,
// Sma Input Sources                
output wire Sma10MHzSourceEnable_EnOut,
output wire SmaExtPpsSource1_EvtOut,
output wire SmaExtPpsSource2_EvtOut,
output wire SmaTs1Source_EvtOut,
output wire SmaTs2Source_EvtOut,
output wire SmaTs3Source_EvtOut,
output wire SmaTs4Source_EvtOut,
output wire SmaFreqCnt1Source_EvtOut,
output wire SmaFreqCnt2Source_EvtOut,
output wire SmaFreqCnt3Source_EvtOut,
output wire SmaFreqCnt4Source_EvtOut,
output wire SmaIrigSlaveSource_DatOut,
output wire SmaDcfSlaveSource_DatOut,
output wire SmaUartExtSource_DatOut,
// Sma Output Sources           
input wire Sma10MHzSource_ClkIn,
input wire SmaFpgaPpsSource_EvtIn,
input wire SmaMacPpsSource_EvtIn,
input wire SmaGnss1PpsSource_EvtIn,
input wire SmaGnss2PpsSource_EvtIn,
input wire SmaIrigMasterSource_DatIn,
input wire SmaDcfMasterSource_DatIn,
input wire SmaSignalGen1Source_DatIn,
input wire SmaSignalGen2Source_DatIn,
input wire SmaSignalGen3Source_DatIn,
input wire SmaSignalGen4Source_DatIn,
input wire SmaUartGnss1Source_DatIn,
input wire SmaUartGnss2Source_DatIn,
input wire SmaUartExtSource_DatIn,
// Sma Input            
input wire SmaIn1_DatIn,
input wire SmaIn2_DatIn,
input wire SmaIn3_DatIn,
input wire SmaIn4_DatIn,
// Sma Output            
output wire SmaOut1_DatOut,
output wire SmaOut2_DatOut,
output wire SmaOut3_DatOut,
output wire SmaOut4_DatOut,
// Buffer enable            
output wire SmaIn1_EnOut,
output wire SmaIn2_EnOut,
output wire SmaIn3_EnOut,
output wire SmaIn4_EnOut,
output wire SmaOut1_EnOut,
output wire SmaOut2_EnOut,
output wire SmaOut3_EnOut,
output wire SmaOut4_EnOut,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi AWVALID" *)
input wire Axi1WriteAddrValid_ValIn,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi AWREADY" *)
output wire Axi1WriteAddrReady_RdyOut,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi AWADDR" *)
input wire [15:0] Axi1WriteAddrAddress_AdrIn,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi AWPROT" *)
input wire [2:0] Axi1WriteAddrProt_DatIn,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi WVALID" *)
input wire Axi1WriteDataValid_ValIn,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi WREADY" *)
output wire Axi1WriteDataReady_RdyOut,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi WDATA" *)
input wire [31:0] Axi1WriteDataData_DatIn,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi WSTRB" *)
input wire [3:0] Axi1WriteDataStrobe_DatIn,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi BVALID" *)
output wire Axi1WriteRespValid_ValOut,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi BREADY" *)
input wire Axi1WriteRespReady_RdyIn,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi BRESP" *)
output wire [1:0] Axi1WriteRespResponse_DatOut,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi ARVALID" *)
input wire Axi1ReadAddrValid_ValIn,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi ARREADY" *)
output wire Axi1ReadAddrReady_RdyOut,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi ARADDR" *)
input wire [15:0] Axi1ReadAddrAddress_AdrIn,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi ARPROT" *)
input wire [2:0] Axi1ReadAddrProt_DatIn,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi RVALID" *)
output wire Axi1ReadDataValid_ValOut,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi RREADY" *)
input wire Axi1ReadDataReady_RdyIn,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi RRESP" *)
output wire [1:0] Axi1ReadDataResponse_DatOut,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi RDATA" *)
output wire [31:0] Axi1ReadDataData_DatOut,

(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi_2 AWVALID" *)
input wire Axi2WriteAddrValid_ValIn,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi_2 AWREADY" *)
output wire Axi2WriteAddrReady_RdyOut,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi_2 AWADDR" *)
input wire [15:0] Axi2WriteAddrAddress_AdrIn,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi_2 AWPROT" *)
input wire [2:0] Axi2WriteAddrProt_DatIn,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi_2 WVALID" *)
input wire Axi2WriteDataValid_ValIn,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi_2 WREADY" *)
output wire Axi2WriteDataReady_RdyOut,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi_2 WDATA" *)
input wire [31:0] Axi2WriteDataData_DatIn,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi_2 WSTRB" *)
input wire [3:0] Axi2WriteDataStrobe_DatIn,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi_2 BVALID" *)
output wire Axi2WriteRespValid_ValOut,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi_2 BREADY" *)
input wire Axi2WriteRespReady_RdyIn,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi_2 BRESP" *)
output wire [1:0] Axi2WriteRespResponse_DatOut,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi_2 ARVALID" *)
input wire Axi2ReadAddrValid_ValIn,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi_2 ARREADY" *)
output wire Axi2ReadAddrReady_RdyOut,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi_2 ARADDR" *)
input wire [15:0] Axi2ReadAddrAddress_AdrIn,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi_2 ARPROT" *)
input wire [2:0] Axi2ReadAddrProt_DatIn,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi_2 RVALID" *)
output wire Axi2ReadDataValid_ValOut,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi_2 RREADY" *)
input wire Axi2ReadDataReady_RdyIn,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi_2 RRESP" *)
output wire [1:0] Axi2ReadDataResponse_DatOut,
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi_2 RDATA" *)
output wire [31:0] Axi2ReadDataData_DatOut
);
SmaSelector #(
.SmaInput1SourceSelect_Gen(SmaInput1SourceSelect_Gen),
.SmaInput2SourceSelect_Gen(SmaInput2SourceSelect_Gen),
.SmaInput3SourceSelect_Gen(SmaInput3SourceSelect_Gen),
.SmaInput4SourceSelect_Gen(SmaInput4SourceSelect_Gen),
.SmaOutput1SourceSelect_Gen(SmaOutput1SourceSelect_Gen),
.SmaOutput2SourceSelect_Gen(SmaOutput2SourceSelect_Gen),
.SmaOutput3SourceSelect_Gen(SmaOutput3SourceSelect_Gen),
.SmaOutput4SourceSelect_Gen(SmaOutput4SourceSelect_Gen)
) SmaSelector_inst (
.SysClk_ClkIn(SysClk_ClkIn),
.SysRstN_RstIn(SysRstN_RstIn),
.Sma10MHzSourceEnable_EnOut(Sma10MHzSourceEnable_EnOut),
.SmaExtPpsSource1_EvtOut(SmaExtPpsSource1_EvtOut),
.SmaExtPpsSource2_EvtOut(SmaExtPpsSource2_EvtOut),
.SmaTs1Source_EvtOut(SmaTs1Source_EvtOut),
.SmaTs2Source_EvtOut(SmaTs2Source_EvtOut),
.SmaTs3Source_EvtOut(SmaTs3Source_EvtOut),
.SmaTs4Source_EvtOut(SmaTs4Source_EvtOut),
.SmaFreqCnt1Source_EvtOut(SmaFreqCnt1Source_EvtOut),
.SmaFreqCnt2Source_EvtOut(SmaFreqCnt2Source_EvtOut),
.SmaFreqCnt3Source_EvtOut(SmaFreqCnt3Source_EvtOut),
.SmaFreqCnt4Source_EvtOut(SmaFreqCnt4Source_EvtOut),
.SmaIrigSlaveSource_DatOut(SmaIrigSlaveSource_DatOut),
.SmaDcfSlaveSource_DatOut(SmaDcfSlaveSource_DatOut),
.SmaUartExtSource_DatOut(SmaUartExtSource_DatOut),
.Sma10MHzSource_ClkIn(Sma10MHzSource_ClkIn),
.SmaFpgaPpsSource_EvtIn(SmaFpgaPpsSource_EvtIn),
.SmaMacPpsSource_EvtIn(SmaMacPpsSource_EvtIn),
.SmaGnss1PpsSource_EvtIn(SmaGnss1PpsSource_EvtIn),
.SmaGnss2PpsSource_EvtIn(SmaGnss2PpsSource_EvtIn),
.SmaIrigMasterSource_DatIn(SmaIrigMasterSource_DatIn),
.SmaDcfMasterSource_DatIn(SmaDcfMasterSource_DatIn),
.SmaSignalGen1Source_DatIn(SmaSignalGen1Source_DatIn),
.SmaSignalGen2Source_DatIn(SmaSignalGen2Source_DatIn),
.SmaSignalGen3Source_DatIn(SmaSignalGen3Source_DatIn),
.SmaSignalGen4Source_DatIn(SmaSignalGen4Source_DatIn),
.SmaUartGnss1Source_DatIn(SmaUartGnss1Source_DatIn),
.SmaUartGnss2Source_DatIn(SmaUartGnss2Source_DatIn),
.SmaUartExtSource_DatIn(SmaUartExtSource_DatIn),
.SmaIn1_DatIn(SmaIn1_DatIn),
.SmaIn2_DatIn(SmaIn2_DatIn),
.SmaIn3_DatIn(SmaIn3_DatIn),
.SmaIn4_DatIn(SmaIn4_DatIn),
.SmaOut1_DatOut(SmaOut1_DatOut),
.SmaOut2_DatOut(SmaOut2_DatOut),
.SmaOut3_DatOut(SmaOut3_DatOut),
.SmaOut4_DatOut(SmaOut4_DatOut),
.SmaIn1_EnOut(SmaIn1_EnOut),
.SmaIn2_EnOut(SmaIn2_EnOut),
.SmaIn3_EnOut(SmaIn3_EnOut),
.SmaIn4_EnOut(SmaIn4_EnOut),
.SmaOut1_EnOut(SmaOut1_EnOut),
.SmaOut2_EnOut(SmaOut2_EnOut),
.SmaOut3_EnOut(SmaOut3_EnOut),
.SmaOut4_EnOut(SmaOut4_EnOut),
.Axi1WriteAddrValid_ValIn(Axi1WriteAddrValid_ValIn),
.Axi1WriteAddrReady_RdyOut(Axi1WriteAddrReady_RdyOut),
.Axi1WriteAddrAddress_AdrIn(Axi1WriteAddrAddress_AdrIn),
.Axi1WriteAddrProt_DatIn(Axi1WriteAddrProt_DatIn),
.Axi1WriteDataValid_ValIn(Axi1WriteDataValid_ValIn),
.Axi1WriteDataReady_RdyOut(Axi1WriteDataReady_RdyOut),
.Axi1WriteDataData_DatIn(Axi1WriteDataData_DatIn),
.Axi1WriteDataStrobe_DatIn(Axi1WriteDataStrobe_DatIn),
.Axi1WriteRespValid_ValOut(Axi1WriteRespValid_ValOut),
.Axi1WriteRespReady_RdyIn(Axi1WriteRespReady_RdyIn),
.Axi1WriteRespResponse_DatOut(Axi1WriteRespResponse_DatOut),
.Axi1ReadAddrValid_ValIn(Axi1ReadAddrValid_ValIn),
.Axi1ReadAddrReady_RdyOut(Axi1ReadAddrReady_RdyOut),
.Axi1ReadAddrAddress_AdrIn(Axi1ReadAddrAddress_AdrIn),
.Axi1ReadAddrProt_DatIn(Axi1ReadAddrProt_DatIn),
.Axi1ReadDataValid_ValOut(Axi1ReadDataValid_ValOut),
.Axi1ReadDataReady_RdyIn(Axi1ReadDataReady_RdyIn),
.Axi1ReadDataResponse_DatOut(Axi1ReadDataResponse_DatOut),
.Axi1ReadDataData_DatOut(Axi1ReadDataData_DatOut),
.Axi2WriteAddrValid_ValIn(Axi2WriteAddrValid_ValIn),
.Axi2WriteAddrReady_RdyOut(Axi2WriteAddrReady_RdyOut),
.Axi2WriteAddrAddress_AdrIn(Axi2WriteAddrAddress_AdrIn),
.Axi2WriteAddrProt_DatIn(Axi2WriteAddrProt_DatIn),
.Axi2WriteDataValid_ValIn(Axi2WriteDataValid_ValIn),
.Axi2WriteDataReady_RdyOut(Axi2WriteDataReady_RdyOut),
.Axi2WriteDataData_DatIn(Axi2WriteDataData_DatIn),
.Axi2WriteDataStrobe_DatIn(Axi2WriteDataStrobe_DatIn),
.Axi2WriteRespValid_ValOut(Axi2WriteRespValid_ValOut),
.Axi2WriteRespReady_RdyIn(Axi2WriteRespReady_RdyIn),
.Axi2WriteRespResponse_DatOut(Axi2WriteRespResponse_DatOut),
.Axi2ReadAddrValid_ValIn(Axi2ReadAddrValid_ValIn),
.Axi2ReadAddrReady_RdyOut(Axi2ReadAddrReady_RdyOut),
.Axi2ReadAddrAddress_AdrIn(Axi2ReadAddrAddress_AdrIn),
.Axi2ReadAddrProt_DatIn(Axi2ReadAddrProt_DatIn),
.Axi2ReadDataValid_ValOut(Axi2ReadDataValid_ValOut),
.Axi2ReadDataReady_RdyIn(Axi2ReadDataReady_RdyIn),
.Axi2ReadDataResponse_DatOut(Axi2ReadDataResponse_DatOut),
.Axi2ReadDataData_DatOut(Axi2ReadDataData_DatOut)
);
endmodule
