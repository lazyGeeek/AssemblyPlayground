section .text
    global main

; Perform the following: 
;   Place the value stored at 0x404000 into rax
;   Make sure the value in rax is the original value stored at 0x404000.

main:
mov rax, [0x404000]
