#!/bin/bash
# Simple QEMU runner for ROS2 node on Unikraft
# This script runs the ROS2 node directly with QEMU using a pre-built Unikraft kernel
#
# NOTE: This script uses --no-check-certificate for wget which is insecure.
# This is acceptable for development/demo but should be fixed for production.
# Consider downloading with proper certificate verification.
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UNIKRAFT_DIR="${SCRIPT_DIR}/unikraft"
KERNEL="${UNIKRAFT_DIR}/elfloader_qemu-x86_64.bin"
NODE_BINARY="${SCRIPT_DIR}/bazel-bin/ros2_node"

echo "=========================================="
echo "Unikraft ROS2 Node Runner (Simple QEMU)"
echo "=========================================="
echo ""

# Check if binary exists
if [ ! -f "${NODE_BINARY}" ]; then
    echo "Error: Binary not found at ${NODE_BINARY}"
    echo "Please build first: bazel build //:ros2_node"
    exit 1
fi

# Check binary info
echo "Binary information:"
file "${NODE_BINARY}"
echo "Binary size: $(du -h "${NODE_BINARY}" | cut -f1)"
echo ""

# Verify it's a Linux ELF static-pie binary
if ! file "${NODE_BINARY}" | grep -q "ELF.*Linux.*static"; then
    echo "WARNING: Binary might not be suitable for Unikraft"
    echo "Expected: ELF 64-bit LSB pie executable, x86-64, static-pie linked"
    echo ""
fi

# Check/download kernel
if [ ! -f "${KERNEL}" ]; then
    echo "Unikraft kernel not found. Downloading..."
    mkdir -p "${UNIKRAFT_DIR}"
    
    # Try multiple sources
    if wget --no-check-certificate -O "${KERNEL}" \
        "https://github.com/unikraft/app-elfloader/releases/download/v0.17.0/elfloader_qemu-x86_64.bin" 2>/dev/null; then
        echo "Downloaded from GitHub releases"
    elif wget --no-check-certificate -O "${KERNEL}" \
        "https://builds.unikraft.io/qemu/x86_64/app-elfloader/latest/kernel" 2>/dev/null; then
        echo "Downloaded from builds.unikraft.io"
    else
        echo "Error: Could not download Unikraft kernel"
        echo ""
        echo "Please download manually from one of these sources:"
        echo "  - https://github.com/unikraft/app-elfloader/releases"
        echo "  - https://builds.unikraft.io/qemu/x86_64/app-elfloader/latest/kernel"
        echo ""
        echo "And save it to: ${KERNEL}"
        exit 1
    fi
fi

# Check if QEMU is installed
if ! command -v qemu-system-x86_64 &> /dev/null; then
    echo "Error: qemu-system-x86_64 not found"
    echo "Install with: sudo apt-get install -y qemu-system-x86"
    exit 1
fi

echo "=========================================="
echo "Starting Unikraft VM with QEMU"
echo "=========================================="
echo "Press Ctrl+A then X to exit QEMU"
echo ""

# Run with QEMU
qemu-system-x86_64 \
    -kernel "${KERNEL}" \
    -initrd "${NODE_BINARY}" \
    -append "vfs.fstab=[ \"initrd0:/:extract::ramfs=1:\" ] -- /ros2_node" \
    -nographic \
    -m 512M

echo ""
echo "=========================================="
echo "Unikraft execution completed"
echo "=========================================="
