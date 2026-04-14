LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE work.isa_defs_pkg.ALL;

ENTITY processor IS
    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        intr_in : IN STD_LOGIC;
        in_port : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        out_port : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);

        pc_monitor : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        sp_monitor : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        ccr_monitor : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        r0_monitor : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        r1_monitor : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        r2_monitor : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        r3_monitor : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        r4_monitor : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        r5_monitor : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        r6_monitor : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        r7_monitor : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END ENTITY processor;

ARCHITECTURE rtl OF processor IS
BEGIN
    -- TODO: integrate 6 stages
    -- Fetch -> Decode -> Execute-1 -> Execute-2 -> Memory -> Write-Back
    -- TODO: integrate IF/ID, ID/EX1, EX1/EX2, EX2/MEM, MEM/WB pipeline registers
    -- TODO: integrate control unit, forwarding unit, hazard control, dynamic branch predictor
    -- TODO: use internal opcodes OPCODE_SWAP2 / OPCODE_INT2 / OPCODE_INT3 in decode-injected flow
    -- TODO: connect unified memory path for instruction fetch + data memory operations
END ARCHITECTURE rtl;