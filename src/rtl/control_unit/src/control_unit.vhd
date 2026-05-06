LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE work.isa_defs_pkg.ALL;

ENTITY control_unit IS
    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        intr_in : IN STD_LOGIC;
        --instr : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
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
    signal reg_wb_en_i : STD_LOGIC;
    signal update_flags_i : STD_LOGIC;
    signal memr_i : STD_LOGIC;
    signal memw_i : STD_LOGIC;
    signal output_port_en_i : STD_LOGIC;
    signal hlt_i : STD_LOGIC;
    signal alu_op_i : alu_op_t;
    signal alu_input_sel_i : alu_input_sel_t;
    signal mem_address_sel_i : mem_address_sel_t;
    signal mem_write_sel_i : mem_write_sel_t;
    signal cond_branch_i : STD_LOGIC;
    signal pc_write_en_i : STD_LOGIC;
    signal swap_2nd_cycle_i : STD_LOGIC;
    signal multicycle_stall_i : STD_LOGIC;
    signal multicycle_sel_i : multicycle_sel_t;
BEGIN

    REG_WB_EN <= reg_wb_en_i;
    UPDATE_FLAGS <= update_flags_i;
    MEMR <= memr_i;
    MEMW <= memw_i;
    OUTPUT_PORT_EN <= output_port_en_i;
    HLT <= hlt_i;
    ALU_OP <= alu_op_i;
    ALU_INPUT_SEL <= alu_input_sel_i;
    MEM_ADDRESS_SEL <= mem_address_sel_i;
    MEM_WRITE_SEL <= mem_write_sel_i;
    COND_BRANCH <= cond_branch_i;
    PC_WRITE_EN <= pc_write_en_i;
    SWAP_2ND_CYCLE <= swap_2nd_cycle_i;
    MULTICYCLE_STALL <= multicycle_stall_i;
    MULTICYCLE_SEL <= multicycle_sel_i;

    with opcode select reg_wb_en_i <=
        '0' when OPCODE_NOP | OPCODE_HLT | OPCODE_SETC | OPCODE_OUT | OPCODE_PUSH |
                 OPCODE_STD | OPCODE_JZ | OPCODE_JN | OPCODE_JC | OPCODE_JMP |
                 OPCODE_CALL | OPCODE_RET | OPCODE_RTI | OPCODE_INT |
                 OPCODE_INT2 | OPCODE_INT3,
        '1' when OPCODE_NOT | OPCODE_INC | OPCODE_IN | OPCODE_MOV | OPCODE_SWAP |
                 OPCODE_ADD | OPCODE_SUB | OPCODE_AND | OPCODE_IADD | OPCODE_POP |
                 OPCODE_LDM | OPCODE_LDD | OPCODE_SWAP2,
        reg_wb_en_i when others;

    with opcode select update_flags_i <=
        '0' when OPCODE_NOP | OPCODE_HLT | OPCODE_IN | OPCODE_OUT | OPCODE_MOV |
                 OPCODE_SWAP | OPCODE_PUSH | OPCODE_POP | OPCODE_LDM | OPCODE_LDD |
                 OPCODE_STD | OPCODE_JZ | OPCODE_JN | OPCODE_JC | OPCODE_JMP |
                 OPCODE_CALL | OPCODE_RET | OPCODE_INT | OPCODE_SWAP2 |
                 OPCODE_INT2 | OPCODE_INT3,
        '1' when OPCODE_SETC | OPCODE_NOT | OPCODE_INC | OPCODE_ADD | OPCODE_SUB |
                 OPCODE_AND | OPCODE_IADD | OPCODE_RTI,
        update_flags_i when others;

    with opcode select memr_i <=
        '0' when OPCODE_NOP | OPCODE_HLT | OPCODE_SETC | OPCODE_NOT | OPCODE_INC |
                 OPCODE_IN | OPCODE_OUT | OPCODE_MOV | OPCODE_SWAP | OPCODE_ADD |
                 OPCODE_SUB | OPCODE_AND | OPCODE_IADD | OPCODE_PUSH | OPCODE_LDM |
                 OPCODE_STD | OPCODE_JZ | OPCODE_JN | OPCODE_JC | OPCODE_JMP |
                 OPCODE_CALL | OPCODE_INT | OPCODE_SWAP2 | OPCODE_INT2 |
                 OPCODE_INT3,
        '1' when OPCODE_POP | OPCODE_LDD | OPCODE_RET | OPCODE_RTI,
        memr_i when others;

    with opcode select memw_i <=
        '0' when OPCODE_NOP | OPCODE_HLT | OPCODE_SETC | OPCODE_NOT | OPCODE_INC |
                 OPCODE_IN | OPCODE_OUT | OPCODE_MOV | OPCODE_SWAP | OPCODE_ADD |
                 OPCODE_SUB | OPCODE_AND | OPCODE_IADD | OPCODE_POP | OPCODE_LDM |
                 OPCODE_LDD | OPCODE_JZ | OPCODE_JN | OPCODE_JC | OPCODE_JMP |
                 OPCODE_RET | OPCODE_RTI | OPCODE_SWAP2 | OPCODE_INT3,
        '1' when OPCODE_PUSH | OPCODE_STD | OPCODE_CALL | OPCODE_INT | OPCODE_INT2,
        memw_i when others;

    with opcode select output_port_en_i <=
        '0' when OPCODE_NOP | OPCODE_HLT | OPCODE_SETC | OPCODE_NOT | OPCODE_INC |
                 OPCODE_IN | OPCODE_MOV | OPCODE_SWAP | OPCODE_ADD | OPCODE_SUB |
                 OPCODE_AND | OPCODE_IADD,
        '1' when OPCODE_OUT,
        output_port_en_i when others;

    with opcode select hlt_i <=
        '1' when OPCODE_HLT,
        hlt_i when others;

    with opcode select alu_op_i <=
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
        alu_op_i when others;

    with opcode select alu_input_sel_i <=
        ALU_INPUT_IN_PORT when OPCODE_IN,
        ALU_INPUT_RSRC2 when OPCODE_ADD | OPCODE_SUB | OPCODE_AND,
        ALU_INPUT_IMMEDIATE when OPCODE_IADD,
        alu_input_sel_i when others;

    with opcode select mem_address_sel_i <=
        MEM_ADDRESS_SP_PUSH when OPCODE_PUSH | OPCODE_CALL | OPCODE_INT | OPCODE_INT2,
        MEM_ADDRESS_SP_POP when OPCODE_POP | OPCODE_RET | OPCODE_RTI,
        MEM_ADDRESS_CALC when OPCODE_LDM | OPCODE_LDD | OPCODE_STD | OPCODE_JZ |
                               OPCODE_JN | OPCODE_JC | OPCODE_JMP | OPCODE_SWAP2,
        MEM_ADDRESS_INT_VECTOR when OPCODE_INT3,
        mem_address_sel_i when others;

    with opcode select mem_write_sel_i <=
        MEM_WRITE_ALU_DATA when OPCODE_PUSH | OPCODE_POP | OPCODE_LDM | OPCODE_LDD |
                              OPCODE_STD | OPCODE_JZ | OPCODE_JN | OPCODE_JC |
                              OPCODE_JMP | OPCODE_RTI | OPCODE_SWAP2 |
                              OPCODE_INT3,
        MEM_WRITE_PC_DATA when OPCODE_CALL | OPCODE_RET | OPCODE_INT,
        MEM_WRITE_FLAGS_DATA when OPCODE_INT2,
        mem_write_sel_i when others;

    with opcode select cond_branch_i <=
        '0' when OPCODE_PUSH | OPCODE_POP | OPCODE_LDM | OPCODE_LDD | OPCODE_STD |
                 OPCODE_JMP | OPCODE_CALL | OPCODE_RET | OPCODE_RTI | OPCODE_INT,
        '1' when OPCODE_JZ | OPCODE_JN | OPCODE_JC,
        cond_branch_i when others;

    with opcode select pc_write_en_i <=
        '0' when OPCODE_PUSH | OPCODE_POP | OPCODE_LDM | OPCODE_LDD | OPCODE_STD |
                 OPCODE_JZ | OPCODE_JN | OPCODE_JC | OPCODE_JMP | OPCODE_CALL |
                 OPCODE_INT2,
        '1' when OPCODE_RET | OPCODE_RTI | OPCODE_INT | OPCODE_SWAP2 | OPCODE_INT3,
        pc_write_en_i when others;

    with opcode select swap_2nd_cycle_i <=
        '1' when OPCODE_SWAP | OPCODE_SWAP2,
        '0' when OPCODE_INT2 | OPCODE_INT3,
        swap_2nd_cycle_i when others;

    with opcode select multicycle_stall_i <=
        '1' when OPCODE_SWAP | OPCODE_INT | OPCODE_INT2,
        '0' when OPCODE_SWAP2 | OPCODE_INT3,
        multicycle_stall_i when others;

    with opcode select multicycle_sel_i <=
        MULTICYCLE_SWAP2 when OPCODE_SWAP,
        MULTICYCLE_INT2 when OPCODE_INT,
        MULTICYCLE_NONE when OPCODE_SWAP2 | OPCODE_INT3,
        MULTICYCLE_INT3 when OPCODE_INT2,
        multicycle_sel_i when others;
END ARCHITECTURE rtl;