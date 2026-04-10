; SP26 Branch Test Skeleton
; all numbers are expected in hex

.ORG 0
0200

.ORG 1
0400

.ORG 2
0800

.ORG 3
0A00

; TODO: INT0 handler at 0x0800
.ORG 0800
NOP
RTI

; TODO: INT1 handler at 0x0A00
.ORG 0A00
NOP
RTI

; main program
.ORG 0200
; TODO: setup registers and flags
; TODO: test JZ / JN / JC / JMP / CALL / RET interactions
; TODO: include at least one misprediction recovery scenario
