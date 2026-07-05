section .text
    global main

; Perform the following:  
;   rax = rdi AND rsi

main:
and rdi, rsi
xor rax, ra
xor rax, rdi
