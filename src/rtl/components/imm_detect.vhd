LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY imm_detect IS
    PORT (
        instruction : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        imm_follows : OUT STD_LOGIC
    );
END ENTITY imm_detect;

ARCHITECTURE rtl OF imm_detect IS
BEGIN
    -- TODO: decode instructions requiring immediate-follow word
END ARCHITECTURE rtl;