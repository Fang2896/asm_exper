DATA SEGMENT
    db '1975','1976','1977','1978','1979','1980','1981','1982','1983'
    db '1984','1985','1986','1987','1988','1989','1990','1991','1992'
    db '1993','1994','1995'

    dd 16,22,382,1356,2390,8000,16000,24486,50065,97479,140417,197514
    dd 345980,590827,803530,1183000,1843000,2759000,3753000,4649000,5937000

    dw 3,7,9,13,28,38,130,220,476,778,1001,1442,2258,2793,4037,5635,8226
    dw 11542,14430,15257,17800

    db 21 DUP (0)
DATA ENDS

STACKS SEGMENT 
    dw 16 DUP (0)
STACKS ENDS


CODE SEGMENT
ASSUME CS:CODE, DS:DATA, SS:STACKS
START:
    MOV AX, DATA
    MOV DS, AX
    MOV AX, STACKS
    MOV SS, AX
    MOV SP, 32

    MOV BX, 0
    MOV SI, 0
    MOV DI, 0
    MOV AX, 0

; 1. compute the meam salaries
COMPUTE:        
    MOV CX, [BX]
    MOV DX, [SI + 86]
    MOV AX, [SI + 84]
    CALL DIVDW
    MOV [SI + 210], AX
    MOV [SI + 212], DX

    MOV CX, 21
    MOV AX, 0

; 2. if str, print in screen, if number, first change then print in screen.
PRINT:    
    ; Calculate the beginning of the line   (DI)
    PUSH AX
    MOV BX, 160
    MUL BX
    ADD AX, 10
    MOV DI, AX
    POP AX
    INC AX

    ; str. '19xx'
    MOV BX, 16
    CALL CHANGEPRINT
    ; num of 32bit
    ADD SI, 84
    ADD DI, 20
    MOV BX ,32
    CALL CHANGEPRINT
    ; num of 16bit
    ADD SI, 84
    ADD DI, 20
    MOV BX, 16
    CALL CHANGEPRINT
    ; num of 32 bit
    ADD SI, 42
    ADD DI, 20
    MOV BX, 32
    CALL CHANGEPRINT
    
    LOOP COMPUTE


    MOV AH, 4CH
    INT 21H


; ===============================================================;
; Divide sub program
; Parameter: dividend:  DX: high 16bit digit, AX: low 16bit digit.
;            divisor:   CX
; Return:    quotient:  DX: high 16bit digit, AX: low 16bit digit.
;            remainder: CX
; ===============================================================;
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
    DIV CX          ; compute teh [rem(H/N)*65536 + L]/N

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


; ===============================================================;
; Change format and print in screen
; parameter :
;       BX: length of target(16, 32)
;       DS:SI: adress of the target
;       ES:DI: adress of the screen location
; return : change the target's format to str and print in screen       
; ===============================================================;
CHANGEPRINT:
    PUSH AX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI

    JMP DETERMINE
; allocate some space to save DI and SI
    CHANGEREG dw 2 DUP (0)

; Determine weather is a number or str. '19' == 3139H
DETERMINE:
    MOV AX, CHANGEREG
    MOV ES, AX
    MOV ES:[0], SI
    MOV ES:[2], DI

    CMP BX, 32
    JE NUM32
    MOV AX, [SI]
    CMP AX, 3139H
    JE STR16
    JMP NUM16

; number of 16bit
NUM16:
    MOV BX, 10
    MOV AX, [SI]
    MOV DI, 0
NUM16DEVIDE:
    MOV CX, AX
    JCXZ STOPPUSH   ;???????????????

    DIV BX
    INC DI
    PUSH DX
    MOV DX, 0
    JMP NUM16DEVIDE
; number of 32 bit
NUM32:
    MOV BX, 10
    MOV AX, [SI]
    MOV DI, 0
HIGH_NUM32DEVIDE:
    MOV CX, AX
    JCXZ MID

    DIV BX
    INC DI
    PUSH DX
    MOV DX, 0
    JMP HIGH_NUM32DEVIDE
MID:
    MOV AX, [SI+2]
LOW_NUM32DEVIDE:
    MOV CX, AX
    JCXZ STOPPUSH   ;???????????????

    MOV DX, 0
    DIV BX
    INC DI
    PUSH DX
    JMP LOW_NUM32DEVIDE

; Stop to devide and begin to change and print in screen.
STOPPUSH:
    MOV CX, DI
CHANGE2STR:
    POP BX
    ADD BX, 30H
    MOV DI, ES:[2]
    MOV AX, 0B800H
    MOV ES, AX

    MOV ES:[DI], BL
    MOV BYTE PTR ES:[DI+1], 07H  ; Black background and white string
    INC DI
    INC DI
    LOOP CHANGE2STR

    JMP OK
    
; string. for example: '1985'
STR16:
    MOV AX, 0B800H
    MOV ES, AX
    MOV CX, 4
STR16PRINT:
    MOV AL, [SI]
    MOV ES:[DI], AL
    MOV BYTE PTR ES:[DI + 1], 07H
    INC SI
    INC DI
    INC DI
    LOOP STR16PRINT

    JMP OK


OK:
    POP DI
    POP SI
    POP DX
    POP CX
    POP AX

    RET


CODE ENDS
END START