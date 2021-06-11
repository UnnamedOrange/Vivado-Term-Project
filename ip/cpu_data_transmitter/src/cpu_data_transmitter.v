// Copyright (c) UnnamedOrange and Jack-Lyu. Licensed under the MIT License.
// See the LICENSE file in the repository root for full license text.

/// <projectname>mania-to-go</projectname>
/// <modulename>cpu_data_transmitter</modulename>
/// <filedescription>CPU 数据传输器。</filedescription>
/// <version>
/// 0.0.1 (UnnamedOrange) : First commit.
/// 0.0.2 (UnnamedOrange) : 增大缓冲区大小。将输出改为同步输出。
/// 0.0.3 (UnnamedOrange) : 增加一些调试用输出。
/// 0.0.4 (UnnamedOrange) : 回退到无缓冲区的模式。使用新的编码。
/// 0.0.5 (UnnamedOrange) : 将控制信号的输出改为同步的。
/// </version>

`timescale 1 ns / 1 ps

module cpu_data_transmitter #
(
	parameter data_width = 32,
	parameter output_data_width = 8
)
(
	output [output_data_width - 1 : 0] DATA_OUT,
	output reg DATA_READY,
	output reg TRANSMIT_FINISHED,
	input REQUEST_DATA,
	input RESTART,
	input [7:0] INIT_INDEX,
	input [7:0] INIT_AUX_INFO,
	output [data_width - 1 : 0] REGISTER_OUT_0,
	output [data_width - 1 : 0] REGISTER_OUT_1,
	output [data_width - 1 : 0] REGISTER_OUT_2,
	output [data_width - 1 : 0] REGISTER_OUT_3,
	input [data_width - 1 : 0] REGISTER_IN_0,
	input [data_width - 1 : 0] REGISTER_IN_1,
	input [data_width - 1 : 0] REGISTER_IN_2,
	input [data_width - 1 : 0] REGISTER_IN_3,
	input RESET_L,
	input CLK
);

	reg [27:0] progress;

	always @(posedge CLK) begin
		if (!RESET_L) begin
			progress <= 0;
			DATA_READY <= 0;
			TRANSMIT_FINISHED <= 0;
		end
		else begin
			DATA_READY <= REGISTER_IN_3[31] && progress < REGISTER_IN_3[27:0];
			TRANSMIT_FINISHED <= REGISTER_IN_3[28];
			if (REGISTER_IN_3[31])
				progress <= REGISTER_IN_3[27:0];
			else
				progress <= 0;
		end
	end

	assign DATA_OUT = REGISTER_IN_0[output_data_width - 1 : 0];
	assign REGISTER_OUT_0 = 0;
	assign REGISTER_OUT_1 = 0;
	assign REGISTER_OUT_2 = 0;
	assign REGISTER_OUT_3 = { RESTART, REQUEST_DATA, 14'b0, INIT_AUX_INFO, INIT_INDEX };

endmodule