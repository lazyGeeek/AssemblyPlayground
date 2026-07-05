section .text
    global main

; Implement the following logic:
;   if x is even then
;       y = 1
;   else
;       y = 0
;
;   where:
;       x = rdi
;       y = rax

main:
and rdi, 1
xor rdi, 1
xor rax, rax
or rax, rdi
