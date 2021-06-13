`timescale 1ns / 1ps
// Copyright (c) UnnamedOrange and Jack-Lyu. Licensed under the MIT License.
// See the LICENSE file in the repository root for full license text.

/// <projectname>mania-to-go</projectname>
/// <modulename>keyboard_t</modulename>
/// <filedescription>键盘输入。</filedescription>
/// <version>
/// 0.0.2 (UnnamedOrange and Jack-Lyu) : It can work
/// </version>


module keyboard_t(
	input kbdata,
	input kbclk,
	input clk,
	input reset,
	output [3:0] DOWN,
	output [3:0] CHANGE
    );
    
    wire [15:0] keycode;
    wire oflag;
    reg [3:0] down;
    reg [3:0] n_down;
    reg [3:0] change;
    reg [3:0] n_change ;
    
    PS2scan u1 (
    .clk(clk),                  
	.kclk(kbclk),
	.kdata(kbdata),                
	.keycode(keycode),//out
	.oflag(oflag)//out
	);
	
	parameter Ecode=8'h24;
	parameter Rcode=8'h2D;
	parameter Ucode=8'h3C;
	parameter Icode=8'h43;
	
	always @(posedge clk) begin
		change <= n_change;
		down <= n_down;
	end
	
	always @(*) begin  //组合逻辑设计
		n_down=down;
    	n_change=change;
    	if(reset) begin
    		n_down=4'b0;
    		n_change=4'b0;
    	end
    	else if (!oflag) begin
    		n_change=4'b0;
    	end
 		else if(keycode[15:8] == 8'hf0) begin//确定要松开的键
    		case(keycode[7:0])
    			Ecode: begin n_down[0]=0 ; n_change[0]=1; end 
    			Rcode: begin n_down[1]=0 ; n_change[1]=1; end 
    			Ucode: begin n_down[2]=0 ; n_change[2]=1; end 
    			Icode: begin n_down[3]=0 ; n_change[3]=1; end 
    		endcase
    	end
    	else begin
    		case(keycode[7:0])
    			Ecode: begin n_down[0]=1 ; n_change[0]=1; end 
    			Rcode: begin n_down[1]=1 ; n_change[1]=1; end 
    			Ucode: begin n_down[2]=1 ; n_change[2]=1; end 
    			Icode: begin n_down[3]=1 ; n_change[3]=1; end  
    		endcase
    	end
    end
    
    assign DOWN = down;
    assign CHANGE = change;
    
endmodule
