// Copyright (c) UnnamedOrange and Jack-Lyu. Licensed under the MIT License.
// See the LICENSE file in the repository root for full license text.

/// <projectname>mania-to-go</projectname>
/// <modulename>vga_top</modulename>
/// <filedescription>VGA 总模块。</filedescription>
/// <version>
/// 0.0.1 (UnnamedOrange and Jack-Lyu) : First commit.
/// 0.0.2 (Jack-Lyu) : VGA模块搭建完毕。
/// 0.0.3 (UnnamedOrange) : 修复复位的有效性与变量名不同的问题。
/// </version>

`timescale 1ns / 1ps

module vga_top(
	input wire clk,
	input wire rst,
	input [3:0] get_r,
	input [3:0] get_g,
	input [3:0] get_b,
	output [9:0] hcnt_request,
	output [9:0] vcnt_request,
	output request,
	output wire hsync,
	output wire vsync,
	output wire [3:0] vga_r,
	output wire [3:0] vga_g,
	output wire [3:0] vga_b
	);

	wire valid;
	wire[9:0] h_cnt;
	wire[9:0] v_cnt;
	dcm_25m1 u0 (.clk_in(clk),.clk_out(pclk),.reset(rst));
	vga_640x480 u1(.pclk(pclk),.reset(rst),.hsync(hsync),.vsync(vsync),.valid(valid),.h_cnt(h_cnt),.v_cnt(v_cnt));
	vga_display u2(.vidon(valid),.h_cnt(h_cnt),.v_cnt(v_cnt),.vga_r(vga_r),.vga_b(vga_b),.vga_g(vga_g),
	.get_r(get_r),.get_g(get_g),.get_b(get_b),
	.rst(rst),.clk_25(pclk)
	);
	request_controller u3(.clk(clk),.rst(rst),.clk_25(pclk),
	.h_cnt(h_cnt),.v_cnt(v_cnt),.valid(valid),
	.request(request),.hcnt_request(hcnt_request),.vcnt_request(vcnt_request));

endmodule