// Copyright (c) UnnamedOrange and Jack-Lyu. Licensed under the MIT Licence.
// See the LICENSE file in the repository root for full licence text.

/// <projectname>PmodAMP3</projectname>
/// <modulename>PmodAMP3</modulename>
/// <projectdescription>An unofficial IP core of Pmod AMP3.</projectdescription>
/// <version>
/// 0.0.1 (UnnamedOrange) : First commit.
/// </version>

module PmodAMP3 #
(
	parameter sample_rate = 44100,
	parameter MCLK_ratio = 384,
	parameter resolution = 8,
	parameter is_stereo = 0,
	parameter MCLK_freq = sample_rate * MCLK_ratio,

	localparam __unused = 0
)
(
	output EX_LRCLK,
	output EX_SDATA,
	output EX_BCLK,
	output EX_MCLE,
	input [resolution * (1 + is_stereo) - 1 : 0] SAMPLE, // 输入的单次采样。如果是双声道，低位是左声道，高位是右声道。
	input EN,
	input RESET_L,
	input CLK, // 频率为 100 MHz 的全局时钟。
	input MCLK // 频率为 MCLK_freq 的时钟（默认应为 16.9344 MHz）。
);



endmodule