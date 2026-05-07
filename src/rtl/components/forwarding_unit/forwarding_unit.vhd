LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE work.isa_defs_pkg.ALL;

ENTITY forwarding_unit IS
    PORT (
        read_reg_1 : IN reg_idx_t;
        read_reg_2 : IN reg_idx_t;
        
        EX1_UPDATE_FLAGS : IN STD_LOGIC;
        EX2_UPDATE_FLAGS : IN STD_LOGIC;
        MEM_UPDATE_FLAGS : IN STD_LOGIC;

        EX1_REG_WRITE_EN_1 : IN STD_LOGIC;
        EX1_REG_WRITE_EN_2 : IN STD_LOGIC;
        EX1_WRITE_ADDRESS_1 : IN reg_idx_t;
        EX1_WRITE_ADDRESS_2 : IN reg_idx_t;
        EX2_REG_WRITE_EN_1 : IN STD_LOGIC;
        EX2_REG_WRITE_EN_2 : IN STD_LOGIC;
        EX2_WRITE_ADDRESS_1 : IN reg_idx_t;
        EX2_WRITE_ADDRESS_2 : IN reg_idx_t;
        MEM_REG_WRITE_EN_1 : IN STD_LOGIC;
        MEM_REG_WRITE_EN_2 : IN STD_LOGIC;
        MEM_WRITE_ADDRESS_1 : IN reg_idx_t;
        MEM_WRITE_ADDRESS_2 : IN reg_idx_t;

        FLAG_SRC_SEL : OUT flag_src_sel_t;
        RSRC1_SEL : OUT fwd_sel_t;
        RSRC2_SEL : OUT fwd_sel_t
    );
END ENTITY forwarding_unit;

ARCHITECTURE rtl OF forwarding_unit IS
BEGIN
    process(read_reg_1, read_reg_2, EX1_UPDATE_FLAGS, EX2_UPDATE_FLAGS, MEM_UPDATE_FLAGS, EX1_REG_WRITE_EN_1, EX1_REG_WRITE_EN_2, EX1_WRITE_ADDRESS_1, EX1_WRITE_ADDRESS_2, EX2_REG_WRITE_EN_1, EX2_REG_WRITE_EN_2, EX2_WRITE_ADDRESS_1, EX2_WRITE_ADDRESS_2, MEM_REG_WRITE_EN_1, MEM_REG_WRITE_EN_2, MEM_WRITE_ADDRESS_1, MEM_WRITE_ADDRESS_2)
    begin
        if(EX1_UPDATE_FLAGS = '1') then
            FLAG_SRC_SEL <= FLAG_FROM_EX1;
        elsif(EX2_UPDATE_FLAGS = '1') then
            FLAG_SRC_SEL <= FLAG_FROM_EX2;
        elsif(MEM_UPDATE_FLAGS = '1') then
            FLAG_SRC_SEL <= FLAG_FROM_MEM;
        else
            FLAG_SRC_SEL <= FLAG_FROM_REGFILE;
        end if;
        if(read_reg_1 = EX1_WRITE_ADDRESS_1 and EX1_REG_WRITE_EN_1 = '1') then
            RSRC1_SEL <= FWD_FROM_EX1;
        elsif(read_reg_1 = EX1_WRITE_ADDRESS_2 and EX1_REG_WRITE_EN_2 = '1') then
            RSRC1_SEL <= FWD_FROM_EX1_PORT2;
        elsif(read_reg_1 = EX2_WRITE_ADDRESS_1 and EX2_REG_WRITE_EN_1 = '1') then
            RSRC1_SEL <= FWD_FROM_EX2;
        elsif(read_reg_1 = EX2_WRITE_ADDRESS_2 and EX2_REG_WRITE_EN_2 = '1') then
            RSRC1_SEL <= FWD_FROM_EX2_PORT2;
        elsif(read_reg_1 = MEM_WRITE_ADDRESS_1 and MEM_REG_WRITE_EN_1 = '1') then
            RSRC1_SEL <= FWD_FROM_MEM;
        elsif(read_reg_1 = MEM_WRITE_ADDRESS_2 and MEM_REG_WRITE_EN_2 = '1') then
            RSRC1_SEL <= FWD_FROM_MEM_PORT2;
        else
            RSRC1_SEL <= FWD_FROM_REGFILE;
        end if;
        if(read_reg_2 = EX1_WRITE_ADDRESS_1 and EX1_REG_WRITE_EN_1 = '1') then
            RSRC2_SEL <= FWD_FROM_EX1;
        elsif(read_reg_2 = EX1_WRITE_ADDRESS_2 and EX1_REG_WRITE_EN_2 = '1') then
            RSRC2_SEL <= FWD_FROM_EX1_PORT2;
        elsif(read_reg_2 = EX2_WRITE_ADDRESS_1 and EX2_REG_WRITE_EN_1 = '1') then
            RSRC2_SEL <= FWD_FROM_EX2;
        elsif(read_reg_2 = EX2_WRITE_ADDRESS_2 and EX2_REG_WRITE_EN_2 = '1') then
            RSRC2_SEL <= FWD_FROM_EX2_PORT2;
        elsif(read_reg_2 = MEM_WRITE_ADDRESS_1 and MEM_REG_WRITE_EN_1 = '1') then
            RSRC2_SEL <= FWD_FROM_MEM;
        elsif(read_reg_2 = MEM_WRITE_ADDRESS_2 and MEM_REG_WRITE_EN_2 = '1') then
            RSRC2_SEL <= FWD_FROM_MEM_PORT2;
        else
            RSRC2_SEL <= FWD_FROM_REGFILE;
        end if;
    end process;
END ARCHITECTURE rtl;