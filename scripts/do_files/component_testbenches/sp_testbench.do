vcom src/rtl/common/*.vhd
vcom src/rtl/components/sp_unit/sp_unit.vhd
vcom src/rtl/components/sp_unit/sp_unit_tb.vhd
vsim sp_unit_tb
add wave -radix dec -r sim:/sp_unit_tb/DUT/*
run 120 ns
wave zoom full