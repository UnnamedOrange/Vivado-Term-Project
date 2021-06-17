// Copyright (c) UnnamedOrange and Jack-Lyu. Licensed under the MIT License.
// See the LICENSE file in the repository root for full license text.

/// <projectname>mania-to-go</projectname>
/// <modulename>draw_controller_t</modulename>
/// <filedescription>画图需要的数据的管理器。</filedescription>
/// <version>
/// 0.0.1 (UnnamedOrange) : 定义输入输出。
/// 0.0.2 (UnnamedOrange) : 实现。
/// </version>

`timescale 1ns / 1ps

module draw_controller_t #
(
	// 内部参数。
	parameter state_width = 4
)
(
	// 控制。
	input sig_on,
	output sig_done,

	// BRAM。
	output reg [12:0] do_1_b_addr,
	input [3:0] do_1_b_data_out,
	output reg do_1_b_en,

	output reg [12:0] do_2_b_addr,
	input [3:0] do_2_b_data_out,
	output reg do_2_b_en,

	output reg [12:0] dp_b_addr,
	input [31:0] dp_b_data_out,
	output reg dp_b_en,

	output reg [14:0] ds_b_addr,
	input [15:0] ds_b_data_out,
	output reg ds_b_en,

	// 数量与基地址。
	input [12:0] do_size_0,
	input [12:0] do_size_1,
	input [12:0] do_size_2,
	input [12:0] do_size_3,
	input [12:0] do_base_addr_0,
	input [12:0] do_base_addr_1,
	input [12:0] do_base_addr_2,
	input [12:0] do_base_addr_3,
	input [12:0] dp_size_0,
	input [12:0] dp_size_1,
	input [12:0] dp_size_2,
	input [12:0] dp_size_3,
	input [12:0] dp_base_addr_0,
	input [12:0] dp_base_addr_1,
	input [12:0] dp_base_addr_2,
	input [12:0] dp_base_addr_3,

	// 键盘。
	input [3:0] is_key_down,

	// 当前位置。
	input [31:0] current_pixel,

	// 得分信息。
	input [15:0] miss,
	input [15:0] bad,
	input [15:0] good,
	input [15:0] great,
	input [15:0] perfect,

	// VGA。
	output vga_reset,
	output reg [3:0] vga_r,
	output reg [3:0] vga_g,
	output reg [3:0] vga_b,
	input [9:0] vga_x, // 行。
	input [9:0] vga_y, // 列。
	input vga_request,

	// 复位与时钟。
	input RESET_L,
	input CLK
);

	// 开始工作。
	reg is_working;
	reg is_first_frame;
	always @(posedge CLK) begin
		if (!RESET_L) begin
			is_working <= 0;
			is_first_frame <= 1;
		end
		else begin
			if (!is_working) begin
				if (sig_on) begin
					is_working <= 1;
				end
			end
			else begin
				if (sig_on) begin
					is_first_frame <= 0;
				end
			end
		end
	end

	// 显示器使能。
	assign vga_reset = !is_working;

	// 乒乓。
	reg ping_pong; // 更新 ping_pong 的，显示 !ping_pong 的。
	reg [31:0] saved_current_pixel[0:1];
	always @(posedge CLK) begin
		if (!RESET_L) begin
			ping_pong <= 0;
			saved_current_pixel[0] <= 0;
			saved_current_pixel[1] <= 0;
		end
		else begin
			if (sig_on) begin
				ping_pong <= !ping_pong;
				saved_current_pixel[!ping_pong] <= current_pixel; // 注意是 !ping_pong，因为非阻塞。
			end
		end
	end

	// 列管理器。
	wire sig_refresh_on[0:3][0:1];
	wire sig_refresh_done[0:3][0:1];
	wire sig_next_line[0:3][0:1];
	wire [12:0] do_cc_b_addr[0:3][0:1];
	wire do_cc_b_en[0:3][0:1];
	wire [12:0] dp_cc_b_addr[0:3][0:1];
	wire dp_cc_b_en[0:3][0:1];
	wire is_click[0:3][0:1];
	wire is_slide_begin[0:3][0:1];
	wire is_slide_end[0:3][0:1];
	wire is_slide_space[0:3][0:1];
	wire is_discarded[0:3][0:1];
	wire [7:0] x_idx[0:3][0:1];

	// 内存选通。
	always @(*) begin : mux_t
		integer i, j;

		do_1_b_addr = 0;
		do_1_b_en = 0;
		do_2_b_addr = 0;
		do_2_b_en = 0;
		dp_b_addr = 0;
		dp_b_en = 0;

		for (i = 0; i < 4; i = i + 1) begin
			if (do_cc_b_en[i][0]) begin
				do_1_b_addr = do_cc_b_addr[i][0];
				do_1_b_en = do_cc_b_en[i][0];
			end
			if (do_cc_b_en[i][1]) begin
				do_2_b_addr = do_cc_b_addr[i][1];
				do_2_b_en = do_cc_b_en[i][1];
			end
		end
		for (j = 0; j < 2; j = j + 1)
			for (i = 0; i < 4; i = i + 1) begin
				if (dp_cc_b_en[i][j]) begin
					dp_b_addr = dp_cc_b_addr[i][j];
					dp_b_en = dp_cc_b_en[i][j];
				end
			end
	end

	column_controller_t cc_00 (
		.sig_refresh_on(sig_refresh_on[0][0]),
		.sig_refresh_done(sig_refresh_done[0][0]),
		.sig_next_line(sig_next_line[0][0]),

		.do_b_addr(do_cc_b_addr[0][0]),
		.do_b_data_out(do_1_b_data_out),
		.do_b_en(do_cc_b_en[0][0]),

		.dp_b_addr(dp_cc_b_addr[0][0]),
		.dp_b_data_out(dp_b_data_out),
		.dp_b_en(dp_cc_b_en[0][0]),

		.do_size(do_size_0),
		.do_base_addr(do_base_addr_0),
		.dp_size(dp_size_0),
		.dp_base_addr(dp_base_addr_0),

		.current_pixel(saved_current_pixel[0]),

		.is_click(is_click[0][0]),
		.is_slide_begin(is_slide_begin[0][0]),
		.is_slide_end(is_slide_end[0][0]),
		.is_slide_space(is_slide_space[0][0]),
		.is_discarded(is_discarded[0][0]),
		.x_idx(x_idx[0][0]),

		.RESET_L(RESET_L),
		.CLK(CLK)
	);

	column_controller_t cc_01 (
		.sig_refresh_on(sig_refresh_on[0][1]),
		.sig_refresh_done(sig_refresh_done[0][1]),
		.sig_next_line(sig_next_line[0][1]),

		.do_b_addr(do_cc_b_addr[0][1]),
		.do_b_data_out(do_2_b_data_out),
		.do_b_en(do_cc_b_en[0][1]),

		.dp_b_addr(dp_cc_b_addr[0][1]),
		.dp_b_data_out(dp_b_data_out),
		.dp_b_en(dp_cc_b_en[0][1]),

		.do_size(do_size_0),
		.do_base_addr(do_base_addr_0),
		.dp_size(dp_size_0),
		.dp_base_addr(dp_base_addr_0),

		.current_pixel(saved_current_pixel[1]),

		.is_click(is_click[0][1]),
		.is_slide_begin(is_slide_begin[0][1]),
		.is_slide_end(is_slide_end[0][1]),
		.is_slide_space(is_slide_space[0][1]),
		.is_discarded(is_discarded[0][1]),
		.x_idx(x_idx[0][1]),

		.RESET_L(RESET_L),
		.CLK(CLK)
	);

	column_controller_t cc_10 (
		.sig_refresh_on(sig_refresh_on[1][0]),
		.sig_refresh_done(sig_refresh_done[1][0]),
		.sig_next_line(sig_next_line[1][0]),

		.do_b_addr(do_cc_b_addr[1][0]),
		.do_b_data_out(do_1_b_data_out),
		.do_b_en(do_cc_b_en[1][0]),

		.dp_b_addr(dp_cc_b_addr[1][0]),
		.dp_b_data_out(dp_b_data_out),
		.dp_b_en(dp_cc_b_en[1][0]),

		.do_size(do_size_1),
		.do_base_addr(do_base_addr_1),
		.dp_size(dp_size_1),
		.dp_base_addr(dp_base_addr_1),

		.current_pixel(saved_current_pixel[0]),

		.is_click(is_click[1][0]),
		.is_slide_begin(is_slide_begin[1][0]),
		.is_slide_end(is_slide_end[1][0]),
		.is_slide_space(is_slide_space[1][0]),
		.is_discarded(is_discarded[1][0]),
		.x_idx(x_idx[1][0]),

		.RESET_L(RESET_L),
		.CLK(CLK)
	);

	column_controller_t cc_11 (
		.sig_refresh_on(sig_refresh_on[1][1]),
		.sig_refresh_done(sig_refresh_done[1][1]),
		.sig_next_line(sig_next_line[1][1]),

		.do_b_addr(do_cc_b_addr[1][1]),
		.do_b_data_out(do_2_b_data_out),
		.do_b_en(do_cc_b_en[1][1]),

		.dp_b_addr(dp_cc_b_addr[1][1]),
		.dp_b_data_out(dp_b_data_out),
		.dp_b_en(dp_cc_b_en[1][1]),

		.do_size(do_size_1),
		.do_base_addr(do_base_addr_1),
		.dp_size(dp_size_1),
		.dp_base_addr(dp_base_addr_1),

		.current_pixel(saved_current_pixel[1]),

		.is_click(is_click[1][1]),
		.is_slide_begin(is_slide_begin[1][1]),
		.is_slide_end(is_slide_end[1][1]),
		.is_slide_space(is_slide_space[1][1]),
		.is_discarded(is_discarded[1][1]),
		.x_idx(x_idx[1][1]),

		.RESET_L(RESET_L),
		.CLK(CLK)
	);

	column_controller_t cc_20 (
		.sig_refresh_on(sig_refresh_on[2][0]),
		.sig_refresh_done(sig_refresh_done[2][0]),
		.sig_next_line(sig_next_line[2][0]),

		.do_b_addr(do_cc_b_addr[2][0]),
		.do_b_data_out(do_1_b_data_out),
		.do_b_en(do_cc_b_en[2][0]),

		.dp_b_addr(dp_cc_b_addr[2][0]),
		.dp_b_data_out(dp_b_data_out),
		.dp_b_en(dp_cc_b_en[2][0]),

		.do_size(do_size_2),
		.do_base_addr(do_base_addr_2),
		.dp_size(dp_size_2),
		.dp_base_addr(dp_base_addr_2),

		.current_pixel(saved_current_pixel[0]),

		.is_click(is_click[2][0]),
		.is_slide_begin(is_slide_begin[2][0]),
		.is_slide_end(is_slide_end[2][0]),
		.is_slide_space(is_slide_space[2][0]),
		.is_discarded(is_discarded[2][0]),
		.x_idx(x_idx[2][0]),

		.RESET_L(RESET_L),
		.CLK(CLK)
	);

	column_controller_t cc_21 (
		.sig_refresh_on(sig_refresh_on[2][1]),
		.sig_refresh_done(sig_refresh_done[2][1]),
		.sig_next_line(sig_next_line[2][1]),

		.do_b_addr(do_cc_b_addr[2][1]),
		.do_b_data_out(do_2_b_data_out),
		.do_b_en(do_cc_b_en[2][1]),

		.dp_b_addr(dp_cc_b_addr[2][1]),
		.dp_b_data_out(dp_b_data_out),
		.dp_b_en(dp_cc_b_en[2][1]),

		.do_size(do_size_2),
		.do_base_addr(do_base_addr_2),
		.dp_size(dp_size_2),
		.dp_base_addr(dp_base_addr_2),

		.current_pixel(saved_current_pixel[1]),

		.is_click(is_click[2][1]),
		.is_slide_begin(is_slide_begin[2][1]),
		.is_slide_end(is_slide_end[2][1]),
		.is_slide_space(is_slide_space[2][1]),
		.is_discarded(is_discarded[2][1]),
		.x_idx(x_idx[2][1]),

		.RESET_L(RESET_L),
		.CLK(CLK)
	);

	column_controller_t cc_30 (
		.sig_refresh_on(sig_refresh_on[3][0]),
		.sig_refresh_done(sig_refresh_done[3][0]),
		.sig_next_line(sig_next_line[3][0]),

		.do_b_addr(do_cc_b_addr[3][0]),
		.do_b_data_out(do_1_b_data_out),
		.do_b_en(do_cc_b_en[3][0]),

		.dp_b_addr(dp_cc_b_addr[3][0]),
		.dp_b_data_out(dp_b_data_out),
		.dp_b_en(dp_cc_b_en[3][0]),

		.do_size(do_size_3),
		.do_base_addr(do_base_addr_3),
		.dp_size(dp_size_3),
		.dp_base_addr(dp_base_addr_3),

		.current_pixel(saved_current_pixel[0]),

		.is_click(is_click[3][0]),
		.is_slide_begin(is_slide_begin[3][0]),
		.is_slide_end(is_slide_end[3][0]),
		.is_slide_space(is_slide_space[3][0]),
		.is_discarded(is_discarded[3][0]),
		.x_idx(x_idx[3][0]),

		.RESET_L(RESET_L),
		.CLK(CLK)
	);

	column_controller_t cc_31 (
		.sig_refresh_on(sig_refresh_on[3][1]),
		.sig_refresh_done(sig_refresh_done[3][1]),
		.sig_next_line(sig_next_line[3][1]),

		.do_b_addr(do_cc_b_addr[3][1]),
		.do_b_data_out(do_2_b_data_out),
		.do_b_en(do_cc_b_en[3][1]),

		.dp_b_addr(dp_cc_b_addr[3][1]),
		.dp_b_data_out(dp_b_data_out),
		.dp_b_en(dp_cc_b_en[3][1]),

		.do_size(do_size_3),
		.do_base_addr(do_base_addr_3),
		.dp_size(dp_size_3),
		.dp_base_addr(dp_base_addr_3),

		.current_pixel(saved_current_pixel[1]),

		.is_click(is_click[3][1]),
		.is_slide_begin(is_slide_begin[3][1]),
		.is_slide_end(is_slide_end[3][1]),
		.is_slide_space(is_slide_space[3][1]),
		.is_discarded(is_discarded[3][1]),
		.x_idx(x_idx[3][1]),

		.RESET_L(RESET_L),
		.CLK(CLK)
	);

	// 状态定义。
	localparam [state_width - 1 : 0]
		s_init           = 4'h0, // 等待。
		s_refresh_0      = 4'h1, // 刷新第一个。
		s_w_refresh_0    = 4'h2, // 等待刷新第一个。
		s_refresh_1      = 4'h3, // 刷新第二个。
		s_w_refresh_1    = 4'h4, // 等待刷新第二个。
		s_refresh_2      = 4'h5, // 刷新第三个。
		s_w_refresh_2    = 4'h6, // 等待刷新第三个。
		s_refresh_3      = 4'h7, // 刷新第四个。
		s_w_refresh_3    = 4'h8, // 等待刷新第四个。
		s_done           = 4'hf, // 完成。
		s_unused = 4'hf;
	reg [state_width - 1 : 0] state, n_state;

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
				n_state = sig_on ? s_refresh_0 : s_init;
			s_refresh_0:
				n_state = s_w_refresh_0;
			s_w_refresh_0:
				n_state = sig_refresh_done[0][ping_pong] ? s_refresh_1 : s_w_refresh_0;
			s_refresh_1:
				n_state = s_w_refresh_1;
			s_w_refresh_1:
				n_state = sig_refresh_done[1][ping_pong] ? s_refresh_2 : s_w_refresh_1;
			s_refresh_2:
				n_state = s_w_refresh_2;
			s_w_refresh_2:
				n_state = sig_refresh_done[2][ping_pong] ? s_refresh_3 : s_w_refresh_2;
			s_refresh_3:
				n_state = s_w_refresh_3;
			s_w_refresh_3:
				n_state = sig_refresh_done[3][ping_pong] ? s_done : s_w_refresh_3;
			s_done:
				n_state = s_init;
			default:
				n_state = s_init;
		endcase
	end

	// 输出方程。
	assign sig_done = state == s_done;
	assign sig_refresh_on[0][0] = state == s_refresh_0 && !ping_pong;
	assign sig_refresh_on[1][0] = state == s_refresh_1 && !ping_pong;
	assign sig_refresh_on[2][0] = state == s_refresh_2 && !ping_pong;
	assign sig_refresh_on[3][0] = state == s_refresh_3 && !ping_pong;
	assign sig_refresh_on[0][1] = state == s_refresh_0 && ping_pong;
	assign sig_refresh_on[1][1] = state == s_refresh_1 && ping_pong;
	assign sig_refresh_on[2][1] = state == s_refresh_2 && ping_pong;
	assign sig_refresh_on[3][1] = state == s_refresh_3 && ping_pong;

	assign sig_next_line[0][0] = vga_request && vga_y == 260 && ping_pong;
	assign sig_next_line[1][0] = vga_request && vga_y == 320 && ping_pong;
	assign sig_next_line[2][0] = vga_request && vga_y == 380 && ping_pong;
	assign sig_next_line[3][0] = vga_request && vga_y == 440 && ping_pong;
	assign sig_next_line[0][1] = vga_request && vga_y == 260 && !ping_pong;
	assign sig_next_line[1][1] = vga_request && vga_y == 320 && !ping_pong;
	assign sig_next_line[2][1] = vga_request && vga_y == 380 && !ping_pong;
	assign sig_next_line[3][1] = vga_request && vga_y == 440 && !ping_pong;

	// 颜色输出。
	parameter [14:0]
		size_digit                       = 480,
		base_addr_perfect                = 4800,
		base_addr_great                  = 6336,
		base_addr_good                   = 7872,
		base_addr_bad                    = 9408,
		base_addr_miss                   = 10944,
		base_addr_click                  = 12480,
		base_addr_slide_begin            = 14640,
		base_addr_slide_begin_discarded  = 15720,
		base_addr_slide_end              = 16800,
		base_addr_slide_end_discarded    = 17880,
		base_addr_slide_space            = 18960,
		base_addr_slide_space_discarded  = 19020,
		base_addr_down_button            = 19080,
		base_addr_up_button              = 22680;
	parameter [9:0]
		cx_sign  = 24,
		cy_sign  = 64,
		cx_digit = 24,
		cy_digit = 20;
	parameter [9:0]
		x_p  = 396,
		y_p  = 453,
		x_gr = 356,
		y_gr = 453,
		x_go = 316,
		y_go = 453,
		x_b  = 276,
		y_b  = 453,
		x_m  = 236,
		y_m  = 453;

	parameter [9:0]
		y_d = y_p + cy_sign + 10,
		y_d_interval = 3;

	reg working;
	reg [1:0] pat;
	always @(posedge CLK) begin
		if (!RESET_L) begin
			vga_r <= 0;
			vga_g <= 0;
			vga_b <= 0;

			ds_b_addr <= 0;
			ds_b_en <= 0;

			working <= 0;
			pat <= 0;
		end
		else begin
			if (vga_request) begin
				if (is_first_frame) begin // 第一帧，显示黑色。
					vga_r <= 0;
					vga_g <= 0;
					vga_b <= 0;
				end
				else begin // 正式开始显示图像。
					if (200 <= vga_y && vga_y < 260) begin // 第一列。
						if (vga_x < 420) begin // 轨道。
							if (is_click[0][!ping_pong])
								ds_b_addr <= base_addr_click + x_idx[0][!ping_pong] * 60 + (vga_y - 200);
							else if (is_slide_begin[0][!ping_pong])
								ds_b_addr <= (is_discarded[0][!ping_pong] ? base_addr_slide_begin : base_addr_slide_begin_discarded)
									+ x_idx[0][!ping_pong] * 60 + (vga_y - 200);
							else if (is_slide_end[0][!ping_pong])
								ds_b_addr <= (is_discarded[0][!ping_pong] ? base_addr_slide_end : base_addr_slide_end_discarded)
									+ x_idx[0][!ping_pong] * 60 + (vga_y - 200);
							else if (is_slide_space[0][!ping_pong])
								ds_b_addr <= (is_discarded[0][!ping_pong] ? base_addr_slide_space : base_addr_slide_space_discarded)
									+ x_idx[0][!ping_pong] * 60 + (vga_y - 200);
							else
								ds_b_addr <= 0;
						end
						else begin // 按键指示。
							if (is_key_down[0])
								ds_b_addr <= base_addr_down_button + (vga_x - 420) * 60 + (vga_y - 200);
							else
								ds_b_addr <= base_addr_up_button + (vga_x - 420) * 60 + (vga_y - 200);
						end
					end
					else if (260 <= vga_y && vga_y < 320) begin // 第二列。
						if (vga_x < 420) begin // 轨道。
							if (is_click[1][!ping_pong])
								ds_b_addr <= base_addr_click + x_idx[1][!ping_pong] * 60 + (vga_y - 260);
							else if (is_slide_begin[1][!ping_pong])
								ds_b_addr <= (is_discarded[1][!ping_pong] ? base_addr_slide_begin : base_addr_slide_begin_discarded)
									+ x_idx[1][!ping_pong] * 60 + (vga_y - 260);
							else if (is_slide_end[1][!ping_pong])
								ds_b_addr <= (is_discarded[1][!ping_pong] ? base_addr_slide_end : base_addr_slide_end_discarded)
									+ x_idx[1][!ping_pong] * 60 + (vga_y - 260);
							else if (is_slide_space[1][!ping_pong])
								ds_b_addr <= (is_discarded[1][!ping_pong] ? base_addr_slide_space : base_addr_slide_space_discarded)
									+ x_idx[1][!ping_pong] * 60 + (vga_y - 260);
							else
								ds_b_addr <= 0;
						end
						else begin // 按键指示。
							if (is_key_down[1])
								ds_b_addr <= base_addr_down_button + (vga_x - 420) * 60 + (vga_y - 260);
							else
								ds_b_addr <= base_addr_up_button + (vga_x - 420) * 60 + (vga_y - 260);
						end
					end
					else if (320 <= vga_y && vga_y < 380) begin // 第三列。
						if (vga_x < 420) begin // 轨道。
							if (is_click[2][!ping_pong])
								ds_b_addr <= base_addr_click + x_idx[2][!ping_pong] * 60 + (vga_y - 320);
							else if (is_slide_begin[2][!ping_pong])
								ds_b_addr <= (is_discarded[2][!ping_pong] ? base_addr_slide_begin : base_addr_slide_begin_discarded)
									+ x_idx[2][!ping_pong] * 60 + (vga_y - 320);
							else if (is_slide_end[2][!ping_pong])
								ds_b_addr <= (is_discarded[2][!ping_pong] ? base_addr_slide_end : base_addr_slide_end_discarded)
									+ x_idx[2][!ping_pong] * 60 + (vga_y - 320);
							else if (is_slide_space[2][!ping_pong])
								ds_b_addr <= (is_discarded[2][!ping_pong] ? base_addr_slide_space : base_addr_slide_space_discarded)
									+ x_idx[2][!ping_pong] * 60 + (vga_y - 320);
							else
								ds_b_addr <= 0;
						end
						else begin // 按键指示。
							if (is_key_down[2])
								ds_b_addr <= base_addr_down_button + (vga_x - 420) * 60 + (vga_y - 320);
							else
								ds_b_addr <= base_addr_up_button + (vga_x - 420) * 60 + (vga_y - 320);
						end
					end
					else if (380 <= vga_y && vga_y < 440) begin // 第四列。
						if (vga_x < 420) begin // 轨道。
							if (is_click[3][!ping_pong])
								ds_b_addr <= base_addr_click + x_idx[3][!ping_pong] * 60 + (vga_y - 380);
							else if (is_slide_begin[3][!ping_pong])
								ds_b_addr <= (is_discarded[3][!ping_pong] ? base_addr_slide_begin : base_addr_slide_begin_discarded)
									+ x_idx[3][!ping_pong] * 60 + (vga_y - 380);
							else if (is_slide_end[3][!ping_pong])
								ds_b_addr <= (is_discarded[3][!ping_pong] ? base_addr_slide_end : base_addr_slide_end_discarded)
									+ x_idx[3][!ping_pong] * 60 + (vga_y - 380);
							else if (is_slide_space[3][!ping_pong])
								ds_b_addr <= (is_discarded[3][!ping_pong] ? base_addr_slide_space : base_addr_slide_space_discarded)
									+ x_idx[3][!ping_pong] * 60 + (vga_y - 380);
							else
								ds_b_addr <= 0;
						end
						else begin // 按键指示。
							if (is_key_down[3])
								ds_b_addr <= base_addr_down_button + (vga_x - 420) * 60 + (vga_y - 380);
							else
								ds_b_addr <= base_addr_up_button + (vga_x - 420) * 60 + (vga_y - 380);
						end
					end
					else if (x_p <= vga_x && vga_x < x_p + cx_sign &&
							y_p <= vga_y && vga_y < y_p + cy_sign)
						ds_b_addr <= base_addr_perfect + (vga_x - x_p) * cy_sign + (vga_y - y_p); // 计分处的 perfect。
					else if (x_gr <= vga_x && vga_x < x_gr + cx_sign &&
							y_gr <= vga_y && vga_y < y_gr + cy_sign)
						ds_b_addr <= base_addr_great + (vga_x - x_gr) * cy_sign + (vga_y - y_gr); // 计分处的 great。
					else if (x_go <= vga_x && vga_x < x_go + cx_sign &&
							y_go <= vga_y && vga_y < y_go + cy_sign)
						ds_b_addr <= base_addr_good + (vga_x - x_go) * cy_sign + (vga_y - y_go); // 计分处的 good。
					else if (x_b <= vga_x && vga_x < x_b + cx_sign &&
							y_b <= vga_y && vga_y < y_b + cy_sign)
						ds_b_addr <= base_addr_bad + (vga_x - x_b) * cy_sign + (vga_y - y_b); // 计分处的 bad。
					else if (x_m <= vga_x && vga_x < x_m + cx_sign &&
							y_m <= vga_y && vga_y < y_m + cy_sign)
						ds_b_addr <= base_addr_miss + (vga_x - x_m) * cy_sign + (vga_y - y_m); // 计分处的 miss。
					else begin : digit_t
						integer i;

						ds_b_addr <= 0; // 待验证的写法。
						for (i = 0; i < 4; i = i + 1) begin
							if (x_p <= vga_x && vga_x < x_p + cx_sign &&
								y_d + i * (y_d_interval + cy_digit) <= vga_y && vga_y < y_d + i * (y_d_interval + cy_digit) + cy_digit)
								ds_b_addr <= perfect[(3 - i) * 4 +: 4] * size_digit + (vga_x - x_p) * cy_digit + (vga_y - (y_d + i * (y_d_interval + cy_digit)));
						end
						for (i = 0; i < 4; i = i + 1) begin
							if (x_gr <= vga_x && vga_x < x_gr + cx_sign &&
								y_d + i * (y_d_interval + cy_digit) <= vga_y && vga_y < y_d + i * (y_d_interval + cy_digit) + cy_digit)
								ds_b_addr <= great[(3 - i) * 4 +: 4] * size_digit + (vga_x - x_gr) * cy_digit + (vga_y - (y_d + i * (y_d_interval + cy_digit)));
						end
						for (i = 0; i < 4; i = i + 1) begin
							if (x_go <= vga_x && vga_x < x_go + cx_sign &&
								y_d + i * (y_d_interval + cy_digit) <= vga_y && vga_y < y_d + i * (y_d_interval + cy_digit) + cy_digit)
								ds_b_addr <= good[(3 - i) * 4 +: 4] * size_digit + (vga_x - x_go) * cy_digit + (vga_y - (y_d + i * (y_d_interval + cy_digit)));
						end
						for (i = 0; i < 4; i = i + 1) begin
							if (x_b <= vga_x && vga_x < x_b + cx_sign &&
								y_d + i * (y_d_interval + cy_digit) <= vga_y && vga_y < y_d + i * (y_d_interval + cy_digit) + cy_digit)
								ds_b_addr <= bad[(3 - i) * 4 +: 4] * size_digit + (vga_x - x_b) * cy_digit + (vga_y - (y_d + i * (y_d_interval + cy_digit)));
						end
						for (i = 0; i < 4; i = i + 1) begin
							if (x_m <= vga_x && vga_x < x_m + cx_sign &&
								y_d + i * (y_d_interval + cy_digit) <= vga_y && vga_y < y_d + i * (y_d_interval + cy_digit) + cy_digit)
								ds_b_addr <= miss[(3 - i) * 4 +: 4] * size_digit + (vga_x - x_m) * cy_digit + (vga_y - (y_d + i * (y_d_interval + cy_digit)));
						end
					end

					ds_b_en <= 1;
					working <= 1;
					pat <= 1;
				end
			end
			if (working) begin // 读取内存的后续事宜。
				if (pat == 3) begin
					vga_r <= ds_b_data_out[3:0];
					vga_g <= ds_b_data_out[7:4];
					vga_b <= ds_b_data_out[11:8];
					ds_b_en <= 0;
					working <= 0;
				end
				pat <= pat + 1;
			end
		end
	end

endmodule