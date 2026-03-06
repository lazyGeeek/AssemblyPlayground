section .text
    global main

; Using the earlier mentioned info, perform the following:
;   Set [rdi] = 0xdeadbeef00001337
;   Set [rsi] = 0xc0ffee0000

main:
mov rax, 0xdeadbeef00001337
mov [rdi], rax
mov rax, 0xc0ffee0000
mov [rsi], rax
