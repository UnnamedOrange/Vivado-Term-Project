// Copyright (c) UnnamedOrange and Jack-Lyu. Licensed under the MIT License.
// See the LICENSE file in the repository root for full license text.

/// <projectname>mania-to-go</projectname>
/// <modulename>uut_basic</modulename>
/// <version>
/// 0.0.1 (UnnamedOrange) : First commit.
/// </version>

`timescale 1ns / 1ps

module uut_basic();
	wire [15:0] AUDIO_OUT;
	reg [7: 0] MAIN_AUDIO_IN;
	reg MAIN_AUDIO_EN;
	reg [3:0] MAIN_AUDIO_VOLUMN;
	reg [7:0] AUX_AUDIO_IN;
	reg AUX_AUDIO_EN;
	reg [3:0] AUX_AUDIO_VOLUMN;
	reg EN;

	audio_synthesis_t U1(
		.AUDIO_OUT(AUDIO_OUT),
		.MAIN_AUDIO_IN(MAIN_AUDIO_IN),
		.MAIN_AUDIO_EN(MAIN_AUDIO_EN),
		.MAIN_AUDIO_VOLUMN(MAIN_AUDIO_VOLUMN),
		.AUX_AUDIO_IN(AUX_AUDIO_IN),
		.AUX_AUDIO_EN(AUX_AUDIO_EN),
		.AUX_AUDIO_VOLUMN(AUX_AUDIO_VOLUMN),
		.EN(EN));

	// ·ÂÕæÁ÷³Ì¡£
	initial begin
		#105;
		EN = 1;
		MAIN_AUDIO_IN = 233;
		MAIN_AUDIO_EN = 1;
		MAIN_AUDIO_VOLUMN = 0;
		AUX_AUDIO_IN = 66;
		AUX_AUDIO_EN = 1;
		AUX_AUDIO_VOLUMN = 6;
		#100;
		AUX_AUDIO_EN = 0;
		#100;
		EN = 0;
		#100;
		$stop(1);
	end

endmodule