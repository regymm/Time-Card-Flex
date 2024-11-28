module xbar_ptp_1_23 #(
        // parameter NM = 1,
        // parameter NS = 24
    )(
    (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME s_axi_clk, ASSOCIATED_BUSIF s_axi_0:m_axi_0:m_axi_1:m_axi_2:m_axi_3:m_axi_4:m_axi_5:m_axi_6:m_axi_7:m_axi_8:m_axi_9:m_axi_10:m_axi_11:m_axi_12:m_axi_13:m_axi_14:m_axi_15:m_axi_16:m_axi_17:m_axi_18:m_axi_19:m_axi_20:m_axi_21:m_axi_22:m_axi_23, ASSOCIATED_RESET s_axi_aresetn" *)
    (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 s_axi_clk CLK" *)
    input wire S_AXI_ACLK,
    (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 s_axi_aresetn RST" *)
    input wire S_AXI_ARESETN,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_0 AWVALID" *)
    output wire M_AXI_0_AWVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_0 AWREADY" *)
    input wire M_AXI_0_AWREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_0 AWADDR" *)
    output wire [32-1:0] M_AXI_0_AWADDR,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_0 AWPROT" *)
    output wire [2:0] M_AXI_0_AWPROT,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_0 WVALID" *)
    output wire M_AXI_0_WVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_0 WREADY" *)
    input wire M_AXI_0_WREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_0 WDATA" *)
    output wire [32-1:0] M_AXI_0_WDATA,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_0 WSTRB" *)
    output wire [4-1:0] M_AXI_0_WSTRB,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_0 BVALID" *)
    input wire M_AXI_0_BVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_0 BREADY" *)
    output wire M_AXI_0_BREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_0 BRESP" *)
    input wire [1:0] M_AXI_0_BRESP,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_0 ARVALID" *)
    output wire M_AXI_0_ARVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_0 ARREADY" *)
    input wire M_AXI_0_ARREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_0 ARADDR" *)
    output wire [32-1:0] M_AXI_0_ARADDR,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_0 ARPROT" *)
    output wire [2:0] M_AXI_0_ARPROT,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_0 RVALID" *)
    input wire M_AXI_0_RVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_0 RREADY" *)
    output wire M_AXI_0_RREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_0 RRESP" *)
    input wire [1:0] M_AXI_0_RRESP,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_0 RDATA" *)
    input wire [32-1:0] M_AXI_0_RDATA,
    
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_1 AWVALID" *)
    output wire M_AXI_1_AWVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_1 AWREADY" *)
    input wire M_AXI_1_AWREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_1 AWADDR" *)
    output wire [32-1:0] M_AXI_1_AWADDR,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_1 AWPROT" *)
    output wire [2:0] M_AXI_1_AWPROT,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_1 WVALID" *)
    output wire M_AXI_1_WVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_1 WREADY" *)
    input wire M_AXI_1_WREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_1 WDATA" *)
    output wire [32-1:0] M_AXI_1_WDATA,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_1 WSTRB" *)
    output wire [4-1:0] M_AXI_1_WSTRB,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_1 BVALID" *)
    input wire M_AXI_1_BVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_1 BREADY" *)
    output wire M_AXI_1_BREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_1 BRESP" *)
    input wire [1:0] M_AXI_1_BRESP,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_1 ARVALID" *)
    output wire M_AXI_1_ARVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_1 ARREADY" *)
    input wire M_AXI_1_ARREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_1 ARADDR" *)
    output wire [32-1:0] M_AXI_1_ARADDR,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_1 ARPROT" *)
    output wire [2:0] M_AXI_1_ARPROT,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_1 RVALID" *)
    input wire M_AXI_1_RVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_1 RREADY" *)
    output wire M_AXI_1_RREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_1 RRESP" *)
    input wire [1:0] M_AXI_1_RRESP,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_1 RDATA" *)
    input wire [32-1:0] M_AXI_1_RDATA,
    
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_2 AWVALID" *)
    output wire M_AXI_2_AWVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_2 AWREADY" *)
    input wire M_AXI_2_AWREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_2 AWADDR" *)
    output wire [32-1:0] M_AXI_2_AWADDR,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_2 AWPROT" *)
    output wire [2:0] M_AXI_2_AWPROT,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_2 WVALID" *)
    output wire M_AXI_2_WVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_2 WREADY" *)
    input wire M_AXI_2_WREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_2 WDATA" *)
    output wire [32-1:0] M_AXI_2_WDATA,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_2 WSTRB" *)
    output wire [4-1:0] M_AXI_2_WSTRB,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_2 BVALID" *)
    input wire M_AXI_2_BVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_2 BREADY" *)
    output wire M_AXI_2_BREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_2 BRESP" *)
    input wire [1:0] M_AXI_2_BRESP,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_2 ARVALID" *)
    output wire M_AXI_2_ARVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_2 ARREADY" *)
    input wire M_AXI_2_ARREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_2 ARADDR" *)
    output wire [32-1:0] M_AXI_2_ARADDR,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_2 ARPROT" *)
    output wire [2:0] M_AXI_2_ARPROT,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_2 RVALID" *)
    input wire M_AXI_2_RVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_2 RREADY" *)
    output wire M_AXI_2_RREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_2 RRESP" *)
    input wire [1:0] M_AXI_2_RRESP,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_2 RDATA" *)
    input wire [32-1:0] M_AXI_2_RDATA,
    
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_3 AWVALID" *)
    output wire M_AXI_3_AWVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_3 AWREADY" *)
    input wire M_AXI_3_AWREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_3 AWADDR" *)
    output wire [32-1:0] M_AXI_3_AWADDR,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_3 AWPROT" *)
    output wire [2:0] M_AXI_3_AWPROT,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_3 WVALID" *)
    output wire M_AXI_3_WVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_3 WREADY" *)
    input wire M_AXI_3_WREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_3 WDATA" *)
    output wire [32-1:0] M_AXI_3_WDATA,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_3 WSTRB" *)
    output wire [4-1:0] M_AXI_3_WSTRB,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_3 BVALID" *)
    input wire M_AXI_3_BVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_3 BREADY" *)
    output wire M_AXI_3_BREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_3 BRESP" *)
    input wire [1:0] M_AXI_3_BRESP,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_3 ARVALID" *)
    output wire M_AXI_3_ARVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_3 ARREADY" *)
    input wire M_AXI_3_ARREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_3 ARADDR" *)
    output wire [32-1:0] M_AXI_3_ARADDR,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_3 ARPROT" *)
    output wire [2:0] M_AXI_3_ARPROT,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_3 RVALID" *)
    input wire M_AXI_3_RVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_3 RREADY" *)
    output wire M_AXI_3_RREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_3 RRESP" *)
    input wire [1:0] M_AXI_3_RRESP,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_3 RDATA" *)
    input wire [32-1:0] M_AXI_3_RDATA,
    
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_4 AWVALID" *)
    output wire M_AXI_4_AWVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_4 AWREADY" *)
    input wire M_AXI_4_AWREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_4 AWADDR" *)
    output wire [32-1:0] M_AXI_4_AWADDR,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_4 AWPROT" *)
    output wire [2:0] M_AXI_4_AWPROT,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_4 WVALID" *)
    output wire M_AXI_4_WVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_4 WREADY" *)
    input wire M_AXI_4_WREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_4 WDATA" *)
    output wire [32-1:0] M_AXI_4_WDATA,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_4 WSTRB" *)
    output wire [4-1:0] M_AXI_4_WSTRB,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_4 BVALID" *)
    input wire M_AXI_4_BVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_4 BREADY" *)
    output wire M_AXI_4_BREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_4 BRESP" *)
    input wire [1:0] M_AXI_4_BRESP,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_4 ARVALID" *)
    output wire M_AXI_4_ARVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_4 ARREADY" *)
    input wire M_AXI_4_ARREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_4 ARADDR" *)
    output wire [32-1:0] M_AXI_4_ARADDR,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_4 ARPROT" *)
    output wire [2:0] M_AXI_4_ARPROT,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_4 RVALID" *)
    input wire M_AXI_4_RVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_4 RREADY" *)
    output wire M_AXI_4_RREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_4 RRESP" *)
    input wire [1:0] M_AXI_4_RRESP,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_4 RDATA" *)
    input wire [32-1:0] M_AXI_4_RDATA,
    
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_5 AWVALID" *)
    output wire M_AXI_5_AWVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_5 AWREADY" *)
    input wire M_AXI_5_AWREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_5 AWADDR" *)
    output wire [32-1:0] M_AXI_5_AWADDR,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_5 AWPROT" *)
    output wire [2:0] M_AXI_5_AWPROT,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_5 WVALID" *)
    output wire M_AXI_5_WVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_5 WREADY" *)
    input wire M_AXI_5_WREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_5 WDATA" *)
    output wire [32-1:0] M_AXI_5_WDATA,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_5 WSTRB" *)
    output wire [4-1:0] M_AXI_5_WSTRB,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_5 BVALID" *)
    input wire M_AXI_5_BVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_5 BREADY" *)
    output wire M_AXI_5_BREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_5 BRESP" *)
    input wire [1:0] M_AXI_5_BRESP,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_5 ARVALID" *)
    output wire M_AXI_5_ARVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_5 ARREADY" *)
    input wire M_AXI_5_ARREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_5 ARADDR" *)
    output wire [32-1:0] M_AXI_5_ARADDR,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_5 ARPROT" *)
    output wire [2:0] M_AXI_5_ARPROT,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_5 RVALID" *)
    input wire M_AXI_5_RVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_5 RREADY" *)
    output wire M_AXI_5_RREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_5 RRESP" *)
    input wire [1:0] M_AXI_5_RRESP,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_5 RDATA" *)
    input wire [32-1:0] M_AXI_5_RDATA,
    
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_6 AWVALID" *)
    output wire M_AXI_6_AWVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_6 AWREADY" *)
    input wire M_AXI_6_AWREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_6 AWADDR" *)
    output wire [32-1:0] M_AXI_6_AWADDR,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_6 AWPROT" *)
    output wire [2:0] M_AXI_6_AWPROT,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_6 WVALID" *)
    output wire M_AXI_6_WVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_6 WREADY" *)
    input wire M_AXI_6_WREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_6 WDATA" *)
    output wire [32-1:0] M_AXI_6_WDATA,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_6 WSTRB" *)
    output wire [4-1:0] M_AXI_6_WSTRB,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_6 BVALID" *)
    input wire M_AXI_6_BVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_6 BREADY" *)
    output wire M_AXI_6_BREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_6 BRESP" *)
    input wire [1:0] M_AXI_6_BRESP,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_6 ARVALID" *)
    output wire M_AXI_6_ARVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_6 ARREADY" *)
    input wire M_AXI_6_ARREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_6 ARADDR" *)
    output wire [32-1:0] M_AXI_6_ARADDR,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_6 ARPROT" *)
    output wire [2:0] M_AXI_6_ARPROT,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_6 RVALID" *)
    input wire M_AXI_6_RVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_6 RREADY" *)
    output wire M_AXI_6_RREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_6 RRESP" *)
    input wire [1:0] M_AXI_6_RRESP,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_6 RDATA" *)
    input wire [32-1:0] M_AXI_6_RDATA,
    
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_7 AWVALID" *)
    output wire M_AXI_7_AWVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_7 AWREADY" *)
    input wire M_AXI_7_AWREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_7 AWADDR" *)
    output wire [32-1:0] M_AXI_7_AWADDR,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_7 AWPROT" *)
    output wire [2:0] M_AXI_7_AWPROT,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_7 WVALID" *)
    output wire M_AXI_7_WVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_7 WREADY" *)
    input wire M_AXI_7_WREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_7 WDATA" *)
    output wire [32-1:0] M_AXI_7_WDATA,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_7 WSTRB" *)
    output wire [4-1:0] M_AXI_7_WSTRB,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_7 BVALID" *)
    input wire M_AXI_7_BVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_7 BREADY" *)
    output wire M_AXI_7_BREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_7 BRESP" *)
    input wire [1:0] M_AXI_7_BRESP,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_7 ARVALID" *)
    output wire M_AXI_7_ARVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_7 ARREADY" *)
    input wire M_AXI_7_ARREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_7 ARADDR" *)
    output wire [32-1:0] M_AXI_7_ARADDR,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_7 ARPROT" *)
    output wire [2:0] M_AXI_7_ARPROT,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_7 RVALID" *)
    input wire M_AXI_7_RVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_7 RREADY" *)
    output wire M_AXI_7_RREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_7 RRESP" *)
    input wire [1:0] M_AXI_7_RRESP,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_7 RDATA" *)
    input wire [32-1:0] M_AXI_7_RDATA,
    
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_8 AWVALID" *)
    output wire M_AXI_8_AWVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_8 AWREADY" *)
    input wire M_AXI_8_AWREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_8 AWADDR" *)
    output wire [32-1:0] M_AXI_8_AWADDR,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_8 AWPROT" *)
    output wire [2:0] M_AXI_8_AWPROT,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_8 WVALID" *)
    output wire M_AXI_8_WVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_8 WREADY" *)
    input wire M_AXI_8_WREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_8 WDATA" *)
    output wire [32-1:0] M_AXI_8_WDATA,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_8 WSTRB" *)
    output wire [4-1:0] M_AXI_8_WSTRB,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_8 BVALID" *)
    input wire M_AXI_8_BVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_8 BREADY" *)
    output wire M_AXI_8_BREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_8 BRESP" *)
    input wire [1:0] M_AXI_8_BRESP,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_8 ARVALID" *)
    output wire M_AXI_8_ARVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_8 ARREADY" *)
    input wire M_AXI_8_ARREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_8 ARADDR" *)
    output wire [32-1:0] M_AXI_8_ARADDR,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_8 ARPROT" *)
    output wire [2:0] M_AXI_8_ARPROT,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_8 RVALID" *)
    input wire M_AXI_8_RVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_8 RREADY" *)
    output wire M_AXI_8_RREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_8 RRESP" *)
    input wire [1:0] M_AXI_8_RRESP,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_8 RDATA" *)
    input wire [32-1:0] M_AXI_8_RDATA,
    
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_9 AWVALID" *)
    output wire M_AXI_9_AWVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_9 AWREADY" *)
    input wire M_AXI_9_AWREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_9 AWADDR" *)
    output wire [32-1:0] M_AXI_9_AWADDR,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_9 AWPROT" *)
    output wire [2:0] M_AXI_9_AWPROT,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_9 WVALID" *)
    output wire M_AXI_9_WVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_9 WREADY" *)
    input wire M_AXI_9_WREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_9 WDATA" *)
    output wire [32-1:0] M_AXI_9_WDATA,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_9 WSTRB" *)
    output wire [4-1:0] M_AXI_9_WSTRB,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_9 BVALID" *)
    input wire M_AXI_9_BVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_9 BREADY" *)
    output wire M_AXI_9_BREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_9 BRESP" *)
    input wire [1:0] M_AXI_9_BRESP,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_9 ARVALID" *)
    output wire M_AXI_9_ARVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_9 ARREADY" *)
    input wire M_AXI_9_ARREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_9 ARADDR" *)
    output wire [32-1:0] M_AXI_9_ARADDR,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_9 ARPROT" *)
    output wire [2:0] M_AXI_9_ARPROT,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_9 RVALID" *)
    input wire M_AXI_9_RVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_9 RREADY" *)
    output wire M_AXI_9_RREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_9 RRESP" *)
    input wire [1:0] M_AXI_9_RRESP,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_9 RDATA" *)
    input wire [32-1:0] M_AXI_9_RDATA,
    
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_10 AWVALID" *)
    output wire M_AXI_10_AWVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_10 AWREADY" *)
    input wire M_AXI_10_AWREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_10 AWADDR" *)
    output wire [32-1:0] M_AXI_10_AWADDR,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_10 AWPROT" *)
    output wire [2:0] M_AXI_10_AWPROT,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_10 WVALID" *)
    output wire M_AXI_10_WVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_10 WREADY" *)
    input wire M_AXI_10_WREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_10 WDATA" *)
    output wire [32-1:0] M_AXI_10_WDATA,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_10 WSTRB" *)
    output wire [4-1:0] M_AXI_10_WSTRB,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_10 BVALID" *)
    input wire M_AXI_10_BVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_10 BREADY" *)
    output wire M_AXI_10_BREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_10 BRESP" *)
    input wire [1:0] M_AXI_10_BRESP,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_10 ARVALID" *)
    output wire M_AXI_10_ARVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_10 ARREADY" *)
    input wire M_AXI_10_ARREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_10 ARADDR" *)
    output wire [32-1:0] M_AXI_10_ARADDR,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_10 ARPROT" *)
    output wire [2:0] M_AXI_10_ARPROT,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_10 RVALID" *)
    input wire M_AXI_10_RVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_10 RREADY" *)
    output wire M_AXI_10_RREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_10 RRESP" *)
    input wire [1:0] M_AXI_10_RRESP,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_10 RDATA" *)
    input wire [32-1:0] M_AXI_10_RDATA,
    
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_11 AWVALID" *)
    output wire M_AXI_11_AWVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_11 AWREADY" *)
    input wire M_AXI_11_AWREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_11 AWADDR" *)
    output wire [32-1:0] M_AXI_11_AWADDR,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_11 AWPROT" *)
    output wire [2:0] M_AXI_11_AWPROT,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_11 WVALID" *)
    output wire M_AXI_11_WVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_11 WREADY" *)
    input wire M_AXI_11_WREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_11 WDATA" *)
    output wire [32-1:0] M_AXI_11_WDATA,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_11 WSTRB" *)
    output wire [4-1:0] M_AXI_11_WSTRB,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_11 BVALID" *)
    input wire M_AXI_11_BVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_11 BREADY" *)
    output wire M_AXI_11_BREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_11 BRESP" *)
    input wire [1:0] M_AXI_11_BRESP,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_11 ARVALID" *)
    output wire M_AXI_11_ARVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_11 ARREADY" *)
    input wire M_AXI_11_ARREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_11 ARADDR" *)
    output wire [32-1:0] M_AXI_11_ARADDR,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_11 ARPROT" *)
    output wire [2:0] M_AXI_11_ARPROT,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_11 RVALID" *)
    input wire M_AXI_11_RVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_11 RREADY" *)
    output wire M_AXI_11_RREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_11 RRESP" *)
    input wire [1:0] M_AXI_11_RRESP,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_11 RDATA" *)
    input wire [32-1:0] M_AXI_11_RDATA,
    
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_12 AWVALID" *)
    output wire M_AXI_12_AWVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_12 AWREADY" *)
    input wire M_AXI_12_AWREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_12 AWADDR" *)
    output wire [32-1:0] M_AXI_12_AWADDR,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_12 AWPROT" *)
    output wire [2:0] M_AXI_12_AWPROT,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_12 WVALID" *)
    output wire M_AXI_12_WVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_12 WREADY" *)
    input wire M_AXI_12_WREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_12 WDATA" *)
    output wire [32-1:0] M_AXI_12_WDATA,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_12 WSTRB" *)
    output wire [4-1:0] M_AXI_12_WSTRB,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_12 BVALID" *)
    input wire M_AXI_12_BVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_12 BREADY" *)
    output wire M_AXI_12_BREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_12 BRESP" *)
    input wire [1:0] M_AXI_12_BRESP,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_12 ARVALID" *)
    output wire M_AXI_12_ARVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_12 ARREADY" *)
    input wire M_AXI_12_ARREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_12 ARADDR" *)
    output wire [32-1:0] M_AXI_12_ARADDR,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_12 ARPROT" *)
    output wire [2:0] M_AXI_12_ARPROT,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_12 RVALID" *)
    input wire M_AXI_12_RVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_12 RREADY" *)
    output wire M_AXI_12_RREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_12 RRESP" *)
    input wire [1:0] M_AXI_12_RRESP,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_12 RDATA" *)
    input wire [32-1:0] M_AXI_12_RDATA,
    
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_13 AWVALID" *)
    output wire M_AXI_13_AWVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_13 AWREADY" *)
    input wire M_AXI_13_AWREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_13 AWADDR" *)
    output wire [32-1:0] M_AXI_13_AWADDR,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_13 AWPROT" *)
    output wire [2:0] M_AXI_13_AWPROT,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_13 WVALID" *)
    output wire M_AXI_13_WVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_13 WREADY" *)
    input wire M_AXI_13_WREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_13 WDATA" *)
    output wire [32-1:0] M_AXI_13_WDATA,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_13 WSTRB" *)
    output wire [4-1:0] M_AXI_13_WSTRB,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_13 BVALID" *)
    input wire M_AXI_13_BVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_13 BREADY" *)
    output wire M_AXI_13_BREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_13 BRESP" *)
    input wire [1:0] M_AXI_13_BRESP,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_13 ARVALID" *)
    output wire M_AXI_13_ARVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_13 ARREADY" *)
    input wire M_AXI_13_ARREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_13 ARADDR" *)
    output wire [32-1:0] M_AXI_13_ARADDR,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_13 ARPROT" *)
    output wire [2:0] M_AXI_13_ARPROT,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_13 RVALID" *)
    input wire M_AXI_13_RVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_13 RREADY" *)
    output wire M_AXI_13_RREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_13 RRESP" *)
    input wire [1:0] M_AXI_13_RRESP,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_13 RDATA" *)
    input wire [32-1:0] M_AXI_13_RDATA,
    
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_14 AWVALID" *)
    output wire M_AXI_14_AWVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_14 AWREADY" *)
    input wire M_AXI_14_AWREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_14 AWADDR" *)
    output wire [32-1:0] M_AXI_14_AWADDR,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_14 AWPROT" *)
    output wire [2:0] M_AXI_14_AWPROT,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_14 WVALID" *)
    output wire M_AXI_14_WVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_14 WREADY" *)
    input wire M_AXI_14_WREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_14 WDATA" *)
    output wire [32-1:0] M_AXI_14_WDATA,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_14 WSTRB" *)
    output wire [4-1:0] M_AXI_14_WSTRB,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_14 BVALID" *)
    input wire M_AXI_14_BVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_14 BREADY" *)
    output wire M_AXI_14_BREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_14 BRESP" *)
    input wire [1:0] M_AXI_14_BRESP,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_14 ARVALID" *)
    output wire M_AXI_14_ARVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_14 ARREADY" *)
    input wire M_AXI_14_ARREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_14 ARADDR" *)
    output wire [32-1:0] M_AXI_14_ARADDR,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_14 ARPROT" *)
    output wire [2:0] M_AXI_14_ARPROT,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_14 RVALID" *)
    input wire M_AXI_14_RVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_14 RREADY" *)
    output wire M_AXI_14_RREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_14 RRESP" *)
    input wire [1:0] M_AXI_14_RRESP,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_14 RDATA" *)
    input wire [32-1:0] M_AXI_14_RDATA,
    
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_15 AWVALID" *)
    output wire M_AXI_15_AWVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_15 AWREADY" *)
    input wire M_AXI_15_AWREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_15 AWADDR" *)
    output wire [32-1:0] M_AXI_15_AWADDR,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_15 AWPROT" *)
    output wire [2:0] M_AXI_15_AWPROT,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_15 WVALID" *)
    output wire M_AXI_15_WVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_15 WREADY" *)
    input wire M_AXI_15_WREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_15 WDATA" *)
    output wire [32-1:0] M_AXI_15_WDATA,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_15 WSTRB" *)
    output wire [4-1:0] M_AXI_15_WSTRB,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_15 BVALID" *)
    input wire M_AXI_15_BVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_15 BREADY" *)
    output wire M_AXI_15_BREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_15 BRESP" *)
    input wire [1:0] M_AXI_15_BRESP,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_15 ARVALID" *)
    output wire M_AXI_15_ARVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_15 ARREADY" *)
    input wire M_AXI_15_ARREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_15 ARADDR" *)
    output wire [32-1:0] M_AXI_15_ARADDR,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_15 ARPROT" *)
    output wire [2:0] M_AXI_15_ARPROT,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_15 RVALID" *)
    input wire M_AXI_15_RVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_15 RREADY" *)
    output wire M_AXI_15_RREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_15 RRESP" *)
    input wire [1:0] M_AXI_15_RRESP,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_15 RDATA" *)
    input wire [32-1:0] M_AXI_15_RDATA,
    
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_16 AWVALID" *)
    output wire M_AXI_16_AWVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_16 AWREADY" *)
    input wire M_AXI_16_AWREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_16 AWADDR" *)
    output wire [32-1:0] M_AXI_16_AWADDR,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_16 AWPROT" *)
    output wire [2:0] M_AXI_16_AWPROT,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_16 WVALID" *)
    output wire M_AXI_16_WVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_16 WREADY" *)
    input wire M_AXI_16_WREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_16 WDATA" *)
    output wire [32-1:0] M_AXI_16_WDATA,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_16 WSTRB" *)
    output wire [4-1:0] M_AXI_16_WSTRB,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_16 BVALID" *)
    input wire M_AXI_16_BVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_16 BREADY" *)
    output wire M_AXI_16_BREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_16 BRESP" *)
    input wire [1:0] M_AXI_16_BRESP,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_16 ARVALID" *)
    output wire M_AXI_16_ARVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_16 ARREADY" *)
    input wire M_AXI_16_ARREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_16 ARADDR" *)
    output wire [32-1:0] M_AXI_16_ARADDR,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_16 ARPROT" *)
    output wire [2:0] M_AXI_16_ARPROT,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_16 RVALID" *)
    input wire M_AXI_16_RVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_16 RREADY" *)
    output wire M_AXI_16_RREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_16 RRESP" *)
    input wire [1:0] M_AXI_16_RRESP,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_16 RDATA" *)
    input wire [32-1:0] M_AXI_16_RDATA,
    
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_17 AWVALID" *)
    output wire M_AXI_17_AWVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_17 AWREADY" *)
    input wire M_AXI_17_AWREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_17 AWADDR" *)
    output wire [32-1:0] M_AXI_17_AWADDR,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_17 AWPROT" *)
    output wire [2:0] M_AXI_17_AWPROT,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_17 WVALID" *)
    output wire M_AXI_17_WVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_17 WREADY" *)
    input wire M_AXI_17_WREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_17 WDATA" *)
    output wire [32-1:0] M_AXI_17_WDATA,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_17 WSTRB" *)
    output wire [4-1:0] M_AXI_17_WSTRB,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_17 BVALID" *)
    input wire M_AXI_17_BVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_17 BREADY" *)
    output wire M_AXI_17_BREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_17 BRESP" *)
    input wire [1:0] M_AXI_17_BRESP,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_17 ARVALID" *)
    output wire M_AXI_17_ARVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_17 ARREADY" *)
    input wire M_AXI_17_ARREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_17 ARADDR" *)
    output wire [32-1:0] M_AXI_17_ARADDR,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_17 ARPROT" *)
    output wire [2:0] M_AXI_17_ARPROT,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_17 RVALID" *)
    input wire M_AXI_17_RVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_17 RREADY" *)
    output wire M_AXI_17_RREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_17 RRESP" *)
    input wire [1:0] M_AXI_17_RRESP,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_17 RDATA" *)
    input wire [32-1:0] M_AXI_17_RDATA,
    
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_18 AWVALID" *)
    output wire M_AXI_18_AWVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_18 AWREADY" *)
    input wire M_AXI_18_AWREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_18 AWADDR" *)
    output wire [32-1:0] M_AXI_18_AWADDR,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_18 AWPROT" *)
    output wire [2:0] M_AXI_18_AWPROT,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_18 WVALID" *)
    output wire M_AXI_18_WVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_18 WREADY" *)
    input wire M_AXI_18_WREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_18 WDATA" *)
    output wire [32-1:0] M_AXI_18_WDATA,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_18 WSTRB" *)
    output wire [4-1:0] M_AXI_18_WSTRB,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_18 BVALID" *)
    input wire M_AXI_18_BVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_18 BREADY" *)
    output wire M_AXI_18_BREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_18 BRESP" *)
    input wire [1:0] M_AXI_18_BRESP,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_18 ARVALID" *)
    output wire M_AXI_18_ARVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_18 ARREADY" *)
    input wire M_AXI_18_ARREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_18 ARADDR" *)
    output wire [32-1:0] M_AXI_18_ARADDR,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_18 ARPROT" *)
    output wire [2:0] M_AXI_18_ARPROT,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_18 RVALID" *)
    input wire M_AXI_18_RVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_18 RREADY" *)
    output wire M_AXI_18_RREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_18 RRESP" *)
    input wire [1:0] M_AXI_18_RRESP,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_18 RDATA" *)
    input wire [32-1:0] M_AXI_18_RDATA,
    
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_19 AWVALID" *)
    output wire M_AXI_19_AWVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_19 AWREADY" *)
    input wire M_AXI_19_AWREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_19 AWADDR" *)
    output wire [32-1:0] M_AXI_19_AWADDR,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_19 AWPROT" *)
    output wire [2:0] M_AXI_19_AWPROT,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_19 WVALID" *)
    output wire M_AXI_19_WVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_19 WREADY" *)
    input wire M_AXI_19_WREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_19 WDATA" *)
    output wire [32-1:0] M_AXI_19_WDATA,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_19 WSTRB" *)
    output wire [4-1:0] M_AXI_19_WSTRB,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_19 BVALID" *)
    input wire M_AXI_19_BVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_19 BREADY" *)
    output wire M_AXI_19_BREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_19 BRESP" *)
    input wire [1:0] M_AXI_19_BRESP,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_19 ARVALID" *)
    output wire M_AXI_19_ARVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_19 ARREADY" *)
    input wire M_AXI_19_ARREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_19 ARADDR" *)
    output wire [32-1:0] M_AXI_19_ARADDR,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_19 ARPROT" *)
    output wire [2:0] M_AXI_19_ARPROT,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_19 RVALID" *)
    input wire M_AXI_19_RVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_19 RREADY" *)
    output wire M_AXI_19_RREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_19 RRESP" *)
    input wire [1:0] M_AXI_19_RRESP,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_19 RDATA" *)
    input wire [32-1:0] M_AXI_19_RDATA,
    
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_20 AWVALID" *)
    output wire M_AXI_20_AWVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_20 AWREADY" *)
    input wire M_AXI_20_AWREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_20 AWADDR" *)
    output wire [32-1:0] M_AXI_20_AWADDR,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_20 AWPROT" *)
    output wire [2:0] M_AXI_20_AWPROT,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_20 WVALID" *)
    output wire M_AXI_20_WVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_20 WREADY" *)
    input wire M_AXI_20_WREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_20 WDATA" *)
    output wire [32-1:0] M_AXI_20_WDATA,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_20 WSTRB" *)
    output wire [4-1:0] M_AXI_20_WSTRB,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_20 BVALID" *)
    input wire M_AXI_20_BVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_20 BREADY" *)
    output wire M_AXI_20_BREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_20 BRESP" *)
    input wire [1:0] M_AXI_20_BRESP,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_20 ARVALID" *)
    output wire M_AXI_20_ARVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_20 ARREADY" *)
    input wire M_AXI_20_ARREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_20 ARADDR" *)
    output wire [32-1:0] M_AXI_20_ARADDR,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_20 ARPROT" *)
    output wire [2:0] M_AXI_20_ARPROT,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_20 RVALID" *)
    input wire M_AXI_20_RVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_20 RREADY" *)
    output wire M_AXI_20_RREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_20 RRESP" *)
    input wire [1:0] M_AXI_20_RRESP,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_20 RDATA" *)
    input wire [32-1:0] M_AXI_20_RDATA,
    
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_21 AWVALID" *)
    output wire M_AXI_21_AWVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_21 AWREADY" *)
    input wire M_AXI_21_AWREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_21 AWADDR" *)
    output wire [32-1:0] M_AXI_21_AWADDR,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_21 AWPROT" *)
    output wire [2:0] M_AXI_21_AWPROT,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_21 WVALID" *)
    output wire M_AXI_21_WVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_21 WREADY" *)
    input wire M_AXI_21_WREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_21 WDATA" *)
    output wire [32-1:0] M_AXI_21_WDATA,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_21 WSTRB" *)
    output wire [4-1:0] M_AXI_21_WSTRB,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_21 BVALID" *)
    input wire M_AXI_21_BVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_21 BREADY" *)
    output wire M_AXI_21_BREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_21 BRESP" *)
    input wire [1:0] M_AXI_21_BRESP,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_21 ARVALID" *)
    output wire M_AXI_21_ARVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_21 ARREADY" *)
    input wire M_AXI_21_ARREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_21 ARADDR" *)
    output wire [32-1:0] M_AXI_21_ARADDR,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_21 ARPROT" *)
    output wire [2:0] M_AXI_21_ARPROT,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_21 RVALID" *)
    input wire M_AXI_21_RVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_21 RREADY" *)
    output wire M_AXI_21_RREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_21 RRESP" *)
    input wire [1:0] M_AXI_21_RRESP,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_21 RDATA" *)
    input wire [32-1:0] M_AXI_21_RDATA,
    
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_22 AWVALID" *)
    output wire M_AXI_22_AWVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_22 AWREADY" *)
    input wire M_AXI_22_AWREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_22 AWADDR" *)
    output wire [32-1:0] M_AXI_22_AWADDR,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_22 AWPROT" *)
    output wire [2:0] M_AXI_22_AWPROT,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_22 WVALID" *)
    output wire M_AXI_22_WVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_22 WREADY" *)
    input wire M_AXI_22_WREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_22 WDATA" *)
    output wire [32-1:0] M_AXI_22_WDATA,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_22 WSTRB" *)
    output wire [4-1:0] M_AXI_22_WSTRB,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_22 BVALID" *)
    input wire M_AXI_22_BVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_22 BREADY" *)
    output wire M_AXI_22_BREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_22 BRESP" *)
    input wire [1:0] M_AXI_22_BRESP,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_22 ARVALID" *)
    output wire M_AXI_22_ARVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_22 ARREADY" *)
    input wire M_AXI_22_ARREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_22 ARADDR" *)
    output wire [32-1:0] M_AXI_22_ARADDR,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_22 ARPROT" *)
    output wire [2:0] M_AXI_22_ARPROT,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_22 RVALID" *)
    input wire M_AXI_22_RVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_22 RREADY" *)
    output wire M_AXI_22_RREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_22 RRESP" *)
    input wire [1:0] M_AXI_22_RRESP,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_22 RDATA" *)
    input wire [32-1:0] M_AXI_22_RDATA,
    
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_23 AWVALID" *)
    output wire M_AXI_23_AWVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_23 AWREADY" *)
    input wire M_AXI_23_AWREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_23 AWADDR" *)
    output wire [32-1:0] M_AXI_23_AWADDR,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_23 AWPROT" *)
    output wire [2:0] M_AXI_23_AWPROT,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_23 WVALID" *)
    output wire M_AXI_23_WVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_23 WREADY" *)
    input wire M_AXI_23_WREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_23 WDATA" *)
    output wire [32-1:0] M_AXI_23_WDATA,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_23 WSTRB" *)
    output wire [4-1:0] M_AXI_23_WSTRB,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_23 BVALID" *)
    input wire M_AXI_23_BVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_23 BREADY" *)
    output wire M_AXI_23_BREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_23 BRESP" *)
    input wire [1:0] M_AXI_23_BRESP,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_23 ARVALID" *)
    output wire M_AXI_23_ARVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_23 ARREADY" *)
    input wire M_AXI_23_ARREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_23 ARADDR" *)
    output wire [32-1:0] M_AXI_23_ARADDR,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_23 ARPROT" *)
    output wire [2:0] M_AXI_23_ARPROT,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_23 RVALID" *)
    input wire M_AXI_23_RVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_23 RREADY" *)
    output wire M_AXI_23_RREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_23 RRESP" *)
    input wire [1:0] M_AXI_23_RRESP,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_23 RDATA" *)
    input wire [32-1:0] M_AXI_23_RDATA,
    
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi_0 AWVALID" *)
    input wire S_AXI_0_AWVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi_0 AWREADY" *)
    output wire S_AXI_0_AWREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi_0 AWADDR" *)
    input wire [32-1:0] S_AXI_0_AWADDR,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi_0 AWPROT" *)
    input wire [2:0] S_AXI_0_AWPROT,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi_0 WVALID" *)
    input wire S_AXI_0_WVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi_0 WREADY" *)
    output wire S_AXI_0_WREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi_0 WDATA" *)
    input wire [32-1:0] S_AXI_0_WDATA,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi_0 WSTRB" *)
    input wire [4-1:0] S_AXI_0_WSTRB,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi_0 BVALID" *)
    output wire S_AXI_0_BVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi_0 BREADY" *)
    input wire S_AXI_0_BREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi_0 BRESP" *)
    output wire [1:0] S_AXI_0_BRESP,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi_0 ARVALID" *)
    input wire S_AXI_0_ARVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi_0 ARREADY" *)
    output wire S_AXI_0_ARREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi_0 ARADDR" *)
    input wire [32-1:0] S_AXI_0_ARADDR,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi_0 ARPROT" *)
    input wire [2:0] S_AXI_0_ARPROT,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi_0 RVALID" *)
    output wire S_AXI_0_RVALID,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi_0 RREADY" *)
    input wire S_AXI_0_RREADY,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi_0 RRESP" *)
    output wire [1:0] S_AXI_0_RRESP,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi_0 RDATA" *)
    output wire [32-1:0] S_AXI_0_RDATA
    );
    axilxbar #(
    .C_AXI_DATA_WIDTH(32),
    .C_AXI_ADDR_WIDTH(32),
    .NM(1),
    .NS(24),
    .SLAVE_ADDR(
{32'h0130_0000,
32'h0123_0000,
32'h0122_0000,
32'h0121_0000,
32'h0120_0000,
32'h0112_0000,
32'h0111_0000,
32'h0110_0000,
32'h010F_0000,
32'h010E_0000,
32'h010D_0000,
32'h010C_0000,
32'h010B_0000,
32'h010A_0000,
32'h0109_0000,
32'h0108_0000,
32'h0107_0000,
32'h0106_0000,
32'h0105_0000,
32'h0104_0000,
32'h0103_0000,
32'h0102_0000,
32'h0101_0000,
32'h0100_0000} ),
    .SLAVE_MASK({24{ 32'h00FF0000 }})
    ) axilxbar_inst (
    .S_AXI_AWVALID({S_AXI_0_AWVALID}),
.S_AXI_AWREADY({S_AXI_0_AWREADY}),
.S_AXI_AWADDR({S_AXI_0_AWADDR}),
.S_AXI_AWPROT({S_AXI_0_AWPROT}),
.S_AXI_WVALID({S_AXI_0_WVALID}),
.S_AXI_WREADY({S_AXI_0_WREADY}),
.S_AXI_WDATA({S_AXI_0_WDATA}),
.S_AXI_WSTRB({S_AXI_0_WSTRB}),
.S_AXI_BVALID({S_AXI_0_BVALID}),
.S_AXI_BREADY({S_AXI_0_BREADY}),
.S_AXI_BRESP({S_AXI_0_BRESP}),
.S_AXI_ARVALID({S_AXI_0_ARVALID}),
.S_AXI_ARREADY({S_AXI_0_ARREADY}),
.S_AXI_ARADDR({S_AXI_0_ARADDR}),
.S_AXI_ARPROT({S_AXI_0_ARPROT}),
.S_AXI_RVALID({S_AXI_0_RVALID}),
.S_AXI_RREADY({S_AXI_0_RREADY}),
.S_AXI_RDATA({S_AXI_0_RDATA}),
.S_AXI_RRESP({S_AXI_0_RRESP}),
.M_AXI_AWVALID({M_AXI_23_AWVALID,M_AXI_22_AWVALID,M_AXI_21_AWVALID,M_AXI_20_AWVALID,M_AXI_19_AWVALID,M_AXI_18_AWVALID,M_AXI_17_AWVALID,M_AXI_16_AWVALID,M_AXI_15_AWVALID,M_AXI_14_AWVALID,M_AXI_13_AWVALID,M_AXI_12_AWVALID,M_AXI_11_AWVALID,M_AXI_10_AWVALID,M_AXI_9_AWVALID,M_AXI_8_AWVALID,M_AXI_7_AWVALID,M_AXI_6_AWVALID,M_AXI_5_AWVALID,M_AXI_4_AWVALID,M_AXI_3_AWVALID,M_AXI_2_AWVALID,M_AXI_1_AWVALID,M_AXI_0_AWVALID}),
.M_AXI_AWREADY({M_AXI_23_AWREADY,M_AXI_22_AWREADY,M_AXI_21_AWREADY,M_AXI_20_AWREADY,M_AXI_19_AWREADY,M_AXI_18_AWREADY,M_AXI_17_AWREADY,M_AXI_16_AWREADY,M_AXI_15_AWREADY,M_AXI_14_AWREADY,M_AXI_13_AWREADY,M_AXI_12_AWREADY,M_AXI_11_AWREADY,M_AXI_10_AWREADY,M_AXI_9_AWREADY,M_AXI_8_AWREADY,M_AXI_7_AWREADY,M_AXI_6_AWREADY,M_AXI_5_AWREADY,M_AXI_4_AWREADY,M_AXI_3_AWREADY,M_AXI_2_AWREADY,M_AXI_1_AWREADY,M_AXI_0_AWREADY}),
.M_AXI_AWADDR({M_AXI_23_AWADDR,M_AXI_22_AWADDR,M_AXI_21_AWADDR,M_AXI_20_AWADDR,M_AXI_19_AWADDR,M_AXI_18_AWADDR,M_AXI_17_AWADDR,M_AXI_16_AWADDR,M_AXI_15_AWADDR,M_AXI_14_AWADDR,M_AXI_13_AWADDR,M_AXI_12_AWADDR,M_AXI_11_AWADDR,M_AXI_10_AWADDR,M_AXI_9_AWADDR,M_AXI_8_AWADDR,M_AXI_7_AWADDR,M_AXI_6_AWADDR,M_AXI_5_AWADDR,M_AXI_4_AWADDR,M_AXI_3_AWADDR,M_AXI_2_AWADDR,M_AXI_1_AWADDR,M_AXI_0_AWADDR}),
.M_AXI_AWPROT({M_AXI_23_AWPROT,M_AXI_22_AWPROT,M_AXI_21_AWPROT,M_AXI_20_AWPROT,M_AXI_19_AWPROT,M_AXI_18_AWPROT,M_AXI_17_AWPROT,M_AXI_16_AWPROT,M_AXI_15_AWPROT,M_AXI_14_AWPROT,M_AXI_13_AWPROT,M_AXI_12_AWPROT,M_AXI_11_AWPROT,M_AXI_10_AWPROT,M_AXI_9_AWPROT,M_AXI_8_AWPROT,M_AXI_7_AWPROT,M_AXI_6_AWPROT,M_AXI_5_AWPROT,M_AXI_4_AWPROT,M_AXI_3_AWPROT,M_AXI_2_AWPROT,M_AXI_1_AWPROT,M_AXI_0_AWPROT}),
.M_AXI_WVALID({M_AXI_23_WVALID,M_AXI_22_WVALID,M_AXI_21_WVALID,M_AXI_20_WVALID,M_AXI_19_WVALID,M_AXI_18_WVALID,M_AXI_17_WVALID,M_AXI_16_WVALID,M_AXI_15_WVALID,M_AXI_14_WVALID,M_AXI_13_WVALID,M_AXI_12_WVALID,M_AXI_11_WVALID,M_AXI_10_WVALID,M_AXI_9_WVALID,M_AXI_8_WVALID,M_AXI_7_WVALID,M_AXI_6_WVALID,M_AXI_5_WVALID,M_AXI_4_WVALID,M_AXI_3_WVALID,M_AXI_2_WVALID,M_AXI_1_WVALID,M_AXI_0_WVALID}),
.M_AXI_WREADY({M_AXI_23_WREADY,M_AXI_22_WREADY,M_AXI_21_WREADY,M_AXI_20_WREADY,M_AXI_19_WREADY,M_AXI_18_WREADY,M_AXI_17_WREADY,M_AXI_16_WREADY,M_AXI_15_WREADY,M_AXI_14_WREADY,M_AXI_13_WREADY,M_AXI_12_WREADY,M_AXI_11_WREADY,M_AXI_10_WREADY,M_AXI_9_WREADY,M_AXI_8_WREADY,M_AXI_7_WREADY,M_AXI_6_WREADY,M_AXI_5_WREADY,M_AXI_4_WREADY,M_AXI_3_WREADY,M_AXI_2_WREADY,M_AXI_1_WREADY,M_AXI_0_WREADY}),
.M_AXI_WDATA({M_AXI_23_WDATA,M_AXI_22_WDATA,M_AXI_21_WDATA,M_AXI_20_WDATA,M_AXI_19_WDATA,M_AXI_18_WDATA,M_AXI_17_WDATA,M_AXI_16_WDATA,M_AXI_15_WDATA,M_AXI_14_WDATA,M_AXI_13_WDATA,M_AXI_12_WDATA,M_AXI_11_WDATA,M_AXI_10_WDATA,M_AXI_9_WDATA,M_AXI_8_WDATA,M_AXI_7_WDATA,M_AXI_6_WDATA,M_AXI_5_WDATA,M_AXI_4_WDATA,M_AXI_3_WDATA,M_AXI_2_WDATA,M_AXI_1_WDATA,M_AXI_0_WDATA}),
.M_AXI_WSTRB({M_AXI_23_WSTRB,M_AXI_22_WSTRB,M_AXI_21_WSTRB,M_AXI_20_WSTRB,M_AXI_19_WSTRB,M_AXI_18_WSTRB,M_AXI_17_WSTRB,M_AXI_16_WSTRB,M_AXI_15_WSTRB,M_AXI_14_WSTRB,M_AXI_13_WSTRB,M_AXI_12_WSTRB,M_AXI_11_WSTRB,M_AXI_10_WSTRB,M_AXI_9_WSTRB,M_AXI_8_WSTRB,M_AXI_7_WSTRB,M_AXI_6_WSTRB,M_AXI_5_WSTRB,M_AXI_4_WSTRB,M_AXI_3_WSTRB,M_AXI_2_WSTRB,M_AXI_1_WSTRB,M_AXI_0_WSTRB}),
.M_AXI_BVALID({M_AXI_23_BVALID,M_AXI_22_BVALID,M_AXI_21_BVALID,M_AXI_20_BVALID,M_AXI_19_BVALID,M_AXI_18_BVALID,M_AXI_17_BVALID,M_AXI_16_BVALID,M_AXI_15_BVALID,M_AXI_14_BVALID,M_AXI_13_BVALID,M_AXI_12_BVALID,M_AXI_11_BVALID,M_AXI_10_BVALID,M_AXI_9_BVALID,M_AXI_8_BVALID,M_AXI_7_BVALID,M_AXI_6_BVALID,M_AXI_5_BVALID,M_AXI_4_BVALID,M_AXI_3_BVALID,M_AXI_2_BVALID,M_AXI_1_BVALID,M_AXI_0_BVALID}),
.M_AXI_BREADY({M_AXI_23_BREADY,M_AXI_22_BREADY,M_AXI_21_BREADY,M_AXI_20_BREADY,M_AXI_19_BREADY,M_AXI_18_BREADY,M_AXI_17_BREADY,M_AXI_16_BREADY,M_AXI_15_BREADY,M_AXI_14_BREADY,M_AXI_13_BREADY,M_AXI_12_BREADY,M_AXI_11_BREADY,M_AXI_10_BREADY,M_AXI_9_BREADY,M_AXI_8_BREADY,M_AXI_7_BREADY,M_AXI_6_BREADY,M_AXI_5_BREADY,M_AXI_4_BREADY,M_AXI_3_BREADY,M_AXI_2_BREADY,M_AXI_1_BREADY,M_AXI_0_BREADY}),
.M_AXI_BRESP({M_AXI_23_BRESP,M_AXI_22_BRESP,M_AXI_21_BRESP,M_AXI_20_BRESP,M_AXI_19_BRESP,M_AXI_18_BRESP,M_AXI_17_BRESP,M_AXI_16_BRESP,M_AXI_15_BRESP,M_AXI_14_BRESP,M_AXI_13_BRESP,M_AXI_12_BRESP,M_AXI_11_BRESP,M_AXI_10_BRESP,M_AXI_9_BRESP,M_AXI_8_BRESP,M_AXI_7_BRESP,M_AXI_6_BRESP,M_AXI_5_BRESP,M_AXI_4_BRESP,M_AXI_3_BRESP,M_AXI_2_BRESP,M_AXI_1_BRESP,M_AXI_0_BRESP}),
.M_AXI_ARVALID({M_AXI_23_ARVALID,M_AXI_22_ARVALID,M_AXI_21_ARVALID,M_AXI_20_ARVALID,M_AXI_19_ARVALID,M_AXI_18_ARVALID,M_AXI_17_ARVALID,M_AXI_16_ARVALID,M_AXI_15_ARVALID,M_AXI_14_ARVALID,M_AXI_13_ARVALID,M_AXI_12_ARVALID,M_AXI_11_ARVALID,M_AXI_10_ARVALID,M_AXI_9_ARVALID,M_AXI_8_ARVALID,M_AXI_7_ARVALID,M_AXI_6_ARVALID,M_AXI_5_ARVALID,M_AXI_4_ARVALID,M_AXI_3_ARVALID,M_AXI_2_ARVALID,M_AXI_1_ARVALID,M_AXI_0_ARVALID}),
.M_AXI_ARREADY({M_AXI_23_ARREADY,M_AXI_22_ARREADY,M_AXI_21_ARREADY,M_AXI_20_ARREADY,M_AXI_19_ARREADY,M_AXI_18_ARREADY,M_AXI_17_ARREADY,M_AXI_16_ARREADY,M_AXI_15_ARREADY,M_AXI_14_ARREADY,M_AXI_13_ARREADY,M_AXI_12_ARREADY,M_AXI_11_ARREADY,M_AXI_10_ARREADY,M_AXI_9_ARREADY,M_AXI_8_ARREADY,M_AXI_7_ARREADY,M_AXI_6_ARREADY,M_AXI_5_ARREADY,M_AXI_4_ARREADY,M_AXI_3_ARREADY,M_AXI_2_ARREADY,M_AXI_1_ARREADY,M_AXI_0_ARREADY}),
.M_AXI_ARADDR({M_AXI_23_ARADDR,M_AXI_22_ARADDR,M_AXI_21_ARADDR,M_AXI_20_ARADDR,M_AXI_19_ARADDR,M_AXI_18_ARADDR,M_AXI_17_ARADDR,M_AXI_16_ARADDR,M_AXI_15_ARADDR,M_AXI_14_ARADDR,M_AXI_13_ARADDR,M_AXI_12_ARADDR,M_AXI_11_ARADDR,M_AXI_10_ARADDR,M_AXI_9_ARADDR,M_AXI_8_ARADDR,M_AXI_7_ARADDR,M_AXI_6_ARADDR,M_AXI_5_ARADDR,M_AXI_4_ARADDR,M_AXI_3_ARADDR,M_AXI_2_ARADDR,M_AXI_1_ARADDR,M_AXI_0_ARADDR}),
.M_AXI_ARPROT({M_AXI_23_ARPROT,M_AXI_22_ARPROT,M_AXI_21_ARPROT,M_AXI_20_ARPROT,M_AXI_19_ARPROT,M_AXI_18_ARPROT,M_AXI_17_ARPROT,M_AXI_16_ARPROT,M_AXI_15_ARPROT,M_AXI_14_ARPROT,M_AXI_13_ARPROT,M_AXI_12_ARPROT,M_AXI_11_ARPROT,M_AXI_10_ARPROT,M_AXI_9_ARPROT,M_AXI_8_ARPROT,M_AXI_7_ARPROT,M_AXI_6_ARPROT,M_AXI_5_ARPROT,M_AXI_4_ARPROT,M_AXI_3_ARPROT,M_AXI_2_ARPROT,M_AXI_1_ARPROT,M_AXI_0_ARPROT}),
.M_AXI_RVALID({M_AXI_23_RVALID,M_AXI_22_RVALID,M_AXI_21_RVALID,M_AXI_20_RVALID,M_AXI_19_RVALID,M_AXI_18_RVALID,M_AXI_17_RVALID,M_AXI_16_RVALID,M_AXI_15_RVALID,M_AXI_14_RVALID,M_AXI_13_RVALID,M_AXI_12_RVALID,M_AXI_11_RVALID,M_AXI_10_RVALID,M_AXI_9_RVALID,M_AXI_8_RVALID,M_AXI_7_RVALID,M_AXI_6_RVALID,M_AXI_5_RVALID,M_AXI_4_RVALID,M_AXI_3_RVALID,M_AXI_2_RVALID,M_AXI_1_RVALID,M_AXI_0_RVALID}),
.M_AXI_RREADY({M_AXI_23_RREADY,M_AXI_22_RREADY,M_AXI_21_RREADY,M_AXI_20_RREADY,M_AXI_19_RREADY,M_AXI_18_RREADY,M_AXI_17_RREADY,M_AXI_16_RREADY,M_AXI_15_RREADY,M_AXI_14_RREADY,M_AXI_13_RREADY,M_AXI_12_RREADY,M_AXI_11_RREADY,M_AXI_10_RREADY,M_AXI_9_RREADY,M_AXI_8_RREADY,M_AXI_7_RREADY,M_AXI_6_RREADY,M_AXI_5_RREADY,M_AXI_4_RREADY,M_AXI_3_RREADY,M_AXI_2_RREADY,M_AXI_1_RREADY,M_AXI_0_RREADY}),
.M_AXI_RDATA({M_AXI_23_RDATA,M_AXI_22_RDATA,M_AXI_21_RDATA,M_AXI_20_RDATA,M_AXI_19_RDATA,M_AXI_18_RDATA,M_AXI_17_RDATA,M_AXI_16_RDATA,M_AXI_15_RDATA,M_AXI_14_RDATA,M_AXI_13_RDATA,M_AXI_12_RDATA,M_AXI_11_RDATA,M_AXI_10_RDATA,M_AXI_9_RDATA,M_AXI_8_RDATA,M_AXI_7_RDATA,M_AXI_6_RDATA,M_AXI_5_RDATA,M_AXI_4_RDATA,M_AXI_3_RDATA,M_AXI_2_RDATA,M_AXI_1_RDATA,M_AXI_0_RDATA}),
.M_AXI_RRESP({M_AXI_23_RRESP,M_AXI_22_RRESP,M_AXI_21_RRESP,M_AXI_20_RRESP,M_AXI_19_RRESP,M_AXI_18_RRESP,M_AXI_17_RRESP,M_AXI_16_RRESP,M_AXI_15_RRESP,M_AXI_14_RRESP,M_AXI_13_RRESP,M_AXI_12_RRESP,M_AXI_11_RRESP,M_AXI_10_RRESP,M_AXI_9_RRESP,M_AXI_8_RRESP,M_AXI_7_RRESP,M_AXI_6_RRESP,M_AXI_5_RRESP,M_AXI_4_RRESP,M_AXI_3_RRESP,M_AXI_2_RRESP,M_AXI_1_RRESP,M_AXI_0_RRESP}),

    .S_AXI_ACLK(S_AXI_ACLK),
    .S_AXI_ARESETN(S_AXI_ARESETN)
    );
    endmodule
    