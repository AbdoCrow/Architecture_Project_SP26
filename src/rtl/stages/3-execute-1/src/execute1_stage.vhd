LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY execute1_stage IS
    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        read_data1_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        read_data2_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        immediate_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        ctrl_in : IN STD_LOGIC_VECTOR(47 DOWNTO 0);
        fwd_ex2_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        fwd_mem_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        fwd_wb_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        fwd_sel_a : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        fwd_sel_b : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        alu_partial_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        operand_b_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        ccr_candidate_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
    );
END ENTITY execute1_stage;

ARCHITECTURE rtl OF execute1_stage IS
BEGIN
    -- TODO: ALU operations and partial execute outputs
END ARCHITECTURE rtl;