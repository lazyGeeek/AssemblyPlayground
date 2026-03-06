section .text
    global main

; Implement the following:
;
;if [x] is 0x7f454c46:
;   y = [x+4] + [x+8] + [x+12]
;else if [x] is 0x00005A4D:
;   y = [x+4] - [x+8] - [x+12]
;else:
;   y = [x+4] * [x+8] * [x+12]
;
; where:
;  x = rdi, y = rax
; 
; Assume each dereferenced value is a `signed dword`.  
; This means the values can start as a negative value at each memory position.
; 
; A valid solution will use the following at least once:  
;  jmp (any variant), cmp

main:
mov rsi, [rdi]
mov eax, [rdi+4]
mov ebx, [rdi+8]
mov ecx, [rdi+12]

cmp esi, 0x7f454c46
je handle_case_0x7f454c46

cmp esi, 0x00005A4D
je handle_case_0x00005A4D

default_case:
	imul ebx
	imul ecx
    int3
	jmp end
	
case_0x7f454c46:
	add eax, ebx
	add eax, ecx
	int3
	jmp end
	
case_0x00005A4D:
	sub eax, ebx
	sub eax, ecx
    int3
	jmp end
	
end:  nop
