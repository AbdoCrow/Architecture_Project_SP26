LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY id_ex1_register IS
    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        flush : IN STD_LOGIC;
        read_data1_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        read_data2_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        immediate_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        rs1_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        rs2_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        rd_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        ctrl_in : IN STD_LOGIC_VECTOR(47 DOWNTO 0);
        read_data1_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        read_data2_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        immediate_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        rs1_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        rs2_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        rd_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        ctrl_out : OUT STD_LOGIC_VECTOR(47 DOWNTO 0)
    );
END ENTITY id_ex1_register;

ARCHITECTURE rtl OF id_ex1_register IS
BEGIN
    -- TODO: ID -> EX1 pipeline register implementation
END ARCHITECTURE rtl;