DATA SEGMENT
    db "Beginner's All-purpose Symbolic Instruction Code.", 0
DATA ENDS


CODES SEGMENT
    ASSUME CS:CODES, DS:DATA
START:
    MOV AX, DATA
    MOV DS, AX
    
    MOV AH, 4CH
    INT 21H
CODES ENDS
END START