
alias c "

	#vlog -O0 +acc ../rtl_source/csi2_rx-master/lib/unisim/BUFIO.v
	#vlog -O0 +acc ../rtl_source/csi2_rx-master/lib/unisim/BUFR.v
	#vlog -O0 +acc ../rtl_source/csi2_rx-master/lib/unisim/IBUFDS.v
	#vlog -O0 +acc ../rtl_source/csi2_rx-master/lib/unisim/ISERDESE2.v
	
	vlog -O0 +acc ../rtl_source/raw10toRGB/raw10toRGB.sv
	vlog -O0 +acc ../rtl_source/raw10toRGB/rgb10toGray8.sv

	vlog -O0 +acc ../rtl_source/nn/nn.sv
	vlog -O0 +acc ../rtl_source/nn/ram.sv
	vlog -O0 +acc ../rtl_source/nn/nn_ram.sv
	vlog -O0 +acc ../rtl_source/nn/nn_tb.sv
	vlog -O0 +acc ../rtl_source/nn/nn_28x28_pixl.sv
	
	vlog -O0 +acc ../rtl_source/nn_mnist.sv
	vlog -O0 +acc ../rtl_source/nn_mnist_tb.sv

	vlog -O0 +acc ../rtl_source/csi2_rx-master/lib/dphy_lib/dphy_if.sv
	vlog -O0 +acc ../rtl_source/csi2_rx-master/lib/axi4_lib/src/interface/axi4_stream_if.sv
	vlog -O0 +acc ../rtl_source/csi2_rx-master/lib/fifo_lib/src/bin2gray.sv
	vlog -O0 +acc ../rtl_source/csi2_rx-master/lib/fifo_lib/src/gray2bin.sv
	vlog -O0 +acc ../rtl_source/csi2_rx-master/lib/fifo_lib/src/dc_fifo.sv
	vlog -O0 +acc ../rtl_source/csi2_rx-master/lib/fifo_lib/src/axi4_stream_fifo.sv
	vlog -O0 +acc ../rtl_source/csi2_rx-master/src/csi2_data_types_pkg.sv
	vlog -L unisim -O0 +acc ../rtl_source/csi2_rx-master/src/dphy_hs_clk_rx.sv
	vlog -L unisim -O0 +acc ../rtl_source/csi2_rx-master/src/dphy_hs_data_rx.sv
	vlog -O0 +acc ../rtl_source/csi2_rx-master/src/dphy_settle_ignore.sv
	vlog -O0 +acc ../rtl_source/csi2_rx-master/src/clk_detect.sv
	vlog -O0 +acc ../rtl_source/csi2_rx-master/src/dphy_byte_align.sv
	vlog -O0 +acc ../rtl_source/csi2_rx-master/src/dphy_word_align.sv
	vlog -O0 +acc ../rtl_source/csi2_rx-master/src/dphy_32b_map.sv
	vlog -O0 +acc ../rtl_source/csi2_rx-master/src/dphy_slave.sv
	vlog -O0 +acc ../rtl_source/csi2_rx-master/ip/dual_port_ram/src/dual_port_ram.sv
	vlog -O0 +acc ../rtl_source/csi2_rx-master/ip/crc_calc/src/crc_calc.sv
	vlog -O0 +acc ../rtl_source/csi2_rx-master/src/csi2_crc_calc.sv
	vlog -O0 +acc ../rtl_source/csi2_rx-master/src/csi2_err_bit_pos_pkg.sv
	vlog -O0 +acc ../rtl_source/csi2_rx-master/src/csi2_hamming_dec.sv
	vlog -O0 +acc ../rtl_source/csi2_rx-master/src/csi2_to_axi4_stream.sv
	vlog -O0 +acc ../rtl_source/csi2_rx-master/src/csi2_pkt_handler.sv
	vlog -O0 +acc ../rtl_source/csi2_rx-master/src/csi2_raw10_32b_40b_gbx.sv
	vlog -O0 +acc ../rtl_source/csi2_rx-master/src/csi2_px_serializer.sv
	vlog -O0 +acc ../rtl_source/csi2_rx-master/src/csi2_rx.sv
	vlog -O0 +acc ../rtl_source/csi2_rx-master/tb/tb_csi2.sv
	
"
alias s "
	vopt -L unisim +acc -novopt -O0 work.nn_mnist_tb -o nn_mnist_tb_opt 
	vsim -L unisim -novopt work.nn_mnist_tb_opt 

	#vopt -L unisim +acc -novopt -O0 work.tb_csi2 -o tb_csi2_opt 
	#vsim -L unisim -novopt work.tb_csi2_opt 

	#vopt -L unisim +acc -novopt -O0 work.nn_tb -o nn_tb_opt 
	#vsim -L unisim -novopt work.nn_tb_opt 


	#do wave.do
	#do wave2.do
	#do wave3.do
	do wave4.do
	
	run 1 us
	wave zoom full
	"
