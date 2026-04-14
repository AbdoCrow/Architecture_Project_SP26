LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE work.isa_defs_pkg.ALL;

ENTITY mem_wb_register IS
    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;

        UPDATE_FLAGS_IN : IN STD_LOGIC;
        OUTPUT_PORT_EN_IN : IN STD_LOGIC;
        REG_WB_EN_IN : IN STD_LOGIC;

        flag_wb_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        wb_data_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        reg_write_address_in : IN reg_idx_t;

        UPDATE_FLAGS_OUT : OUT STD_LOGIC;
        OUTPUT_PORT_EN_OUT : OUT STD_LOGIC;
        REG_WB_EN_OUT : OUT STD_LOGIC;

        flag_wb_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        wb_data_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        reg_write_address_out : OUT reg_idx_t
    );
END ENTITY mem_wb_register;

ARCHITECTURE rtl OF mem_wb_register IS
BEGIN
    -- Definition-only skeleton.
END ARCHITECTURE rtl;