LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE work.isa_defs_pkg.ALL;

ENTITY control_unit IS
    PORT (
        --opcode and hints
        opcode : IN opcode_t;
        cond_branch_hint : IN STD_LOGIC;
        
        -- Control signals
        LOAD_FLAGS : OUT STD_LOGIC;
        PC_WRITE_EN : OUT STD_LOGIC;
        MEM_WRITE_SEL : OUT mem_write_sel_t;
        COND_BRANCH : OUT STD_LOGIC;
        HLT : OUT STD_LOGIC;
        MEMW : OUT STD_LOGIC;
        MEMR : OUT STD_LOGIC;
        REG_WB_EN_1 : OUT STD_LOGIC;
        REG_WB_EN_2 : OUT STD_LOGIC;
        UPDATE_FLAGS : OUT STD_LOGIC;
        ALU_OP : OUT alu_op_t;
        ALU_INPUT_SEL : OUT alu_input_sel_t;
        JMP_FLAG_SEL : OUT jmp_flag_sel_t;
        OUTPUT_PORT_EN : OUT STD_LOGIC;
        MEM_ADDRESS_SEL : OUT mem_address_sel_t;
        MULTICYCLE_STALL : OUT STD_LOGIC;
        MULTICYCLE_SEL : OUT multicycle_sel_t

    );
END ENTITY control_unit;

ARCHITECTURE rtl OF control_unit IS
BEGIN
    -- Simple flag Signals
    LOAD_FLAGS <= '1' WHEN opcode = OPCODE_INT ELSE '0';
    OUTPUT_PORT_EN <= '1' WHEN opcode = OPCODE_OUT ELSE '0';
    HLT <= '1' WHEN opcode = OPCODE_HLT ELSE '0';
    MULTICYCLE_STALL <= '1' WHEN opcode = OPCODE_INT OR opcode = OPCODE_INT2 OR opcode = OPCODE_RTI ELSE '0';
    COND_BRANCH <= cond_branch_hint;
    REG_WB_EN_2 <= '1' WHEN opcode = OPCODE_IN OR opcode = OPCODE_SWAP OR opcode = OPCODE_LDM ELSE '0';
    PC_WRITE_EN <= '1' WHEN opcode = OPCODE_RET OR opcode = OPCODE_INT3 ELSE '0';


    -- complex flag signals
    MEMW <= '1' WHEN opcode = OPCODE_PUSH OR
                    opcode = OPCODE_STD OR
                    opcode = OPCODE_CALL OR
                    opcode = OPCODE_INT or
                    opcode = OPCODE_INT2
                    ELSE '0';
    MEMR <= '1' WHEN opcode = OPCODE_POP OR
                    opcode = OPCODE_RET OR
                    opcode = OPCODE_RTI OR
                    opcode = OPCODE_LDD OR 
                    opcode = OPCODE_INT3
                    ELSE '0';

    UPDATE_FLAGS <= '1' WHEN opcode = OPCODE_NOT OR
                        opcode = OPCODE_INC OR
                        opcode = OPCODE_SETC OR
                        opcode = OPCODE_ADD OR
                        opcode = OPCODE_SUB OR
                        opcode = OPCODE_AND OR
                        opcode = OPCODE_IADD OR
                        opcode = OPCODE_RTI
                        ELSE '0';
    REG_WB_EN_1 <= '1' WHEN opcode = OPCODE_NOT OR
                        opcode = OPCODE_INC OR
                        opcode = OPCODE_ADD OR
                        opcode = OPCODE_SUB OR
                        opcode = OPCODE_AND OR
                        opcode = OPCODE_IADD OR
                        opcode = OPCODE_LDD OR
                        opcode = OPCODE_SWAP OR 
                        opcode = OPCODE_MOV OR
                        opcode = OPCODE_POP
                        ELSE '0';
    -- Selector Signals
    WITH opcode SELECT
        MEM_WRITE_SEL <= MEM_WRITE_FLAGS_DATA WHEN OPCODE_INT2,
                         MEM_WRITE_PC_DATA WHEN OPCODE_CALL | OPCODE_INT,
                         MEM_WRITE_ALU_DATA WHEN OTHERS;
    WITH opcode SELECT
        MEM_ADDRESS_SEL <= MEM_ADDRESS_SP_PUSH WHEN  OPCODE_INT | OPCODE_INT2 | OPCODE_PUSH | OPCODE_CALL,
                           MEM_ADDRESS_SP_POP WHEN OPCODE_POP | OPCODE_RET | OPCODE_RTI,
                           MEM_ADDRESS_INT_VECTOR WHEN OPCODE_INT3,
                           MEM_ADDRESS_CALC WHEN OTHERS;
    WITH opcode SELECT
        MULTICYCLE_SEL <= MULTICYCLE_INT2 WHEN OPCODE_INT,
                          MULTICYCLE_INT3 WHEN OPCODE_INT2,
                          MULTICYCLE_RET_STEP WHEN OPCODE_RTI,
                          MULTICYCLE_NONE WHEN OTHERS;
    WITH opcode SELECT
        JMP_FLAG_SEL <= JMP_FLAG_Z WHEN OPCODE_JZ,
                        JMP_FLAG_N WHEN OPCODE_JN,
                        JMP_FLAG_C WHEN OPCODE_JC,
                        JMP_FLAG_NONE WHEN OTHERS;
    WITH opcode SELECT
        ALU_INPUT_SEL <= ALU_INPUT_IMMEDIATE WHEN OPCODE_IADD | OPCODE_LDM,
                         ALU_INPUT_IN_PORT WHEN OPCODE_IN,
                         ALU_INPUT_RSRC2 WHEN OTHERS;

    with opcode SELECT
        ALU_OP <= ALU_OP_ADD WHEN OPCODE_ADD | OPCODE_IADD,
                  ALU_OP_SUB WHEN OPCODE_SUB,
                  ALU_OP_AND WHEN OPCODE_AND,
                  ALU_OP_NOT_A WHEN OPCODE_NOT,
                  ALU_OP_INC_A WHEN OPCODE_INC,
                  ALU_OP_SETC WHEN OPCODE_SETC,
                  ALU_OP_NOP WHEN OPCODE_NOP,
                  ALU_OP_PASS WHEN OTHERS;
END ARCHITECTURE rtl;