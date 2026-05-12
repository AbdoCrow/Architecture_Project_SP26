LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE work.isa_defs_pkg.ALL;

ENTITY memory_tb IS
END memory_tb;

ARCHITECTURE behavior OF memory_tb IS 
Signal clk : std_logic := '0';
Signal reset : std_logic := '0';
Signal intr_in : std_logic := '0';
Signal in_port  : std_logic_vector(31 downto 0) := (others => '0');

signal out_port : std_logic_vector(31 downto 0);
Signal PC_monitor : std_logic_vector(31 downto 0);
Signal SP_monitor : std_logic_vector(31 downto 0);
Signal CCR_monitor : std_logic_vector(2 downto 0);
Signal r0_monitor : std_logic_vector(31 downto 0);
Signal r1_monitor : std_logic_vector(31 downto 0);
Signal r2_monitor : std_logic_vector(31 downto 0);
Signal r3_monitor : std_logic_vector(31 downto 0);
Signal r4_monitor : std_logic_vector(31 downto 0);
Signal r5_monitor : std_logic_vector(31 downto 0);
Signal r6_monitor : std_logic_vector(31 downto 0);
Signal r7_monitor : std_logic_vector(31 downto 0);

Constant clk_period : time := 10 ns;
procedure check_signal (
    signal actual   : in std_logic_vector;
    constant expected : in std_logic_vector;
    constant msg      : in string
) is
begin
    assert actual = expected
    report msg &
            " Expected = " & integer'image(to_integer(unsigned(expected))) &
            " Actual = " & integer'image(to_integer(unsigned(actual)))
    severity error;
end procedure;
procedure drive_input_at_pc (
    signal pc_sig       : in std_logic_vector(31 downto 0);
    signal in_port_sig  : out std_logic_vector(31 downto 0);

    constant target_pc  : in std_logic_vector(31 downto 0);
    constant value      : in std_logic_vector(31 downto 0)
) is
begin
    wait until pc_sig = target_pc;

    in_port_sig <= value;

    report "Driving input port at PC = " & integer'image(to_integer(unsigned(target_pc)));
end procedure;
BEGIN
clk_process :process
begin
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
end process;

uut: Entity work.processor
    Port Map (
        clk => clk,
        reset => reset,
        intr_in => intr_in,
        in_port => in_port,
        out_port => out_port,
        PC_monitor => PC_monitor,
        SP_monitor => SP_monitor,
        CCR_monitor => CCR_monitor,
        r0_monitor => r0_monitor,
        r1_monitor => r1_monitor,
        r2_monitor => r2_monitor,
        r3_monitor => r3_monitor,
        r4_monitor => r4_monitor,
        r5_monitor => r5_monitor,
        r6_monitor => r6_monitor,
        r7_monitor => r7_monitor
    );
reset_process: process
begin
    reset <= '1';
    wait for clk_period;
    reset <= '0';
    wait;
end process;
stimulus_process: process
begin
    drive_input_at_pc(PC_monitor, in_port, x"00000300", x"00000019");  -- Load 19 into r2
    drive_input_at_pc(PC_monitor, in_port, x"00000301", x"FFFFFFFF");  -- Load -1 into r3
    drive_input_at_pc(PC_monitor, in_port, x"00000302", x"FFFFF320");  -- Load  into r4
    drive_input_at_pc(PC_monitor, in_port, x"00000309", x"00000010");  -- Load 10 into r5
    drive_input_at_pc(PC_monitor, in_port, x"00000310", x"00000019");  -- Load 19 into r2
end process;
END behavior;