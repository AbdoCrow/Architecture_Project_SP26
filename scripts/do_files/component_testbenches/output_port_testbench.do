vcom src/rtl/common/*.vhd
vcom src/rtl/components/output_port/output_port.vhd
vcom src/rtl/components/output_port/output_port_tb.vhd
vsim output_port_tb
add wave -radix hex -r sim:/output_port_tb/DUT/*
run 70 ns
wave zoom full