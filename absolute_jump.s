section .text
    global main

; Perform the following:  
;  Jump to the absolute address `0x403000`

main:
push 0x403000
ret
