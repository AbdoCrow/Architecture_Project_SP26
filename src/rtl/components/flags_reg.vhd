LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY flags_reg IS
    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        flag_enable : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        flag_reset : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        flags_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        flags_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
    );
END ENTITY flags_reg;

ARCHITECTURE rtl OF flags_reg IS
BEGIN
    -- TODO: implement CCR/NZC storage and update
END ARCHITECTURE rtl;