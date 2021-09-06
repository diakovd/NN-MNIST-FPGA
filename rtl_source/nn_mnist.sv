
 module nn_mnist
 #(
  parameter int DATA_LANES       = 2
  )(

  // DPHY inputs
  input                              dphy_clk_p,
  input                              dphy_clk_n,
  input  [DATA_LANES - 1 : 0]        dphy_data_p,
  input  [DATA_LANES - 1 : 0]        dphy_data_n,
  input  [DATA_LANES - 1 : 0]        dphy_lp_data_p,
  input  [DATA_LANES - 1 : 0]        dphy_lp_data_n, 

  // 200 MHz refernce clock
  input                              ref_clk,
  input                              rst,

  output [3:0] digit,
  output digit_valid,
 
  // 74.25 MHz pixel clock
  input                              clk_i,
  input                              rst_i 
 );
 

 logic frame_start_pkt;
 logic frame_end_pkt;
 logic [29:0] rgb10; 
 logic dat_valid;

 logic frame_valid;
 
 // 40 bit payload
axi4_stream_if #(
  .TDATA_WIDTH ( 40        )
) payload_40b_if (
  .aclk        ( clk_i  ),
  .aresetn     ( !rst_i )
);
 
csi2_rx #(
  .DATA_LANES               ( DATA_LANES             )
) csi2_rx_inst (
  .dphy_clk_p_i             ( dphy_clk_p             ),
  .dphy_clk_n_i             ( dphy_clk_n             ),
  .dphy_data_p_i            ( dphy_data_p            ),
  .dphy_data_n_i            ( dphy_data_n            ),
  .lp_data_p_i              ( dphy_lp_data_p         ),
  .lp_data_n_i              ( dphy_lp_data_n         ),
  .ref_clk_i                ( ref_clk                ),
  .ref_rst_i                ( rst                    ),
  .px_clk_i                 ( clk_i                  ),
  .px_rst_i                 ( rst_i                  ),
  .enable_i                 ( 1'b1                   ),
  .delay_act_i              ( 1'b0                   ),
  .lane_delay_i             ( '0                     ),
  .header_err_o             (                        ),
  .corr_header_err_o        (                        ),
  .crc_err_o                (                        ),
  .payload_40b_if           ( payload_40b_if         ),
  .frame_start_pkt			( frame_start_pkt        ),
  .frame_end_pkt			( frame_end_pkt          )  
);

 
 raw10toRGB raw10toRGB_inst
 (
  .frame_start_i(frame_start_pkt), 
  .frame_end_i(frame_end_pkt),
	
  .pkt_i(payload_40b_if),

  .rgb10(rgb10),
  .dat_valid(dat_valid),
  .frame_valid(frame_valid),

  .Rst(rst_i),
  .Clk(clk_i)
 );

 nn_28x28_pixl nn_28x28_pixl_inst(
  .rgb10(rgb10),
  .dat_valid(dat_valid),
  .frame_start_pkt(frame_start_pkt),
  .frame_end_pkt(frame_end_pkt),
  .digit(digit),
  .digit_valid(digit_valid),
  
  .Rst(rst_i),
  .Clk(clk_i)
 );

 endmodule