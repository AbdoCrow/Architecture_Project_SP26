vcom src/rtl/common/*.vhd
vcom src/rtl/components/register_file/register_file.vhd
vcom src/rtl/components/register_file/register_file_tb.vhd
vsim register_file_tb
add wave -radix dec -r sim:/register_file_tb/DUT/*
run 200 ns
wave zoom full