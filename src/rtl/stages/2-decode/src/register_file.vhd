LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY register_file IS
    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        write_en : IN STD_LOGIC;
        write_addr : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        write_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        read_addr_1 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        read_addr_2 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        read_data_1 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        read_data_2 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END ENTITY register_file;

ARCHITECTURE rtl OF register_file IS
BEGIN
    -- TODO: implement register file
END ARCHITECTURE rtl;