`timescale 1ns / 1ps

// Copyright (c) UnnamedOrange and Jack-Lyu. Licensed under the MIT License.
// See the LICENSE file in the repository root for full license text.

/// <projectname>mania-to-go</projectname>
/// <modulename>update_single_track_t</modulename>
/// <filedescription>������� update ��������</filedescription>
/// <version>
/// 0.0.1 (UnnamedOrange) : �������������
/// 0.0.2 (Jack-Lyu) : ģ����ɣ�����֤��

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
	input [12:0] db_size,         // ����ʱ���������������ж�"û����һ������ʱ���"��
	input [12:0] db_base_addr,    // ����ʱ������ַ���� db_base_addr + i ���ʵ� i ������ʱ��㣬�±�� 0 ��ʼ��
	input [12:0] do_size,         // �����������
	input [12:0] do_base_addr,    // �������ַ���� do_base_addr + i ���ʵ� i �������±�� 0 ��ʼ��ע��д��ȥ��ʱ��λ��������ַλ��һλ��

	// ���̡�
	input is_key_down,       // �Ƿ��¼��̡�
	input is_key_changed,    // �����ж�"�¼�����"��

	// �������롣
	input [19:0] current_time, // ��ǰʱ�䣬��λΪ���롣����"���³ɼ�"��

	// ���������
	output is_game_over, // �Ƿ�"������"��
	output [1:0] comb,
	output is_miss,
	output is_bad,
	output is_good,
	output is_great,
	output is_perfect,

	// ��λ��ʱ�ӡ�
	input RESET_L,
	input CLK
);
	
	reg reset;
	
	always @ (posedge CLK)
		reset <= RESET_L;

	
	connect_BRAM u0 (.clk(CLK),.rst(reset),
	.update(update),.next_time(nextt),.next_object(nexto),
	.get_time(db_b_data_out),.get_object(do_b_data_out),.over(gameover),
	.db_size(db_size),.db_base_addr(db_base_addr),
	.db_b_addr(db_b_addr),.db_b_en(db_b_en),.do_size(do_size),.do_base_addr(do_base_addr),
	.do_a_addr(do_a_addr),.do_a_data_in(do_a_data_in),.do_a_en_w(do_a_en_w),.do_b_addr(do_b_addr),.do_b_en(do_b_en),
	.start_end(start_end),.connect_done(Connect_done)
	);
	
	single_track_judge u1 (.clk(CLK),.rst(reset),.sig_on(sig_on),
	.is_key_down(is_key_down),.is_key_changed(is_key_changed),
	.current_time(current_time),
	.next_time(nextt),.next_object(nexto),
	.done(sig_done),.over(gameover),.comb(comb),.update(update),
	.is_game_over(is_game_over),.is_miss(is_miss),.is_bad(is_bad),.is_good(is_good),.is_great(is_great),.is_perfect(is_perfect),
	.start_end(start_end),.Connect_done(connect_done)
	);
	

endmodule
