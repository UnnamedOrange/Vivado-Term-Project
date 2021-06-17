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
	input [7:0] is_combo,
	input [3:0] is_miss,
	input [3:0] is_bad,
	input [3:0] is_good,
	input [3:0] is_great,
	input [3:0] is_perfect,
	input [19:0] song_length,

	// 需要作为输出的变量。
	output reg [19:0] current_time,
	output reg [31:0] current_pixel,

	output reg [15:0] miss,
	output reg [15:0] bad,
	output reg [15:0] good,
	output reg [15:0] great,
	output reg [15:0] perfect,
	output reg [15:0] combo,

	// 复位与时钟。
	input RESET_L,
	input CLK
);

	// 变量。
	reg [11:0] current_speed;
	reg [11:0] current_offset;

	// 状态定义。
	localparam [state_width - 1 : 0]
		s_init                     = 4'd0,       // 复位。
		s_update_speed             = 4'd1,       // 更新速度。
		s_w_update_speed           = 4'd2,       // 等待更新速度。
		s_update_time_and_pixel    = 4'd3,       // 更新时间和像素。
		s_update_score             = 4'd4,       // 更新分数。
		s_done                     = 4'b1111,    // 完成。
		s_unused = 4'b1111;
	reg [state_width - 1 : 0] state, n_state;

	// 读取并更新速度。
	wire sig_update_speed_on;
	reg sig_update_speed_done;
	always @(posedge CLK) begin : update_speed_t
		reg working;
		reg [1:0] pat;

		if (!RESET_L) begin
			current_speed <= 0;
			current_offset <= 0;
			working <= 0;
			pat <= 0;
			sig_update_speed_done <= 0;
			dt_b_addr <= 0;
			dt_b_en <= 0;
		end
		else begin
			if (!working) begin
				if (sig_update_speed_on)
					working <= 1;
			end
			else begin
				if (pat == 0) begin
					dt_b_en <= 1;
					dt_b_addr <= dt_base_addr + current_offset;
				end
				else if (pat == 3) begin
					dt_b_en <= 0;
					working <= 0;
					// 更新速度。
					if (dt_b_data_out[19:0] == current_time) begin
						current_speed <= dt_b_data_out[31:20];
						current_offset <= current_offset + 1;
					end
				end
				pat <= pat + 1;
			end
			sig_update_speed_done <= working && pat == 2'b11;
		end
	end

	// 更新时间和位置。
	always @(posedge CLK) begin
		if (!RESET_L) begin
			current_time <= 0;
			current_pixel <= 0;
		end
		else begin
			if (state == s_update_time_and_pixel) begin
				if (current_time < song_length) begin
					current_time <= current_time + 1;
					current_pixel <= current_pixel + current_speed;
				end
			end
		end
	end

	// 更新分数。
	reg [15:0] next_miss;
	reg [15:0] next_bad;
	reg [15:0] next_good;
	reg [15:0] next_great;
	reg [15:0] next_perfect;
	reg [15:0] next_combo;
	always @(posedge CLK) begin
		if (!RESET_L) begin
			miss <= 0;
			bad <= 0;
			good <= 0;
			great <= 0;
			perfect <= 0;
			combo <= 0;
		end
		else begin
			if (state == s_update_score) begin
				miss <= next_miss;
				bad <= next_bad;
				good <= next_good;
				great <= next_great;
				perfect <= next_perfect;
				combo <= next_combo;
			end
		end
	end

	always @(*) begin : score_excitation
		integer i, j;

		next_miss = miss;
		next_bad = bad;
		next_good = good;
		next_great = great;
		next_perfect = perfect;
		for (i = 0; i < 4; i = i + 1) begin
			next_miss = next_miss + is_miss[i];
			for (j = 0; j < 4; j = j + 1) begin
				if (next_miss[j * 4 +: 4] >= 10) begin
					next_miss[j * 4 +: 4] = 0;
					if (j + 1 < 4)
						next_miss[(j + 1) * 4 +: 4] = next_miss[(j + 1) * 4 +: 4] + 1;
				end
			end
		end
		for (i = 0; i < 4; i = i + 1) begin
			next_bad = next_bad + is_bad[i];
			for (j = 0; j < 4; j = j + 1) begin
				if (next_bad[j * 4 +: 4] >= 10) begin
					next_bad[j * 4 +: 4] = 0;
					if (j + 1 < 4)
						next_bad[(j + 1) * 4 +: 4] = next_bad[(j + 1) * 4 +: 4] + 1;
				end
			end
		end
		for (i = 0; i < 4; i = i + 1) begin
			next_good = next_good + is_good[i];
			for (j = 0; j < 4; j = j + 1) begin
				if (next_good[j * 4 +: 4] >= 10) begin
					next_good[j * 4 +: 4] = 0;
					if (j + 1 < 4)
						next_good[(j + 1) * 4 +: 4] = next_good[(j + 1) * 4 +: 4] + 1;
				end
			end
		end
		for (i = 0; i < 4; i = i + 1) begin
			next_great = next_great + is_great[i];
			for (j = 0; j < 4; j = j + 1) begin
				if (next_great[j * 4 +: 4] >= 10) begin
					next_great[j * 4 +: 4] = 0;
					if (j + 1 < 4)
						next_great[(j + 1) * 4 +: 4] = next_great[(j + 1) * 4 +: 4] + 1;
				end
			end
		end
		for (i = 0; i < 4; i = i + 1) begin
			next_perfect = next_perfect + is_perfect[i];
			for (j = 0; j < 4; j = j + 1) begin
				if (next_perfect[j * 4 +: 4] >= 10) begin
					next_perfect[j * 4 +: 4] = 0;
					if (j + 1 < 4)
						next_perfect[(j + 1) * 4 +: 4] = next_perfect[(j + 1) * 4 +: 4] + 1;
				end
			end
		end

		next_combo = combo;
		for (i = 0; i < 4; i = i + 1)
			if (is_combo[i * 2 +: 2] == 2'b10)
				next_combo = 0;
		for (i = 0; i < 4; i = i + 1) begin
			if (is_combo[i * 2 +: 2] == 2'b01)
				next_combo = next_combo + 1;
			for (j = 0; j < 4; j = j + 1) begin
				if (next_combo[j * 4 +: 4] >= 10) begin
					next_combo[j * 4 +: 4] = 0;
					if (j + 1 < 4)
						next_combo[(j + 1) * 4 +: 4] = next_combo[(j + 1) * 4 +: 4] + 1;
				end
			end
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
				n_state = sig_on ? ((current_offset < dt_size) ? s_update_speed : s_update_time_and_pixel) : s_init;
			s_update_speed:
				n_state = s_w_update_speed;
			s_w_update_speed:
				n_state = sig_update_speed_done ? s_update_time_and_pixel : s_w_update_speed;
			s_update_time_and_pixel:
				n_state = s_update_score;
			s_update_score:
				n_state = s_done;
			s_done:
				n_state = s_init;
			default:
				n_state = s_init;
		endcase
	end

	// 输出方程。
	assign sig_done = state == s_done;
	assign sig_update_speed_on = state == s_update_speed;

endmodule