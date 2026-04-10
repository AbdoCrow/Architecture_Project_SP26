LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY ex1_ex2_register IS
    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        flush : IN STD_LOGIC;
        alu_partial_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        operand_b_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        immediate_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        rd_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        ctrl_in : IN STD_LOGIC_VECTOR(47 DOWNTO 0);
        alu_partial_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        operand_b_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        immediate_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        rd_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        ctrl_out : OUT STD_LOGIC_VECTOR(47 DOWNTO 0)
    );
END ENTITY ex1_ex2_register;

ARCHITECTURE rtl OF ex1_ex2_register IS
BEGIN
    -- TODO: EX1 -> EX2 pipeline register implementation
END ARCHITECTURE rtl;