// Copyright (c) UnnamedOrange and Jack-Lyu. Licensed under the MIT License.
// See the LICENSE file in the repository root for full license text.

/// <projectname>mania-to-go</projectname>
/// <modulename>draw_controller_t</modulename>
/// <filedescription>��ͼ��Ҫ�����ݵĹ�������</filedescription>
/// <version>
/// 0.0.1 (UnnamedOrange) : �������������
/// </version>

`timescale 1ns / 1ps

module draw_controller_t #
(
	parameter __unused = 0
)
(
	// ���ơ�
	input sig_on,
	output sig_done,

	// BRAM��
	output reg [12:0] do_b_addr,
	input [3:0] do_b_data_out,
	output reg do_b_en,

	output reg [12:0] dp_b_addr,
	input [31:0] dp_b_data_out,
	output reg dp_b_en,

	output reg [14:0] ds_b_addr,
	input [15:0] ds_b_data_out,
	output reg ds_b_en,

	// ���������ַ��
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

	// ���̡�
	input [3:0] is_key_down,

	// ��ǰλ�á�
	input [31:0] current_pixel,

	// TODO: ����������Ϣ��

	// VGA��
	output vga_reset,
	output [3:0] vga_r,
	output [3:0] vga_g,
	output [3:0] vga_b,
	input [9:0] vga_x, // �С�
	input [9:0] vga_y, // �С�
	input vga_request,

	// ��λ��ʱ�ӡ�
	input RESET_L,
	input CLK
);



endmodule