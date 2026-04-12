# Opcode Table (Phase 1)

Address alignment note for 4KB memory: absolute control-flow targets are encoded in the same instruction word as `[26:12]=0`, `[11:0]=TargetAddr`.
F1 alignment note: one-operand instructions mirror the operand register in both `[26:24]` (`Rdst`) and `[23:21]` (`Rsrc1`); F0 keeps both fields `000`.

| Mnemonic | Opcode (bin) | Format | Notes                |
| -------- | ------------ | ------ | -------------------- |
| NOP      | 00000        | F0     |                      |
| HLT      | 00001        | F0     |                      |
| SETC     | 00010        | F0     |                      |
| NOT      | 00011        | F1     |                      |
| INC      | 00100        | F1     |                      |
| OUT      | 00101        | F1     |                      |
| IN       | 00110        | F1     |                      |
| MOV      | 01000        | F2     |                      |
| SWAP     | 01001        | F2     | multi-cycle handling |
| ADD      | 01010        | F2     | updates Z/N/C        |
| SUB      | 01011        | F2     | updates Z/N/C        |
| AND      | 01100        | F2     | updates Z/N          |
| IADD     | 01101        | F3     | 1-word, imm16        |
| PUSH     | 10000        | F1     | SP--                 |
| POP      | 10001        | F1     | SP++                 |
| LDM      | 10010        | F3     | 1-word, imm16        |
| LDD      | 10011        | F3     | 1-word, offset16     |
| STD      | 10100        | F3     | 1-word, offset16     |
| JZ       | 11000        | F3     | 1-word, addr12       |
| JN       | 11001        | F3     | 1-word, addr12       |
| JC       | 11010        | F3     | 1-word, addr12       |
| JMP      | 11011        | F3     | 1-word, addr12       |
| CALL     | 11100        | F3     | 1-word, addr12       |
| RET      | 11101        | F0     |                      |
| INT      | 11110        | F3     | 1-word, index=0/1    |
| RTI      | 11111        | F0     |                      |
