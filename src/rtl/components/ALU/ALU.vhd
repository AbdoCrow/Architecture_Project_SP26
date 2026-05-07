LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE work.isa_defs_pkg.ALL;
ENTITY ALU IS
    PORT (
        A       : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
        B       : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
        prev_flags : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
        output_flags : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        ALUOp   : IN  ALU_OP_TYPE;
        Result1  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        Result2  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END ALU;
ARCHITECTURE Behavioral OF ALU IS
BEGIN
END Behavioral;