LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE work.isa_defs_pkg.ALL;

ENTITY ex1_ex2_register IS
    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        FLUSH : IN STD_LOGIC;

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
        JMP_FLAG_SEL_IN : IN jmp_flag_sel_t;

        corrected_ccr_flags_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        branch_prediction_in : IN STD_LOGIC;
        alu_flags_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        alu_result_1_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        alu_result_2_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        base_reg_data_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        imm_offset_in : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        reg_write_address_1_in : IN reg_idx_t;
        reg_write_address_2_in : IN reg_idx_t;
        next_pc_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);

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
        JMP_FLAG_SEL_OUT : OUT jmp_flag_sel_t;

        corrected_ccr_flags_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        branch_prediction_out : OUT STD_LOGIC;
        alu_flags_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        alu_result_1_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        alu_result_2_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        base_reg_data_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        imm_offset_out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        reg_write_address_1_out : OUT reg_idx_t;
        reg_write_address_2_out : OUT reg_idx_t;
        next_pc_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END ENTITY ex1_ex2_register;

ARCHITECTURE rtl OF ex1_ex2_register IS
BEGIN
    process (clk, reset)
    BEGIN
        if reset = '1' then
            -- Reset all outputs to default values
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
            JMP_FLAG_SEL_OUT <= (OTHERS => '0');
            
            corrected_ccr_flags_out <= (OTHERS => '0');
            branch_prediction_out <= '0';
            alu_flags_out <= (OTHERS => '0');
            alu_result_1_out <= (OTHERS => '0');
            alu_result_2_out <= (OTHERS => '0');
            base_reg_data_out <= (OTHERS => '0');
            imm_offset_out <= (OTHERS => '0');
            reg_write_address_1_out <= (OTHERS => '0');
            reg_write_address_2_out <= (OTHERS => '0');
            next_pc_out <= (OTHERS => '0');
        elsif rising_edge(clk) then
            -- Transfer inputs to outputs
            if FLUSH = '1' then
                -- If FLUSH is asserted, invalidate the outputs (set to default values)
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
                JMP_FLAG_SEL_OUT <= (OTHERS => '0');
                
                corrected_ccr_flags_out <= (OTHERS => '0');
                branch_prediction_out <= '0';
                alu_flags_out <= (OTHERS => '0');
                alu_result_1_out <= (OTHERS => '0');
                alu_result_2_out <= (OTHERS => '0');
                base_reg_data_out <= (OTHERS => '0');
                imm_offset_out <= (OTHERS => '0');
                reg_write_address_1_out <= (OTHERS => '0');
                reg_write_address_2_out <= (OTHERS => '0');
                next_pc_out <= (OTHERS => '0');
            else
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
                JMP_FLAG_SEL_OUT <= JMP_FLAG_SEL_IN;

                corrected_ccr_flags_out <= corrected_ccr_flags_in;
                branch_prediction_out <= branch_prediction_in;
                alu_flags_out <= alu_flags_in;
                alu_result_1_out <= alu_result_1_in;
                alu_result_2_out <= alu_result_2_in;
                base_reg_data_out <= base_reg_data_in;
                imm_offset_out <= imm_offset_in;
                reg_write_address_1_out <= reg_write_address_1_in;
                reg_write_address_2_out <= reg_write_address_2_in;
                next_pc_out <= next_pc_in;
            end if;
        end if;
    end process;

END ARCHITECTURE rtl;