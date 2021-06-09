// Copyright (c) UnnamedOrange and Jack-Lyu. Licensed under the MIT License.
// See the LICENSE file in the repository root for full license text.

/// <projectname>mania-to-go</projectname>
/// <modulename>bram_data_loader_t</modulename>
/// <filedescription>����Դ�� SD ���ж��������ŵ�ָ�� BRAM �С�</filedescription>
/// <version>
/// 0.0.1 (UnnamedOrange and Jack-Lyu) : First commit.
/// </version>

`timescale 1ns / 1ps

module bram_data_loader_t #
(
	parameter addr_width = 13,
	parameter data_width_in_byte = 3
)
(
	// BRAM��
	output [addr_width - 1 : 0] bram_addr_w,
	output [data_width_in_byte * 8 - 1 : 0] bram_data_in,
	output bram_en_w,

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

	// �ⲿ��Ϣ��
	input [7:0] song_selection,

	// ��λ��ʱ�ӡ�
	input RESET_L,
	input CLK
);



endmodule