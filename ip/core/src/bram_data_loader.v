// Copyright (c) UnnamedOrange and Jack-Lyu. Licensed under the MIT License.
// See the LICENSE file in the repository root for full license text.

/// <projectname>mania-to-go</projectname>
/// <modulename>bram_data_loader_t</modulename>
/// <filedescription>����Դ�� SD ���ж��������ŵ�ָ�� BRAM �С�</filedescription>
/// <version>
/// 0.0.1 (UnnamedOrange) : First commit.
/// </version>

`timescale 1ns / 1ps

module bram_data_loader_t #
(
	parameter addr_width = 13,
	parameter data_width_in_byte = 3,
	parameter [7:0] static_init_aux_info = 8'b00000000,
	parameter restarting_timeout = 1000000
)
(
	// BRAM��
	output reg [addr_width - 1 : 0] bram_addr_w,
	output [data_width_in_byte * 8 - 1 : 0] bram_data_in,
	output reg bram_en_w,

	// ���ơ�
	input sig_on,
	output sig_done,

	// CPU ���ݽ�����
	output restart,
	output [7:0] init_index,
	output [7:0] init_aux_info,
	output request_data,
	input data_ready,
	input [7:0] cpu_data_in,
	input transmit_finished,

	// �ⲿ��Ϣ��
	input [7:0] song_selection,

	// ��λ��ʱ�ӡ�
	input RESET_L,
	input CLK
);

	// ״̬���塣
	localparam state_width = 3;
	localparam [state_width - 1 : 0]
		s_init =       0, // �ȴ�����ʹ�ܡ�
		s_restarting = 1, // �ȴ� CPU ��ʼ����
		s_standby =    2, // ��һ�����
		s_read =       3, // �����ݵ���������
		s_write =      4, // ����������д���ݵ� BRAM��
		s_done =       5, // ��������������ɡ�
		s_unused = 0;
	reg [state_width - 1 : 0] state, n_state;

	// ��ʱ����
	reg [24:0] timer;
	always @(posedge CLK) begin
		if (!RESET_L) begin
			timer <= 0;
		end
		else begin
			if (state == s_restarting || state == s_standby) begin
				if (timer == restarting_timeout - 1)
					timer <= 0;
				else
					timer <= timer + 1;
			end
		end
	end

	// ���塣
	reg [data_width_in_byte * 8 - 1 : 0] cache;
	reg [3:0] dumped;

	// ������������
	always @(posedge CLK) begin
		if (!RESET_L) begin
			cache <= 0;
			dumped <= 0;
		end
		else begin
			if (data_ready) begin
				if (data_width_in_byte == 1)
					cache <= cpu_data_in;
				else
					cache <= {cpu_data_in, cache[data_width_in_byte * 8 - 1: 8]};
				if (dumped == data_width_in_byte - 1)
					dumped <= 0;
				else
					dumped <= dumped + 1;
			end
		end
	end

	// д BRAM ��ء�
	reg hold_on;

	always @(posedge CLK) begin
		if (!RESET_L) begin
			bram_addr_w <= 0;
			bram_en_w <= 0;
			hold_on <= 0;
		end
		else begin
			if (state == s_write) begin
				if (!hold_on) begin
					bram_en_w <= 1;
					hold_on <= 1;
				end
				else begin
					bram_addr_w <= bram_addr_w + 1;
					bram_en_w <= 0;
					hold_on <= 0;
				end
			end
		end
	end

	// �������̡�
	always @(posedge CLK) begin
		if (!RESET_L) begin
			state <= s_init;
		end
		else begin
			state <= n_state;
		end
	end

	// �������̡�
	always @(*) begin
		case (state)
			s_init:
				n_state = sig_on ? s_restarting : s_init;
			s_restarting:
				n_state = timer == restarting_timeout - 1 ? s_standby : s_restarting;
			s_standby:
				n_state = timer == restarting_timeout - 1 ? s_read : s_standby;
			s_read:
				n_state = transmit_finished ? s_write : (dumped == data_width_in_byte - 1 && data_ready ? s_write : s_read);
			s_write:
				n_state = hold_on == 1 ? (transmit_finished ? s_done : s_read) : s_write;
			s_done:
				n_state = s_init;
			default:
				n_state = s_init;
		endcase
	end

	// ������̡�
	assign sig_done = state == s_done;
	assign restart = state == s_restarting;
	assign init_index = song_selection;
	assign init_aux_info = static_init_aux_info;
	assign request_data = state == s_read;

	assign bram_data_in = cache;

endmodule