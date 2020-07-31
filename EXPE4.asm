ASSUME CS:code

code SEGMENT 
    mov ax, 0020H
    mov ds, ax
    mov bx, 0
    mov cx, 40H

s:  mov [bx], bl
    inc	bx
    loop s

    mov ax, 4c00H
    int 21H
code ENDS

END