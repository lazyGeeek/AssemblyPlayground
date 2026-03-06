section .text
	global main

; Place compute the following and place the value in rax
; rdi % rsi

main:
mov rax, rdi
div rsi
mov rax, rdx
