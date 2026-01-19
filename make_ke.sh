#!/usr/bin/env bash

set -euo pipefail

KERNEL_DIR="kernel/stable"
BIN_DIR="bin"
LOGFILE="$PWD/tmp/make_ke.log"
BASE_DIR=$PWD
touch $LOGFILE

echo "Building kernel..."
if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <path-to-kernel-config>"
    exit 1
fi

CONFIG_PATH="$1"

if [[ ! -f "$CONFIG_PATH" ]]; then
    echo "Error: config file not found: $CONFIG_PATH"
    exit 1
fi

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

# Полная очистка дерева
make mrproper 2>&1 | tee -ai "$LOGFILE"

# Копируем конфиг прямо в .config
cp -vf "$BASE_DIR/$CONFIG_PATH" .config | tee -ai "$LOGFILE"

# Актуализируем конфиг
make olddefconfig 2>&1 | tee -ai "$LOGFILE"

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

# Копирование результатов
rm -f \
    "$BASE_DIR/$BIN_DIR/bzImage" \
    "$BASE_DIR/$BIN_DIR/vmlinux" \
    "$BASE_DIR/$BIN_DIR/kernel.config"

cp "$BZIMAGE" "$BASE_DIR/$BIN_DIR/bzImage"
cp "$VMLINUX" "$BASE_DIR/$BIN_DIR/vmlinux"
cp ".config" "$BASE_DIR/$BIN_DIR/kernel.config"

echo "Kernel build completed successfully" | tee -ai "$LOGFILE"
