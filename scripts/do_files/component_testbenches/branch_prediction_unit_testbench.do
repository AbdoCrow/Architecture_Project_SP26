vcom src/rtl/common/*.vhd
vcom src/rtl/components/Branch_Prediction_Unit/branch_prediction_unit.vhd
vcom src/rtl/components/Branch_Prediction_Unit/Branch_Prediction_unit_tb.vhd
vsim Branch_Prediction_unit_tb
add wave -radix hex -r sim:/Branch_Prediction_unit_tb/DUT/*
run 170 ns
wave zoom full