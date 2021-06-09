// Copyright (c) UnnamedOrange and Jack-Lyu. Licensed under the MIT License.
// See the LICENSE file in the repository root for full license text.

/// <projectname>mania-to-go</projectname>
/// <modulename>fifo_controller_t</modulename>
/// <filedescription>用于 cpu_data_transmitter 的 FIFO 管理器。</filedescription>
/// <version>
/// 0.0.1 (UnnamedOrange) : First commit.
/// </version>

`timescale 1ns / 1ps

module fifo_controller_t #
(
	parameter data_width = 8
)
(
	// 面向 FIFO 的输入输出。
	output Q_REN,
	input Q_EMPTY,
	input [data_width - 1 : 0] Q_OUT,
	input Q_VALID,
	output Q_WEN,
	input Q_FULL,
	output [data_width - 1 : 0] Q_IN,
	output Q_RST,

	// 面向 CPU Data Transmitter 的输入输出。
	output C_REQUEST_DATA,
	output C_RESTART,
	input [data_width - 1 : 0] C_DATA_OUT,
	input C_DATA_READY,
	input C_TRANSMIT_FINISHED,

	// 对外的输入输出。
	input REQUEST_DATA,
	input RESTART,
	output [data_width - 1 : 0] DATA_OUT,
	output DATA_READY,
	output TRANSMIT_FINISHED,

	// 复位。
	input RESET_L
);

	// 复位。
	assign Q_RST = !RESET_L || RESTART;
	assign C_RESTART = RESTART;

	// CPU 输入。
	assign C_REQUEST_DATA = !Q_FULL;

	// CPU 输出，FIFO 输入。
	assign Q_IN = C_DATA_OUT;
	assign Q_WEN = C_DATA_READY;

	// FIFO 输出。
	assign Q_REN = REQUEST_DATA && !Q_EMPTY;
	assign DATA_OUT = Q_OUT;
	assign DATA_READY = Q_VALID;
	assign TRANSMIT_FINISHED = C_TRANSMIT_FINISHED && Q_EMPTY;

endmodule