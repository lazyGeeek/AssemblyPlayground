section .text
    global main

; Implement the following logic:
;
;if rdi is 0:
;	jmp 0x403016
;else if rdi is 1:
;	jmp 0x4030e4
;else if rdi is 2:
;	jmp 0x4031e1
;else if rdi is 3:
;	jmp 0x403298
;else:
;	jmp 0x403321
;
; Please do the above with the following constraints:
;  Assume rdi will NOT be negative
;  Use no more than 1 cmp instruction
;  Use no more than 3 jumps (of any variant)
;  We will provide you with the number to switch on in rdi.
;  We will provide you with a jump table base address in rsi.

main:
cmp rdi, 3
jbe here
mov rdi, 4

here:
mov rax, [8 * rdi + rsi]
jmp rax
