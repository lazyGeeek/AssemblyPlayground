section .text
    global main

; Please implement the following logic:  
;
;str_lower(src_addr):
;	i = 0
;	if src_addr != 0:
;		while [src_addr] != 0x00:
;			if [src_addr] less than or equal to 0x5a:
;				[src_addr] = foo([src_addr])
;				i += 1
;			src_addr += 1
; 	return i
; 
; foo is provided at 0x403000.
; foo takes a single argument as a value and returns a value.
; 
; All functions (foo and str_lower) must follow the Linux amd64 calling convention (also known as System V AMD64 ABI):  
;  https://en.wikipedia.org/wiki/X86_calling_conventions#System_V_AMD64_ABI
; 
; Therefore, your function str_lower should look for src_addr in rdi and place the function return in rax.
; 
; An important note is that src_addr is an address in memory (where the string is located) and [src_addr] refers to the byte that exists at src_addr.
; 
; Therefore, the function foo accepts a byte as its first argument and returns a byte.

main:
mov rax, 0                # Set counter to 0

cmp rdi, 0                # Check if src_addr = 0
je done

while_loop:
xor rbx, rbx
mov bl, [rdi]             # Move 1 byte of data into bl from src_addr
cmp bl, 0                 # Check if [src_addr] = 0x00
je done

cmp bl, 90                # Check if [src_addr] <= 0x5ajg greater_than_0x5a

push rdi                  # Preserve src_addr
push rax                  # Preserve counter
mov rdi, 0
mov dil, bl               # Set up 1 byte as the argument for foo()
mov r10, 0x403000
call r10                  # Call foo()
mov bl, al                # Move result of foo() into bl
pop rax                   # Restore counter
pop rdi                   # Restore src_addr
mov [rdi], bl             # Replace original byte by result of foo()
add rax, 1                # Increase counter

greater_than_0x5a:
add rdi, 1                # Point ot next byte at src_addr
jmp while_loop            # Repear while loop

done:
ret
