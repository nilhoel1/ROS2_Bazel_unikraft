#!/bin/bash
set -e

# Script to run ROS2 node on Unikraft using QEMU via kraft
# This script runs the statically linked ROS2 node on Unikraft using the app-elfloader

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UNIKRAFT_DIR="${SCRIPT_DIR}/unikraft-app"

# Check for Linux binary first (from Docker build), then native
if [ -f "${SCRIPT_DIR}/build-linux/ros2_node" ]; then
    NODE_BINARY="${SCRIPT_DIR}/build-linux/ros2_node"
    echo "Using Linux binary from Docker build"
elif [ -f "${SCRIPT_DIR}/bazel-bin/ros2_node" ]; then
    NODE_BINARY="${SCRIPT_DIR}/bazel-bin/ros2_node"
    echo "Using native binary (may not work on Unikraft if not Linux ELF)"
else
    echo "Error: No binary found. Run 'make build-linux' first."
    exit 1
fi

echo "=========================================="
echo "Unikraft ROS2 Node Runner"
echo "=========================================="

# Check binary info
echo ""
echo "Binary information:"
file "${NODE_BINARY}"
echo "Binary size: $(du -h "${NODE_BINARY}" | cut -f1)"
echo ""

# Verify it's a Linux ELF binary
if ! file "${NODE_BINARY}" | grep -q "ELF.*Linux"; then
    echo ""
    echo "WARNING: Binary is not a Linux ELF executable!"
    echo "Unikraft requires a Linux x86_64 static binary."
    echo ""
    echo "On macOS, run 'make build-linux' to cross-compile via Docker."
    exit 1
fi

# Check if kraft is installed
if ! command -v kraft &> /dev/null; then
    echo "kraft CLI not found. Installing..."
    curl -sSfL https://get.kraftkit.sh | sh

    # Add kraft to PATH for this session
    export PATH="$HOME/.local/bin:$PATH"

    if ! command -v kraft &> /dev/null; then
        echo "Error: kraft installation failed or not in PATH."
        echo "Please install kraft manually: https://unikraft.org/docs/cli/install"
        echo "After installation, add to PATH: export PATH=\"\$HOME/.local/bin:\$PATH\""
        exit 1
    fi
fi

echo "kraft version: $(kraft version 2>/dev/null || echo 'unknown')"

# Create Unikraft app directory
rm -rf "${UNIKRAFT_DIR}"
mkdir -p "${UNIKRAFT_DIR}"

# Copy the binary to the app directory as rootfs
mkdir -p "${UNIKRAFT_DIR}/rootfs"
cp "${NODE_BINARY}" "${UNIKRAFT_DIR}/rootfs/ros2_node"
chmod +x "${UNIKRAFT_DIR}/rootfs/ros2_node"

# Create Kraftfile using base runtime
cat > "${UNIKRAFT_DIR}/Kraftfile" << 'KRAFTFILE'
spec: v0.6

runtime: base:latest

rootfs: ./rootfs

cmd: ["/ros2_node"]
KRAFTFILE

echo ""
echo "Building Unikraft unikernel with kraft..."
cd "${UNIKRAFT_DIR}"

# Build the unikernel using kraft
kraft build --no-cache --arch x86_64 --plat qemu

echo ""
echo "=========================================="
echo "Running ROS2 node on Unikraft with QEMU"
echo "=========================================="
echo ""

# Run the unikernel with QEMU
kraft run --arch x86_64 --plat qemu --memory 512M

echo ""
echo "=========================================="
echo "Unikraft execution completed"
echo "=========================================="
