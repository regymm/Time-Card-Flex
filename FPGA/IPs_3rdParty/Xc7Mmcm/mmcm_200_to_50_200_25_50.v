// SPDX-License-Identifier: MIT
`timescale 1ps/1ps

// system peripherals clock
module mmcm_200_to_50_200_25_50 (
    input  wire   resetn,
    input  wire   clk_in1_p,
    input  wire   clk_in1_n,
    output wire   clk_out1,
    output wire   clk_out2,
    output wire   clk_out3,
    output wire   clk_out4,
    output wire   locked
 );
    wire clk_in1_mmcm;
    IBUFDS clkin1_ibufds
        (.O (clk_in1_mmcm),
        .I  (clk_in1_p),
        .IB (clk_in1_n));
    wire clk_out1_mmcm;
    wire clk_out2_mmcm;
    wire clk_out3_mmcm;
    wire clk_out4_mmcm;
    wire fb;
    wire fb_buf;
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
        .CLKOUT2_DIVIDE       (40), // 25 MHz
        .CLKOUT2_PHASE        (0.000),
        .CLKOUT2_DUTY_CYCLE   (0.500),
        .CLKOUT2_USE_FINE_PS  ("FALSE"),
        .CLKOUT3_DIVIDE       (20), // 50 MHz
        .CLKOUT3_PHASE        (0.000),
        .CLKOUT3_DUTY_CYCLE   (0.500),
        .CLKOUT3_USE_FINE_PS  ("FALSE"),
        .CLKIN1_PERIOD        (5.000)
        ) mmcm_adv_inst (
        .CLKFBOUT            (fb),
        .CLKFBOUTB           (),
        .CLKOUT0             (clk_out1_mmcm),
        .CLKOUT0B            (),
        .CLKOUT1             (clk_out2_mmcm),
        .CLKOUT1B            (),
        .CLKOUT2             (clk_out3_mmcm),
        .CLKOUT2B            (),
        .CLKOUT3             (clk_out4_mmcm),
        .CLKOUT3B            (),
        .CLKOUT4             (),
        .CLKOUT5             (),
        .CLKOUT6             (),
        .CLKFBIN             (fb_buf),
        .CLKIN1              (clk_in1_mmcm),
        .CLKIN2              (1'b0),
        .CLKINSEL            (1'b1),
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
    BUFG clkf_buf
        (.O (fb_buf),
        .I (fb));
    BUFG clkout1_buf
        (.O   (clk_out1),
        .I   (clk_out1_mmcm));
    BUFG clkout2_buf
        (.O   (clk_out2),
        .I   (clk_out2_mmcm));
    BUFG clkout3_buf
        (.O   (clk_out3),
        .I   (clk_out3_mmcm));
    BUFG clkout4_buf
        (.O   (clk_out4),
        .I   (clk_out4_mmcm));
endmodule
