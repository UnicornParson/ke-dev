#!/usr/bin/env bash

set -euo pipefail

KERNEL_DIR="kernel/dev"
BIN_DIR="bin"
LOGFILE="$PWD/tmp/make_ke.log"
BASE_DIR=$PWD
touch $LOGFILE

echo "Building kernel..."

if [[ ! -d "$KERNEL_DIR" ]]; then
    echo "Error: kernel directory not found: $KERNEL_DIR"
    exit 1
fi

if [[ ! -d "$BIN_DIR" ]]; then
    echo "Error: bin directory not found: $BIN_DIR"
    exit 1
fi

mkdir -p "$(dirname "$LOGFILE")"

echo "build ke" > "$LOGFILE"

cd "$KERNEL_DIR"



# Сборка ядра
make -j"$(nproc)" 2>&1 | tee -ai "$LOGFILE"

# Проверка артефактов
BZIMAGE="arch/x86/boot/bzImage"
VMLINUX="vmlinux"

if [[ ! -f "$BZIMAGE" ]]; then
    echo "Error: bzImage not produced" | tee -ai "$LOGFILE"
    exit 1
fi

if [[ ! -f "$VMLINUX" ]]; then
    echo "Error: vmlinux not produced" | tee -ai "$LOGFILE"
    exit 1
fi

echo "bin cleanup"
rm -vf \
    "$BASE_DIR/$BIN_DIR/bzImage" \
    "$BASE_DIR/$BIN_DIR/vmlinux" \
    "$BASE_DIR/$BIN_DIR/kernel.config"\
    "$BASE_DIR/$BIN_DIR/vmlinuz"

cp "$BZIMAGE" "$BASE_DIR/$BIN_DIR/bzImage"
cp "$BZIMAGE" "$BASE_DIR/$BIN_DIR/vmlinuz"
cp "$VMLINUX" "$BASE_DIR/$BIN_DIR/vmlinux"
cp ".config" "$BASE_DIR/$BIN_DIR/kernel.config"

echo "Kernel build completed successfully" | tee -ai "$LOGFILE"
