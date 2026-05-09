LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE work.isa_defs_pkg.ALL;

ENTITY mem_wb_register IS
    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;

        UPDATE_FLAGS_IN : IN STD_LOGIC;
        OUTPUT_PORT_EN_IN : IN STD_LOGIC;
        REG_WB_EN_1_IN : IN STD_LOGIC;
        REG_WB_EN_2_IN : IN STD_LOGIC;

        flag_wb_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        wb_data_1_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        wb_data_2_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        reg_write_address_1_in : IN reg_idx_t;
        reg_write_address_2_in : IN reg_idx_t;

        UPDATE_FLAGS_OUT : OUT STD_LOGIC;
        OUTPUT_PORT_EN_OUT : OUT STD_LOGIC;
        REG_WB_EN_1_OUT : OUT STD_LOGIC;
        REG_WB_EN_2_OUT : OUT STD_LOGIC;

        flag_wb_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        wb_data_1_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        wb_data_2_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        reg_write_address_1_out : OUT reg_idx_t;
        reg_write_address_2_out : OUT reg_idx_t
    );
END ENTITY mem_wb_register;

ARCHITECTURE rtl OF mem_wb_register IS
BEGIN
    PROCESS (clk, reset)
    BEGIN
        IF reset = '1' THEN
            UPDATE_FLAGS_OUT <= '0';
            OUTPUT_PORT_EN_OUT <= '0';
            REG_WB_EN_1_OUT <= '0';
            REG_WB_EN_2_OUT <= '0';
            flag_wb_out <= (OTHERS => '0');
            wb_data_1_out <= (OTHERS => '0');
            wb_data_2_out <= (OTHERS => '0');
            reg_write_address_1_out <= (OTHERS => '0');
            reg_write_address_2_out <= (OTHERS => '0');
        ELSIF rising_edge(clk) THEN
            UPDATE_FLAGS_OUT <= UPDATE_FLAGS_IN;
            OUTPUT_PORT_EN_OUT <= OUTPUT_PORT_EN_IN;
            REG_WB_EN_1_OUT <= REG_WB_EN_1_IN;
            REG_WB_EN_2_OUT <= REG_WB_EN_2_IN;
            flag_wb_out <= flag_wb_in;
            wb_data_1_out <= wb_data_1_in;
            wb_data_2_out <= wb_data_2_in;
            reg_write_address_1_out <= reg_write_address_1_in;
            reg_write_address_2_out <= reg_write_address_2_in;
        END IF;
    END PROCESS;
END ARCHITECTURE rtl;