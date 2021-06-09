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
	output [12:0] db_addr_r,
	input [23:0] db_data_out,
	output db_en_r,

	// .object (do) 对应 BRAM。
	output [11:0] do_addr_w,
	output [7:0] do_data_in,
	output do_en_w,
	output [12:0] do_addr_r,
	input [3:0] do_data_out,
	output do_en_r,

	// .pixel (dp) 对应 BRAM。
	output [12:0] dp_addr_w,
	output [31:0] dp_data_in,
	output dp_en_w,
	output [12:0] dp_addr_r,
	input [31:0] dp_data_out,
	output dp_en_r,

	// .timing (dt) 对应 BRAM。
	output [11:0] dt_addr_w,
	output [31:0] dt_data_in,
	output dt_en_w,
	output [11:0] dt_addr_r,
	input [31:0] dt_data_out,
	output dt_en_r,

	// .skin (ds) 对应 BRAM。
	output [14:0] ds_addr_w,
	output [15:0] ds_data_in,
	output ds_en_w,
	output [14:0] ds_addr_r,
	input [15:0] ds_data_out,
	output ds_en_r,

	// 选歌开关。
	input [7:0] song_selection, // 假设不变。

	// 预读取数据用的 SD 卡模块。
	output reg [7:0] pre_init_index,
	output reg [7:0] pre_init_aux_info,
	input [pre_data_width - 1 : 0] pre_data_in,
	input pre_data_ready,
	output reg pre_request_data,
	output reg pre_restart,

	// 读取歌曲的 SD 卡模块。
	output [7:0] song_init_index,
	output [7:0] song_init_aux_info,
	input [song_data_width - 1 : 0] song_data_in,
	input song_data_ready,
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
		s_init              = 16'h0000, // 复位。
		s_load_skin         = 16'h0001, // 加载 .skin 到 BRAM。
		s_load_beatmap_0    = 16'h0002, // 加载 .beatmap 到 BRAM。
		s_load_beatmap_1    = 16'h0003, // 加载 .object 到 BRAM。
		s_load_beatmap_2    = 16'h0004, // 加载 .pixel 到 BRAM。
		s_load_beatmap_3    = 16'h0005, // 加载 .timing 到 BRAM。
		s_standby           = 16'h9999, // 游戏结束，不做其他事（暂时保留）。
		s_unused = 16'hffff;
	reg [state_width - 1 : 0] state, n_state;

	/* 模块互联。*/
	// BRAM。
	reg sig_db_on;
	wire sig_db_done;
	wire [7:0] db_pre_init_index;
	wire [7:0] db_pre_init_aux_info;
	wire db_pre_request_data;
	wire db_pre_restart;
	bram_data_loader_t #
	(
		.addr_width(13),
		.data_width_in_byte(3),
		.static_init_aux_info(8'b00000000),
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
		.song_selection(song_selection),
		.RESET_L(RESET_L),
		.CLK(CLK)
	);

	reg sig_do_on;
	wire sig_do_done;
	wire [7:0] do_pre_init_index;
	wire [7:0] do_pre_init_aux_info;
	wire do_pre_request_data;
	wire do_pre_restart;
	bram_data_loader_t #
	(
		.addr_width(13),
		.data_width_in_byte(1),
		.static_init_aux_info(8'b00000001),
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
		.song_selection(song_selection),
		.RESET_L(RESET_L),
		.CLK(CLK)
	);

	reg sig_dp_on;
	wire sig_dp_done;
	wire [7:0] dp_pre_init_index;
	wire [7:0] dp_pre_init_aux_info;
	wire dp_pre_request_data;
	wire dp_pre_restart;
	bram_data_loader_t #
	(
		.addr_width(13),
		.data_width_in_byte(4),
		.static_init_aux_info(8'b00000010),
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
		.song_selection(song_selection),
		.RESET_L(RESET_L),
		.CLK(CLK)
	);

	reg sig_dt_on;
	wire sig_dt_done;
	wire [7:0] dt_pre_init_index;
	wire [7:0] dt_pre_init_aux_info;
	wire dt_pre_request_data;
	wire dt_pre_restart;
	bram_data_loader_t #
	(
		.addr_width(12),
		.data_width_in_byte(4),
		.static_init_aux_info(8'b00000011),
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
		.song_selection(song_selection),
		.RESET_L(RESET_L),
		.CLK(CLK)
	);

	reg sig_ds_on;
	wire sig_ds_done;
	wire [7:0] ds_pre_init_index;
	wire [7:0] ds_pre_init_aux_info;
	wire ds_pre_request_data;
	wire ds_pre_restart;
	bram_data_loader_t #
	(
		.addr_width(15),
		.data_width_in_byte(2),
		.static_init_aux_info(8'b10000000),
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
		.song_selection(song_selection),
		.RESET_L(RESET_L),
		.CLK(CLK)
	);

	// 选通 pre_cpu。
	always @(*) begin
		case (state)
			s_load_skin: begin
				pre_init_index =    ds_pre_init_index;
				pre_init_aux_info = ds_pre_init_aux_info;
				pre_request_data =  ds_pre_request_data;
				pre_restart =       ds_pre_restart;
			end
			s_load_beatmap_0: begin
				pre_init_index =    db_pre_init_index;
				pre_init_aux_info = db_pre_init_aux_info;
				pre_request_data =  db_pre_request_data;
				pre_restart =       db_pre_restart;
			end
			s_load_beatmap_1: begin
				pre_init_index =    do_pre_init_index;
				pre_init_aux_info = do_pre_init_aux_info;
				pre_request_data =  do_pre_request_data;
				pre_restart =       do_pre_restart;
			end
			s_load_beatmap_2: begin
				pre_init_index =    dp_pre_init_index;
				pre_init_aux_info = dp_pre_init_aux_info;
				pre_request_data =  dp_pre_request_data;
				pre_restart =       dp_pre_restart;
			end
			s_load_beatmap_3: begin
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

	/* 调试输出。*/
	assign DEBUG_CURRENT_STATE = state;

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
			s_init: n_state = s_load_skin;

			s_standby: n_state = s_standby;
			default: n_state = s_init;
		endcase
	end

endmodule