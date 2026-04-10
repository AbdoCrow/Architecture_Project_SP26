LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY control_unit IS
    PORT (
        opcode : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        intr_in : IN STD_LOGIC;

        fetch_stall : OUT STD_LOGIC;
        decode_stall : OUT STD_LOGIC;
        decode_flush : OUT STD_LOGIC;
        ex1_flush : OUT STD_LOGIC;
        pc_enable : OUT STD_LOGIC;

        jump_type : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        jump_is_unconditional : OUT STD_LOGIC;
        uses_immediate_word : OUT STD_LOGIC;

        alu_op : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        alu_src_a_sel : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        alu_src_b_sel : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);

        wb_enable : OUT STD_LOGIC;
        wb_data_sel : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        out_port_enable : OUT STD_LOGIC;

        mem_read_enable : OUT STD_LOGIC;
        mem_write_enable : OUT STD_LOGIC;
        mem_addr_sel : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        mem_write_data_sel : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);

        sp_write_enable : OUT STD_LOGIC;
        is_push : OUT STD_LOGIC;

        ccr_enable : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        ccr_reset : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
    );
END ENTITY control_unit;

ARCHITECTURE rtl OF control_unit IS
BEGIN
    -- TODO: opcode mapping for full ISA
    -- TODO: control bundles for 6-stage pipeline
    -- TODO: multi-cycle sequencing for INT, RTI, CALL, RET, SWAP
END ARCHITECTURE rtl;