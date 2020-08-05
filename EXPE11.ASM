DATA SEGMENT
    db "Beginner's All-purpose Symbolic Instruction Code.", 0
DATA ENDS


CODES SEGMENT
    ASSUME CS:CODES, DS:DATA
START:
    MOV AX, DATA
    MOV DS, AX
    MOV SI, 0
    CALL LETTERC
    
    MOV AH, 4CH
    INT 21H


; if 97<str<121, then plus 32
LETTERC:
    PUSH AX
    PUSH SI
    PUSHF

    MOV AX, 0
S0:
    MOV AL, [SI]
    CMP AL, 0
    JE OK

    CMP AL, 97
    JB NEXT
    CMP AL, 121
    JA NEXT
    SUB BYTE PTR [SI], 32
NEXT:
    INC SI
    JMP SHORT S0
OK:
    POPF
    POP SI
    POP AX
    RET


CODES ENDS
END START