section .text
    global main

; Compute the following:
; rax = rdi % 256
; rbx = rsi % 65536


; MSB                                    LSB
; +----------------------------------------+
; |                   rax                  |  64 bit
; +--------------------+-------------------+
;                      |        eax        |  32 bit
;                      +---------+---------+
;                                |   ax    |  16 bit
;                                +----+----+
;                                | ah | al |  8 bit each
;                                +----+----+

main:
mov rax, 0
mov rbx, 0
mov al, dil
mov bx, si
