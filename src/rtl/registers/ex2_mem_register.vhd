LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY ex2_mem_register IS
    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        flush : IN STD_LOGIC;
        alu_result_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        branch_taken_in : IN STD_LOGIC;
        branch_target_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        store_data_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        rd_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        ctrl_in : IN STD_LOGIC_VECTOR(47 DOWNTO 0);
        alu_result_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        branch_taken_out : OUT STD_LOGIC;
        branch_target_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        store_data_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        rd_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        ctrl_out : OUT STD_LOGIC_VECTOR(47 DOWNTO 0)
    );
END ENTITY ex2_mem_register;

ARCHITECTURE rtl OF ex2_mem_register IS
BEGIN
    -- TODO: EX2 -> MEM pipeline register implementation
END ARCHITECTURE rtl;