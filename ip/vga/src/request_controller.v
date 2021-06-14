// Copyright (c) UnnamedOrange and Jack-Lyu. Licensed under the MIT License.
// See the LICENSE file in the repository root for full license text.

/// <projectname>mania-to-go</projectname>
/// <modulename>request_controller</modulename>
/// <filedescription>VGA 与Controller交互模块。</filedescription>
/// <version>
/// 0.0.1 (Jack-Lyu) : VGA与Controller交互模块模块搭建完毕。
/// </version>

`timescale 1ns / 1ps

module request_controller // 产生request信号
(
	input wire clk,
	input wire rst,
	input clk_25,//在clk_25的上升沿发送要request的下一个位置
	input [9:0] h_cnt,//输入为我正在显示哪个像素点
	input [9:0] v_cnt,
	input valid, // 是否是有效像素点。
	output [9:0] hcnt_request,
	output [9:0] vcnt_request,
	output request
);

	reg [9:0] HC;
	reg [9:0] VC;
	reg [1:0] REQ;

	always @(posedge clk) begin
		if(rst)
			REQ <= 0;
		else
			REQ <= REQ + 1;
	end

//    always @(*) begin
//    	n_REQ = REQ + 1;
//    	case(REQ)
//    		0: n_REQ = (clk_25==1) ? 1 : 0;
//    		1: n_REQ = 0;
//    		default: n_REQ = 0;
//    	endcase
//    end

	always @(posedge clk_25) begin
		if(rst) begin // rst之后控制器给我的数据要在第二个25M时钟周期再显示
			HC <= 0 ;//h从0~639
			VC <= 0 ; //v从0~479
		end
		else if (valid) begin
			if(h_cnt >= 639 | v_cnt >= 479) begin
				if(h_cnt >= 639 & v_cnt >= 479) begin
					HC <= 0 ;
					VC <= 0 ;
				end
				else if(h_cnt >= 639) begin
					HC <= 0;
					VC <= v_cnt+1;
				end
				else begin
					HC <= h_cnt+1;
					VC <= v_cnt;
				end
			end
			else if(h_cnt>=0 & h_cnt<639 & v_cnt>=0 & v_cnt<479)begin
				HC <= h_cnt+1;
				VC <= v_cnt;
			end
			else begin
				HC = 0;
				VC = 0;
			end
		end
	end
	assign hcnt_request = HC;
	assign vcnt_request = VC;
	assign request = REQ == 2'b1;

endmodule