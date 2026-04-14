LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY if_id_register IS
    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        STALL : IN STD_LOGIC;
        FLUSH : IN STD_LOGIC;

        instr_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        next_pc_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        branch_prediction_in : IN STD_LOGIC;

        instr_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        next_pc_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        branch_prediction_out : OUT STD_LOGIC
    );
END ENTITY if_id_register;

ARCHITECTURE rtl OF if_id_register IS
BEGIN
    -- Definition-only skeleton.
END ARCHITECTURE rtl;