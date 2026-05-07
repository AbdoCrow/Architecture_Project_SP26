LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY if_id_register IS
    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        enable : IN STD_LOGIC;

        instr_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        next_pc_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        branch_prediction_in : IN STD_LOGIC;

        instr_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        next_pc_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        branch_prediction_out : OUT STD_LOGIC
    );
END ENTITY if_id_register;

ARCHITECTURE rtl OF if_id_register IS
BEGIN
    PROCESS (clk, reset)
    BEGIN
        IF reset = '1' THEN
            instr_out <= (OTHERS => '0');
            next_pc_out <= (OTHERS => '0');
            branch_prediction_out <= '0';
        ELSIF rising_edge(clk) THEN
            IF enable = '1' THEN
                instr_out <= instr_in;
                next_pc_out <= next_pc_in;
                branch_prediction_out <= branch_prediction_in;
            END IF;
        END IF;
    END PROCESS;
END ARCHITECTURE rtl;