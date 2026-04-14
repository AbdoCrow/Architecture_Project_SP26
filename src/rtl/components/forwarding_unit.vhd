LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE work.isa_defs_pkg.ALL;

ENTITY forwarding_unit IS
    PORT (
        read_reg_1 : IN reg_idx_t;
        read_reg_2 : IN reg_idx_t;

        SWAP_2ND_CYCLE : IN STD_LOGIC;

        EX1_UPDATE_FLAGS : IN STD_LOGIC;
        EX2_UPDATE_FLAGS : IN STD_LOGIC;
        MEM_UPDATE_FLAGS : IN STD_LOGIC;

        EX1_WB : IN STD_LOGIC;
        EX1_WRITE_ADDRESS : IN reg_idx_t;
        EX2_WB : IN STD_LOGIC;
        EX2_WRITE_ADDRESS : IN reg_idx_t;
        MEM_WB : IN STD_LOGIC;
        MEM_WRITE_ADDRESS : IN reg_idx_t;

        FLAG_SRC_SEL : OUT flag_src_sel_t;
        RSRC1_SEL : OUT fwd_sel_t;
        RSRC2_SEL : OUT fwd_sel_t
    );
END ENTITY forwarding_unit;

ARCHITECTURE rtl OF forwarding_unit IS
BEGIN
    -- Definition-only skeleton.
END ARCHITECTURE rtl;