////////////////////////////////////////////////////////////////////////////////
//
// Filename: 	axixclk.v
// {{{
// Project:	WB2AXIPSP: bus bridges and other odds and ends
//
// Purpose:	Cross AXI clock domains
//
// Performance:
//
// Creator:	Dan Gisselquist, Ph.D.
//		Gisselquist Technology, LLC
//
////////////////////////////////////////////////////////////////////////////////
// }}}
// Copyright (C) 2019-2024, Gisselquist Technology, LLC
// {{{
// This file is part of the WB2AXIP project.
//
// The WB2AXIP project contains free software and gateware, licensed under the
// Apache License, Version 2.0 (the "License").  You may not use this project,
// or this file, except in compliance with the License.  You may obtain a copy
// of the License at
//
//	http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
// WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
// License for the specific language governing permissions and limitations
// under the License.
//
////////////////////////////////////////////////////////////////////////////////
//
//
`default_nettype	none
// }}}
module axixclk_al2al #(
		// {{{
		parameter integer C_S_AXI_ID_WIDTH	= 2,
		parameter integer C_S_AXI_DATA_WIDTH	= 32,
		parameter integer C_S_AXI_ADDR_WIDTH	= 32,
		// Some useful short-hand definitions
		// localparam	AW = C_S_AXI_ADDR_WIDTH,
		// localparam	DW = C_S_AXI_DATA_WIDTH,
		// localparam	IW = C_S_AXI_ID_WIDTH,
		//
		parameter [0:0]	OPT_WRITE_ONLY = 1'b0,
		parameter [0:0]	OPT_READ_ONLY = 1'b0,
		parameter	XCLOCK_FFS = 2,
		parameter	LGFIFO = 5
		// }}}
	) (
		// {{{
		// Users to add ports here

		// User ports ends
		// Do not modify the ports beyond this line

		input	wire				S_AXI_ACLK,
		input	wire				S_AXI_ARESETN,
		//
		input	wire [C_S_AXI_ADDR_WIDTH-1 : 0]	S_AXI_AWADDR,
		input	wire [2 : 0]			S_AXI_AWPROT,
		input	wire				S_AXI_AWVALID,
		output	wire				S_AXI_AWREADY,
		//
		input	wire [C_S_AXI_DATA_WIDTH-1 : 0]	S_AXI_WDATA,
		input	wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0] S_AXI_WSTRB,
		input	wire				S_AXI_WVALID,
		output	wire				S_AXI_WREADY,
		//
		output	wire [1 : 0]			S_AXI_BRESP,
		output	wire				S_AXI_BVALID,
		input	wire				S_AXI_BREADY,
		//
		input	wire [C_S_AXI_ADDR_WIDTH-1 : 0]	S_AXI_ARADDR,
		input	wire [2 : 0]			S_AXI_ARPROT,
		input	wire				S_AXI_ARVALID,
		output	wire				S_AXI_ARREADY,
		//
		output	wire [C_S_AXI_DATA_WIDTH-1 : 0]	S_AXI_RDATA,
		output	wire [1 : 0]			S_AXI_RRESP,
		output	wire				S_AXI_RVALID,
		input	wire				S_AXI_RREADY,

		//
		//	Downstream port
		//
		input	wire				M_AXI_ACLK,
		output	wire				M_AXI_ARESETN,
		//
		output	wire [C_S_AXI_ADDR_WIDTH-1 : 0]	M_AXI_AWADDR,
		output	wire [2 : 0]			M_AXI_AWPROT,
		output	wire				M_AXI_AWVALID,
		input	wire				M_AXI_AWREADY,
		//
		output	wire [C_S_AXI_DATA_WIDTH-1 : 0]	M_AXI_WDATA,
		output	wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0] M_AXI_WSTRB,
		output	wire				M_AXI_WVALID,
		input	wire				M_AXI_WREADY,
		//
		input	wire [1 : 0]			M_AXI_BRESP,
		input	wire				M_AXI_BVALID,
		output	wire				M_AXI_BREADY,
		//
		output	wire [C_S_AXI_ADDR_WIDTH-1 : 0]	M_AXI_ARADDR,
		output	wire [2 : 0]			M_AXI_ARPROT,
		output	wire				M_AXI_ARVALID,
		input	wire				M_AXI_ARREADY,
		//
		input	wire [C_S_AXI_DATA_WIDTH-1 : 0]	M_AXI_RDATA,
		input	wire [1 : 0]			M_AXI_RRESP,
		input	wire				M_AXI_RVALID,
		output	wire				M_AXI_RREADY
		// }}}
	);
	wire [C_S_AXI_ID_WIDTH-1 : 0]	S_AXI_AWID = 0;
	wire [7 : 0]			S_AXI_AWLEN = 0;
	wire [2 : 0]			S_AXI_AWSIZE = 0;
	wire [1 : 0]			S_AXI_AWBURST = 0;
	wire				S_AXI_AWLOCK = 0;
	wire [3 : 0]			S_AXI_AWCACHE = 0;
	wire [3 : 0]			S_AXI_AWQOS = 0;
	wire				S_AXI_WLAST = 0;
	wire [C_S_AXI_ID_WIDTH-1 : 0]	S_AXI_BID;
	wire [C_S_AXI_ID_WIDTH-1 : 0]	S_AXI_ARID = 0;
	wire [7 : 0]			S_AXI_ARLEN = 0;
	wire [2 : 0]			S_AXI_ARSIZE = 0;
	wire [1 : 0]			S_AXI_ARBURST = 0;
	wire				S_AXI_ARLOCK = 0;
	wire [3 : 0]			S_AXI_ARCACHE = 0;
	wire [3 : 0]			S_AXI_ARQOS = 0;
	wire [C_S_AXI_ID_WIDTH-1 : 0]	S_AXI_RID;
	wire				S_AXI_RLAST;
	wire [C_S_AXI_ID_WIDTH-1 : 0]	M_AXI_AWID;
	wire [7 : 0]			M_AXI_AWLEN;
	wire [2 : 0]			M_AXI_AWSIZE;
	wire [1 : 0]			M_AXI_AWBURST;
	wire				M_AXI_AWLOCK;
	wire [3 : 0]			M_AXI_AWCACHE;
	wire [3 : 0]			M_AXI_AWQOS;
	wire				M_AXI_WLAST;
	wire [C_S_AXI_ID_WIDTH-1 : 0]	M_AXI_BID = 0;
	wire [C_S_AXI_ID_WIDTH-1 : 0]	M_AXI_ARID;
	wire [7 : 0]			M_AXI_ARLEN;
	wire [2 : 0]			M_AXI_ARSIZE;
	wire [1 : 0]			M_AXI_ARBURST;
	wire				M_AXI_ARLOCK;
	wire [3 : 0]			M_AXI_ARCACHE;
	wire [3 : 0]			M_AXI_ARQOS;
	wire [C_S_AXI_ID_WIDTH-1 : 0]	M_AXI_RID = 0;
	wire				M_AXI_RLAST = 0;

	reg	[2:0]	mreset;

	(* ASYNC_REG = "TRUE" *) initial	mreset = 3'b000;
	always @(posedge M_AXI_ACLK, negedge S_AXI_ARESETN)
	if (!S_AXI_ARESETN)
		mreset <= 3'b000;
	else
		mreset <= { mreset[1:0], 1'b1 };

	assign	M_AXI_ARESETN = mreset[2];

	generate if (OPT_READ_ONLY)
	begin : READ_ONLY

		assign	M_AXI_AWID = 0;
		assign	M_AXI_AWADDR = 0;
		assign	M_AXI_AWLEN  = 0;
		assign	M_AXI_AWSIZE = 0;
		assign	M_AXI_AWBURST= 0;
		assign	M_AXI_AWLOCK = 0;
		assign	M_AXI_AWCACHE= 0;
		assign	M_AXI_AWPROT = 0;
		assign	M_AXI_AWQOS  = 0;
		// Either way we do these we're wrong, so don't try accessing
		// the write side of the bus when OPT_READ_ONLY is set or your
		// design will hang.

		assign	M_AXI_AWVALID = 1'b0;
		assign	S_AXI_AWREADY = 1'b0;

		assign	M_AXI_WDATA = 0;
		assign	M_AXI_WSTRB = 0;
		assign	M_AXI_WLAST = 0;

		assign	M_AXI_WVALID = 1'b0;
		assign	S_AXI_WREADY = 1'b0;

		assign	S_AXI_BID   = 0;
		assign	S_AXI_BRESP = 2'b11;

		assign	M_AXI_BREADY = 1'b0;
		assign	S_AXI_BVALID = 1'b0;

	end else begin : WRITE_FIFO
		wire	awfull, awempty, wfull, wempty, bfull, bempty;

		afifo #(.LGFIFO(LGFIFO),
			.NFF(XCLOCK_FFS),
			.WIDTH(C_S_AXI_ID_WIDTH + C_S_AXI_ADDR_WIDTH
				+ 8 + 3 + 2 + 1 + 4 + 3 + 4))
		awfifo(S_AXI_ACLK, S_AXI_ARESETN, S_AXI_AWVALID&& S_AXI_AWREADY,
			{ S_AXI_AWID, S_AXI_AWADDR,
				S_AXI_AWLEN, S_AXI_AWSIZE, S_AXI_AWBURST,
				S_AXI_AWLOCK,
				S_AXI_AWCACHE, S_AXI_AWPROT, S_AXI_AWQOS },
			awfull,
			M_AXI_ACLK, M_AXI_ARESETN, M_AXI_AWREADY,
			{ M_AXI_AWID, M_AXI_AWADDR,
				M_AXI_AWLEN, M_AXI_AWSIZE, M_AXI_AWBURST,
				M_AXI_AWLOCK,
				M_AXI_AWCACHE, M_AXI_AWPROT, M_AXI_AWQOS },
			awempty);

		assign	M_AXI_AWVALID = !awempty;
		assign	S_AXI_AWREADY = !awfull;

		afifo #(.LGFIFO(LGFIFO),
			.NFF(XCLOCK_FFS),
			.WIDTH(C_S_AXI_DATA_WIDTH + C_S_AXI_DATA_WIDTH/8 + 1))
		wfifo(S_AXI_ACLK, S_AXI_ARESETN, S_AXI_WVALID&& S_AXI_WREADY,
			{ S_AXI_WDATA, S_AXI_WSTRB, S_AXI_WLAST },
			wfull,
			M_AXI_ACLK, M_AXI_ARESETN, M_AXI_WREADY,
			{ M_AXI_WDATA, M_AXI_WSTRB, M_AXI_WLAST },
			wempty);

		assign	M_AXI_WVALID = !wempty;
		assign	S_AXI_WREADY = !wfull;

		afifo #(.LGFIFO(LGFIFO),
			.NFF(XCLOCK_FFS),
			.WIDTH(C_S_AXI_ID_WIDTH + 2))
		bfifo(M_AXI_ACLK, M_AXI_ARESETN, M_AXI_BVALID&& M_AXI_BREADY,
			{ M_AXI_BID, M_AXI_BRESP }, bfull,
			S_AXI_ACLK, S_AXI_ARESETN, S_AXI_BREADY,
			{ S_AXI_BID, S_AXI_BRESP }, bempty);

		assign	S_AXI_BVALID = !bempty;
		assign	M_AXI_BREADY = !bfull;
	end endgenerate

	generate if (OPT_WRITE_ONLY)
	begin : NO_READS

		assign	M_AXI_ARID = 0;
		assign	M_AXI_ARADDR = 0;
		assign	M_AXI_ARLEN  = 0;
		assign	M_AXI_ARSIZE = 0;
		assign	M_AXI_ARBURST= 0;
		assign	M_AXI_ARLOCK = 0;
		assign	M_AXI_ARCACHE= 0;
		assign	M_AXI_ARPROT = 0;
		assign	M_AXI_ARQOS  = 0;
		// Either way we do these we're wrong, so don't try accessing
		// the write side of the bus when OPT_READ_ONLY is set or your
		// design will hang.

		assign	M_AXI_ARVALID = 1'b0;
		assign	S_AXI_ARREADY = 1'b0;

		assign	S_AXI_RID   = 0;
		assign	S_AXI_RDATA = 2'b11;
		assign	S_AXI_RLAST = 1'b1;
		assign	S_AXI_RRESP = 2'b11;

		assign	M_AXI_RREADY = 1'b0;
		assign	S_AXI_RVALID = 1'b0;

	end else begin : READ_FIFO
		wire	arfull, arempty, rfull, rempty;

		afifo #(.LGFIFO(LGFIFO),
			.NFF(XCLOCK_FFS),
			.WIDTH(C_S_AXI_ID_WIDTH + C_S_AXI_ADDR_WIDTH
				+ 8 + 3 + 2 + 1 + 4 + 3 + 4))
		arfifo(S_AXI_ACLK, S_AXI_ARESETN, S_AXI_ARVALID&& S_AXI_ARREADY,
			{ S_AXI_ARID, S_AXI_ARADDR,
				S_AXI_ARLEN, S_AXI_ARSIZE, S_AXI_ARBURST,
				S_AXI_ARLOCK,
				S_AXI_ARCACHE, S_AXI_ARPROT, S_AXI_ARQOS },
			arfull,
			M_AXI_ACLK, M_AXI_ARESETN, M_AXI_ARREADY,
			{ M_AXI_ARID, M_AXI_ARADDR,
				M_AXI_ARLEN, M_AXI_ARSIZE, M_AXI_ARBURST,
				M_AXI_ARLOCK,
				M_AXI_ARCACHE, M_AXI_ARPROT, M_AXI_ARQOS },
			arempty);

		assign	M_AXI_ARVALID = !arempty;
		assign	S_AXI_ARREADY = !arfull;


		afifo #(.LGFIFO(LGFIFO),
			.NFF(XCLOCK_FFS),
			.WIDTH(C_S_AXI_ID_WIDTH + C_S_AXI_DATA_WIDTH+3))
		rfifo(M_AXI_ACLK, M_AXI_ARESETN, M_AXI_RVALID&& M_AXI_RREADY,
			{ M_AXI_RID, M_AXI_RDATA, M_AXI_RLAST, M_AXI_RRESP },
			rfull,
			S_AXI_ACLK, S_AXI_ARESETN, S_AXI_RREADY,
			{ S_AXI_RID, S_AXI_RDATA, S_AXI_RLAST, S_AXI_RRESP },
			rempty);

		assign	S_AXI_RVALID = !rempty;
		assign	M_AXI_RREADY = !rfull;

	end endgenerate

endmodule
