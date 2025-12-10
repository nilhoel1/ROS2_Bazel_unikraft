# Running ROS2 Node on Unikraft with QEMU

This guide explains how to run the statically-linked ROS2 node on Unikraft using QEMU.

## Prerequisites

1. **QEMU** - Install with: `sudo apt-get install -y qemu-system-x86`
2. **Unikraft Kernel** - You need the app-elfloader kernel for x86_64

## Option 1: Using kraft CLI (Recommended)

If you have internet connectivity and can install kraft:

```bash
# Install kraft
curl -sSfL https://get.kraftkit.sh | sh
export PATH="$HOME/.local/bin:$PATH"

# Run the application
./run_qemu.sh
```

The `run_qemu.sh` script will:
1. Create a Kraftfile with the app configuration
2. Build a Unikraft unikernel
3. Run it with QEMU

## Option 2: Manual QEMU Execution

If kraft is not available, you can run QEMU directly with a pre-built Unikraft kernel:

### Step 1: Download Unikraft Kernel

Download the pre-built app-elfloader kernel:

```bash
mkdir -p unikraft
cd unikraft

# Try official releases
wget https://github.com/unikraft/app-elfloader/releases/download/v0.17.0/elfloader_qemu-x86_64.bin

# Or try nightly builds
wget https://builds.unikraft.io/qemu/x86_64/app-elfloader/latest/kernel -O elfloader_qemu-x86_64.bin
```

### Step 2: Run with QEMU

```bash
qemu-system-x86_64 \
  -kernel unikraft/elfloader_qemu-x86_64.bin \
  -initrd bazel-bin/ros2_node \
  -append "vfs.fstab=[ \"initrd0:/:extract::ramfs=1:\" ] -- /ros2_node" \
  -nographic \
  -m 512M
```

**Parameters explained:**
- `-kernel`: The Unikraft kernel with app-elfloader
- `-initrd`: Your statically-linked ROS2 binary (as initrd)
- `-append`: Kernel command line arguments
  - `vfs.fstab`: Mount the initrd as root filesystem
  - `--`: Separator before application arguments
  - `/ros2_node`: Path to your application in the virtual filesystem
- `-nographic`: Run without graphics (serial console only)
- `-m 512M`: Allocate 512MB of RAM

**To exit**: Press `Ctrl+A` then `X` (in QEMU's serial console), or `Ctrl+C` from terminal.

## Option 3: Using Docker for Cross-Compilation

If you're on macOS or non-Linux system, use Docker to build a Linux binary first:

```bash
make build-linux  # Builds using Docker
make run          # Runs on Unikraft with QEMU
```

## Verifying the Binary

Before running on Unikraft, verify your binary is suitable:

```bash
# Check file type
file bazel-bin/ros2_node
# Should show: ELF 64-bit LSB pie executable, x86-64, version 1 (GNU/Linux), static-pie linked

# Verify static linking
ldd bazel-bin/ros2_node
# Should show: statically linked

# Test locally first
./bazel-bin/ros2_node
# Should run and output ROS2 logging messages
```

## Troubleshooting

### Build Issues

If you encounter build errors:

1. **SSL Certificate Issues**: The build uses local repository overrides. Ensure `/tmp/bazel_deps` exists with the required dependencies.

2. **Linker Issues**: The build uses ld.bfd (not ld.gold). If you get linker errors, check that ld.bfd is available:
   ```bash
   sudo update-alternatives --install /usr/bin/ld ld /usr/bin/ld.bfd 100
   ```

3. **Clean Build**: If something is cached incorrectly:
   ```bash
   bazel clean --expunge
   bazel build --override_repository=rules_python=/tmp/bazel_deps/rules_python-0.24.0 //:ros2_node
   ```

### Runtime Issues

1. **Binary not found**: Make sure you've built the binary first with `bazel build //:ros2_node`

2. **QEMU not starting**: Check that QEMU is installed and in PATH

3. **Kernel not found**: Download the Unikraft elfloader kernel as described above

4. **Application crashes**: Increase memory allocation with `-m 1024M` or higher

## Current Status

✅ Binary builds successfully as static PIE
✅ Binary runs correctly on Linux
⏳ Unikraft execution pending kernel download

The application is ready to run on Unikraft once the kernel is available!
