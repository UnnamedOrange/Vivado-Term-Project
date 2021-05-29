// Copyright (c) UnnamedOrange and Jack-Lyu. Licensed under the MIT Licence.
// See the LICENSE file in the repository root for full licence text.

/// <projectname>PmodAMP3</projectname>
/// <modulename>PmodAMP3</modulename>
/// <projectdescription>An unofficial IP core of Pmod AMP3.</projectdescription>
/// <version>
/// 0.0.1 (UnnamedOrange) : First commit.
/// 0.0.2 (UnnamedOrange) : ���ݷ����������롣
/// </version>

`timescale 1ns / 1ps

module PmodAMP3 #
(
	parameter sample_rate = 44100,
	parameter resolution = 8,
	parameter is_stereo = 0,
	parameter MCLK_ratio = resolution == 24 ? 384 : 256,
	parameter MCLK_freq = sample_rate * MCLK_ratio,
	parameter BCLK_freq = sample_rate * resolution * 2,
	parameter MCLK_divided_by_BCLK = MCLK_freq / BCLK_freq,
	parameter width = resolution * (1 + is_stereo),

	parameter log_MCLK_divided_by_BCLK =
		MCLK_divided_by_BCLK == 4 ? 2 :
		MCLK_divided_by_BCLK == 8 ? 3 :
		MCLK_divided_by_BCLK == 16 ? 4 : 114514
)
(
	output EX_LRCLK,
	output EX_SDATA,
	output EX_BCLK,
	output EX_MCLK,
	input [width - 1 : 0] SAMPLE,
	input EN,
	input RESET_L,
	input CLK // ���� 100 MHz ʱ�ӡ�
);

	reg [width - 1 : 0] sync_sample_buffer, sync_sample; // ͬ������
	reg sync_en_buffer, sync_en; // ͬ������
	reg [log_MCLK_divided_by_BCLK - 1 : 0] divide_to_bclk; // ��Ƶ����

	reg [width - 1 : 0] to_play; // �����ֵ��
	reg [5:0] current_bit; // ��ǰ�ǵڼ�λ��
	reg is_LRCLK_right; // ��������ʱ�ӡ�
	reg is_left; // ��ǰ���ĸ�������

	assign EX_MCLK = CLK;
	assign EX_BCLK = !divide_to_bclk[log_MCLK_divided_by_BCLK - 1];

	// ͬ������
	always @(posedge CLK) begin
		if (!RESET_L) begin
			sync_sample_buffer <= 0;
			sync_sample <= 0;
			sync_en_buffer <= 0;
			sync_en <= 0;
		end
		else begin
			sync_sample_buffer <= SAMPLE;
			sync_sample <= sync_sample_buffer;
			sync_en_buffer <= EN;
			sync_en <= sync_en_buffer;
		end
	end

	// ��Ƶ����������һ���в���������
	always @(posedge CLK) begin
		if (!RESET_L) begin
			divide_to_bclk <= 0;
		end
		else begin
			divide_to_bclk <= divide_to_bclk + 1;
		end
	end

	// BCLK ������ʱ����
	always @(posedge CLK) begin // ����ͬ��ʱ����ơ�
		if (!RESET_L) begin
			to_play <= 0;
			current_bit <= 0;
			is_LRCLK_right <= 0;
			is_left <= 0;
		end
		else if (divide_to_bclk == MCLK_divided_by_BCLK - 1) begin // BCLK �����غ�ĵ�һ��ʱ��ʱ��
			if (current_bit == 0) begin
				if (is_LRCLK_right == 0) // ׼�������µ����ݡ�
					if (sync_en)
						to_play <= sync_sample;
					else
						to_play <= 0;
				current_bit <= resolution - 1;
				// ���� is_left��
				is_left <= !is_left;
				// is_LRCLK_right ���ֲ��䡣
			end
			else begin
				// ���� is_LRCLK_right��
				if (current_bit == 1)
					is_LRCLK_right <= !is_LRCLK_right;
				current_bit <= current_bit - 1;
			end
		end
	end

	assign EX_LRCLK = is_LRCLK_right;
	assign EX_SDATA = (is_stereo && !is_left) ? to_play[resolution + current_bit] : to_play[current_bit];

endmodule