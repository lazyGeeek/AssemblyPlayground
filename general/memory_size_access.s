section .text
    global main

; Perform the following:
;   Set rax to the byte at 0x404000
;   Set rbx to the word at 0x404000
;   Set rcx to the double word at 0x404000
;   Set rdx to the quad word at 0x404000

; Quad word:    qword ptr
; Double word:  dword ptr
; Word:         word ptr
; Byte:         byte ptr

main:
mov al, byte ptr [0x404000]
mov bx, word ptr [0x404000]
mov ecx, dword ptr [0x404000]
mov rdx, qword ptr [0x404000]
