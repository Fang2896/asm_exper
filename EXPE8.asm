ASSUME CS:CODES
CODES SEGMENT

    MOV AX, 4C00H
    INT 21H

START:  MOV AX, 0
S:      NOP
        NOP

        MOV DI, OFFSET S
        MOV SI, OFFSET S2
        MOV AX, CS:[SI]
        MOV CS:[DI], AX

S0:     JMP SHORT S

S1:     MOV AX, 0
        INT 21H
        MOV AX, 0

S2:     JMP SHORT S1
        NOP

CODES ENDS
END START