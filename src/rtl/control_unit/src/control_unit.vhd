LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY control_unit IS
    PORT (
        opcode : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        intr_in : IN STD_LOGIC;



        -- fetch_stall : OUT STD_LOGIC;
        -- decode_stall : OUT STD_LOGIC;
        -- decode_flush : OUT STD_LOGIC;
        -- ex1_flush : OUT STD_LOGIC;
        -- PC_EN : OUT STD_LOGIC;

        -- jump_type : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        -- jump_is_unconditional : OUT STD_LOGIC;
        -- uses_immediate_word : OUT STD_LOGIC;

        -- alu_op : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        -- alu_src_a_sel : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        -- alu_src_b_sel : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);

        -- wb_enable : OUT STD_LOGIC;
        -- wb_data_sel : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        -- out_port_enable : OUT STD_LOGIC;

        -- mem_read_enable : OUT STD_LOGIC;
        -- mem_write_enable : OUT STD_LOGIC;
        -- mem_addr_sel : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        -- mem_write_data_sel : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);

        -- sp_write_enable : OUT STD_LOGIC;
        -- is_push : OUT STD_LOGIC;

        -- ccr_enable : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        -- ccr_reset : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)

        ID_EX1_EN : OUT STD_LOGIC;
        LOAD_FLAGS : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        PC_WRITE_EN : OUT STD_LOGIC;
        MEM_WRITE_EN : OUT STD_LOGIC;
        MEM_WRITE_SEL : OUT STD_LOGIC;
        COND_BRANCH : OUT STD_LOGIC;
        HLT : OUT STD_LOGIC;
        SWAP_2ND_CYCLE : OUT STD_LOGIC;
        MEMW : OUT STD_LOGIC;
        MEMR : OUT STD_LOGIC;
        UPDATE_FLAGS : OUT STD_LOGIC;
        MEM_ADDRESS_SEL : OUT STD_LOGIC_VECTOR(1 DOWNTO 0); -- the size is a placeholder
        OUTPUT_PORT_EN : OUT STD_LOGIC;
        REG_WB_EN : OUT STD_LOGIC;
        ALU_INPUT_SEL : OUT STD_LOGIC_VECTOR(1 DOWNTO 0); 
        ALU_OP : OUT STD_LOGIC_VECTOR(2 DOWNTO 0); -- I think this will be vectort not sure
        JMP_FLAG_SEL : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        MULTICYCLE_SEL : OUT STD_LOGIC;
        PC_EN : OUT STD_LOGIC
    );
END ENTITY control_unit;

ARCHITECTURE rtl OF control_unit IS
BEGIN
    -- note any one still with null either means not don't or missing something
    process(opcode)
    begin
        case opcode is
            when "00000" => -- NOP
                ID_EX1_EN <= '0';
            when "00001" => -- HLT
                PC_EN<= '0';
                hlt <= '1';
            when "00010" => -- SETC
                UPDATE_FLAGS <= '1';
                LOAD_FLAGS <= LOAD_FLAGS OR "0100"; -- set carry flag
                null;
            when "00011" => -- NOT
                REG_WB_EN <= '1';
                UPDATE_FLAGS <= '1';
                null;
            when "00100" => -- INC
                UPDATE_FLAGS <= '1';
                REG_WB_EN <= '1';
                null;
            when "00101" => -- OUT
                REG_WB_EN <= '0';
                UPDATE_FLAGS <= '0';
                OUTPUT_PORT_EN <= '1';
                null;
            when "00110" => -- IN
                REG_WB_EN <= '1';
                UPDATE_FLAGS <= '0';
                ALU_INPUT_SEL <= "01"; -- select input port
                null;
            when "01000" => -- MOV
                REG_WB_EN <= '1';
                UPDATE_FLAGS <= '0';

                null;
            when "01001" => -- SWAP
            UPDATE_FLAGS <= '0';
            REG_WB_EN <= '1';
            MULTICYCLE_SEL <= '1';
                null;
            when "01010" => -- ADD
            UPDATE_FLAGS <= '1';
            REG_WB_EN <= '1';
            ALU_INPUT_SEL <= "00"; -- select register file 
                null;
            when "01011" => -- SUB
            UPDATE_FLAGS <= '1';
            REG_WB_EN <= '1';
            ALU_INPUT_SEL <= "00"; -- select register file
                null;
            when "01100" => -- AND
            UPDATE_FLAGS <= '1';
            REG_WB_EN <= '1';
            ALU_INPUT_SEL <= "00"; -- select register file
                null;
            when "01101" => -- IADD
            UPDATE_FLAGS <= '1';
            REG_WB_EN <= '1';
            ALU_INPUT_SEL <= "10"; -- select immediate value
                null;
            when "10000" => -- PUSH
                UPDATE_FLAGS <= '0';
                REG_WB_EN <= '0';
                MEMW <= '1';
                MEM_ADDRESS_SEL <= "10"; -- select stack pointer
                null;
            when "10001" => -- POP
                UPDATE_FLAGS <= '0';
                REG_WB_EN <= '1';
                MEMR <= '1';
                MEM_ADDRESS_SEL <= "11"; 
                null;
            when "10010" => -- LDM
                UPDATE_FLAGS <= '0';
                REG_WB_EN <= '1';
                ALU_INPUT_SEL <= "10"; -- select immediate value
                null;
            when "10011" => -- LDD
                REG_WB_EN <= '1';
                UPDATE_FLAGS <= '0';
                MEMR <= '1';
                MEM_ADDRESS_SEL <= "00"; -- select computed address
                null;
            when "10100" => -- STD
                REG_WB_EN <= '0';
                UPDATE_FLAGS <= '0';
                MEMW <= '1';
                MEM_ADDRESS_SEL <= "00"; -- select computed address
                null;
            when "11000" => -- JZ
                null;
            when "11001" => -- JN
                null;
            when "11010" => -- JC
                null;
            when "11011" => -- JMP
                null;
            when "11100" => -- CALL
                null;
            when "11101" => -- RET
                null;
            when "11110" => -- INT
                null;
            when "11111" => -- RTI
                null;
            when others =>
                null; -- default case for unimplemented opcodes
        end case;
    end process;

END ARCHITECTURE rtl;