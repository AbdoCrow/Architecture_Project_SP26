LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY if_id_register IS
    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        stall : IN STD_LOGIC;
        flush : IN STD_LOGIC;
        pc_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        instruction_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        immediate_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        pc_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        instruction_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        immediate_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END ENTITY if_id_register;

ARCHITECTURE rtl OF if_id_register IS
BEGIN
    -- TODO: IF/ID latch with stall/flush behavior
END ARCHITECTURE rtl;