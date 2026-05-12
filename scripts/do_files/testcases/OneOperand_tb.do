
set ASM_FILE  "testcases/OneOperand.asm"     ;# path to your .asm source file
set RUN_TIME  "200 ns"
set MEM_FILE  [file rootname $ASM_FILE].mem
set MEM_PATH  "/oneoperand_tb/uut/memory_inst"
# =============================================================================
# STEP 1 — Compile design sources
# =============================================================================
echo ""
echo "============================================================"
echo " Compiling design"
echo "============================================================"

do compile_processor.do
vcom ./src/rtl/oneoperand_tb.vhd

# =============================================================================
# STEP 2 — Start simulation
# =============================================================================
echo ""
echo "============================================================"
echo " Starting simulation"
echo "============================================================"

vsim -t ns work.oneoperand_tb


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
add wave -noupdate -label "CLK"    -color "Yellow"       sim:/oneoperand_tb/uut/clk
add wave -noupdate -label "RESET"  -color "Orange"       sim:/oneoperand_tb/uut/reset
add wave -noupdate -label "INTR"   -color "Orange"       sim:/oneoperand_tb/uut/intr_in

# ---- Ports ------------------------------------------------------------------
add wave -noupdate -label "IN_PORT"  -radix hex  sim:/oneoperand_tb/uut/in_port
add wave -noupdate -label "OUT_PORT" -radix hex  sim:/oneoperand_tb/uut/out_port
add wave -noupdate -label "HLT" -radix binary  sim:/oneoperand_tb/uut/ex2_HLT
# ---- Programmer-visible state -----------------------------------------------
add wave -noupdate -label "PC"   -radix hex  sim:/oneoperand_tb/uut/pc_monitor
add wave -noupdate -label "SP"   -radix hex  sim:/oneoperand_tb/uut/sp_monitor
add wave -noupdate -label "CCR"  -radix binary       sim:/oneoperand_tb/uut/ccr_monitor

# ---- Register file ----------------------------------------------------------
add wave -noupdate -label "R0" -radix hex  sim:/oneoperand_tb/uut/r0_monitor
add wave -noupdate -label "R1" -radix hex  sim:/oneoperand_tb/uut/r1_monitor
add wave -noupdate -label "R2" -radix hex  sim:/oneoperand_tb/uut/r2_monitor
add wave -noupdate -label "R3" -radix hex  sim:/oneoperand_tb/uut/r3_monitor
add wave -noupdate -label "R4" -radix hex  sim:/oneoperand_tb/uut/r4_monitor
add wave -noupdate -label "R5" -radix hex  sim:/oneoperand_tb/uut/r5_monitor
add wave -noupdate -label "R6" -radix hex  sim:/oneoperand_tb/uut/r6_monitor
add wave -noupdate -label "R7" -radix hex  sim:/oneoperand_tb/uut/r7_monitor

# ---- Pipeline stage visibility (comment out if signals don't exist yet) -----
add wave -noupdate -label "IF  instr"    -radix hex  sim:/oneoperand_tb/uut/fetch_instr
add wave -noupdate -label "IF  next_pc"  -radix hex  sim:/oneoperand_tb/uut/fetch_next_pc

# add wave -noupdate -label "ID  instr"    -radix hex  sim:/oneoperand_tb/uut/decode_instr
add wave -noupdate -label "ID  next_pc"  -radix hex  sim:/oneoperand_tb/uut/dec_next_pc

add wave -noupdate -label "EX1 next_pc"  -radix hex  sim:/oneoperand_tb/uut/ex1_next_pc

add wave -noupdate -label "EX2 next_pc"  -radix hex  sim:/oneoperand_tb/uut/ex2_next_pc
# add wave -noupdate -label "EX2 br_result"                     sim:/oneoperand_tb/uut/ex2_branch_result
# add wave -noupdate -label "EX2 correct_pc" -radix hex sim:/oneoperand_tb/uut/ex2_correct_pc_value

add wave -noupdate -label "MEM next_pc"  -radix hex  sim:/oneoperand_tb/uut/mem_next_pc
# add wave -noupdate -label "MEM address"  -radix hex  sim:/oneoperand_tb/uut/mem_address
# add wave -noupdate -label "MEM address"  -radix hex  sim:/oneoperand_tb/uut/mem_addr

add wave -noupdate -label "STALL"          sim:/oneoperand_tb/uut/haz_STALL
add wave -noupdate -label "FLUSH"          sim:/oneoperand_tb/uut/haz_FLUSH
# add wave -noupdate -label "RSRC1_SEL" -radix unsigned  sim:/oneoperand_tb/uut/fwd_RSRC1_SEL
# add wave -noupdate -label "RSRC2_SEL" -radix unsigned  sim:/oneoperand_tb/uut/fwd_RSRC2_SEL
# add wave -noupdate -label "FLAG_SRC"  -radix unsigned  sim:/oneoperand_tb/uut/fwd_FLAG_SRC_SEL

# add wave -radix hex  -r sim:/oneoperand_tb/uut/hazard_control_unit_inst/*
# add wave -radix hex  -r sim:/oneoperand_tb/uut/fetch_stage_inst/*
# add wave -radix hex  -r sim:/oneoperand_tb/uut/decode_stage_inst/*
# add wave -radix hex -r sim:/oneoperand_tb/uut/execute1_stage_inst/* 
# add wave -radix hex -r sim:/oneoperand_tb/uut/execute2_stage_inst/* 
# add wave -radix hex  -r sim:/oneoperand_tb/uut/memory_stage_inst/*
add wave -radix hex  -r sim:/oneoperand_tb/uut/memory_inst/memory_array
# add wave -radix hex  -r sim:/oneoperand_tb/uut/interrupt_handler_inst/*
# add wave -radix hex  -r sim:/oneoperand_tb/uut/IF_ID_reg_inst/*
# add wave -radix hex  -r sim:/oneoperand_tb/uut/ID_EX1_reg_inst/*
# add wave -radix hex  -r sim:/oneoperand_tb/uut/EX1_EX2_reg_inst/*



add wave -radix hex  -r sim:/oneoperand_tb/uut/ex1_HLT
add wave -radix hex  -r sim:/oneoperand_tb/uut/dec_HLT



configure wave -namecolwidth  200
configure wave -valuecolwidth 120
configure wave -justifyvalue  left
configure wave -signalnamewidth 1
configure wave -timelineunits  ns

WaveRestoreZoom {0 ns} {200 ns}
run $RUN_TIME
wave zoom full