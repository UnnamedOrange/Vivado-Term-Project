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
	parameter MCLK_rate = 384,

	localparam MCLK_freq = sample_rate * MCLK_rate,
	localparam __unused = 0
)
(
	input RESET_L,
	input CLK, // Ƶ��Ϊ 100 MHz ��ȫ��ʱ�ӡ�
	input MCLK // Ƶ��Ϊ MCLK_freq ��ʱ�ӣ�Ĭ��ӦΪ 16.9344 MHz����
);



endmodule