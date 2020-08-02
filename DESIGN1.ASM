DATA SEGMENT
    db '1975','1976','1977','1978','1979','1980','1981','1982','1983'
    db '1984','1985','1986','1987','1988','1989','1990','1991','1992'
    db '1993','1994','1995'

    dd 16,22,382,1356,2390,8000,16000,24486,50065,97479,140417,197514
    dd 345980,590827,803530,1183000,1843000,2759000,3753000,4649000,5937000

    dw 3,7,9,13,28,38,130,220,476,778,1001,1442,2258,2793,4037,5635,8226
    dw 11542,14430,15257,17800

    dd 21 DUP (0)
DATA ENDS

STRING SEGMENT
    db 21 DUP '          '  ; 10 blank
    db 21 DUP '     '       ; 5 blank
    db 21 DUP '          '  ; 10 blank
STRING ENDS

CACHE SEGMENT
    dw 8 DUP 0
CACHE ENDS


; ===============================================================;
; Function: print the data above on the screen
; 1. call the subprogram(DIVDW) to process the data, compute the meam salaries and save them
; 2. call the subprogram(DTOC) to modify the dword number data to the string and show in screen
; ===============================================================;
CODES SEGMENT
    ASSUME CS:CODES, DS:DATA
START:
    MOV AX, DATA
    MOV DS, AX
    MOV AX, 0B800H
    MOV ES, AX

    MOV SI, 0
    MOV BX, 168
    MOV CX, 21

PROCESS:
    PUSH CX

COMPUTE:    ; 1. compute the meam salaries
    MOV CX, [BX]
    MOV DX, [SI + 86]
    MOV AX, [SI + 84]
    CALL DIVDW
    MOV [SI + 210], AX
    MOV [SI + 212], DX

NUM2STR:    ; 2. modify the dword number data to the string  and show in screen
    PUSH SI

    ; Double word
    ADD SI, 84
    MOV AX, [SI]
    MOV DX, [SI + 2]
    CALL DTOC
    MOV [SI], AX
    MOV [SI + 2], DX

    ; word
    MOV DX, 0
    MOV AX, [BX]
    CALL DTOC
    MOV [BX], AX
    ; Double word
    ADD SI, 126
    MOV AX, [SI]
    MOV DX, [SI + 2]
    CALL DTOC
    MOV [SI], AX
    MOV [SI + 2], DX


    POP SI
    ADD SI, 4
    ADD BX, 2
    LOOP PROCESS
    
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



; ===============================================================;
; Double word data-string change sub program
; parameter:    DX-> high 16bit, AX-> low 16bit, DS:[SI]-> location of the data
; return:       change the number to the string
; ===============================================================;
DTOC:
    PUSH DS
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH DI
    PUSH SI   
    
    MOV DI, 0   ; As a counter
    MOV SI, DX  ; temporally save the DX(high 16bit number data)
    MOV DX, 0
    MOV BX, 10

LOWDIV:
    MOV CX, AX
    JCXZ MID

    ; 32bit / 16bit 
    MOV DX, 0
    DIV BX
    INC DI
    PUSH DX
    JMP LOWDIV

MID:
    MOV AX, SI
HIGHDIV:
    MOV CX, AX
    JCXZ STOP

    MOV DX, 0
    DIV BX
    INC DI
    PUSH DX
    JMP HIGHDIV

STOP:
    MOV CX, DI  ; DI is the length of the str-number
    MOV AX, STRING
    MOV DS, AX
STRSHOW:
    
    POP BX
    ADD BX, 30H
    MOV ES:[SI], BL
    INC SI
    LOOP STRSHOW


    POP DX
    POP CX
    POP BX
    POP AX
    POP DI
    POP SI
    POP DS

RET



; ===============================================================;
; Show the data on the screen sub program
; DH-index, DL-row, CL-color
; DS-DataSegment, SI-data location,
; BX-length of the str 
; ES-screen segment adress, DI-screen location
; ===============================================================;
; SHOW_STR:
;     ; push all used-parameter to the stack
;     PUSH SI
;     PUSH DI
;     PUSH DS
;     PUSH ES
;     PUSH AX
;     PUSH CX
;     PUSH BX

;     MOV AX, 0B800H
;     MOV ES, AX
;     MOV BX, 0   ;save the location of the screen. (DI + BX)
;     MOV AX, 0   ;used in MUL
;     MOV DI, 0

;     ;Use BX to save the (160*index + 2*row)
;     PUSH DX
;     MOV DH, 0
;     ADD DX, DX
;     MOV BX, DX
;     MOV AL, 160
;     POP DX
;     MUL DH
;     ADD BX, AX      ; Now the BX save the location of the screen

; ; Data-> [SI], Screen-> str:[DI+BX], color:[DI+BX+1]
; SHOW:
    
;     JCXZ OK

    
;     JMP SHORT SHOW

; OK:
;     POP CX
;     POP BX
;     POP AX
;     POP ES
;     POP DS
;     POP DI
;     POP SI

; RET


CODES ENDS
END START