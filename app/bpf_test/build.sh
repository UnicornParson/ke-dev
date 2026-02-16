#!/bin/bash
set -ex
cd /bpf_test
BUILD_DIR="build"
mkdir -p $BUILD_DIR

BPF_SRC="src/bpf/bpf_trap.c"
BPF_OBJ="${BUILD_DIR}/bpf_trap.bpf.o"
BPF_SKEL_H="src/bpf/bpf_trap.skel.h"  # или "${BUILD_DIR}/bpf_trap.skel.h"

# Компиляция BPF-объекта
clang -g -O2 -target bpf -D__TARGET_ARCH_x86 \
    -I/usr/include/x86_64-linux-gnu \
    -c "$BPF_SRC" -o "$BPF_OBJ"

# Генерация скелетного заголовка из объектного файла
bpftool gen skeleton "$BPF_OBJ" > "$BPF_SKEL_H"

# Сборка основной программы через CMake
cd $BUILD_DIR
echo "@@ $(pwd)"
cmake ..
make -j$(nproc)

cd ..