// Copyright (c) UnnamedOrange and Jack-Lyu. Licensed under the MIT License.
// See the LICENSE file in the repository root for full license text.

/// <projectname>mania-to-go</projectname>
/// <modulename>bram_data_loader_t</modulename>
/// <filedescription>将资源从 SD 卡中读出，并放到指定 BRAM 中。</filedescription>
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
	// BRAM。
	output [addr_width - 1 : 0] bram_addr_w,
	output [data_width_in_byte * 8 - 1 : 0] bram_data_in,
	output bram_en_w,

	// 控制。
	input sig_on,
	output sig_done,

	// CPU 数据交互。
	output restart,
	output [7:0] init_index,
	output [7:0] init_aux_info,
	output request_data,
	input data_ready,
	input [7:0] cpu_data_in,

	// 外部信息。
	input [7:0] song_selection,

	// 复位与时钟。
	input RESET_L,
	input CLK
);



endmodule