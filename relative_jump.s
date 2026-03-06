section .text
    global main

; Perform the following:
;  Make the first instruction in your code a jmp
;  Make that jmp a relative jump to 0x51 bytes from the current position
;  At the code location where the relative jump will redirect control flow set rax to 0x1

main:
jmp Relative
.rept 0x51
nop
.endr
Relative:
mov rax, 0x1
