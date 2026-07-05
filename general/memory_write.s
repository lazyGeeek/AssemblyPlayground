section .text
    global main

; Perform the following:
;   Place the value stored in rax to 0x404000

main:
mov [0x404000], rax
