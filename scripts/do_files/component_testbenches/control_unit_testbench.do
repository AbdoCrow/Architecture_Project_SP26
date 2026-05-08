vcom src/rtl/common/*.vhd
vcom src/rtl/components/control_unit/control_unit.vhd
vcom src/rtl/components/control_unit/control_unit_tb.vhd
vsim control_unit_tb
run 300 ns