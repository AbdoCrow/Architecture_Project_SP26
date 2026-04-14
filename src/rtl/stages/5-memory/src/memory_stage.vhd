LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE work.isa_defs_pkg.ALL;

ENTITY memory_stage IS
    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;

        LOAD_FLAGS_IN : IN STD_LOGIC;
        PC_WRITE_EN_IN : IN STD_LOGIC;
        MEM_WRITE_SEL_IN : IN mem_write_sel_t;
        MEMW_IN : IN STD_LOGIC;
        MEMR_IN : IN STD_LOGIC;
        UPDATE_FLAGS_IN : IN STD_LOGIC;
        MEM_ADDRESS_SEL_IN : IN mem_address_sel_t;
        OUTPUT_PORT_EN_IN : IN STD_LOGIC;
        REG_WB_EN_IN : IN STD_LOGIC;

        corrected_ccr_flags_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        alu_flags_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        alu_result_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        mem_adr_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        interrupt_adr_in : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        reg_write_address_in : IN reg_idx_t;
        next_pc_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);

        UPDATE_FLAGS_OUT : OUT STD_LOGIC;
        OUTPUT_PORT_EN_OUT : OUT STD_LOGIC;
        REG_WB_EN_OUT : OUT STD_LOGIC;

        flag_wb_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        wb_data_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        reg_write_address_out : OUT reg_idx_t;
        pc_write_en_out : OUT STD_LOGIC;
        pc_write_data_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END ENTITY memory_stage;

ARCHITECTURE rtl OF memory_stage IS
BEGIN
    -- Definition-only skeleton.
END ARCHITECTURE rtl;