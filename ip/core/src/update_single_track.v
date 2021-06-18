`timescale 1ns / 1ps

// Copyright (c) UnnamedOrange and Jack-Lyu. Licensed under the MIT License.
// See the LICENSE file in the repository root for full license text.

/// <projectname>mania-to-go</projectname>
/// <modulename>update_single_track_t</modulename>
/// <filedescription>单条轨道 update 管理器。</filedescription>
/// <version>
/// 0.0.1 (UnnamedOrange) : 定义输入输出。
/// 0.0.2 (Jack-Lyu) : 模块完成，待验证。
/// 0.0.3(Jack-Lyu) : 尝试解决不输出sig_done的问题。

`timescale 1ns / 1ps

module update_single_track_t #
(
	parameter __unused = 0
)
(
	// 控制。
	input sig_on,       // 收到 sig_on 时开始工作。
	output sig_done,    // 工作结束后发送 sig_done。

	// BRAM。端口 a 是写端口，端口 b 是读端口。
	// beatmap（对象时间点）
	output [12:0] db_b_addr,
	input [23:0] db_b_data_out,
	output db_b_en,

	// object（对象）
	output [11:0] do_a_addr,
	output [7:0] do_a_data_in,
	output do_a_en_w,
	output [12:0] do_b_addr,
	input [3:0] do_b_data_out,
	output do_b_en,

	// 数量与基地址。
	input [12:0] db_size,         // 对象时间点的数量。用于判断"没有下一个对象时间点"。
	input [12:0] db_base_addr,    // 对象时间点基地址。用 db_base_addr + i 访问第 i 个对象时间点，下标从 0 开始。
	input [12:0] do_size,         // 对象的数量。
	input [12:0] do_base_addr,    // 对象基地址。用 do_base_addr + i 访问第 i 个对象，下标从 0 开始。注意写回去的时候位宽翻倍，地址位少一位。

	// 键盘。
	input is_key_down,       // 是否按下键盘。
	input is_key_changed,    // 用于判断"事件发生"。

	// 额外输入。
	input [19:0] current_time, // 当前时间，单位为毫秒。用于"更新成绩"。

	// 额外输出。
	output is_game_over, // 是否"打完了"。
	output [1:0] comb,
	output is_miss,
	output is_bad,
	output is_good,
	output is_great,
	output is_perfect,

	// 复位与时钟。
	input RESET_L,
	input CLK
);
	
	wire reset;
	assign reset = !RESET_L;
	
	reg Sig_done;
	assign sig_done= Sig_done;
	reg [12:0] addr_r_time;
	assign db_b_addr = addr_r_time;
	reg time_r_en;
	assign db_b_en = time_r_en;
	reg [11:0] addr_r_object;
	assign do_a_addr = addr_r_object;
	reg object_r_en;
	assign do_b_en = object_r_en ;	
	reg [7:0] object_write;
	assign do_a_data_in = object_write;
	reg object_w_en;
	assign do_a_en_w = object_w_en ;
	reg [12:0] addr_w_object;
	assign do_b_addr = addr_w_object;
	reg game_over;
	assign is_game_over = Gameover;
	reg [1:0] Comb;
	assign comb = Combe;
	reg miss;
	assign is_miss = Miss ;
	reg bad;
	assign is_bad = Bad;
	reg good;
	assign is_good = Good;
	reg great ;
	assign is_great = Great;
	reg perfect;
	assign is_perfect = Perfect;
	
	
	reg [1:0] Combe;
	reg Gameover;
	reg Miss;
	reg Bad;
	reg Good;
	reg Great;
	reg Perfect;

	reg [19:0] delta_time;
	reg [23:0] beatmap;
	reg [23:0] beatmap_read;
	reg [3:0] PON_object;
	reg [3:0] PON_object_read;
	reg [3:0] object;
	reg [3:0] object_read;
	reg Start_End=0;//为1代表next_time为面条start,为0代表next_time为面条end

	reg discard;
	reg disappear;

//address	
	reg [12:0] cnt_beatmap;
	reg [12:0] cnt_object;
	reg plus_flag;
	reg plus;//代表是否在Made状态使cnt_beatmap   +1
	reg [12:0] visiting_time;
	reg [12:0] visiting_object;
    always @(*) begin
    	visiting_time = db_base_addr + cnt_beatmap ;
    	visiting_object =  do_base_addr + cnt_object ;
    end

	reg write;
	reg plus_cnt;
	reg init;
	
	always @(posedge CLK) begin
		if(reset) begin
			cnt_beatmap <= 0;
			cnt_object <= 0;
			Start_End <= 0;
			Perfect <= 0;
			Great <= 0;
			Good <= 0;
			Bad <= 0;
			Miss <= 0;
			Combe <= 0;
			Gameover <= 0;
		end
		else if(init) begin
			plus <= 0;
			object <= 0;
			beatmap <= 0;
		end
		else begin
			if(game_over)
				Gameover <= 1;
			else if(perfect)
				Perfect <= 1;
			else if(great)
				Great <= 1;
			else if(good)
				Good <= 1;
			else if(bad)
				Bad <= 1;
			else if(miss)
				Miss <= 1;
			if(Comb > 0)
				Combe <= Comb;
			else 
				Combe <= Combe;
			if(plus_cnt)begin
				cnt_beatmap <= cnt_beatmap + plus;
				if( object[0] == 1 & Start_End == 0)//为面条开始
					cnt_object <= cnt_object;
				else
					cnt_object <= cnt_object + plus;
				if(object[0])
					Start_End = Start_End + 1;
			end
			else if(write) begin
				if( visiting_object[0] ) begin//和上一个一起写这个做高位
					object_write <= {object , PON_object};
				end
				else begin//和下一个一起写这个做低位
					object_write <= {PON_object , object};
				end
				addr_w_object <= visiting_object[12:1] ;
				object_w_en <= 1;
			end
			else begin
				object_w_en  <= 0;
				if(plus_flag) begin
					plus <= 1;
				end	
				else if(discard)
					object[2] <= 1;
				else if(disappear)
					object[1] <= 1;
				else begin
					if(beatmap_read == 0) begin
						beatmap <= beatmap ;
					end
					else begin
						beatmap <= beatmap_read;
					end
					
					if(PON_object_read == 0) begin
						PON_object <= PON_object ;
					end
					else begin
						PON_object <= PON_object_read;
					end
					
					if(object_read == 0) begin
						object <= object ;
					end
					else begin
						object <= object_read;
					end
				end
			end
		end
	end

	
    parameter tmiss=150;
    parameter tbad=80;
    parameter tgood=75;
    parameter tgreat=50;
    parameter tperfect=15;
	
	
	
	parameter Idle       = 4'd0;
	parameter Read0      = 4'd1;
	parameter Read1      = 4'd2;
	parameter Read2      = 4'd3;
	parameter Read3      = 4'd4;//第一次读取完毕，开始第二次读取
	parameter Read4      = 4'd5;
	parameter Read5      = 4'd6;
	parameter Read6      = 4'd7;//第二次读取完毕
	parameter Over       = 4'd8;//GameOver,之后rst会复位
    parameter Write      = 4'd9;//等待事件发生
    parameter Done       = 4'd10;//非更新结束
    parameter Disappear  = 4'd11;//方块或面条以消失结束，注意要在此状态改写out_object，comb，并计算评分,更新连击数
    parameter Discard    = 4'd12;//面条以遗弃结束
    parameter None       = 4'd13;//面条被按住不会消失也不会遗弃，但是要更新
    parameter N_Disappear= 4'd14;//方块没有按到以消失结束
    parameter Made       = 4'd15;//此次状态转移结束，输出done信号
	
	reg [3:0] curr_state;
	reg [3:0] next_state;
	always @(posedge CLK) begin
		if(reset) begin
			curr_state <= Idle;
		end
		else begin
			curr_state <= next_state; 
		end
	end
	
	always @(*) begin
		if(reset) begin
			next_state = Idle;
		end
		else begin
			if( cnt_beatmap == db_size ) begin
				next_state = Over;
			end
			else begin
				case(curr_state)
					Idle:begin
						if(sig_on) 
							next_state = Read0;
						else
							next_state = Idle;
					end
					Read0:
						next_state = Read1;
					Read1:
						next_state = Read2;
					Read2:
						next_state = Read3;
					Read3:
						next_state = Read4;
					Read4:
						next_state = Read5;
					Read5:
						next_state = Read6;
					Read6:begin
    				if(!is_key_changed) begin// 没有事件发生
    					if(!object[0]) begin//下一个对象是方块
    						if( current_time > beatmap & current_time - beatmap > tmiss )//太晚
    							next_state = N_Disappear;
    						else 
    							next_state = Done;// 否则啥也不干
    					end
    					else begin// 下一个对象是面条
    						if(Start_End) begin//下一个对象时间点是面条起始
    							if( current_time > beatmap & current_time - beatmap > tmiss )//太晚
    								next_state = Discard;
    							else 
    								next_state = Done;// 否则啥也不干
    						end
    						else begin// 下一个对象时间点是面条终止
    							if( current_time > beatmap & current_time - beatmap > tmiss )//太晚
    								next_state = N_Disappear;
    							else 
    								next_state = Done;
    						end
    					end
    				end
    				else if(is_key_down) begin
    					if(!object[0]) begin//下个对象是方块
    						if( current_time < beatmap & beatmap - current_time > tmiss ) 
    							next_state = Done;
    						else 
    							next_state = Disappear;
    					end
    					else begin//下个对象是面条
    						if(Start_End) begin//下一个对象时间点是面条起始
    							if( current_time < beatmap & beatmap - current_time > tmiss )
    								next_state = Done;
    							else begin
    								if(( current_time < beatmap & beatmap - current_time > tbad )|( current_time > beatmap & current_time - beatmap > tbad ))
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
    					if(!object[0]) begin//下一个对象是方块
    						next_state = Done;
    						// 啥也不做。
    					end
    					else begin// 下一个对象是面条
    						if(Start_End) begin//下一个对象时间点是面条起始
    							next_state = Done;
    							// 啥也不做。
    						end
    						else begin// 下一个对象时间点是面条终止
    							if( current_time < beatmap & beatmap - current_time > tmiss ) begin//太早
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
					Done:
						next_state = Write; 
					Disappear:  
						next_state = Write;
					Discard:    
						next_state = Write;
					None:   
						next_state = Write;
					N_Disappear:
						next_state = Write;
					Write:
						next_state = Made;
					Made://结束状态
						next_state = Idle;
					Over:
						next_state = Over; 		
					default:
						next_state = Made;
				endcase
			end
		end
	end
	
	
	always @(*) begin
		if(reset) begin
			perfect             =0;
			great               =0;
			good                =0;
			bad                 =0;
			miss                =0;
			beatmap_read        =0;
			object_read         =0;
			time_r_en           =0;
			object_r_en         =0;
			addr_r_time         =0;
			addr_r_object       =0;
			PON_object_read     =0;
			plus_flag           =0;
			Comb                =2'b00;
			disappear           =0;
			discard             =0;
			delta_time          =0;
			write               =0;
			plus_cnt            =0;
			Sig_done            =0;
			init                =0;
			game_over           =0;
		end
		else begin
			//initial something to avoid latch
			perfect             =0;
			great               =0;
			good                =0;
			bad                 =0;
			miss                =0;
			beatmap_read        =0;
			object_read         =0;
			time_r_en           =0;
			object_r_en         =0;
			addr_r_time         =0;
			addr_r_object       =0;
			PON_object_read     =0;
			plus_flag           =0;
			Comb                =2'b00;
			disappear           =0;
			discard             =0;
			delta_time          =0;
			write               =0;
			plus_cnt            =0;
			Sig_done            =0;
			init                =0;
			game_over           =0;
			case(curr_state)
				Idle:begin//initial something
					init=1;
				end
				Read0:begin//读beatmap 和object
					addr_r_time = visiting_time;
                    time_r_en = 1;
                    addr_r_object = visiting_object ;
                    object_r_en = 1 ;
				end
				Read1:begin//啥都不做
					addr_r_time = visiting_time;
                    time_r_en = 1;
                    addr_r_object = visiting_object ;
                    object_r_en = 1 ;
				end 
				Read2:begin//啥都不做
					addr_r_time = visiting_time;
                    time_r_en = 1;
                    addr_r_object = visiting_object ;
                    object_r_en = 1 ;
				end
				Read3:begin//接受数据并继续读object的前或者后
					//读完这一个
                    beatmap_read = db_b_data_out;//注意要将其锁存到beatmap中
                    time_r_en = 0;
                    object_read = do_b_data_out;//注意要将其锁存到object中
                     object_r_en = 1 ;
					//读另一个  object
					if( visiting_object[0] ) begin//读上一个
						addr_r_object = visiting_object - 1 ;
					end
					else begin//读下一个
						addr_r_object = visiting_object + 1 ;
					end
				end
				Read4:begin
					object_r_en = 1 ;
				end//啥都不做
				Read5:begin
					object_r_en = 1 ;
				end//啥都不做
				Read6:begin//接受数据
					PON_object_read = do_b_data_out;//注意要将其锁存到PON_object中
                	time_r_en = 0;
				end
				Done:miss = 1;//啥都不做
				Disappear:begin
					plus_flag=1;
					Comb = 2'b01;
					disappear =1;
					if(beatmap > current_time)
						delta_time = beatmap - current_time ;
					else
						delta_time = current_time - beatmap ;
					if( delta_time < tperfect )
						perfect = 1 ;
					else if( delta_time < tgreat )
						great = 1 ;
					else if( delta_time < tgood )
						good = 1 ;
					else if( delta_time < tbad )
						bad = 1 ;
					else
						miss = 1 ;
				end
				Discard:begin
					Comb = 2'b10;
					plus_flag=1;
					discard = 1;
					miss = 1;
				end
				None:begin
						plus_flag=1;
					Comb = 2'b01;
					if(beatmap > current_time)
						delta_time = beatmap - current_time ;
					else
						delta_time = current_time - beatmap ;
					if( delta_time < tperfect )
						perfect = 1 ;
					else if( delta_time < tgreat )
						great = 1 ;
					else if( delta_time < tgood )
						good = 1 ;
					else if( delta_time < tbad )
						bad = 1 ;
					else
						miss = 1 ;
				end
				N_Disappear:begin
					Comb = 2'b10;
					plus_flag=1;
					disappear =1;
					miss = 1;
				end
				Write:begin
					write = 1;
				end
				Made:begin
					plus_cnt = 1;
					Sig_done = 1;
				end
				Over: begin
					game_over = 1;
					Sig_done = 1;
				end
				default:begin
					Sig_done = 1;
				end//啥都不做
			endcase	
		end
	end
	

endmodule
