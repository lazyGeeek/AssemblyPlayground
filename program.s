.intel_syntax noprefix
.global _start
_start:

# rdi is scr_addr, rsi is size

# init rcx as a counter
xor rcx, rcx # rcx is 'i'
xor rbx, rbx # rbx is 'curr_byte'

push rbp # Setup base of the stack
mov rbp, rsp
mov rsp, rsi # Move stack to 'size' values down

while_size:

cmp rcx, rsi      # i <= size-1
jae end_while_size

movzx eax, byte ptr [rdi+rcx] # curr_byte = [src_addr + i]

# curr_byte * 2
mov ebx, 2
mul ebx

# stack_base - curr_byte * 2
mov rdx, rbp
sub rdx, rax
sub rdx, 8

inc word ptr[rdx] # [stack_base - curr_byte * 2] += 1
xor rdx, rdx

inc rcx # i += 1

jmp while_size

end_while_size:

xor rcx, rcx # b = 0
xor r9, r9 # max_freq = 0
xor r10, r10 # max_freq_byte = 0

while_less_then_0xff:

# while b <= 0xff
cmp rcx, 0xff
ja end_while_less_then_0xff

#  b * 2
mov eax, ecx
mov edx, 2
mul edx

# stack_base - b * 2# while b <= 0xff
cmp rcx, 0xff
ja end_while_less_then_0xff

#  b * 2
mov eax, ecx
mov edx, 2
mul edx

# stack_base - b * 2
mov rdx, rbp
sub rdx, rax
sub rdx, 8

# if [stack_base - b * 2] > max_freq
cmp word ptr [rdx], r9w
jna less_then_0xff

movzx r9, word ptr [rdx] # max_freq = [stack_base - b * 2]
mov r10, rcx # max_freq_byte = b

less_then_0xff:
inc  rcx # b += 1
jmp while_less_then_0xff # Return back to while

end_while_less_then_0xff:

done:
mov rax, r10
mov rsp, rbp  # Restore the allocated space
pop rbp
ret
mov rdx, rbp
sub rdx, rax
sub rdx, 8

# if [stack_base - b * 2] > max_freq
cmp word ptr [rdx], r9w
jna less_then_0xff

movzx r9, word ptr [rdx] # max_freq = [stack_base - b * 2]
mov r10, rcx # max_freq_byte = b

less_then_0xff:
inc  rcx # b += 1
jmp while_less_then_0xff # Return back to while

end_while_less_then_0xff:

done:
mov rax, r10
mov rsp, rbp  # Restore the allocated space
pop rbp
ret
