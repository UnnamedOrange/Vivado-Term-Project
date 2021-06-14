// Copyright (c) UnnamedOrange and Jack-Lyu. Licensed under the MIT License.
// See the LICENSE file in the repository root for full license text.

/// <projectname>mania-to-go</projectname>
/// <modulename>update_single_track_t</modulename>
/// <filedescription>单条轨道 update 管理器。</filedescription>
/// <version>
/// 0.0.1 (UnnamedOrange) : 定义输入输出。
/// </version>

`timescale 1ns / 1ps

module update_single_track_t #
(
	parameter __unused = 0
)
(
	// 控制。
	input sig_on,       // 收到 sig_on 时开始工作。
	output sig_done,    // 工作结束后发送 sig_done。

	// BRAM。端口 a 是写端口，端口 b 是读端口。
	// beatmap（对象时间点）
	output [12:0] db_b_addr,
	input [23:0] db_b_data_out,
	output db_b_en,

	// object（对象）
	output [11:0] do_a_addr,
	output [7:0] do_a_data_in,
	output do_a_en_w,
	output [12:0] do_b_addr,
	input [3:0] do_b_data_out,
	output do_b_en,

	// 数量与基地址。
	input [12:0] db_size,         // 对象时间点的数量。用于判断“没有下一个对象时间点”。
	input [12:0] db_base_addr,    // 对象时间点基地址。用 db_base_addr + i 访问第 i 个对象时间点，下标从 0 开始。
	input [12:0] do_size,         // 对象的数量。
	input [12:0] do_base_addr,    // 对象基地址。用 do_base_addr + i 访问第 i 个对象，下标从 0 开始。注意写回去的时候位宽翻倍，地址位少一位。

	// 键盘。
	input is_key_down,       // 是否按下键盘。
	input is_key_changed,    // 用于判断“事件发生”。

	// 额外输入。
	input [19:0] current_time, // 当前时间，单位为毫秒。用于“更新成绩”。

	// 额外输出。
	output is_game_over, // 是否“打完了”。
	output is_miss,
	output is_bad,
	output is_good,
	output is_great,
	output is_perfect,

	// 复位与时钟。
	input RESET_L,
	input CLK
);



endmodule