// Copyright (c) UnnamedOrange and Jack-Lyu. Licensed under the MIT License.
// See the LICENSE file in the repository root for full license text.

/// <projectname>mania-to-go</projectname>
/// <modulename>request_controller</modulename>
/// <filedescription>VGA ��Controller����ģ�顣</filedescription>
/// <version>
/// 0.0.1 (Jack-Lyu) : VGA��Controller����ģ��ģ����ϡ�
/// </version>

`timescale 1ns / 1ps

module request_controller // ����request�ź�
(
	input wire clk,
	input wire rst,
	input clk_25,//��clk_25�������ط���Ҫrequest����һ��λ��
	input [9:0] h_cnt,//����Ϊ��������ʾ�ĸ����ص�
	input [9:0] v_cnt,
	input valid, // �Ƿ�����Ч���ص㡣
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
		if(rst) begin // rst֮����������ҵ�����Ҫ�ڵڶ���25Mʱ����������ʾ
			HC <= 0 ;//h��0~639
			VC <= 0 ; //v��0~479
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