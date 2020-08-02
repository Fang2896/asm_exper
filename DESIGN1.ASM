DATA SEGMENT
    db '1975','1976','1977','1978','1979','1980','1981','1982','1983'
    db '1984','1985','1986','1987','1988','1989','1990','1991','1992'
    db '1993','1994','1995'

    dd 16,22,382,1356,2390,8000,16000,24486,50065,97479,140417,197514
    dd 345980,590827,803530,1183000,1843000,2759000,3753000,4649000,5937000

    dw 3,7,9,13,28,38,130,220,476,778,1001,1442,2258,2793,4037,5635,8226
    dw 11542,14430,15257,17800
DATA ENDS

TABLE SEGMENT
    db 21 dup ('year summ ne ?? ')
TABLE ENDS

CODES SEGMENT
    ASSUME CS:CODES, DS:DATA
START:
    MOV AX, DATA
    MOV DS, AX
    MOV AX, TABLE
    MOV ES, AX


    
    MOV AH, 4CH
    INT 21H



; Divide sub program
; Parameter: dividend:  DX: high 16bit digit, AX: low 16bit digit.
;            divisor:   CX
; Result:    quotient:  DX: high 16bit digit, AX: low 16bit digit.
;            remainder: CX
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
    DIX CX          ; compute teh [rem(H/N)*65536 + L]/N

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



CODES ENDS
END START