vcom src/rtl/common/*.vhd
vcom src/rtl/components/Jump_Detection_Unit/jump_detection_unit.vhd
vcom src/rtl/components/Jump_Detection_Unit/Jump_Detection_unit_tb.vhd
vsim Jump_Detection_unit_tb
add wave -radix hex -r sim:/Jump_Detection_unit_tb/DUT/*
run 80 ns
wave zoom full