// Copyright (c) UnnamedOrange and Jack-Lyu. Licensed under the MIT License.
// See the LICENSE file in the repository root for full license text.

/// <projectname>mania-to-go</projectname>
/// <modulename>column_controller_t</modulename>
/// <filedescription>ÿ�й�����ݵ��ṩ�ߡ�</filedescription>
/// <version>
/// 0.0.1 (UnnamedOrange) : First commit.
/// </version>

`timescale 1ns / 1ps

module column_controller_t #
(
	// �ڲ�������
	parameter state_width = 8
)
(
	// ���ơ�
	input sig_refresh_on,
	output sig_refresh_done,
	input sig_next_line,

	// BRAM��
	output reg [12:0] do_b_addr,
	input [3:0] do_b_data_out,
	output reg do_b_en,

	output reg [12:0] dp_b_addr,
	input [31:0] dp_b_data_out,
	output reg dp_b_en,

	// ���������ַ��
	input [12:0] do_size,
	input [12:0] do_base_addr,
	input [12:0] dp_size,
	input [12:0] dp_base_addr,

	// ��ǰ����λ�á�
	input [31:0] current_pixel,

	// �����
	output is_click,
	output is_slide_begin,
	output is_slide_end,
	output [7:0] x_idx,

	// ��λ��ʱ�ӡ�
	input RESET_L,
	input CLK
);

	// ״̬���塣
	localparam [state_width - 1 : 0]
		s_init              = 8'h00, // �ȴ���
		s_refresh_init      = 8'h01, // ��ʼ��ʼ��
		s_refresh_done      = 8'h0f, // ˢ����ɡ�
		s_next_line_init    = 8'h11, // �л�����һ�С�
		s_unused = 8'hff;
	reg [state_width - 1 : 0] state, n_state;

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
				if (sig_refresh_on)
					n_state = s_refresh_init;
				else if (sig_next_line)
					n_state = s_next_line_init;
				else
					n_state = s_init;
			default:
				n_state = s_init;
		endcase
	end

	// ������̡�
	assign sig_refresh_done = state == s_refresh_done;

endmodule