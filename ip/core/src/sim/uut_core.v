// Copyright (c) UnnamedOrange and Jack-Lyu. Licensed under the MIT License.
// See the LICENSE file in the repository root for full license text.

/// <projectname>mania-to-go</projectname>
/// <filedescription>core 相关的所有单元测试。</filedescription>
/// <version>
/// 0.0.1 (UnnamedOrange) : First commit.
/// </version>

`timescale 10ns / 1ps

module uut_bram_data_loader #
(
	parameter addr_width = 13,
	parameter data_width_in_byte = 3,
	parameter [7:0] static_init_aux_info = 8'b00000000,
	parameter restarting_timeout = 5
)
();
	// BRAM。
	wire [addr_width - 1 : 0] bram_addr_w;
	wire [data_width_in_byte * 8 - 1 : 0] bram_data_in;
	wire bram_en_w;

	// 控制。
	reg sig_on;
	wire sig_done;

	// CPU 数据交互。
	wire restart;
	wire [7:0] init_index;
	wire [7:0] init_aux_info;
	wire request_data;
	reg data_ready;
	reg [7:0] cpu_data_in;
	reg transmit_finished;

	// 外部信息。
	reg [7:0] song_selection;

	// 复位与时钟。
	reg RESET_L;
	reg CLK;

	bram_data_loader_t #
	(
		.addr_width(addr_width),
		.data_width_in_byte (data_width_in_byte ),
		.static_init_aux_info(static_init_aux_info),
		.restarting_timeout(restarting_timeout)
	) U1 (
		.bram_addr_w(bram_addr_w),
		.bram_data_in(bram_data_in),
		.bram_en_w(bram_en_w),
		.sig_on(sig_on),
		.sig_done(sig_done),
		.restart(restart),
		.init_index(init_index),
		.init_aux_info(init_aux_info),
		.request_data(request_data),
		.data_ready(data_ready),
		.cpu_data_in(cpu_data_in),
		.transmit_finished(transmit_finished),
		.song_selection(song_selection),
		.RESET_L(RESET_L),
		.CLK(CLK)
	);

	always begin
		#0.05;
		CLK = 1;
		#0.5;
		CLK = 0;
		#0.45;
	end

	initial begin : TB
		integer i;

		RESET_L = 0;
		CLK = 0;

		sig_on = 0;
		data_ready = 0;
		cpu_data_in = 0;
		transmit_finished = 0;
		song_selection = 0;

		#10;
		RESET_L = 1;

		sig_on = 1;
		#1;
		sig_on = 0;
		#restarting_timeout;
		#restarting_timeout;

		for (i = 1; i <= 12; i = i + 1) begin
			#i;
			cpu_data_in = i;
			data_ready = 1;
			#1;
			data_ready = 0;
		end
		transmit_finished = 1;
		#1;

		#5;
		$stop(1);
	end

endmodule

module uut_core_0_load #
(
	parameter pre_data_width = 8,
	parameter song_data_width = 8
)
();
	wire [15:0] DEBUG_CURRENT_STATE;
	wire [14:0] ds_addr_w;
	wire [15:0] ds_data_in;
	wire ds_en_w;
	wire [14:0] ds_addr_r;
	reg [15:0] ds_data_out;
	wire ds_en_r;
	reg [7:0] song_selection;
	reg [pre_data_width - 1 : 0] pre_data_in;
	reg pre_data_ready;
	reg pre_transmit_finished;
	wire pre_request_data;
	wire pre_restart;
	wire [7:0] song_init_index;
	wire [7:0] song_init_aux_info;
	reg RESET_L;
	reg CLK;

	core_t #(
		.pre_data_width(pre_data_width),
		.song_data_width(song_data_width)
	) U1 (
		.DEBUG_CURRENT_STATE(DEBUG_CURRENT_STATE),
		.ds_addr_w(ds_addr_w),
		.ds_data_in(ds_data_in),
		.ds_en_w(ds_en_w),
		.ds_addr_r(ds_addr_r),
		.ds_data_out(ds_data_out),
		.ds_en_r(ds_en_r),
		.song_selection(song_selection),
		.pre_data_in(pre_data_in),
		.pre_data_ready(pre_data_ready),
		.pre_transmit_finished(pre_transmit_finished),
		.pre_request_data(pre_request_data),
		.pre_restart(pre_restart),
		.song_init_index(song_init_index),
		.song_init_aux_info(song_init_aux_info),
		.RESET_L(RESET_L),
		.CLK(CLK)
	);

	always begin
		#0.05;
		CLK = 1;
		#0.5;
		CLK = 0;
		#0.45;
	end

	initial begin : TB
		integer i;

		RESET_L = 0;
		CLK = 0;
		ds_data_out = 0;
		song_selection = 0;
		pre_data_in = 0;
		pre_data_ready = 0;
		pre_transmit_finished = 0;

		#10;
		RESET_L = 1;
		#1000000;
		#1000000;
		
		#2;
		for (i = 1; i <= 12; i = i + 1) begin
			#i;
			pre_data_in = i;
			pre_data_ready = 1;
			#1;
			pre_data_ready = 0;
		end
		pre_transmit_finished = 1;
		#1;

		#5;
		$stop(1);
	end

endmodule