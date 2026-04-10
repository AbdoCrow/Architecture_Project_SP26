LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY execute2_stage IS
    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        alu_partial_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        operand_b_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        immediate_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        ccr_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        ctrl_in : IN STD_LOGIC_VECTOR(47 DOWNTO 0);
        branch_taken_out : OUT STD_LOGIC;
        branch_target_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        mem_addr_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        store_data_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        alu_result_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END ENTITY execute2_stage;

ARCHITECTURE rtl OF execute2_stage IS
BEGIN
    -- TODO: branch resolution and effective address calculation (LDD/STD)
END ARCHITECTURE rtl;