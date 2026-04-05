#!/bin/bash

# Script to start an existing VM and show VNC connection info

VM_NAME="kedev-vm"

# Check if VM exists
if ! sudo virsh list --all --name | grep -qx "$VM_NAME"; then
    echo "Error: VM '$VM_NAME' does not exist. Run create.sh first."
    exit 1
fi

# Get VM state
state=$(sudo virsh domstate "$VM_NAME")

if [ "$state" == "running" ]; then
    echo "VM '$VM_NAME' is already running."
else
    echo "Starting VM '$VM_NAME' ..."
    sudo virsh start "$VM_NAME"
    if [ $? -ne 0 ]; then
        echo "Error: Failed to start VM."
        exit 1
    fi
    echo "VM started."
fi

# Show VNC port
vnc_display=$(sudo virsh vncdisplay "$VM_NAME" 2>/dev/null)
if [ -n "$vnc_display" ]; then
    # vncdisplay returns something like ":1"
    port=$((5900 + ${vnc_display#:}))
    echo "VNC is available on port $port (display $vnc_display)."
    echo "Connect your VNC viewer to <server-ip>:$port"
else
    echo "VNC display not found. Check VM graphics configuration."
fi