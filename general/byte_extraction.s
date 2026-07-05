section .text
    global main

; Perform the following:
; Set `rax` to the 5th least significant byte of `rdi`;
;
; For example:
;   rdi = | B7 | B6 | B5 | B4 | B3 | B2 | B1 | B0 |
;   Set rax to the value of B4

; +---------------------------------------+
; | B7 | B6 | B5 | B4 | B3 | B2 | B1 | B0 |
; +---------------------------------------+
; shl rdi, 24
; +---------------------------------------+
; | B4 | B3 | B2 | B1 | B0 | 0  | 0  | 0  |
; +---------------------------------------+
; shr rdi, 56
; +---------------------------------------+
; | 0  | 0  | 0  | 0  | 0  | 0  | 0  | B4 |
; +---------------------------------------+

main:
shl rdi, 24
shr rdi, 56
mov rax, rdi
