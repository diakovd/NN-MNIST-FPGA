
  module ram
 #(
	parameter bw = 32,
	parameter aw = 8 //160 pixl 
 )
 (
	input [aw-1:0] adrr_wr,
	input [bw-1:0] data_wr,
	input wr,

	input  [aw-1:0] adrr_rd,
	output [bw-1:0] data_rd,

	input Clk
 );

`ifdef sim

 (* ram_style = "block" *) reg  [bw-1:0] ram [(2**aw)-1:0];
 
 always @(posedge Clk) begin
	if (wr) ram[adrr_wr] <= data_wr;
 end
 
 assign data_rd = ram[adrr_rd];
 `else
  generate
	if(bw == 8)
		ram_8b (
		  .clka(Clk),
		  .wea(wr),
		  .addra(adrr_wr),
		  .dina(data_wr),
		  .clkb(Clk),
		  .addrb(adrr_rd),
		  .doutb(data_rd)
		);		
	else if(bw == 40)
		ram_40b (
		  .clka(Clk),
		  .wea(wr),
		  .addra(adrr_wr),
		  .dina(data_wr),
		  .clkb(Clk),
		  .addrb(adrr_rd),
		  .doutb(data_rd)
		);	
   endgenerate	
 `endif
 endmodule