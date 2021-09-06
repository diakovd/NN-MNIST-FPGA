
  module nn_ram
 #(
	parameter block = 0,
	parameter bw 	= 32,
	parameter aw 	= 8 //160 pixl 
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

 string s;
 (* ram_style = "block" *) reg  [bw-1:0] ram [(2**aw)-1:0];
 
  initial
  begin
    s = $sformatf("../output_files/RAMblock%0d.hex", block);
    $readmemh(s, ram);
  end
 
 always @(posedge Clk) begin
	if (wr) ram[adrr_wr] <= data_wr;
 end
 
 assign data_rd = ram[adrr_rd];
`else
 generate
	if(block == 0)
		nn_ram_0  ram_0_inst(
							  .clka(Clk),
							  .ena(1'b1),
							  .wea(wr),
							  .addra(adrr_rd),
							  .dina(data_wr),
							  .douta(data_rd)
							);
	else if (block == 1)
		nn_ram_1  ram_1_inst(
							  .clka(Clk),
							  .ena(1'b1),
							  .wea(wr),
							  .addra(adrr_rd),
							  .dina(data_wr),
							  .douta(data_rd)
							);	
	else if (block == 2)
		nn_ram_2  ram_2_inst(
							  .clka(Clk),
							  .ena(1'b1),
							  .wea(wr),
							  .addra(adrr_rd),
							  .dina(data_wr),
							  .douta(data_rd)
							);	
	else 
		nn_ram_3  ram_3_inst(
							  .clka(Clk),
							  .ena(1'b1),
							  .wea(wr),
							  .addra(adrr_rd),
							  .dina(data_wr),
							  .douta(data_rd)
							);								
 endgenerate
`endif
 
 endmodule
 