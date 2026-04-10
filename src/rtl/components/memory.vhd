LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY memory IS
    GENERIC (
        DATA_WIDTH : INTEGER := 32;
        ADDR_WIDTH : INTEGER := 12;
        MEMORY_SIZE : INTEGER := 4096
    );
    PORT (
        clk : IN STD_LOGIC;
        address : IN STD_LOGIC_VECTOR(ADDR_WIDTH - 1 DOWNTO 0);
        write_data : IN STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
        read_data : OUT STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
        read_en : IN STD_LOGIC;
        write_en : IN STD_LOGIC
    );
END ENTITY memory;

ARCHITECTURE rtl OF memory IS
BEGIN
    -- TODO: implement unified memory model (program + data)
    -- TODO: initialize PC reset vector from memory location 0
    -- TODO: support interrupt vector at memory location 1
END ARCHITECTURE rtl;