// Copyright (c) UnnamedOrange and Jack-Lyu. Licensed under the MIT Licence.
// See the LICENSE file in the repository root for full licence text.

/// <projectname>PmodAMP3</projectname>
/// <modulename>uut_basic_timing</modulename>
/// <version>
/// 0.0.1 (UnnamedOrange) : First commit.
/// </version>

`timescale 1ns / 1ps

module uut_basic_timing();
	wire EX_LRCLK;
	wire EX_SDATA;
	wire EX_BCLK;
	wire EX_MCLK;
	reg [15:0] SAMPLE;
	reg EN;
	reg RESET_L;
	reg CLK;

	PmodAMP3 #(.is_stereo(1)) U1(
		.EX_LRCLK(EX_LRCLK),
		.EX_SDATA(EX_SDATA),
		.EX_BCLK(EX_BCLK),
		.EX_MCLK(EX_MCLK),
		.SAMPLE(SAMPLE),
		.EN(EN),
		.RESET_L(RESET_L),
		.CLK(CLK));

	// 11.2896 MHz 时钟。
	initial begin
		#1;
		forever begin
			CLK = 0;
			#4.4288;
			CLK = 1;
			#4.4288;
		end
	end

	// 仿真流程。
	initial begin
		SAMPLE = 0;
		EN = 0;
		RESET_L = 0;
		#105;
		RESET_L = 1;
		EN = 1;
		SAMPLE = {8'b10011010, 8'b10111100};
		#10000;
		SAMPLE = {8'b10111100, 8'b10011010};
		#10000;
		EN = 0;
		#1000;
		$stop(1);
	end

endmodule