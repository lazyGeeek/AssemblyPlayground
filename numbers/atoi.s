section .note.GNU-stack noalloc noexec nowrite progbits

section .text
global atoi:function

; rdi - input string
atoi:
    convert_string:
        xor rax, rax ; Output number
        xor rcx, rcx ; Counter

        check_neg:
            cmp byte [rdi], '-' ; Check if it's negative number
            jne convert_string_loop
            inc rcx

        convert_string_loop:
            movzx rdx, byte [rdi + rcx]

            cmp rdx, 0 ; Check if it's a NULL terminated
            je minus
            
            sub rdx, 0x30 ; Convert to a number
            js minus
            
            cmp rdx, 9 ; Check if it's a number
            ja minus

            imul rax, 10
            add rax, rdx
            
            inc rcx
            jmp convert_string_loop

        minus:
            cmp byte [rdi], '-' ; Check if it's negative number
            jne finish

            neg rax

    finish:
        ret