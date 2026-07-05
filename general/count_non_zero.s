section .text
    global main

; Count the consecutive non-zero bytes in a contiguous region of memory, where:  
;  rdi = memory address of the 1st byte  
;  rax = number of consecutive non-zero bytes
; 
; Additionally, if rdi = 0, then set rax = 0

main:
cmp rdi, 0
je done
mov rax, 0

loop:
cmp byte ptr [rdi], 0
je done
add rax, 1
add rdi, 1
jmp loop

done:
nop
