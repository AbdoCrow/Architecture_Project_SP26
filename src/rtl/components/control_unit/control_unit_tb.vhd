LIBRARY ieee;
USE ieee.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.isa_defs_pkg.ALL;
ENTITY control_unit_tb IS
END ENTITY;

ARCHITECTURE tb OF control_unit_tb IS
    CONSTANT CLK_PERIOD : time := 10 ns;
    --------------------------------------------------------------------
    -- DUT Signals
    --------------------------------------------------------------------
    SIGNAL opcode : opcode_t := (OTHERS => '0');
    SIGNAL cond_branch_hint : STD_LOGIC := '0';
    SIGNAL LOAD_FLAGS : STD_LOGIC;
    SIGNAL PC_WRITE_EN : STD_LOGIC;
    SIGNAL OUTPUT_PORT_EN : STD_LOGIC;
    SIGNAL MEM_WRITE_SEL : mem_write_sel_t;
    SIGNAL COND_BRANCH : STD_LOGIC;
    SIGNAL HLT : STD_LOGIC;
    SIGNAL MEMW : STD_LOGIC;
    SIGNAL MEMR : STD_LOGIC;
    SIGNAL REG_WB_EN_1 : STD_LOGIC;
    SIGNAL REG_WB_EN_2 : STD_LOGIC;
    SIGNAL UPDATE_FLAGS : STD_LOGIC;
    SIGNAL ALU_OP : alu_op_t;
    SIGNAL ALU_INPUT_SEL : alu_input_sel_t;
    SIGNAL JMP_FLAG_SEL : jmp_flag_sel_t;
    SIGNAL MEM_ADDRESS_SEL : mem_address_sel_t;
    SIGNAL MULTICYCLE_STALL : STD_LOGIC;
    SIGNAL MULTICYCLE_SEL : multicycle_sel_t;

BEGIN

    --------------------------------------------------------------------
    -- DUT Instantiation
    --------------------------------------------------------------------
    DUT : ENTITY work.control_unit
        PORT MAP (
            opcode => opcode,
            cond_branch_hint => cond_branch_hint,
            LOAD_FLAGS => LOAD_FLAGS,
            PC_WRITE_EN => PC_WRITE_EN,
            MEM_WRITE_SEL => MEM_WRITE_SEL,
            COND_BRANCH => COND_BRANCH,
            HLT => HLT,
            MEMW => MEMW,
            MEMR => MEMR,
            REG_WB_EN_1 => REG_WB_EN_1,
            REG_WB_EN_2 => REG_WB_EN_2,
            UPDATE_FLAGS => UPDATE_FLAGS,
            ALU_OP => ALU_OP,
            ALU_INPUT_SEL => ALU_INPUT_SEL,
            JMP_FLAG_SEL => JMP_FLAG_SEL,
            MEM_ADDRESS_SEL => MEM_ADDRESS_SEL,
            MULTICYCLE_STALL => MULTICYCLE_STALL,
            MULTICYCLE_SEL => MULTICYCLE_SEL,
            OUTPUT_PORT_EN => OUTPUT_PORT_EN
        );

    --------------------------------------------------------------------
    -- Stimulus Process
    --------------------------------------------------------------------
    stim_process : PROCESS
        -- Helper procedure for checkiing read data
        PROCEDURE check_MEM(expectedRead : STD_LOGIC; expectedWrite : STD_LOGIC; expectedAddress : mem_address_sel_t; expectedWriteDataSel : mem_write_sel_t; expectedLoadFlags : STD_LOGIC) IS
        BEGIN
            ASSERT MEMR = expectedRead
                REPORT "MEMR mismatch: expected " & STD_LOGIC'image(expectedRead) & ", got " & STD_LOGIC'image(MEMR)
                SEVERITY ERROR;
            ASSERT MEMW = expectedWrite
                REPORT "MEMW mismatch: expected " & STD_LOGIC'image(expectedWrite) & ", got " & STD_LOGIC'image(MEMW)
                SEVERITY ERROR;
            ASSERT MEM_ADDRESS_SEL = expectedAddress
                REPORT "MEM_ADDRESS_SEL mismatch: expected " & integer'image(to_integer(unsigned(expectedAddress))) & ", got " & integer'image(to_integer(unsigned(MEM_ADDRESS_SEL)))
                SEVERITY ERROR;
            ASSERT MEM_WRITE_SEL = expectedWriteDataSel
                REPORT "MEM_WRITE_SEL mismatch: expected " & integer'image(to_integer(unsigned(expectedWriteDataSel))) & ", got " & integer'image(to_integer(unsigned(MEM_WRITE_SEL)))
                SEVERITY ERROR;
            ASSERT LOAD_FLAGS = expectedLoadFlags
                REPORT "LOAD_FLAGS mismatch: expected " & STD_LOGIC'image(expectedLoadFlags) & ", got " & STD_LOGIC'image(LOAD_FLAGS)
                SEVERITY ERROR;
        END PROCEDURE;
        PROCEDURE check_WriteBack(expected1 : STD_LOGIC; expected2 : STD_LOGIC; expectedFlags : STD_LOGIC; expectedPCWrite : STD_LOGIC) IS
        BEGIN
            ASSERT REG_WB_EN_1 = expected1
                REPORT "REG_WB_EN_1 mismatch: expected " & STD_LOGIC'image(expected1) & ", got " & STD_LOGIC'image(REG_WB_EN_1)
                SEVERITY ERROR;
            ASSERT REG_WB_EN_2 = expected2
                REPORT "REG_WB_EN_2 mismatch: expected " & STD_LOGIC'image(expected2) & ", got " & STD_LOGIC'image(REG_WB_EN_2)
                SEVERITY ERROR;
            ASSERT UPDATE_FLAGS = expectedFlags
                REPORT "UPDATE_FLAGS mismatch: expected " & STD_LOGIC'image(expectedFlags) & ", got " & STD_LOGIC'image(UPDATE_FLAGS)
                SEVERITY ERROR;
            ASSERT PC_WRITE_EN = expectedPCWrite
                REPORT "PC_WRITE_EN mismatch: expected " & STD_LOGIC'image(expectedPCWrite) & ", got " & STD_LOGIC'image(PC_WRITE_EN)
                SEVERITY ERROR;
        END PROCEDURE;
        PROCEDURE check_ALU(expectedOp : alu_op_t; expectedInputSel : alu_input_sel_t; expectedJmpFlagSel : jmp_flag_sel_t; expectedCondBranch : STD_LOGIC) IS
        BEGIN
            ASSERT ALU_OP = expectedOp
                REPORT "ALU_OP mismatch: expected " & integer'image(to_integer(unsigned(expectedOp))) & ", got " & integer'image(to_integer(unsigned(ALU_OP)))
                SEVERITY ERROR;
            ASSERT ALU_INPUT_SEL = expectedInputSel
                REPORT "ALU_INPUT_SEL mismatch: expected " & integer'image(to_integer(unsigned(expectedInputSel))) & ", got " & integer'image(to_integer(unsigned(ALU_INPUT_SEL)))
                SEVERITY ERROR;
            ASSERT JMP_FLAG_SEL = expectedJmpFlagSel
                REPORT "JMP_FLAG_SEL mismatch: expected " & integer'image(to_integer(unsigned(expectedJmpFlagSel))) & ", got " & integer'image(to_integer(unsigned(JMP_FLAG_SEL)))
                SEVERITY ERROR;
            ASSERT COND_BRANCH = expectedCondBranch
                REPORT "COND_BRANCH mismatch: expected " & STD_LOGIC'image(expectedCondBranch) & ", got " & STD_LOGIC'image(COND_BRANCH)
                SEVERITY ERROR;
        END PROCEDURE;
        PROCEDURE check_HLT(expectedHLT : STD_LOGIC) IS
        BEGIN
            ASSERT HLT = expectedHLT
                REPORT "HLT mismatch: expected " & STD_LOGIC'image(expectedHLT) & ", got " & STD_LOGIC'image(HLT)
                SEVERITY ERROR;
        END PROCEDURE;
        PROCEDURE check_OutputPort(expectedOutputPortEn : STD_LOGIC) IS
        BEGIN
            ASSERT OUTPUT_PORT_EN = expectedOutputPortEn
                REPORT "OUTPUT_PORT_EN mismatch: expected " & STD_LOGIC'image(expectedOutputPortEn) & ", got " & STD_LOGIC'image(OUTPUT_PORT_EN)
                SEVERITY ERROR;
        END PROCEDURE;
        PROCEDURE check_Multicycle(expectedStall : STD_LOGIC; expectedSel : multicycle_sel_t) IS
        BEGIN
            ASSERT MULTICYCLE_STALL = expectedStall
                REPORT "MULTICYCLE_STALL mismatch: expected " & STD_LOGIC'image(expectedStall) & ", got " & STD_LOGIC'image(MULTICYCLE_STALL)
                SEVERITY ERROR;
            ASSERT MULTICYCLE_SEL = expectedSel
                REPORT "MULTICYCLE_SEL mismatch: expected " & integer'image(to_integer(unsigned(expectedSel))) & ", got " & integer'image(to_integer(unsigned(MULTICYCLE_SEL)))
                SEVERITY ERROR;
        END PROCEDURE;
    BEGIN
        -- Test 1 NOP:
        opcode <= OPCODE_NOP;
        cond_branch_hint <= '0';
        WAIT FOR CLK_PERIOD;
        check_ALU(ALU_OP_NOP, ALU_INPUT_RSRC2, JMP_FLAG_NONE, '0');
        check_WriteBack('0', '0', '0', '0');
        check_MEM('0', '0', MEM_ADDRESS_CALC, MEM_WRITE_ALU_DATA, '0');
        check_HLT('0');
        check_OutputPort('0');
        check_Multicycle('0', MULTICYCLE_NONE);
        REPORT "NOP test passed" SEVERITY NOTE;

        -- Test 2 HLT:
        opcode <= OPCODE_HLT;
        cond_branch_hint <= '0';
        WAIT FOR CLK_PERIOD;
        check_ALU(ALU_OP_PASS, ALU_INPUT_RSRC2, JMP_FLAG_NONE, '0');
        check_WriteBack('0', '0', '0', '0');
        check_MEM('0', '0', MEM_ADDRESS_CALC, MEM_WRITE_ALU_DATA, '0');
        check_HLT('1');
        check_OutputPort('0');
        check_Multicycle('0', MULTICYCLE_NONE);
        REPORT "HLT test passed" SEVERITY NOTE;

        -- Test 3 SETC:
        opcode <= OPCODE_SETC;
        cond_branch_hint <= '0';
        WAIT FOR CLK_PERIOD;
        check_ALU(ALU_OP_SETC, ALU_INPUT_RSRC2, JMP_FLAG_NONE, '0');
        check_WriteBack('0', '0', '1', '0');
        check_MEM('0', '0', MEM_ADDRESS_CALC, MEM_WRITE_ALU_DATA, '0');
        check_HLT('0');
        check_OutputPort('0');
        check_Multicycle('0', MULTICYCLE_NONE);
        REPORT "SETC test passed" SEVERITY NOTE;

        -- Test 4 NOT:
        opcode <= OPCODE_NOT;
        cond_branch_hint <= '0';
        WAIT FOR CLK_PERIOD;
        check_ALU(ALU_OP_NOT_A, ALU_INPUT_RSRC2, JMP_FLAG_NONE, '0');
        check_WriteBack('1', '0', '1', '0');
        check_MEM('0', '0', MEM_ADDRESS_CALC, MEM_WRITE_ALU_DATA, '0');
        check_HLT('0');
        check_OutputPort('0');
        check_Multicycle('0', MULTICYCLE_NONE);
        REPORT "NOT test passed" SEVERITY NOTE;

        -- Test 5 INC:
        opcode <= OPCODE_INC;
        cond_branch_hint <= '0';
        WAIT FOR CLK_PERIOD;
        check_ALU(ALU_OP_INC_A, ALU_INPUT_RSRC2, JMP_FLAG_NONE, '0');
        check_WriteBack('1', '0', '1', '0');
        check_MEM('0', '0', MEM_ADDRESS_CALC, MEM_WRITE_ALU_DATA, '0');
        check_HLT('0');
        check_OutputPort('0');
        check_Multicycle('0', MULTICYCLE_NONE);
        REPORT "INC test passed" SEVERITY NOTE;

        -- Test 6 OUT:
        opcode <= OPCODE_OUT;
        cond_branch_hint <= '0';
        WAIT FOR CLK_PERIOD;
        check_ALU(ALU_OP_PASS, ALU_INPUT_RSRC2, JMP_FLAG_NONE, '0');
        check_WriteBack('0', '0', '0', '0');
        check_MEM('0', '0', MEM_ADDRESS_CALC, MEM_WRITE_ALU_DATA, '0');
        check_HLT('0');
        check_OutputPort('1');
        check_Multicycle('0', MULTICYCLE_NONE);
        REPORT "OUT test passed" SEVERITY NOTE;

        -- Test 7 IN:
        opcode <= OPCODE_IN;
        cond_branch_hint <= '0';
        WAIT FOR CLK_PERIOD;
        check_ALU(ALU_OP_PASS, ALU_INPUT_IN_PORT, JMP_FLAG_NONE, '0');
        check_WriteBack('0', '1', '0', '0');
        check_MEM('0', '0', MEM_ADDRESS_CALC, MEM_WRITE_ALU_DATA, '0');
        check_HLT('0');
        check_OutputPort('0');
        check_Multicycle('0', MULTICYCLE_NONE);
        REPORT "IN test passed" SEVERITY NOTE;

        -- Test 8 MOV:
        opcode <= OPCODE_MOV;
        cond_branch_hint <= '0';
        WAIT FOR CLK_PERIOD;
        check_ALU(ALU_OP_PASS, ALU_INPUT_RSRC2, JMP_FLAG_NONE, '0');
        check_WriteBack('1', '0', '0', '0');
        check_MEM('0', '0', MEM_ADDRESS_CALC, MEM_WRITE_ALU_DATA, '0');
        check_HLT('0');
        check_OutputPort('0');
        check_Multicycle('0', MULTICYCLE_NONE);
        REPORT "MOV test passed" SEVERITY NOTE;

        -- Test 9 SWAP:
        opcode <= OPCODE_SWAP;
        cond_branch_hint <= '0';
        WAIT FOR CLK_PERIOD;
        check_ALU(ALU_OP_PASS, ALU_INPUT_RSRC2, JMP_FLAG_NONE, '0');
        check_WriteBack('1', '1', '0', '0');
        check_MEM('0', '0', MEM_ADDRESS_CALC, MEM_WRITE_ALU_DATA, '0');
        check_HLT('0');
        check_OutputPort('0');
        check_Multicycle('0', MULTICYCLE_NONE);
        REPORT "SWAP test passed" SEVERITY NOTE;

        -- Test 10 ADD:
        opcode <= OPCODE_ADD;
        cond_branch_hint <= '0';
        WAIT FOR CLK_PERIOD;
        check_ALU(ALU_OP_ADD, ALU_INPUT_RSRC2, JMP_FLAG_NONE, '0');
        check_WriteBack('1', '0', '1', '0');
        check_MEM('0', '0', MEM_ADDRESS_CALC, MEM_WRITE_ALU_DATA, '0');
        check_HLT('0');
        check_OutputPort('0');
        check_Multicycle('0', MULTICYCLE_NONE);
        REPORT "ADD test passed" SEVERITY NOTE;

        -- Test 11 AND:
        opcode <= OPCODE_AND;
        cond_branch_hint <= '0';
        WAIT FOR CLK_PERIOD;
        check_ALU(ALU_OP_AND, ALU_INPUT_RSRC2, JMP_FLAG_NONE, '0');
        check_WriteBack('1', '0', '1', '0');
        check_MEM('0', '0', MEM_ADDRESS_CALC, MEM_WRITE_ALU_DATA, '0');
        check_HLT('0');
        check_OutputPort('0');
        check_Multicycle('0', MULTICYCLE_NONE);
        REPORT "AND test passed" SEVERITY NOTE;

        -- Test 12 SUB:
        opcode <= OPCODE_SUB;
        cond_branch_hint <= '0';
        WAIT FOR CLK_PERIOD;
        check_ALU(ALU_OP_SUB, ALU_INPUT_RSRC2, JMP_FLAG_NONE, '0');
        check_WriteBack('1', '0', '1', '0');
        check_MEM('0', '0', MEM_ADDRESS_CALC, MEM_WRITE_ALU_DATA, '0');
        check_HLT('0');
        check_OutputPort('0');
        check_Multicycle('0', MULTICYCLE_NONE);
        REPORT "SUB test passed" SEVERITY NOTE;

        -- Test 13 IADD:
        opcode <= OPCODE_IADD;
        cond_branch_hint <= '0';
        WAIT FOR CLK_PERIOD;
        check_ALU(ALU_OP_ADD, ALU_INPUT_IMMEDIATE, JMP_FLAG_NONE, '0');
        check_WriteBack('1', '0', '1', '0');
        check_MEM('0', '0', MEM_ADDRESS_CALC, MEM_WRITE_ALU_DATA, '0');
        check_HLT('0');
        check_OutputPort('0');
        check_Multicycle('0', MULTICYCLE_NONE);
        REPORT "IADD test passed" SEVERITY NOTE;

        -- Test 14 PUSH:
        opcode <= OPCODE_PUSH;
        cond_branch_hint <= '0';
        WAIT FOR CLK_PERIOD;
        check_ALU(ALU_OP_PASS, ALU_INPUT_RSRC2, JMP_FLAG_NONE, '0');
        check_WriteBack('0', '0', '0', '0');
        check_MEM('0', '1', MEM_ADDRESS_SP_PUSH, MEM_WRITE_ALU_DATA, '0');
        check_HLT('0');
        check_OutputPort('0');
        check_Multicycle('0', MULTICYCLE_NONE);
        REPORT "PUSH test passed" SEVERITY NOTE;

        -- Test 15 POP:
        opcode <= OPCODE_POP;
        cond_branch_hint <= '0';
        WAIT FOR CLK_PERIOD;
        check_ALU(ALU_OP_PASS, ALU_INPUT_RSRC2, JMP_FLAG_NONE, '0');
        check_WriteBack('1', '0', '0', '0');
        check_MEM('1', '0', MEM_ADDRESS_SP_POP, MEM_WRITE_ALU_DATA, '0');
        check_HLT('0');
        check_OutputPort('0');
        check_Multicycle('0', MULTICYCLE_NONE);
        REPORT "POP test passed" SEVERITY NOTE;

        -- Test 16 CALL:
        opcode <= OPCODE_CALL;
        cond_branch_hint <= '0';
        WAIT FOR CLK_PERIOD;
        check_ALU(ALU_OP_PASS, ALU_INPUT_RSRC2, JMP_FLAG_NONE, '0');
        check_WriteBack('0', '0', '0', '0');
        check_MEM('0', '1', MEM_ADDRESS_SP_PUSH, MEM_WRITE_PC_DATA, '0');
        check_HLT('0');
        check_OutputPort('0');
        check_Multicycle('0', MULTICYCLE_NONE);
        REPORT "CALL test passed" SEVERITY NOTE;
        -- Test 17 RET:
        opcode <= OPCODE_RET;
        cond_branch_hint <= '0';
        WAIT FOR CLK_PERIOD;
        check_ALU(ALU_OP_PASS, ALU_INPUT_RSRC2, JMP_FLAG_NONE, '0');
        check_WriteBack('0', '0', '0', '1');
        check_MEM('1', '0', MEM_ADDRESS_SP_POP, MEM_WRITE_ALU_DATA, '0');
        check_HLT('0');
        check_OutputPort('0');
        check_Multicycle('0', MULTICYCLE_NONE);
        REPORT "RET test passed" SEVERITY NOTE;

        -- Test 18 INT:
        opcode <= OPCODE_INT;
        cond_branch_hint <= '0';
        WAIT FOR CLK_PERIOD;
        check_ALU(ALU_OP_PASS, ALU_INPUT_RSRC2, JMP_FLAG_NONE, '0');
        check_WriteBack('0', '0', '0', '0');
        check_MEM('0', '1', MEM_ADDRESS_SP_PUSH, MEM_WRITE_PC_INTR, '1');
        check_HLT('0');
        check_OutputPort('0');
        check_Multicycle('1', MULTICYCLE_INT2);
        REPORT "INT test passed" SEVERITY NOTE;
        -- Test 19 INT2:
        opcode <= OPCODE_INT2;
        cond_branch_hint <= '0';
        WAIT FOR CLK_PERIOD;
        check_ALU(ALU_OP_PASS, ALU_INPUT_RSRC2, JMP_FLAG_NONE, '0');
        check_WriteBack('0', '0', '0', '0');
        check_MEM('0', '1', MEM_ADDRESS_SP_PUSH, MEM_WRITE_FLAGS_DATA, '0');
        check_HLT('0');
        check_OutputPort('0');
        check_Multicycle('1', MULTICYCLE_INT3);
        REPORT "INT2 test passed" SEVERITY NOTE;

        -- Test 20 INT3:
        opcode <= OPCODE_INT3;
        cond_branch_hint <= '0';
        WAIT FOR CLK_PERIOD;
        check_ALU(ALU_OP_PASS, ALU_INPUT_RSRC2, JMP_FLAG_NONE, '0');
        check_WriteBack('0', '0', '0', '1');
        check_MEM('1', '0', MEM_ADDRESS_INT_VECTOR, MEM_WRITE_ALU_DATA, '0');
        check_HLT('0');
        check_OutputPort('0');
        check_Multicycle('0', MULTICYCLE_NONE);
        REPORT "INT3 test passed" SEVERITY NOTE;

        -- Test 21 RTI:
        opcode <= OPCODE_RTI;
        cond_branch_hint <= '0';
        WAIT FOR CLK_PERIOD;
        check_ALU(ALU_OP_PASS, ALU_INPUT_RSRC2, JMP_FLAG_NONE, '0');
        check_WriteBack('0', '0', '1', '0');
        check_MEM('1', '0', MEM_ADDRESS_SP_POP, MEM_WRITE_ALU_DATA, '0');
        check_HLT('0');
        check_OutputPort('0');
        check_Multicycle('1', MULTICYCLE_RET_STEP);
        REPORT "RTI test passed" SEVERITY NOTE;

        -- Test 22 JZ:
        opcode <= OPCODE_JZ;
        cond_branch_hint <= '1';
        WAIT FOR CLK_PERIOD;
        check_ALU(ALU_OP_PASS, ALU_INPUT_RSRC2, JMP_FLAG_Z, '1');
        check_WriteBack('0', '0', '0', '0');
        check_MEM('0', '0', MEM_ADDRESS_CALC, MEM_WRITE_ALU_DATA, '0');
        check_HLT('0'); 
        check_OutputPort('0');
        check_Multicycle('0', MULTICYCLE_NONE);
        REPORT "JZ test passed" SEVERITY NOTE;

        -- Test 23 JN:
        opcode <= OPCODE_JN;
        cond_branch_hint <= '1';
         WAIT FOR CLK_PERIOD;
        check_ALU(ALU_OP_PASS, ALU_INPUT_RSRC2, JMP_FLAG_N, '1');
        check_WriteBack('0', '0', '0', '0');
        check_MEM('0', '0', MEM_ADDRESS_CALC, MEM_WRITE_ALU_DATA, '0');
        check_HLT('0');
        check_OutputPort('0');
        check_Multicycle('0', MULTICYCLE_NONE);
        REPORT "JN test passed" SEVERITY NOTE;
        -- Test 24 JC:
        opcode <= OPCODE_JC;
        cond_branch_hint <= '1';
        WAIT FOR CLK_PERIOD;
        check_ALU(ALU_OP_PASS, ALU_INPUT_RSRC2, JMP_FLAG_C, '1');
        check_WriteBack('0', '0', '0', '0');
        check_MEM('0', '0', MEM_ADDRESS_CALC, MEM_WRITE_ALU_DATA, '0');
        check_HLT('0');
        check_OutputPort('0');
        check_Multicycle('0', MULTICYCLE_NONE);
        REPORT "JC test passed" SEVERITY NOTE;
        -- Test 25 JMP:
        opcode <= OPCODE_JMP;
        cond_branch_hint <= '0';
        WAIT FOR CLK_PERIOD;
        check_ALU(ALU_OP_PASS, ALU_INPUT_RSRC2, JMP_FLAG_NONE, '0');
        check_WriteBack('0', '0', '0', '0');
        check_MEM('0', '0', MEM_ADDRESS_CALC, MEM_WRITE_ALU_DATA, '0');
        check_HLT('0');
        check_OutputPort('0');
        check_Multicycle('0', MULTICYCLE_NONE);
        REPORT "JMP test passed" SEVERITY NOTE;

        -- Test 26 LDD:
        opcode <= OPCODE_LDD;
        cond_branch_hint <= '0';
        WAIT FOR CLK_PERIOD;
        check_ALU(ALU_OP_PASS, ALU_INPUT_RSRC2, JMP_FLAG_NONE, '0');
        check_WriteBack('1', '0', '0', '0');
        check_MEM('1', '0', MEM_ADDRESS_CALC, MEM_WRITE_ALU_DATA, '0');
        check_HLT('0');
        check_OutputPort('0');
        check_Multicycle('0', MULTICYCLE_NONE);
        REPORT "LDD test passed" SEVERITY NOTE;

        -- Test 27 STD:
        opcode <= OPCODE_STD;
        cond_branch_hint <= '0';
        WAIT FOR CLK_PERIOD;
        check_ALU(ALU_OP_PASS, ALU_INPUT_RSRC2, JMP_FLAG_NONE, '0');
        check_WriteBack('0', '0', '0', '0');
        check_MEM('0', '1', MEM_ADDRESS_CALC, MEM_WRITE_ALU_DATA, '0');
        check_HLT('0');
        check_OutputPort('0');
        check_Multicycle('0', MULTICYCLE_NONE);
        REPORT "STD test passed" SEVERITY NOTE;

        -- Test 28 LDM:  
        opcode <= OPCODE_LDM;
        cond_branch_hint <= '0';
        WAIT FOR CLK_PERIOD;
        check_ALU(ALU_OP_PASS, ALU_INPUT_IMMEDIATE, JMP_FLAG_NONE, '0');
        check_WriteBack('0', '1', '0', '0');
        check_MEM('0', '0', MEM_ADDRESS_CALC, MEM_WRITE_ALU_DATA, '0');
        check_HLT('0');
        check_OutputPort('0');
        check_Multicycle('0', MULTICYCLE_NONE);
        REPORT "LDM test passed" SEVERITY NOTE;

        WAIT; -- Wait indefinitely after tests
    END PROCESS;
END ARCHITECTURE;