.intel_syntax noprefix
.global  str_swapcase
str_swapcase:
    .loop:
        mov al, BYTE PTR[rdi]
        test al, al
        je .done
        ; or al, 0x20 ; make lower case
        ; and al, 0xDF ; make upper case
        xor al, 0x20 ; swap case
        mov BYTE PTR[rdi], al
        inc rdi
        jmp .loop
     .done:
        ret