section .note.GNU-stack noalloc noexec nowrite progbits

section .text
default rel

global main

SYS_read   equ 0
SYS_write  equ 1
SYS_open   equ 2
SYS_close  equ 3
SYS_socket equ 41
SYS_accept equ 43
SYS_bind   equ 49
SYS_listen equ 50
SYS_fork   equ 57
SYS_exit   equ 60

AF_INET     equ 2
SOCK_STREAM equ 1

BUFFER_SIZE equ 1024

main:
    ; Call "socket(AF_INET, SOCK_STREAM, IPROTO_IP) = fd"
    ; AF_INET = 2
    ; SOCK_STREAM = 1
    ; IPROTO_IP = 0
    mov rax, SYS_socket
    mov rdi, AF_INET
    mov rsi, SOCK_STREAM
    xor rdx, rdx
    syscall

    ; Check error
    test rax, rax
    jl exit_error

    mov [rel server_fd], rax

    ; Call "bind(fd, sockaddr, sizeof(sockaddr)) = 0"
    mov rax, SYS_bind
    mov rdi, [rel server_fd]
    lea rsi, [rel sockaddr]
    mov rdx, 16 ; Size of sockaddr
    syscall

    ; Check error
    test rax, rax
    jl exit_error

    ; Call "listen(fd, 0) = 0"
    ; 1 is number of expected connections
    mov rax, SYS_listen
    mov rdi, [rel server_fd]
    xor rsi, rsi
    syscall

    ; Check error
    test rax, rax
    jl exit_error

    accept_loop:
        ; Call "accept(fd, NULL, NULL) = 4"
        mov rax, SYS_accept
        mov rdi, [rel server_fd]
        xor rsi, rsi
        xor rdx, rdx
        syscall

        ; Check error
        test rax, rax
        jl accept_loop

        mov rdx, rax

        ; fork()
        mov rax, SYS_fork
        syscall

        test rax, rax
        js stop_server

        jnz parent_process

        mov rax, SYS_close
        mov rdi, [rel server_fd]
        syscall

        mov rdi, rdx
        call handle_response

        parent_process:
            mov rdi, rdx
            mov rax, 3
            syscall

    jmp accept_loop

stop_server:
    ; Close server file descriptor
    ; Call "close(fd)"
    mov rax, SYS_close
    mov rdi, [rel server_fd]
    syscall

    test rax, rax
    jl exit_error

exit_success:
    xor rdi, rdi ; exit code = 0
    jmp finish

exit_error:
    mov rdi, 0x1 ; exit error code = 1

finish:
    mov rax, SYS_exit ; sys_exit
    syscall

handle_response:
    push rbp
    mov rbp, rsp
    sub rsp, BUFFER_SIZE

    mov rbx, rdi

    ; read(client_fd, buffer, BUFFER_SIZE)
    mov rax, SYS_read
    mov rdi, rbx
    lea rsi, [rbp - BUFFER_SIZE]
    mov rdx, BUFFER_SIZE
    syscall

    test rax, rax
    jle exit_handle_response

    mov byte [rbp - BUFFER_SIZE + rax], 0x0

    lea rdi, [rbp - BUFFER_SIZE]
    call check_request

    cmp rax, 1
    je call_get_response

    cmp rax, 2
    je call_post_response

    jmp exit_handle_response

    call_get_response:
        mov rdi, rbx
        lea rsi, [rbp - BUFFER_SIZE]
        call get_response
        jmp exit_handle_response

    call_post_response:
        mov rdi, rbx
        lea rsi, [rbp - BUFFER_SIZE]
        call post_response
        jmp exit_handle_response

    exit_handle_response:
        leave
        ret

check_request:
    ; 0x47 0x45 0x54 0x20 - GET
    ; 0x50 0x4F 0x53 0x54 - POST
    ; 0x53 0x54 0x4F 0x50 - STOP
    cmp dword [rdi], 0x20544547
    je return_get

    cmp dword [rdi], 0x54534F50
    je return_post

    cmp dword [rdi], 0x504F5453
    je return_stop

    xor rax, rax
    ret

return_get:
    mov rax, 1
    ret

return_post:
    mov rax, 2
    ret

return_stop:
    mov rax, -1
    ret

get_response:
    push rcx
    push rbp

    mov rbp, rsp
    sub rsp, BUFFER_SIZE

    mov [rsp - 8], rdi ; client_fd

    add rsi, 5
    xor rcx, rcx ; counter

    parse_get_loop:
        cmp byte [rsi + rcx], 0x20
        je finish_parse_get_loop

        inc rcx
        jmp parse_get_loop

    finish_parse_get_loop:
        mov byte [rbp - BUFFER_SIZE + rcx], 0x0

        ; Copy file name from Client message
        cld                          ; DF = 0 for forward copying
        lea rdi, [rbp - BUFFER_SIZE] ; Destination
        rep movsb

        ; Open file to read file content
        ; open("read_file", O_RDONLY)
        mov rax, SYS_open ; 257 - open_at
        lea rdi, [rbp - BUFFER_SIZE]
        xor rsi, rsi
        xor rdx, rdx
        syscall

        ; Check error
        test rax, rax
        jl finish_get_response

        mov [rsp - 16], rax

        ; Copy "http_msg" to buffer
        cld                          ; DF = 0 for forward copying
        lea rsi, [rel http_msg]      ; Source
        lea rdi, [rbp - BUFFER_SIZE] ; Destination
        mov rcx, http_msg_len        ; Number of bytes
        rep movsb

        ; Read file content into buffer
        ; read(5, "read_file", 128)
        mov rdi, [rsp - 16]
        lea rsi, [rbp - BUFFER_SIZE + http_msg_len]
        mov rdx, BUFFER_SIZE - http_msg_len
        mov rax, 0
        syscall

        mov [rsp - 24], rax

        ; close open "read_file"
        mov rdi, [rsp - 16]
        mov rax, SYS_close
        syscall

        ; Call "write(clientFd, output_buff, message_len)"
        mov rdi, [rsp - 8]
        lea rsi, [rbp - BUFFER_SIZE]
        mov rdx, http_msg_len
        add rdx, [rsp - 24] ; [rsp - 24] - Number of bytes from read function
        mov rax, SYS_write
        syscall

    finish_get_response:
        leave
        pop rcx
        ret

post_response:
    push rcx
    push rbp

    mov rbp, rsp
    sub rsp, BUFFER_SIZE

    mov [rsp - 8],  rdi ; client_fd
    mov [rsp - 16], rsi ; post message

    add rsi, 6
    xor rcx, rcx ; counter

    parse_post_name_loop:
        cmp byte [rsi + rcx], 0x20
        je finish_parse_post_name_loop

        inc rcx
        jmp parse_post_name_loop

    finish_parse_post_name_loop:
        mov byte [rbp - BUFFER_SIZE + rcx], 0x0

        ; Copy file name from Client message
        cld                          ; DF = 0 for forward copying
        lea rdi, [rbp - BUFFER_SIZE] ; Destination
        rep movsb

        ; Open file to write content to file
        ; open("write_file", O_WRONLY, 0)
        mov rax, SYS_open ; 257 - open_at
        lea rdi, [rbp - BUFFER_SIZE]
        mov rsi, 65 ; O_WRONLY(1) | O_CREAT(64) | O_TRUNC(512)
        mov rdx, 0777
        syscall

        ; Check error
        test rax, rax
        jl finish_post_response

        mov [rsp - 24], rax
        mov rsi, [rsp - 16]

        xor rcx, rcx ; counter

        skip_post_header_loop:
            ; 0D 0A 0D 0A - \r\n\r\n
            cmp dword [rsi + rcx], 0x0a0d0a0d
            je finish_post_header_loop

            inc rcx
            jmp skip_post_header_loop

        finish_post_header_loop:
            add rcx, 4
            add rsi, rcx

            xor rdx, rdx

            read_post_content_loop:
                cmp byte [rsi + rdx], 0x0
                je finish_read_post_content_loop

                inc rdx
                jmp read_post_content_loop

            finish_read_post_content_loop:
                ; Write content from buffer into file
                ; write(5, "write_file", BUFFER_SIZE)
                mov rdi, [rsp - 24]
                mov rax, SYS_write
                syscall

                mov rax, SYS_close
                mov rdi, [rsp - 24]
                syscall

                ; Call "write(clientFd, http_msg, http_msg_len)"
                mov rdi, [rsp - 8]
                lea rsi, [rel http_msg]
                mov rdx, http_msg_len
                mov rax, SYS_write
                syscall

                finish_post_response:
                    leave
                    pop rcx
                    ret

section .data
; sockaddr_in layout (16 bytes):
;   uint16_t sin_family   = AF_INET (2)
;   uint16_t sin_port     = htons(1337) -> 0x3905
;   uint32_t sin_addr     = 127.0.0.1
;   uint8_t  __pad[8]     = 0
sockaddr:
    db 2, 0                   ; sin_family = AF_INET
    db 0x05, 0x39             ; sin_port   = htons(1337)
    db 127, 0, 0, 1           ; sin_addr   = inet_addr("127.0.0.1")
    db 0, 0, 0, 0, 0, 0, 0, 0 ; __pad[8]

http_msg:
    http_msg db "HTTP/1.0 200 OK", 13, 10, 13, 10 ; 13 - \r; 10 - \n
    http_msg_len equ $ - http_msg

section .bss
    server_fd: resq 1

