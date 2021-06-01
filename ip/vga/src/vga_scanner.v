// Copyright (c) UnnamedOrange and Jack-Lyu. Licensed under the MIT License.
// See the LICENSE file in the repository root for full license text.

/// <projectname>mania-to-go</projectname>
/// <modulename>vga_scanner_t</modulename>
/// <filedescription>VGA É¨ÃèÄ£¿é¡£</filedescription>
/// <version>
/// 0.0.1 (UnnamedOrange and Jack-Lyu) : First commit.
/// </version>

`timescale 1ns / 1ps
module vga_scanner_t #
(
	parameter h_frontporch = 96,
	parameter h_active = 144,
	parameter h_backporch = 784,
	parameter h_total = 800,
	parameter v_frontporch = 2,
	parameter v_active = 35,
	parameter v_backporch = 515,
	parameter v_total = 525
)
(
	output HSYNC,
	output VSYNC,
	output reg [9:0] H_CNT,
	output reg [9:0] V_CNT,
	output EN_DISPLAY,
	input RESET_L,
	input CLK
);



endmodule