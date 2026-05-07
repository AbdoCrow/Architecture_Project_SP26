library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
USE work.isa_defs_pkg.ALL;
entity Branch_Prediction_unit is
    port (
        clk : in std_logic;
        reset : in std_logic;
        BRANCH_RESULT: in std_logic;
        COND_BRANCH: in std_logic;
        BRANCH_TAKEN: out std_logic
    );
end entity Branch_Prediction_unit;

architecture rtl of Branch_Prediction_unit is
    -- Definition-only skeleton.
    type state_type is (STRONGLY_NOT_TAKEN, WEAKLY_NOT_TAKEN, WEAKLY_TAKEN, STRONGLY_TAKEN);
    signal state : state_type;
begin
    process (clk)
    begin
        if reset = '1' then
            state <= STRONGLY_NOT_TAKEN;
            BRANCH_TAKEN <= '0';
        elsif COND_BRANCH = '0' then
            state <= state; -- No change in state if not a conditional branch
            BRANCH_TAKEN <= '0'; -- Default to not taken for non-conditional branches
        elsif rising_edge(clk) then
        case state is
            when STRONGLY_NOT_TAKEN =>
                BRANCH_TAKEN <= '0';
                if BRANCH_RESULT = '1' then
                    state <= WEAKLY_NOT_TAKEN;
                else
                    state <= STRONGLY_NOT_TAKEN;
                end if ;
            when WEAKLY_NOT_TAKEN =>
                BRANCH_TAKEN <= '0';
                if BRANCH_RESULT = '1' then
                    state <= STRONGLY_TAKEN;
                else
                    state <= STRONGLY_NOT_TAKEN;
                end if ;
            when WEAKLY_TAKEN =>
                BRANCH_TAKEN <= '1';
                if BRANCH_RESULT = '1' then
                    state <= STRONGLY_TAKEN;
                else
                    state <= STRONGLY_NOT_TAKEN;
                end if ;
            when STRONGLY_TAKEN =>
                BRANCH_TAKEN <= '1';
                if BRANCH_RESULT = '1' then
                    state <= STRONGLY_TAKEN;
                else
                    state <= WEAKLY_TAKEN;
                end if ;
        end case;
        end if;
    end process;
end architecture rtl;   