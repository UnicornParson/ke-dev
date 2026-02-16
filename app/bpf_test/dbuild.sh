#!/bin/bash
set -e
DOCKERFILE="Dockerfile.ubuntu"
docker build -f "$DOCKERFILE" -t ebpf-builder-ubuntu .

H_ALL="http://cz.archive.ubuntu.com/ubuntu/pool/main/l/linux/linux-headers-6.19.0-3_6.19.0-3.3_all.deb"
H_GEN="http://cz.archive.ubuntu.com/ubuntu/pool/main/l/linux/linux-headers-6.14.0-13-generic_6.14.0-13.13_amd64.deb"
docker run --rm \
    -e HEADERS_ALL_URL="$H_ALL" \
    -e HEADERS_ARCH_URL="$H_GEN" \
    -v $(pwd)/../bpf_test:/bpf_test \
    ebpf-builder-ubuntu

if [ $? -ne 0 ]; then
    echo "Build failed, exiting."
    exit 1
fi