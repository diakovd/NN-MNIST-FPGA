
 module nn_tb;

 parameter int INPUTsize = 784;
 logic signed [7 : 0]  dat [0 : (INPUTsize - 1)];
 logic signed [7 : 0]  x;
 logic signed [15:0] y; 
 int i;
 logic Clk = 1;
 logic Rst;
 
 always #10 Clk = ~Clk;
 
 initial
  begin
    $readmemh( "../output_files/inputData.hex", dat );
  end

 initial
  begin
	Rst = 1;
	y = 0;
	#100;
	Rst = 0;
	#100;
	for( i = 0; i < 784; i = i + 1) begin
		@(posedge Clk);
		x = dat[i];
		y = 1;	
	end
	@(posedge Clk);
	y = 0;
 end

  nn nn_inst(
	.x(x),
	.x_valid(y),
	
	.Rst(Rst),
	.Clk(Clk)
 );
 
 endmodule