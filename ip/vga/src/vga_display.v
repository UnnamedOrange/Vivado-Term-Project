`timescale 1ns / 1ps
// Copyright (c) UnnamedOrange and Jack-Lyu. Licensed under the MIT License.
// See the LICENSE file in the repository root for full license text.

/// <projectname>mania-to-go</projectname>
/// <modulename>vga_t</modulename>
/// <filedescription>VGA 显示模块。</filedescription>
/// <version>
/// 0.0.1 (Jack-Lyu) : VGA显示模块搭建完毕。
/// </version>


module vga_display(
	input wire vidon,
	input wire [9:0] h_cnt,
	input wire [9:0] v_cnt,
	input [3:0] get_r,
	input [3:0] get_g,
	input [3:0] get_b,
	input clk_25,
	input rst,
	output reg [3:0] vga_r,
	output reg [3:0] vga_g,
	output reg [3:0] vga_b 
    );
    
    reg [3:0] dis_r;
    reg [3:0] dis_g;
    reg [3:0] dis_b;
    
	always @(posedge clk_25) begin
		if(rst) begin
			vga_r <= 0;
			vga_g <= 0;
			vga_b <= 0;
		end
		else if(!vidon) begin
			vga_r <= 0;
			vga_g <= 0;
			vga_b <= 0;
		end
		else if( h_cnt == 0 & v_cnt == 0 ) begin
			vga_r <= 0;
			vga_g <= 0;
			vga_b <= 0;
		end
		else begin
			vga_r <= get_r;
			vga_g <= get_g;
			vga_b <= get_b;
		end
	end
    
endmodule
