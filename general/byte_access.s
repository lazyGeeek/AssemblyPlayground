section .text
    global main

; Perform the following:
;   Set rax to the byte at 0x404000

; Quad word:    qword ptr
; Double word:  dword ptr
; Word:         word ptr
; Byte:         byte ptr

main:
mov rax, byte ptr [0x404000]
