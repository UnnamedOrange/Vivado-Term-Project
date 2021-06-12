// Copyright (c) UnnamedOrange and Jack-Lyu. Licensed under the MIT License.
// See the LICENSE file in the repository root for full license text.

/// <projectname>mania-to-go</projectname>
/// <filedescription>基地址初始化测试。</filedescription>
/// <version>
/// 0.0.1 (UnnamedOrange) : First commit.
/// </version>

`timescale 1ns / 1ps

module base_addr_0_t
(
	input sig_get_base_addr_0_on,
	output reg sig_get_base_addr_0_done,
	input RESET_L,
	input CLK
);

	reg [12:0] db_addr_r;
	wire [23:0] db_data_out;
	reg db_en_r;

	blk_mem_gen_0 mem1
	(
		.addra(db_addr_r),
		.ena(db_en_r),
		.clka(CLK),
		.douta(db_data_out)
	);

	reg [12:0] db_size[0:3];
	reg [12:0] db_base_addr[0:3];

	integer i;
	reg [2:0] which;
	reg [1:0] pat;

	always @(posedge CLK) begin: get_base_addr_0_t
		if (!RESET_L) begin
			for (i = 0; i < 4; i = i + 1)
				db_size[i] <= 0;
			for (i = 0; i < 4; i = i + 1)
				db_base_addr[i] <= 0;
			sig_get_base_addr_0_done <= 0;
			which <= 0;
			pat <= 0;
			db_en_r <= 0;
			db_addr_r <= 0;
		end
		else begin
			if (!which[2]) begin
				if (sig_get_base_addr_0_on)
					which[2] <= 1;
			end
			else begin
				if (pat == 0) begin
					if (which[1:0] == 2'd0)
						db_addr_r <= 0;
					else
						db_addr_r <= db_base_addr[which[1:0] - 1] + db_size[which[1:0] - 1];
					db_en_r <= 1;
				end
				else if (pat == 3) begin
					db_size[which[1:0]] <= db_data_out;
					if (which[1:0] == 2'd0)
						db_base_addr[0] <= 1;
					else
						db_base_addr[which[1:0]] <= db_base_addr[which[1:0] - 1] + db_size[which[1:0] - 1] + 1;
					db_en_r <= 0;
					if (which[1:0] < 3)
						which[1:0] <= which[1:0] + 1;
					else
						which <= 3'b0;
				end
				pat <= pat + 1;
			end
			sig_get_base_addr_0_done <= which == 3'b111 && pat == 2'b11;
		end
	end

endmodule

module base_addr_1_t
(
	input sig_get_base_addr_1_on,
	output reg sig_get_base_addr_1_done,
	input RESET_L,
	input CLK
);

	reg [12:0] do_addr_r;
	wire [3:0] do_data_out;
	reg do_en_r;

	blk_mem_gen_1 mem1
	(
		.addrb(do_addr_r),
		.enb(do_en_r),
		.clkb(CLK),
		.doutb(do_data_out)
	);

	reg [12:0] do_size[0:3];
	reg [12:0] do_base_addr[0:3];

	integer i;
	reg [2:0] which;
	reg [1:0] part;
	reg [1:0] pat;

	always @(posedge CLK) begin: get_base_addr_1_t
		if (!RESET_L) begin
			for (i = 0; i < 4; i = i + 1)
				do_size[i] <= 0;
			for (i = 0; i < 4; i = i + 1)
				do_base_addr[i] <= 0;
			sig_get_base_addr_1_done <= 0;
			which <= 0;
			part <= 0;
			pat <= 0;
			do_en_r <= 0;
			do_addr_r <= 0;
		end
		else begin
			if (!which[2]) begin
				if (sig_get_base_addr_1_on)
					which[2] <= 1;
			end
			else begin
				if (pat == 0) begin
					if (which[1:0] == 2'd0)
						do_addr_r <= part;
					else
						do_addr_r <= do_base_addr[which[1:0] - 1] + do_size[which[1:0] - 1] + part;
					do_en_r <= 1;
				end
				else if (pat == 3) begin
					do_size[which[1:0]][part * 4 +: 4] <= do_data_out;
					part <= part + 1;
					do_en_r <= 0;
					if (part == 2'b11) begin
						if (which[1:0] == 2'd0)
							do_base_addr[0] <= 4;
						else
							do_base_addr[which[1:0]] <= do_base_addr[which[1:0] - 1] + do_size[which[1:0] - 1] + 4;

						if (which[1:0] < 3)
							which[1:0] <= which[1:0] + 1;
						else
							which <= 3'b0;
					end
				end
				pat <= pat + 1;
			end
			sig_get_base_addr_1_done <= which == 3'b111 && part == 2'b11 && pat == 2'b11;
		end
	end

endmodule