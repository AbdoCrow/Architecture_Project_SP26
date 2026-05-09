vcom src/rtl/common/*.vhd
vcom src/rtl/components/pc_reg/pc_reg.vhd
vcom src/rtl/components/multicycle_instruction_unit/multicycle_instruction_unit.vhd
vcom src/rtl/components/Branch_Prediction_Unit/branch_prediction_unit.vhd
vcom src/rtl/pipeline_stages/1-fetch/fetch_stage.vhd
vcom src/rtl/pipeline_stages/1-fetch/fetch_stage_tb.vhd
vsim fetch_stage_tb
add wave -radix hex -r sim:/fetch_stage_tb/DUT/*
wave zoom full
run 200 ns