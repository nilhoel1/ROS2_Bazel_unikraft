#!/bin/bash
set -e

# Script to download Unikraft app-elfloader kernel and execute ROS2 node
# This script runs the statically linked ROS2 node on Unikraft using QEMU

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UNIKRAFT_DIR="${SCRIPT_DIR}/unikraft"
LOADER_URL="https://builds.unikraft.io/binaries/app-elfloader/0.13.1/elfloader_qemu-x86_64.bin"
LOADER_IMAGE="${UNIKRAFT_DIR}/elfloader_qemu-x86_64.bin"
NODE_BINARY="${SCRIPT_DIR}/bazel-bin/ros2_node"

echo "=========================================="
echo "Unikraft ROS2 Node Runner"
echo "=========================================="

# Create unikraft directory if it doesn't exist
if [ ! -d "${UNIKRAFT_DIR}" ]; then
    echo "Creating Unikraft directory..."
    mkdir -p "${UNIKRAFT_DIR}"
fi

# Download Unikraft app-elfloader kernel if not present
if [ ! -f "${LOADER_IMAGE}" ]; then
    echo "Downloading Unikraft app-elfloader kernel..."
    echo "URL: ${LOADER_URL}"
    
    if command -v wget &> /dev/null; then
        wget -O "${LOADER_IMAGE}" "${LOADER_URL}"
    elif command -v curl &> /dev/null; then
        curl -L -o "${LOADER_IMAGE}" "${LOADER_URL}"
    else
        echo "Error: Neither wget nor curl found. Please install one of them."
        exit 1
    fi
    
    echo "Downloaded Unikraft kernel to ${LOADER_IMAGE}"
else
    echo "Unikraft kernel already exists at ${LOADER_IMAGE}"
fi

# Check if the ROS2 node binary exists
if [ ! -f "${NODE_BINARY}" ]; then
    echo "Error: ROS2 node binary not found at ${NODE_BINARY}"
    echo "Please build the project first with: bazel build //:ros2_node"
    exit 1
fi

echo ""
echo "Binary information:"
file "${NODE_BINARY}"
echo ""
echo "Binary size: $(du -h "${NODE_BINARY}" | cut -f1)"
echo ""

# Check if qemu-system-x86_64 is available
if ! command -v qemu-system-x86_64 &> /dev/null; then
    echo "Error: qemu-system-x86_64 not found. Please install QEMU."
    echo "On Ubuntu/Debian: sudo apt-get install qemu-system-x86"
    echo "On macOS: brew install qemu"
    exit 1
fi

echo "=========================================="
echo "Launching ROS2 Node on Unikraft..."
echo "=========================================="
echo "Kernel: ${LOADER_IMAGE}"
echo "InitRD: ${NODE_BINARY}"
echo "Command: /ros2_node"
echo ""
echo "Press Ctrl+C to stop the VM"
echo "=========================================="
echo ""

# Run QEMU with Unikraft kernel and ROS2 node as initrd
# -kernel: Unikraft app-elfloader kernel
# -initrd: The statically linked ROS2 node binary
# -append: Command line arguments (path to execute in the initrd)
# -nographic: Run without graphical display
# -m: Memory size (512MB should be sufficient)
# -cpu: CPU type (host if available, otherwise qemu64)
exec qemu-system-x86_64 \
    -kernel "${LOADER_IMAGE}" \
    -initrd "${NODE_BINARY}" \
    -append "vfs.fstab=[ \"initrd0:/:extract::ramfs=1:\" ] -- /ros2_node" \
    -nographic \
    -m 512M \
    -cpu max \
    -enable-kvm 2>/dev/null || exec qemu-system-x86_64 \
    -kernel "${LOADER_IMAGE}" \
    -initrd "${NODE_BINARY}" \
    -append "vfs.fstab=[ \"initrd0:/:extract::ramfs=1:\" ] -- /ros2_node" \
    -nographic \
    -m 512M \
    -cpu qemu64
