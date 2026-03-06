section .text
    global main

; Using only following instructions: push, pop
; Swap values in rdi and rsi.  
; If to start rdi = 2 and rsi = 5  
; Then to end rdi = 5 and rsi = 2

main:
push rdi
push rsi
pop rdi
pop rsi
