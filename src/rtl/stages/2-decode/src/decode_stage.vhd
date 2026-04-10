LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY decode_stage IS
    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        intr_in : IN STD_LOGIC;
        instruction_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        imm_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        wb_addr_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        wb_data_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        wb_en_in : IN STD_LOGIC;
        rs1_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        rs2_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        rd_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        read_data1_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        read_data2_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        ctrl_out : OUT STD_LOGIC_VECTOR(47 DOWNTO 0);
        predicted_taken_out : OUT STD_LOGIC
    );
END ENTITY decode_stage;

ARCHITECTURE rtl OF decode_stage IS
BEGIN
    -- TODO: instruction decode + control distribution + regfile access
END ARCHITECTURE rtl;