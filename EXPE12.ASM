

CODE SEGMENT 
ASSUME CS:CODE
START:
    ; D0安装程序. D0位置在0：200处
    MOV AX, CS
    MOV DS, AX
    MOV SI, OFFSET D0
    MOV AX, 0
    MOV ES, AX
    MOV DI, 200H

    MOV CX, OFFSET D0END - OFFSET D0
    CLD
    REP MOVSB

    ; 设置中断向量表. 把处理程序入口地址送入
    MOV AX, 0
    MOV ES, AX
    MOV WORD PTR ES:[0*4], 200H
    MOV WORD PTR ES:[0*4 + 2], 0



    ; 异常测试程序
    MOV AX, 1000H
    MOV BH, 1
    DIV BH



    MOV AX, 4C00H
    INT 21H



; 0号异常发生后的处理程序. 也就是中断程序
D0:                     ; 此程序放在 0:200H 上
    JMP SHORT D0START   ; 占2个字节
    db 'divide error!'  ; 这里的偏移地址为202H
D0START:
    MOV AX, 0B800H
    MOV ES, AX
    MOV DI, 160*12 + 36*2
    MOV AX, CS
    MOV DS, AX
    MOV SI, 202H

    MOV CX, 13
S0:
    MOV AL, [SI]
    MOV ES:[DI], AL
    INC SI
    ADD DI, 2
    LOOP S0


    MOV AX, 4C00H
    INT 21H
D0END:
    NOP

CODE ENDS
END START
