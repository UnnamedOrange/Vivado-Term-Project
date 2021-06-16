// Copyright (c) UnnamedOrange and Jack-Lyu. Licensed under the MIT License.
// See the LICENSE file in the repository root for full license text.

/// <projectname>mania-to-go</projectname>
/// <modulename>update_single_track_t</modulename>
/// <filedescription>单条轨道 update 管理器。</filedescription>
/// <version>
/// 0.0.1 (UnnamedOrange) : 定义输入输出。
/// 0.0.2 (Jack-Lyu) : 模块完成，待验证。
/// </version>

`timescale 1ns / 1ps

module single_track_judge(
	input clk,
	input rst,
	input sig_on,
	input is_key_down,
	input is_key_changed,
	input [19:0] current_time,
	input [23:0] next_time,
	input [3:0] next_object,
	input over,
	output update,//用于提醒connect_BRAM对时间点和对象进行更新
	output [3:0] out_object,
	output [1:0] comb,
	output done,
	output is_game_over,
	output is_miss,
	output is_bad,
	output is_good,
	output is_great,
	output is_perfect,
	output start_end,
	input Connect_done
    );
    
    parameter tmiss=150;
    parameter tbad=80;
    parameter tgood=75;
    parameter tgreat=50;
    parameter tperfect=15;
  
  	parameter Over=4'b0;//GameOver,之后rst会复位
    parameter Idle=4'b01;//等待事件发生
    parameter Done=4'b10;//非更新结束
    parameter Disappear=4'b11;//方块或面条以消失结束，注意要在此状态改写out_object，comb，并计算评分,更新连击数
    parameter Discard=4'b100;//面条以遗弃结束
    parameter None=4'b101;//面条被按住不会消失也不会遗弃，但是要更新
    parameter N_Disappear=4'b110;//方块没有按到以消失结束
    
    reg Start_End=0;//为1代表next_time为面条start,为0代表next_time为面条end
    assign start_end = Start_End;
    always @(next_time) begin
    	if (next_object[0])
    		Start_End = Start_End + 1 ;
    end
    
    reg work;
    reg [3:0] curr_state;
    reg [3:0] next_state;   
    
    always @ (posedge clk) begin
    	if(rst)
    		curr_state <= Idle;
    	else if(over)
    		curr_state <= Over;
    	else
    		curr_state <= next_state;
    end
    
    always @(posedge clk) begin
    	if(Connect_done) begin
    		work <= 1;
    	end
    	work <= 0;
    end
    
    always @ (*) begin
    	if(!sig_on)
    		next_state = Idle ;
    	else if(!work)
    		next_state = Idle ;
    	else if(over)
    		next_state = Over ;
    	else begin
    		case(curr_state)
    			Over: next_state = (rst) ? Idle : Over ;
    			Idle: begin
    				if(!is_key_changed) begin// 没有事件发生
    					if(!next_object[0]) begin//下一个对象是方块
    						if( current_time > next_time & current_time - next_time > tmiss )//太晚
    							next_state = N_Disappear;
    						else 
    							next_state = Done;// 否则啥也不干
    					end
    					else begin// 下一个对象是面条
    						if(Start_End) begin//下一个对象时间点是面条起始
    							if( current_time > next_time & current_time - next_time > tmiss )//太晚
    								next_state = Discard;
    							else 
    								next_state = Done;// 否则啥也不干
    						end
    						else begin// 下一个对象时间点是面条终止
    							if( current_time > next_time & current_time - next_time > tmiss )//太晚
    								next_state = N_Disappear;
    							else 
    								next_state = Done;
    						end
    					end
    				end
    				else if(is_key_down) begin
    					if(!next_object[0]) begin//下个对象是方块
    						if( current_time < next_time & next_time - current_time > tmiss ) 
    							next_state = Done;
    						else 
    							next_state = Disappear;
    					end
    					else begin//下个对象是面条
    						if(Start_End) begin//下一个对象时间点是面条起始
    							if( current_time < next_time & next_time - current_time > tmiss )
    								next_state = Done;
    							else begin
    								if(( current_time < next_time & next_time - current_time > tbad )|( current_time > next_time & current_time - next_time > tbad ))
    									next_state = Discard;
    								else
    									next_state = None;
    							end
    						end
    						else begin
    							next_state = Done;
    							//此时面条一定被遗弃，啥也不做。
    						end
    					end
    				end
    				else begin//放开事件
    					if(!next_object[0]) begin//下一个对象是方块
    						next_state = Done;
    						// 啥也不做。
    					end
    					else begin// 下一个对象是面条
    						if(Start_End) begin//下一个对象时间点是面条起始
    							next_state = Done;
    							// 啥也不做。
    						end
    						else begin// 下一个对象时间点是面条终止
    							if( current_time < next_time & next_time - current_time > tmiss ) begin//太早
    								next_state = Discard;//遗弃面条, 连击数清零;
    							end
    							else begin
    								// 如果面条已被遗弃，更新成绩时最多记 OK。
    								next_state = Disappear;
    							end
    						end
    					end
    				end
    			end
    			Done: next_state = Idle;
    			Disappear: next_state = Idle;
    			Discard: next_state = Idle;
    			None: next_state = Idle;
    			N_Disappear: next_state = Idle;
    			default: next_state = Idle;
    		endcase
    	end
    end
    
    reg Update;//用于提醒connect_BRAM对时间点和对象进行更新
	reg [3:0] Out_object;
	reg [1:0] Comb;
	reg DONE;
	reg Is_game_over;
	reg Is_miss;
	reg Is_bad;
	reg Is_good;
	reg Is_great;
	reg Is_perfect;
	reg [19:0] delta_time;
    always @ (*) begin//输出
    	if(rst) begin//复位将输出均置为0
    		Comb=0        ;
    		Update=0      ;
    		DONE=0        ;
    		Is_game_over=0;
    		Is_miss=0     ;
    		Is_bad=0      ;  
    		Is_good=0     ;  
    		Is_great=0    ;  
    		Is_perfect=0  ;  
    	end
    	else begin
    		Out_object=next_object;
    		Is_game_over=0;
    		Is_miss=0     ;
    		Is_bad=0      ;  
    		Is_good=0     ;  
    		Is_great=0    ;  
    		Is_perfect=0  ;  
    		if(next_time > current_time)
    			delta_time = next_time - current_time ;
    		else
    			delta_time = current_time - next_time ;
			case(curr_state)
				Over: Is_game_over = 1 ;
				Idle: begin
					Comb = 2'b00;
					DONE = 0    ;
					Update=0    ;
				end
				Done: begin
					Comb = 2'b00;
					DONE = 1    ;
					Update=0    ;
					work=0      ;
				end
				Disappear: begin
					Comb = 2'b01;
					DONE = 1    ;
					Update=1    ;
					work=0      ;
					Out_object[1]=1;
					if( delta_time < tperfect )
						Is_perfect = 1 ;
					else if( delta_time < tgreat )
						Is_great = 1 ;
					else if( delta_time < tgood )
						Is_good = 1 ;
					else if( delta_time < tbad )
						Is_bad = 1 ;
					else if( delta_time < tmiss )
						Is_miss = 1 ;
				end
				Discard: begin
					Comb = 2'b10;
					DONE = 1    ;
					Update=1    ;
					Out_object[2]=1;
					Is_miss = 1 ;
					work=0      ;
				end
				None: begin
					Comb = 2'b01;
					DONE = 1    ;
					Update=1    ;
					work=0      ;
					if( delta_time < tperfect )
						Is_perfect = 1 ;
					else if( delta_time < tgreat )
						Is_great = 1 ;
					else if( delta_time < tgood )
						Is_good = 1 ;
					else if( delta_time < tbad )
						Is_bad = 1 ;
					else if( delta_time < tmiss )
						Is_miss = 1 ;
				end
				N_Disappear: begin
					Comb = 2'b10;
					DONE = 1    ;
					Update=1    ;
					work=0      ;
					Out_object[1]=1;
				end
				default: begin
					Comb = 2'b00;
					DONE = 0    ;
					Update=0    ;
					work=0      ;
				end
			endcase
		end
    end
    assign update = Update;
    assign out_object = out_object;
    assign comb = Comb;
    assign done = DONE;
    assign is_game_over = Is_game_over;
    assign is_miss = Is_miss;
    assign is_bad = Is_bad;
    assign is_good = Is_good;
    assign is_great = Is_great;
    assign is_perfect = Is_perfect;
    
endmodule
