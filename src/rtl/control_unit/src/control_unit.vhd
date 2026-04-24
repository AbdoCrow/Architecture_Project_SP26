LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE work.isa_defs_pkg.ALL;

ENTITY control_unit IS
    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        intr_in : IN STD_LOGIC;
        instr : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        opcode : IN opcode_t;

        FETCH_STALL : OUT STD_LOGIC;
        DECODE_STALL : OUT STD_LOGIC;
        DECODE_FLUSH : OUT STD_LOGIC;
        EX1_FLUSH : OUT STD_LOGIC;
        PC_ENABLE : OUT STD_LOGIC;

        LOAD_FLAGS : OUT STD_LOGIC;
        PC_WRITE_EN : OUT STD_LOGIC;
        MEM_WRITE_SEL : OUT mem_write_sel_t;
        COND_BRANCH : OUT STD_LOGIC;
        HLT : OUT STD_LOGIC;
        MEMW : OUT STD_LOGIC;
        MEMR : OUT STD_LOGIC;
        REG_WB_EN : OUT STD_LOGIC;
        UPDATE_FLAGS : OUT STD_LOGIC;
        ALU_OP : OUT alu_op_t;
        ALU_INPUT_SEL : OUT alu_input_sel_t;
        JMP_FLAG_SEL : OUT jmp_flag_sel_t;
        OUTPUT_PORT_EN : OUT STD_LOGIC;
        MEM_ADDRESS_SEL : OUT mem_address_sel_t;
        SWAP_2ND_CYCLE : OUT STD_LOGIC;
        MULTICYCLE_STALL : OUT STD_LOGIC;
        MULTICYCLE_SEL : OUT multicycle_sel_t
    );
END ENTITY control_unit;

ARCHITECTURE rtl OF control_unit IS
BEGIN
-- Definition-only skeleton.
-- TODO: map opcode/internal opcode values from isa_defs_pkg to control outputs.
-- TODO: implement multicycle sequencing for SWAP -> SWAP2 and INT -> INT2 -> INT3.
-- TODO: generate CALL/JMP early-branch behavior based on instr(BR_HINT_UNCOND_BIT)
    with opcode select REG_WB_EN <=
        '1' when OPCODE_NOT | OPCODE_INC | OPCODE_IN | OPCODE_MOV | OPCODE_SWAP |
                 OPCODE_ADD | OPCODE_SUB | OPCODE_AND | OPCODE_IADD | OPCODE_POP |
                 OPCODE_LDM | OPCODE_LDD | OPCODE_SWAP2,
        '0' when others;

    with opcode select UPDATE_FLAGS <=
        '1' when OPCODE_SETC | OPCODE_NOT | OPCODE_INC | OPCODE_ADD |
                 OPCODE_SUB | OPCODE_AND | OPCODE_IADD | OPCODE_RTI,
        '0' when others;

    with opcode select MEMR <=
        '1' when OPCODE_POP | OPCODE_LDD | OPCODE_RET | OPCODE_RTI,
        '0' when others;

    with opcode select MEMW <=
        '1' when OPCODE_PUSH | OPCODE_STD | OPCODE_CALL | OPCODE_INT | OPCODE_INT2,
        '0' when others;

    with opcode select OUTPUT_PORT_EN <=
        '1' when OPCODE_OUT,
        '0' when others;

    with opcode select HLT <=
        '1' when OPCODE_HLT,
        '0' when others;

    with opcode select ALU_OP <=
        ALU_OP_SETC when OPCODE_SETC,
        ALU_OP_NOT_A when OPCODE_NOT,
        ALU_OP_INC_A when OPCODE_INC,
        ALU_OP_PASS_B when OPCODE_IN | OPCODE_LDM,
        ALU_OP_PASS_A when OPCODE_OUT | OPCODE_MOV | OPCODE_SWAP | OPCODE_PUSH |
                           OPCODE_POP | OPCODE_STD | OPCODE_JZ | OPCODE_JN |
                           OPCODE_JC | OPCODE_JMP | OPCODE_CALL | OPCODE_RET |
                           OPCODE_RTI | OPCODE_INT,
        ALU_OP_ADD when OPCODE_ADD | OPCODE_IADD | OPCODE_LDD,
        ALU_OP_SUB when OPCODE_SUB,
        ALU_OP_AND when OPCODE_AND,
        ALU_OP_NOP when others;

    with opcode select ALU_INPUT_SEL <=
        ALU_INPUT_IN_PORT when OPCODE_IN,
        ALU_INPUT_IMMEDIATE when OPCODE_IADD,
        ALU_INPUT_RSRC2 when others;

    with opcode select MEM_ADDRESS_SEL <=
        MEM_ADDRESS_SP_PUSH when OPCODE_PUSH | OPCODE_CALL | OPCODE_INT | OPCODE_INT2,
        MEM_ADDRESS_SP_POP when OPCODE_POP | OPCODE_RET | OPCODE_RTI,
        MEM_ADDRESS_INT_VECTOR when OPCODE_INT3,
        MEM_ADDRESS_CALC when others;

    with opcode select MEM_WRITE_SEL <=
        MEM_WRITE_PC_DATA when OPCODE_CALL | OPCODE_RET | OPCODE_INT,
        MEM_WRITE_FLAGS_DATA when OPCODE_INT2,
        MEM_WRITE_ALU_DATA when others;

    with opcode select COND_BRANCH <=
        '1' when OPCODE_JZ | OPCODE_JN | OPCODE_JC,
        '0' when others;

    with opcode select PC_WRITE_EN <=
        '1' when OPCODE_RET | OPCODE_RTI | OPCODE_INT | OPCODE_SWAP2 | OPCODE_INT3,
        '0' when others;

    with opcode select SWAP_2ND_CYCLE <=
        '1' when OPCODE_SWAP | OPCODE_SWAP2,
        '0' when others;

    with opcode select MULTICYCLE_STALL <=
        '1' when OPCODE_SWAP | OPCODE_INT | OPCODE_INT2,
        '0' when others;

    with opcode select MULTICYCLE_SEL <=
        MULTICYCLE_SWAP2 when OPCODE_SWAP,
        MULTICYCLE_INT2 when OPCODE_INT,
        MULTICYCLE_INT3 when OPCODE_INT2,
        MULTICYCLE_NONE when others;
END ARCHITECTURE rtl;