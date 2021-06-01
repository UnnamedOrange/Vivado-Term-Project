// Copyright (c) UnnamedOrange and Jack-Lyu. Licensed under the MIT License.
// See the LICENSE file in the repository root for full license text.

/// <projectname>mania-to-go</projectname>
/// <modulename>core_t</modulename>
/// <filedescription>����ģ�顣</filedescription>
/// <version>
/// 0.0.1 (UnnamedOrange and Jack-Lyu) : First commit.
/// </version>

`timescale 1ns / 1ps

module core_t #
(
	// SD ��ģ�顣
	parameter song_data_width = 8
)
(
	// ����ģ�顣
	input [3:0] IS_KEY_DOWN,
	input [3:0] IS_KEY_CHANGED,

	// SD ��ģ�顣
	output [7:0] INIT_INDEX,
	output [7:0] INIT_AUX_INFO,
	input [song_data_width - 1 : 0] SONG_DATA_IN,
	input SONG_DATA_READY,
	output REQUEST_SONG_DATA,

	// ��Ƶģ�顣
	output [song_data_width - 1 : 0] MAIN_AUDIO_OUT,
	output MAIN_AUDIO_EN,
	output [3:0] MAIN_AUDIO_VOLUMN,
	output [song_data_width - 1 : 0] AUX_AUDIO_OUT,
	output AUX_AUDIO_EN,
	output [3:0] AUX_AUDIO_VOLUMN,
	output AUDIO_EN,

	// VGA ģ�顣
	output [0:0] DATA_TODO, // TODO

	// ��λ��ʱ�ӡ�
	input RESET_L,
	input CLK
);



endmodule