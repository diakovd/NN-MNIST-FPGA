`include "../rtl_source/csi2_rx-master/lib/dphy_lib/DPHYSender.sv";
`include "../rtl_source/csi2_rx-master/lib/axi4_lib/src/class/AXI4StreamSlave.sv"

`timescale 1 ps / 1 ps

module nn_mnist_tb;
 
parameter int DATA_LANES   = 2;
parameter int DELAY[4]     = '{0,0,0,0};
parameter int DPHY_CLK_T   = 4762;
parameter int REF_CLK_T    = 4762;
parameter int PX_CLK_T     = 13423;

parameter int Y_RES        = 480; //1096;
parameter int X_RES        = 640; //1936;
parameter int W_CNT		   = X_RES * 1.25;	
parameter int PX_AMOUNT    = X_RES * Y_RES;
parameter int BYTES_AMOUNT = PX_AMOUNT + PX_AMOUNT / 4;

parameter int LINE_TIME    = 25_986_928;
parameter int LINE_PERIOD  = 30_413_625;

localparam int CSI2_CRC_POLY = 16'h1021;

bit [DATA_LANES - 1 : 0] dphy_data_p;
bit [DATA_LANES - 1 : 0] dphy_data_n;
bit [DATA_LANES - 1 : 0] dphy_lp_data_p;
bit [DATA_LANES - 1 : 0] dphy_lp_data_n;
bit                      dphy_clk_p;
bit                      dphy_clk_n;
bit                      ref_clk;
bit                      px_clk;
bit                      rst;
bit [9 : 0]              tx_img [PX_AMOUNT - 1 : 0];
bit [15 : 0]             rx_img [PX_AMOUNT - 1 : 0];
bit [7 : 0]              tx_q   [BYTES_AMOUNT - 1 : 0];
bit [7 : 0]              rx_pkt_q [$];
logic save_f;
logic [3:0] digit;
logic digit_valid;


int mem_ptr;

initial
  begin
    //$readmemb( "../tb/scripts/px_img.bin", tx_img );
    //$readmemb( "../tb/scripts/csi2_img.bin", tx_q );
	$readmemh( "../output_files/raw10.hex", tx_q );
  end

dphy_if #(
  .DATA_LANES ( DATA_LANES )
) sender_if ();

axi4_stream_if #(
  .TDATA_WIDTH ( 16     )
) video (
  .aclk        ( px_clk ),
  .aresetn     ( !rst   )
);

assign dphy_data_p    = sender_if.hs_data_p;
assign dphy_data_n    = sender_if.hs_data_n;
assign dphy_clk_p     = sender_if.hs_clk_p;
assign dphy_clk_n     = sender_if.hs_clk_n;
assign dphy_lp_data_p = sender_if.lp_data_p;
assign dphy_lp_data_n = sender_if.lp_data_n;

mailbox data_to_send = new();
mailbox rx_data_mbx  = new();

DPHYSender #(
  .DATA_LANES ( DATA_LANES ),
  .DPHY_CLK_T ( DPHY_CLK_T )
) dphy_gen = new( .dphy_if_v    ( sender_if    ),
                  .data_to_send ( data_to_send )
                );

AXI4StreamSlave #(
  .TDATA_WIDTH ( 16 )
) axi4_stream_receiver;

task automatic ref_clk_gen();
  forever
    begin
      #( REF_CLK_T / 2 );
      ref_clk = !ref_clk;
    end
endtask

task automatic px_clk_gen();
  #2000;
  forever
    begin
      #( PX_CLK_T / 2 );
      px_clk = !px_clk;
    end
endtask

task automatic apply_rst;
  @( posedge px_clk );
  rst <= 1'b1;
  @( posedge px_clk );
  rst <= 1'b0;
endtask

// This function generates ECC for header
function automatic bit [7 : 0] gen_ham ( bit [23 : 0] data );
  bit [5:0] generated_parity;

  generated_parity[0] = data[0]  ^ data[1]  ^ data[2]  ^ data[4]  ^ data[5]  ^
                        data[7]  ^ data[10] ^ data[11] ^ data[13] ^ data[16] ^
                        data[20] ^ data[21] ^ data[22] ^ data[23];
  generated_parity[1] = data[0]  ^ data[1]  ^ data[3]  ^ data[4]  ^ data[6]  ^
                        data[8]  ^ data[10] ^ data[12] ^ data[14] ^ data[17] ^
                        data[20] ^ data[21] ^ data[22] ^ data[23];
  generated_parity[2] = data[0]  ^ data[2]  ^ data[3]  ^ data[5]  ^ data[6]  ^
                        data[9]  ^ data[11] ^ data[12] ^ data[15] ^ data[18] ^
                        data[20] ^ data[21] ^ data[22];
  generated_parity[3] = data[1]  ^ data[2]  ^ data[3]  ^ data[7]  ^ data[8]  ^
                        data[9]  ^ data[13] ^ data[14] ^ data[15] ^ data[19] ^
                        data[20] ^ data[21] ^ data[23];
  generated_parity[4] = data[4]  ^ data[5]  ^ data[6]  ^ data[7]  ^ data[8]  ^
                        data[9]  ^ data[16] ^ data[17] ^ data[18] ^ data[19] ^
                        data[20] ^ data[22] ^ data[23];
  generated_parity[5] = data[10] ^ data[11] ^ data[12] ^ data[13] ^ data[14] ^
                        data[15] ^ data[16] ^ data[17] ^ data[18] ^ data[19] ^
                        data[21] ^ data[22] ^ data[23];

  gen_ham = { 2'b0, generated_parity };
endfunction

function automatic bit [31 : 0] gen_header ( int          error_ins,
                                             int          error_pos,
                                             bit [7 : 0]  data_identifier,
                                             bit [15 : 0] word_cnt
                                           );
bit [7 : 0] ecc;
ecc = gen_ham ( { word_cnt, data_identifier } );
if( error_ins == 0 )
  gen_header = { ecc, word_cnt, data_identifier };
else
  begin
    gen_header            = { ecc, word_cnt, data_identifier };
    gen_header[error_pos] = !gen_header[error_pos];
  end
endfunction

function automatic bit [15 : 0] gen_crc ( bit [7 : 0] payload [$] );
  bit [7 : 0]  current_byte;
  bit [15 : 0] current_crc = 16'hffff;
  while( payload.size() > 0 )
    begin
      current_byte = payload.pop_front();
      for( int i = 0; i < 8; i++ )
        begin
          gen_crc[15] = current_crc[0] ^ current_byte[i];
          for( int j = 1; j < 16; j++ )
            if( CSI2_CRC_POLY[j] )
              gen_crc[15 - j] = current_crc[16 - j] ^ current_crc[0] ^ current_byte[i];
            else
              gen_crc[15 - j] = current_crc[16 - j];
          current_crc = gen_crc;
        end
    end
endfunction

task automatic send_long_pkt(
  input bit [7 : 0]  data_identifier,
  input bit [15 : 0] word_cnt
);
logic [31 : 0] header = gen_header( .error_ins       ( 0               ),
                                    .error_pos       ( 0               ),
                                    .data_identifier ( data_identifier ),
                                    .word_cnt        ( word_cnt        )
                                  );
bit [7 : 0]  tx_pkt_q [$];
bit [7 : 0]  tx_byte;
bit [15 : 0] crc;

@( posedge ref_clk );
for( int i = 0; i < 4; i++ )
  data_to_send.put( header[i * 8 + 7 -: 8] );
for( int i = 0; i < word_cnt; i++ )
  begin
    tx_byte = tx_q[mem_ptr];
    mem_ptr++;
    tx_pkt_q.push_back( tx_byte );
    data_to_send.put( tx_byte );
  end
crc = gen_crc( tx_pkt_q );
data_to_send.put( crc[7 : 0] );
data_to_send.put( crc[15 : 8] );
dphy_gen.send();
endtask

task automatic send_short_pkt(
  input bit [7 : 0]  data_identifier,
  input bit [15 : 0] data_field
);
bit [31 : 0] header = gen_header( .error_ins       ( 0               ),
                                  .error_pos       ( 0               ),
                                  .data_identifier ( data_identifier ),
                                  .word_cnt        ( data_field      )
                                );
bit [7 : 0] tx_pkt_q [$];
@( posedge ref_clk );
for( int i = 0; i < 4; i++ )
  begin
    tx_pkt_q.push_back( header[i * 8 + 7 -: 8] );
    data_to_send.put( header[i * 8 + 7 -: 8] );
  end
dphy_gen.send();
endtask

nn_mnist #(
  .DATA_LANES               ( DATA_LANES             )
) nn_mnist_inst (
  .dphy_clk_p               ( dphy_clk_p             ),
  .dphy_clk_n               ( dphy_clk_n             ),
  .dphy_data_p              ( dphy_data_p            ),
  .dphy_data_n              ( dphy_data_n            ),
  .dphy_lp_data_p           ( dphy_lp_data_p         ),
  .dphy_lp_data_n           ( dphy_lp_data_n         ),
  .ref_clk                  ( ref_clk                ),
  .rst                      ( rst                    ),
  .clk_i                    ( px_clk                 ),
  .rst_i                    ( rst                    ),
  .digit                    ( digit                  ),
  .digit_valid              ( digit_valid            )
);

int file;

initial
  begin
	save_f = 0;

    axi4_stream_receiver = new( .axi4_stream_if_v ( video       ),
                                .rx_data_mbx      ( rx_data_mbx )
                              );
    fork
      ref_clk_gen;
      px_clk_gen;
      apply_rst;
    join_none
    repeat( 1000 )
      @( posedge ref_clk );
    @( posedge ref_clk );
    repeat( 1 )
      begin
        send_short_pkt( .data_identifier ( 6'h0  ),
                        .data_field      ( 16'h0 )
                      );
        #1_000_000;
        repeat( Y_RES )
          begin
            send_long_pkt( .data_identifier ( 6'h2b  ),
                           .word_cnt        ( W_CNT )
                         );
            #( LINE_PERIOD - LINE_TIME );
          end
        #1_000_000;  
        send_short_pkt( .data_identifier( 6'h1   ),
                        .data_field     ( 6'h0 )
                      );
      end


    repeat( 23000 )
      @( posedge px_clk );
	  
	@( posedge px_clk );
	save_f = 1;
	@( posedge px_clk );
	save_f = 0;

    $stop;
  end

 initial begin
 
	@( posedge px_clk );
	@( posedge px_clk );
	@( posedge px_clk );
 
    file = $fopen("../output_files/rx_digit.dat","w");
    while(1)
      begin
	  
		@( posedge px_clk );
		if(digit_valid) begin
			$fdisplay(file, "%d", digit);
		end
		
		if(save_f)  $fclose(file);  		 
      end 
 end 

 endmodule