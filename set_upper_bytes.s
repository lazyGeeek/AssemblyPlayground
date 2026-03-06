section .text
    global main

; Set the upper 8 bits of the ax register to 0x42.
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
mov ah, 0x42
