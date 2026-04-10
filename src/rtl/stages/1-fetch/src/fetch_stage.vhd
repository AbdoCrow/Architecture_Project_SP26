LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY fetch_stage IS
    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        pc_enable : IN STD_LOGIC;
        imm_follows : IN STD_LOGIC;
        predicted_taken_in : IN STD_LOGIC;
        resolved_taken_in : IN STD_LOGIC;
        jump_target_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        return_pc_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        pc_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        next_pc_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        instr_address_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END ENTITY fetch_stage;

ARCHITECTURE rtl OF fetch_stage IS
BEGIN
    -- TODO: implement PC source mux and next-PC generation
    -- TODO: add static branch prediction selection at fetch time
END ARCHITECTURE rtl;