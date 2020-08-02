ASSUME CS:CODE, DS:DATA

DATA SEGMENT 
    DB 10 DUP (0)
DATA ENDS

CODE SEGMENT 

START:
    MOV AX, 12666
    MOV BX, DATA
    MOV DS, BX
    MOV SI, 0
    CALL DTOC

    MOV DH, 8
    MOV DL, 3
    MOV CL, 2
    CALL SHOW_STR


DTOC:
    PUSH AX
    PUSH SI
    PUSH DI
    PUSH DX
    PUSH BX
    PUSH CX

    MOV DI, 0
    MOV DX, 0
    MOV BX, 10

DEVIDE:
    MOV CX, AX  ; When AX=0, then jump to the STOP
    JCXZ STOP

    DIV BX
    INC DI      ; count the digit of the target number
    PUSH DX
    MOV DX, 0
    JMP DEVIDE

STOP:
    MOV CX, DI

STRING:
    POP BX
    ADD BX, 30H
    MOV [SI], BL
    INC SI
    LOOP STRING

    POP CX
    POP BX
    POP DX
    POP DI
    POP SI
    POP AX

    RET


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


CODE ENDS
END START