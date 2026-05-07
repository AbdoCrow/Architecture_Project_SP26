LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE work.isa_defs_pkg.ALL;

ENTITY decode_stage IS
    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        intr_in : IN STD_LOGIC;

        instr_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        next_pc_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        branch_prediction_in : IN STD_LOGIC;

        wb_addr_in : IN reg_idx_t;
        wb_data_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        REG_WB_EN_IN : IN STD_LOGIC;

        LOAD_FLAGS : OUT STD_LOGIC;
        PC_WRITE_EN : OUT STD_LOGIC;
        MEM_WRITE_SEL : OUT mem_write_sel_t;
        COND_BRANCH : OUT STD_LOGIC;
        HLT : OUT STD_LOGIC;
        SWAP_2ND_CYCLE : OUT STD_LOGIC;
        MEMW : OUT STD_LOGIC;
        MEMR : OUT STD_LOGIC;
        UPDATE_FLAGS : OUT STD_LOGIC;
        MEM_ADDRESS_SEL : OUT mem_address_sel_t;
        OUTPUT_PORT_EN : OUT STD_LOGIC;
        REG_WB_EN : OUT STD_LOGIC;
        ALU_INPUT_SEL : OUT alu_input_sel_t;
        JMP_FLAG_SEL : OUT jmp_flag_sel_t;
        ALU_OP : OUT alu_op_t;

        MULTICYCLE_STALL : OUT STD_LOGIC;
        MULTICYCLE_SEL : OUT multicycle_sel_t;

        read_data_1_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        read_data_2_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        imm_offset_out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        reg_write_address_out : OUT reg_idx_t;
        next_pc_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        read_reg_1_out : OUT reg_idx_t;
        read_reg_2_out : OUT reg_idx_t;
        branch_prediction_out : OUT STD_LOGIC
    );
END ENTITY decode_stage;

ARCHITECTURE rtl OF decode_stage IS
BEGIN
    -- Definition-only skeleton.
    -- TODO: decode opcodes including OPCODE_SWAP2/OPCODE_INT2/OPCODE_INT3 for internal sequencing.
END ARCHITECTURE rtl;