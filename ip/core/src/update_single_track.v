// Copyright (c) UnnamedOrange and Jack-Lyu. Licensed under the MIT License.
// See the LICENSE file in the repository root for full license text.

/// <projectname>mania-to-go</projectname>
/// <modulename>update_single_track_t</modulename>
/// <filedescription>单条轨道 update 管理器。</filedescription>
/// <version>
/// 0.0.1 (UnnamedOrange) : 定义输入输出。
/// 0.0.2 (UnnamedOrange) : 代码非常稳定，不要随便修改。
/// </version>

`timescale 1ns / 1ps

module update_single_track_t #
(
	// 内部参数。
	parameter state_width = 8
)
(
	// 控制。
	input sig_on,       // 收到 sig_on 时开始工作。
	output reg sig_done,    // 工作结束后发送 sig_done。

	// BRAM。端口 a 是写端口，端口 b 是读端口。
	// beatmap（对象时间点）
	output reg [12:0] db_b_addr,
	input [23:0] db_b_data_out,
	output reg db_b_en,

	// object（对象）
	output [11:0] do_a_addr,
	output [7:0] do_a_data_in,
	output do_a_en_w,
	output reg [12:0] do_b_addr,
	input [3:0] do_b_data_out,
	output reg do_b_en,

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
	output reg [1:0] comb,
	output reg is_miss,
	output reg is_bad,
	output reg is_good,
	output reg is_great,
	output reg is_perfect,

	// 复位与时钟。
	input RESET_L,
	input CLK
);

	// 维护的信息。
	reg [12:0] object_idx[0:1];
	reg [3:0] object_info[0:1];
	reg [12:0] beatmap_idx;
	reg [19:0] beatmap_val[0:1];
	reg is_end;
	reg is_any;

	// 组合变量。
	wire is_click;
	assign is_click = !object_info[0][0];
	wire is_slide_begin;
	assign is_slide_begin = object_info[0][0] && object_idx[0] == object_idx[1];
	wire is_slide_end;
	assign is_slide_end = !is_click && !is_slide_begin;

	wire too_early;
	wire too_late;
	wire in_perfect;
	wire in_great;
	wire in_good;
	wire in_bad;
	wire in_miss;
	time_judge_t time_judge(
		.current_time(current_time),
		.object_time(beatmap_val[0]),

		.too_early(too_early),
		.too_late(too_late),
		.in_perfect(in_perfect),
		.in_great(in_great),
		.in_good(in_good),
		.in_bad(in_bad),
		.in_miss(in_miss)
	);

	// 写回助手。
	reg sig_write_on;
	wire sig_write_done; // 未使用。
	wire [12:0] do_write_b_addr;
	wire do_write_b_en;
	write_object_t write_object(
		.sig_on(sig_write_on),
		.sig_done(sig_write_done),

		.data_in(object_info[0]),
		.addr_to_write(do_base_addr + object_idx[0]),

		.do_a_addr(do_a_addr),
		.do_a_data_in(do_a_data_in),
		.do_a_en_w(do_a_en_w),
		.do_b_addr(do_write_b_addr),
		.do_b_data_out(do_b_data_out),
		.do_b_en(do_write_b_en),

		.RESET_L(RESET_L),
		.CLK(CLK)
	);

	reg [12:0] do_read_b_addr;
	reg do_read_b_en;

	// 内存选通。
	always @(*) begin
		do_b_addr = 0;
		do_b_en = 0;
		if (do_write_b_en) begin
			do_b_addr = do_write_b_addr;
			do_b_en = do_write_b_en;
		end
		else if (do_read_b_en) begin
			do_b_addr = do_read_b_addr;
			do_b_en = do_read_b_en;
		end
	end

	// which 状态。
	parameter [state_width - 1 : 0]
		s_first           = 8'h00, // 首次读入时将前两个读进来（第一个）。
		s_second          = 8'h01, // 首次读入时将前两个读进来（第二个）。
		s_0               = 8'h02, // 分支 0。
		s_1               = 8'h03, // 分支 1。
		s_2               = 8'h04, // 分支 2。
		s_3               = 8'h05, // 分支 3。
		s_4               = 8'h06, // 分支 4。
		s_5               = 8'h07, // 分支 5。
		s_6               = 8'h08, // 分支 6。
		s_7               = 8'h09, // 分支 7。
		s_w_write_only    = 8'hfb, // 等待写回。
		s_w_write         = 8'hfc, // 等待写回，之后读。
		s_read            = 8'hfd, // 更新下一个时间点。
		s_no_update       = 8'hfe, // 不更新。
		s_done            = 8'hff, // 完成。
		s_unused = 8'hff;
	reg [state_width - 1 : 0] which;

	// 第一步转移。
	reg [state_width - 1 : 0] step;
	always @(*) begin
		step = s_no_update; // 等效于 return 时啥也不做。
		if (is_end)
			step = s_no_update;
		else begin
			if (is_key_changed) begin
				if (is_key_down) begin
					if (is_click) begin
						if (too_early)
							step = s_no_update;
						else
							step = s_0;
					end
					else if (is_slide_begin) begin
						if (too_early)
							step = s_no_update;
						else begin
							if (in_miss)
								step = s_1;
							else
								step = s_2;
						end
					end
					else // is_slide_end
						step = s_no_update;
				end
				else begin
					if (is_click)
						step = s_no_update;
					else if (is_slide_begin)
						step = s_no_update;
					else begin // is_slide_end
						if (too_early)
							step = s_3;
						else
							step = s_4;
					end
				end
			end
			else begin // !is_key_changed
				if (is_click) begin
					if (too_late)
						step = s_5;
				end
				else if (is_slide_begin) begin
					if (too_late)
						step = s_6;
				end
				else if (is_slide_end) begin
					if (too_late)
						step = s_7;
				end
			end
		end
	end

	// 刷新过程。
	reg working;
	reg [1:0] pat;
	reg [1:0] waiting;
	always @(posedge CLK) begin
		if (!RESET_L) begin
			comb <= 0;
			is_miss <= 0;
			is_bad <= 0;
			is_good <= 0;
			is_great <= 0;
			is_perfect <= 0;

			object_idx[0] <= 0;
			object_idx[1] <= 0;
			object_info[0] <= 0;
			object_info[1] <= 0;
			beatmap_idx <= 0;
			beatmap_val[0] <= 0;
			beatmap_val[1] <= 0;
			is_end <= 0;
			is_any <= 0;

			db_b_addr <= 0;
			db_b_en <= 0;
			do_read_b_addr <= 0;
			do_read_b_en <= 0;

			sig_done <= 0;

			working <= 0;
			which <= 0;
			pat <= 0;
			waiting <= 0;
		end
		else begin
			if (!working) begin
				if (sig_on) begin
					working <= 1;
					if (!is_any)
						which <= s_first;
					else
						which <= step;
				end
			end
			else begin
				if (pat == 0) begin
					case (which)
						s_first: begin
							db_b_addr <= db_base_addr;
							db_b_en <= 1;
							do_read_b_addr <= do_base_addr;
							do_read_b_en <= 1;
						end
						s_second: begin
							db_b_addr <= db_base_addr + 1;
							db_b_en <= 1;
							do_read_b_addr <= do_base_addr + (!object_info[0][0]);
							do_read_b_en <= 1;
							beatmap_idx <= 2;
							object_idx[1] <= !object_info[0][0];
						end

						s_0: begin
							comb <= in_miss ? 2'b10 : 2'b01;
							is_miss <= in_miss;
							is_bad <= in_bad;
							is_good <= in_good;
							is_great <= in_great;
							is_perfect <= in_perfect;
							object_info[0][1] <= 1;
							sig_write_on <= 1;
						end
						s_1: begin
							comb <= 2'b10;
							is_miss <= in_miss;
							is_bad <= in_bad;
							is_good <= in_good;
							is_great <= in_great;
							is_perfect <= in_perfect;
							object_info[0][2] <= 1;
							sig_write_on <= 1;
						end
						s_2: begin
							comb <= 2'b01;
							is_miss <= in_miss;
							is_bad <= in_bad;
							is_good <= in_good;
							is_great <= in_great;
							is_perfect <= in_perfect;
						end
						s_3: begin
							comb <= 2'b10;
							is_miss <= 0;
							is_bad <= 0;
							is_good <= 0;
							is_great <= 0;
							is_perfect <= 0;
							object_info[0][2] <= 1;
							sig_write_on <= 1;
						end
						s_4: begin
							comb <= in_miss ? 2'b10 : 2'b01;
							is_miss <= in_miss;
							is_bad <= object_info[0][2] ? (is_bad || is_good || is_great || is_perfect) : in_bad;
							is_good <= object_info[0][2] ? 0 : in_good;
							is_great <= object_info[0][2] ? 0 : in_great;
							is_perfect <= object_info[0][2] ? 0 : in_perfect;
							object_info[0][1] <= 1;
							sig_write_on <= 1;
						end
						s_5: begin
							comb <= 2'b10;
							is_miss <= 1;
							is_bad <= 0;
							is_good <= 0;
							is_great <= 0;
							is_perfect <= 0;
							object_info[0][1] <= 1;
							sig_write_on <= 1;
						end
						s_6: begin
							comb <= 2'b10;
							is_miss <= 1;
							is_bad <= 0;
							is_good <= 0;
							is_great <= 0;
							is_perfect <= 0;
							object_info[0][2] <= 1;
							sig_write_on <= 1;
						end
						s_7: begin
							comb <= 2'b10;
							is_miss <= 1;
							is_bad <= 0;
							is_good <= 0;
							is_great <= 0;
							is_perfect <= 0;
							object_info[0][1] <= 1;
							sig_write_on <= 1;
						end

						s_read: begin
							object_idx[0] <= object_idx[1];
							object_info[0] <= object_info[1];
							beatmap_val[0] <= beatmap_val[1];
							is_end <= beatmap_idx > db_size;

							object_idx[1] <= object_idx[1] + !(object_info[1][0] && object_idx[0] != object_idx[1]);
							beatmap_idx <= beatmap_idx + 1;

							db_b_addr <= db_base_addr + beatmap_idx;
							db_b_en <= 1;
							do_read_b_addr <= do_base_addr + object_idx[1] + !(object_info[1][0] && object_idx[0] != object_idx[1]);
							do_read_b_en <= 1;
						end

						s_no_update: begin
							comb <= 0;
							is_miss <= 0;
							is_bad <= 0;
							is_good <= 0;
							is_great <= 0;
							is_perfect <= 0;
						end
					endcase
				end
				else if (pat == 3) begin
					case (which)
						s_first: begin
							beatmap_val[0] <= db_b_data_out;
							object_info[0] <= do_b_data_out;
							db_b_en <= 0;
							do_read_b_en <= 0;
							which <= s_second;
						end
						s_second: begin
							beatmap_val[1] <= db_b_data_out;
							object_info[1] <= do_b_data_out;
							db_b_en <= 0;
							do_read_b_en <= 0;
							which <= step;
							is_any <= 1;
						end

						s_2: begin
							which <= s_read;
						end
						s_3: begin
							sig_write_on <= 0;
							waiting <= 0;
							which <= s_w_write_only;
						end
						s_0, s_1, s_4, s_5, s_6, s_7: begin
							sig_write_on <= 0;
							waiting <= 0;
							which <= s_w_write;
						end

						s_w_write_only: begin
							waiting <= waiting + 1;
							if (waiting == 3)
								which <= s_done;
						end
						s_w_write: begin
							waiting <= waiting + 1;
							if (waiting == 3)
								which <= s_read;
						end
						s_read: begin
							beatmap_val[1] <= db_b_data_out;
							object_info[1] <= do_b_data_out;
							db_b_en <= 0;
							do_read_b_en <= 0;
							which <= s_done;
						end

						s_no_update: begin
							which <= s_done;
						end
						s_done: begin
							working <= 0;
						end
					endcase
				end
				pat <= pat + 1;
			end
			sig_done <= working && which == s_done && pat == 3;
		end
	end

	// 输出方程。
	assign is_game_over = is_end;

endmodule