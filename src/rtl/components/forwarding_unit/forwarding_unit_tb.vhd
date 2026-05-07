LIBRARY ieee;
USE ieee.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.isa_defs_pkg.ALL;
ENTITY forwarding_unit_tb IS
END ENTITY;

ARCHITECTURE tb OF forwarding_unit_tb IS
    CONSTANT CLK_PERIOD : time := 10 ns;
    --------------------------------------------------------------------
    -- DUT Signals
    --------------------------------------------------------------------
    SIGNAL read_reg_1 : reg_idx_t := (OTHERS => '0');
    SIGNAL read_reg_2 : reg_idx_t := (OTHERS => '0');
    SIGNAL EX1_UPDATE_FLAGS : STD_LOGIC := '0';
    SIGNAL EX2_UPDATE_FLAGS : STD_LOGIC := '0';
    SIGNAL MEM_UPDATE_FLAGS : STD_LOGIC := '0';
    SIGNAL EX1_REG_WRITE_EN_1 : STD_LOGIC := '0';
    SIGNAL EX1_REG_WRITE_EN_2 : STD_LOGIC := '0';
    SIGNAL EX1_WRITE_ADDRESS_1 : reg_idx_t := (OTHERS => '0');
    SIGNAL EX1_WRITE_ADDRESS_2 : reg_idx_t := (OTHERS => '0');
    SIGNAL EX2_REG_WRITE_EN_1: STD_LOGIC := '0';
    SIGNAL EX2_REG_WRITE_EN_2: STD_LOGIC := '0';
    SIGNAL EX2_WRITE_ADDRESS_1 : reg_idx_t := (OTHERS => '0');
    SIGNAL EX2_WRITE_ADDRESS_2 : reg_idx_t := (OTHERS => '0');
    SIGNAL MEM_REG_WRITE_EN_1 : STD_LOGIC := '0';
    SIGNAL MEM_REG_WRITE_EN_2 : STD_LOGIC := '0';
    SIGNAL MEM_WRITE_ADDRESS_1 : reg_idx_t := (OTHERS => '0');
    SIGNAL MEM_WRITE_ADDRESS_2 : reg_idx_t := (OTHERS => '0');
    SIGNAL FLAG_SRC_SEL : flag_src_sel_t;
    SIGNAL RSRC1_SEL : fwd_sel_t;
    SIGNAL RSRC2_SEL : fwd_sel_t;
BEGIN

    --------------------------------------------------------------------
    -- DUT Instantiation
    --------------------------------------------------------------------
    DUT : ENTITY work.forwarding_unit
        PORT MAP (
            read_reg_1 => read_reg_1,
            read_reg_2 => read_reg_2,
            EX1_UPDATE_FLAGS => EX1_UPDATE_FLAGS,
            EX2_UPDATE_FLAGS => EX2_UPDATE_FLAGS,
            MEM_UPDATE_FLAGS => MEM_UPDATE_FLAGS,
            EX1_REG_WRITE_EN_1 => EX1_REG_WRITE_EN_1,
            EX1_REG_WRITE_EN_2 => EX1_REG_WRITE_EN_2,
            EX1_WRITE_ADDRESS_1 => EX1_WRITE_ADDRESS_1,
            EX1_WRITE_ADDRESS_2 => EX1_WRITE_ADDRESS_2,
            EX2_REG_WRITE_EN_1 => EX2_REG_WRITE_EN_1,
            EX2_REG_WRITE_EN_2 => EX2_REG_WRITE_EN_2,
            EX2_WRITE_ADDRESS_1 => EX2_WRITE_ADDRESS_1,
            EX2_WRITE_ADDRESS_2 => EX2_WRITE_ADDRESS_2,
            MEM_REG_WRITE_EN_1 => MEM_REG_WRITE_EN_1,
            MEM_REG_WRITE_EN_2 => MEM_REG_WRITE_EN_2,
            MEM_WRITE_ADDRESS_1 => MEM_WRITE_ADDRESS_1,
            MEM_WRITE_ADDRESS_2 => MEM_WRITE_ADDRESS_2,
            FLAG_SRC_SEL => FLAG_SRC_SEL,
            RSRC1_SEL => RSRC1_SEL,
            RSRC2_SEL => RSRC2_SEL
        );


    --------------------------------------------------------------------
    -- Stimulus Process
    --------------------------------------------------------------------
    stim_process : PROCESS
        -- Helper procedure for checkiing read data
        PROCEDURE check_selected_sources(src1_expected: fwd_sel_t; src2_expected: fwd_sel_t; src_flag_expected: flag_src_sel_t) IS
        BEGIN
            ASSERT RSRC1_SEL = src1_expected
                REPORT "RSRC1_SEL value mismatch: expected " & integer'image(to_integer(unsigned(src1_expected))) &
                       ", got " & integer'image(to_integer(unsigned(RSRC1_SEL)))
                SEVERITY error;
            ASSERT RSRC2_SEL = src2_expected
                REPORT "RSRC2_SEL value mismatch: expected " & integer'image(to_integer(unsigned(src2_expected))) &
                       ", got " & integer'image(to_integer(unsigned(RSRC2_SEL)))
                SEVERITY error;
            ASSERT FLAG_SRC_SEL = src_flag_expected
                REPORT "FLAG_SRC_SEL value mismatch: expected " & integer'image(to_integer(unsigned(src_flag_expected))) &
                       ", got " & integer'image(to_integer(unsigned(FLAG_SRC_SEL)))
                SEVERITY error;
        END PROCEDURE;  
    BEGIN
        -- Test 1: No hazards, should select from register file
        read_reg_1 <= "101"; -- r5
        read_reg_2 <= "010"; -- r2
        EX1_UPDATE_FLAGS <= '0';
        EX2_UPDATE_FLAGS <= '0';
        MEM_UPDATE_FLAGS <= '0';
        EX1_REG_WRITE_EN_1 <= '0';
        EX1_REG_WRITE_EN_2 <= '0';
        EX2_REG_WRITE_EN_1 <= '0';
        EX2_REG_WRITE_EN_2 <= '0';
        MEM_REG_WRITE_EN_1 <= '0';
        MEM_REG_WRITE_EN_2 <= '0';
        EX1_WRITE_ADDRESS_1 <= "000"; -- r0
        EX1_WRITE_ADDRESS_2 <= "000"; -- r0
        EX2_WRITE_ADDRESS_1 <= "000"; -- r0
        EX2_WRITE_ADDRESS_2 <= "000"; -- r0
        MEM_WRITE_ADDRESS_1 <= "000"; -- r0
        MEM_WRITE_ADDRESS_2 <= "000"; -- r0
        WAIT FOR CLK_PERIOD;
        check_selected_sources(FWD_FROM_REGFILE, FWD_FROM_REGFILE, FLAG_FROM_REGFILE);

        -- Test 2: EX1 is writing to r5, should forward to src1
        read_reg_1 <= "101"; -- r5
        read_reg_2 <= "010"; -- r2
        EX1_UPDATE_FLAGS <= '0';
        EX2_UPDATE_FLAGS <= '0';
        MEM_UPDATE_FLAGS <= '0';
        EX1_REG_WRITE_EN_1 <= '1';
        EX1_REG_WRITE_EN_2 <= '0';
        EX2_REG_WRITE_EN_1 <= '0';
        EX2_REG_WRITE_EN_2 <= '0';
        MEM_REG_WRITE_EN_1 <= '0';
        MEM_REG_WRITE_EN_2 <= '0';
        EX1_WRITE_ADDRESS_1 <= "101"; -- r5
        EX1_WRITE_ADDRESS_2 <= "000"; -- r0
        EX2_WRITE_ADDRESS_1 <= "000"; -- r0
        EX2_WRITE_ADDRESS_2 <= "000"; -- r0
        MEM_WRITE_ADDRESS_1 <= "000"; -- r0
        MEM_WRITE_ADDRESS_2 <= "000"; -- r0
        WAIT FOR CLK_PERIOD;
        check_selected_sources(FWD_FROM_EX1, FWD_FROM_REGFILE, FLAG_FROM_REGFILE);
        -- Test 2: Both EX1 and MEM are writing to r5, should forward from EX1 since it's more recent
        read_reg_1 <= "101"; -- r5
        read_reg_2 <= "010"; -- r2
        EX1_UPDATE_FLAGS <= '0';
        EX2_UPDATE_FLAGS <= '0';
        MEM_UPDATE_FLAGS <= '0';
        EX1_REG_WRITE_EN_1 <= '1';
        EX1_REG_WRITE_EN_2 <= '0';
        EX2_REG_WRITE_EN_1 <= '0';
        EX2_REG_WRITE_EN_2 <= '0';
        MEM_REG_WRITE_EN_1 <= '0';
        MEM_REG_WRITE_EN_2 <= '1';
        EX1_WRITE_ADDRESS_1 <= "101"; -- r5
        EX1_WRITE_ADDRESS_2 <= "000"; -- r0
        EX2_WRITE_ADDRESS_1 <= "000"; -- r0
        EX2_WRITE_ADDRESS_2 <= "000"; -- r0
        MEM_WRITE_ADDRESS_1 <= "101"; -- r5
        MEM_WRITE_ADDRESS_2 <= "000"; -- r0
        WAIT FOR CLK_PERIOD;
        check_selected_sources(FWD_FROM_EX1, FWD_FROM_REGFILE, FLAG_FROM_REGFILE);
        -- Test 3: EX2 is writing to r2, should forward to src2
        read_reg_1 <= "101"; -- r5
        read_reg_2 <= "010"; -- r2
        EX1_UPDATE_FLAGS <= '0';
        EX2_UPDATE_FLAGS <= '0';
        MEM_UPDATE_FLAGS <= '0';
        EX1_REG_WRITE_EN_1 <= '0';
        EX1_REG_WRITE_EN_2 <= '0';
        EX2_REG_WRITE_EN_1 <= '0';
        EX2_REG_WRITE_EN_2 <= '1';
        MEM_REG_WRITE_EN_1 <= '0';
        MEM_REG_WRITE_EN_2 <= '0';
        EX1_WRITE_ADDRESS_1 <= "000"; -- r0
        EX1_WRITE_ADDRESS_2 <= "000"; -- r0
        EX2_WRITE_ADDRESS_1 <= "000"; -- r0
        EX2_WRITE_ADDRESS_2 <= "010"; -- r2
        MEM_WRITE_ADDRESS_1 <= "000"; -- r0
        MEM_WRITE_ADDRESS_2 <= "000"; -- r0
        WAIT FOR CLK_PERIOD;
        check_selected_sources(FWD_FROM_REGFILE, FWD_FROM_EX2_PORT2, FLAG_FROM_REGFILE);
        -- Test 4: EX1 is updating flags, should select flags from EX1
        read_reg_1 <= "101"; -- r5
        read_reg_2 <= "010"; -- r2
        EX1_UPDATE_FLAGS <= '1';
        EX2_UPDATE_FLAGS <= '0';
        MEM_UPDATE_FLAGS <= '0';
        EX1_REG_WRITE_EN_1 <= '0';
        EX1_REG_WRITE_EN_2 <= '0';
        EX2_REG_WRITE_EN_1 <= '1';
        EX2_REG_WRITE_EN_2 <= '0';
        MEM_REG_WRITE_EN_1 <= '0';
        MEM_REG_WRITE_EN_2 <= '0';
        EX1_WRITE_ADDRESS_1 <= "000"; -- r0
        EX1_WRITE_ADDRESS_2 <= "000"; -- r0
        EX2_WRITE_ADDRESS_1 <= "010"; -- r2
        EX2_WRITE_ADDRESS_2 <= "000"; -- r0
        MEM_WRITE_ADDRESS_1 <= "000"; -- r0
        MEM_WRITE_ADDRESS_2 <= "000"; -- r0
        WAIT FOR CLK_PERIOD;
        check_selected_sources(FWD_FROM_REGFILE, FWD_FROM_EX2, FLAG_FROM_EX1);
        WAIT; -- Wait indefinitely after tests
    END PROCESS;
END ARCHITECTURE;