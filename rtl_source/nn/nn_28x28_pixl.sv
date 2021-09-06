 module nn_28x28_pixl(
	input [29:0] rgb10,
	input dat_valid,
	input frame_start_pkt,
	input frame_end_pkt,
	
	output [3:0] digit,
	output digit_valid,
	
	input Rst,
	input Clk
 );

 parameter LnSize = 640; //  

 logic signed [31:0] y [0:9];
 logic y_valid; // output result
 
 logic [13:0] adrr_wr_b0;
 logic [7:0]  data_wr_b0;
 logic wr_b0;
 
 logic [13:0] adrr_rd_b0;
 logic [7:0]  data_rd_b0;

 logic [10:0] adrr_wr_b0_add;
 logic [7:0]  data_wr_b0_add;
 logic wr_b0_add;
 
 logic [10:0] adrr_rd_b0_add;
 logic [7:0]  data_rd_b0_add;

 logic [13:0] adrr_wr_b1;
 logic [7:0]  data_wr_b1;
 logic wr_b1;
 
 logic [13:0] adrr_rd_b1;
 logic [7:0]  data_rd_b1;

 logic [10:0] adrr_wr_b1_add;
 logic [7:0]  data_wr_b1_add;
 logic wr_b1_add;

 logic [13:0] adrr_rd;
 logic [10:0] adrr_rd_add;
 logic rd_add;
 
 logic [10:0] adrr_rd_b1_add;
 logic [7:0]  data_rd_b1_add;

 logic [13:0] cnt_addr;
 logic [4:0] cnt_row;  //row 1 - 28 
 logic [4:0] cnt_col;  //col 1 - 28
 logic [4:0] cnt_smpl_row; //22 sempl in 640 pixel withg by 28   
 logic [4:0] cnt_smpl_col; //13 sempl in 480 pixel high  by 28   
 
 logic activBuf;
 logic en_cnt_addr;
 logic wr_add;
 logic st_conv;
 logic [7:0] gray8;
 logic signed [7:0] dat;
 logic signed [7:0] dat1;
 logic signed [7:0] x;
 logic stp_conv;
 logic endFrame;
 logic pause;
 
 typedef enum 
 {
	idle, st1, st2, st3
 } fsm_state;
 fsm_state state; 
 
 rgb10toGray8 rgb10toGray8_inst(
	.rgb10(rgb10),
	.gray8(gray8)
 );

 assign dat1 = gray8 >> 1; //scale to 256 gray color to 0 - 127 signet value 
 assign dat = (dat1 > 50)? 127 : dat1; //add more contrast 
 
 //Mem Buffers for two block by 28 lines 
 //First buffer for to get 28 lines
 //Second buffer for to calculation 22 time nn (28*28 pixl, 28 lines 640 pixel)
 
 assign data_wr_b0     = dat;
 assign data_wr_b0_add = dat;
 assign data_wr_b1     = dat;
 assign data_wr_b1_add = dat;
 
 
 //16k + 2k buffer for 28 imaje lines 
 ram #(.bw(8),.aw(14)) wb_ram0( 
	.adrr_wr(cnt_addr),
	.data_wr(data_wr_b0),
	.wr(dat_valid & !activBuf & !wr_add),

	.adrr_rd(adrr_rd),
	.data_rd(data_rd_b0),

	.Clk(Clk)
 );
 ram #(.bw(8),.aw(11)) wb_ram0_add( 
	.adrr_wr(cnt_addr[10:0]),
	.data_wr(data_wr_b0_add),
	.wr(dat_valid & !activBuf & wr_add),

	.adrr_rd(adrr_rd_add),
	.data_rd(data_rd_b0_add),

	.Clk(Clk)
 );

 //16k + 2k buffer for 28 imaje lines 
 ram #(.bw(8),.aw(14)) wb_ram1( 
	.adrr_wr(cnt_addr),
	.data_wr(data_wr_b1),
	.wr(dat_valid & activBuf & !wr_add),

	.adrr_rd(adrr_rd),
	.data_rd(data_rd_b1),

	.Clk(Clk)
 );
 ram #(.bw(8),.aw(11)) wb_ram1_add( 
	.adrr_wr(cnt_addr[10:0]),
	.data_wr(data_wr_b1_add),
	.wr(dat_valid & activBuf & wr_add),

	.adrr_rd(adrr_rd_add),
	.data_rd(data_rd_b1_add),

	.Clk(Clk)
 );
 
 //adrr_rd  cnt_smpl_row * cnt_row  (cnt_col * 640)  cnt_smpl_col * 640
 // base_row
 // base_col

 assign adrr_rd     =  cnt_col * 640 + cnt_smpl_row * 28 + cnt_row;
 assign adrr_rd_add = (cnt_col - 25) * 640 + cnt_smpl_row * 28 + cnt_row;
 assign rd_add	    = (cnt_col < 25)? 0 : 1;
 
 assign x = (!activBuf)? ((rd_add)? data_rd_b1_add : data_rd_b1) : ((rd_add)? data_rd_b0_add : data_rd_b0);
 assign x_valid = (cnt_smpl_row < 22)? 1 : 0;
 
  nn nn_inst(
	.x(x), 
	.x_valid(x_valid & !pause),		
	
	.y(y),
	.N(digit),
	.y_valid(y_valid),
	
	.Rst(Rst),
	.Clk(Clk)
 );
 assign digit_valid = y_valid;

 always @(posedge Clk) begin
	if(Rst) begin
		cnt_addr    <= 0;
		//cnt_addr_rd <= 0;
		wr_add    <= 0;
		activBuf  <= 0;
		en_cnt_addr		<= 0; 	
		//en_cnt_addr_rd	<= 0; 	
		cnt_smpl_row    <= 22;
		cnt_smpl_col    <= 0;
		stp_conv 		<= 0;
		endFrame 		<= 0;
		pause 			<= 0;
  	end
	else begin
	
		if(!en_cnt_addr) cnt_addr <= 0;
		else if(dat_valid) begin
			cnt_addr <= cnt_addr + 1;
		end

		if(cnt_row == 27 & cnt_col == 27)  pause <= 1;
		else if(y_valid) pause <= 0;

		if(cnt_smpl_row < 22) begin
			if(!pause) begin
				if(cnt_row < 27) cnt_row <= cnt_row + 1;
				else begin
					cnt_row  <= 0;
					stp_conv <= 0;
					if(cnt_col < 27) cnt_col <= cnt_col + 1;
					else begin
						cnt_col <= 0;
						if(cnt_smpl_row < 22) cnt_smpl_row <= cnt_smpl_row + 1;
						if(cnt_smpl_row == 21) begin
							stp_conv <= 1;
							if(cnt_smpl_col == 16) endFrame <= 1;
							else endFrame <= 0;
						end	
						else begin
							stp_conv <= 0;
							endFrame <= 0;
						end
					end
				end
			end
		end
		else if(st_conv) begin
			cnt_smpl_row <= 0;
			cnt_row 	 <= 0;
			cnt_col 	 <= 0;
			stp_conv 	 <= 0;
			endFrame     <= 0;
		end
		else begin
			stp_conv <= 0;
			endFrame <= 0;
		end
		
        case (state)
            idle: begin
				if(frame_start_pkt) begin
					en_cnt_addr	<= 1;
					state 		<= st1;
				end
				activBuf     <= 0;	
				en_cnt_addr	 <= 0;
				cnt_smpl_col <= 0;
			end
			
			//RX 28 lines from sensor
			st1:begin
				if(cnt_addr == 16000) begin // get 25 lines
					en_cnt_addr	<= 0; //reset cnt_addr
					wr_add 		<= 1; //swith wr to add buff 
				end
				else if(wr_add & cnt_addr == 1920) begin //get 28 lines
					activBuf  	<= ~activBuf; //swith wr to buffer block b1 
					st_conv		<= 1;
					en_cnt_addr	<= 0;
					wr_add 		<= 0; 
				end
				else begin
					en_cnt_addr <= 1;
					st_conv		<= 0;
				end
				
				if(endFrame) state <= idle; 
				if(stp_conv) cnt_smpl_col <= cnt_smpl_col + 1; 
			end
			
            default: ;
        endcase	
	end
 end
 
 endmodule