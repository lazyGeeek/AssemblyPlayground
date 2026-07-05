section .text
	global main

; Compute the folowing
; speed = distance / time, where:
;	distance = rdi
;	time = rsi
;	speed = rax

main:
mov rax, rdi
div rsi
