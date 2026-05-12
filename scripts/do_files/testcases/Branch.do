
set RUN_TIME  "500 ns"           ;#
set CLOCK_PERIOD "50 ns"      ;# clock period (for stimulus timing)
set MEM_FILE  "testcases/Branch.mem"
set MEM_PATH  "/processor/memory_inst"
# =============================================================================
# STEP 1 — Compile design sources
# =============================================================================
echo ""
echo "============================================================"
echo " Compiling design"
echo "============================================================"

do compile_processor.do

# =============================================================================
# STEP 2 — Start simulation
# =============================================================================
echo ""
echo "============================================================"
echo " Starting simulation"
echo "============================================================"

vsim -t ns work.processor


# =============================================================================
# STEP 3 — Load assembled memory image
# =============================================================================
echo " Loading memory image: $MEM_FILE"
echo " Into: $MEM_PATH"
echo " (If this fails, set MEM_PATH at the top of this script)"

mem load -infile $MEM_FILE -format mti $MEM_PATH


# =============================================================================
# STEP 4 — Wave window setup
# =============================================================================
quietly WaveActivateNextPane {} 0

# ---- Clock & control --------------------------------------------------------
add wave -noupdate -label "CLK"    -color "Yellow"       sim:/processor/clk
add wave -noupdate -label "RESET"  -color "Orange"       sim:/processor/reset
add wave -noupdate -label "INTR"   -color "Orange"       sim:/processor/intr_in

# ---- Ports ------------------------------------------------------------------
add wave -noupdate -label "IN_PORT"  -radix hex  sim:/processor/in_port
add wave -noupdate -label "OUT_PORT" -radix hex  sim:/processor/out_port
add wave -noupdate -label "HLT" -radix binary  sim:/processor/ex2_HLT
# ---- Programmer-visible state -----------------------------------------------
add wave -noupdate -label "PC"   -radix hex  sim:/processor/pc_monitor
add wave -noupdate -label "SP"   -radix hex  sim:/processor/sp_monitor
add wave -noupdate -label "CCR"  -radix binary       sim:/processor/ccr_monitor

# ---- Register file ----------------------------------------------------------
add wave -noupdate -label "R0" -radix hex  sim:/processor/r0_monitor
add wave -noupdate -label "R1" -radix hex  sim:/processor/r1_monitor
add wave -noupdate -label "R2" -radix hex  sim:/processor/r2_monitor
add wave -noupdate -label "R3" -radix hex  sim:/processor/r3_monitor
add wave -noupdate -label "R4" -radix hex  sim:/processor/r4_monitor
add wave -noupdate -label "R5" -radix hex  sim:/processor/r5_monitor
add wave -noupdate -label "R6" -radix hex  sim:/processor/r6_monitor
add wave -noupdate -label "R7" -radix hex  sim:/processor/r7_monitor

# ---- Pipeline stage visibility (comment out if signals don't exist yet) -----
add wave -noupdate -label "IF  instr"    -radix hex  sim:/processor/fetch_instr
add wave -noupdate -label "IF  next_pc"  -radix hex  sim:/processor/fetch_next_pc

# add wave -noupdate -label "ID  instr"    -radix hex  sim:/processor/decode_instr
add wave -noupdate -label "ID  next_pc"  -radix hex  sim:/processor/dec_next_pc

add wave -noupdate -label "EX1 next_pc"  -radix hex  sim:/processor/ex1_next_pc

add wave -noupdate -label "EX2 next_pc"  -radix hex  sim:/processor/ex2_next_pc
# add wave -noupdate -label "EX2 br_result"                     sim:/processor/ex2_branch_result
# add wave -noupdate -label "EX2 correct_pc" -radix hex sim:/processor/ex2_correct_pc_value

add wave -noupdate -label "MEM next_pc"  -radix hex  sim:/processor/mem_next_pc
# add wave -noupdate -label "MEM address"  -radix hex  sim:/processor/mem_address
# add wave -noupdate -label "MEM address"  -radix hex  sim:/processor/mem_addr

add wave -noupdate -label "STALL"          sim:/processor/haz_STALL
add wave -noupdate -label "FLUSH"          sim:/processor/haz_FLUSH
# add wave -noupdate -label "RSRC1_SEL" -radix unsigned  sim:/processor/fwd_RSRC1_SEL
# add wave -noupdate -label "RSRC2_SEL" -radix unsigned  sim:/processor/fwd_RSRC2_SEL
# add wave -noupdate -label "FLAG_SRC"  -radix unsigned  sim:/processor/fwd_FLAG_SRC_SEL

# add wave -radix hex  -r sim:/processor/hazard_control_unit_inst/*
# add wave -radix hex  -r sim:/processor/fetch_stage_inst/*
# add wave -radix hex  -r sim:/processor/decode_stage_inst/*
# add wave -radix hex -r sim:/processor/execute1_stage_inst/* 
# add wave -radix hex -r sim:/processor/execute2_stage_inst/* 
# add wave -radix hex  -r sim:/processor/memory_stage_inst/*
add wave -radix hex  -r sim:/processor/memory_inst/memory_array
# add wave -radix hex  -r sim:/processor/interrupt_handler_inst/*
# add wave -radix hex  -r sim:/processor/IF_ID_reg_inst/*
# add wave -radix hex  -r sim:/processor/ID_EX1_reg_inst/*
# add wave -radix hex  -r sim:/processor/EX1_EX2_reg_inst/*



add wave -radix hex  -r sim:/processor/ex1_HLT
add wave -radix hex  -r sim:/processor/dec_HLT



configure wave -namecolwidth  200
configure wave -valuecolwidth 120
configure wave -justifyvalue  left
configure wave -signalnamewidth 1
configure wave -timelineunits  ns

WaveRestoreZoom {0 ns} {200 ns}


# =============================================================================
# STEP 5 — Reset sequence
# =============================================================================
echo ""
echo "============================================================"
echo " Running reset"
echo "============================================================"

force -freeze sim:/processor/clk   1 0, 0 {25 ns} -r $CLOCK_PERIOD

force -freeze sim:/processor/in_port  16#00000000 0

force -freeze sim:/processor/intr_in 0 0

# Assert reset for 1 cycle, then release
force -freeze sim:/processor/reset  1 0
run $CLOCK_PERIOD
force -freeze sim:/processor/reset  0 0

# =============================================================================
# INPUT STIMULUS
# =============================================================================
force -freeze sim:/processor/in_port 16#00000030 0
run $CLOCK_PERIOD
force -freeze sim:/processor/in_port 16#00000050 0
run $CLOCK_PERIOD
force -freeze sim:/processor/in_port 16#00000100 0
run $CLOCK_PERIOD
force -freeze sim:/processor/in_port 16#00000300 0
run $CLOCK_PERIOD
run $RUN_TIME
force -freeze sim:/processor/in_port 16#00000060 0
run $CLOCK_PERIOD
run $CLOCK_PERIOD
run $CLOCK_PERIOD
run $CLOCK_PERIOD
run $CLOCK_PERIOD
force -freeze sim:/processor/in_port 16#00000070 0
run $RUN_TIME
run $CLOCK_PERIOD

force -freeze sim:/processor/intr_in 1 0
run $CLOCK_PERIOD
force -freeze sim:/processor/intr_in 0 0
force -freeze sim:/processor/in_port 16#00000005 0
run $RUN_TIME
run $CLOCK_PERIOD
run $CLOCK_PERIOD
run $CLOCK_PERIOD
run $CLOCK_PERIOD
force -freeze sim:/processor/intr_in 1 0
run $CLOCK_PERIOD
force -freeze sim:/processor/intr_in 0 0
force -freeze sim:/processor/in_port 16#00000005 0
run $RUN_TIME
run $CLOCK_PERIOD
run $CLOCK_PERIOD
force -freeze sim:/processor/in_port 16#00000600 0
run $RUN_TIME
run $CLOCK_PERIOD
force -freeze sim:/processor/intr_in 1 0
run $CLOCK_PERIOD
force -freeze sim:/processor/intr_in 0 0
force -freeze sim:/processor/in_port 16#00000005 0
run $RUN_TIME
run $CLOCK_PERIOD
run $CLOCK_PERIOD
run $CLOCK_PERIOD
run $CLOCK_PERIOD
run $CLOCK_PERIOD
run $CLOCK_PERIOD
run $CLOCK_PERIOD
run $CLOCK_PERIOD


force -freeze sim:/processor/intr_in 1 0
run $CLOCK_PERIOD
force -freeze sim:/processor/intr_in 0 0
run $RUN_TIME
run $RUN_TIME
run $RUN_TIME
run $RUN_TIME

wave zoom full