section .text
    global main

;  Take the top value of the stack, subtract rdi from it, then put it back

main:
pop rax
sub rax, rdi
push rax
