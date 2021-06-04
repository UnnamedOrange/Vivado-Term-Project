// Copyright (c) UnnamedOrange and Jack-Lyu. Licensed under the MIT License.
// See the LICENSE file in the repository root for full license text.

/// <projectname>mania-to-go</projectname>
/// <modulename>uut_cpu_data_transmitter</modulename>
/// <version>
/// 0.0.1 (UnnamedOrange) : First commit.
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
	wire DEBUG_DATA_FROM_CPU_READY;
	wire [15:0] DEBUG_BUFFER_SIZE;
	reg REQUEST_DATA;
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
		.DEBUG_DATA_FROM_CPU_READY(DEBUG_DATA_FROM_CPU_READY),
		.DEBUG_BUFFER_SIZE(DEBUG_BUFFER_SIZE),
		.REQUEST_DATA(REQUEST_DATA),
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
		REGISTER_IN_0 = 0;
		REGISTER_IN_1 = 0;
		REGISTER_IN_2 = 0;
		REGISTER_IN_3 = 0;
		REQUEST_DATA = 0;
		#11;
		RESET_L = 1;
		#5;
		REGISTER_IN_0 = 1;
		REGISTER_IN_3 = {1'b1, 3'b0, 28'd1};
		#5;
		REGISTER_IN_0 = 2;
		REGISTER_IN_3 = {1'b1, 3'b0, 28'd2};
		#5;
		REGISTER_IN_0 = 3;
		REGISTER_IN_3 = {1'b1, 3'b0, 28'd3};
		#5;
		REGISTER_IN_0 = 4;
		REGISTER_IN_3 = {1'b1, 3'b0, 28'd4};
		#5;
		REGISTER_IN_0 = 5;
		REGISTER_IN_3 = {1'b1, 3'b0, 28'd5};
		#5;
		REGISTER_IN_0 = 6;
		REGISTER_IN_3 = {1'b1, 3'b0, 28'd6};
		#5;
		REGISTER_IN_0 = 7;
		REGISTER_IN_3 = {1'b1, 3'b0, 28'd7};
		#5;
		REGISTER_IN_0 = 8;
		REGISTER_IN_3 = {1'b1, 3'b0, 28'd8};
		REQUEST_DATA = 1;
		#5;
		REGISTER_IN_0 = 9;
		REGISTER_IN_3 = {1'b1, 3'b0, 28'd9};
		#5;
		REGISTER_IN_0 = 10;
		REGISTER_IN_3 = {1'b1, 3'b0, 28'd10};
		#5;
		REGISTER_IN_0 = 11;
		REGISTER_IN_3 = {1'b1, 3'b0, 28'd11};
		#5;
		REGISTER_IN_0 = 12;
		REGISTER_IN_3 = {1'b1, 3'b0, 28'd12};
		#5;
		REGISTER_IN_0 = 13;
		REGISTER_IN_3 = {1'b1, 3'b0, 28'd13};
		#5;
		REGISTER_IN_0 = 14;
		REGISTER_IN_3 = {1'b1, 3'b0, 28'd14};
		#5;
		REGISTER_IN_0 = 15;
		REGISTER_IN_3 = {1'b1, 3'b0, 28'd15};
		#5;
		REGISTER_IN_0 = 16;
		REGISTER_IN_3 = {1'b1, 3'b0, 28'd16};
		#5;
		REGISTER_IN_0 = 17;
		REGISTER_IN_3 = {1'b1, 3'b0, 28'd17};
		#5;
		REGISTER_IN_0 = 18;
		REGISTER_IN_3 = {1'b1, 3'b0, 28'd18};
		#5;
		REGISTER_IN_0 = 19;
		REGISTER_IN_3 = {1'b1, 3'b0, 28'd19};
		$stop(1);
	end

endmodule