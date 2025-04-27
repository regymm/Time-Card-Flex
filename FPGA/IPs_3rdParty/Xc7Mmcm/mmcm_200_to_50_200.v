// SPDX-License-Identifier: MIT
`timescale 1ps/1ps

// PTP peripherals driver clock
module mmcm_200_to_50_200 (
    input  wire   resetn,
    input  wire   clk_in_sel,
    input  wire   clk_in2,
    input  wire   clk_in1,
    output wire   clk_out1,
    output wire   clk_out2,
    output wire   locked
 );
    wire        fb;
    wire        fb_buf;
    wire        clk_out1_mmcm;
    wire        clk_out2_mmcm;
    MMCME2_ADV #(
        .BANDWIDTH            ("OPTIMIZED"),
        .CLKOUT4_CASCADE      ("FALSE"),
        .COMPENSATION         ("ZHOLD"),
        .STARTUP_WAIT         ("FALSE"),
        .DIVCLK_DIVIDE        (1),
        .CLKFBOUT_MULT_F      (5.000), // PLL 1 GHz
        .CLKFBOUT_PHASE       (0.000),
        .CLKFBOUT_USE_FINE_PS ("FALSE"),
        .CLKOUT0_DIVIDE_F     (20.000), // 50 MHz
        .CLKOUT0_PHASE        (0.000),
        .CLKOUT0_DUTY_CYCLE   (0.500),
        .CLKOUT0_USE_FINE_PS  ("FALSE"),
        .CLKOUT1_DIVIDE       (5), // 200 MHz
        .CLKOUT1_PHASE        (0.000),
        .CLKOUT1_DUTY_CYCLE   (0.500),
        .CLKOUT1_USE_FINE_PS  ("FALSE"),
        .CLKIN1_PERIOD        (5.000),
        .CLKIN2_PERIOD        (5.000)
        ) mmcm_adv_inst (
        .CLKFBOUT            (fb),
        .CLKFBOUTB           (),
        .CLKOUT0             (clk_out1_mmcm),
        .CLKOUT0B            (),
        .CLKOUT1             (clk_out2_mmcm),
        .CLKOUT1B            (),
        .CLKOUT2             (),
        .CLKOUT2B            (),
        .CLKOUT3             (),
        .CLKOUT3B            (),
        .CLKOUT4             (),
        .CLKOUT5             (),
        .CLKOUT6             (),
        .CLKFBIN             (fb_buf),
        .CLKIN1              (clk_in1),
        .CLKIN2              (clk_in2),
        .CLKINSEL            (clk_in_sel),
        .DADDR               (7'h0),
        .DCLK                (1'b0),
        .DEN                 (1'b0),
        .DI                  (16'h0),
        .DO                  (),
        .DRDY                (),
        .DWE                 (1'b0),
        .PSCLK               (1'b0),
        .PSEN                (1'b0),
        .PSINCDEC            (1'b0),
        .PSDONE              (),
        .LOCKED              (locked),
        .CLKINSTOPPED        (),
        .CLKFBSTOPPED        (),
        .PWRDWN              (1'b0),
        .RST                 (~resetn));
    BUFG clkf_buf (
        .O (fb_buf),
        .I (fb));
    BUFG clkout1_buf (
        .O   (clk_out1),
        .I   (clk_out1_mmcm));
    BUFG clkout2_buf (
        .O   (clk_out2),
        .I   (clk_out2_mmcm));
endmodule
