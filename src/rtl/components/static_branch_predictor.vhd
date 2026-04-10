LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY static_branch_predictor IS
    PORT (
        instruction_opcode : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
        predicted_taken : OUT STD_LOGIC
    );
END ENTITY static_branch_predictor;

ARCHITECTURE rtl OF static_branch_predictor IS
BEGIN
    -- TODO: implement static branch policy (e.g., always not-taken or configured strategy)
END ARCHITECTURE rtl;