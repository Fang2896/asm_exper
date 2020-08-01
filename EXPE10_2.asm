DATA SEGMENT
    dw 0, 0, 0, 0, 0, 0, 0, 0
    ; AX,BX,CX,DX,int(H/N)[low/high],rem(H/N)[low/high]
DATA ENDS

CODES SEGMENT
    ASSUME CS:CODES, DS:DATA
START:
    MOV AX, DATA
    MOV DS, AX

    MOV AX, 4240H
    MOV DX, 000FH
    MOV CX, 0AH
    CALL DIVDW
    
    MOV AH, 4CH
    INT 21H

; H:L / N = int(H/N)*65536 + [rem(H/N)*65536 + L]/N
DIVDW:
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    ; Compute int(H/N)*65536 and rem(H/N)*65536
    MOV [0], AX
    MOV [2], BX
    MOV [4], CX
    MOV [6], DX
    MOV AX, DX
    MOV DX, 0
    DIV WORD PTR CX

    ; DWORD[8] = int(H/N)*65536, DWORD[12] = rem(H/N)*65536
    MOV [8], AX
    MOV [12], DX
    MOV AX, 65536
    MUL	WORD PTR [8]
    MOV [8], AX
    MOV [10], DX
    MOV AX, 65536
    MUL WORD PTR [12]
    MOV [12], AX
    MOV [14], DX
    
    ; rem(H/N)*65536 + L. L = (0)
    MOV BX, 0
    MOV CX, [0]
    CALL DADD

    ; [rem(H/N)*65536 + L]/N
    MOV CX, [4]
    DIV WORD PTR CX
    MOV CX, DX

    MOV 




; double-precision addition
; parameter:    DX, AX - high/low 32bit number1
;               BX, CX - high/low 32bit number2
; return:       DX, AX - high/low 32bit result
DADD:





    

    
    




CODES ENDS
END START