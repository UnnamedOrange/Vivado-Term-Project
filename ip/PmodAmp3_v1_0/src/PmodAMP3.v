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
	parameter resolution = 8,
	parameter is_stereo = 0,
	parameter MCLK_ratio = resolution == 24 ? 384 : 256,
	parameter MCLK_freq = sample_rate * MCLK_ratio,
	parameter BCLK_freq = sample_rate * resolution * 2,
	parameter MCLK_divided_by_BCLK = MCLK_freq / BCLK_freq,
	parameter width = resolution * (1 + is_stereo),

	localparam log_MCLK_divided_by_BCLK =
		MCLK_divided_by_BCLK == 1 ? 0 :
		MCLK_divided_by_BCLK == 2 ? 1 :
		MCLK_divided_by_BCLK == 4 ? 2 :
		MCLK_divided_by_BCLK == 8 ? 3 :
		MCLK_divided_by_BCLK == 16 ? 4 : 5,
	localparam __unused = 0
)
(
	output EX_LRCLK,
	output EX_SDATA,
	output EX_BCLK,
	output EX_MCLK,
	input [width - 1 : 0] SAMPLE,
	input EN,
	input RESET_L,
	input CLK // 不是 100 MHz 时钟。
);

	reg [width - 1 : 0] sync_sample_buffer, sync_sample; // 同步器。
	reg sync_en_buffer, sync_en; // 同步器。
	reg [log_MCLK_divided_by_BCLK : 0] divide_to_bclk; // 分频器。

	reg [width - 1 : 0] to_play; // 保存的值。

	assign EX_MCLK = CLK;
	assign EX_BCLK = divide_to_bclk[log_MCLK_divided_by_BCLK];

	// 同步器。
	always @(posedge CLK) begin
		if (!RESET_L) begin
			sync_sample_buffer <= 0;
			sync_sample <= 0;
			sync_en_buffer <= 0;
			sync_en <= 0;
		end
		else begin
			sync_sample_buffer <= SAMPLE;
			sync_sample <= sync_sample_buffer;
			sync_en_buffer <= EN;
			sync_en <= sync_en_buffer;
		end
	end

	// 分频器，本质是一个行波计数器。
	always @(posedge CLK) begin
		if (!RESET_L) begin
			divide_to_bclk <= 0;
		end
		else begin
			divide_to_bclk <= divide_to_bclk + 1;
		end
	end

endmodule