onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /nn_mnist_tb/nn_mnist_inst/dphy_lp_data_p
add wave -noupdate /nn_mnist_tb/nn_mnist_inst/dphy_lp_data_n
add wave -noupdate /nn_mnist_tb/nn_mnist_inst/dphy_data_p
add wave -noupdate /nn_mnist_tb/nn_mnist_inst/dphy_data_n
add wave -noupdate /nn_mnist_tb/nn_mnist_inst/dphy_clk_p
add wave -noupdate /nn_mnist_tb/nn_mnist_inst/dphy_clk_n
add wave -noupdate -divider {New Divider}
add wave -noupdate /nn_mnist_tb/nn_mnist_inst/payload_40b_if/tdata
add wave -noupdate /nn_mnist_tb/nn_mnist_inst/payload_40b_if/tvalid
add wave -noupdate /nn_mnist_tb/nn_mnist_inst/payload_40b_if/tready
add wave -noupdate /nn_mnist_tb/nn_mnist_inst/payload_40b_if/tlast
add wave -noupdate -divider {New Divider}
add wave -noupdate /nn_mnist_tb/nn_mnist_inst/nn_28x28_pixl_inst/rgb10
add wave -noupdate /nn_mnist_tb/nn_mnist_inst/nn_28x28_pixl_inst/dat_valid
add wave -noupdate /nn_mnist_tb/nn_mnist_inst/nn_28x28_pixl_inst/digit
add wave -noupdate /nn_mnist_tb/nn_mnist_inst/nn_28x28_pixl_inst/digit_valid
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {995452981 ps} 0}
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
WaveRestoreZoom {0 ps} {3709372161 ps}
