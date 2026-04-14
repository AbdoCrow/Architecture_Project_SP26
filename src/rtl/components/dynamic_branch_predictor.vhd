LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY dynamic_branch_predictor IS
    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;

        fetch_pc : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        fetch_is_cond_branch : IN STD_LOGIC;
        fetch_is_uncond_branch : IN STD_LOGIC;

        PREDICTOR_UPDATE_EN : IN STD_LOGIC;
        update_pc : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        update_taken : IN STD_LOGIC;

        branch_prediction : OUT STD_LOGIC
    );
END ENTITY dynamic_branch_predictor;

ARCHITECTURE rtl OF dynamic_branch_predictor IS
BEGIN
    -- Definition-only skeleton.
    -- TODO: implement 2-bit dynamic predictor table update and lookup.
END ARCHITECTURE rtl;