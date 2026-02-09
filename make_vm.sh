#!/usr/bin/env bash
set -euo pipefail

# -------- configuration --------
HOME_DIR="$(pwd)"
KERNEL_DIR="$(pwd)/kernel/stable"
WORKDIR="$(pwd)/vm"
INITRAMFS_OUT="$(pwd)/vm/initramfs.cpio.gz"
BUSYBOX_BIN="$(command -v busybox)"
ARCH="x86_64"
# --------------------------------

if [[ -z "$BUSYBOX_BIN" ]]; then
    echo "busybox not found"
    exit 1
fi

if ! command -v qemu-system-x86_64 >/dev/null; then
    echo "qemu-system-x86_64 not found"
    exit 1
fi

echo "[*] Preparing directory layout"
rm -rf "$WORKDIR"
mkdir -p "$WORKDIR"/{bin,sbin,etc,proc,sys,dev,usr/bin,usr/sbin,mnt/host,opt,tmp}

chmod 1777 "$WORKDIR/tmp"

echo "[*] Installing busybox"
cp "$BUSYBOX_BIN" "$WORKDIR/bin/"
chmod +x "$WORKDIR/bin/busybox"

pushd "$WORKDIR/bin" >/dev/null
for app in $("$BUSYBOX_BIN" --list); do
    ln -s busybox "$app"
done
popd >/dev/null

echo "[*] Creating init script"

cat > "$WORKDIR/init" <<'EOF'
#!/bin/sh
mount -t proc none /proc
mount -t sysfs none /sys
mount -t devtmpfs none /dev

echo "Mounting host share"
mkdir -p /mnt/host
mount -t 9p -o trans=virtio,version=9p2000.L hostshare /mnt/host

mkdir -p /opt

echo "INIT READY"
exec sh
EOF

chmod +x "$WORKDIR/init"

echo "[*] Creating minimal /etc files"

cat > "$WORKDIR/etc/passwd" <<'EOF'
root:x:0:0:root:/root:/bin/sh
EOF

cat > "$WORKDIR/etc/group" <<'EOF'
root:x:0:
EOF

echo "[*] Packing initramfs"

pushd "$WORKDIR" >/dev/null
find . -print0 \
    | cpio --null -ov --format=newc \
    | gzip -9 > "$INITRAMFS_OUT"
popd >/dev/null

echo
echo "[+] initramfs created: $INITRAMFS_OUT"
echo
echo "Next steps:"
echo "  1) Build your kernel (bzImage)"
echo "  2) Run python test script with:"
echo "     --initramfs $INITRAMFS_OUT"
