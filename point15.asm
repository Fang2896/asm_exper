ASSUME CS:CODE

STACK SEGMENT
    db 128 DUP (0)
STACK ENDS

DATA SEGMENT 
    dw 0, 0
DATA ENDS

CODE SEGMENT 
START:
    MOV AX, STACK
    MOV SS, AX
    MOV SP, 128

    MOV AX, DATA
    MOV DS, AX

    MOV AX, 0
    MOV ES, AX

    PUSH ES:[9*4]
    POP DS:[0]
    PUSH ES:[9*4 + 2]
    POP DS:[2]

    ; 这里是在中断向量表中设置新的int9 中断例程的入口地址
    ; 必须使用CLI和STI来屏蔽中断，否则如果在执行这段程序的时候发生了键盘中断的话
    ; CPU将会转去一个错误的地址执行，将发生错误
    CLI     ; 屏蔽中断
    MOV WORD PTR ES:[9*4], OFFSET INT9
    MOV ES:[9*4 + 2], CS
    STI     ; 不屏蔽中断

    MOV AX, 0B800H
    MOV ES, AX
    MOV AH, 'a'
S:
    MOV ES:[160*12 + 40*2], AH
    CALL DELAY
    INC AH
    CMP AH, 'z'
    JNA S

    MOV AX, 0
    MOV ES, AX

    ; 恢复原来的int9中断程序
    PUSH DS:[0]
    POP ES:[9*4]
    PUSH DS:[2]
    POP ES:[9*4 + 2]

    MOV AX, 4C00H
    INT 21H



DELAY:
    PUSH AX
    PUSH DX
    MOV DX, 10H
    MOV AX, 0
S1:
    SUB AX, 1
    SBB DX, 0
    CMP AX ,0
    JNE S1
    CMP DX, 0
    JNE S1
    
    POP DX
    POP AX

    RET


; ----------int9-------------
INT9:
    PUSH AX
    PUSH BX
    PUSH ES

    IN AL, 60H

    PUSHF
    CALL DWORD PTR DS:[0]   ; 对int指令进行模拟，调用原来的int9中断例程

    CMP AL, 1               ; ESC被按下的话。
    JNE INT9RET

    MOV AX, 0B800H
    MOV ES, AX
    INC BYTE PTR ES:[160*12 + 40*2 + 1] ;改变颜色

INT9RET:
    POP ES
    POP BX
    POP AX
    IRET


CODE ENDS
END START