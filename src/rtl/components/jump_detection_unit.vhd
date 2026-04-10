LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY jump_detection_unit IS
    PORT (
        ccr_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        jump_type : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        jump_is_taken : OUT STD_LOGIC
    );
END ENTITY jump_detection_unit;

ARCHITECTURE rtl OF jump_detection_unit IS
BEGIN
    -- TODO: evaluate branch conditions
END ARCHITECTURE rtl;