LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY pc_reg IS
    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        enable : IN STD_LOGIC;
        pc_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        pc_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END ENTITY pc_reg;

ARCHITECTURE rtl OF pc_reg IS
BEGIN
    -- TODO: implement PC register behavior
END ARCHITECTURE rtl;