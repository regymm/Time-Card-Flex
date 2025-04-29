// SPDX-License-Identifier: MIT
// Author: regymm
module reset_counter #(
	parameter EXT_RST_LOGIC_LEVEL = 0,
	parameter EXT_RST_ACTIVE_WIDTH = 4, // <256
	parameter AUX_RST_LOGIC_LEVEL = 0,
	parameter AUX_RST_ACTIVE_WIDTH = 4, // <256
	parameter USE_EXT_RESET = 1,
	parameter USE_AUX_RESET = 1,
    parameter USE_CLK_LOCKED = 1,
    parameter FIRST_RESET_WIDTH = 16, // the three width summed up to be <256
    parameter FIRST_SECOND_WIDTH = 16,
    parameter SECOND_THIRD_WIDTH = 16
)(
	input slowest_sync_clk,
	input ext_reset_in,
	input aux_reset_in,
	input clk_locked,

    output wire rst_1,
    output wire rst_1_n,
    output wire rst_2,
    output wire rst_2_n,
    output wire rst_3,
    output wire rst_3_n
);
    // 1 means reset for internal signals
    wire clk_rst = USE_CLK_LOCKED ? !clk_locked : 1'b0;
    wire ext_rst = USE_EXT_RESET ? ext_reset_in ^ !EXT_RST_LOGIC_LEVEL : 1'b0;
    wire aux_rst = USE_AUX_RESET ? aux_reset_in ^ !AUX_RST_LOGIC_LEVEL : 1'b0;
    reg [7:0]ext_cnt = 0;
    reg [7:0]aux_cnt = 0;
    reg ext_trigger = 0;
    reg aux_trigger = 0;
    reg in_rst = 0;
    reg [7:0]rst_cnt = 0;
    always @ (posedge slowest_sync_clk) begin
        if (!clk_rst) begin
            if (in_rst) begin
                rst_cnt <= rst_cnt + 1;
                if (rst_cnt > FIRST_RESET_WIDTH + FIRST_SECOND_WIDTH + SECOND_THIRD_WIDTH) begin
                    in_rst <= 0;
                    rst_cnt <= 0;
                    ext_cnt <= 0;
                    aux_cnt <= 0;
                end
            end else begin
                if (ext_rst) begin
                    if (ext_cnt < EXT_RST_ACTIVE_WIDTH) ext_cnt <= ext_cnt + 1;
                end else begin
                    if (ext_cnt == EXT_RST_ACTIVE_WIDTH) ext_trigger <= 1;
                    ext_cnt <= 0;
                end
                if (aux_rst) begin
                    if (aux_cnt < AUX_RST_ACTIVE_WIDTH) aux_cnt <= aux_cnt + 1;
                end else begin
                    if (aux_cnt == AUX_RST_ACTIVE_WIDTH) aux_trigger <= 1;
                    aux_cnt <= 0;
                end
                if (ext_trigger | aux_trigger) begin
                    ext_trigger <= 0;
                    aux_trigger <= 0;
                    in_rst <= 1;
                    rst_cnt <= 0;
                end
            end
        end
    end
    assign rst_1 = clk_rst | (in_rst & rst_cnt <= FIRST_RESET_WIDTH);
    assign rst_2 = clk_rst | (in_rst & rst_cnt <= (FIRST_RESET_WIDTH + FIRST_SECOND_WIDTH));
    assign rst_3 = clk_rst | (in_rst & rst_cnt <= (FIRST_RESET_WIDTH + FIRST_SECOND_WIDTH + SECOND_THIRD_WIDTH));
    assign rst_1_n = !rst_1;
    assign rst_2_n = !rst_2;
    assign rst_3_n = !rst_3;
endmodule
