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
    -- TODO: generate CALL/JMP early-branch behavior based on instr(BR_HINT_UNCOND_BIT).
END ARCHITECTURE rtl;