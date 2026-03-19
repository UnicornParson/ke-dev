#!/bin/bash

# Minimal comments. Long operations show execution time.

VM_NAME="kedev-vm"
RAM="8096"
VCPUS="8"
DISK_SIZE="30"
OS_VARIANT="ubuntu22.04"
ISO_URL="https://mirror.sitsa.com.ar/ubuntu-releases/questing/ubuntu-25.10-live-server-amd64.iso"
IMAGES_HOME="./data"
ISO_PATH="$IMAGES_HOME/ubuntu.iso"
DISK_PATH="$IMAGES_HOME/$VM_NAME.qcow2"
VNC_PASSWORD="1"

# Abort if VM already exists
if sudo virsh list --all --name | grep -qx "$VM_NAME"; then
    echo "Error: VM '$VM_NAME' already exists. Remove it manually if needed."
    exit 1
fi

mkdir -p "$IMAGES_HOME"

# Download ISO if missing (long operation)
if [ ! -f "$ISO_PATH" ]; then
    echo "ISO not found. Downloading from $ISO_URL ..."
    start=$(date +%s)
    if command -v wget >/dev/null 2>&1; then
        wget -O "$ISO_PATH" "$ISO_URL"
    elif command -v curl >/dev/null 2>&1; then
        curl -L -o "$ISO_PATH" "$ISO_URL"
    else
        echo "Error: Neither wget nor curl found."
        exit 1
    fi
    end=$(date +%s)
    if [ $? -ne 0 ] || [ ! -f "$ISO_PATH" ]; then
        echo "Error: Failed to download ISO."
        exit 1
    fi
    echo "Download finished in $((end - start)) seconds."
fi

# Create VM (long operation)
echo "Creating and starting VM '$VM_NAME' with virt-install ..."
start=$(date +%s)
sudo virt-install \
    --name "$VM_NAME" \
    --ram "$RAM" \
    --vcpus "$VCPUS" \
    --disk path="$DISK_PATH",size="$DISK_SIZE",format=qcow2 \
    --os-variant "$OS_VARIANT" \
    --cdrom "$ISO_PATH" \
    --graphics vnc,listen=0.0.0.0,password="$VNC_PASSWORD" \
    --noautoconsole \
    --network bridge=virbr0
result=$?
end=$(date +%s)
if [ $result -ne 0 ]; then
    echo "Error: virt-install failed."
    exit $result
fi
echo "VM creation finished in $((end - start)) seconds."

# Show how to connect via VNC
echo "VM '$VM_NAME' is now running."
echo "To find its VNC port, run: sudo virsh vncdisplay $VM_NAME"
echo "Then connect your VNC viewer to <server-ip>:<port> (e.g., 5900 for :0)."