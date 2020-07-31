ASSUME CS:CODES, DS:DATA, SS:STACKS

DATA SEGMENT
    dw 0123h, 0456h, 0789h, 0abch, 0defh, 0fedh, 0cbah, 0987h
DATA ENDS

STACKS SEGMENT
    dw 0, 0, 0, 0, 0, 0, 0, 0
STACKS ENDS

CODES SEGMENT

START:  MOV AX, STACKS
        MOV SS, AX
        MOV SP, 16
        
        MOV AX, DATA
        MOV DS, AX

        PUSH DS:[0]
        PUSH DS:[2]
        POP DS:[2]
        POP DS:[0]
        
        MOV AX, 4C00H
        INT 21H

CODES ENDS
END START