// Copyright (c) UnnamedOrange and Jack-Lyu. Licensed under the MIT License.
// See the LICENSE file in the repository root for full license text.

/// <projectname>mania-to-go</projectname>
/// <modulename>keyboard_t</modulename>
/// <filedescription>º¸≈Ã ‰»Î°£</filedescription>
/// <version>
/// 0.0.1 (UnnamedOrange and Jack-Lyu) : First commit.
/// </version>

`timescale 1ns / 1ps

module keyboard_t #
(
	parameter key_0 = 8'h23,
	parameter key_1 = 8'h2B,
	parameter key_2 = 8'h3B,
	parameter key_3 = 8'h42
)
(
	output [3:0] IS_KEY_DOWN,
	output [3:0] IS_KEY_CHANGED,
	input KB_DATA,
	input KB_CLK,
	input RESET_L,
	input CLK
);

	reg sync_clk;

	always @(posedge CLK) begin
		if (!RESET_L) begin
			sync_clk <= 1;
		end
		else begin
			if (!KB_CLK)
				sync_clk <= KB_CLK;
			else
				sync_clk <= 1;
		end
	end

endmodule