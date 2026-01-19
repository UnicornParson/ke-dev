#!/bin/bash

set -e

BIN_DIR="bin"

if [ ! -d "$BIN_DIR" ]; then
    echo "Error: $BIN_DIR does not exist"
    exit 1
fi

find "$BIN_DIR" -mindepth 1 ! -name '.gitkeep' -exec rm -rf {} +

echo "..done"