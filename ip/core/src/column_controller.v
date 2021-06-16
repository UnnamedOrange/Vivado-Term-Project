// Copyright (c) UnnamedOrange and Jack-Lyu. Licensed under the MIT License.
// See the LICENSE file in the repository root for full license text.

/// <projectname>mania-to-go</projectname>
/// <modulename>column_controller_t</modulename>
/// <filedescription>每列轨道数据的提供者。</filedescription>
/// <version>
/// 0.0.1 (UnnamedOrange) : First commit.
/// </version>

`timescale 1ns / 1ps

module column_controller_t #
(
	// 内部参数。
	parameter state_width = 8
)
(
	// 控制。
	input sig_refresh_on,
	output sig_refresh_done,
	input sig_next_line,

	// BRAM。
	output reg [12:0] do_b_addr,
	input [3:0] do_b_data_out,
	output reg do_b_en,

	output reg [12:0] dp_b_addr,
	input [31:0] dp_b_data_out,
	output reg dp_b_en,

	// 数量与基地址。
	input [12:0] do_size,
	input [12:0] do_base_addr,
	input [12:0] dp_size,
	input [12:0] dp_base_addr,

	// 当前像素位置（已锁定）。
	input [31:0] current_pixel,

	// 输出。
	output is_click,
	output is_slide_begin,
	output is_slide_end,
	output is_slide_space,
	output is_discarded,
	output reg [7:0] x_idx,

	// 复位与时钟。
	input RESET_L,
	input CLK
);

	// 状态定义。
	localparam [state_width - 1 : 0]
		s_init              = 8'h00, // 等待。
		s_refresh_init      = 8'h01, // 开始初始化
		s_refresh_first     = 8'h02, // 第一次读入。
		s_w_refresh_first   = 8'h03, // 等待第一次读入。
		s_refresh_done      = 8'h0f, // 刷新完成。
		s_next_line_init    = 8'h11, // 切换到下一行。
		s_unused = 8'hff;
	reg [state_width - 1 : 0] state, n_state;

	// 维护的信息。
	reg [31:0] internal_current_pixel;
	reg [12:0] object_idx[0:1];
	reg [3:0] object_info[0:1];
	reg [12:0] pixel_idx; // 只保留大的那一个。
	reg [31:0] pixel_val[0:1];
	reg is_any;

	// 刷新过程。
	wire sig_refresh_first_on;
	reg sig_refresh_first_done;
	always @(posedge CLK) begin : refresh_first_t
		reg working;
		reg [3:0] which;
		reg [1:0] pat;

		if (!RESET_L || state == s_refresh_init) begin
			internal_current_pixel <= 0;
			object_idx[0] <= 0;
			object_idx[1] <= 0;
			object_info[0] <= 0;
			object_info[1] <= 0;
			pixel_idx <= 0;
			pixel_val[0] <= 0;
			pixel_val[1] <= 0;
			is_any <= 0;

			do_b_addr <= 0;
			do_b_en <= 0;
			dp_b_addr <= 0;
			dp_b_en <= 0;

			working <= 0;
			which <= 0;
			pat <= 0;
			sig_refresh_first_done <= 0;
		end
		else begin
			if (!working) begin
				if (sig_refresh_first_on) begin
					internal_current_pixel <= current_pixel + (480 << 8);
					working <= 1;
				end
			end
			else begin
				if (pat == 0) begin
					case (which)
						0: begin
							dp_b_addr <= dp_base_addr + pixel_idx;
							dp_b_en <= 1;
						end
						1: begin
							do_b_addr <= do_base_addr + object_idx[1];
							do_b_en <= 1;
						end
						2: begin
							; // 不做。
						end
					endcase
				end
				else if (pat == 3) begin
					case (which)
						0: begin
							pixel_val[1] <= dp_b_data_out;
							dp_b_en <= 0;
							pixel_idx <= pixel_idx + 1;
						end
						1: begin
							object_info[1] <= do_b_data_out;
							do_b_en <= 0;
							if ((!is_any || object_idx[0] != object_idx[1]) && object_info[1][0]) begin
								; // 不走。
							end
							else
								object_idx[1] <= object_idx[1] + 1;

							if (pixel_val[1] >= internal_current_pixel || pixel_idx >= dp_size) begin
								; // 结束。
							end
							else begin
								is_any <= 1;
								pixel_val[0] <= pixel_val[1];
								object_idx[0] <= object_idx[1];
								object_info[0] <= object_info[1];
							end
						end
						2: begin
							; // 不做。
						end
					endcase

					if (which < 1 || which == 1 && (pixel_val[1] >= internal_current_pixel || pixel_idx >= dp_size))
						which <= which + 1;
					else if (which == 1 && !(pixel_val[1] >= internal_current_pixel || pixel_idx >= dp_size))
						which <= 0;
					else begin
						which <= 0;
						working <= 0;
					end
				end
				pat <= pat + 1;
			end

			sig_refresh_first_done <= working && which == 2 && pat == 2'b11;
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
				if (sig_refresh_on)
					n_state = s_refresh_init;
				else if (sig_next_line)
					n_state = s_next_line_init;
				else
					n_state = s_init;

			s_refresh_first:
				n_state = s_w_refresh_first;
			s_w_refresh_first:
				n_state = sig_refresh_first_done ? s_refresh_done : s_w_refresh_first;
			s_refresh_done:
				n_state = s_init;

			default:
				n_state = s_init;
		endcase
	end

	// 输出方程。
	assign sig_refresh_done = state == s_refresh_done;

	assign sig_refresh_first_on = state == s_refresh_first;

	assign is_click         = is_any && !object_info[0][1] && !object_info[0][0] && (internal_current_pixel - pixel_val[0]) < (36 << 8);
	assign is_slide_begin   = is_any && !object_info[0][1] && object_info[0][0] && (internal_current_pixel - pixel_val[0]) < (18 << 8) && (object_idx[0] == object_idx[1] && pixel_idx != dp_size);
	assign is_slide_end     = is_any && !object_info[0][1] && object_info[0][0] && (internal_current_pixel - pixel_val[0]) < (18 << 8) && !(object_idx[0] == object_idx[1] && pixel_idx != dp_size);
	assign is_slide_space   = is_any && !object_info[0][1] && object_info[0][0] && (internal_current_pixel - pixel_val[0]) >= (18 << 8) && (object_idx[0] == object_idx[1] && pixel_idx != dp_size);
	assign is_discarded     = is_any && !object_info[0][1] && object_info[0][0] && object_info[0][2];

	always @(*) begin
		x_idx = 0;
		if (is_click)
			x_idx = (pixel_val[0] + (36 << 8) - internal_current_pixel) >> 8;
		else if (is_slide_begin)
			x_idx = (pixel_val[0] + (18 << 8) - internal_current_pixel) >> 8;
		else if (is_slide_end)
			x_idx = (pixel_val[0] + (18 << 8) - internal_current_pixel) >> 8;
		else if (is_slide_space)
			x_idx = 0;
	end

endmodule