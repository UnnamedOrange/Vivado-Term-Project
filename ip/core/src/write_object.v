// Copyright (c) UnnamedOrange and Jack-Lyu. Licensed under the MIT License.
// See the LICENSE file in the repository root for full license text.

/// <projectname>mania-to-go</projectname>
/// <modulename>write_object_t</modulename>
/// <filedescription>回写 object 的模块</filedescription>
/// <version>
/// 0.0.1 (UnnamedOrange) : First commit.
/// </version>

`timescale 1ns / 1ps

module write_object_t
(
	// 控制。
	input sig_on,
	output reg sig_done,

	// 数据。
	input [3:0] data_in,
	input [12:0] addr_to_write,

	// BRAM。
	output [11:0] do_a_addr,
	output [7:0] do_a_data_in,
	output reg do_a_en_w,
	output reg [12:0] do_b_addr,
	input [3:0] do_b_data_out,
	output reg do_b_en,

	// 复位与时钟。
	input RESET_L,
	input CLK
);

	reg [7:0] buffer;
	assign do_a_addr = addr_to_write[12:1];
	assign do_a_data_in = buffer;

	reg working;
	reg [1:0] pat;
	reg [1:0] which;
	always @(posedge CLK) begin
		if (!RESET_L) begin
			buffer <= 0;

			do_a_en_w <= 0;
			do_b_addr <= 0;
			do_b_en <= 0;

			working <= 0;
			pat <= 0;
			which <= 0;
		end
		else begin
			if (!working) begin
				if (sig_on) begin
					working <= 1;
					which <= 0;
				end
			end
			else begin
				if (pat == 0) begin
					case (which)
						0: begin
							do_b_addr <= {addr_to_write[12:1], 1'b0};
							do_b_en <= 1;
						end
						1: begin
							do_b_addr <= {addr_to_write[12:1], 1'b1};
							do_b_en <= 1;
						end
						2: begin
							buffer[addr_to_write[0] * 4 +: 4] <= data_in;
						end
						3: begin
							do_a_en_w <= 1;
						end
					endcase
				end
				else if (pat == 3) begin
					case (which)
						0: begin
							buffer[3:0] <= do_b_data_out;
							do_b_en <= 0;
							which <= 1;
						end
						1: begin
							buffer[7:4] <= do_b_data_out;
							do_b_en <= 0;
							which <= 2;
						end
						2: begin
							which <= 3;
						end
						3: begin
							do_a_en_w <= 0;

							working <= 0;
							which <= 0;
						end
					endcase
				end
				pat <= pat + 1;
			end
			sig_done <= working && which == 3 && pat == 2'b11;
		end
	end

endmodule