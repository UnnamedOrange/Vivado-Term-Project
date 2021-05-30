// Copyright (c) UnnamedOrange and Jack-Lyu. Licensed under the MIT Licence.
// See the LICENSE file in the repository root for full licence text.

/// <projectname>mania-to-go</projectname>
/// <modulename>cpu_data_transmitter</modulename>
/// <filedescription>CPU Êý¾Ý´«ÊäÆ÷¡£</filedescription>
/// <version>
/// 0.0.1 (UnnamedOrange) : First commit.
/// </version>

`timescale 1 ns / 1 ps

module cpu_data_transmitter #
(
	parameter data_width = 32,
	parameter output_data_width = 8
)
(
	output [output_data_width - 1 : 0] DATA_OUT,
	output DATA_READY,
	input REQUEST_DATA,
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

	always @(posedge CLK) begin
		if (!RESET_L) begin

		end
		else begin

		end
	end

endmodule