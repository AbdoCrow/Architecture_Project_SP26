LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE work.isa_defs_pkg.ALL;

-- =============================================================================
-- Decode Stage Testbench
-- Tests:
--   1. Instruction field decoding (RDST, RSRC1, RSRC2, imm_offset, INT target)
--   2. Register file read path (read_data_1/2 from RSRC1/RSRC2)
--   3. Register file write path via writeback ports
--   4. Write-address routing (reg_write_address_1 = RDST, _2 = RSRC1 for SWAP/IN/LDM)
--   5. Control signals pass-through when FLUSH=0, STALL=0
--   6. NOP injection: all control signals forced to 0 when FLUSH='1'
--   7. NOP injection: all control signals forced to 0 when STALL='1'
--   8. Branch prediction and next_pc passthrough
--   9. MULTICYCLE_SEL / MULTICYCLE_STALL passthrough (from control unit)
--  10. Register file reset (all regs => 0 after reset)
-- =============================================================================

ENTITY decode_stage_tb IS
END ENTITY decode_stage_tb;

ARCHITECTURE tb OF decode_stage_tb IS

    CONSTANT CLK_PERIOD : TIME := 10 ns;

    -- -------------------------------------------------------------------------
    -- DUT ports
    -- -------------------------------------------------------------------------
    SIGNAL clk                   : STD_LOGIC := '0';
    SIGNAL reset                 : STD_LOGIC := '0';

    -- From fetch
    SIGNAL instr_in              : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL next_pc_in            : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL branch_prediction_in  : STD_LOGIC := '0';

    -- From writeback
    SIGNAL wb_addr_1_in          : reg_idx_t := (OTHERS => '0');
    SIGNAL wb_data_1_in          : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL REG_WB_EN_1_IN        : STD_LOGIC := '0';
    SIGNAL wb_addr_2_in          : reg_idx_t := (OTHERS => '0');
    SIGNAL wb_data_2_in          : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL REG_WB_EN_2_IN        : STD_LOGIC := '0';

    -- Hazard unit
    SIGNAL STALL                 : STD_LOGIC := '0';
    SIGNAL FLUSH                 : STD_LOGIC := '0';

    -- Control outputs
    SIGNAL LOAD_FLAGS            : STD_LOGIC;
    SIGNAL PC_WRITE_EN           : STD_LOGIC;
    SIGNAL MEM_WRITE_SEL         : mem_write_sel_t;
    SIGNAL COND_BRANCH           : STD_LOGIC;
    SIGNAL HLT                   : STD_LOGIC;
    SIGNAL MEMW                  : STD_LOGIC;
    SIGNAL MEMR                  : STD_LOGIC;
    SIGNAL UPDATE_FLAGS          : STD_LOGIC;
    SIGNAL MEM_ADDRESS_SEL       : mem_address_sel_t;
    SIGNAL OUTPUT_PORT_EN        : STD_LOGIC;
    SIGNAL REG_WB_EN_1           : STD_LOGIC;
    SIGNAL REG_WB_EN_2           : STD_LOGIC;
    SIGNAL ALU_INPUT_SEL         : alu_input_sel_t;
    SIGNAL JMP_FLAG_SEL          : jmp_flag_sel_t;
    SIGNAL ALU_OP                : alu_op_t;

    -- Data outputs
    SIGNAL read_data_1_out       : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL read_data_2_out       : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL imm_offset_out        : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL reg_write_address_1_out : reg_idx_t;
    SIGNAL reg_write_address_2_out : reg_idx_t;
    SIGNAL next_pc_out           : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL read_reg_1_out        : reg_idx_t;
    SIGNAL read_reg_2_out        : reg_idx_t;
    SIGNAL branch_prediction_out : STD_LOGIC;

    -- Multicycle / interrupt
    SIGNAL MULTICYCLE_SEL        : multicycle_sel_t;
    SIGNAL MULTICYCLE_STALL      : STD_LOGIC;
    SIGNAL INT_TARGERT_ADDR      : int_idx_t;

    -- Debug register monitors
    SIGNAL reg0_out : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL reg1_out : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL reg2_out : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL reg3_out : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL reg4_out : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL reg5_out : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL reg6_out : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL reg7_out : STD_LOGIC_VECTOR(31 DOWNTO 0);

    -- -------------------------------------------------------------------------
    -- Helper: build a 32-bit instruction word
    --   [31:27] opcode  [26:24] Rdst  [23:21] Rsrc1  [20:18] Rsrc2  [15:0] imm
    -- -------------------------------------------------------------------------
    FUNCTION make_instr(
        op   : opcode_t;
        rdst : INTEGER;
        rs1  : INTEGER;
        rs2  : INTEGER;
        imm  : STD_LOGIC_VECTOR(15 DOWNTO 0)
    ) RETURN STD_LOGIC_VECTOR IS
        VARIABLE v : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    BEGIN
        v(31 DOWNTO 27) := op;
        v(26 DOWNTO 24) := STD_LOGIC_VECTOR(TO_UNSIGNED(rdst, 3));
        v(23 DOWNTO 21) := STD_LOGIC_VECTOR(TO_UNSIGNED(rs1,  3));
        v(20 DOWNTO 18) := STD_LOGIC_VECTOR(TO_UNSIGNED(rs2,  3));
        v(15 DOWNTO  0) := imm;
        RETURN v;
    END FUNCTION;

    -- Convenience zero-imm variant
    FUNCTION make_instr(
        op   : opcode_t;
        rdst : INTEGER;
        rs1  : INTEGER;
        rs2  : INTEGER
    ) RETURN STD_LOGIC_VECTOR IS
    BEGIN
        RETURN make_instr(op, rdst, rs1, rs2, (OTHERS => '0'));
    END FUNCTION;

    -- Zero vector helpers
    CONSTANT ZEROS_MEM_ADDR  : mem_address_sel_t := MEM_ADDRESS_CALC;
    CONSTANT ZEROS_MEM_WRITE : mem_write_sel_t   := MEM_WRITE_ALU_DATA;
    CONSTANT ZEROS_ALU_SEL   : alu_input_sel_t   := ALU_INPUT_RSRC2;
    CONSTANT ZEROS_JMP       : jmp_flag_sel_t    := JMP_FLAG_NONE;
    CONSTANT ZEROS_ALU_OP    : alu_op_t          := ALU_OP_NOP;
    CONSTANT ZEROS_MC_SEL    : multicycle_sel_t  := MULTICYCLE_NONE;

BEGIN

    -- -------------------------------------------------------------------------
    -- Clock generator
    -- -------------------------------------------------------------------------
    clk_process : PROCESS
    BEGIN
        WHILE true LOOP
            clk <= '0';
            WAIT FOR CLK_PERIOD / 2;
            clk <= '1';
            WAIT FOR CLK_PERIOD / 2;
        END LOOP;
    END PROCESS;
    -- -------------------------------------------------------------------------
    -- DUT
    -- -------------------------------------------------------------------------
    DUT : ENTITY work.decode_stage
        PORT MAP (
            clk                    => clk,
            reset                  => reset,
            instr_in               => instr_in,
            next_pc_in             => next_pc_in,
            branch_prediction_in   => branch_prediction_in,
            wb_addr_1_in           => wb_addr_1_in,
            wb_data_1_in           => wb_data_1_in,
            REG_WB_EN_1_IN         => REG_WB_EN_1_IN,
            wb_addr_2_in           => wb_addr_2_in,
            wb_data_2_in           => wb_data_2_in,
            REG_WB_EN_2_IN         => REG_WB_EN_2_IN,
            STALL                  => STALL,
            FLUSH                  => FLUSH,
            LOAD_FLAGS             => LOAD_FLAGS,
            PC_WRITE_EN            => PC_WRITE_EN,
            MEM_WRITE_SEL          => MEM_WRITE_SEL,
            COND_BRANCH            => COND_BRANCH,
            HLT                    => HLT,
            MEMW                   => MEMW,
            MEMR                   => MEMR,
            UPDATE_FLAGS           => UPDATE_FLAGS,
            MEM_ADDRESS_SEL        => MEM_ADDRESS_SEL,
            OUTPUT_PORT_EN         => OUTPUT_PORT_EN,
            REG_WB_EN_1            => REG_WB_EN_1,
            REG_WB_EN_2            => REG_WB_EN_2,
            ALU_INPUT_SEL          => ALU_INPUT_SEL,
            JMP_FLAG_SEL           => JMP_FLAG_SEL,
            ALU_OP                 => ALU_OP,
            read_data_1_out        => read_data_1_out,
            read_data_2_out        => read_data_2_out,
            imm_offset_out         => imm_offset_out,
            reg_write_address_1_out => reg_write_address_1_out,
            reg_write_address_2_out => reg_write_address_2_out,
            next_pc_out            => next_pc_out,
            read_reg_1_out         => read_reg_1_out,
            read_reg_2_out         => read_reg_2_out,
            branch_prediction_out  => branch_prediction_out,
            MULTICYCLE_SEL         => MULTICYCLE_SEL,
            MULTICYCLE_STALL       => MULTICYCLE_STALL,
            INT_TARGERT_ADDR       => INT_TARGERT_ADDR,
            reg0_out               => reg0_out,
            reg1_out               => reg1_out,
            reg2_out               => reg2_out,
            reg3_out               => reg3_out,
            reg4_out               => reg4_out,
            reg5_out               => reg5_out,
            reg6_out               => reg6_out,
            reg7_out               => reg7_out
        );

    -- -------------------------------------------------------------------------
    -- Stimulus
    -- -------------------------------------------------------------------------
    stim : PROCESS

        -- ------------------------------------------------------------------
        -- Assertion helpers
        -- ------------------------------------------------------------------
        PROCEDURE check_field_decode(
            test_name : STRING;
            exp_rdst  : INTEGER;
            exp_rs1   : INTEGER;
            exp_rs2   : INTEGER;
            exp_imm   : STD_LOGIC_VECTOR(15 DOWNTO 0)
        ) IS
        BEGIN
            ASSERT reg_write_address_1_out = STD_LOGIC_VECTOR(TO_UNSIGNED(exp_rdst, reg_write_address_1_out'LENGTH))
                REPORT test_name & ": reg_write_address_1 (RDST) mismatch"
                SEVERITY ERROR;
            ASSERT reg_write_address_2_out = STD_LOGIC_VECTOR(TO_UNSIGNED(exp_rs1, reg_write_address_2_out'LENGTH))
                REPORT test_name & ": reg_write_address_2 (RSRC1) mismatch"
                SEVERITY ERROR;
            ASSERT read_reg_1_out = STD_LOGIC_VECTOR(TO_UNSIGNED(exp_rs1, read_reg_1_out'LENGTH))
                REPORT test_name & ": read_reg_1 (RSRC1) mismatch"
                SEVERITY ERROR;
            ASSERT read_reg_2_out = STD_LOGIC_VECTOR(TO_UNSIGNED(exp_rs2, read_reg_2_out'LENGTH))
                REPORT test_name & ": read_reg_2 (RSRC2) mismatch"
                SEVERITY ERROR;
            ASSERT imm_offset_out = exp_imm
                REPORT test_name & ": imm_offset mismatch"
                SEVERITY ERROR;
        END PROCEDURE;

        PROCEDURE check_all_ctrl_zero(test_name : STRING) IS
        BEGIN
            ASSERT UPDATE_FLAGS  = '0' REPORT test_name & ": UPDATE_FLAGS should be 0" SEVERITY ERROR;
            ASSERT MEMR          = '0' REPORT test_name & ": MEMR should be 0"         SEVERITY ERROR;
            ASSERT MEMW          = '0' REPORT test_name & ": MEMW should be 0"         SEVERITY ERROR;
            ASSERT HLT           = '0' REPORT test_name & ": HLT should be 0"          SEVERITY ERROR;
            ASSERT COND_BRANCH   = '0' REPORT test_name & ": COND_BRANCH should be 0"  SEVERITY ERROR;
            ASSERT OUTPUT_PORT_EN= '0' REPORT test_name & ": OUTPUT_PORT_EN should be 0" SEVERITY ERROR;
            ASSERT PC_WRITE_EN   = '0' REPORT test_name & ": PC_WRITE_EN should be 0"  SEVERITY ERROR;
            ASSERT LOAD_FLAGS    = '0' REPORT test_name & ": LOAD_FLAGS should be 0"   SEVERITY ERROR;
            ASSERT REG_WB_EN_1   = '0' REPORT test_name & ": REG_WB_EN_1 should be 0" SEVERITY ERROR;
            ASSERT REG_WB_EN_2   = '0' REPORT test_name & ": REG_WB_EN_2 should be 0" SEVERITY ERROR;
            ASSERT MEM_ADDRESS_SEL = ZEROS_MEM_ADDR  REPORT test_name & ": MEM_ADDRESS_SEL should be 0" SEVERITY ERROR;
            ASSERT MEM_WRITE_SEL   = ZEROS_MEM_WRITE REPORT test_name & ": MEM_WRITE_SEL should be 0"   SEVERITY ERROR;
            ASSERT ALU_INPUT_SEL   = ZEROS_ALU_SEL   REPORT test_name & ": ALU_INPUT_SEL should be 0"   SEVERITY ERROR;
            ASSERT JMP_FLAG_SEL    = ZEROS_JMP       REPORT test_name & ": JMP_FLAG_SEL should be 0"    SEVERITY ERROR;
            ASSERT ALU_OP          = ZEROS_ALU_OP    REPORT test_name & ": ALU_OP should be 0"          SEVERITY ERROR;
        END PROCEDURE;

        PROCEDURE check_passthrough(test_name : STRING;
                                    exp_next_pc : STD_LOGIC_VECTOR(31 DOWNTO 0);
                                    exp_bp      : STD_LOGIC) IS
        BEGIN
            ASSERT next_pc_out = exp_next_pc
                REPORT test_name & ": next_pc_out mismatch"
                SEVERITY ERROR;
            ASSERT branch_prediction_out = exp_bp
                REPORT test_name & ": branch_prediction_out mismatch"
                SEVERITY ERROR;
        END PROCEDURE;

    BEGIN

        -- ==================================================================
        -- TEST 0: Reset
        -- ==================================================================
        reset <= '1';
        instr_in <= (OTHERS => '0');
        STALL <= '0'; FLUSH <= '0';
        WAIT FOR CLK_PERIOD * 2;
        -- After reset all registers should be 0
        ASSERT reg0_out = X"00000000" REPORT "Reset: R0 != 0" SEVERITY ERROR;
        ASSERT reg1_out = X"00000000" REPORT "Reset: R1 != 0" SEVERITY ERROR;
        ASSERT reg2_out = X"00000000" REPORT "Reset: R2 != 0" SEVERITY ERROR;
        ASSERT reg3_out = X"00000000" REPORT "Reset: R3 != 0" SEVERITY ERROR;
        ASSERT reg4_out = X"00000000" REPORT "Reset: R4 != 0" SEVERITY ERROR;
        ASSERT reg5_out = X"00000000" REPORT "Reset: R5 != 0" SEVERITY ERROR;
        ASSERT reg6_out = X"00000000" REPORT "Reset: R6 != 0" SEVERITY ERROR;
        ASSERT reg7_out = X"00000000" REPORT "Reset: R7 != 0" SEVERITY ERROR;
        REPORT "TEST 0 (Reset) passed" SEVERITY NOTE;
        reset <= '0';

        -- ==================================================================
        -- TEST 1: Instruction field decoding – ADD R3, R1, R2
        --   bits[31:27]=OPCODE_ADD  [26:24]=3  [23:21]=1  [20:18]=2  [15:0]=0xABCD
        -- ==================================================================
        instr_in <= make_instr(OPCODE_ADD, 3, 1, 2, X"ABCD");
        next_pc_in <= X"00000010";
        branch_prediction_in <= '0';
        WAIT FOR CLK_PERIOD;
        check_field_decode("ADD field decode", 3, 1, 2, X"ABCD");
        check_passthrough("ADD passthrough", X"00000010", '0');
        REPORT "TEST 1 (Instruction field decode) passed" SEVERITY NOTE;

        -- ==================================================================
        -- TEST 2: INT target address field – INT instruction with bits[1:0]=2
        --   We check that INT_TARGERT_ADDR correctly picks up instr_in[1:0]
        -- ==================================================================
        instr_in <= make_instr(OPCODE_INT, 0, 0, 0, X"0002");
        WAIT FOR CLK_PERIOD;
        ASSERT INT_TARGERT_ADDR = "10"
            REPORT "TEST 2: INT_TARGERT_ADDR mismatch" SEVERITY ERROR;
        REPORT "TEST 2 (INT target address decode) passed" SEVERITY NOTE;

        -- ==================================================================
        -- TEST 3: Register file write-back then read (port 1)
        --   Write 0xDEADBEEF into R4 via wb port 1, then read R4 as RSRC1
        -- ==================================================================
        -- Write on clock edge
        wb_addr_1_in  <= STD_LOGIC_VECTOR(TO_UNSIGNED(4, wb_addr_1_in'LENGTH));
        wb_data_1_in  <= X"DEADBEEF";
        REG_WB_EN_1_IN <= '1';
        WAIT FOR CLK_PERIOD;   -- register file captures on clk edge
        REG_WB_EN_1_IN <= '0';
        -- Now read R4 via RSRC1 (bits [23:21] = 4)
        instr_in <= make_instr(OPCODE_ADD, 0, 4, 0);
        WAIT FOR CLK_PERIOD;
        ASSERT read_data_1_out = X"DEADBEEF"
            REPORT "TEST 3: read_data_1 after wb port-1 write mismatch" SEVERITY ERROR;
        REPORT "TEST 3 (WB port-1 write + RSRC1 read) passed" SEVERITY NOTE;

        -- ==================================================================
        -- TEST 4: Register file write-back then read (port 2)
        --   Write 0xCAFEBABE into R5 via wb port 2, then read R5 as RSRC2
        -- ==================================================================
        wb_addr_2_in  <= STD_LOGIC_VECTOR(TO_UNSIGNED(5, wb_addr_2_in'LENGTH));
        wb_data_2_in  <= X"CAFEBABE";
        REG_WB_EN_2_IN <= '1';
        WAIT FOR CLK_PERIOD;
        REG_WB_EN_2_IN <= '0';
        -- Read R5 via RSRC2 (bits [20:18] = 5)
        instr_in <= make_instr(OPCODE_ADD, 0, 0, 5);
        WAIT FOR CLK_PERIOD;
        ASSERT read_data_2_out = X"CAFEBABE"
            REPORT "TEST 4: read_data_2 after wb port-2 write mismatch" SEVERITY ERROR;
        REPORT "TEST 4 (WB port-2 write + RSRC2 read) passed" SEVERITY NOTE;

        -- ==================================================================
        -- TEST 5: Write-address routing – normal instruction (not SWAP/IN/LDM)
        --   reg_write_address_1 should be RDST, reg_write_address_2 = RSRC1
        -- ==================================================================
        instr_in <= make_instr(OPCODE_SUB, 7, 3, 2);
        WAIT FOR CLK_PERIOD;
        ASSERT reg_write_address_1_out = STD_LOGIC_VECTOR(TO_UNSIGNED(7, reg_write_address_1_out'LENGTH))
            REPORT "TEST 5: reg_write_address_1 != RDST" SEVERITY ERROR;
        ASSERT reg_write_address_2_out = STD_LOGIC_VECTOR(TO_UNSIGNED(3, reg_write_address_2_out'LENGTH))
            REPORT "TEST 5: reg_write_address_2 != RSRC1" SEVERITY ERROR;
        REPORT "TEST 5 (Write-address routing) passed" SEVERITY NOTE;

        -- ==================================================================
        -- TEST 6: Control signal pass-through when FLUSH=0, STALL=0 (ADD)
        --   ADD should produce: REG_WB_EN_1='1', UPDATE_FLAGS='1', ALU_OP=ADD, etc.
        -- ==================================================================
        instr_in <= make_instr(OPCODE_ADD, 1, 2, 3);
        STALL <= '0'; FLUSH <= '0';
        WAIT FOR CLK_PERIOD;
        ASSERT REG_WB_EN_1  = '1' REPORT "TEST 6 ADD: REG_WB_EN_1 should be 1" SEVERITY ERROR;
        ASSERT UPDATE_FLAGS = '1' REPORT "TEST 6 ADD: UPDATE_FLAGS should be 1" SEVERITY ERROR;
        ASSERT ALU_OP       = ALU_OP_ADD REPORT "TEST 6 ADD: ALU_OP wrong"      SEVERITY ERROR;
        ASSERT MEMR = '0' REPORT "TEST 6 ADD: MEMR should be 0" SEVERITY ERROR;
        ASSERT MEMW = '0' REPORT "TEST 6 ADD: MEMW should be 0" SEVERITY ERROR;
        REPORT "TEST 6 (Ctrl pass-through - ADD) passed" SEVERITY NOTE;

        -- ==================================================================
        -- TEST 7: FLUSH forces NOP – inject ADD then assert with FLUSH=1
        -- ==================================================================
        instr_in <= make_instr(OPCODE_ADD, 1, 2, 3);
        FLUSH <= '1'; STALL <= '0';
        WAIT FOR CLK_PERIOD;
        check_all_ctrl_zero("FLUSH NOP");
        FLUSH <= '0';
        REPORT "TEST 7 (FLUSH forces NOP) passed" SEVERITY NOTE;

        -- ==================================================================
        -- TEST 8: STALL forces NOP – inject ADD then assert with STALL=1
        -- ==================================================================
        instr_in <= make_instr(OPCODE_ADD, 1, 2, 3);
        STALL <= '1'; FLUSH <= '0';
        WAIT FOR CLK_PERIOD;
        check_all_ctrl_zero("STALL NOP");
        STALL <= '0';
        REPORT "TEST 8 (STALL forces NOP) passed" SEVERITY NOTE;

        -- ==================================================================
        -- TEST 9: FLUSH=1 AND STALL=1 simultaneously – still NOP
        -- ==================================================================
        instr_in <= make_instr(OPCODE_HLT, 0, 0, 0);
        FLUSH <= '1'; STALL <= '1';
        WAIT FOR CLK_PERIOD;
        check_all_ctrl_zero("FLUSH+STALL NOP");
        ASSERT HLT = '0' REPORT "TEST 9: HLT should be masked by FLUSH+STALL" SEVERITY ERROR;
        FLUSH <= '0'; STALL <= '0';
        REPORT "TEST 9 (FLUSH+STALL together) passed" SEVERITY NOTE;

        -- ==================================================================
        -- TEST 10: NOP instruction – inherently zero control signals
        -- ==================================================================
        instr_in <= make_instr(OPCODE_NOP, 0, 0, 0);
        STALL <= '0'; FLUSH <= '0';
        WAIT FOR CLK_PERIOD;
        ASSERT HLT           = '0' REPORT "TEST 10 NOP: HLT!=0"           SEVERITY ERROR;
        ASSERT MEMR          = '0' REPORT "TEST 10 NOP: MEMR!=0"           SEVERITY ERROR;
        ASSERT MEMW          = '0' REPORT "TEST 10 NOP: MEMW!=0"           SEVERITY ERROR;
        ASSERT REG_WB_EN_1   = '0' REPORT "TEST 10 NOP: REG_WB_EN_1!=0"   SEVERITY ERROR;
        ASSERT REG_WB_EN_2   = '0' REPORT "TEST 10 NOP: REG_WB_EN_2!=0"   SEVERITY ERROR;
        ASSERT UPDATE_FLAGS  = '0' REPORT "TEST 10 NOP: UPDATE_FLAGS!=0"   SEVERITY ERROR;
        ASSERT OUTPUT_PORT_EN= '0' REPORT "TEST 10 NOP: OUTPUT_PORT_EN!=0" SEVERITY ERROR;
        REPORT "TEST 10 (NOP opcode) passed" SEVERITY NOTE;

        -- ==================================================================
        -- TEST 11: HLT pass-through (no flush/stall)
        -- ==================================================================
        instr_in <= make_instr(OPCODE_HLT, 0, 0, 0);
        STALL <= '0'; FLUSH <= '0';
        WAIT FOR CLK_PERIOD;
        ASSERT HLT = '1' REPORT "TEST 11: HLT should be 1" SEVERITY ERROR;
        REPORT "TEST 11 (HLT pass-through) passed" SEVERITY NOTE;

        -- ==================================================================
        -- TEST 12: MEMR and MEMW for LDD and STD
        -- ==================================================================
        -- LDD: MEMR=1, MEMW=0, REG_WB_EN_1=1
        instr_in <= make_instr(OPCODE_LDD, 2, 1, 0);
        WAIT FOR CLK_PERIOD;
        ASSERT MEMR       = '1' REPORT "TEST 12 LDD: MEMR should be 1"       SEVERITY ERROR;
        ASSERT MEMW       = '0' REPORT "TEST 12 LDD: MEMW should be 0"       SEVERITY ERROR;
        ASSERT REG_WB_EN_1 = '1' REPORT "TEST 12 LDD: REG_WB_EN_1 should be 1" SEVERITY ERROR;
        REPORT "TEST 12a (LDD memory signals) passed" SEVERITY NOTE;

        -- STD: MEMR=0, MEMW=1, REG_WB_EN_1=0
        instr_in <= make_instr(OPCODE_STD, 0, 2, 0);
        WAIT FOR CLK_PERIOD;
        ASSERT MEMR        = '0' REPORT "TEST 12 STD: MEMR should be 0"        SEVERITY ERROR;
        ASSERT MEMW        = '1' REPORT "TEST 12 STD: MEMW should be 1"        SEVERITY ERROR;
        ASSERT REG_WB_EN_1 = '0' REPORT "TEST 12 STD: REG_WB_EN_1 should be 0" SEVERITY ERROR;
        REPORT "TEST 12b (STD memory signals) passed" SEVERITY NOTE;

        -- ==================================================================
        -- TEST 13: PUSH / POP SP-relative address selects
        -- ==================================================================
        instr_in <= make_instr(OPCODE_PUSH, 0, 1, 0);
        WAIT FOR CLK_PERIOD;
        ASSERT MEMW            = '1'               REPORT "TEST 13 PUSH: MEMW!=1"                SEVERITY ERROR;
        ASSERT MEM_ADDRESS_SEL = MEM_ADDRESS_SP_PUSH REPORT "TEST 13 PUSH: MEM_ADDRESS_SEL wrong" SEVERITY ERROR;

        instr_in <= make_instr(OPCODE_POP, 1, 0, 0);
        WAIT FOR CLK_PERIOD;
        ASSERT MEMR            = '1'              REPORT "TEST 13 POP: MEMR!=1"                SEVERITY ERROR;
        ASSERT MEM_ADDRESS_SEL = MEM_ADDRESS_SP_POP REPORT "TEST 13 POP: MEM_ADDRESS_SEL wrong" SEVERITY ERROR;
        REPORT "TEST 13 (PUSH/POP address select) passed" SEVERITY NOTE;

        -- ==================================================================
        -- TEST 14: CALL – writes PC to stack
        -- ==================================================================
        instr_in <= make_instr(OPCODE_CALL, 0, 1, 0);
        WAIT FOR CLK_PERIOD;
        ASSERT MEMW          = '1'                  REPORT "TEST 14 CALL: MEMW!=1"                SEVERITY ERROR;
        ASSERT MEM_ADDRESS_SEL = MEM_ADDRESS_SP_PUSH REPORT "TEST 14 CALL: MEM_ADDRESS_SEL wrong" SEVERITY ERROR;
        ASSERT MEM_WRITE_SEL   = MEM_WRITE_PC_DATA   REPORT "TEST 14 CALL: MEM_WRITE_SEL!=PC_DATA" SEVERITY ERROR;
        REPORT "TEST 14 (CALL) passed" SEVERITY NOTE;

        -- ==================================================================
        -- TEST 15: RET – reads PC from stack
        -- ==================================================================
        instr_in <= make_instr(OPCODE_RET, 0, 0, 0);
        WAIT FOR CLK_PERIOD;
        ASSERT MEMR          = '1'               REPORT "TEST 15 RET: MEMR!=1"                  SEVERITY ERROR;
        ASSERT PC_WRITE_EN   = '1'               REPORT "TEST 15 RET: PC_WRITE_EN!=1"           SEVERITY ERROR;
        ASSERT MEM_ADDRESS_SEL = MEM_ADDRESS_SP_POP REPORT "TEST 15 RET: MEM_ADDRESS_SEL wrong" SEVERITY ERROR;
        REPORT "TEST 15 (RET) passed" SEVERITY NOTE;

        -- ==================================================================
        -- TEST 16: Conditional branches with hint bit
        --   JZ with hint=1 → COND_BRANCH=1, JMP_FLAG_SEL=JMP_FLAG_Z
        -- ==================================================================
        instr_in(31 DOWNTO 27) <= OPCODE_JZ;
        instr_in(BR_HINT_COND_BIT) <= '1';   -- branch prediction hint
        WAIT FOR CLK_PERIOD;
        ASSERT COND_BRANCH  = '1'       REPORT "TEST 16 JZ: COND_BRANCH!=1"       SEVERITY ERROR;
        ASSERT JMP_FLAG_SEL = JMP_FLAG_Z REPORT "TEST 16 JZ: JMP_FLAG_SEL!=Z"     SEVERITY ERROR;

        instr_in(31 DOWNTO 27) <= OPCODE_JN;
        WAIT FOR CLK_PERIOD;
        ASSERT COND_BRANCH  = '1'       REPORT "TEST 16 JN: COND_BRANCH!=1"       SEVERITY ERROR;
        ASSERT JMP_FLAG_SEL = JMP_FLAG_N REPORT "TEST 16 JN: JMP_FLAG_SEL!=N"     SEVERITY ERROR;

        instr_in(31 DOWNTO 27) <= OPCODE_JC;
        WAIT FOR CLK_PERIOD;
        ASSERT COND_BRANCH  = '1'       REPORT "TEST 16 JC: COND_BRANCH!=1"       SEVERITY ERROR;
        ASSERT JMP_FLAG_SEL = JMP_FLAG_C REPORT "TEST 16 JC: JMP_FLAG_SEL!=C"     SEVERITY ERROR;
        REPORT "TEST 16 (Conditional branches) passed" SEVERITY NOTE;

        -- ==================================================================
        -- TEST 17: SWAP – both write-back enables should be '1'
        -- ==================================================================
        instr_in <= make_instr(OPCODE_SWAP, 2, 3, 0);
        STALL <= '0'; FLUSH <= '0';
        WAIT FOR CLK_PERIOD;
        ASSERT REG_WB_EN_1 = '1' REPORT "TEST 17 SWAP: REG_WB_EN_1!=1" SEVERITY ERROR;
        ASSERT REG_WB_EN_2 = '1' REPORT "TEST 17 SWAP: REG_WB_EN_2!=1" SEVERITY ERROR;
        REPORT "TEST 17 (SWAP dual writeback) passed" SEVERITY NOTE;

        -- ==================================================================
        -- TEST 18: IN instruction – write to RSRC1 slot, input from IN port
        -- ==================================================================
        instr_in <= make_instr(OPCODE_IN, 0, 2, 0);
        WAIT FOR CLK_PERIOD;
        ASSERT REG_WB_EN_2   = '1'            REPORT "TEST 18 IN: REG_WB_EN_2!=1"          SEVERITY ERROR;
        ASSERT ALU_INPUT_SEL = ALU_INPUT_IN_PORT REPORT "TEST 18 IN: ALU_INPUT_SEL!=IN_PORT" SEVERITY ERROR;
        REPORT "TEST 18 (IN instruction) passed" SEVERITY NOTE;

        -- ==================================================================
        -- TEST 19: LDM – immediate operand into register (RSRC1 destination)
        -- ==================================================================
        instr_in <= make_instr(OPCODE_LDM, 0, 3, 0, X"1234");
        WAIT FOR CLK_PERIOD;
        ASSERT REG_WB_EN_2   = '1'               REPORT "TEST 19 LDM: REG_WB_EN_2!=1"           SEVERITY ERROR;
        ASSERT ALU_INPUT_SEL = ALU_INPUT_IMMEDIATE REPORT "TEST 19 LDM: ALU_INPUT_SEL!=IMMEDIATE" SEVERITY ERROR;
        ASSERT imm_offset_out = X"1234"            REPORT "TEST 19 LDM: imm_offset mismatch"      SEVERITY ERROR;
        REPORT "TEST 19 (LDM) passed" SEVERITY NOTE;

        -- ==================================================================
        -- TEST 20: OUT instruction – OUTPUT_PORT_EN='1'
        -- ==================================================================
        instr_in <= make_instr(OPCODE_OUT, 0, 1, 0);
        WAIT FOR CLK_PERIOD;
        ASSERT OUTPUT_PORT_EN = '1' REPORT "TEST 20 OUT: OUTPUT_PORT_EN!=1" SEVERITY ERROR;
        REPORT "TEST 20 (OUT) passed" SEVERITY NOTE;

        -- ==================================================================
        -- TEST 21: INT multicycle – MULTICYCLE_STALL='1', SEL=MULTICYCLE_INT2
        -- ==================================================================
        instr_in <= make_instr(OPCODE_INT, 0, 0, 0, X"0001");
        WAIT FOR CLK_PERIOD;
        ASSERT MULTICYCLE_STALL = '1'           REPORT "TEST 21 INT: MULTICYCLE_STALL!=1"       SEVERITY ERROR;
        ASSERT MULTICYCLE_SEL   = MULTICYCLE_INT2 REPORT "TEST 21 INT: MULTICYCLE_SEL!=INT2"    SEVERITY ERROR;
        REPORT "TEST 21 (INT multicycle) passed" SEVERITY NOTE;

        -- ==================================================================
        -- TEST 22: next_pc and branch_prediction passthrough values
        -- ==================================================================
        instr_in              <= make_instr(OPCODE_NOP, 0, 0, 0);
        next_pc_in            <= X"FEEDFACE";
        branch_prediction_in  <= '1';
        WAIT FOR CLK_PERIOD;
        check_passthrough("next_pc + bp passthrough", X"FEEDFACE", '1');
        REPORT "TEST 22 (next_pc / branch_prediction passthrough) passed" SEVERITY NOTE;

        -- ==================================================================
        -- TEST 23: Transition FLUSH=1 → FLUSH=0 – control signals should
        --          revert to the decoded values on the very next cycle
        -- ==================================================================
        instr_in <= make_instr(OPCODE_ADD, 1, 2, 3);
        FLUSH <= '1';
        WAIT FOR CLK_PERIOD;
        check_all_ctrl_zero("Transition FLUSH cycle");
        FLUSH <= '0';
        WAIT FOR CLK_PERIOD;
        ASSERT REG_WB_EN_1 = '1'     REPORT "TEST 23: REG_WB_EN_1 should recover to 1 after FLUSH" SEVERITY ERROR;
        ASSERT UPDATE_FLAGS = '1'    REPORT "TEST 23: UPDATE_FLAGS should recover to 1 after FLUSH" SEVERITY ERROR;
        REPORT "TEST 23 (FLUSH-normal transition) passed" SEVERITY NOTE;

        -- ==================================================================
        -- Done
        -- ==================================================================
        REPORT "=== All decode_stage tests PASSED ===" SEVERITY NOTE;
        WAIT;
    END PROCESS stim;

END ARCHITECTURE tb;