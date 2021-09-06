onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /nn_mnist_tb/nn_mnist_inst/csi2_rx_inst/lp_data_p_i
add wave -noupdate /nn_mnist_tb/nn_mnist_inst/csi2_rx_inst/lp_data_n_i
add wave -noupdate /nn_mnist_tb/nn_mnist_inst/csi2_rx_inst/dphy_data_p_i
add wave -noupdate -expand /nn_mnist_tb/nn_mnist_inst/csi2_rx_inst/dphy_data_n_i
add wave -noupdate /nn_mnist_tb/nn_mnist_inst/csi2_rx_inst/dphy_clk_p_i
add wave -noupdate /nn_mnist_tb/nn_mnist_inst/csi2_rx_inst/dphy_clk_n_i
add wave -noupdate /nn_mnist_tb/nn_mnist_inst/payload_40b_if/aclk
add wave -noupdate /nn_mnist_tb/nn_mnist_inst/payload_40b_if/aresetn
add wave -noupdate /nn_mnist_tb/nn_mnist_inst/payload_40b_if/tvalid
add wave -noupdate /nn_mnist_tb/nn_mnist_inst/payload_40b_if/tready
add wave -noupdate /nn_mnist_tb/nn_mnist_inst/payload_40b_if/tdata
add wave -noupdate /nn_mnist_tb/nn_mnist_inst/payload_40b_if/tstrb
add wave -noupdate /nn_mnist_tb/nn_mnist_inst/payload_40b_if/tkeep
add wave -noupdate /nn_mnist_tb/nn_mnist_inst/payload_40b_if/tlast
add wave -noupdate /nn_mnist_tb/nn_mnist_inst/payload_40b_if/tid
add wave -noupdate /nn_mnist_tb/nn_mnist_inst/payload_40b_if/tdest
add wave -noupdate /nn_mnist_tb/nn_mnist_inst/payload_40b_if/tuser
add wave -noupdate -divider {New Divider}
add wave -noupdate /nn_mnist_tb/nn_mnist_inst/raw10toRGB_inst/rgb10
add wave -noupdate /nn_mnist_tb/nn_mnist_inst/raw10toRGB_inst/dat_valid
add wave -noupdate /nn_mnist_tb/nn_mnist_inst/nn_28x28_pixl_inst/digit_valid
add wave -noupdate /nn_mnist_tb/nn_mnist_inst/nn_28x28_pixl_inst/digit
add wave -noupdate -divider {New Divider}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {6340422371 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {12808632001 ps}
