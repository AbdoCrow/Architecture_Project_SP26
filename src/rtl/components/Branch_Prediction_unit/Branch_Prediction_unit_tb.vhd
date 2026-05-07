library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
USE work.isa_defs_pkg.ALL;

entity Branch_Prediciton_unit_tb is
end entity Branch_Prediciton_unit_tb;
architecture testbench of Branch_Prediciton_unit_tb is
    component Branch_Prediction_unit
    port (
        BRANCH_RESULT: in std_logic;
        COND_BRANCH: in std_logic;
        BRANCH_TAKEN: out std_logic;
        STATE_TEST : out STD_LOGIC_VECTOR (1 downto 0)
    );
    end component;
    signal BRANCH_RESULT : STD_LOGIC ;
    signal COND_BRANCH : STD_LOGIC ;
    signal BRANCH_TAKEN : STD_LOGIC ;
    signal STATE_TEST : STD_LOGIC_VECTOR (1 DOWNTO 0) ;
    SIGNAL COND_BRANCH_STOP : STD_LOGIC;
    begin
     uut: Branch_Prediction_unit
     port map (
        BRANCH_RESULT => BRANCH_RESULT,
        COND_BRANCH => COND_BRANCH,
        BRANCH_TAKEN => BRANCH_TAKEN,
        STATE_TEST => STATE_TEST
     );
     COND_BRANCH_process : process
    begin
        loop
            exit when COND_BRANCH_STOP = '1';
            COND_BRANCH <= '0';
            wait for 100 ps;
            exit when COND_BRANCH_STOP = '1';
            COND_BRANCH <= '1';
            wait for 100 ps;
        end loop;
        COND_BRANCH <= '0';
        wait;  
    end process COND_BRANCH_process;
    stimulus_process : process
    begin
        COND_BRANCH_STOP <= '0';
        BRANCH_RESULT <= '1';
        WAIT FOR 200 PS;
        BRANCH_RESULT <= '1';
        WAIT FOR 200 PS;
        BRANCH_RESULT <= '1';
        WAIT FOR 200 PS;  
        BRANCH_RESULT <= '0';
        WAIT FOR 200 PS;
        BRANCH_RESULT <= '0';
        WAIT FOR 200 PS;
        BRANCH_RESULT <= '0';
        WAIT FOR 200 PS;
        COND_BRANCH_STOP <= '1'; 
        WAIT;
    end process stimulus_process;
end testbench;