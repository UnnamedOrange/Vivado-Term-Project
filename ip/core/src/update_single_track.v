// Copyright (c) UnnamedOrange and Jack-Lyu. Licensed under the MIT License.
// See the LICENSE file in the repository root for full license text.

/// <projectname>mania-to-go</projectname>
/// <modulename>update_single_track_t</modulename>
/// <filedescription>������� update ��������</filedescription>
/// <version>
/// 0.0.1 (UnnamedOrange) : �������������
/// </version>

`timescale 1ns / 1ps

module update_single_track_t #
(
	parameter __unused = 0
)
(
	// ���ơ�
	input sig_on,       // �յ� sig_on ʱ��ʼ������
	output sig_done,    // ������������ sig_done��

	// BRAM���˿� a ��д�˿ڣ��˿� b �Ƕ��˿ڡ�
	// beatmap������ʱ��㣩
	output [12:0] db_b_addr,
	input [23:0] db_b_data_out,
	output db_b_en,

	// object������
	output [11:0] do_a_addr,
	output [7:0] do_a_data_in,
	output do_a_en_w,
	output [12:0] do_b_addr,
	input [3:0] do_b_data_out,
	output do_b_en,

	// ���������ַ��
	input [12:0] db_size,         // ����ʱ���������������жϡ�û����һ������ʱ��㡱��
	input [12:0] db_base_addr,    // ����ʱ������ַ���� db_base_addr + i ���ʵ� i ������ʱ��㣬�±�� 0 ��ʼ��
	input [12:0] do_size,         // �����������
	input [12:0] do_base_addr,    // �������ַ���� do_base_addr + i ���ʵ� i �������±�� 0 ��ʼ��ע��д��ȥ��ʱ��λ��������ַλ��һλ��

	// ���̡�
	input is_key_down,       // �Ƿ��¼��̡�
	input is_key_changed,    // �����жϡ��¼���������

	// �������롣
	input [19:0] current_time, // ��ǰʱ�䣬��λΪ���롣���ڡ����³ɼ�����

	// ���������
	output is_game_over, // �Ƿ񡰴����ˡ���
	output is_miss,
	output is_bad,
	output is_good,
	output is_great,
	output is_perfect,

	// ��λ��ʱ�ӡ�
	input RESET_L,
	input CLK
);



endmodule