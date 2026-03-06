section .text
	global main

; Compute the following and place the result into rax
; f(x) = mx + b, where:
;	m = rdi
;	x = rsi
;	b = rdx

main:
mov rax, rdi
mul rsi
add rax, rdx
