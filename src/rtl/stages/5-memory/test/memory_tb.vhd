library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
entity memory_tb is
end entity memory_tb;
architecture testbench of memory_tb is
    signal clk : std_logic := '0';
    signal reset : std_logic := '0';
    signal mem_addr_in : std_logic_vector(11 downto 0);
    signal mem_data_in : std_logic_vector(31 downto 0);
    signal mem_data_out : std_logic_vector(31 downto 0);
    signal MEMORY_READ_EN : std_logic := '0';
    signal MEMORY_WRITE_EN : std_logic := '0';

    component memory
        generic (
            DATA_WIDTH : integer := 32;
            ADDR_WIDTH : integer := 12;
            MEMORY_SIZE : integer := 4096
        );
        port (
            clk : in std_logic;
            mem_addr : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
            mem_data_in : in std_logic_vector(DATA_WIDTH - 1 downto 0);
            mem_data_out : out std_logic_vector(DATA_WIDTH - 1 downto 0);
            MEMORY_READ_EN : in std_logic;
            MEMORY_WRITE_EN : in std_logic
        );
    end component memory;
begin
    uut: memory
        port map (
            clk => clk,
            mem_addr => mem_addr_in,
            mem_data_in => mem_data_in,
            mem_data_out => mem_data_out,
            MEMORY_READ_EN => MEMORY_READ_EN,
            MEMORY_WRITE_EN => MEMORY_WRITE_EN
        );
    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for 100 ps;
            clk <= '1';
            wait for 100 ps;
        end loop;
    end process clk_process;
    stimulus_process : process
    begin
        -- Test case 1: Write to memory and read back
        mem_addr_in <= x"000"; -- Address 0
        mem_data_in <= x"12345678"; -- Data to write
        MEMORY_WRITE_EN <= '1';
        wait for 200 ps;
        MEMORY_WRITE_EN <= '0';
        wait for 200 ps;
        MEMORY_READ_EN <= '1';
        wait for 200 ps;
        MEMORY_READ_EN <= '0';
        wait for 200 ps;

        -- Test case 2: Write to another address and read back
        mem_addr_in <= x"001"; -- Address 1
        mem_data_in <= x"87654321"; -- Data to write
        MEMORY_WRITE_EN <= '1';
        wait for 200 ps;
        MEMORY_WRITE_EN <= '0';
        wait for 200 ps;
        MEMORY_READ_EN <= '1';
        wait for 200 ps;
        MEMORY_READ_EN <= '0';
        wait for 200 ps;

        -- End simulation
        wait;
    end process stimulus_process;
end architecture testbench;
