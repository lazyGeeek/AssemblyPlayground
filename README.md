# Compiling assembly

```sh
nasm -f win64 program.s -o program.obj 
clang program.obj -o program.exe
```

# Other

## Headers for portable GNU assembler on Linux using ld

```sh
.intel_syntax noprefix
.global _start
section .text

_start:
```

## Headers for Windows clang

```sh
default rel
global main
extern ExitProcess

section .text
main:
```

## Compile using GNU compiler

```sh
as -o program.o program.s
ld -o program program.o
```
