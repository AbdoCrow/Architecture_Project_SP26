vcom src/rtl/common/*.vhd
vcom src/rtl/components/ALU/ALU.vhd
vcom src/rtl/components/ALU/ALU_tb.vhd
vsim ALU_tb
add wave -radix hex -r sim:/ALU_tb/DUT/*
run 170 ns
wave zoom full