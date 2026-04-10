LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY writeback_stage IS
    PORT (
        ctrl_in : IN STD_LOGIC_VECTOR(47 DOWNTO 0);
        mem_data_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        alu_data_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        rd_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        wb_enable_out : OUT STD_LOGIC;
        wb_addr_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        wb_data_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        out_port_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END ENTITY writeback_stage;

ARCHITECTURE rtl OF writeback_stage IS
BEGIN
    -- TODO: write-back source selection and OUT instruction routing
END ARCHITECTURE rtl;