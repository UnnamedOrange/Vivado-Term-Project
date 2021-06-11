// Copyright (c) UnnamedOrange and Jack-Lyu. Licensed under the MIT License.
// See the LICENSE file in the repository root for full license text.

/// <projectname>mania-to-go</projectname>
/// <modulename>uut_cpu_data_transmitter</modulename>
/// <version>
/// 0.0.1 (UnnamedOrange) : First commit.
/// 0.0.2 (UnnamedOrange) : 该测试文件适用于目前的无缓冲区版本。
/// </version>

`timescale 10ns / 1ps

module uut_cpu_data_transmitter #
(
	parameter data_width = 32,
	parameter output_data_width = 8,
	parameter log_buf_size = 4,
	parameter buf_size = 1 << log_buf_size,
	parameter buf_size_mask = buf_size - 1
)
();

	wire [output_data_width - 1 : 0] DATA_OUT;
	wire DATA_READY;
	wire TRANSMIT_FINISHED;
	reg REQUEST_DATA;
	reg RESTART;
	reg [7:0] INIT_INDEX;
	reg [7:0] INIT_AUX_INFO;
	wire [data_width - 1 : 0] REGISTER_OUT_0;
	wire [data_width - 1 : 0] REGISTER_OUT_1;
	wire [data_width - 1 : 0] REGISTER_OUT_2;
	wire [data_width - 1 : 0] REGISTER_OUT_3;
	reg [data_width - 1 : 0] REGISTER_IN_0;
	reg [data_width - 1 : 0] REGISTER_IN_1;
	reg [data_width - 1 : 0] REGISTER_IN_2;
	reg [data_width - 1 : 0] REGISTER_IN_3;
	reg RESET_L;
	reg CLK;

	cpu_data_transmitter # (
		.data_width(data_width),
		.output_data_width(output_data_width),
		.log_buf_size(log_buf_size),
		.buf_size(buf_size),
		.buf_size_mask(buf_size_mask)
	) U1 (
		.DATA_OUT(DATA_OUT),
		.DATA_READY(DATA_READY),
		.TRANSMIT_FINISHED(TRANSMIT_FINISHED),
		.REQUEST_DATA(REQUEST_DATA),
		.RESTART(RESTART),
		.INIT_INDEX(INIT_INDEX),
		.INIT_AUX_INFO(INIT_AUX_INFO),
		.REGISTER_OUT_0(REGISTER_OUT_0),
		.REGISTER_OUT_1(REGISTER_OUT_1),
		.REGISTER_OUT_2(REGISTER_OUT_2),
		.REGISTER_OUT_3(REGISTER_OUT_3),
		.REGISTER_IN_0(REGISTER_IN_0),
		.REGISTER_IN_1(REGISTER_IN_1),
		.REGISTER_IN_2(REGISTER_IN_2),
		.REGISTER_IN_3(REGISTER_IN_3),
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

	initial begin
		RESET_L = 0;
		INIT_INDEX = 0;
		INIT_AUX_INFO = 0;
		RESTART = 0;
		REGISTER_IN_0 = 0;
		REGISTER_IN_1 = 0;
		REGISTER_IN_2 = 0;
		REGISTER_IN_3 = 0;
		REQUEST_DATA = 0;
		#11;
		RESET_L = 1;
		REGISTER_IN_3 = {1'b0, 2'b0, 1'b0, 28'd0};
		#1;
		REQUEST_DATA = 1;
		#5;
		REGISTER_IN_0 = 1;
		REGISTER_IN_3 = {1'b1, 2'b0, 1'b0, 28'd1};
		#5;
		REGISTER_IN_0 = 2;
		REGISTER_IN_3 = {1'b1, 2'b0, 1'b0, 28'd2};
		#5;
		REGISTER_IN_0 = 3;
		REGISTER_IN_3 = {1'b1, 2'b0, 1'b1, 28'd3};
		#1;
		REQUEST_DATA = 0;
		RESTART = 1;
		#2;
		REGISTER_IN_3 = {1'b0, 2'b0, 1'b0, 28'd0};
		#2;
		RESTART = 0;
		REQUEST_DATA = 1;
		#10;
		REGISTER_IN_0 = 1;
		REGISTER_IN_3 = {1'b1, 2'b0, 1'b0, 28'd1};
		#5;
		REGISTER_IN_0 = 2;
		REGISTER_IN_3 = {1'b1, 2'b0, 1'b0, 28'd2};
		#5;
		REGISTER_IN_0 = 3;
		REGISTER_IN_3 = {1'b1, 2'b0, 1'b1, 28'd3};

		#5;
		$stop(1);
	end

endmodule