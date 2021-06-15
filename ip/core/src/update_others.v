// Copyright (c) UnnamedOrange and Jack-Lyu. Licensed under the MIT License.
// See the LICENSE file in the repository root for full license text.

/// <projectname>mania-to-go</projectname>
/// <modulename>update_others_t</modulename>
/// <filedescription>update 其他信息，包括时间、像素、总分数。</filedescription>
/// <version>
/// 0.0.1 (UnnamedOrange) : First commit.
/// </version>

`timescale 1ns / 1ps

module update_others_t #
(
	// 内部参数。
	parameter state_width = 4
)
(
	// 控制。
	input sig_on,
	output sig_done,

	// BRAM。
	output reg [11:0] dt_b_addr,
	input [31:0] dt_b_data_out,
	output reg dt_b_en,

	// 数量与基地址。
	input [11:0] dt_size,
	input [11:0] dt_base_addr, // == 2

	// 游戏状态。
	input [3:0] is_game_over,
	input [3:0] is_miss,
	input [3:0] is_bad,
	input [3:0] is_good,
	input [3:0] is_great,
	input [3:0] is_perfect,

	// 需要作为输出的变量。
	output reg [19:0] current_time,
	output reg [31:0] current_pixel,

	// 复位与时钟。
	input RESET_L,
	input CLK
);

	// 变量。
	reg [11:0] current_speed;

	// 状态定义。
	

endmodule