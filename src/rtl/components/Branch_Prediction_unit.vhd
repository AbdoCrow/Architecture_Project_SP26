library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
USE work.isa_defs_pkg.ALL;
entity Branch_Prediction_unit is
    port (
       -- clk : in std_logic;
        BRANCH_RESULT: in std_logic;
        COND_BRANCH: in std_logic;
        BRANCH_TAKEN: out std_logic;
        STATE_TEST : OUT STD_LOGIC_VECTOR (1 DOWNTO 0) -- for testing/Debugging
    );
end entity Branch_Prediction_unit;

architecture rtl of Branch_Prediction_unit is
    -- Definition-only skeleton.
    type state_type is (STRONGLY_NOT_TAKEN, WEAKLY_NOT_TAKEN, WEAKLY_TAKEN, STRONGLY_TAKEN);
    signal state : state_type;
begin
    process (COND_BRANCH)
    begin
        if rising_edge(COND_BRANCH) then
        case state is
            when STRONGLY_NOT_TAKEN =>
            if BRANCH_RESULT = '1' then
                state <= WEAKLY_NOT_TAKEN;
            else
                state <= STRONGLY_NOT_TAKEN;
            end if ;
            when WEAKLY_NOT_TAKEN =>
             if BRANCH_RESULT = '1' then
                state <= WEAKLY_TAKEN;
            else
                state <= STRONGLY_NOT_TAKEN;
            end if ;
            when WEAKLY_TAKEN =>
             if BRANCH_RESULT = '1' then
                state <= STRONGLY_TAKEN;
            else
                state <= WEAKLY_NOT_TAKEN;
            end if ;
            when STRONGLY_TAKEN =>
             if BRANCH_RESULT = '1' then
                state <= STRONGLY_TAKEN;
            else
                state <= WEAKLY_TAKEN;
            end if ;
        end case;
        end if;
    end process;

    process (state)
    begin
        case state is
            when STRONGLY_NOT_TAKEN =>
                BRANCH_TAKEN <= '0';
            when WEAKLY_NOT_TAKEN => 
                BRANCH_TAKEN <= '0';
            when WEAKLY_TAKEN => 
                BRANCH_TAKEN <= '1';
            when STRONGLY_TAKEN => 
                BRANCH_TAKEN <= '1';
        end case;
    end process;
    with state select
        STATE_TEST <= "00" when STRONGLY_NOT_TAKEN,
                      "01" when WEAKLY_NOT_TAKEN,
                      "10" when WEAKLY_TAKEN,
                      "11" when STRONGLY_TAKEN;
end architecture rtl;   