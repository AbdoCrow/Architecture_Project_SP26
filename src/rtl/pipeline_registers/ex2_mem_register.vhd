LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE work.isa_defs_pkg.ALL;

ENTITY ex2_mem_register IS
    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        enable : IN STD_LOGIC;

        LOAD_FLAGS_IN : IN STD_LOGIC;
        PC_WRITE_EN_IN : IN STD_LOGIC;
        MEM_WRITE_SEL_IN : IN mem_write_sel_t;
        MEMW_IN : IN STD_LOGIC;
        MEMR_IN : IN STD_LOGIC;
        UPDATE_FLAGS_IN : IN STD_LOGIC;
        MEM_ADDRESS_SEL_IN : IN mem_address_sel_t;
        OUTPUT_PORT_EN_IN : IN STD_LOGIC;
        REG_WB_EN_1_IN : IN STD_LOGIC;
        REG_WB_EN_2_IN : IN STD_LOGIC;

        corrected_ccr_flags_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        alu_flags_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        alu_result_1_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        alu_result_2_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        mem_adr_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        interrupt_adr_in : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        reg_write_address_1_in : IN reg_idx_t;
        reg_write_address_2_in : IN reg_idx_t;
        next_pc_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);

        LOAD_FLAGS_OUT : OUT STD_LOGIC;
        PC_WRITE_EN_OUT : OUT STD_LOGIC;
        MEM_WRITE_SEL_OUT : OUT mem_write_sel_t;
        MEMW_OUT : OUT STD_LOGIC;
        MEMR_OUT : OUT STD_LOGIC;
        UPDATE_FLAGS_OUT : OUT STD_LOGIC;
        MEM_ADDRESS_SEL_OUT : OUT mem_address_sel_t;
        OUTPUT_PORT_EN_OUT : OUT STD_LOGIC;
        REG_WB_EN_1_OUT : OUT STD_LOGIC;
        REG_WB_EN_2_OUT : OUT STD_LOGIC;

        corrected_ccr_flags_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        alu_flags_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        alu_result_1_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        alu_result_2_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        mem_adr_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        interrupt_adr_out : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        reg_write_address_1_out : OUT reg_idx_t;
        reg_write_address_2_out : OUT reg_idx_t;
        next_pc_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END ENTITY ex2_mem_register;

ARCHITECTURE rtl OF ex2_mem_register IS
BEGIN
    process (clk, reset)
    BEGIN
    IF reset = '1' THEN
        LOAD_FLAGS_OUT <= '0';
        PC_WRITE_EN_OUT <= '0';
        MEM_WRITE_SEL_OUT <= (OTHERS => '0');
        MEMW_OUT <= '0';
        MEMR_OUT <= '0';
        UPDATE_FLAGS_OUT <= '0';
        MEM_ADDRESS_SEL_OUT <= (OTHERS => '0');
        OUTPUT_PORT_EN_OUT <= '0';
        REG_WB_EN_1_OUT <= '0';
        REG_WB_EN_2_OUT <= '0';
        corrected_ccr_flags_out <= (OTHERS => '0');
        alu_flags_out <= (OTHERS => '0');
        alu_result_1_out <= (OTHERS => '0');
        alu_result_2_out <= (OTHERS => '0');
        mem_adr_out <= (OTHERS => '0');
        interrupt_adr_out <= (OTHERS => '0');
        reg_write_address_1_out <= (OTHERS => '0');
        reg_write_address_2_out <= (OTHERS => '0');
        next_pc_out <= (OTHERS => '0');
    ELSIF rising_edge(clk) THEN 
        IF enable = '1' THEN
            LOAD_FLAGS_OUT <= LOAD_FLAGS_IN;
            PC_WRITE_EN_OUT <= PC_WRITE_EN_IN;
            MEM_WRITE_SEL_OUT <= MEM_WRITE_SEL_IN;
            MEMW_OUT <= MEMW_IN;
            MEMR_OUT <= MEMR_IN;
            UPDATE_FLAGS_OUT <= UPDATE_FLAGS_IN;
            MEM_ADDRESS_SEL_OUT <= MEM_ADDRESS_SEL_IN;
            OUTPUT_PORT_EN_OUT <= OUTPUT_PORT_EN_IN;
            REG_WB_EN_1_OUT <= REG_WB_EN_1_IN;
            REG_WB_EN_2_OUT <= REG_WB_EN_2_IN;
            corrected_ccr_flags_out <= corrected_ccr_flags_in;
            alu_flags_out <= alu_flags_in;
            alu_result_1_out <= alu_result_1_in;
            alu_result_2_out <= alu_result_2_in;
            mem_adr_out <= mem_adr_in;
            interrupt_adr_out <= interrupt_adr_in;
            reg_write_address_1_out <= reg_write_address_1_in;
            reg_write_address_2_out <= reg_write_address_2_in;
            next_pc_out <= next_pc_in;
        END IF;
    END IF;
    END PROCESS;
END ARCHITECTURE rtl;