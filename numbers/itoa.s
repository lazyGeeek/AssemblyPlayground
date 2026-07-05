section .note.GNU-stack noalloc noexec nowrite progbits

section .text
global itoa:function

; rdi - input number
; rsi - ouput buffer
itoa:
    xor rcx, rcx ; array size
    mov r10, 10  ; devider

    cmp rdi, 0
    jne check_neg ; Check if it zero and if not jump to check_neg

    ; It's zero return simple '0'
    mov byte [rsi], '0'
    mov byte [rsi + 1], 0 ; NULL terminator
    mov rax, 1            ; Return size of output string
    ret

    check_neg:
        test rdi, rdi ; Tests the register against itself, just to set the flags
        jns calculate_size ; Jump if not sign (>= 0)

        inc rcx
        mov byte [rsi], 0x2d ; Put '-' into begging of the output buffer
        neg rdi              ; Convert negative number in rdi into positive

    calculate_size:
        mov r9, rdi

        calculate_size_loop:
            cmp r9, 0
            je convert_number

            xor rdx, rdx ; Clear reminde
            mov rax, r9
            div r10
            inc rcx
            mov r9, rax

            jmp calculate_size_loop

    convert_number:
        push rcx
        mov byte [rsi + rcx], 0
        mov r11, rcx
        sub rcx, 1

        convert_number_loop:
            cmp rdi, 0
            je finish

            xor rdx, rdx ; Clear reminder
            mov rax, rdi
            div r10

            add rdx, 0x30 ; Convert from number to ASCII
            
            mov [rsi + rcx], dl
            sub rcx, 1

            mov rdi, rax

            jmp convert_number_loop

    finish:
        pop rax
        ret