// SPDX-License-Identifier: MIT
// Author: regymm
module axil_gpio #(
	parameter ALL_INPUT = 0,
	parameter ALL_OUTPUT = 0,
	parameter WIDTH = 32,
	parameter DEFAULT_OUTPUT = 32'h00000000,
	parameter DEFAULT_TRI = 32'hFFFFFFFF,
	parameter ALL_INPUT_2 = 0,
	parameter ALL_OUTPUT_2 = 0,
	parameter WIDTH_2 = 32,
	parameter DEFAULT_OUTPUT_2 = 32'h00000000,
	parameter DEFAULT_TRI_2 = 32'hFFFFFFFF
)(
	input s_axi_clk,
	input s_axi_aresetn,

	// Standard AXI Lite
    input           [31:0] s_axi_awaddr,
    input                  s_axi_awvalid,
    output reg             s_axi_awready,

    input           [31:0] s_axi_wdata,
    input           [3:0]  s_axi_wstrb,
    input                  s_axi_wvalid,
    output reg             s_axi_wready,

    output reg       [1:0] s_axi_bresp,
    output reg             s_axi_bvalid,
    input                  s_axi_bready,

    input            [31:0] s_axi_araddr,
    input                  s_axi_arvalid,
    output reg             s_axi_arready,

    output reg       [31:0]s_axi_rdata = 0,
    output reg             s_axi_rvalid,
    input                  s_axi_rready,
    output reg       [1:0] s_axi_rresp,

	// inout [31:0]gpio;
	// inout [31:0]gpio2;
	// genvar i;
	// generate
	// for (i = 0; i < 32; i = i + 1) begin
	//     assign gpio_i[i] = gpio[i];
	//     assign gpio[i] = gpio_t[i] ? 1'bz : gpio_o[i];
	//     assign gpio2_i[i] = gpio2[i];
	//     assign gpio2[i] = gpio2_t[i] ? 1'bz : gpio2_o[i];
	// end
	// endgenerate
	(* X_INTERFACE_INFO = "xilinx.com:interface:gpio_rtl:1.0 GPIO TRI_I" *)
	(* X_INTERFACE_MODE = "master GPIO" *)
	input            [WIDTH-1:0]gpio_i,
	(* X_INTERFACE_INFO = "xilinx.com:interface:gpio_rtl:1.0 GPIO TRI_O" *)
	output reg       [WIDTH-1:0]gpio_o,
	(* X_INTERFACE_INFO = "xilinx.com:interface:gpio_rtl:1.0 GPIO TRI_T" *)
	output reg       [WIDTH-1:0]gpio_t,
	(* X_INTERFACE_INFO = "xilinx.com:interface:gpio_rtl:1.0 GPIO2 TRI_I" *)
	(* X_INTERFACE_MODE = "master GPIO2" *)
	input            [WIDTH_2-1:0]gpio2_i,
	(* X_INTERFACE_INFO = "xilinx.com:interface:gpio_rtl:1.0 GPIO2 TRI_O" *)
	output reg       [WIDTH_2-1:0]gpio2_o,
	(* X_INTERFACE_INFO = "xilinx.com:interface:gpio_rtl:1.0 GPIO2 TRI_T" *)
	output reg       [WIDTH_2-1:0]gpio2_t
);
	wire clk = s_axi_clk;
	wire rst_n = s_axi_aresetn;
	
	// GPIO drivers
	reg [31:0]gpio_d_r = 0;
	reg [31:0]gpio_d_w = 0;
	reg [31:0]gpio2_d_r = 0;
	reg [31:0]gpio2_d_w = 0;
	always @ (posedge clk) begin
		gpio_d_r <= {{(32-WIDTH){1'b0}}, gpio_i};
		gpio2_d_r <= {{(32-WIDTH_2){1'b0}}, gpio2_i};
		gpio_o <= gpio_d_w;
		gpio2_o <= gpio2_d_w;
	end

    // Memory and initialization
	reg [31:0]mem[255:0];
    integer i;
    initial begin
        // Initialize memory to zero
        for (i = 0; i < 256; i = i + 1) begin
            mem[i] = 32'h0;
        end
    end

	// Internal signals
    reg [31:0] write_address;
    reg [31:0] read_address;
    //reg        aw_en;

    // AXI Lite Write Address Channel
    always @(posedge clk) begin
        if (!rst_n) begin
			s_axi_awready <= 1'b1;
        end else begin
			if (s_axi_awvalid) begin
				write_address <= s_axi_awaddr;
			end
        end
    end

    // AXI Lite Write Data Channel
    always @(posedge clk) begin
        if (!rst_n) begin
            s_axi_wready <= 1'b0;
        end else begin
            if (!s_axi_wready && s_axi_wvalid) begin
                s_axi_wready <= 1'b1;
            end else begin
                s_axi_wready <= 1'b0;
            end
        end
    end

    // Write Operation
    always @(posedge clk) begin
        if (!rst_n) begin
			gpio_t <= DEFAULT_TRI;
			gpio2_t <= DEFAULT_TRI_2;
			gpio_d_w <= DEFAULT_OUTPUT;
			gpio2_d_w <= DEFAULT_OUTPUT_2;
            s_axi_bvalid <= 1'b0;
            s_axi_bresp  <= 2'b00;
        end else begin
			if (s_axi_wready && s_axi_wvalid) begin
                // Perform write operation
				case (write_address[7:0])
					8'h00: gpio_d_w <= s_axi_wdata;
					8'h04: gpio_t <= s_axi_wdata;
					8'h08: gpio2_d_w <= s_axi_wdata;
					8'h0C: gpio2_t <= s_axi_wdata;
					default: ;
				endcase
                s_axi_bvalid <= 1'b1;
                s_axi_bresp  <= 2'b00; // OKAY response
            end else if (s_axi_bvalid && s_axi_bready) begin
                s_axi_bvalid <= 1'b0;
            end else begin
                s_axi_bvalid <= s_axi_bvalid;
            end
        end
    end

    // AXI Lite Read Address Channel
    always @(posedge clk) begin
        if (!rst_n) begin
			s_axi_arready <= 1'b0;
        end else begin
			if (!s_axi_arready && s_axi_arvalid) begin
				s_axi_arready <= 1'b1;
				read_address  <= s_axi_araddr;
			end else begin
				s_axi_arready <= 1'b0;
			end
        end
    end

    // Read Operation
    always @(posedge clk) begin
        if (!rst_n) begin
            s_axi_rvalid <= 1'b0;
            s_axi_rresp  <= 2'b00;
        end else begin
            if (s_axi_arready && s_axi_arvalid) begin
                // Perform read operation
				case (read_address[7:0])
					8'h00: s_axi_rdata <= gpio_d_r;
					8'h04: s_axi_rdata <= gpio_t;
					8'h08: s_axi_rdata <= gpio2_d_r;
					8'h0C: s_axi_rdata <= gpio2_t;
					default: ;
				endcase
                s_axi_rvalid <= 1'b1;
                s_axi_rresp  <= 2'b00; // OKAY response
            end else if (s_axi_rvalid && s_axi_rready) begin
                s_axi_rvalid <= 1'b0;
            end else begin
                s_axi_rvalid <= s_axi_rvalid;
            end
        end
	end
endmodule
