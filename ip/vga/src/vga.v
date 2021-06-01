// Copyright (c) UnnamedOrange and Jack-Lyu. Licensed under the MIT License.
// See the LICENSE file in the repository root for full license text.

/// <projectname>mania-to-go</projectname>
/// <modulename>vga_t</modulename>
/// <filedescription>VGA 总模块。</filedescription>
/// <version>
/// 0.0.1 (UnnamedOrange and Jack-Lyu) : First commit.
/// </version>

`timescale 1ns / 1ps
module vga_t #
(
	parameter data_width = 1
)
(
	output HSYNC,
	output VSYNC,
	output [3:0] R,
	output [3:0] G,
	output [3:0] B,
	input [data_width - 1 : 0] DATA_TODO, // 看作异步输入。
	input RESET_L,
	input CLK
);

	wire [9:0] h_cnt, v_cnt;
	wire en_display;

	vga_scanner_t U1
	(
		.HSYNC(HSYNC),
		.VSYNC(VSYNC),
		.H_CNT(h_cnt),
		.V_CNT(v_cnt),
		.EN_DISPLAY(en_display),
		.RESET_L(RESET_L),
		.CLK(CLK)
	);

	vga_display_t #(.data_width(data_width)) U2
	(
		 .R(R),
		 .G(G),
		 .B(B),
		 .DATA_TODO(DATA_TODO),
		 .H_CNT(h_cnt),
		 .V_CNT(v_cnt),
		 .EN(en_display)
	);

endmodule