`timescale 1ns / 1ps
// Copyright (c) UnnamedOrange and Jack-Lyu. Licensed under the MIT License.
// See the LICENSE file in the repository root for full license text.

/// <projectname>mania-to-go</projectname>
/// <modulename>vga_t</modulename>
/// <filedescription>VGA �ķ�Ƶģ�顣</filedescription>
/// <version>
/// 0.0.1 (Jack-Lyu) : VGA�ķ�Ƶģ����ϡ�
/// </version>


module dcm_25m1(//�ķ�Ƶ��·
	input clk_in,
	input reset,
	output clk_out
    );
    
	reg CLK2=0;
    reg CLK4=0;
    
    always @(posedge clk_in) begin//����Ƶ
    	if(reset)
    		CLK2=0;
    	else 
    		CLK2=~CLK2;
    end
    always @(posedge CLK2) begin//�ķ�Ƶ
    	if(reset)
    		CLK4=0;
    	else 
    		CLK4=~CLK4;
    end
    
    assign clk_out = CLK4; 

endmodule
