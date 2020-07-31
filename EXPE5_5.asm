a SEGMENT
    db 1, 2, 3, 4, 5, 6, 7, 8
a ENDS

b SEGMENT
    db 1, 2, 3, 4, 5, 6, 7, 8
b ENDS

c SEGMENT
    db 0, 0, 0, 0, 0, 0, 0, 0
c ENDS

CODES SEGMENT
    ASSUME CS:CODES
START:
    MOV AX,a
    MOV DS,AX

    MOV BX,0
    MOV AL,0
    MOV CX,8

S:  MOV AL,[BX]
    ADD AL,[16+BX]
    MOV [32+BX],AL
    INC BX
    LOOP S


    MOV AH, 4CH
    INT 21H
CODES ENDS
END START