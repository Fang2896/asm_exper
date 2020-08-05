ASSUME CS:CODE

CODE SEGMENT 
    
START:
    MOV DX, 128
    MOV AX, 0
    MOV CX, 128
    CALL DIVDW

    MOV AH, 4CH
    INT 21H


DIVDW:
    JMP SHORT DIVSTART
    DATAREG DW 4 DUP (0)
DIVSTART:
    PUSH DX
    PUSH DS
    PUSH SI

    CMP DX, CX
    JB DIVNOFLO     ; if DX<CX, move to the DIVNOFLO segment

    MOV BX, CS
    MOV DS, BX      ; DS save the code segment adress
    MOV SI, OFFSET DATAREG

    MOV [SI], AX
    MOV AX, DX
    MOV DX, 0       ; avoid overflow
    DIV CX
    
    MOV [SI+2], DX  ; save the remainder
    MOV AX, DX      
    MOV BX, 512
    MUL BX
    MOV BX, 128
    MUL BX          ; int(H/N)*65536

    MOV [SI+4], AX  ; save the int(H/N)*65536
    MOV [SI+6], DX

    MOV AX, [SI+2]  ; get the remainder 
    MOV BX, 512
    MUL BX
    MOV BX, 128
    MUL BX
    ADD AX, [SI]    ; compute the rem(H/N)*65536 + L
    DIV CX          ; compute teh [rem(H/N)*65536 + L]/N

    MOV CX, DX      ; the remainder of result
    ADD AX, [SI+4]  ; low 4bit of result
    MOV DX, [SI+6]  ; high 4bit of result
    JMP SHORT DSRET

DIVNOFLO:
    DIV CX
    MOV CX, DX
    MOV DX, 0

DSRET:
    POP SI
    POP DS
    POP BX
    RET

CODE ENDS
END START