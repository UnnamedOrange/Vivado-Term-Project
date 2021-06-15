// Copyright (c) UnnamedOrange and Jack-Lyu. Licensed under the MIT License.
// See the LICENSE file in the repository root for full license text.

/// <projectname>mania-to-go</projectname>
/// <modulename>keyboard_t</modulename>
/// <filedescription>键盘输入。</filedescription>
/// <version>
/// 0.0.1 (UnnamedOrange and Jack-Lyu) : First commit.
/// 0.0.2 (Jack-Lyu) : 成了。
/// 0.0.3 (UnnamedOrange and Jack-Lyu) : 修复键盘 CHANGE 持续时间错误的问题。
/// </version>

`timescale 1ns / 1ps

module keyboard_t #
(
	parameter key_0 = 8'h24,
	parameter key_1 = 8'h2D,
	parameter key_2 = 8'h3C,
	parameter key_3 = 8'h43
)
(
	output [3:0] DOWN,
	output [3:0] CHANGE,
	input kbdata,
	input kbclk,
	input RESET_L,
	input CLK
);
	wire reset, clk;
	assign reset = !RESET_L;
	assign clk = CLK;

	wire [15:0] keycode;
	wire oflag;
	reg [3:0] down;
	reg [3:0] n_down;
	reg [3:0] change;
	reg [3:0] n_change;

	parameter change_period = 100000;
	reg [16:0] change_counter[3:0];
	always @(posedge CLK) begin : b1
		integer i;

		if (reset) begin
			for (i = 0; i < 4; i = i + 1)
				change_counter[i] <= 0;
		end
		else begin
			for (i = 0; i < 4; i = i + 1) begin
				if (change[i])
					change_counter[i] <= change_period - 1;
				else begin
					if (change_counter[i] > 0)
						change_counter[i] <= change_counter[i] - 1;
				end
			end
		end
	end

	reg [3:0] true_change;
	always @(*) begin : b2
		integer i;

		for (i = 0; i < 4; i = i + 1)
			true_change[i] = change_counter[i] != 0;
	end

	PS2scan u1(
		.clk(clk),
		.kclk(kbclk),
		.kdata(kbdata),
		.keycode(keycode), //out
		.oflag(oflag) //out
	);

	always @(posedge clk) begin
		change <= n_change;
		down <= n_down;
	end

	always @(*) begin // 组合逻辑设计
		n_down = down;
		n_change = change;
		if(reset) begin
			n_down = 4'b0;
			n_change = 4'b0;
		end
		else if (!oflag) begin
			n_change = 4'b0;
		end
 		else if(keycode[15:8] == 8'hf0) begin // 确定要松开的键
			case(keycode[7:0])
				key_0: begin n_down[0] = 0 ; n_change[0] = 1; end
				key_1: begin n_down[1] = 0 ; n_change[1] = 1; end
				key_2: begin n_down[2] = 0 ; n_change[2] = 1; end
				key_3: begin n_down[3] = 0 ; n_change[3] = 1; end
			endcase
		end
		else begin
			case(keycode[7:0])
				key_0: begin
					if(!n_down[0])
						n_change[0] = 1; 
					else 
						n_change[0] = 0; 
					n_down[0] = 1 ;
				end
				key_1: begin
					if(!n_down[1])
						n_change[1] = 1; 
					else 
						n_change[1] = 0; 
					n_down[1] = 1 ;
				end
				key_2: begin
					if(!n_down[2])
						n_change[2] = 1; 
					else 
						n_change[2] = 0; 
					n_down[2] = 1 ;
				end
				key_3: begin
					if(!n_down[3])
						n_change[3] = 1; 
					else 
						n_change[3] = 0; 
					n_down[3] = 1 ;
				end
			endcase
		end
	end

	assign DOWN = down;
	assign CHANGE = true_change;

endmodule