vcom src/rtl/common/*.vhd
vcom src/rtl/components/control_unit/control_unit.vhd
vcom src/rtl/components/register_file/register_file.vhd
vcom src/rtl/pipeline_stages/2-decode/decode_stage.vhd
vcom src/rtl/pipeline_stages/2-decode/decode_stage_tb.vhd
vsim decode_stage_tb
run 400 ns