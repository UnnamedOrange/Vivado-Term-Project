// Copyright (c) UnnamedOrange and Jack-Lyu. Licensed under the MIT License.
// See the LICENSE file in the repository root for full license text.

/// <projectname>mania-to-go</projectname>
/// <modulename>audio_synthesis</modulename>
/// <filedescription>音频合成。</filedescription>
/// <version>
/// 0.0.1 (UnnamedOrange) : First commit.
/// </version>

`timescale 10ns / 1ps

module audio_synthesis_t #
(
	parameter resolution_input = 8,
	parameter resolution_output = 16
)
(
	output [resolution_output - 1 : 0] AUDIO_OUT,
	input [resolution_input - 1 : 0] MAIN_AUDIO_IN,
	input MAIN_AUDIO_EN,
	input [3:0] MAIN_AUDIO_VOLUMN,
	input [resolution_input - 1 : 0] AUX_AUDIO_IN,
	input AUX_AUDIO_EN,
	input [3:0] AUX_AUDIO_VOLUMN,
	input EN
);

	reg [resolution_output - 1 : 0] // 位宽对齐并处理后的音频。
		main_audio_align,
		aux_audio_align;

	always @* begin
		if (MAIN_AUDIO_EN) begin
			main_audio_align = MAIN_AUDIO_IN << (resolution_output - resolution_input);
			main_audio_align = main_audio_align >> MAIN_AUDIO_VOLUMN;
		end
		else
			main_audio_align = 0;
		if (AUX_AUDIO_EN) begin
			aux_audio_align = AUX_AUDIO_IN << (resolution_output - resolution_input);
			aux_audio_align = aux_audio_align >> AUX_AUDIO_VOLUMN;
		end
		else
			aux_audio_align = 0;
	end

	assign AUDIO_OUT = EN ? (main_audio_align + aux_audio_align) : 0;

endmodule