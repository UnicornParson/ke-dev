#!/bin/bash

VM_NAME="${VM_NAME:-kedev-qemu-vm}"
RAM="${RAM:-8G}"
VCPUS="${VCPUS:-2}"
DISK_PATH="${DISK_PATH:-./data/ke02.qcow2}"
KE_BIN="${KE_BIN:-../../bin}"
KERNEL_CMDLINE="${KERNEL_CMDLINE:-console=ttyS0 root=/dev/mapper/ubuntu--vg-ubuntu--lv}"

if [ ! -f "$DISK_PATH" ]; then
    echo "Error: disk image $DISK_PATH not found"
    exit 1
fi
if [ ! -f "$KE_BIN/vmlinuz" ]; then
    echo "Error: kernel $KE_BIN/vmlinuz not found"
    exit 1
fi

INITRD_ARGS=""
[ -f "$KE_BIN/initrd.img" ] && INITRD_ARGS="-initrd $KE_BIN/initrd.img"

echo "Starting VM '$VM_NAME' (SSH port 2222 -> guest:22)"

qemu-system-x86_64 -enable-kvm \
    -name "$VM_NAME" \
    -m $RAM \
    -smp $VCPUS \
    -drive file="$DISK_PATH",format=qcow2,if=virtio \
    -netdev user,id=net0,hostfwd=tcp::2222-:22 \
    -device virtio-net,netdev=net0

#qemu-system-x86_64 -enable-kvm \
#    -name "$VM_NAME" \
#    -m "$RAM" \
#    -smp "$VCPUS" \
#    -kernel "$KE_BIN/vmlinuz" \
#    $INITRD_ARGS \
#    -append "$KERNEL_CMDLINE" \
#    -drive file="$DISK_PATH",format=qcow2,if=virtio \
#    -netdev user,id=net0,hostfwd=tcp::2222-:22 \
#    -device virtio-net,netdev=net0


#    -nographic