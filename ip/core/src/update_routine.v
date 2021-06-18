// Copyright (c) UnnamedOrange and Jack-Lyu. Licensed under the MIT License.
// See the LICENSE file in the repository root for full license text.

/// <projectname>mania-to-go</projectname>
/// <modulename>update_routine_t</modulename>
/// <filedescription>update 管理器。</filedescription>
/// <version>
/// 0.0.1 (UnnamedOrange) : First commit.
/// </version>

`timescale 1ns / 1ps

module update_routine_t #
(
	// 内部参数。
	parameter state_width = 4
)
(
	// 控制。
	input sig_on,
	output sig_done,

	// BRAM。
	output reg [12:0] db_b_addr,
	input [23:0] db_b_data_out,
	output reg db_b_en,

	output reg [11:0] do_a_addr,
	output reg [7:0] do_a_data_in,
	output reg do_a_en_w,
	output reg [12:0] do_b_addr,
	input [3:0] do_b_data_out,
	output reg do_b_en,

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
	input [11:0] dt_size,
	input [11:0] dt_base_addr, // == 2
	input [19:0] song_length,

	// 键盘。
	input [3:0] is_key_down,
	input [3:0] is_key_changed,

	// 需要作为输出的变量。
	output [19:0] current_time,
	output [31:0] current_pixel,

	output [15:0] miss,
	output [15:0] bad,
	output [15:0] good,
	output [15:0] great,
	output [15:0] perfect,
	output [15:0] combo,
	output [3:0] current_score,
	output [1:0] current_score_fade,

	// 复位与时钟。
	input RESET_L,
	input CLK
);

	// 状态定义。
	localparam [state_width - 1 : 0]
		s_init               = 4'd0,       // 复位。
		s_update_0           = 4'd1,       // 更新第一条轨道。
		s_w_update_0         = 4'd2,       // 等待更新第一条轨道。
		s_update_1           = 4'd3,       // 更新第二条轨道。
		s_w_update_1         = 4'd4,       // 等待更新第二条轨道。
		s_update_2           = 4'd5,       // 更新第三条轨道。
		s_w_update_2         = 4'd6,       // 等待更新第三条轨道。
		s_update_3           = 4'd7,       // 更新第四条轨道。
		s_w_update_3         = 4'd8,       // 等待更新第四条轨道。
		s_update_others      = 4'd9,       // 更新时间和像素点。
		s_w_update_others    = 4'd10,      // 等待更新时间和像素点。
		s_done               = 4'b1111,    // 完成。
		s_unused = 4'b1111;
	reg [state_width - 1 : 0] state, n_state;

	// 模块互联。
	wire [3:0] is_game_over;
	wire [3:0] is_miss;
	wire [3:0] is_bad;
	wire [3:0] is_good;
	wire [3:0] is_great;
	wire [3:0] is_perfect;
	wire [7:0] is_combo;

	wire sig_update_0_on;
	wire sig_update_0_done;
	wire [12:0] db_0_b_addr;
	wire db_0_b_en;
	wire [11:0] do_0_a_addr;
	wire [7:0] do_0_a_data_in;
	wire do_0_a_en_w;
	wire [12:0] do_0_b_addr;
	wire do_0_b_en;
	update_single_track_t update_single_track_0 (
		.sig_on(sig_update_0_on),
		.sig_done(sig_update_0_done),

		.db_b_addr(db_0_b_addr),
		.db_b_data_out(db_b_data_out),
		.db_b_en(db_0_b_en),

		.do_a_addr(do_0_a_addr),
		.do_a_data_in(do_0_a_data_in),
		.do_a_en_w(do_0_a_en_w),
		.do_b_addr(do_0_b_addr),
		.do_b_data_out(do_b_data_out),
		.do_b_en(do_0_b_en),

		.db_size(db_size_0),
		.db_base_addr(db_base_addr_0),
		.do_size(do_size_0),
		.do_base_addr(do_base_addr_0),

		.is_key_down(is_key_down[0]),
		.is_key_changed(is_key_changed[0]),

		.current_time(current_time),

		.is_game_over(is_game_over[0]),
		.comb(is_combo[1:0]),
		.is_miss(is_miss[0]),
		.is_bad(is_bad[0]),
		.is_good(is_good[0]),
		.is_great(is_great[0]),
		.is_perfect(is_perfect[0]),

		.RESET_L(RESET_L),
		.CLK(CLK)
	);

	wire sig_update_1_on;
	wire sig_update_1_done;
	wire [12:0] db_1_b_addr;
	wire db_1_b_en;
	wire [11:0] do_1_a_addr;
	wire [7:0] do_1_a_data_in;
	wire do_1_a_en_w;
	wire [12:0] do_1_b_addr;
	wire do_1_b_en;
	update_single_track_t update_single_track_1 (
		.sig_on(sig_update_1_on),
		.sig_done(sig_update_1_done),

		.db_b_addr(db_1_b_addr),
		.db_b_data_out(db_b_data_out),
		.db_b_en(db_1_b_en),

		.do_a_addr(do_1_a_addr),
		.do_a_data_in(do_1_a_data_in),
		.do_a_en_w(do_1_a_en_w),
		.do_b_addr(do_1_b_addr),
		.do_b_data_out(do_b_data_out),
		.do_b_en(do_1_b_en),

		.db_size(db_size_1),
		.db_base_addr(db_base_addr_1),
		.do_size(do_size_1),
		.do_base_addr(do_base_addr_1),

		.is_key_down(is_key_down[1]),
		.is_key_changed(is_key_changed[1]),

		.current_time(current_time),

		.is_game_over(is_game_over[1]),
		.comb(is_combo[3:2]),
		.is_miss(is_miss[1]),
		.is_bad(is_bad[1]),
		.is_good(is_good[1]),
		.is_great(is_great[1]),
		.is_perfect(is_perfect[1]),

		.RESET_L(RESET_L),
		.CLK(CLK)
	);

	wire sig_update_2_on;
	wire sig_update_2_done;
	wire [12:0] db_2_b_addr;
	wire db_2_b_en;
	wire [11:0] do_2_a_addr;
	wire [7:0] do_2_a_data_in;
	wire do_2_a_en_w;
	wire [12:0] do_2_b_addr;
	wire do_2_b_en;
	update_single_track_t update_single_track_2 (
		.sig_on(sig_update_2_on),
		.sig_done(sig_update_2_done),

		.db_b_addr(db_2_b_addr),
		.db_b_data_out(db_b_data_out),
		.db_b_en(db_2_b_en),

		.do_a_addr(do_2_a_addr),
		.do_a_data_in(do_2_a_data_in),
		.do_a_en_w(do_2_a_en_w),
		.do_b_addr(do_2_b_addr),
		.do_b_data_out(do_b_data_out),
		.do_b_en(do_2_b_en),

		.db_size(db_size_2),
		.db_base_addr(db_base_addr_2),
		.do_size(do_size_2),
		.do_base_addr(do_base_addr_2),

		.is_key_down(is_key_down[2]),
		.is_key_changed(is_key_changed[2]),

		.current_time(current_time),

		.is_game_over(is_game_over[2]),
		.comb(is_combo[5:4]),
		.is_miss(is_miss[2]),
		.is_bad(is_bad[2]),
		.is_good(is_good[2]),
		.is_great(is_great[2]),
		.is_perfect(is_perfect[2]),

		.RESET_L(RESET_L),
		.CLK(CLK)
	);

	wire sig_update_3_on;
	wire sig_update_3_done;
	wire [12:0] db_3_b_addr;
	wire db_3_b_en;
	wire [11:0] do_3_a_addr;
	wire [7:0] do_3_a_data_in;
	wire do_3_a_en_w;
	wire [12:0] do_3_b_addr;
	wire do_3_b_en;
	update_single_track_t update_single_track_3 (
		.sig_on(sig_update_3_on),
		.sig_done(sig_update_3_done),

		.db_b_addr(db_3_b_addr),
		.db_b_data_out(db_b_data_out),
		.db_b_en(db_3_b_en),

		.do_a_addr(do_3_a_addr),
		.do_a_data_in(do_3_a_data_in),
		.do_a_en_w(do_3_a_en_w),
		.do_b_addr(do_3_b_addr),
		.do_b_data_out(do_b_data_out),
		.do_b_en(do_3_b_en),

		.db_size(db_size_3),
		.db_base_addr(db_base_addr_3),
		.do_size(do_size_3),
		.do_base_addr(do_base_addr_3),

		.is_key_down(is_key_down[3]),
		.is_key_changed(is_key_changed[3]),

		.current_time(current_time),

		.is_game_over(is_game_over[3]),
		.comb(is_combo[7:6]),
		.is_miss(is_miss[3]),
		.is_bad(is_bad[3]),
		.is_good(is_good[3]),
		.is_great(is_great[3]),
		.is_perfect(is_perfect[3]),

		.RESET_L(RESET_L),
		.CLK(CLK)
	);

	wire sig_update_others_on;
	wire sig_update_others_done;
	update_others_t update_others_t(
		.sig_on(sig_update_others_on),
		.sig_done(sig_update_others_done),

		.dt_b_addr(dt_b_addr),
		.dt_b_data_out(dt_b_data_out),
		.dt_b_en(dt_b_en),

		.dt_size(dt_size),
		.dt_base_addr(dt_base_addr),

		.is_game_over(is_game_over),
		.is_combo(is_combo),
		.is_miss(is_miss),
		.is_bad(is_bad),
		.is_good(is_good),
		.is_great(is_great),
		.is_perfect(is_perfect),
		.song_length(song_length),

		.current_time(current_time),
		.current_pixel(current_pixel),

		.miss(miss),
		.bad(bad),
		.good(good),
		.great(great),
		.perfect(perfect),
		.combo(combo),
		.current_score(current_score),
		.current_score_fade(current_score_fade),

		.RESET_L(RESET_L),
		.CLK(CLK)
	);

	// 内存接口选通。
	always @(*) begin
		db_b_addr = 0;
		db_b_en = 0;
		do_a_addr = 0;
		do_a_data_in = 0;
		do_a_en_w = 0;
		do_b_addr = 0;
		do_b_en = 0;
		case (state)
			s_update_0, s_w_update_0: begin
				db_b_addr = db_0_b_addr;
				db_b_en = db_0_b_en;
				do_a_addr = do_0_a_addr;
				do_a_data_in = do_0_a_data_in;
				do_a_en_w = do_0_a_en_w;
				do_b_addr = do_0_b_addr;
				do_b_en = do_0_b_en;
			end
			s_update_1, s_w_update_1: begin
				db_b_addr = db_1_b_addr;
				db_b_en = db_1_b_en;
				do_a_addr = do_1_a_addr;
				do_a_data_in = do_1_a_data_in;
				do_a_en_w = do_1_a_en_w;
				do_b_addr = do_1_b_addr;
				do_b_en = do_1_b_en;
			end
			s_update_2, s_w_update_2: begin
				db_b_addr = db_2_b_addr;
				db_b_en = db_2_b_en;
				do_a_addr = do_2_a_addr;
				do_a_data_in = do_2_a_data_in;
				do_a_en_w = do_2_a_en_w;
				do_b_addr = do_2_b_addr;
				do_b_en = do_2_b_en;
			end
			s_update_3, s_w_update_3: begin
				db_b_addr = db_3_b_addr;
				db_b_en = db_3_b_en;
				do_a_addr = do_3_a_addr;
				do_a_data_in = do_3_a_data_in;
				do_a_en_w = do_3_a_en_w;
				do_b_addr = do_3_b_addr;
				do_b_en = do_3_b_en;
			end
		endcase
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
				n_state = sig_on ? s_update_0 : s_init;
			s_update_0:
				n_state = s_w_update_0;
			s_w_update_0:
				n_state = sig_update_0_done ? s_update_1 : s_w_update_0;
			s_update_1:
				n_state = s_w_update_1;
			s_w_update_1:
				n_state = sig_update_1_done ? s_update_2 : s_w_update_1;
			s_update_2:
				n_state = s_w_update_2;
			s_w_update_2:
				n_state = sig_update_2_done ? s_update_3 : s_w_update_2;
			s_update_3:
				n_state = s_w_update_3;
			s_w_update_3:
				n_state = sig_update_3_done ? s_update_others : s_w_update_3;
			s_update_others:
				n_state = s_w_update_others;
			s_w_update_others:
				n_state = sig_update_others_done ? s_done : s_w_update_others;
			s_done:
				n_state = s_init;
			default:
				n_state = s_init;
		endcase
	end

	// 输出方程。
	assign sig_update_0_on = state == s_update_0;
	assign sig_update_1_on = state == s_update_1;
	assign sig_update_2_on = state == s_update_2;
	assign sig_update_3_on = state == s_update_3;
	assign sig_update_others_on = state == s_update_others;

	assign sig_done = state == s_done;

endmodule