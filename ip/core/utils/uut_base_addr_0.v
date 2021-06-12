// Copyright (c) UnnamedOrange and Jack-Lyu. Licensed under the MIT License.
// See the LICENSE file in the repository root for full license text.

/// <projectname>mania-to-go</projectname>
/// <filedescription>基地址初始化测试（UUT）。</filedescription>
/// <version>
/// 0.0.1 (UnnamedOrange) : First commit.
/// </version>

`timescale 10ns / 1ps

module uut_base_addr_0();
	reg sig_get_base_addr_0_on;
	wire sig_get_base_addr_0_done;
	reg RESET_L;
	reg CLK;

	base_addr_0_t base_addr_0
	(
		.sig_get_base_addr_0_on(sig_get_base_addr_0_on),
		.sig_get_base_addr_0_done(sig_get_base_addr_0_done),
		.RESET_L(RESET_L),
		.CLK(CLK)
	);

	always begin
		#0.05;
		CLK = 1;
		#0.5;
		CLK = 0;
		#0.45;
	end

	initial begin
		RESET_L = 0;
		CLK = 0;
		sig_get_base_addr_0_on = 0;
		#10;
		RESET_L = 1;

		#3;
		sig_get_base_addr_0_on = 1;
		#1;
		sig_get_base_addr_0_on = 0;

		while (!sig_get_base_addr_0_done)
			#1;

		#5;
		$stop(1);
	end
endmodule

module uut_base_addr_1();
	reg sig_get_base_addr_1_on;
	wire sig_get_base_addr_1_done;
	reg RESET_L;
	reg CLK;

	base_addr_1_t base_addr_1
	(
		.sig_get_base_addr_1_on(sig_get_base_addr_1_on),
		.sig_get_base_addr_1_done(sig_get_base_addr_1_done),
		.RESET_L(RESET_L),
		.CLK(CLK)
	);

	always begin
		#0.05;
		CLK = 1;
		#0.5;
		CLK = 0;
		#0.45;
	end

	initial begin
		RESET_L = 0;
		CLK = 0;
		sig_get_base_addr_1_on = 0;
		#10;
		RESET_L = 1;

		#3;
		sig_get_base_addr_1_on = 1;
		#1;
		sig_get_base_addr_1_on = 0;

		while (!sig_get_base_addr_1_done)
			#1;

		#5;
		$stop(1);
	end
endmodule