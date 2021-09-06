
 module raw10toRGB(
	input frame_start_i, 
	input frame_end_i,
	
    axi4_stream_if.slave  pkt_i,

	output logic [29:0] rgb10,
	output logic dat_valid,
	output logic frame_valid,

	input Rst,
	input Clk
 );

 wire  [1:0] LnCntRD1;
 logic [1:0] LnCntWR;
 logic [1:0] LnCntRD;
 logic [1:0] LnCnt;
 logic [7:0] adrrCntWR;
 logic [7:0] adrrCntRD;
 logic [1:0] ctrPxl;
 logic [7:0]  line_size;
 logic [9:0] debayerWinL1 [0:2];
 logic [9:0] debayerWinL2 [0:2];
 logic [9:0] debayerWinL3 [0:2];
 logic lineRX;
 logic lineRX_del;
 logic LnWR;
 logic LnRD;
 logic full;
 logic empty;
 logic enConv;
 logic enLnCntRD;
 
 logic [9:0] datL1;
 logic [9:0] datL2;
 logic [9:0] datL3;
 logic [9:0] sumP;
 logic [9:0] sumZ;
 logic [9:0] sumV;
 logic [9:0] sumH;
 
 logic [1:0] pos;
 
 logic [39:0] dataL1;
 logic [39:0] dataL2;
 logic [39:0] dataL3;
 
 logic [39:0] data_rd_L1;
 logic [39:0] data_rd_L2;
 logic [39:0] data_rd_L3;
 logic [39:0] data_rd_L4; 
 logic [39:0] data_wr;
 logic enLnCntRD_del;
 logic LnRD_del;
 
 typedef enum 
 {
	idle, st1, st2, st3
 } fsm_state;
 fsm_state state;        
 
 assign LnWR = lineRX_del & !lineRX;
 
 assign pkt_i.tready = 1;
 
 always @(posedge Clk) begin
	if(Rst) begin
		LnCntWR <= 0;
		LnCntRD <= 0;
		adrrCntWR  <= 0;
		adrrCntRD  <= 0;
		line_size  <= 0;
		ctrPxl	   <= 0;
		lineRX      <= 0;
		state 	   <= idle;
		LnCnt	   <= 0;
		enLnCntRD	   <= 0;
		LnRD       <= 0;
		full  	   <= 0;
		empty 	   <= 1;
		debayerWinL1 <= {0,0,0};
		debayerWinL2 <= {0,0,0};
		debayerWinL3 <= {0,0,0};
		enConv		 <= 0;
		enLnCntRD_del<= 0;
	end
	else begin

	//Line rx
		if     (pkt_i.tvalid & pkt_i.tready & !lineRX) lineRX <= 1;
		else if(pkt_i.tlast  & pkt_i.tvalid  & pkt_i.tready & lineRX) begin
			lineRX    <= 0;
			line_size <= adrrCntWR;
		end
		lineRX_del <= lineRX;
		LnRD_del   <= LnRD;
	//Conter address for line buffer
		if(pkt_i.tvalid & pkt_i.tready) adrrCntWR <= adrrCntWR + 1;
		else if(LnWR) adrrCntWR <=  0;

	//line fifo 
		if (LnWR) begin
			if (LnCntRD == LnCntWR + 1) full  <= 1;
								   else full  <= 0;
			LnCntWR   <= LnCntWR + 1;
			empty <= 0;
		end
		else if(LnRD) begin 
			if ( LnCntWR  == LnCntRD1) begin
  			    $display("%0t LnCntRD %d", $time, LnCntRD);
				empty <= 1;
			end
			else empty <= 0;
			
			if((LnCntWR == 0) & (LnCntRD == 3)) $display("%0t LnCntRD %d", $time, LnCntRD);
			
			LnCntRD <= LnCntRD + 1;
			full  <= 0;
		end
		
		if(LnWR & LnRD) LnCnt <= LnCnt;
		else if(LnWR)   LnCnt <= LnCnt + 1;
		else if(LnRD)   LnCnt <= LnCnt - 1;
		

	//FSM control convertion raw to rgb
	//wait 2 reseved lines, 
	//convertion to rgb by line,
	//after frame_end_i convert to rgb last 2 buffered lines
        case (state)
            idle: begin
				if(frame_start_i) state <= st1;
			end
			st1:begin
				if(frame_end_i) begin
					enLnCntRD <= 1;
					state   <= st2;
				end
				else if(LnCnt >= 2) begin
					enLnCntRD <= 1;
					state   <= st2;
				end
				LnRD    <= 0;
			end
			st2:begin
				if((adrrCntRD == line_size) & (ctrPxl == 3)) begin
					LnRD      <= 1;
					enLnCntRD <= 0;
				end
				else LnRD   <= 0;
				
				if(LnRD_del) begin
					if(empty) state <= idle;
					else      state <= st1;	
				end
			end
            default: ;
        endcase

		if (enLnCntRD) begin
			if(ctrPxl == 3) adrrCntRD <= adrrCntRD + 1;
		end
		else adrrCntRD <= 0; // end convertion line

		if (enLnCntRD) ctrPxl <= ctrPxl + 1;
		else ctrPxl <= 0; // end convertion line
		
		enLnCntRD_del <= enLnCntRD;
		enConv 		  <= enLnCntRD_del;

		//if(conv_en) begin
		    debayerWinL1[2] <= debayerWinL1[1]; debayerWinL1[1] <= debayerWinL1[0]; debayerWinL1[0] <= datL1; 
		    debayerWinL2[2] <= debayerWinL2[1]; debayerWinL2[1] <= debayerWinL2[0]; debayerWinL2[0] <= datL2; 
		    debayerWinL3[2] <= debayerWinL3[1]; debayerWinL3[1] <= debayerWinL3[0]; debayerWinL3[0] <= datL3; 
		//end

		//SUM
		//	  [] 
		//	[] x[]
		//	  []
		sumP = (debayerWinL1[1] + debayerWinL2[0] + debayerWinL2[2] + debayerWinL3[1]) >> 2;

		//	[]  [] 
		//	  x
		//	[]  []
		sumZ = (debayerWinL1[2] + debayerWinL1[0] + debayerWinL3[2] + debayerWinL3[0]) >> 2;

		//	   
		//	[]x []
		//	  
		sumH = (debayerWinL2[2] + debayerWinL2[0]) >> 1;

		//	  [] 
		//	   x 
		//	  []
		sumV = (debayerWinL1[1] + debayerWinL3[1]) >> 1;

		//pxel position in:rg           gb
		//                 gb           rg  
		// map to:         0 1          0 1
		//				   2 3          2 3
		pos <= {LnCntRD[0], !ctrPxl[0]}; //position 

		// position 0 =>
		//	r = debayerWinL2[1]         r = sumV        
		//  g = sumP                    g = debayerWinL2[1]      
		//  b = sumZ                    b = sumH

		// position 1 =>
		//	r = sumH                    r = sumZ
		//  g = debayerWinL2[1]         g = sumP
		//  b = sumV                    b = debayerWinL2[1]

		// position 2 =>
		//	r = sumV                    r = debayerWinL2[1]
		//  g = debayerWinL2[1]         g = sumP 
		//  b = sumH                    b = sumZ

		// position 3 =>
		//	r = sumZ                    r = sumH 
		//  g = sumP                    g = debayerWinL2[1]   
		//  b = debayerWinL2[1]         b = sumV   

		if     (pos == 0) rgb10 <= {sumV            , debayerWinL2[1] , sumH};
		else if(pos == 1) rgb10 <= {sumZ            , sumP            , debayerWinL2[1]};
		else if(pos == 2) rgb10 <= {debayerWinL2[1] , sumP            , sumZ};
		else if(pos == 3) rgb10 <= {sumH            , debayerWinL2[1] , sumV};

	end
 end

 assign LnCntRD1 = LnCntRD + 1;
 
 assign dat_valid   = enConv;
 assign frame_valid = !idle;

 assign dataL1 = ((LnCntRD - 1) == 0)?  data_rd_L1:
				 ((LnCntRD - 1) == 1)?  data_rd_L2:
				 ((LnCntRD - 1) == 2)?  data_rd_L3: 
				 ((LnCntRD - 1) == 3)?  data_rd_L4: 40'h0;

 assign dataL2 = (LnCntRD == 0)?  data_rd_L1:
				 (LnCntRD == 1)?  data_rd_L2:
				 (LnCntRD == 2)?  data_rd_L3: 
				 (LnCntRD == 3)?  data_rd_L4: 40'h0;

 assign dataL3 = ((LnCntRD + 1) == 0)?  data_rd_L1:
				 ((LnCntRD + 1) == 1)?  data_rd_L2:
				 ((LnCntRD + 1) == 2)?  data_rd_L3: 
				 ((LnCntRD + 1) == 3)?  data_rd_L4: 40'h0;
				 

 assign datL1 = (ctrPxl == 0)? dataL1[9:0] :
			    (ctrPxl == 1)? dataL1[19:10] :
			    (ctrPxl == 2)? dataL1[29:20] :
			    (ctrPxl == 3)? dataL1[39:30] : 10'h0;

 assign datL2 = (ctrPxl == 0)? dataL2[9:0] :
			    (ctrPxl == 1)? dataL2[19:10] :
			    (ctrPxl == 2)? dataL2[29:20] :
			    (ctrPxl == 3)? dataL2[39:30] : 10'h0;
				
 assign datL3 = (ctrPxl == 0)? dataL3[9:0] :
			    (ctrPxl == 1)? dataL3[19:10] :
			    (ctrPxl == 2)? dataL3[29:20] :
			    (ctrPxl == 3)? dataL3[39:30] : 10'h0;

 // convert 4 pixel (5 byte) to 4 pixl (10bit) 
 assign data_wr = {
			pkt_i.tdata[31:24],pkt_i.tdata[39:38],
			pkt_i.tdata[23:16],pkt_i.tdata[37:36],
			pkt_i.tdata[15:8] ,pkt_i.tdata[35:34],
			pkt_i.tdata[7:0]  ,pkt_i.tdata[33:32]};
 
 ram #(.bw(40),.aw(8)) line1_ram(
	.adrr_wr(adrrCntWR),
	.data_wr(data_wr),
	.wr(pkt_i.tvalid & pkt_i.tready & !LnCntWR[1] & !LnCntWR[0]),

	.adrr_rd(adrrCntRD),
	.data_rd(data_rd_L1),

	.Clk(Clk)
 );

 ram #(.bw(40),.aw(8)) line2_ram(
	.adrr_wr(adrrCntWR),
	.data_wr(data_wr),
	.wr(pkt_i.tvalid & pkt_i.tready & !LnCntWR[1] & LnCntWR[0]),

	.adrr_rd(adrrCntRD),
	.data_rd(data_rd_L2),

	.Clk(Clk)
 );

 ram #(.bw(40),.aw(8)) line3_ram(
	.adrr_wr(adrrCntWR),
	.data_wr(data_wr),
	.wr(pkt_i.tvalid & pkt_i.tready & LnCntWR[1] & !LnCntWR[0]),

	.adrr_rd(adrrCntRD),
	.data_rd(data_rd_L3),

	.Clk(Clk)
 );

 ram #(.bw(40),.aw(8)) line4_ram(
	.adrr_wr(adrrCntWR),
	.data_wr(data_wr),
	.wr(pkt_i.tvalid & pkt_i.tready & LnCntWR[1] & LnCntWR[0]),

	.adrr_rd(adrrCntRD),
	.data_rd(data_rd_L4),

	.Clk(Clk)
 );

endmodule