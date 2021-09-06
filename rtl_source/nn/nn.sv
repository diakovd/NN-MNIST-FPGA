 //             ____   _    __
 //x_valid    _/    784 tick  \___
 //x            xxxxxxxxxxxxxx 
 //             ______________
 //layer1 cal _/              \___
 //                            _________
 //layer2 cal ________________/ 30 tick \__________
 //get maxN   __________________________/ 10 tick  \_
 //y_valid    _____________________________________/ \__  
 
 module nn(
	input signed [7:0] x, // input data
	input x_valid,		  //  
	
	output logic signed [31:0] y [0:9], //second layer output without activation function  
	output logic [3:0] N, //  Value of recognized digit
	output y_valid, // output result valid
	
	input Rst,
	input Clk
 );
 // logic signed [7:0] w;
 // logic signed [7:0] b;
 
 parameter int INPUTsize = 784;
 parameter int L1size    = 30;
 parameter int L2size    = 10;
 
 logic [9:0] addrWR [0:3];
 logic [9:0] addrRD [0:3];
 logic signed [63 : 0] data_wr [0:3];
 logic signed [63 : 0] data_rd [0:3];
 logic [3:0] wr;
 
 logic [9:0] cnt;
 logic [9:0] cntl2;
 logic [9:0] LayerSize;
 logic conv_compl;
 logic clr_sum;

 logic signed [15:0] mul[0:29];
 logic signed [7:0]  mul_dat[0:29];
 logic signed [7:0]  x_L2;
 logic signed [31:0] sum[0:29];

 logic signed [7:0]  L1_const[0:29]; // weights/biases for first layer 
 logic signed [7:0]  Relu[0:29]; //first layer output 
 logic addBias;
 logic LayerNum;
 logic L1_out;

 logic signed [31:0] max_val;
 logic [3:0] maxN;

 // logic signed [31:0] max_val0;
 // logic signed [31:0] max_val1;
 // logic signed [31:0] max_val2;
 // logic signed [31:0] max_val3;
 // logic signed [31:0] max_val4;
 // logic signed [31:0] max_val5;
 // logic signed [31:0] max_val6;
 // logic signed [31:0] max_val7;

 // logic [3:0] maxN0;
 // logic [3:0] maxN1;
 // logic [3:0] maxN2;
 // logic [3:0] maxN3;
 // logic [3:0] maxN4;
 // logic [3:0] maxN5;
 // logic [3:0] maxN6;
 // logic [3:0] maxN7;
 
 logic db;
 
 typedef enum 
 {
	idle, st1, st2, st3
 } fsm_state;
 fsm_state state;    
 
 //Save input grayscale image to file
 initial begin
	int fw, c;
	fw = $fopen("../output_files/x.dat", "w"); 
	db = 0;
	
	@(posedge Clk);
	@(posedge Clk);
	@(posedge Clk);
	@(posedge Clk);
	@(posedge Clk);

	for(c = 0; c < 22; c = c + 1) begin
		
  	    db = 1;
		while(!x_valid) @(posedge Clk);
		
  	    db = 0;
		while(x_valid) begin
			@(posedge Clk);
			// $fdisplay(fw, "%d", x);
		end
		// $fdisplay(fw, "--------");
	end
	
	for(c = 0; c < 22; c = c + 1) begin
		
  	    db = 1;
		while(!x_valid) @(posedge Clk);
		
  	    db = 0;
		while(x_valid) begin
			@(posedge Clk);
			$fdisplay(fw, "%d", x);
		end
		$fdisplay(fw, "--------");
	end	
	 $fclose(fw);  
 end
 
 //weights, biases ram 
 generate
  genvar j;
  for(j = 0; j < 4; j = j + 1)begin
	nn_ram #(.block(j),.bw(64),.aw(10)) wb_ram( 
		.adrr_wr(addrWR[j]),
		.data_wr(data_wr[j]),
		.wr(wr[j]),

		.adrr_rd(addrRD[j]),
		.data_rd(data_rd[j]),

		.Clk(Clk)
    );

	assign L1_const[8*j + 0] = data_rd[j][7:0];
	assign L1_const[8*j + 1] = data_rd[j][15:8];
	assign L1_const[8*j + 2] = data_rd[j][23:16];
	assign L1_const[8*j + 3] = data_rd[j][31:24];
	assign L1_const[8*j + 4] = data_rd[j][39:32];
	assign L1_const[8*j + 5] = data_rd[j][47:40];
	assign L1_const[8*j + 6] = data_rd[j][55:48];
	assign L1_const[8*j + 7] = data_rd[j][63:56];

  end	
endgenerate  
 
 generate
  genvar i;
  for(i = 0; i < 30; i = i + 1)begin
	assign addrWR[i]  = 0;
	assign data_wr[i] = 0;
	assign wr[i]      = 0;
	
	assign addrRD[i]  = cnt;

	assign mul_dat[i] = (addBias)? 1 : ((!LayerNum)?  x : x_L2); 
	assign mul[i] = L1_const[i]*mul_dat[i];
	
	always @(posedge Clk) begin
		if(Rst) begin
			sum[i] <= 0;
		end
		else begin
			//y[i] = y[i] + data_rd[i]*x; //mux + acc
			if(clr_sum) sum[i] <= 0;
			else sum[i] <= sum[i] + mul[i];
		end		

		if(L1_out) Relu[i] <= (sum[i] > 0)? ((sum[i] < 6)? sum[i] : 6) : 0;
		
	end
	
  end
 endgenerate

 generate
  genvar k;
  for(k = 0; k < 10; k = k + 1)begin
  	always @(posedge Clk) begin
		if(Rst) begin
			y[k] <= 0;
		end
		else begin
			if (L1_out) y[k] <= sum[k];
		end
    end		
  end
 endgenerate
 assign y_valid = conv_compl;

 assign cntl2 = cnt - (INPUTsize + 1);
 assign x_L2 = Relu[cntl2[4:0]];

 
 always @(posedge Clk) begin
	if(Rst) begin
		cnt 	   <= 0;
		conv_compl <= 0;
		clr_sum    <= 0;
		addBias    <= 0;
		L1_out	   <= 0;
		LayerSize  <= 0;
		LayerNum   <= 0;
 	end
	else begin
	
        case (state)
            idle: begin
				if(x_valid) begin
					state     <= st1;
					LayerNum  <= 0;
					LayerSize <= INPUTsize - 1;
					clr_sum   <= 0;
					cnt 	  <= cnt + 1;
				end
				else begin
					cnt 		<= 0;
					conv_compl 	<= 0;
					clr_sum     <= 1;
				end
			end
			
			//calculate layer  
			st1:begin
				if(cnt == LayerSize) addBias <= 1;
				                else addBias <= 0;

				if(addBias) begin
					state     <= st2;
					clr_sum <= 1;
				end
				else clr_sum <= 0;
				cnt <= cnt + 1;
			end
			
			//add biases to calculated layer  
			st2:begin
			    clr_sum <= 0;
				if(LayerNum) begin
					state      <= st3;
					max_val	   <= 0;
					maxN	   <= 10; //  
					cnt		   <= 0;
					//conv_compl <= 1;
				end
				else begin
					LayerNum  <= 1;
					LayerSize <= INPUTsize + L1size;
					state     <= st1;
				end
			end
			
			//finde max value of net output (replase sigmode to max value for simpl) 
			st3:begin
				if(cnt < 10) begin
					if(max_val < y[cnt]) begin
						max_val <= y[cnt];
						maxN 	<= cnt;
					end
					cnt <= cnt + 1;
				end
				else begin
					state      <= idle;
					conv_compl <= 1;
				end
			end
           default: ;
        endcase	
		
		L1_out <= addBias;
	end
 end
 assign N = maxN;
 endmodule