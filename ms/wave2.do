onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /nn_tb/nn_inst/x
add wave -noupdate /nn_tb/nn_inst/w
add wave -noupdate /nn_tb/nn_inst/b
add wave -noupdate /nn_tb/nn_inst/x_valid
add wave -noupdate /nn_tb/nn_inst/x_L2
add wave -noupdate /nn_tb/nn_inst/x
add wave -noupdate /nn_tb/nn_inst/wr
add wave -noupdate /nn_tb/nn_inst/w
add wave -noupdate /nn_tb/nn_inst/L1
add wave -noupdate /nn_tb/nn_inst/L2
add wave -noupdate /nn_tb/nn_inst/L1_out
add wave -noupdate /nn_tb/nn_inst/ReluL1
add wave -noupdate /nn_tb/nn_inst/sum
add wave -noupdate /nn_tb/nn_inst/state
add wave -noupdate /nn_tb/nn_inst/Rst
add wave -noupdate /nn_tb/nn_inst/L1_const
add wave -noupdate {/nn_tb/nn_inst/genblk1[0]/wb_ram/data_rd}
add wave -noupdate {/nn_tb/nn_inst/genblk1[1]/wb_ram/data_rd}
add wave -noupdate {/nn_tb/nn_inst/genblk1[2]/wb_ram/data_rd}
add wave -noupdate {/nn_tb/nn_inst/genblk1[3]/wb_ram/data_rd}
add wave -noupdate /nn_tb/nn_inst/mul_dat
add wave -noupdate /nn_tb/nn_inst/mul
add wave -noupdate /nn_tb/nn_inst/L2size
add wave -noupdate /nn_tb/nn_inst/L1size
add wave -noupdate /nn_tb/nn_inst/INPUTsize
add wave -noupdate /nn_tb/nn_inst/data_wr
add wave -noupdate /nn_tb/nn_inst/data_rd
add wave -noupdate /nn_tb/nn_inst/conv_compl
add wave -noupdate -radix unsigned -childformat {{{/nn_tb/nn_inst/cnt[9]} -radix unsigned} {{/nn_tb/nn_inst/cnt[8]} -radix unsigned} {{/nn_tb/nn_inst/cnt[7]} -radix unsigned} {{/nn_tb/nn_inst/cnt[6]} -radix unsigned} {{/nn_tb/nn_inst/cnt[5]} -radix unsigned} {{/nn_tb/nn_inst/cnt[4]} -radix unsigned} {{/nn_tb/nn_inst/cnt[3]} -radix unsigned} {{/nn_tb/nn_inst/cnt[2]} -radix unsigned} {{/nn_tb/nn_inst/cnt[1]} -radix unsigned} {{/nn_tb/nn_inst/cnt[0]} -radix unsigned}} -subitemconfig {{/nn_tb/nn_inst/cnt[9]} {-height 15 -radix unsigned} {/nn_tb/nn_inst/cnt[8]} {-height 15 -radix unsigned} {/nn_tb/nn_inst/cnt[7]} {-height 15 -radix unsigned} {/nn_tb/nn_inst/cnt[6]} {-height 15 -radix unsigned} {/nn_tb/nn_inst/cnt[5]} {-height 15 -radix unsigned} {/nn_tb/nn_inst/cnt[4]} {-height 15 -radix unsigned} {/nn_tb/nn_inst/cnt[3]} {-height 15 -radix unsigned} {/nn_tb/nn_inst/cnt[2]} {-height 15 -radix unsigned} {/nn_tb/nn_inst/cnt[1]} {-height 15 -radix unsigned} {/nn_tb/nn_inst/cnt[0]} {-height 15 -radix unsigned}} /nn_tb/nn_inst/cnt
add wave -noupdate /nn_tb/nn_inst/clr_sum
add wave -noupdate /nn_tb/nn_inst/Clk
add wave -noupdate /nn_tb/nn_inst/b
add wave -noupdate /nn_tb/nn_inst/addrWR
add wave -noupdate /nn_tb/nn_inst/addrRD
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {16504 ns} 0}
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
WaveRestoreZoom {16440 ns} {16727 ns}
