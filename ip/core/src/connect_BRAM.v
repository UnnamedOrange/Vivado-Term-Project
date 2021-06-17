`timescale 1ns / 1ps
// Copyright (c) UnnamedOrange and Jack-Lyu. Licensed under the MIT License.
// See the LICENSE file in the repository root for full license text.

/// <projectname>mania-to-go</projectname>
/// <modulename>update_single_track_t</modulename>
/// <filedescription>单条轨道 update 管理器。</filedescription>
/// <version>
/// 0.0.1 (UnnamedOrange) : 定义输入输出。
/// 0.0.2 (Jack-Lyu) : 模块完成，待验证。
/// </version>


module connect_BRAM(
	input clk,
	input rst,
	input update,//在update时把要到的信号给发送出去，并要下一拍的信号
	input start_end,//为0代表读到的面条为start，为1代表读到的面条为end，只在end处加cnt_object
	
	input [23:0] get_time,
	input [3:0] get_object,
	input [3:0] out_object,
	//用于判定是否gameover
	input [12:0] db_size,       
	input [12:0] db_base_addr,  
	input [12:0] do_size,       
	input [12:0] do_base_addr,  
	//读time
	output [12:0] db_b_addr,
	output db_b_en,
	//读object
	output [12:0] do_b_addr,
	output do_b_en,
	//写object
	output [11:0] do_a_addr,
	output [7:0] do_a_data_in,
	output do_a_en_w,
	//真正的模块内输出
	output [23:0] next_time,
	output [3:0] next_object,
	output is_game_over,
	output Connect_done
	
    );
	
	reg [23:0] This_time;
	reg [3:0] PON_object;
	reg [3:0] This_object;
	reg [12:0] addr_r_time;
	reg [12:0] addr_r_object;
	reg [12:0] addr_next_object;
	reg [12:0] addr_post_object;
	reg [11:0] addr_w_object;
	reg en_r_time;
	reg en_r_object;
	reg en_w_object;
	reg [7:0] Object_w;
	reg game_over;
	reg connect_done;
	
	assign Connect_done = connect_done;
	assign is_game_over = game_over;
	assign do_a_data_in = Object_w;
	assign next_time = This_time ;
	assign next_object = This_object ;
	assign db_b_addr = addr_r_time;
	assign do_b_addr = addr_r_object;
	assign do_a_addr = addr_w_object;
	assign db_b_en = en_r_time;
	assign do_b_en = en_r_object;
	assign do_a_en_w = en_w_object;
	
    parameter Idle =  4'b0000;
    parameter Write = 4'b0001;
    parameter Read =  4'b0010;
    parameter Over =  4'b0011;
    parameter NextR = 4'b0100;
    parameter Done =  4'b0101;
    
    reg begin_write;
    reg begin_read;
    
    
//address	
	reg [12:0] cnt_beatmap;
	reg [12:0] cnt_object;
	reg [12:0] visiting_time;
	reg [12:0] visiting_object;
    always @(*) begin
    	visiting_time = db_base_addr + cnt_beatmap ;
    	visiting_object =  do_base_addr + cnt_object ;
    end
    
//状态机
    reg [3:0] curr_state;
    reg [3:0] next_state;
    reg Reading;
    always @ (posedge clk) begin
        if(rst) begin
            curr_state <= Idle;
        end
        else
            curr_state <= next_state;
    end 

    always @(*) begin
        if (rst) begin
            next_state = Idle;
        end
        else begin
            case(curr_state)
            	Over:begin
            		next_state = Over ;
            	end
                Idle:begin
                    if (!update) begin
                        next_state = Idle;
                    end
                    else begin
                        if( cnt_beatmap == db_size) begin
                            next_state = Over;
                        end
                        else begin
                            next_state = Write;
                        end
                    end
                end
                Read: begin
                    if(Reading) begin
                        next_state = NextR;
                    end
                    else begin
                        next_state = Read;
                    end
                end
                NextR:begin
                    if(Reading) begin
                        next_state = NextR;
                    end
                    else begin
                        next_state = Done;
                    end
                end
                Write:begin
                    next_state = Read;
                end
                Done:begin
                	next_state = Idle;
                end
                default: next_state = Idle;
            endcase
        end
    end
	
//Read
    reg [2:0] pat;
    always @ (posedge clk) begin
        if (rst) begin
            pat <= 0;
            Reading <= 0;
            This_object <= 0;
            This_time <= 0;
            addr_r_time<=0;
            en_r_time<=0;
            en_r_object<=0;
            addr_r_object<=0;
            PON_object<=0;
        end
        else begin
            if (!Reading) begin
                if ( begin_read )
                    Reading <= 1;
            end
            else begin         
                if (pat == 0) begin
                    addr_r_time <= visiting_time;
                    en_r_time <= 1;
                    addr_r_object <= visiting_object ;
                    en_r_object <= 1 ;
                end
                else if (pat == 3) begin
                //读完这一个
                    This_time <= get_time;
                    en_r_time <= 0;
                    This_object <= get_object;
                //读另一个  object
                if( visiting_object[0] ) begin//读上一个
                    addr_r_object <= visiting_object - 1 ;
                end
                else begin//读下一个
                	addr_r_object <= visiting_object + 1 ;
                end
                end
                else if(pat == 7) begin
                	PON_object <= get_object;
                	en_r_object <= 0;
                	Reading <= 0;
                end
                pat <= pat + 1;
            end
        end
    end
//Write 
    always @ (posedge clk) begin
    	if(rst) begin
    		en_w_object <= 0;
    	end
    	if( cnt_object == 0 && !start_end ) begin
    		
    	end
    	else
    	if( begin_write ) begin
    	//写入，但是在object写入之前要注意先读出其相邻的一位数据再写入
    	//注意面条的object是一个object
    	//目前读入的object地址为addr_r_object，是四位数据的地址，要写入八位数据的地址的话需要再把相邻的地址读进来
    		if( visiting_object[0] ) begin//和上一个一起写这个做高位
				Object_w = {out_object , PON_object};
            end
            else begin//和下一个一起写这个做低位
                Object_w = {PON_object , out_object};
            end
    		addr_w_object <= visiting_object[12:1] ;
    		en_w_object <= 1;
    		
    		
    		cnt_beatmap <= cnt_beatmap + 1 ;
			if( This_object[0] == 1 & start_end == 0)//为面条开始
				cnt_object <= cnt_object;
			else
			cnt_object <= cnt_object + 1;
    	end
    	else begin
    		en_w_object <= 0;
    	end
    end

	always @(*) begin
		if (rst) begin
            begin_write = 0;
			begin_read = 0;
			game_over = 0;
			connect_done = 0;
		end
		else begin
			case(curr_state)
				Over:begin
					game_over = 1;
					begin_write = 0;
					begin_read = 0;
					connect_done = 0;
				end
				Idle: begin
					begin_write = 0;
					begin_read = 0;
					game_over = 0;
					connect_done = 0;
				end
				Read:begin
					begin_read = 1 ;
					begin_write = 0;
					game_over = 0;
					connect_done = 0;
				end
				NextR:begin
					begin_read = 1 ;
					begin_write = 0;
					game_over = 0;
					connect_done = 0;
				end
				Write:begin
					begin_read = 0 ;
					begin_write = 1;
					game_over = 0;
					connect_done = 0;
				end
				Done:begin
					begin_read = 0 ;
					begin_write = 0;
					connect_done = 1;
					game_over = 0;
				end
				default:begin
					begin_write = 0;
					begin_read = 0;
					game_over = 0;
					connect_done = 0;
				end
			endcase
		end
	end
	
	
	
endmodule
