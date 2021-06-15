// Copyright (c) UnnamedOrange and Jack-Lyu. Licensed under the MIT License.
// See the LICENSE file in the repository root for full license text.

/// <projectname>mania-to-go</projectname>
/// <modulename>draw_controller_t</modulename>
/// <filedescription>��ͼ��Ҫ�����ݵĹ�������</filedescription>
/// <version>
/// 0.0.1 (UnnamedOrange) : �������������
/// 0.0.2 (UnnamedOrange) : ʵ�֡�
/// </version>

`timescale 1ns / 1ps

module draw_controller_t
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
	output reg [3:0] vga_r,
	output reg [3:0] vga_g,
	output reg [3:0] vga_b,
	input [9:0] vga_x, // �С�
	input [9:0] vga_y, // �С�
	input vga_request,

	// ��λ��ʱ�ӡ�
	input RESET_L,
	input CLK
);

	// ��ʼ������
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

	// ��ʾ��ʹ�ܡ�
	assign vga_reset = !is_working;

	// ƹ�ҡ�
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

	// TODO: �й�������

	// ��ɫ�����
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
				if (is_first_frame) begin // ��һ֡����ʾ��ɫ��
					vga_r <= 0;
					vga_g <= 0;
					vga_b <= 0;
				end
				else begin // ��ʽ��ʼ��ʾͼ��
					if (200 <= vga_y && vga_y < 260) begin // ��һ�С�
						if (vga_x < 480) begin // �����

						end
						else begin // ����ָʾ��

						end
					end
					else if (260 <= vga_y && vga_y < 320) begin // �ڶ��С�
						if (vga_x < 480) begin // �����

						end
						else begin // ����ָʾ��

						end
					end
					else if (320 <= vga_y && vga_y < 380) begin // �����С�
						if (vga_x < 480) begin // �����

						end
						else begin // ����ָʾ��

						end
					end
					else if (380 <= vga_y && vga_y < 440) begin // �����С�
						if (vga_x < 480) begin // �����

						end
						else begin // ����ָʾ��

						end
					end
					else begin // TODO: ����λ�á�

					end
				end
			end
			else begin // ��ȡ�ڴ�ĺ������ˡ�

			end
		end
	end

endmodule