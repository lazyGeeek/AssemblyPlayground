section .text
	global main

main:
; Reading bytes from the "/flag" file
; open("/flag", 0);

mov rdi, [rsp+16] ; load a pointer to the filename (stored at [rsp+16], the first argument)
mov rsi, 0 ; specify the default of read access for the second argument
mov rax, 2 ; calling open function
syscall ; do the system call

; file descriptor store in the rax

; Reading 100 bytes from stdin to the stack:
; n = read(0, buf, 100);

mov rdi, 0 ; the stdin file descriptor
mov rsi, rsp ; read the data onto the stack
mov rdx, 100 ; the number of bytes to read
mov rax, 0 ; system call number of read()
syscall ; do the system call

; read returns the number of bytes read via rax
; write(1, buf, n);

mov rdi, 1 ; the stdout file descriptor
mov rsi, rsp ; write the from the stack
mov rdx, rax ; the number of bytes to write
mov rax, 1 ; system call number of write()
syscall ; do the system call

mov rdi, 0x2a
mov rax, 0x3c
syscal
