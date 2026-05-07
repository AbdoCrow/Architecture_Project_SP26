vcom src/rtl/common/*.vhd
vcom src/rtl/components/Forwarding_Unit/forwarding_unit.vhd
vcom src/rtl/components/Forwarding_Unit/forwarding_unit_tb.vhd
vsim forwarding_unit_tb
add wave -radix hex -r sim:/forwarding_unit_tb/DUT/*
run 70 ns
wave zoom full