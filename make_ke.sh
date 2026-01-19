#!/usr/bin/env bash

set -euo pipefail

KERNEL_DIR="kernel/stable"
BIN_DIR="bin"
BASE_DIT="$PWD"
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

# Temporary build directory
BUILD_DIR="tmp/make_ke"
rm -rf "$BUILD_DIR"
mkdir -p $BUILD_DIR
LOGFILE="tmp/make_ke.log"
cleanup() {
    rm -rf "$BUILD_DIR"
}
trap cleanup EXIT

# Prepare kernel config
cp -vf "$CONFIG_PATH" "$KERNEL_DIR/.config"
cd "$KERNEL_DIR"
# Configure and build kernel out-of-tree
echo "build ke" > $LOGFILE # new file
make -C "$KERNEL_DIR" O="$BUILD_DIR" clean

make mrproper

make -C "$KERNEL_DIR" O="$BUILD_DIR" olddefconfig 2>&1 | tee -ai "$LOGFILE"
make -C "$KERNEL_DIR" O="$BUILD_DIR" -j"$(nproc)" 2>&1 | tee -ai "$LOGFILE"

# Expected artifacts
BZIMAGE="$BUILD_DIR/arch/x86/boot/bzImage"
VMLINUX="$BUILD_DIR/vmlinux"

if [[ ! -f "$BZIMAGE" ]]; then
    echo "Error: bzImage not produced"
    exit 1
fi

if [[ ! -f "$VMLINUX" ]]; then
    echo "Error: vmlinux not produced"
    exit 1
fi

# Atomically replace kernel artifacts in bin/
rm -f \
    "$BIN_DIR/bzImage" \
    "$BIN_DIR/vmlinux" \
    "$BIN_DIR/kernel.config"

cp "$BZIMAGE" "$BIN_DIR/bzImage"
cp "$VMLINUX" "$BIN_DIR/vmlinux"
cp "$BUILD_DIR/.config" "$BIN_DIR/kernel.config"

echo "Kernel build completed successfully"
