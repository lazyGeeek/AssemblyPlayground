section .note.GNU-stack noalloc noexec nowrite progbits

section .text
default rel

global main

extern atoi
extern itoa

main:
    cmp rdi, 1   ; Check is there any arguments
    je print_zero

    sub rdi, 1   ; Remove first argument which represent executable name

    xor rbx, rbx ; Final sum

    sub rsp, 255 ; Reserve space for buffer

    args_loop:
        cmp rdi, 0
        je convert_sum_to_ascii

        add rsi, 8

        push rdi
        mov rdi, [rsi]

        call atoi wrt ..plt

        add rbx, rax
        pop rdi
        sub rdi, 1

        jmp args_loop

    convert_sum_to_ascii:
        mov rdi, rbx
        mov rsi, rsp

        call itoa wrt ..plt

    print_result:
        mov rdi, rsi
        mov rsi, rax
        call print_sum

    add rsp, 255 ; Free space
    jmp finish

    print_zero:
        sub rsp, 16           ; Reserve space for buffer
        mov byte [rsp], '0'   ; Put '0' to stack for output
        mov byte [rsp + 1], 0 ; NULL terminated symbol
        mov rdi, rsp          ; Size of output
        mov rsi, 2            ; Buffer output
        call print_sum
        add rsp, 16           ; Free space
        jmp finish
    
    finish:
        mov rdi, 0x2a
        mov rax, 0x3c
        syscall

print_sum:
    mov rdx, rsi ; The number of bytes to write
    mov rsi, rdi ; Write the from the stack
    mov rdi, 1   ; The stdout file descriptor
    mov rax, 1   ; System call number of write()
    syscall      ; Do the system call
    ret
