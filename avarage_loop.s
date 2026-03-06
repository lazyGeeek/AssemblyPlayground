section .text
    global main

; Please compute the average of n consecutive quad words, where:
;  rdi = memory address of the 1st quad word
;  rsi = n (amount to loop for)
;  rax = average computed

main:
mov rax, 0
mov rbx, 1
mov rax, [rdi]

loop:
cmp rbx, rsi
jg done
add rax, [rdi + rbx * 0x8]
add rbx, 1
jmp loop

done:
div rsi
