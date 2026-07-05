section .text
    global main

; Without using pop, please calculate the average of 4 consecutive quad words stored on the stack.
; 
; Push the average on the top of the stack.
; 
; Hint:  
;  RSP+0x?? Quad Word A
;  RSP+0x?? Quad Word B
;  RSP+0x?? Quad Word C
;  RSP Quad Word D

main:
mov rax, [rsp]
add rax, [rsp + 8]
add rax, [rsp + 16]
add rax, [rsp + 24]
shr rax, 2
push rax
