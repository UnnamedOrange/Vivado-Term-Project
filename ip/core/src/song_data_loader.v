// Copyright (c) UnnamedOrange and Jack-Lyu. Licensed under the MIT License.
// See the LICENSE file in the repository root for full license text.

/// <projectname>mania-to-go</projectname>
/// <modulename>song_data_loader_t</modulename>
/// <filedescription>将歌曲初始化。</filedescription>
/// <version>
/// 0.0.1 (UnnamedOrange) : First commit.
/// </version>

`timescale 1ns / 1ps

module song_data_loader_t #
(
	parameter [7:0] static_init_aux_info = 8'b00000100,
	parameter restarting_timeout = 10000000
)
(
	// CPU。
	output [7:0] song_init_index,
	output [7:0] song_init_aux_info,
	output song_restart,

	// 外部信息。
	input [7:0] song_selection,

	// 控制。
	input sig_on,
	output sig_done,

	// 复位与时钟。
	input RESET_L,
	input CLK
);

	// 状态定义。
	localparam state_width = 2;
	localparam [state_width - 1 : 0]
		s_init =       0, // 等待工作使能。
		s_restarting = 1, // 等待 CPU 初始化。
		s_done =       2, // 向外宣布工作完成。
		s_unused = 0;
	reg [state_width - 1 : 0] state, n_state;

	// 计时器。
	reg [31:0] timer;

	always @(posedge CLK) begin
		if (!RESET_L) begin
			timer <= 0;
		end
		else begin
			if (timer == restarting_timeout - 1)
				timer <= 0;
			else
				timer <= timer + 1;
		end
	end

	// 特征方程。
	always @(posedge CLK) begin
		if (!RESET_L) begin
			state <= s_init;
		end
		else begin
			state <= n_state;
		end
	end

	// 激励方程。
	always @(*) begin
		case (state)
			s_init:
				n_state = sig_on ? s_restarting : s_init;
			s_restarting:
				n_state = timer == restarting_timeout - 1 ? s_done : s_restarting;
			s_done:
				n_state = s_init;
			default:
				n_state = s_init;
		endcase
	end

	// 输出方程。
	assign song_init_index = song_selection;
	assign song_init_aux_info = static_init_aux_info;
	assign song_restart = state == s_restarting;
	assign sig_done = state == s_done;

endmodule