LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE work.isa_defs_pkg.ALL;

ENTITY writeback_stage IS
    PORT (
        UPDATE_FLAGS_IN : IN STD_LOGIC;
        OUTPUT_PORT_EN_IN : IN STD_LOGIC;
        REG_WB_EN_IN : IN STD_LOGIC;

        flag_wb_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        wb_data_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        reg_write_address_in : IN reg_idx_t;

        REG_WB_EN_OUT : OUT STD_LOGIC;
        wb_addr_out : OUT reg_idx_t;
        wb_data_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        flags_write_en_out : OUT STD_LOGIC;
        flags_data_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        OUTPUT_PORT_EN_OUT : OUT STD_LOGIC;
        out_port_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END ENTITY writeback_stage;

ARCHITECTURE rtl OF writeback_stage IS
BEGIN
    -- Definition-only skeleton.
END ARCHITECTURE rtl;