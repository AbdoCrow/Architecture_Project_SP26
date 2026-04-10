# Pipeline Design (Phase 1)

## 6 Stages

1. Fetch
2. Decode
3. Execute-1
4. Execute-2
5. Memory
6. Write-Back

## Pipeline registers

- `IF_ID`
- `ID_EX1`
- `EX1_EX2`
- `EX2_MEM`
- `MEM_WB`

## Stage contracts

- Fill signal lists, widths, and timing assumptions per stage.
- Define where each instruction class resolves (ALU, branch, memory, writeback).

## Clocking policy

- TODO: choose rising/falling-edge usage for memory/regfile/flags.
