vcom src/rtl/common/*.vhd
vcom src/rtl/components/pc_reg/pc_reg.vhd
vcom src/rtl/components/pc_reg/pc_reg_tb.vhd
vsim pc_reg_tb
add wave -radix hex -r sim:/pc_reg_tb/DUT/*
run 70 ns
wave zoom full