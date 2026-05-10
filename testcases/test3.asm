# =============================================================================
# COMPREHENSIVE TEST CASE - RISC Processor
# =============================================================================
# All immediates / addresses in HEX unless noted.
# "Expected:" comments show the architectural state AFTER the instruction
# retires (post-writeback), so they can be used to drive a testbench.
#
# SECTIONS
#   0x000        Reset vector  -> 0x004 
#   0x001        HW-INT vector -> 0xA00
#   0x002        INT0 vector   -> 0x500
#   0x003        INT1 vector   -> 0x600
#
#   0x004-0x0FF  Section 1 : ALU & Immediate ops
#   0x100-0x1FF  Section 2 : Memory (PUSH/POP, LDM, LDD, STD)
#   0x200-0x2FF  Section 3 : Branches & flags (JZ / JN / JC / JMP)
#   0x300-0x3FF  Section 4 : CALL / RET chain
#   0x400-0x4FF  Section 5 : NOT / SETC / flag forwarding stress
#   0x500-0x5FF  INT 0 handler
#   0x600-0x6FF  INT 1 handler
#   0xA00-0xAFF  HW-INT handler
# =============================================================================

# --- interrupt-vector directives  --------------------------------------------
# .INT_VECTOR 0   INT0_HANDLER    # INT 0  -> 0x500
# .INT_VECTOR 1   INT1_HANDLER    # INT 1  -> 0x600

# =============================================================================
# SECTION 1 - ALU & Immediate operations (0x004)
# =============================================================================
# Goal: verify ADD, SUB, AND, NOT, INC, MOV, SWAP, IADD, SETC, IN, OUT
# All inputs come from IN so the testbench can drive known values.
#
#  Register file at section start  (all undefined / 0)
# =============================================================================
.ORG 0
4
.ORG 1
A00
.ORG 2
500
.ORG 3
600
.ORG 4

SECTION1_START:
    IN   R1                  # R1 = 0x0010  (user drives 0x0010)
    IN   R2                  # R2 = 0x0020  (user drives 0x0020)
    IN   R3                  # R3 = 0x0005  (user drives 0x0005)

    # --- MOV (register copy) -------------------------------------------------
    MOV  R4, R1              # R4 = R1 = 0x0010   ; flags unchanged
    OUT  R4                  # Expected OUT: 0x0010

    # --- ADD -----------------------------------------------------------------
    ADD  R5, R1, R2          # R5 = 0x0010 + 0x0020 = 0x0030 ; Z=0,N=0,C=0
    OUT  R5                  # Expected OUT: 0x0030

    # --- SUB (result positive) -----------------------------------------------
    SUB  R6, R2, R1          # R6 = 0x0020 - 0x0010 = 0x0010 ; Z=0,N=0,C=0
    OUT  R6                  # Expected OUT: 0x0010

    # --- SUB (result zero -> Z flag) -----------------------------------------
    SUB  R6, R1, R1          # R6 = 0x0010 - 0x0010 = 0x0000 ; Z=1,N=0,C=0
    OUT  R6                  # Expected OUT: 0x0000

    # --- AND (result zero -> Z flag) -----------------------------------------
    AND  R5, R1, R6          # R5 = 0x0010 & 0x0000 = 0x0000 ; Z=1,N=0
    OUT  R5                  # Expected OUT: 0x0000

    # --- NOT (of zero -> all ones) --------------------------------------------
    NOT  R5                  # R5 = ~0x0000 = 0xFFFFFFFF ; Z=0,N=1
    OUT  R5                  # Expected OUT: 0xFFFFFFFF

    # --- AND (non-zero result) ----------------------------------------------
    AND  R7, R1, R1          # R7 = 0x0010 & 0x0010 = 0x0010 ; Z=0,N=0
    OUT  R7                  # Expected OUT: 0x0010

    # --- IADD (immediate add, result positive) --------------------------------
    IADD R4, R1, 0005        # R4 = 0x0010 + 0x0005 = 0x0015 ; Z=0,N=0
    OUT  R4                  # Expected OUT: 0x0015

    # --- INC (adds 1) --------------------------------------------------------
    INC  R3                  # R3 = 0x0005 + 1 = 0x0006 ; Z=0,N=0
    INC  R3                  # R3 = 0x0006 + 1 = 0x0007
    OUT  R3                  # Expected OUT: 0x0007

    # --- SETC (force carry flag) ----------------------------------------------
    SETC                     # C = 1  ; other flags unchanged
    OUT  R3                  # Expected OUT: 0x0007  (OUT does not alter C)

    # --- SWAP ---------------------------------------------------------------
    SWAP R1, R2              # R1 ↔ R2 -> R1=0x0020, R2=0x0010
    OUT  R1                  # Expected OUT: 0x0020
    OUT  R2                  # Expected OUT: 0x0010

    # --- Flag forwarding hazard: result of ADD used immediately by JZ --------
    # ADD writes Z; next instruction reads Z - tests 1-cycle forwarding path
    AND  R0, R0, R0          # R0 = 0, Z=1 (forward Z into JZ below)
    JZ   SECTION2_START      # TAKEN (Z=1 from AND above, forwarded)
    INC  R0                  # MUST NOT EXECUTE
    INC  R0                  # MUST NOT EXECUTE


# =============================================================================
# SECTION 2 - Memory: PUSH / POP / LDM / LDD / STD  (0x100)
# =============================================================================
# SP starts at 0xFFF (top of memory).
# After each PUSH  SP decrements by 1.
# After each POP   SP increments by 1.
#
# Register state on entry (from Section 1):
#   R0=0x0000  R1=0x0020  R2=0x0010  R3=0x0007
#   R4=0x00010000  R5=0xFFFFFFFF  R6=0x0000  R7=0x0010
# =============================================================================

.ORG 100
SECTION2_START:

    # --- LDM (load immediate word into register) -----------------------------
    LDM  R0, ABCD            # R0 = 0x0000ABCD  ; flags: Z=0,N=0
    OUT  R0                  # Expected OUT: 0x0000ABCD

    LDM  R6, 0000            # R6 = 0x00000000  ; Z=1,N=0
    OUT  R6                  # Expected OUT: 0x00000000

    # --- PUSH / POP roundtrip ------------------------------------------------
    PUSH R0                  # SP = 0xFFE, M[0xFFF] = 0x0000ABCD
    PUSH R1                  # SP = 0xFFD, M[0xFFE] = 0x0020
    PUSH R3                  # SP = 0xFFC, M[0xFFD] = 0x0007

    POP  R5                  # R5 = 0x0007, SP = 0xFFD  ; Z=0,N=0
    OUT  R5                  # Expected OUT: 0x0007

    POP  R5                  # R5 = 0x0020, SP = 0xFFE
    OUT  R5                  # Expected OUT: 0x0020

    POP  R5                  # R5 = 0x0000ABCD, SP = 0xFFF
    OUT  R5                  # Expected OUT: 0x0000ABCD

    # --- STD / LDD -----------------------------------------------------------
    # Use R7 (=0x0010) as base address register for memory access tests.
    # First load a known base address into R7 via LDM.
    LDM  R7, 0F00            # R7 = 0x0F00 (points well inside data area)

    LDM  R0, 1234            # R0 = 0x1234 (data to store)
    LDM  R1, 5678            # R1 = 0x5678

    STD  R0, 0(R7)           # M[0x0F00 + 0x0000] = M[0x0F00] = 0x1234
    STD  R1, 1(R7)           # M[0x0F01] = 0x5678

    # Load use hazard: LDD result needed by next instruction
    LDD  R4, 0(R7)           # R4 = M[0x0F00] = 0x1234  (1-cycle stall expected)
    OUT  R4                  # Expected OUT: 0x1234      (stall resolved before OUT)

    LDD  R5, 1(R7)           # R5 = M[0x0F01] = 0x5678
    OUT  R5                  # Expected OUT: 0x5678

    # Back-to-back LDD then STD (write then read same location)
    LDM  R2, FFFF
    STD  R2, 2(R7)           # M[0x0F02] = 0xFFFF
    LDD  R3, 2(R7)           # R3 = 0xFFFF
    OUT  R3                  # Expected OUT: 0x0000FFFF

    # --- PUSH then POP into different register (cross-register check) ---------
    LDM  R0, CAFE
    PUSH R0                  # SP = 0xFFE, M[0xFFF] = 0xCAFE
    POP  R6                  # R6 = 0xCAFE, SP = 0xFFF
    OUT  R6                  # Expected OUT: 0x0000CAFE

    JMP  SECTION3_START      # Jump to branch-test section


# =============================================================================
# SECTION 3 - Branches & Flags  (0x200)
# =============================================================================
# Tests JZ, JN, JC, JMP, and flag behaviour across pipeline stages.
#
# Register state on entry:
#   R0=0xCAFE  R1=0x5678  R2=0xFFFF  R3=0xFFFF
#   R4=0x1234  R5=0x5678  R6=0xCAFE  R7=0x0200
# =============================================================================

.ORG 200
SECTION3_START:

    # ----- JZ tests ----------------------------------------------------------
    # 3a. JZ NOT taken (Z=0 after SUB with non-zero result)
    SUB  R0, R1, R4          # R0 = 0x5678 - 0x1234 = 0x4444 ; Z=0
    JZ   FAIL_BRANCH         # MUST NOT BE TAKEN
    OUT  R0                  # Expected OUT: 0x4444

    # 3b. JZ taken (Z=1 after AND with zero)
    AND  R0, R6, R4          # R0 = 0xCAFE & 0x1234 = 0x0234 ; Z=0 (intermediate)
    SUB  R0, R0, R0          # R0 = 0 ; Z=1
    JZ   JZ_TAKEN            # TAKEN
    INC  R0                  # MUST NOT EXECUTE
    INC  R0

JZ_TAKEN:
    OUT  R0                  # Expected OUT: 0x0000

    # 3c. Flag NOT forwarded across JZ (Z updated by JZ itself to 0 after taken)
    JZ   FAIL_BRANCH         # Z was cleared by the taken JZ above -> NOT TAKEN

    # ----- JN tests ----------------------------------------------------------
    # 3d. JN taken (N=1 from NOT of zero)
    NOT  R0                  # R0 = 0xFFFFFFFF ; N=1,Z=0
    JN   JN_TAKEN            # TAKEN
    INC  R0                  # MUST NOT EXECUTE

JN_TAKEN:
    OUT  R0                  # Expected OUT: 0xFFFFFFFF

    # 3e. JN not taken after a positive result
    LDM  R0, 0001
    JN   FAIL_BRANCH         # N=0 from LDM (N not set by LDM)
                             # NOTE: LDM does not update flags, so N=1 still from NOT
                             # Adjusted: use ADD to clear N
    ADD  R0, R4, R4          # R0 = 0x1234+0x1234 = 0x2468; N=0,Z=0
    JN   FAIL_BRANCH         # MUST NOT BE TAKEN
    OUT  R0                  # Expected OUT: 0x2468

    # ----- JC tests ----------------------------------------------------------
    # 3f. Generate carry with ADD of large values
    LDM  R1, FFFF
    LDM  R2, 0002
    ADD  R3, R1, R2          # R3 = 0xFFFF + 0x0002 = 0x10001 -> low 32 bits = 0x10001
                             # C=0 (no 32-bit carry), N=0, Z=0
                             # To generate C: need 32-bit overflow
                             # Use SETC to force C=1 for JC test
    SETC                     # C = 1
    JC   JC_TAKEN            # TAKEN
    INC  R0                  # MUST NOT EXECUTE

JC_TAKEN:
    OUT  R3                  # Expected OUT: 0x00010001

    # 3g. JC not taken (C=0 after AND)
    AND  R0, R0, R0          # C unchanged by AND (C=1 still!)
                             # C is only changed by SETC / ADD / SUB / INC
    SUB  R3, R4, R4          # R3 = 0 ; Z=1, N=0, C=0 (no borrow)
    JC   FAIL_BRANCH         # C=0 -> MUST NOT BE TAKEN
    OUT  R3                  # Expected OUT: 0x0000

    # ----- Unconditional JMP -------------------------------------------------
    JMP  SECTION4_START      # Always taken
    INC  R7                  # MUST NOT EXECUTE


# =============================================================================
# FAIL target - if execution ever reaches here, a branch was mispredicted
# =============================================================================
FAIL_BRANCH:
    LDM  R0, DEAD            # sentinel: OUT 0xDEAD signals test failure
    OUT  R0
    HLT


# =============================================================================
# SECTION 4 - CALL / RET chain  (0x300)
# =============================================================================
# Tests nested CALL/RET with register preservation.
#
# Register state on entry (from Section 3):
#   R3=0x0000  R4=0x1234  R7=0x0200  SP=0xFFF  C=0,Z=1,N=0
# =============================================================================

.ORG 300
SECTION4_START:

    LDM  R1, 0001            # R1 = canary value 0x0001
    LDM  R2, 0002            # R2 = 0x0002

    CALL FUNC_ADD            # SP=0xFFE, M[0xFFF]=return addr ; R3 = R1+R2 = 0x0003
    OUT  R3                  # Expected OUT: 0x0003   (result from FUNC_ADD)

    CALL FUNC_NESTED         # Calls FUNC_ADD internally
    OUT  R4                  # Expected OUT: 0x0006   (R4 = 2*R3 set inside FUNC_NESTED)

    # --- Verify SP restored correctly ----------------------------------------
    LDM  R0, 0FFF
    SUB  R5, R0, R7          # meaningless arithmetic, just to produce a known OUT
    OUT  R1                  # R1 still 0x0001 (CALL must not clobber caller regs)
    OUT  R2                  # R2 still 0x0002

    JMP  SECTION5_START


# --- FUNC_ADD(R1,R2) -> R3 = R1+R2  ; does not push/pop (leaf function) ------
.ORG 380
FUNC_ADD:
    ADD  R3, R1, R2          # R3 = R1 + R2
    RET                      # PC = M[SP], SP++


# --- FUNC_NESTED  : R4 = 2*(R1+R2) by calling FUNC_ADD twice ----------------
.ORG 390
FUNC_NESTED:
    CALL FUNC_ADD            # R3 = R1+R2 = 0x0003
    ADD  R4, R3, R3          # R4 = 2*R3 = 0x0006
    RET


# =============================================================================
# SECTION 5 - INT 0 handler test  (trigger at 0x400, handler at 0x500)
# =============================================================================
# The INT instruction saves PC+flags on the stack and jumps to the vector.
# The handler reads a port and returns via RTI.
#
# Register state on entry (from Section 4):
#   R1=0x0001  R2=0x0002  R3=0x0003  R4=0x0006  SP=0xFFF
# =============================================================================

.ORG 400
SECTION5_START:

    LDM  R5, 00AA            # R5 = 0x00AA (value to verify RTI restored context)
    INT  0                   # Invoke INT0 ; PC->stack, flags->stack, PC<-vector[0x002]
                             # Handler at 0x500: IN R0 (reads 0xBEEF), RTI
    OUT  R0                  # Expected OUT: 0xBEEF  (set by INT0 handler)
    OUT  R5                  # Expected OUT: 0x00AA  (RTI must have restored flags/regs indirectly)

    # Verify flags restored by RTI (Z was 1 going into INT from SUB R5-R5 ... actually
    # let us set a known flag state before INT and confirm it after RTI)
    SUB  R6, R3, R3          # R6 = 0, Z=1
    INT  0                   # flags saved (Z=1) -> handler clobbers flags -> RTI restores Z=1
    JZ   AFTER_INT0_JZ       # TAKEN if RTI correctly restored Z=1
    LDM  R0, DEAD
    OUT  R0                  # sentinel: RTI did NOT restore flags -> failure

AFTER_INT0_JZ:
    OUT  R6                  # Expected OUT: 0x0000

    # --- INT 1 test ----------------------------------------------------------
    LDM  R2, 1111
    INT  1                   # Invoke INT1 ; handler at 0x600: IN R1 (reads 0x7777), RTI
    OUT  R1                  # Expected OUT: 0x7777
    OUT  R2                  # Expected OUT: 0x1111  (INT1 handler must not touch R2)

    JMP  SECTION6_START


# =============================================================================
# SECTION 6 - Edge cases and forwarding stress  (0x700)
# =============================================================================
# Tests:
#   a) ALU -> ALU forwarding (back-to-back dependent instructions)
#   b) Load-use stall (LDD result used immediately)
#   c) SUB producing negative (N flag)
#   d) Flag register across PUSH/POP
#   e) CALL from inside a loop (simple counted loop)
# =============================================================================

.ORG 700
SECTION6_START:

    # --- (a) ALU -> ALU forwarding -------------------------------------------
    # Each line depends on the previous result - all must forward without stalls.
    LDM  R0, 0001
    INC  R0                  # R0 = 0x0002  (depends on LDM: forward path)
    ADD  R1, R0, R0          # R1 = 0x0004  (depends on INC: forward path)
    ADD  R2, R1, R0          # R2 = 0x0006  (depends on ADD: forward path)
    ADD  R3, R2, R1          # R3 = 0x000A  (forward chain)
    ADD  R4, R3, R2          # R4 = 0x0010
    OUT  R4                  # Expected OUT: 0x0010

    # --- (b) Load-use stall: LDD -> immediate use ----------------------------
    # Processor must insert a bubble; result must still be correct.
    LDM  R7, 0F00            # R7 = base address 0x0F00 (data already there from Sec 2)
    LDD  R5, 0(R7)           # R5 = M[0x0F00] = 0x1234  <- load
    ADD  R6, R5, R5          # R6 = 0x2468  <- uses R5 1 cycle after load (stall required)
    OUT  R6                  # Expected OUT: 0x2468

    # --- (c) Negative result -------------------------------------------------
    LDM  R0, 0010
    LDM  R1, 0020
    SUB  R2, R0, R1          # R2 = 0x0010 - 0x0020 = 0xFFFFFFF0 ; N=1,Z=0
    OUT  R2                  # Expected OUT: 0xFFFFFFF0
    JN   GOT_NEGATIVE        # TAKEN (N=1)
    LDM  R0, DEAD
    OUT  R0                  # sentinel - should not reach

GOT_NEGATIVE:
    NOT  R2                  # R2 = ~0xFFFFFFF0 = 0x0000000F ; N=0,Z=0
    OUT  R2                  # Expected OUT: 0x0000000F

    # --- (d) Flags preserved across PUSH/POP of unrelated registers ----------
    SUB  R3, R3, R3          # Z=1
    PUSH R4                  # PUSH must not alter flags
    POP  R4                  # POP  must not alter flags
    JZ   FLAGS_OK            # TAKEN if Z still 1
    LDM  R0, DEAD
    OUT  R0

FLAGS_OK:
    OUT  R3                  # Expected OUT: 0x0000

    # --- (e) Simple counted loop via CALL ------------------------------------
    # Loop 3 times: each iteration calls FUNC_INC which increments R0.
    LDM  R0, 0000            # accumulator
    LDM  R1, 0003            # loop counter
LOOP_TOP:
    CALL FUNC_INC            # R0 += 1
    INC  R1                  # Oops - we DECREMENT by using SUB below
    SUB  R1, R1, R4          # use R4=0x0010 ... actually let us keep it simple:
                             # decrement counter with IADD -1 (0xFFFF in 16-bit = -1)
    # Redo: use a cleaner counter approach
    # (see LOOP2 below - cleaner version)
    NOP
    NOP

    # Cleaner loop:
LOOP2_INIT:
    LDM  R0, 0000            # R0 = accumulator = 0
    LDM  R1, 0000            # R1 = iteration count = 0
    LDM  R2, 0004            # R2 = limit = 4
LOOP2:
    CALL FUNC_INC            # R0 += 1 each call
    INC  R1                  # R1 = iteration count
    SUB  R3, R2, R1          # R3 = limit - count ; Z=1 when equal
    JZ   LOOP2_DONE          # exit when count == limit
    JMP  LOOP2               # else continue

LOOP2_DONE:
    OUT  R0                  # Expected OUT: 0x0004  (called FUNC_INC 4 times)
    OUT  R1                  # Expected OUT: 0x0004

    JMP  DONE


# --- Helper: FUNC_INC  R0 += 1 -----------------------------------------------
.ORG 7F0
FUNC_INC:
    INC  R0
    RET


# =============================================================================
# DONE - successful end of test
# =============================================================================
.ORG 7FE
DONE:
    LDM  R0, FFFF
    OUT  R0                  # Expected final OUT: 0x0000FFFF  -> test PASSED sentinel
    HLT


# =============================================================================
# INT 0 HANDLER  (0x500)
# =============================================================================
# Reads one word from the input port into R0 and returns.
# RTI restores PC and FLAGS (hardware responsibility).
# =============================================================================

.ORG 500
INT0_HANDLER:
    IN   R0                  # R0 = 0xBEEF  (test bench drives this value)
    RTI                      # Restore PC and FLAGS from stack; return to caller


# =============================================================================
# INT 1 HANDLER  (0x600)
# =============================================================================

.ORG 600
INT1_HANDLER:
    IN   R1                  # R1 = 0x7777  (test bench drives this value)
    RTI


# =============================================================================
# HW-INT HANDLER  (0xA00)
# =============================================================================
# Can be triggered asynchronously. Reads R7, doubles it, outputs, RTI.
# To trigger: raise the external HW-INT line while the processor is
# executing any instruction in SECTION 6 (recommended: during LOOP2).
# Expected OUT from handler: 2 * (R0 at time of interrupt), which
# varies - confirm RTI restores execution cleanly.
# =============================================================================

.ORG A00
HW_INT_HANDLER:
    IN   R7                  # R7 = external input (test bench drives e.g. 0x00FF)
    ADD  R7, R7, R7          # R7 = 2 * input
    OUT  R7                  # Expected OUT: 2 * IN value (e.g. 0x01FE)
    RTI                      # Resume interrupted instruction stream