vcom ./src/rtl/common/*.vhd
vcom ./src/rtl/components/ALU/ALU.vhd
vcom ./src/rtl/components/Branch_Prediction_unit/Branch_Prediction_unit.vhd
vcom ./src/rtl/components/control_unit/control_unit.vhd
vcom ./src/rtl/components/flags_reg/flags_reg.vhd
vcom ./src/rtl/components/forwarding_unit/forwarding_unit.vhd
vcom ./src/rtl/components/hazard_control_unit/hazard_control_unit.vhd
vcom ./src/rtl/components/interrupt_handler/interrupt_handler.vhd
vcom ./src/rtl/components/jump_detection_unit/jump_detection_unit.vhd
vcom ./src/rtl/components/memory/memory.vhd
vcom ./src/rtl/components/multicycle_instruction_unit/multicycle_instruction_unit.vhd
vcom ./src/rtl/components/output_port/output_port.vhd
vcom ./src/rtl/components/pc_reg/pc_reg.vhd
vcom ./src/rtl/components/register_file/register_file.vhd
vcom ./src/rtl/components/sp_unit/sp_unit.vhd

vcom ./src/rtl/pipeline_registers/*.vhd

vcom ./src/rtl/pipeline_stages/1-fetch/fetch_stage.vhd
vcom ./src/rtl/pipeline_stages/2-decode/decode_stage.vhd
vcom ./src/rtl/pipeline_stages/3-execute-1/execute1_stage.vhd
vcom ./src/rtl/pipeline_stages/4-execute-2/execute2_stage.vhd
vcom ./src/rtl/pipeline_stages/5-memory/memory_stage.vhd


vcom ./src/rtl/processor.vhd