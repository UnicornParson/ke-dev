#!/bin/bash
set -e

# Проверка обязательных переменных окружения
#if [ -z "$HEADERS_ALL_URL" ] || [ -z "$HEADERS_ARCH_URL" ]; then
#    echo "ERROR: HEADERS_ALL_URL and HEADERS_ARCH_URL must be set"
#    exit 1
#fi

#echo "Downloading kernel headers..."
#wget -O /tmp/headers_all.deb "$HEADERS_ALL_URL"
#wget -O /tmp/headers_arch.deb "$HEADERS_ARCH_URL"

#echo "Installing kernel headers..."
#dpkg -i /tmp/headers_all.deb /tmp/headers_arch.deb || true
#apt-get install -f -y   # исправляем возможные проблемы с зависимостями

# Проверка наличия заголовков для текущей версии ядра (хоста)
#KERNEL_VERSION=$(uname -r)
#if [ ! -d "/usr/src/linux-headers-$KERNEL_VERSION" ]; then
#    echo "WARNING: Headers for kernel $KERNEL_VERSION not found in /usr/src. Build may fail."
#fi

# Монтируемая директория с исходным кодом
if [ ! -d "/src" ]; then
    echo "ERROR: /src directory not mounted. Please mount your source code to /src"
    exit 1
fi

cd /

echo "Building eBPF program..."
/bpf_test/build.sh

# Проверка успешной сборки
if [ ! -f "build/ebpf_trap" ]; then
    echo "ERROR: Build failed, binary not found"
    exit 1
fi

# Копирование результата в выходную директорию
if [ -d "/output" ]; then
    cp build/ebpf_trap /output/
    echo "Binary copied to /output/ebpf_trap"
else
    echo "WARNING: /output not mounted, binary remains in /src/build"
fi

echo "Build completed successfully."