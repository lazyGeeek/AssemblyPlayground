# Compiling assembly

```sh
nasm -f win64 program.s -o program.obj 
clang program.obj -o program.exe
```

# Other

## Headers for portable GNU assembler

```sh
.intel_syntax noprefix
.global _start
_start:
```

## Compile using GNU compiler

```sh
as -o program.o program.s
ld -o program program.o
```
