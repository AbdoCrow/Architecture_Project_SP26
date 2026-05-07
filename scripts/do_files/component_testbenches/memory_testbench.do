vcom src/rtl/common/*.vhd
vcom src/rtl/components/memory/memory.vhd
vcom src/rtl/components/memory/memory_tb.vhd
vsim memory_tb
add wave -radix hex -r sim:/memory_tb/DUT/*
run 200 ns
wave zoom full