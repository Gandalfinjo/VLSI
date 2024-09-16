onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /top/clk_reg
add wave -noupdate /top/rst_n_reg
add wave -noupdate /top/cl_reg
add wave -noupdate /top/ld_reg
add wave -noupdate /top/inc_reg
add wave -noupdate /top/dec_reg
add wave -noupdate /top/sr_reg
add wave -noupdate /top/ir_reg
add wave -noupdate /top/sl_reg
add wave -noupdate /top/il_reg
add wave -noupdate /top/in_reg
add wave -noupdate /top/out_reg
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
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
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {200 ps}
