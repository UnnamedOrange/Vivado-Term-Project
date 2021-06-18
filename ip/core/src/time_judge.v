// Copyright (c) UnnamedOrange and Jack-Lyu. Licensed under the MIT License.
// See the LICENSE file in the repository root for full license text.

/// <projectname>mania-to-go</projectname>
/// <modulename>time_judge_t</modulename>
/// <filedescription>时间判定器。输入两个时间，输出应该有的判定。组合逻辑。</filedescription>
/// <version>
/// 0.0.1 (UnnamedOrange) : First commit.
/// </version>

`timescale 1ns / 1ps

module time_judge_t #
(
	parameter t_perfect = 15,
	parameter t_great = 50,
	parameter t_good = 115,
	parameter t_bad = 150,
	parameter t_miss = 200,
	parameter t_offset = 0 // 键盘输入延迟修正。
)
(
	input [19:0] current_time,
	input [19:0] object_time,

	output reg too_early,
	output reg too_late,
	output reg in_perfect,
	output reg in_great,
	output reg in_good,
	output reg in_bad,
	output reg in_miss // 只有早到 miss，没有晚到 miss。
);

	wire [19:0] true_time;
	assign true_time = current_time - t_offset;

	always @(*) begin
		too_early = 0;
		too_late = 0;
		in_perfect = 0;
		in_great = 0;
		in_good = 0;
		in_bad = 0;
		in_miss = 0;

		if (true_time == object_time)
			in_perfect = 1;
		else if (true_time < object_time) begin // 物体在判定线上面。
			if (object_time - true_time <= t_perfect)
				in_perfect = 1;
			else if (object_time - true_time <= t_great)
				in_great = 1;
			else if (object_time - true_time <= t_good)
				in_good = 1;
			else if (object_time - true_time <= t_bad)
				in_bad = 1;
			else if (object_time - true_time <= t_miss)
				in_miss = 1;
			else
				too_early = 1;
		end
		else begin // 物体在判定线下面。
			if (true_time - object_time <= t_perfect)
				in_perfect = 1;
			else if (true_time - object_time <= t_great)
				in_great = 1;
			else if (true_time - object_time <= t_good)
				in_good = 1;
			else if (true_time - object_time <= t_bad)
				in_bad = 1;
			// else if (true_time - object_time <= t_miss)
			// 	in_miss = 1;
			else
				too_late = 1;
		end
	end

endmodule