// Copyright (c) UnnamedOrange and Jack-Lyu. Licensed under the MIT License.
// See the LICENSE file in the repository root for full license text.

/// <projectname>mania-to-go</projectname>
/// <modulename>cpu_data_transmitter</modulename>
/// <filedescription>CPU 数据传输器。</filedescription>
/// <version>
/// 0.0.1 (UnnamedOrange) : First commit.
/// 0.0.2 (UnnamedOrange) : 增大缓冲区大小。将输出改为同步输出。
/// </version>

`timescale 1 ns / 1 ps

module cpu_data_transmitter #
(
	parameter data_width = 32,
	parameter output_data_width = 8,
	parameter log_buf_size = 4,
	parameter buf_size = 1 << log_buf_size,
	parameter buf_size_mask = buf_size - 1
)
(
	output reg [output_data_width - 1 : 0] DATA_OUT,
	output reg DATA_READY,
	input REQUEST_DATA,
	input [7:0] INIT_INDEX,
	input [7:0] INIT_AUX_INFO,
	output [data_width - 1 : 0] REGISTER_OUT_0,
	output [data_width - 1 : 0] REGISTER_OUT_1,
	output [data_width - 1 : 0] REGISTER_OUT_2,
	output [data_width - 1 : 0] REGISTER_OUT_3,
	input [data_width - 1 : 0] REGISTER_IN_0,
	input [data_width - 1 : 0] REGISTER_IN_1,
	input [data_width - 1 : 0] REGISTER_IN_2,
	input [data_width - 1 : 0] REGISTER_IN_3,
	input RESET_L,
	input CLK
);

	reg [27:0] progress;
	reg [output_data_width * buf_size - 1 : 0] buffer, next_buffer;
	reg [log_buf_size - 1 : 0] st, next_st, ed, next_ed;

	reg request_data_from_host;

	always @(posedge CLK) begin
		if (!RESET_L || !REGISTER_IN_3[31]) begin
			progress <= 0;
			buffer <= 0;
			st <= 0;
			ed <= 0;
			DATA_OUT <= 0;
			DATA_READY <= 0;
		end
		else begin
			// 新数据一定在一个时钟周期内获得。
			progress <= REGISTER_IN_3[27:0];
			buffer <= next_buffer;
			st <= next_st;
			ed <= next_ed;
			if (REQUEST_DATA && st != ed)
				DATA_OUT <= next_buffer[st * output_data_width +: output_data_width];
			DATA_READY <= REQUEST_DATA && st != ed;
		end
	end

	always @* begin
		next_buffer = buffer;
		next_st = st;
		next_ed = ed;
		// 更新是否需要继续填充缓冲区。
		request_data_from_host = (buf_size - ((buf_size + ed - st) & buf_size_mask)) > 1;
		// 更新出队列。
		if (REQUEST_DATA && st != ed)
			next_st = (st + 1) & buf_size_mask;
		// 更新入队列。
		if (progress < REGISTER_IN_3[27:0]) begin
			next_buffer[ed * output_data_width +: output_data_width] = REGISTER_IN_0[output_data_width - 1 : 0];
			next_ed = (ed + 1) & buf_size_mask;
		end
	end

	assign REGISTER_OUT_0 = 0;
	assign REGISTER_OUT_1 = 0;
	assign REGISTER_OUT_2 = 0;
	assign REGISTER_OUT_3 = { request_data_from_host, 15'b0, INIT_AUX_INFO, INIT_INDEX };

endmodule