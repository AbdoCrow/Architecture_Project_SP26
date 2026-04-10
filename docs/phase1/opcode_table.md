# Opcode Table (Phase 1)

| Mnemonic | Opcode (bin) | Format | Notes                |
| -------- | ------------ | ------ | -------------------- |
| NOP      | TODO         | F0     |                      |
| HLT      | TODO         | F0     |                      |
| SETC     | TODO         | F0     |                      |
| NOT      | TODO         | F1     |                      |
| INC      | TODO         | F1     |                      |
| OUT      | TODO         | F1     |                      |
| IN       | TODO         | F1     |                      |
| MOV      | TODO         | F2     |                      |
| SWAP     | TODO         | F2     | multi-cycle handling |
| ADD      | TODO         | F2     | updates Z/N/C        |
| SUB      | TODO         | F2     | updates Z/N/C        |
| AND      | TODO         | F2     | updates Z/N          |
| IADD     | TODO         | F3     | 2-word               |
| PUSH     | TODO         | F1     | SP--                 |
| POP      | TODO         | F1     | SP++                 |
| LDM      | TODO         | F3     | 2-word               |
| LDD      | TODO         | F3     | 2-word               |
| STD      | TODO         | F3     | 2-word               |
| JZ       | TODO         | F3     | 2-word               |
| JN       | TODO         | F3     | 2-word               |
| JC       | TODO         | F3     | 2-word               |
| JMP      | TODO         | F3     | 2-word               |
| CALL     | TODO         | F3     | 2-word               |
| RET      | TODO         | F0     |                      |
| INT      | TODO         | F3/F1  | index=0/1            |
| RTI      | TODO         | F0     |                      |
