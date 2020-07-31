a SEGMENT
    dw 1,2,3,4,5,6,7,8,9,0ah,0bh,0ch,0dh,0eh,0fh,0ffh
a ENDS

b SEGMENT
    dw 0,0,0,0,0,0,0,0
b ENDS

CODES SEGMENT
    ASSUME CS:CODES
START:
    MOV AX, a
    MOV DS, AX
    MOV SS, AX
    MOV SP, 28H
    
    MOV AX, 0
    MOV BX, 0
    MOV CX, 8

S:  PUSH AX
    ADD BX, 0
    LOOP S

    MOV AH, 4CH
    INT 21H
CODES ENDS
END START