section .note.GNU-stack noalloc noexec nowrite progbits

SIZE equ 5

section .text
default rel

global main

extern atoi
extern itoa

main:
    cmp rdi, 3   ; Check is there any arguments
    jb print_zero

    add rsi, 8   ; Stop to first number

    sub rsp, 256 ; Reserve space for buffer

    cmp rdi, 3
    je check_unary_operator

    cmp rdi, 4
    je check_binary_operator

    jmp print_zero

    check_unary_operator:
        ; convert number
        mov rdi, [rsi + 8]
        call atoi wrt ..plt

        mov rdi, rax
        mov rbx, [rsi]

        cmp byte [rbx], '-'
        je negate

        cmp byte [rbx], '~'
        je not_operator

        call print_zero

    check_binary_operator:
        ; convert first number
        mov rdi, [rsi]
        call atoi wrt ..plt
        mov rbx, rax

        ; convert second number
        mov rdi, [rsi + 16]
        call atoi wrt ..plt

        mov rdi, rbx
        mov rbx, [rsi + 8]
        mov rsi, rax

        cmp byte [rbx], '+'
        je addition

        cmp byte [rbx], '-'
        je substitution

        cmp byte [rbx], '*'
        je multiplication

        cmp byte [rbx], '/'
        je division

        cmp byte [rbx], '&'
        je and_operator

        cmp byte [rbx], '|'
        je or_operator

        cmp byte [rbx], '^'
        je xor_operator

        call print_zero

    negate:
        neg rdi
        jmp convert_result_to_ascii

    not_operator:
        not rdi
        jmp convert_result_to_ascii

    addition:
        add rdi, rsi
        jmp convert_result_to_ascii

    substitution:
        sub rdi, rsi
        jmp convert_result_to_ascii

    multiplication:
        imul rdi, rsi
        jmp convert_result_to_ascii

    division:
        xor rdx, rdx
        mov rax, rdi
        div rsi
        mov rdi, rax

        cmp rdx, 0
        je convert_result_to_ascii

        mov rbx, rsi
        xor rsi, rsi
        xor rcx, rcx

        division_loop:
            cmp rcx, SIZE
            jae trim_division

            inc rcx

            mov rax, rdx
            imul rax, 10
            xor rdx, rdx
            div rbx

            imul rsi, 10
            add rsi, rax

            cmp rdx, 0
            je convert_double_to_ascii

            jmp division_loop

        trim_division:
            cmp rdx, 5
            jb division_finish
            inc rsi

        division_finish:
            jmp convert_double_to_ascii

    and_operator:
        and rdi, rsi
        jmp convert_result_to_ascii

    or_operator:
        or rdi, rsi
        jmp convert_result_to_ascii

    xor_operator:
        xor rdi, rsi
        jmp convert_result_to_ascii

    convert_result_to_ascii:
        mov rsi, rsp
        call itoa wrt ..plt

        mov rdi, rsi
        mov rsi, rax
        call print_result
        jmp finish

    convert_double_to_ascii:
        mov rcx, rsi
        mov rsi, rsp

        call itoa wrt ..plt

        mov byte [rsi + rax], '.'

        inc rax
        add rsi, rax
        mov rdi, rcx
        mov rcx, rax

        call itoa wrt ..plt

        add rax, rcx

        convert_double_to_ascii_finish:
            mov rdi, rsp
            mov rsi, rax
            call print_result
            jmp finish

    jmp print_zero

    print_zero:
        sub rsp, 16           ; Reserve space for buffer
        mov byte [rsp], '0'   ; Put '0' to stack for output
        mov byte [rsp + 1], 0 ; NULL terminated symbol
        mov rdi, rsp          ; Size of output
        mov rsi, 2            ; Buffer output
        call print_result
        add rsp, 16           ; Free space
        jmp finish

print_result:
    mov rdx, rsi ; The number of bytes to write
    mov rsi, rdi ; Write the from the stack
    mov rdi, 1   ; The stdout file descriptor
    mov rax, 1   ; System call number of write()
    syscall      ; Do the system call
    ret

finish:
    add rsp, 256   ; Free space
    mov rdi, 0x2a
    mov rax, 0x3c
    syscall
