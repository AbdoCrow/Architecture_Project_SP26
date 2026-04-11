# Opcode Table (Phase 1)

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
| IADD     | 01101        | F3     | 2-word               |
| PUSH     | 10000        | F1     | SP--                 |
| POP      | 10001        | F1     | SP++                 |
| LDM      | 10010        | F3     | 2-word               |
| LDD      | 10011        | F3     | 2-word               |
| STD      | 10100        | F3     | 2-word               |
| JZ       | 11000        | F3     | 2-word               |
| JN       | 11001        | F3     | 2-word               |
| JC       | 11010        | F3     | 2-word               |
| JMP      | 11011        | F3     | 2-word               |
| CALL     | 11100        | F3     | 2-word               |
| RET      | 11101        | F0     |                      |
| INT      | 11110        | F3/F1  | index=0/1            |
| RTI      | 11111        | F0     |                      |
