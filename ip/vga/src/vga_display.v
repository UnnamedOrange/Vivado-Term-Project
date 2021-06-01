// Copyright (c) UnnamedOrange and Jack-Lyu. Licensed under the MIT License.
// See the LICENSE file in the repository root for full license text.

/// <projectname>mania-to-go</projectname>
/// <modulename>vga_display_t</modulename>
/// <filedescription>VGA œ‘ æº∆À„ƒ£øÈ°£</filedescription>
/// <version>
/// 0.0.1 (UnnamedOrange and Jack-Lyu) : First commit.
/// </version>

`timescale 1ns / 1ps
module vga_display_t #
(
	parameter data_width = 1
)
(
	output [3:0] R,
	output [3:0] G,
	output [3:0] B,
	input [data_width - 1 : 0] DATA_TODO,
	input [9:0] H_CNT,
	input [9:0] V_CNT,
	input EN
);



endmodule