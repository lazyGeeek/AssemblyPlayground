section .text
    global main

; Perform the following:
;   Load two consecutive quad words from the address stored in rdi
;   Calculate the sum of the previous steps quad words
;   Store the sum at the address in rsi

main:
mov rax, qword ptr [rdi]
mov rbx, qword ptr [rdi + 8]
add rax, rbx
mov [rsi], rax
