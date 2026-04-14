# Hazards & Dynamic Branch Prediction (Phase 1)

## Data hazards

- Forwarding coverage:
  - `EX1/EX2 -> EX1` for ALU inputs
  - `EX2/MEM -> EX1` for ALU inputs
  - `MEM/WB -> EX1` for ALU inputs
  - Forward to store-data path
  - Flag forwarding to branch comparator path (`EX1`, `EX2`, `MEM`, or committed flags)
- `SWAP_2ND_CYCLE=1` disables EX1->EX1 forwarding for that internal cycle.
- Load-use hazard policy:
  - 1-cycle bubble if dependency is on load result in `EX2`
  - 2-cycle bubble if dependency chain still unresolved through `EX1` and `EX2`

## Structural hazards

- Unified memory conflict between fetch and data access
- Arbitration policy:
  - If Memory stage needs memory in current cycle, assert `FETCH_MEMORY_HAZARD=1` to stall Fetch.
  - Decode/execute flow continues unless blocked by other hazard signals.

## Control hazards

- Conditional branches resolve in Execute-2.
- Prediction/mispredict handling:
  - `branch_prediction` generated in Fetch.
  - In Execute-2, compare predicted vs actual branch result.
  - If mismatch: flush 3 younger instructions (`IF/ID`, `ID/EX1`, `EX1/EX2`) and write corrected PC.
- Corrected PC policy:
  - Wrong-not-taken case: corrected PC = immediate target address.
  - Wrong-taken case: corrected PC = original `next_pc`.
- Any instruction that writes PC from memory has priority hazard behavior:
  - stall younger instructions while in-flight
  - flush pipeline when PC load is committed

## Dynamic branch prediction

- Predictor type: 2-bit dynamic saturating counter per tracked branch entry.
- Early decode hook in Fetch:
  - `instr[16]=1` marks unconditional immediate branch
  - `instr[17]=1` marks conditional branch
- Branch direction resolved in Execute-2 and feeds predictor update.

## Interrupt and corner-case gating

- Hardware interrupt entry is delayed when any of the following is true:
  - `ID_COND_BRANCH=1`, `EX1_COND_BRANCH=1`, or `EX2_COND_BRANCH=1`
  - `MULTICYCLE_STALL=1` (decode is injecting internal follow-up op)
- `ALLOW_HW_INT=1` only when queued interrupt exists and none of the above blocking conditions hold.
- If hardware interrupt arrives during unresolved conditional branch window, hold interrupt pending until branch resolves.
- If hardware interrupt arrives while multicycle/word fetch-decode flow is active, hold interrupt pending.
- `INT/INT2/INT3`, `RET`, and `RTI` are treated as control-critical sequences and may trigger pipeline-wide stall/flush according to PC-write rules.

## Hazard unit I/O summary

### Inputs

- Control: `MEMORY`, `EX1_MEMR`, `EX2_MEMR`, `EX2_COND_BRANCH`, `EX1_COND_BRANCH`, `ID_COND_BRANCH`, `MULTICYCLE_STALL`, `HARDWARE_INTERRUPT`, `EX1_PC_WRITE`, `EX2_PC_WRITE`, `MEM_PC_WRITE`
- Data: `read_reg_1`, `read_reg_2`, `id_ex1_write_address`, `ex1_ex2_write_address`, `branch_prediction`, `branch_result`

### Outputs

- Control: `FETCH_MEMORY_HAZARD`, `CORRECT_PC`, `ALLOW_HW_INT`, `BUBBLE`, `STALL`, `FLUSH`
- Data: `correct_pc_value`
