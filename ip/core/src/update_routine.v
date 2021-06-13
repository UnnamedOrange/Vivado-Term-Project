// Copyright (c) UnnamedOrange and Jack-Lyu. Licensed under the MIT License.
// See the LICENSE file in the repository root for full license text.

/// <projectname>mania-to-go</projectname>
/// <modulename>update_routine_t</modulename>
/// <filedescription>update 管理器。</filedescription>
/// <version>
/// 0.0.1 (UnnamedOrange) : First commit.
/// </version>

`timescale 1ns / 1ps

module update_routine_t
(
	// 控制。
	input sig_on,
	output sig_done,

	// BRAM。
	output [12:0] db_b_addr,
	input [23:0] db_b_data_out,
	output db_b_en,

	output [11:0] do_a_addr,
	output [7:0] do_a_data_in,
	output do_a_en_w,
	output [12:0] do_b_addr,
	input [3:0] do_b_data_out,
	output do_b_en,

	output [12:0] dp_b_addr,
	input [31:0] dp_b_data_out,
	output dp_b_en,

	output [11:0] dt_b_addr,
	input [31:0] dt_b_data_out,
	output dt_b_en,

	// 数量与基地址。
	input [12:0] db_size_0,
	input [12:0] db_size_1,
	input [12:0] db_size_2,
	input [12:0] db_size_3,
	input [12:0] db_base_addr_0,
	input [12:0] db_base_addr_1,
	input [12:0] db_base_addr_2,
	input [12:0] db_base_addr_3,
	input [12:0] do_size_0,
	input [12:0] do_size_1,
	input [12:0] do_size_2,
	input [12:0] do_size_3,
	input [12:0] do_base_addr_0,
	input [12:0] do_base_addr_1,
	input [12:0] do_base_addr_2,
	input [12:0] do_base_addr_3,
	// dp_size == db_size
	// dp_base_addr == db_base_addr
	input [11:0] dt_size,
	input [11:0] dt_base_addr, // == 2
	input [19:0] song_length,

	// 键盘。
	input [3:0] is_key_down,
	input [3:0] is_key_changed,

	// 需要作为输出的寄存器。
	output reg [19:0] current_time,

	// 复位与时钟。
	input RESET_L,
	input CLK
);

	// 状态定义。

	// 激励方程。
	always @(posedge CLK) begin
		if (!RESET_L) begin
			current_time <= 0;
		end
		else begin

		end
	end

	// 输出方程。

endmodule