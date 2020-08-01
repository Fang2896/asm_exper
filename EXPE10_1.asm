DATA SEGMENT
    db 'Welcome to the masm!',0
DATA ENDS

STACKS SEGMENT
    dw 8 DUP (0)
STACKS ENDS

CODES SEGMENT
    ASSUME CS:CODES, DS:DATA, SS:STACKS
START:
    ; set parameters. DH-index, DL-row, CL-color
    MOV DH, 24
    MOV DL, 3
    MOV CL, 2

    MOV AX, DATA
    MOV DS, AX
    MOV SP, SS:[16]

    MOV SI, 0
    CALL SHOW_STR

    MOV AH, 4CH
    INT 21H


; DH-index, DL-row, CL-color; 
; DS-DataSegment, SI-data location, ES-screen segment adress, DI-screen location
SHOW_STR:
    ; push all used-parameter to the stack
    PUSH SI
    PUSH DI
    PUSH DS
    PUSH ES
    PUSH BX

    MOV AX, 0B800H
    MOV ES, AX
    MOV BX, 0   ;save the location of the screen. (DI + BX)
    MOV AX, 0   ;used in MUL
    MOV DI, 0

    ;Use BX to save the (160*index + 2*row)
    PUSH DX
    MOV DH, 0
    ADD DX, DX
    MOV BX, DX      ; 2*ROW
    POP DX
    MOV AH, DH
    MOV DH, 0
    MOV DL, AH
    MOV DH, 0
    MOV AX, 160
    MUL DX          ; 160*INDEX
    ADD BX, AX      ; Now the BX save the location of the screen

; Data-> [SI], Screen-> str:[DI+BX], color:[DI+BX+1]
SHOW:
    PUSH CX
    MOV CX, 0
    MOV AL, [SI]
    MOV CL, AL      ;if (CX) is 0, then jump to the end
    JCXZ OK

    POP CX
    MOV BYTE PTR ES:[DI+BX], AL
    MOV BYTE PTR ES:[DI+BX+1], CL
    ADD DI, 2
    INC SI
    JMP SHORT SHOW

OK:
    POP CX
    POP BX
    POP ES
    POP DS
    POP DI
    POP SI
    RET

CODES ENDS
END START