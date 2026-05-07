LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.MATH_REAL.ALL;

ENTITY register_file IS
    PORT (
        clk : IN STD_LOGIC;
        RESET : IN STD_LOGIC;
        WRITE_ENABLE_1 : IN STD_LOGIC;
        write_addr_1 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        write_data_1 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        WRITE_ENABLE_2 : IN STD_LOGIC;
        write_addr_2 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        write_data_2 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        read_addr_1 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        read_addr_2 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        read_data_1 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        read_data_2 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END ENTITY register_file;

ARCHITECTURE rtl OF register_file IS
    TYPE reg_array IS ARRAY (0 TO 7) OF STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL registers : reg_array := (OTHERS => (OTHERS => '0'));
BEGIN
    PROCESS (clk, reset)
        BEGIN
            IF reset = '1' THEN
                registers <= (OTHERS => (OTHERS => '0'));
            ELSIF FALLING_EDGE(clk) THEN
                IF WRITE_ENABLE_1 = '1' THEN
                    registers(TO_INTEGER(UNSIGNED(write_addr_1))) <= write_data_1;
                END IF;
                IF WRITE_ENABLE_2 = '1' THEN
                    registers(TO_INTEGER(UNSIGNED(write_addr_2))) <= write_data_2;
                END IF;
            END IF;
    END PROCESS;

    read_data_1 <= registers(TO_INTEGER(UNSIGNED(read_addr_1)));
    read_data_2 <= registers(TO_INTEGER(UNSIGNED(read_addr_2)));
END ARCHITECTURE rtl;