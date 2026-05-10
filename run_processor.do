# =============================================================================
# SP26 6-Stage Processor Simulation Script
# Usage: do run_processor.do <program.asm> [run_time]
#   or just:  do run_processor.do
# and set ASM_FILE / RUN_TIME below manually.
# =============================================================================

# -----------------------------------------------------------------------------
# USER CONFIGURATION — edit these two lines before running
# -----------------------------------------------------------------------------
set ASM_FILE  "testcases/test2.asm"     ;# path to your .asm source file
set RUN_TIME  "500 ns"           ;# simulation duration after reset release
set CLOCK_PERIOD "50 ns"      ;# clock period (for stimulus timing)

# Memory hierarchy path — find this with:
#   find /processor -name mem
# or check your VHDL for the entity that instantiates 'memory'.
# Common candidates are shown; uncomment the one that matches.
set MEM_PATH  "/processor/memory_inst"
# set MEM_PATH  "/processor/id_memory_inst/mem"
# set MEM_PATH  "/processor/fetch_stage_inst/memory_inst/mem"


# =============================================================================
# STEP 1 — Assemble the source file
# =============================================================================
set MEM_FILE  [file rootname $ASM_FILE].mem

# echo ""
# echo "============================================================"
# echo " Assembling: $ASM_FILE  ->  $MEM_FILE"
# echo "============================================================"

# set assemble_rc [catch {exec python3 assembler.py $ASM_FILE $MEM_FILE} assemble_out]
# echo $assemble_out
# if {$assemble_rc != 0} {
#     echo "ERROR: Assembly failed. Fix the errors above and re-run."
#     return
# }


# =============================================================================
# STEP 2 — Compile design sources
# =============================================================================
echo ""
echo "============================================================"
echo " Compiling design"
echo "============================================================"

do compile_processor.do

# =============================================================================
# STEP 3 — Start simulation
# =============================================================================
echo ""
echo "============================================================"
echo " Starting simulation"
echo "============================================================"

vsim -t ns work.processor


# =============================================================================
# STEP 4 — Load assembled memory image
# =============================================================================
echo " Loading memory image: $MEM_FILE"
echo " Into: $MEM_PATH"
echo " (If this fails, set MEM_PATH at the top of this script)"

mem load -infile $MEM_FILE -format mti $MEM_PATH


# =============================================================================
# STEP 5 — Wave window setup
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
add wave -noupdate -label "RSRC1_SEL" -radix unsigned  sim:/processor/fwd_RSRC1_SEL
add wave -noupdate -label "RSRC2_SEL" -radix unsigned  sim:/processor/fwd_RSRC2_SEL
add wave -noupdate -label "FLAG_SRC"  -radix unsigned  sim:/processor/fwd_FLAG_SRC_SEL

# add wave -radix hex  -r sim:/processor/fetch_stage_inst/*
# add wave -radix hex  -r sim:/processor/decode_stage_inst/*
add wave -radix hex -r sim:/processor/execute1_stage_inst/* 
add wave -radix hex -r sim:/processor/execute2_stage_inst/* 
# add wave -radix hex  -r sim:/processor/memory_stage_inst/*
# add wave -radix hex  -r sim:/processor/memory_inst/memory_array
# add wave -radix hex  -r sim:/processor/interrupt_handler_inst/*
# add wave -radix hex  -r sim:/processor/hazard_control_unit_inst/*

add wave -radix hex  -r sim:/processor/ex1_HLT
add wave -radix hex  -r sim:/processor/dec_HLT



configure wave -namecolwidth  200
configure wave -valuecolwidth 120
configure wave -justifyvalue  left
configure wave -signalnamewidth 1
configure wave -timelineunits  ns

WaveRestoreZoom {0 ns} {200 ns}


# =============================================================================
# STEP 6 — Reset sequence
# =============================================================================
echo ""
echo "============================================================"
echo " Running reset then: $RUN_TIME"
echo "============================================================"

# 50 ns clock (25 ns half-period)
force -freeze sim:/processor/clk   1 0, 0 {25 ns} -r $CLOCK_PERIOD

# Drive IN_PORT to 0 by default; change mid-sim with:
#   force -freeze sim:/processor/in_port 16#ABCD1234 0
force -freeze sim:/processor/in_port  16#00000000 0

# Drive INTR low; raise it mid-sim with:
#   force -freeze sim:/processor/intr_in 1 0
#   run $CLOCK_PERIOD
#   force -freeze sim:/processor/intr_in 0 0
force -freeze sim:/processor/intr_in 0 0

# Assert reset for 1 cycle, then release
force -freeze sim:/processor/reset  1 0
run $CLOCK_PERIOD
force -freeze sim:/processor/reset  0 0

# run $RUN_TIME

# =============================================================================
# INPUT STIMULUS
# =============================================================================
# do Test1.do
do Test2.do
# do Test3.do
# do OneOperand.do
# do TwoOperand.do
# do Memory.do
# run $RUN_TIME
# =============================================================================
# STEP 7 — Fit waveform window
# =============================================================================
# wave zoom full

echo ""
echo "============================================================"
echo " Simulation complete."
echo " Tip: to rerun with a different time, type:"
echo "   run <time>"
echo " To trigger an interrupt:"
echo "   force -freeze sim:/processor/intr_in 1 0"
echo "   run 100ns"
echo "   force -freeze sim:/processor/intr_in 0 0"
echo "============================================================"
