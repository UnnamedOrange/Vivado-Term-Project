// Copyright (c) UnnamedOrange and Jack-Lyu. Licensed under the MIT License.
// See the LICENSE file in the repository root for full license text.

/// <projectname>mania-to-go</projectname>
/// <modulename>draw_controller_t</modulename>
/// <filedescription>画图需要的数据的管理器。</filedescription>
/// <version>
/// 0.0.1 (UnnamedOrange) : 定义输入输出。
/// 0.0.2 (UnnamedOrange) : 实现。
/// </version>

`timescale 1ns / 1ps

module draw_controller_t
(
	// 控制。
	input sig_on,
	output sig_done,

	// BRAM。
	output reg [12:0] do_b_addr,
	input [3:0] do_b_data_out,
	output reg do_b_en,

	output reg [12:0] dp_b_addr,
	input [31:0] dp_b_data_out,
	output reg dp_b_en,

	output reg [14:0] ds_b_addr,
	input [15:0] ds_b_data_out,
	output reg ds_b_en,

	// 数量与基地址。
	input [12:0] do_size_0,
	input [12:0] do_size_1,
	input [12:0] do_size_2,
	input [12:0] do_size_3,
	input [12:0] do_base_addr_0,
	input [12:0] do_base_addr_1,
	input [12:0] do_base_addr_2,
	input [12:0] do_base_addr_3,
	input [12:0] dp_size_0,
	input [12:0] dp_size_1,
	input [12:0] dp_size_2,
	input [12:0] dp_size_3,
	input [12:0] dp_base_addr_0,
	input [12:0] dp_base_addr_1,
	input [12:0] dp_base_addr_2,
	input [12:0] dp_base_addr_3,

	// 键盘。
	input [3:0] is_key_down,

	// 当前位置。
	input [31:0] current_pixel,

	// TODO: 其他辅助信息。

	// VGA。
	output vga_reset,
	output reg [3:0] vga_r,
	output reg [3:0] vga_g,
	output reg [3:0] vga_b,
	input [9:0] vga_x, // 行。
	input [9:0] vga_y, // 列。
	input vga_request,

	// 复位与时钟。
	input RESET_L,
	input CLK
);

	// 开始工作。
	reg is_working;
	reg is_first_frame;
	always @(posedge CLK) begin
		if (!RESET_L) begin
			is_working <= 0;
			is_first_frame <= 1;
		end
		else begin
			if (!is_working) begin
				if (sig_on) begin
					is_working <= 1;
				end
			end
			else begin
				if (sig_on) begin
					is_first_frame <= 0;
				end
			end
		end
	end

	// 显示器使能。
	assign vga_reset = !is_working;

	// 乒乓。
	reg ping_pong;
	always @(posedge CLK) begin
		if (!RESET_L) begin
			ping_pong <= 0;
		end
		else begin
			if (sig_on)
				ping_pong = !ping_pong;
		end
	end

	// TODO: 列管理器。

	// 颜色输出。
	reg [1:0] pat;
	always @(posedge CLK) begin
		if (!RESET_L) begin
			vga_r <= 0;
			vga_g <= 0;
			vga_b <= 0;
			pat <= 0;
		end
		else begin
			if (vga_request) begin
				if (is_first_frame) begin // 第一帧，显示黑色。
					vga_r <= 0;
					vga_g <= 0;
					vga_b <= 0;
				end
				else begin // 正式开始显示图像。
					if (200 <= vga_y && vga_y < 260) begin // 第一列。
						if (vga_x < 480) begin // 轨道。

						end
						else begin // 按键指示。

						end
					end
					else if (260 <= vga_y && vga_y < 320) begin // 第二列。
						if (vga_x < 480) begin // 轨道。

						end
						else begin // 按键指示。

						end
					end
					else if (320 <= vga_y && vga_y < 380) begin // 第三列。
						if (vga_x < 480) begin // 轨道。

						end
						else begin // 按键指示。

						end
					end
					else if (380 <= vga_y && vga_y < 440) begin // 第四列。
						if (vga_x < 480) begin // 轨道。

						end
						else begin // 按键指示。

						end
					end
					else begin // TODO: 其他位置。

					end
				end
			end
			else begin // 读取内存的后续事宜。

			end
		end
	end

endmodule