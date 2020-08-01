DATA SEGMENT
    db 'welcome to masm!';  16 char
DATA ENDS

CODES SEGMENT
    ASSUME CS:CODES, DS:DATA
START:  MOV AX, DATA
        MOV DS, AX

        MOV SI, 0
        MOV AX, 0B800H
        MOV ES, AX

        MOV DI, 160*12+30*2
        MOV CX, 16

NEXT:   MOV AL, [SI]
        MOV ES:[DI], AL
        MOV BYTE PTR ES:[DI+1], 02H; change this value to convert different styles
        INC SI
        ADD DI, 2
        LOOP NEXT

        MOV AH, 4CH
        INT 21H
CODES ENDS
END START