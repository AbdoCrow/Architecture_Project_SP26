library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
USE work.isa_defs_pkg.ALL;

entity control_unit_tb is
end entity control_unit_tb;
architecture testbench of control_unit_tb is
signal clk : std_logic := '0';
signal reset : std_logic := '0';
signal stop_clk : std_logic := '0';
signal intr_in : std_logic := '0';
--signal instr : std_logic_vector(31 downto 0) := (others => '0');
signal opcode : opcode_t := (others => '0');
signal FETCH_STALL : std_logic;
signal DECODE_STALL : std_logic;
signal DECODE_FLUSH : std_logic;
signal EX1_FLUSH : std_logic;
signal PC_ENABLE : std_logic;
signal LOAD_FLAGS : std_logic;
signal PC_WRITE_EN : std_logic;
signal MEM_WRITE_SEL : mem_write_sel_t;
signal COND_BRANCH : std_logic;
signal HLT : std_logic;
signal MEMW : std_logic;
signal MEMR : std_logic;
signal REG_WB_EN : std_logic;
signal UPDATE_FLAGS : std_logic;
signal ALU_OP : alu_op_t;
signal ALU_INPUT_SEL : alu_input_sel_t;
signal JMP_FLAG_SEL : jmp_flag_sel_t;
signal OUTPUT_PORT_EN : std_logic;
signal MEM_ADDRESS_SEL : mem_address_sel_t;
signal SWAP_2ND_CYCLE : std_logic;
signal MULTICYCLE_STALL : std_logic;
signal MULTICYCLE_SEL : multicycle_sel_t;
component control_unit
  PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        intr_in : IN STD_LOGIC;
        --instr : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        opcode : IN opcode_t;

        FETCH_STALL : OUT STD_LOGIC;
        DECODE_STALL : OUT STD_LOGIC;
        DECODE_FLUSH : OUT STD_LOGIC;
        EX1_FLUSH : OUT STD_LOGIC;
        PC_ENABLE : OUT STD_LOGIC;

        LOAD_FLAGS : OUT STD_LOGIC;
        PC_WRITE_EN : OUT STD_LOGIC;
        MEM_WRITE_SEL : OUT mem_write_sel_t;
        COND_BRANCH : OUT STD_LOGIC;
        HLT : OUT STD_LOGIC;
        MEMW : OUT STD_LOGIC;
        MEMR : OUT STD_LOGIC;
        REG_WB_EN : OUT STD_LOGIC;
        UPDATE_FLAGS : OUT STD_LOGIC;
        ALU_OP : OUT alu_op_t;
        ALU_INPUT_SEL : OUT alu_input_sel_t;
        JMP_FLAG_SEL : OUT jmp_flag_sel_t;
        OUTPUT_PORT_EN : OUT STD_LOGIC;
        MEM_ADDRESS_SEL : OUT mem_address_sel_t;
        SWAP_2ND_CYCLE : OUT STD_LOGIC;
        MULTICYCLE_STALL : OUT STD_LOGIC;
        MULTICYCLE_SEL : OUT multicycle_sel_t
    );


end component control_unit;
begin
    uut: control_unit
        port map (
            clk => clk,
            reset => reset,
            intr_in => intr_in,
            --instr => instr,
            opcode => opcode,

            FETCH_STALL => FETCH_STALL,
            DECODE_STALL => DECODE_STALL,
            DECODE_FLUSH => DECODE_FLUSH,
            EX1_FLUSH => EX1_FLUSH,
            PC_ENABLE => PC_ENABLE,

            LOAD_FLAGS => LOAD_FLAGS,
            PC_WRITE_EN => PC_WRITE_EN,
            MEM_WRITE_SEL => MEM_WRITE_SEL,
            COND_BRANCH => COND_BRANCH,
            HLT => HLT,
            MEMW => MEMW,
            MEMR => MEMR,
            REG_WB_EN => REG_WB_EN,
            UPDATE_FLAGS => UPDATE_FLAGS,
            ALU_OP => ALU_OP,
            ALU_INPUT_SEL => ALU_INPUT_SEL,
            JMP_FLAG_SEL => JMP_FLAG_SEL,
            OUTPUT_PORT_EN => OUTPUT_PORT_EN,
            MEM_ADDRESS_SEL => MEM_ADDRESS_SEL,
            SWAP_2ND_CYCLE => SWAP_2ND_CYCLE,
            MULTICYCLE_STALL => MULTICYCLE_STALL,
            MULTICYCLE_SEL => MULTICYCLE_SEL
        );
    clk_process : process
    begin
        while stop_clk = '0' loop
            clk <= '0';
            wait for 100 ps;
            clk <= '1';
            wait for 100 ps;
        end loop;
        clk <= '0';
        wait;  -- Hold final clock state
    end process clk_process;
    stimulus_process : process
    begin
        reset <= '1';
        wait for 200 ps;
        reset <= '0';
        wait for 200 ps;
        opcode <= OPCODE_NOP;
        wait for 200 ps;
        opcode <= OPCODE_HLT;
        wait for 200 ps;
        opcode <= OPCODE_SETC;
        wait for 200 ps;
        opcode <= OPCODE_NOT;
        wait for 200 ps;
        opcode <= OPCODE_INC;
        wait for 200 ps;
        opcode <= OPCODE_OUT;
        wait for 200 ps;
        opcode <= OPCODE_IN;
        wait for 200 ps;
        opcode <= OPCODE_MOV;
        wait for 200 ps;
        opcode <= OPCODE_SWAP;
        wait for 200 ps;
        opcode <= OPCODE_ADD;
        wait for 200 ps;
        opcode <= OPCODE_SUB;
        wait for 200 ps;
        opcode <= OPCODE_AND;
        wait for 200 ps;
        opcode <= OPCODE_IADD;
        wait for 200 ps;
        opcode <= OPCODE_PUSH;
        wait for 200 ps;
        opcode <= OPCODE_POP;
        wait for 200 ps;
        opcode <= OPCODE_LDM;
        wait for 200 ps;
        opcode <= OPCODE_LDD;
        wait for 200 ps;
        opcode <= OPCODE_STD;
        wait for 200 ps;
        opcode <= OPCODE_JZ;
        wait for 200 ps;
        opcode <= OPCODE_JN;
        wait for 200 ps;
        opcode <= OPCODE_JC;
        wait for 200 ps;
        opcode <= OPCODE_JMP;
        wait for 200 ps;
        opcode <= OPCODE_CALL;
        wait for 200 ps;
        opcode <= OPCODE_RET;
        wait for 200 ps;
        opcode <= OPCODE_INT;
        wait for 200 ps;
        opcode <= OPCODE_RTI;   
        wait for 200 ps;
        opcode <= OPCODE_SWAP2;
        wait for 200 ps;
        opcode <= OPCODE_INT2;
        wait for 200 ps;
        opcode <= OPCODE_INT3;
        wait for 200 ps;
        stop_clk <= '1';  -- Stop clock after stimulus
        wait;
    end process stimulus_process;
end architecture testbench;