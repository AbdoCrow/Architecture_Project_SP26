LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE work.isa_defs_pkg.ALL;

ENTITY id_ex1_register IS
    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        enable : IN STD_LOGIC;

        LOAD_FLAGS_IN : IN STD_LOGIC;
        PC_WRITE_EN_IN : IN STD_LOGIC;
        MEM_WRITE_SEL_IN : IN mem_write_sel_t;
        COND_BRANCH_IN : IN STD_LOGIC;
        HLT_IN : IN STD_LOGIC;
        MEMW_IN : IN STD_LOGIC;
        MEMR_IN : IN STD_LOGIC;
        UPDATE_FLAGS_IN : IN STD_LOGIC;
        MEM_ADDRESS_SEL_IN : IN mem_address_sel_t;
        OUTPUT_PORT_EN_IN : IN STD_LOGIC;
        REG_WB_EN_1_IN : IN STD_LOGIC;
        REG_WB_EN_2_IN : IN STD_LOGIC;
        ALU_INPUT_SEL_IN : IN alu_input_sel_t;
        JMP_FLAG_SEL_IN : IN jmp_flag_sel_t;
        ALU_OP_IN : IN alu_op_t;

        branch_prediction_in : IN STD_LOGIC;
        read_data_1_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        read_data_2_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        imm_offset_in : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        reg_write_address_1_in : IN reg_idx_t;
        reg_write_address_2_in : IN reg_idx_t;
        next_pc_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        read_reg_1_in : IN reg_idx_t;
        read_reg_2_in : IN reg_idx_t;

        LOAD_FLAGS_OUT : OUT STD_LOGIC;
        PC_WRITE_EN_OUT : OUT STD_LOGIC;
        MEM_WRITE_SEL_OUT : OUT mem_write_sel_t;
        COND_BRANCH_OUT : OUT STD_LOGIC;
        HLT_OUT : OUT STD_LOGIC;
        MEMW_OUT : OUT STD_LOGIC;
        MEMR_OUT : OUT STD_LOGIC;
        UPDATE_FLAGS_OUT : OUT STD_LOGIC;
        MEM_ADDRESS_SEL_OUT : OUT mem_address_sel_t;
        OUTPUT_PORT_EN_OUT : OUT STD_LOGIC;
        REG_WB_EN_1_OUT : OUT STD_LOGIC;
        REG_WB_EN_2_OUT : OUT STD_LOGIC;
        ALU_INPUT_SEL_OUT : OUT alu_input_sel_t;
        JMP_FLAG_SEL_OUT : OUT jmp_flag_sel_t;
        ALU_OP_OUT : OUT alu_op_t;

        branch_prediction_out : OUT STD_LOGIC;
        read_data_1_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        read_data_2_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        imm_offset_out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        reg_write_address_1_out : OUT reg_idx_t;
        reg_write_address_2_out : OUT reg_idx_t;
        next_pc_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        read_reg_1_out : OUT reg_idx_t;
        read_reg_2_out : OUT reg_idx_t
    );
END ENTITY id_ex1_register;

ARCHITECTURE rtl OF id_ex1_register IS
BEGIN
    PROCESS (clk, reset)
    BEGIN
        IF reset = '1' THEN
            LOAD_FLAGS_OUT <= '0';
            PC_WRITE_EN_OUT <= '0';
            MEM_WRITE_SEL_OUT <= (OTHERS => '0');
            COND_BRANCH_OUT <= '0';
            HLT_OUT <= '0';
            MEMW_OUT <= '0';
            MEMR_OUT <= '0';
            UPDATE_FLAGS_OUT <= '0';
            MEM_ADDRESS_SEL_OUT <= (OTHERS => '0');
            OUTPUT_PORT_EN_OUT <= '0';
            REG_WB_EN_1_OUT <= '0';
            REG_WB_EN_2_OUT <= '0';
            ALU_INPUT_SEL_OUT <= (OTHERS => '0');
            JMP_FLAG_SEL_OUT <= (OTHERS => '0');
            ALU_OP_OUT <= (OTHERS => '0');

            branch_prediction_out <= '0';
            read_data_1_out <= (OTHERS => '0');
            read_data_2_out <= (OTHERS => '0');
            imm_offset_out <= (OTHERS => '0');
            reg_write_address_1_out <= (OTHERS => '0');
            reg_write_address_2_out <= (OTHERS => '0');
            next_pc_out <= (OTHERS => '0');
            read_reg_1_out <= (OTHERS => '0');
            read_reg_2_out <= (OTHERS => '0');
        ELSIF rising_edge(clk) THEN
            IF enable = '1' THEN
                LOAD_FLAGS_OUT <= LOAD_FLAGS_IN;
                PC_WRITE_EN_OUT <= PC_WRITE_EN_IN;
                MEM_WRITE_SEL_OUT <= MEM_WRITE_SEL_IN;
                COND_BRANCH_OUT <= COND_BRANCH_IN;
                HLT_OUT <= HLT_IN;
                MEMW_OUT <= MEMW_IN;
                MEMR_OUT <= MEMR_IN;
                UPDATE_FLAGS_OUT <= UPDATE_FLAGS_IN;
                MEM_ADDRESS_SEL_OUT <= MEM_ADDRESS_SEL_IN;
                OUTPUT_PORT_EN_OUT <= OUTPUT_PORT_EN_IN;
                REG_WB_EN_1_OUT <= REG_WB_EN_1_IN;
                REG_WB_EN_2_OUT <= REG_WB_EN_2_IN;
                ALU_INPUT_SEL_OUT <= ALU_INPUT_SEL_IN;
                JMP_FLAG_SEL_OUT <= JMP_FLAG_SEL_IN;
                ALU_OP_OUT <= ALU_OP_IN;

                branch_prediction_out <= branch_prediction_in;
                read_data_1_out <= read_data_1_in;
                read_data_2_out <= read_data_2_in;
                imm_offset_out <= imm_offset_in;
                reg_write_address_1_out <= reg_write_address_1_in;
                reg_write_address_2_out <= reg_write_address_2_in;
                next_pc_out <= next_pc_in;
                read_reg_1_out <= read_reg_1_in;
                read_reg_2_out <= read_reg_2_in;
            END IF;
        END IF;
    END PROCESS;
END ARCHITECTURE rtl;