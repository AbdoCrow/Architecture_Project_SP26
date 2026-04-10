LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY sp_unit IS
    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        sp_write_en : IN STD_LOGIC;
        is_push : IN STD_LOGIC;
        sp_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END ENTITY sp_unit;

ARCHITECTURE rtl OF sp_unit IS
BEGIN
    -- TODO: implement stack pointer update policy
    -- TODO: initialize SP to (2^12 - 1)
END ARCHITECTURE rtl;