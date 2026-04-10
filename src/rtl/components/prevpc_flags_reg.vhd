LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY prevpc_flags_reg IS
    PORT (
        clk : IN STD_LOGIC;
        save_enable : IN STD_LOGIC;
        pc_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        flags_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        packed_out : OUT STD_LOGIC_VECTOR(34 DOWNTO 0)
    );
END ENTITY prevpc_flags_reg;

ARCHITECTURE rtl OF prevpc_flags_reg IS
BEGIN
    -- TODO: capture previous PC and flags for INT/CALL handling
END ARCHITECTURE rtl;