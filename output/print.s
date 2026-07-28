section .note.GNU-stack noalloc noexec nowrite progbits

section .text
default rel

global main

extern atoi
extern itoa

main:
    cmp rdi, 1   ; Check is there any arguments
    je exit_error

    add rsi, 8   ; Remove first argument which represent executable name
    sub rsp, 256 ; Reserve space for buffer

    mov rbx, [rsi]
    
    mov r9, rsp

    xor r10, r10

    add rsi, 8
    lea r11, [rsi] ; Save pointer in case of additional args
    mov r12, rdi   ; Total args count
    sub r12, 2     ; Remove count for first arg that is program name and original string

    xor r13, r13   ; Counter for used args

    args_loop:
        mov dl, byte [rbx]

        cmp dl, 0
        je finish_loop

        cmp dl, 0x5c ; '\'
        je parse_slash

        cmp dl, 0x25 ; '%'
        je parse_decimal

        jmp parse_symbol

        parse_slash:
            cmp word [rbx], 0x5c5c ; '\\'
            je parse_5c5c

            cmp word [rbx], 0x6e5c ; '\n'
            je parse_6e5c

            cmp word [rbx], 0x745c ; '\t'
            je parse_745c

            cmp word [rbx], 0x765c ; '\v'
            je parse_765c

            cmp word [rbx], 0x785c ; '\x'
            je parse_785c

            jmp parse_symbol

            parse_5c5c:
                mov byte [r9 + r10], 0x5c
                jmp parse_slash_finish

            parse_6e5c:
                mov byte [r9 + r10], 0x0a 
                jmp parse_slash_finish

            parse_745c:
                mov byte [r9 + r10], 0x09
                jmp parse_slash_finish

            parse_765c:
                mov byte [r9 + r10], 0x0b
                jmp parse_slash_finish

            parse_785c:
                add rbx, 2

                xor rax, rax
                xor rcx, rcx

                mov al, byte [rbx]
                ; Jump if value less then '0' 
                cmp al, 0x30
                jb exit_error

                ; Jump if value less then '9' 
                sub al, 0x30
                cmp al, 9
                ja exit_error

                mov cl, byte [rbx + 1]
                ; Jump if value less then '0' 
                cmp cl, 0x30
                jb exit_error

                ; Jump if value is digit
                sub cl, 0x30
                cmp cl, 9
                jbe parse_785c_finish

                ; Throw error if value is greater then 'f'
                mov cl, byte [rbx + 1]
                sub cl, 0x66
                cmp cl, 0
                jg exit_error

                ; Finish if value is in ragne 'a'...'f'
                mov cl, byte [rbx + 1]
                sub cl, 0x61
                add cl, 10
                cmp cl, 10
                jge parse_785c_finish

                ; Throw error if value is greater then 'F'
                mov cl, byte [rbx + 1]
                sub cl, 0x46
                cmp cl, 0
                jg exit_error

                ; Throw error if value is less then 'A'
                mov cl, byte [rbx + 1]
                sub cl, 0x41
                add cl, 10
                cmp cl, 10
                jl exit_error

                parse_785c_finish:
                    shl rax, 4
                    add al, cl
                    mov byte [r9 + r10], al

                jmp parse_slash_finish

            parse_slash_finish:
                inc r10
                add rbx, 2
                jmp args_loop

            jmp args_loop

        parse_decimal:
            cmp word [rbx], 0x2525 ; %%
            je parse_2525

            cmp word [rbx], 0x6425 ; %d
            je parse_6425

            cmp word [rbx], 0x7325 ; %s
            je parse_7325

            jmp parse_symbol

            parse_2525:
                mov byte [r9 + r10], 0x25
                inc r10
                add rbx, 2
                jmp args_loop

            parse_6425:
                cmp r13, r12    ; Check if argument is provided
                jae exit_error

                mov rdi, [r11]
                
                ; The "atoi" and "itoa" messing with r10 and r11, so need to push to stack
                push r11
                push r10
                call atoi wrt ..plt

                mov rdi, rax
                ; Need value that stored in r10 but now in stack,
                ; so need to restore and then again put to stack
                ; so later it can be restored from stack after "itoa" replacing it 
                pop r10
                push r10
                lea rsi, [r9 + r10]
                call itoa wrt ..plt

                ; Restore values from stack
                pop r10
                pop r11
                inc r13    ; Increment number of used arguments
                add r11, 8 ; Jump to next program argument pointer
                add r10, rax
                add rbx, 2
                jmp args_loop

            parse_7325:
                cmp r13, r12    ; Check if argument is provided
                jae exit_error

                mov rdi, [r11]
                parse_7325_loop:
                    mov al, byte [rdi]
                    cmp al, 0x0
                    je parse_7325_finish

                    mov byte [r9 + r10], al
                    inc r10
                    inc rdi

                    jmp parse_7325_loop

                parse_7325_finish:
                    inc r13    ; Increment number of used arguments
                    add r11, 8 ; Jump to next program argument pointer
                    add rbx, 2
                    jmp args_loop

            jmp args_loop

        parse_symbol:
            mov byte [r9 + r10], dl 
            inc r10
            inc rbx
            jmp args_loop

        jmp args_loop

    jmp exit_error

    finish_loop:
        mov rdi, r9
        mov rsi, r10
        jmp print_result

print_result:
    mov rdx, rsi ; The number of bytes to write
    mov rsi, rdi ; Write the from the stack
    mov rdi, 1   ; The stdout file descriptor
    mov rax, 1   ; System call number of write()
    syscall      ; Do the system call
    jmp exit_success

exit_error:
    mov rdi, 0x1  ; exit error code = 1 
    jmp finish

exit_success:
    xor rdi, rdi ; exit code = 0

finish:
    add rsp, 256  ; Release buffer
    mov rax, 0x3c ; sys_exit
    syscall
    ret
