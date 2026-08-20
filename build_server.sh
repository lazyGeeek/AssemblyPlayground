nasm -f elf64 ./web/server.s -o ./build/server.o
# clang -g ./build/server.o -pie ./build/server.o -o ./bin/server -L./bin -litoa -latoi -Wl -rpath '$ORIGIN'
clang -g ./build/server.o -o ./bin/server
