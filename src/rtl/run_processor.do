# SP26 6-stage skeleton simulation script

# TODO: create work library
# vlib work

# TODO: compile order (example)
# 1) common/
# 2) components/
# 3) control_unit/
# 4) registers/
# 5) stages/1-fetch
# 6) stages/2-decode
# 7) stages/3-execute-1
# 8) stages/4-execute-2
# 9) stages/5-memory
# 10) stages/6-writeback
# 11) processor.vhd

# TODO: start simulation
# vsim work.processor

# TODO: load memory image from assembler output
# mem load -i <program.mem> /processor/<memory_signal_path>

# TODO: clean wave (main signals only)
# CLK, Reset, INTR, IN.PORT, OUT.PORT
# R0..R7, PC, SP, CCR

# TODO: force/reset/run
# force -freeze sim:/processor/clk 1 0, 0 {50 ns} -r 100ns
# force -freeze sim:/processor/reset 1 0
# run 100ns
# force -freeze sim:/processor/reset 0 0
# run 5 us
