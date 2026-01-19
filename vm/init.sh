#!/bin/sh
mount -t proc none /proc
mount -t sysfs none /sys
mount -t devtmpfs none /dev

mkdir -p /mnt/host /opt
mount -t 9p -o trans=virtio,version=9p2000.L hostshare /mnt/host

echo "INIT READY"
exec sh
