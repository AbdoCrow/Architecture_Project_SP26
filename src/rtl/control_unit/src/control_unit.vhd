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
    process (opcode)
    begin
        case opcode is
            when OPCODE_NOP =>
            REG_WB_EN <= '0';
            update_flags <= '0';
            MEMR <= '0';
            MEMW <= '0';
            OUTPUT_PORT_EN <= '0';

            when OPCODE_HLT =>
            REG_WB_EN <= '0';
            update_flags <= '0';
            MEMR <= '0';
            MEMW <= '0';
            OUTPUT_PORT_EN <= '0';
            HLT <= '1';

            when OPCODE_SETC =>
            ALU_OP <= ALU_OP_SETC;
            REG_WB_EN <= '0';
            update_flags <= '1';
            MEMR <= '0';
            MEMW <= '0';
            OUTPUT_PORT_EN <= '0';

            when OPCODE_NOT =>
            ALU_OP <= ALU_OP_NOT_A;
            REG_WB_EN <= '1';
            update_flags <= '1';
            MEMR <= '0';
            MEMW <= '0';
            OUTPUT_PORT_EN <= '0';
            when OPCODE_INC =>
            ALU_OP <= ALU_OP_INC_A;
            REG_WB_EN <= '1';
            update_flags <= '1';
            MEMR <= '0';
            MEMW <= '0';
            OUTPUT_PORT_EN <= '0';

            when OPCODE_IN =>
            ALU_OP <= ALU_OP_PASS_B;
            REG_WB_EN <= '1';
            update_flags <= '0';
            MEMR <= '0';
            MEMW <= '0';
            OUTPUT_PORT_EN <= '0';
            ALU_INPUT_SEL <= ALU_INPUT_IN_PORT;

            when OPCODE_OUT =>
            ALU_OP <= ALU_OP_PASS_A;
            REG_WB_EN <= '0';
            update_flags <= '0';
            MEMR <= '0';
            MEMW <= '0';
            OUTPUT_PORT_EN <= '1';

            when OPCODE_MOV =>
            ALU_OP <= ALU_OP_PASS_A;
            REG_WB_EN <= '1';
            update_flags <= '0';
            MEMR <= '0';
            MEMW <= '0';
            OUTPUT_PORT_EN <= '0';
            when OPCODE_SWAP =>
            ALU_OP <= ALU_OP_PASS_A;
            REG_WB_EN <= '1';
            update_flags <= '0';
            MEMR <= '0';
            MEMW <= '0';
            OUTPUT_PORT_EN <= '0';
            multicycle_stall <= '1';
            MULTICYCLE_SEL <= MULTICYCLE_SWAP2;

            SWAP_2ND_CYCLE <= '1';
            when OPCODE_ADD =>
            ALU_OP <= ALU_OP_ADD;
            REG_WB_EN <= '1';
            update_flags <= '1';
            MEMR <= '0';
            MEMW <= '0';
            OUTPUT_PORT_EN <= '0';
            ALU_INPUT_SEL <= ALU_INPUT_RSRC2;

            when OPCODE_SUB =>
            ALU_OP <= ALU_OP_SUB;
            REG_WB_EN <= '1';
            update_flags <= '1';
            MEMR <= '0';
            MEMW <= '0';
            OUTPUT_PORT_EN <= '0';
            ALU_INPUT_SEL <= ALU_INPUT_RSRC2;

            when OPCODE_AND =>
            ALU_OP <= ALU_OP_AND;
            REG_WB_EN <= '1';
            update_flags <= '1';
            MEMR <= '0';
            MEMW <= '0';
            OUTPUT_PORT_EN <= '0';
            ALU_INPUT_SEL <= ALU_INPUT_RSRC2;

            when OPCODE_IADD =>
            ALU_OP <= ALU_OP_ADD;
            REG_WB_EN <= '1';
            update_flags <= '1';
            MEMR <= '0';
            MEMW <= '0';
            OUTPUT_PORT_EN <= '0';
            ALU_INPUT_SEL <= ALU_INPUT_IMMEDIATE;

            when OPCODE_PUSH =>
            ALU_OP <= ALU_OP_PASS_A;
            REG_WB_EN <= '0';
            update_flags <= '0';
            MEMR <= '0';
            MEMW <= '1';
            MEM_ADDRESS_SEL <= MEM_ADDRESS_SP_PUSH;
            MEM_WRITE_SEL <= MEM_WRITE_ALU_DATA;
            COND_BRANCH <= '0';
            PC_WRITE_EN <= '0';

            when OPCODE_POP =>
            ALU_OP <= ALU_OP_PASS_A;
            REG_WB_EN <= '1';
            update_flags <= '0';
            MEMR <= '1';
            MEMW <= '0';
            MEM_ADDRESS_SEL <= MEM_ADDRESS_SP_POP;
            MEM_WRITE_SEL <= MEM_WRITE_ALU_DATA;
            COND_BRANCH <= '0';
            PC_WRITE_EN <= '0';

            when OPCODE_LDM =>
            ALU_OP <= ALU_OP_PASS_B;
            REG_WB_EN <= '1';
            update_flags <= '0';
            MEMR <= '0';
            MEMW <= '0';
            MEM_ADDRESS_SEL <= MEM_ADDRESS_CALC;
            MEM_WRITE_SEL <= MEM_WRITE_ALU_DATA;
            COND_BRANCH <= '0';
            PC_WRITE_EN <= '0';
            
            when OPCODE_LDD =>
            ALU_OP <= ALU_OP_ADD;
            REG_WB_EN <= '1';
            update_flags <= '0';
            MEMR <= '1';
            MEMW <= '0';
            MEM_ADDRESS_SEL <= MEM_ADDRESS_CALC;
            MEM_WRITE_SEL <= MEM_WRITE_ALU_DATA;
            COND_BRANCH <= '0';
            PC_WRITE_EN <= '0';

            WHEN OPCODE_STD =>
            ALU_OP <= ALU_OP_PASS_A;
            REG_WB_EN <= '0';
            update_flags <= '0';
            MEMR <= '0';
            MEMW <= '1';
            MEM_ADDRESS_SEL <= MEM_ADDRESS_CALC;
            MEM_WRITE_SEL <= MEM_WRITE_ALU_DATA;
            COND_BRANCH <= '0';
            PC_WRITE_EN <= '0';

            WHEN OPCODE_JZ | OPCODE_JN | OPCODE_JC =>
            ALU_OP <= ALU_OP_PASS_A;
            REG_WB_EN <= '0';
            update_flags <= '0';
            MEMR <= '0';
            MEMW <= '0';
            MEM_ADDRESS_SEL <= MEM_ADDRESS_CALC;
            MEM_WRITE_SEL <= MEM_WRITE_ALU_DATA;
            COND_BRANCH <= '1';
            PC_WRITE_EN <= '0';

            WHEN OPCODE_JMP =>
            ALU_OP <= ALU_OP_PASS_A;
            REG_WB_EN <= '0';
            update_flags <= '0';
            MEMR <= '0';
            MEMW <= '0';
            MEM_ADDRESS_SEL <= MEM_ADDRESS_CALC;
            MEM_WRITE_SEL <= MEM_WRITE_ALU_DATA;
            COND_BRANCH <= '0';
            PC_WRITE_EN <= '0';

            WHEN OPCODE_CALL =>
            ALU_OP <= ALU_OP_PASS_A;
            REG_WB_EN <= '0';
            update_flags <= '0';
            MEMR <= '0';
            MEMW <= '1';
            MEM_ADDRESS_SEL <= MEM_ADDRESS_SP_PUSH;
            MEM_WRITE_SEL <= MEM_WRITE_PC_DATA;
            COND_BRANCH <= '0';
            PC_WRITE_EN <= '0';

            WHEN OPCODE_RET =>
            ALU_OP <= ALU_OP_PASS_A;
            REG_WB_EN <= '0';   
            update_flags <= '0';
            MEMR <= '1';
            MEMW <= '0';
            MEM_ADDRESS_SEL <= MEM_ADDRESS_SP_POP;
            MEM_WRITE_SEL <= MEM_WRITE_PC_DATA;
            COND_BRANCH <= '0';
            PC_WRITE_EN <= '1';

            WHEN OPCODE_RTI =>
            ALU_OP <= ALU_OP_PASS_A;
            REG_WB_EN <= '0';
            update_flags <= '1';
            MEMR <= '1';
            MEMW <= '0';
            MEM_ADDRESS_SEL <= MEM_ADDRESS_SP_POP;
            MEM_WRITE_SEL <= MEM_WRITE_ALU_DATA;
            COND_BRANCH <= '0';
            PC_WRITE_EN <= '1';

            WHEN OPCODE_INT =>
            ALU_OP <= ALU_OP_PASS_A;
            REG_WB_EN <= '0';
            update_flags <= '0';
            MEMR <= '0';
            MEMW <= '1';
            MEM_ADDRESS_SEL <= MEM_ADDRESS_SP_PUSH;
            MEM_WRITE_SEL <= MEM_WRITE_PC_DATA;
            COND_BRANCH <= '0';
            PC_WRITE_EN <= '1';
            MULTICYCLE_STALL <= '1';
            MULTICYCLE_SEL <= MULTICYCLE_INT2;

            WHEN OPCODE_SWAP2 =>
            REG_WB_EN <= '1';
            update_flags <= '0';
            MEMR <= '0';
            MEMW <= '0';
            MEM_ADDRESS_SEL <= MEM_ADDRESS_CALC;
            MEM_WRITE_SEL <= MEM_WRITE_ALU_DATA;
            PC_WRITE_EN <= '1';
            SWAP_2ND_CYCLE <= '1';
            MULTICYCLE_STALL <= '0';
            MULTICYCLE_SEL <= MULTICYCLE_NONE;

            when OPCODE_INT2 =>
            REG_WB_EN <= '0';
            update_flags <= '0';
            MEMR <= '0';
            MEMW <= '1';
            MEM_ADDRESS_SEL <= MEM_ADDRESS_SP_PUSH;
            MEM_WRITE_SEL <= MEM_WRITE_FLAGS_DATA;
            PC_WRITE_EN <= '0';
            SWAP_2ND_CYCLE <= '0';
            MULTICYCLE_STALL <= '1';
            MULTICYCLE_SEL <= MULTICYCLE_INT3;

            when OPCODE_INT3 =>
            REG_WB_EN <= '0';
            update_flags <= '0';
            MEMR <= '0';
            MEMW <= '0';
            MEM_ADDRESS_SEL <= MEM_ADDRESS_INT_VECTOR;
            MEM_WRITE_SEL <= MEM_WRITE_ALU_DATA;
            PC_WRITE_EN <= '1';
            SWAP_2ND_CYCLE <= '0';
            MULTICYCLE_STALL <= '0';
            MULTICYCLE_SEL <= MULTICYCLE_NONE;

            when others => 
            end case;
    end process;
END ARCHITECTURE rtl;