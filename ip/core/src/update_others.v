// Copyright (c) UnnamedOrange and Jack-Lyu. Licensed under the MIT License.
// See the LICENSE file in the repository root for full license text.

/// <projectname>mania-to-go</projectname>
/// <modulename>update_others_t</modulename>
/// <filedescription>update ������Ϣ������ʱ�䡢���ء��ܷ�����</filedescription>
/// <version>
/// 0.0.1 (UnnamedOrange) : First commit.
/// </version>

`timescale 1ns / 1ps

module update_others_t #
(
	// �ڲ�������
	parameter state_width = 4
)
(
	// ���ơ�
	input sig_on,
	output sig_done,

	// BRAM��
	output reg [11:0] dt_b_addr,
	input [31:0] dt_b_data_out,
	output reg dt_b_en,

	// ���������ַ��
	input [11:0] dt_size,
	input [11:0] dt_base_addr, // == 2

	// ��Ϸ״̬��
	input [3:0] is_game_over,
	input [7:0] comb,
	input [3:0] is_miss,
	input [3:0] is_bad,
	input [3:0] is_good,
	input [3:0] is_great,
	input [3:0] is_perfect,
	input [19:0] song_length,

	// ��Ҫ��Ϊ����ı�����
	output reg [19:0] current_time,
	output reg [31:0] current_pixel,

	// ��λ��ʱ�ӡ�
	input RESET_L,
	input CLK
);

	// ������
	reg [11:0] current_speed;
	reg [11:0] current_offset;

	// ״̬���塣
	localparam [state_width - 1 : 0]
		s_init                     = 4'd0,       // ��λ��
		s_update_speed             = 4'd1,       // �����ٶȡ�
		s_w_update_speed           = 4'd2,       // �ȴ������ٶȡ�
		s_update_time_and_pixel    = 4'd3,       // ����ʱ������ء�
		s_done                     = 4'b1111,    // ��ɡ�
		s_unused = 4'b1111;
	reg [state_width - 1 : 0] state, n_state;

	// ��ȡ�������ٶȡ�
	wire sig_update_speed_on;
	reg sig_update_speed_done;
	always @(posedge CLK) begin : update_speed_t
		reg working;
		reg [1:0] pat;

		if (!RESET_L) begin
			current_speed <= 0;
			current_offset <= 0;
			working <= 0;
			pat <= 0;
			sig_update_speed_done <= 0;
			dt_b_addr <= 0;
			dt_b_en <= 0;
		end
		else begin
			if (!working) begin
				if (sig_update_speed_on)
					working <= 1;
			end
			else begin
				if (pat == 0) begin
					dt_b_en <= 1;
					dt_b_addr <= dt_base_addr + current_offset;
				end
				else if (pat == 3) begin
					dt_b_en <= 0;
					working <= 0;
					// �����ٶȡ�
					if (dt_b_data_out[19:0] == current_time) begin
						current_speed <= dt_b_data_out[31:20];
						current_offset <= current_offset + 1;
					end
				end
				pat <= pat + 1;
			end
			sig_update_speed_done <= working && pat == 2'b11;
		end
	end

	// ����ʱ���λ�á�
	always @(posedge CLK) begin
		if (!RESET_L) begin
			current_time <= 0;
			current_pixel <= 0;
		end
		else begin
			if (state == s_update_time_and_pixel) begin
				if (current_time < song_length) begin
					current_time <= current_time + 1;
					current_pixel <= current_pixel + current_speed;
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
				n_state = sig_on ? ((current_offset < dt_size) ? s_update_speed : s_update_time_and_pixel) : s_init;
			s_update_speed:
				n_state = s_w_update_speed;
			s_w_update_speed:
				n_state = sig_update_speed_done ? s_update_time_and_pixel : s_w_update_speed;
			s_update_time_and_pixel:
				n_state = s_done;
			s_done:
				n_state = s_init;
			default:
				n_state = s_init;
		endcase
	end

	// ������̡�
	assign sig_done = state == s_done;
	assign sig_update_speed_on = state == s_update_speed;

endmodule