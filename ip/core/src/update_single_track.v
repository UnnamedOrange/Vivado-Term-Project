`timescale 1ns / 1ps

// Copyright (c) UnnamedOrange and Jack-Lyu. Licensed under the MIT License.
// See the LICENSE file in the repository root for full license text.

/// <projectname>mania-to-go</projectname>
/// <modulename>update_single_track_t</modulename>
/// <filedescription>������� update ��������</filedescription>
/// <version>
/// 0.0.1 (UnnamedOrange) : �������������
/// 0.0.2 (Jack-Lyu) : ģ����ɣ�����֤��
/// 0.0.3(Jack-Lyu) : ���Խ�������sig_done�����⡣

`timescale 1ns / 1ps

module update_single_track_t #
(
	parameter __unused = 0
)
(
	// ���ơ�
	input sig_on,       // �յ� sig_on ʱ��ʼ������
	output sig_done,    // ������������ sig_done��

	// BRAM���˿� a ��д�˿ڣ��˿� b �Ƕ��˿ڡ�
	// beatmap������ʱ��㣩
	output [12:0] db_b_addr,
	input [23:0] db_b_data_out,
	output db_b_en,

	// object������
	output [11:0] do_a_addr,
	output [7:0] do_a_data_in,
	output do_a_en_w,
	output [12:0] do_b_addr,
	input [3:0] do_b_data_out,
	output do_b_en,

	// ���������ַ��
	input [12:0] db_size,         // ����ʱ���������������ж�"û����һ������ʱ���"��
	input [12:0] db_base_addr,    // ����ʱ������ַ���� db_base_addr + i ���ʵ� i ������ʱ��㣬�±�� 0 ��ʼ��
	input [12:0] do_size,         // �����������
	input [12:0] do_base_addr,    // �������ַ���� do_base_addr + i ���ʵ� i �������±�� 0 ��ʼ��ע��д��ȥ��ʱ��λ��������ַλ��һλ��

	// ���̡�
	input is_key_down,       // �Ƿ��¼��̡�
	input is_key_changed,    // �����ж�"�¼�����"��

	// �������롣
	input [19:0] current_time, // ��ǰʱ�䣬��λΪ���롣����"���³ɼ�"��

	// ���������
	output is_game_over, // �Ƿ�"������"��
	output [1:0] comb,
	output is_miss,
	output is_bad,
	output is_good,
	output is_great,
	output is_perfect,

	// ��λ��ʱ�ӡ�
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
	reg Start_End=0;//Ϊ1����next_timeΪ����start,Ϊ0����next_timeΪ����end

	reg discard;
	reg disappear;

//address	
	reg [12:0] cnt_beatmap;
	reg [12:0] cnt_object;
	reg plus_flag;
	reg plus;//�����Ƿ���Made״̬ʹcnt_beatmap   +1
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
				if( object[0] == 1 & Start_End == 0)//Ϊ������ʼ
					cnt_object <= cnt_object;
				else
					cnt_object <= cnt_object + plus;
				if(object[0])
					Start_End = Start_End + 1;
			end
			else if(write) begin
				if( visiting_object[0] ) begin//����һ��һ��д�������λ
					object_write <= {object , PON_object};
				end
				else begin//����һ��һ��д�������λ
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
	parameter Read3      = 4'd4;//��һ�ζ�ȡ��ϣ���ʼ�ڶ��ζ�ȡ
	parameter Read4      = 4'd5;
	parameter Read5      = 4'd6;
	parameter Read6      = 4'd7;//�ڶ��ζ�ȡ���
	parameter Over       = 4'd8;//GameOver,֮��rst�Ḵλ
    parameter Write      = 4'd9;//�ȴ��¼�����
    parameter Done       = 4'd10;//�Ǹ��½���
    parameter Disappear  = 4'd11;//�������������ʧ������ע��Ҫ�ڴ�״̬��дout_object��comb������������,����������
    parameter Discard    = 4'd12;//��������������
    parameter None       = 4'd13;//��������ס������ʧҲ��������������Ҫ����
    parameter N_Disappear= 4'd14;//����û�а�������ʧ����
    parameter Made       = 4'd15;//�˴�״̬ת�ƽ��������done�ź�
	
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
    				if(!is_key_changed) begin// û���¼�����
    					if(!object[0]) begin//��һ�������Ƿ���
    						if( current_time > beatmap & current_time - beatmap > tmiss )//̫��
    							next_state = N_Disappear;
    						else 
    							next_state = Done;// ����ɶҲ����
    					end
    					else begin// ��һ������������
    						if(Start_End) begin//��һ������ʱ�����������ʼ
    							if( current_time > beatmap & current_time - beatmap > tmiss )//̫��
    								next_state = Discard;
    							else 
    								next_state = Done;// ����ɶҲ����
    						end
    						else begin// ��һ������ʱ�����������ֹ
    							if( current_time > beatmap & current_time - beatmap > tmiss )//̫��
    								next_state = N_Disappear;
    							else 
    								next_state = Done;
    						end
    					end
    				end
    				else if(is_key_down) begin
    					if(!object[0]) begin//�¸������Ƿ���
    						if( current_time < beatmap & beatmap - current_time > tmiss ) 
    							next_state = Done;
    						else 
    							next_state = Disappear;
    					end
    					else begin//�¸�����������
    						if(Start_End) begin//��һ������ʱ�����������ʼ
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
    							//��ʱ����һ����������ɶҲ������
    						end
    					end
    				end
    				else begin//�ſ��¼�
    					if(!object[0]) begin//��һ�������Ƿ���
    						next_state = Done;
    						// ɶҲ������
    					end
    					else begin// ��һ������������
    						if(Start_End) begin//��һ������ʱ�����������ʼ
    							next_state = Done;
    							// ɶҲ������
    						end
    						else begin// ��һ������ʱ�����������ֹ
    							if( current_time < beatmap & beatmap - current_time > tmiss ) begin//̫��
    								next_state = Discard;//��������, ����������;
    							end
    							else begin
    								// ��������ѱ����������³ɼ�ʱ���� OK��
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
					Made://����״̬
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
				Read0:begin//��beatmap ��object
					addr_r_time = visiting_time;
                    time_r_en = 1;
                    addr_r_object = visiting_object ;
                    object_r_en = 1 ;
				end
				Read1:begin//ɶ������
					addr_r_time = visiting_time;
                    time_r_en = 1;
                    addr_r_object = visiting_object ;
                    object_r_en = 1 ;
				end 
				Read2:begin//ɶ������
					addr_r_time = visiting_time;
                    time_r_en = 1;
                    addr_r_object = visiting_object ;
                    object_r_en = 1 ;
				end
				Read3:begin//�������ݲ�������object��ǰ���ߺ�
					//������һ��
                    beatmap_read = db_b_data_out;//ע��Ҫ�������浽beatmap��
                    time_r_en = 0;
                    object_read = do_b_data_out;//ע��Ҫ�������浽object��
                     object_r_en = 1 ;
					//����һ��  object
					if( visiting_object[0] ) begin//����һ��
						addr_r_object = visiting_object - 1 ;
					end
					else begin//����һ��
						addr_r_object = visiting_object + 1 ;
					end
				end
				Read4:begin
					object_r_en = 1 ;
				end//ɶ������
				Read5:begin
					object_r_en = 1 ;
				end//ɶ������
				Read6:begin//��������
					PON_object_read = do_b_data_out;//ע��Ҫ�������浽PON_object��
                	time_r_en = 0;
				end
				Done:miss = 1;//ɶ������
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
				end//ɶ������
			endcase	
		end
	end
	

endmodule
