# Hazards & Static Branch Prediction (Phase 1)

## Data hazards

- Required forwarding paths:
  - EX2 -> EX1
  - MEM -> EX1
  - WB -> EX1
  - Forward to store-data path

## Structural hazards

- Unified memory conflict between fetch and data access
- Arbitration/stall policy: TODO

## Control hazards

- Branch resolved in Execute-2
- Flush policy for wrong-path instructions: TODO

## Static branch prediction

- Baseline policy: TODO (`always not taken` or `always taken`)
- Fetch-stage hook and mispredict recovery path: TODO

## Corner cases

- Interrupt during branch window
- INT/RTI/RET with in-flight instructions
