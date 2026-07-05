.global atoi_digit
.global itoa_digit
.global atoi
.global itoa
.global _start

_start:
    push rbx
    push r12
    push r13

    xor r13, r13
    mov r12, [rsp]
    cmp r12, 0
    je finish

    sub r12, 1
    lea rbx, [rsp + 8]

    loop:
        test r12, r12
        js print_result

        mov rdi, [rbx]
        call atoi

        add r12, rax

        sub r12, 1
        add rbx, 8

        jmp loop

    print_result
        mov rdi, rbx
        sub rsp, 32
        lea rsi, [rsp]

        call itoa

        mov rdi, 1 # the stdout file descriptor
        mov rsi, rsp # write the from the stack
        mov rdx, rax # the number of bytes to write
        mov rax, 32 # system call number of write()
        syscall # do the system call

        add rsp, 32

    finish:
        pop r13
        pop r12
        pop rbx
        mov rdi, 0x2a
        mov rax, 0x3c
        syscall

itoa_digit:
    mov rax, rdi
    add rax, 0x30
    ret

itoa:
    xor rcx, rcx # array size
    mov r9, rdi  # input number
    mov r10, 10  # devider
    xor r11, r11 # out size

    cmp r9, 0
    jne check_neg # not equal

    call itoa_digit
    mov [rsi], al
    mov byte ptr [rsi + 1], 0
    mov r11, 1
    jmp done

    check_neg:
        test r9, r9 # tests the register against itself, just to set the flags
        jns size_loop # jump if not sign (>= 0)

        inc rcx
        mov byte ptr [rsi], 0x2d
        neg rdi
        mov r9, rdi

    size_loop:
        cmp r9, 0        
        je prep_loop

        xor rdx, rdx
        mov rax, r9
        div r10
        inc rcx
        mov r9, rax

        jmp size_loop

    prep_loop:
        mov r9, rdi
        mov byte ptr[rsi + rcx], 0
        mov r11, rcx
        sub rcx, 1
    loop:
        cmp r9, 0
        je done

        xor rdx, rdx # clear reminder
        mov rax, r9
        div r10

        mov r9, rax
        mov rdi, rdx
        call itoa_digit
         
        mov [rsi + rcx], al
        sub rcx, 1

        jmp loop
    done:
        mov rax, r11
        ret

atoi_digit:
    mov r9, rdi
    sub r9, 0x30
    ret

atoi:
    xor rax, rax # return value
    xor rcx, rcx # size
    mov rdx, rdi # pointer to string

    size_loop:
        movzx r10, byte ptr[rdx + rcx]
        cmp r10, 0x2d # Check is negative number
        je increment
        cmp r10, 0 # Check if NULL terminated
        je prep_loop
        sub r10, 0x30 # Check if it is a number
        js prep_loop
        cmp r10, 9 # Check if it is a number
        ja prep_loop
   increment:
        inc rcx
        jmp size_loop
    prep_loop:
        sub rcx, 1
        mov r10, 1
    loop:
        movzx rdi, byte ptr[rdx + rcx]
        cmp rdi, 0x2d # Check is negative number
        je minus

        call atoi_digit

        imul r9, r10
        imul r10, 10
        add rax, r9
        
        sub rcx, 1
        test rcx, rcx
        js done

        jmp loop

    minus:
        neg rax

    done:
        ret

