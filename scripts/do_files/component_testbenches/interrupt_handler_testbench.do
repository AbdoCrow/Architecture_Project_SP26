vcom src/rtl/common/*.vhd
vcom src/rtl/components/interrupt_handler/interrupt_handler.vhd
vcom src/rtl/components/interrupt_handler/interrupt_handler_tb.vhd
vsim interrupt_handler_tb
add wave -radix hex -r sim:/interrupt_handler_tb/DUT/*
run 70 ns
wave zoom full