// Copyright (c) UnnamedOrange and Jack-Lyu. Licensed under the MIT License.
// See the LICENSE file in the repository root for full license text.

/// <projectname>mania-to-go</projectname>
/// <modulename>core_t</modulename>
/// <filedescription>核心模块。</filedescription>
/// <version>
/// 0.0.1 (UnnamedOrange and Jack-Lyu) : First commit.
/// 0.0.2 (UnnamedOrange) : 实现 BRAM 的初始化。
/// </version>

`timescale 1ns / 1ps

module core_t #
(
	// SD 卡模块。
	parameter pre_data_width = 8,
	parameter song_data_width = 8,

	// 内部参数。
	parameter state_width = 16
)
(
	// 调试。
	output [15:0] DEBUG_CURRENT_STATE,

	// 直连的 BRAM。
	// .beatmap (db) 对应 BRAM。
	output [12:0] db_addr_w,
	output [23:0] db_data_in,
	output db_en_w,
	output reg [12:0] db_addr_r,
	input [23:0] db_data_out,
	output reg db_en_r,

	// .object (do) 对应 BRAM。
	output [11:0] do_addr_w,
	output [7:0] do_data_in,
	output do_en_w,
	output reg [12:0] do_addr_r,
	input [3:0] do_data_out,
	output reg do_en_r,

	// .pixel (dp) 对应 BRAM。
	output [12:0] dp_addr_w,
	output [31:0] dp_data_in,
	output dp_en_w,
	output reg [12:0] dp_addr_r,
	input [31:0] dp_data_out,
	output reg dp_en_r,

	// .timing (dt) 对应 BRAM。
	output [11:0] dt_addr_w,
	output [31:0] dt_data_in,
	output dt_en_w,
	output reg [11:0] dt_addr_r,
	input [31:0] dt_data_out,
	output reg dt_en_r,

	// .skin (ds) 对应 BRAM。
	output [14:0] ds_addr_w,
	output [15:0] ds_data_in,
	output ds_en_w,
	output reg [14:0] ds_addr_r,
	input [15:0] ds_data_out,
	output reg ds_en_r,

	// 选歌开关。
	input [7:0] song_selection, // 假设不变。

	// 预读取数据用的 SD 卡模块。
	output reg [7:0] pre_init_index,
	output reg [7:0] pre_init_aux_info,
	input [pre_data_width - 1 : 0] pre_data_in,
	input pre_data_ready,
	input pre_transmit_finished,
	output reg pre_request_data,
	output reg pre_restart,

	// 读取歌曲的 SD 卡模块。
	output [7:0] song_init_index,
	output [7:0] song_init_aux_info,
	input [song_data_width - 1 : 0] song_data_in,
	input song_data_ready,
	input song_transmit_finished,
	output song_request_data,
	output song_restart,

	// 键盘模块。
	input [3:0] IS_KEY_DOWN,
	input [3:0] IS_KEY_CHANGED,

	// 音频模块。
	output [song_data_width - 1 : 0] MAIN_AUDIO_OUT,
	output MAIN_AUDIO_EN,
	output [3:0] MAIN_AUDIO_VOLUMN,
	output [song_data_width - 1 : 0] AUX_AUDIO_OUT,
	output AUX_AUDIO_EN,
	output [3:0] AUX_AUDIO_VOLUMN,
	output AUDIO_EN,

	// VGA 模块。
	output [0:0] DATA_TODO, // TODO

	// 复位与时钟。
	input RESET_L,
	input CLK
);

	/* 状态定义。*/
	localparam [state_width - 1 : 0] // 使用 BCD 码进行编码。
		s_init                      = 16'h0000, // 复位。
		s_load_skin                 = 16'h0001, // 加载 .skin 到 BRAM。
		s_w_load_skin               = 16'h0002, // 等待加载 .skin 到 BRAM。
		s_load_beatmap_0            = 16'h0003, // 加载 .beatmap 到 BRAM。
		s_w_load_beatmap_0          = 16'h0004, // 等待加载 .beatmap 到 BRAM。
		s_load_beatmap_1            = 16'h0005, // 加载 .object 到 BRAM。
		s_w_load_beatmap_1          = 16'h0006, // 等待加载 .object 到 BRAM。
		s_load_beatmap_2            = 16'h0007, // 加载 .pixel 到 BRAM。
		s_w_load_beatmap_2          = 16'h0008, // 等待加载 .pixel 到 BRAM。
		s_load_beatmap_3            = 16'h0009, // 加载 .timing 到 BRAM。
		s_w_load_beatmap_3          = 16'h0010, // 等待加载 .timing 到 BRAM。
		s_reset_cpu_song            = 16'h0011, // 重置 CPU 到歌曲播放。
		s_w_reset_cpu_song          = 16'h0012, // 等待重置 CPU 到歌曲播放。
		s_get_base_addr_0           = 16'h0013, // 获取 .beatmap 的各个基地址。
		s_w_get_base_addr_0         = 16'h0014, // 等待获取 .beatmap 的各个基地址和数量。
		s_get_base_addr_1           = 16'h0015, // 获取 .object 的各个基地址和数量。
		s_w_get_base_addr_1         = 16'h0016, // 等待获取 .object 的各个基地址和数量。
		s_get_base_addr_2           = 16'h0017, // 获取 .pixel 的各个基地址和数量。
		s_w_get_base_addr_2         = 16'h0018, // 等待获取 .pixel 的各个基地址和数量。
		s_get_base_addr_3           = 16'h0019, // 获取 .timing 的各个基地址和数量。
		s_w_get_base_addr_3         = 16'h0020, // 等待获取 .timing 的各个基地址和数量。
		s_system_clock_on           = 16'h0100, // 游戏开始。全局时钟开始运行。
		s_system_clock_pause        = 16'h0101, // 游戏暂停。各时钟停止运行（保留）。
		s_standby                   = 16'h9999, // 游戏结束，不做其他事（暂时保留）。
		s_unused = 16'hffff;
	reg [state_width - 1 : 0] state, n_state;

	/* 关键变量。*/
	reg [12:0] db_size[0:3];
	reg [12:0] db_base_addr[0:3];
	reg [12:0] do_size[0:3];
	reg [12:0] do_base_addr[0:3];
	reg [12:0] dp_size[0:3]; // == db_size
	reg [12:0] dp_base_addr[0:3];
	reg [11:0] dt_size;
	reg [11:0] dt_base_addr; // == 2
	reg [19:0] song_length;

	/* 模块互联与信号量。*/
	// BRAM。
	wire sig_db_on;
	wire sig_db_done;
	wire [7:0] db_pre_init_index;
	wire [7:0] db_pre_init_aux_info;
	wire db_pre_request_data;
	wire db_pre_restart;
	bram_data_loader_t #
	(
		.addr_width(13),
		.data_width_in_byte(3),
		.static_init_aux_info(8'b00000000)
	) bram_data_loader_db
	(
		.bram_addr_w(db_addr_w),
		.bram_data_in(db_data_in),
		.bram_en_w(db_en_w),
		.sig_on(sig_db_on),
		.sig_done(sig_db_done),
		.restart(db_pre_restart),
		.init_index(db_pre_init_index),
		.init_aux_info(db_pre_init_aux_info),
		.request_data(db_pre_request_data),
		.data_ready(pre_data_ready),
		.cpu_data_in(pre_data_in),
		.transmit_finished(pre_transmit_finished),
		.song_selection(song_selection),
		.RESET_L(RESET_L),
		.CLK(CLK)
	);

	wire sig_do_on;
	wire sig_do_done;
	wire [7:0] do_pre_init_index;
	wire [7:0] do_pre_init_aux_info;
	wire do_pre_request_data;
	wire do_pre_restart;
	bram_data_loader_t #
	(
		.addr_width(12),
		.data_width_in_byte(1),
		.static_init_aux_info(8'b00000001)
	) bram_data_loader_do
	(
		.bram_addr_w(do_addr_w),
		.bram_data_in(do_data_in),
		.bram_en_w(do_en_w),
		.sig_on(sig_do_on),
		.sig_done(sig_do_done),
		.restart(do_pre_restart),
		.init_index(do_pre_init_index),
		.init_aux_info(do_pre_init_aux_info),
		.request_data(do_pre_request_data),
		.data_ready(pre_data_ready),
		.cpu_data_in(pre_data_in),
		.transmit_finished(pre_transmit_finished),
		.song_selection(song_selection),
		.RESET_L(RESET_L),
		.CLK(CLK)
	);

	wire sig_dp_on;
	wire sig_dp_done;
	wire [7:0] dp_pre_init_index;
	wire [7:0] dp_pre_init_aux_info;
	wire dp_pre_request_data;
	wire dp_pre_restart;
	bram_data_loader_t #
	(
		.addr_width(13),
		.data_width_in_byte(4),
		.static_init_aux_info(8'b00000010)
	) bram_data_loader_dp
	(
		.bram_addr_w(dp_addr_w),
		.bram_data_in(dp_data_in),
		.bram_en_w(dp_en_w),
		.sig_on(sig_dp_on),
		.sig_done(sig_dp_done),
		.restart(dp_pre_restart),
		.init_index(dp_pre_init_index),
		.init_aux_info(dp_pre_init_aux_info),
		.request_data(dp_pre_request_data),
		.data_ready(pre_data_ready),
		.cpu_data_in(pre_data_in),
		.transmit_finished(pre_transmit_finished),
		.song_selection(song_selection),
		.RESET_L(RESET_L),
		.CLK(CLK)
	);

	wire sig_dt_on;
	wire sig_dt_done;
	wire [7:0] dt_pre_init_index;
	wire [7:0] dt_pre_init_aux_info;
	wire dt_pre_request_data;
	wire dt_pre_restart;
	bram_data_loader_t #
	(
		.addr_width(12),
		.data_width_in_byte(4),
		.static_init_aux_info(8'b00000011)
	) bram_data_loader_dt
	(
		.bram_addr_w(dt_addr_w),
		.bram_data_in(dt_data_in),
		.bram_en_w(dt_en_w),
		.sig_on(sig_dt_on),
		.sig_done(sig_dt_done),
		.restart(dt_pre_restart),
		.init_index(dt_pre_init_index),
		.init_aux_info(dt_pre_init_aux_info),
		.request_data(dt_pre_request_data),
		.data_ready(pre_data_ready),
		.cpu_data_in(pre_data_in),
		.transmit_finished(pre_transmit_finished),
		.song_selection(song_selection),
		.RESET_L(RESET_L),
		.CLK(CLK)
	);

	wire sig_ds_on;
	wire sig_ds_done;
	wire [7:0] ds_pre_init_index;
	wire [7:0] ds_pre_init_aux_info;
	wire ds_pre_request_data;
	wire ds_pre_restart;
	bram_data_loader_t #
	(
		.addr_width(15),
		.data_width_in_byte(2),
		.static_init_aux_info(8'b10000000)
	) bram_data_loader_ds
	(
		.bram_addr_w(ds_addr_w),
		.bram_data_in(ds_data_in),
		.bram_en_w(ds_en_w),
		.sig_on(sig_ds_on),
		.sig_done(sig_ds_done),
		.restart(ds_pre_restart),
		.init_index(ds_pre_init_index),
		.init_aux_info(ds_pre_init_aux_info),
		.request_data(ds_pre_request_data),
		.data_ready(pre_data_ready),
		.cpu_data_in(pre_data_in),
		.transmit_finished(pre_transmit_finished),
		.song_selection(song_selection),
		.RESET_L(RESET_L),
		.CLK(CLK)
	);

	// 选通 pre_cpu。
	always @(*) begin
		case (state)
			s_load_skin,
			s_w_load_skin: begin
				pre_init_index =    ds_pre_init_index;
				pre_init_aux_info = ds_pre_init_aux_info;
				pre_request_data =  ds_pre_request_data;
				pre_restart =       ds_pre_restart;
			end
			s_load_beatmap_0,
			s_w_load_beatmap_0:
			begin
				pre_init_index =    db_pre_init_index;
				pre_init_aux_info = db_pre_init_aux_info;
				pre_request_data =  db_pre_request_data;
				pre_restart =       db_pre_restart;
			end
			s_load_beatmap_1,
			s_w_load_beatmap_1:
			begin
				pre_init_index =    do_pre_init_index;
				pre_init_aux_info = do_pre_init_aux_info;
				pre_request_data =  do_pre_request_data;
				pre_restart =       do_pre_restart;
			end
			s_load_beatmap_2,
			s_w_load_beatmap_2: begin
				pre_init_index =    dp_pre_init_index;
				pre_init_aux_info = dp_pre_init_aux_info;
				pre_request_data =  dp_pre_request_data;
				pre_restart =       dp_pre_restart;
			end
			s_load_beatmap_3,
			s_w_load_beatmap_3: begin
				pre_init_index =    dt_pre_init_index;
				pre_init_aux_info = dt_pre_init_aux_info;
				pre_request_data =  dt_pre_request_data;
				pre_restart =       dt_pre_restart;
			end
			default: begin
				pre_init_index =    0;
				pre_init_aux_info = 0;
				pre_request_data =  0;
				pre_restart =       0;
			end
		endcase
	end

	// reset_cpu_song。
	wire sig_reset_cpu_song_on;
	wire sig_reset_cpu_song_done;
	song_data_loader_t song_data_loader
	(
		.song_init_index(song_init_index),
		.song_init_aux_info(song_init_aux_info),
		.song_restart(song_restart),
		.song_selection(song_selection),
		.sig_on(sig_reset_cpu_song_on),
		.sig_done(sig_reset_cpu_song_done),
		.RESET_L(RESET_L),
		.CLK(CLK)
	);

	// get_base_addr。
	wire sig_get_base_addr_0_on;
	reg sig_get_base_addr_0_done;
	wire sig_get_base_addr_1_on;
	reg sig_get_base_addr_1_done;
	wire sig_get_base_addr_2_on;
	reg sig_get_base_addr_2_done;
	wire sig_get_base_addr_3_on;
	reg sig_get_base_addr_3_done;

	reg [12:0] init_db_addr_r;
	reg init_db_en_r;
	always @(*) begin
		if (state == s_get_base_addr_0 || state == s_w_get_base_addr_0) begin
			db_addr_r = init_db_addr_r;
			db_en_r = init_db_en_r;
		end
		else begin
			// TODO
		end
	end

	always @(posedge CLK) begin: get_base_addr_0_t
		integer i;
		reg [2:0] which;
		reg [1:0] pat;

		if (!RESET_L) begin
			for (i = 0; i < 4; i = i + 1)
				db_size[i] <= 0;
			for (i = 0; i < 4; i = i + 1)
				db_base_addr[i] <= 0;
			sig_get_base_addr_0_done <= 0;
			which <= 0;
			pat <= 0;
			init_db_en_r <= 0;
			init_db_addr_r <= 0;
		end
		else begin
			if (!which[2]) begin
				if (sig_get_base_addr_0_on)
					which[2] <= 1;
			end
			else begin
				if (pat == 0) begin
					if (which[1:0] == 2'd0)
						init_db_addr_r <= 0;
					else
						init_db_addr_r <= db_base_addr[which[1:0] - 1] + db_size[which[1:0] - 1];
					init_db_en_r <= 1;
				end
				else if (pat == 3) begin // 改成 == 2 也可，但是需要额外处理 pat。这里利用了自然溢出。
					db_size[which[1:0]] <= db_data_out;
					if (which[1:0] == 2'd0)
						db_base_addr[0] <= 1;
					else
						db_base_addr[which[1:0]] <= db_base_addr[which[1:0] - 1] + db_size[which[1:0] - 1] + 1;
					init_db_en_r <= 0;
					if (which[1:0] < 3)
						which[1:0] <= which[1:0] + 1;
					else
						which <= 3'b0;
				end
				pat <= pat + 1;
			end
			sig_get_base_addr_0_done <= which == 3'b111 && pat == 2'b11;
		end
	end

	reg [12:0] init_do_addr_r;
	reg init_do_en_r;
	always @(*) begin
		if (state == s_get_base_addr_1 || state == s_w_get_base_addr_1) begin
			do_addr_r = init_do_addr_r;
			do_en_r = init_do_en_r;
		end
		else begin
			// TODO
		end
	end

	always @(posedge CLK) begin: get_base_addr_1_t
		integer i;
		reg [2:0] which;
		reg [1:0] part;
		reg [1:0] pat;

		if (!RESET_L) begin
			for (i = 0; i < 4; i = i + 1)
				do_size[i] <= 0;
			for (i = 0; i < 4; i = i + 1)
				do_base_addr[i] <= 0;
			sig_get_base_addr_1_done <= 0;
			which <= 0;
			part <= 0;
			pat <= 0;
			init_do_en_r <= 0;
			init_do_addr_r <= 0;
		end
		else begin
			if (!which[2]) begin
				if (sig_get_base_addr_1_on)
					which[2] <= 1;
			end
			else begin
				if (pat == 0) begin
					if (which[1:0] == 2'd0)
						init_do_addr_r <= part;
					else
						init_do_addr_r <= do_base_addr[which[1:0] - 1] + do_size[which[1:0] - 1] + part;
					init_do_en_r <= 1;
				end
				else if (pat == 3) begin
					do_size[which[1:0]][part * 4 +: 4] <= do_data_out;
					part <= part + 1;
					init_do_en_r <= 0;
					if (part == 2'b11) begin
						if (which[1:0] == 2'd0)
							do_base_addr[0] <= 4;
						else
							do_base_addr[which[1:0]] <= do_base_addr[which[1:0] - 1] + do_size[which[1:0] - 1] + 4;

						if (which[1:0] < 3)
							which[1:0] <= which[1:0] + 1;
						else
							which <= 3'b0;
					end
				end
				pat <= pat + 1;
			end
			sig_get_base_addr_1_done <= which == 3'b111 && part == 2'b11 && pat == 2'b11;
		end
	end

	reg [12:0] init_dp_addr_r;
	reg init_dp_en_r;
	always @(*) begin
		if (state == s_get_base_addr_2 || state == s_w_get_base_addr_2) begin
			dp_addr_r = init_dp_addr_r;
			dp_en_r = init_dp_en_r;
		end
		else begin
			// TODO
		end
	end

	always @(posedge CLK) begin: get_base_addr_2_t
		integer i;
		reg [2:0] which;
		reg [1:0] pat;

		if (!RESET_L) begin
			for (i = 0; i < 4; i = i + 1)
				dp_size[i] <= 0;
			for (i = 0; i < 4; i = i + 1)
				dp_base_addr[i] <= 0;
			sig_get_base_addr_2_done <= 0;
			which <= 0;
			pat <= 0;
			init_dp_en_r <= 0;
			init_dp_addr_r <= 0;
		end
		else begin
			if (!which[2]) begin
				if (sig_get_base_addr_2_on)
					which[2] <= 1;
			end
			else begin
				if (pat == 0) begin
					if (which[1:0] == 2'd0)
						init_dp_addr_r <= 0;
					else
						init_dp_addr_r <= dp_base_addr[which[1:0] - 1] + dp_size[which[1:0] - 1];
					init_dp_en_r <= 1;
				end
				else if (pat == 3) begin
					dp_size[which[1:0]] <= dp_data_out;
					if (which[1:0] == 2'd0)
						dp_base_addr[0] <= 1;
					else
						dp_base_addr[which[1:0]] <= dp_base_addr[which[1:0] - 1] + dp_size[which[1:0] - 1] + 1;
					init_dp_en_r <= 0;
					if (which[1:0] < 3)
						which[1:0] <= which[1:0] + 1;
					else
						which <= 3'b0;
				end
				pat <= pat + 1;
			end
			sig_get_base_addr_2_done <= which == 3'b111 && pat == 2'b11;
		end
	end

	reg [11:0] init_dt_addr_r;
	reg init_dt_en_r;
	always @(*) begin
		if (state == s_get_base_addr_3 || state == s_w_get_base_addr_3) begin
			dt_addr_r = init_dt_addr_r;
			dt_en_r = init_dt_en_r;
		end
		else begin
			// TODO
		end
	end

	always @(posedge CLK) begin: get_base_addr_3_t
		integer i;
		reg [1:0] which;
		reg [1:0] pat;

		if (!RESET_L) begin
			dt_size <= 0;
			dt_base_addr <= 2; // 总是 2。
			sig_get_base_addr_3_done <= 0;
			which <= 0;
			pat <= 0;
			init_dt_en_r <= 0;
			init_dt_addr_r <= 0;
		end
		else begin
			if (!which[1]) begin
				if (sig_get_base_addr_3_on)
					which[1] <= 1;
			end
			else begin
				if (pat == 0) begin
					if (which[0:0] == 1)
						init_dt_addr_r <= 1;
					else
						init_dt_addr_r <= 0;
					init_dt_en_r <= 1;
				end
				else if (pat == 3) begin
					if (which[0:0] == 1)
						song_length <= dt_data_out;
					else
						dt_size <= dt_data_out;
					init_dt_en_r <= 0;
					if (which[0:0] < 1)
						which[0:0] <= which[0:0] + 1;
					else
						which <= 2'b0;
				end
				pat <= pat + 1;
			end
			sig_get_base_addr_3_done <= which == 2'b11 && pat == 2'b11;
		end
	end

	/* 调试输出。*/
	assign DEBUG_CURRENT_STATE = state;

	/* 控制。*/

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
				n_state = s_load_skin;
			s_load_skin:
				n_state = s_w_load_skin;
			s_w_load_skin:
				n_state = sig_ds_done ? s_load_beatmap_0 : s_w_load_skin;
			s_load_beatmap_0:
				n_state = s_w_load_beatmap_0;
			s_w_load_beatmap_0:
				n_state = sig_db_done ? s_load_beatmap_1 : s_w_load_beatmap_0;
			s_load_beatmap_1:
				n_state = s_w_load_beatmap_1;
			s_w_load_beatmap_1:
				n_state = sig_do_done ? s_load_beatmap_2 : s_w_load_beatmap_1;
			s_load_beatmap_2:
				n_state = s_w_load_beatmap_2;
			s_w_load_beatmap_2:
				n_state = sig_dp_done ? s_load_beatmap_3 : s_w_load_beatmap_2;
			s_load_beatmap_3:
				n_state = s_w_load_beatmap_3;
			s_w_load_beatmap_3:
				n_state = sig_dt_done ? s_reset_cpu_song : s_w_load_beatmap_3;
			s_reset_cpu_song:
				n_state = s_w_reset_cpu_song;
			s_w_reset_cpu_song:
				n_state = sig_reset_cpu_song_done ? s_get_base_addr_0 : s_w_reset_cpu_song;
			s_get_base_addr_0:
				n_state = s_w_get_base_addr_0;
			s_w_get_base_addr_0:
				n_state = sig_get_base_addr_0_done ? s_get_base_addr_1 : s_w_get_base_addr_0;
			s_get_base_addr_1:
				n_state = s_w_get_base_addr_1;
			s_w_get_base_addr_1:
				n_state = sig_get_base_addr_1_done ? s_get_base_addr_2 : s_w_get_base_addr_1;
			s_get_base_addr_2:
				n_state = s_w_get_base_addr_2;
			s_w_get_base_addr_2:
				n_state = sig_get_base_addr_2_done ? s_get_base_addr_3 : s_w_get_base_addr_2;
			s_get_base_addr_3:
				n_state = s_w_get_base_addr_3;
			s_w_get_base_addr_3:
				n_state = sig_get_base_addr_3_done ? s_system_clock_on : s_w_get_base_addr_3;
			s_system_clock_on:
				n_state = s_system_clock_on;
			s_system_clock_pause: // 保留。
				n_state = n_system_clock_pause;
			s_standby:
				n_state = s_standby;
			default:
				n_state = s_init;
		endcase
	end

	/* 输出方程。*/
	// BRAM 初始化。
	assign sig_ds_on = state == s_load_skin;
	assign sig_db_on = state == s_load_beatmap_0;
	assign sig_do_on = state == s_load_beatmap_1;
	assign sig_dp_on = state == s_load_beatmap_2;
	assign sig_dt_on = state == s_load_beatmap_3;

	// reset_cpu_song。
	assign sig_reset_cpu_song_on = state == s_reset_cpu_song;

	// get_base_addr。
	assign sig_get_base_addr_0_on = state == s_get_base_addr_0;
	assign sig_get_base_addr_1_on = state == s_get_base_addr_1;
	assign sig_get_base_addr_2_on = state == s_get_base_addr_2;
	assign sig_get_base_addr_3_on = state == s_get_base_addr_3;

endmodule