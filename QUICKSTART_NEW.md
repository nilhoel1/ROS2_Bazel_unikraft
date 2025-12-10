# Quick Start Guide

This is a quick reference for building and running the ROS2 application on Unikraft.

## Prerequisites

```bash
# Check if you have Bazel (should be 7.4.1)
bazel version

# Install QEMU if needed
sudo apt-get install -y qemu-system-x86

# Verify dependencies are in place
ls /tmp/bazel_deps/rules_python-0.24.0
```

## Building

```bash
# Build the application
make build

# Or manually
bazel build --override_repository=rules_python=/tmp/bazel_deps/rules_python-0.24.0 //:ros2_node
```

## Testing Locally

```bash
# Run the binary natively to test
make run-native

# Or directly
./bazel-bin/ros2_node
```

Expected output:
```
===========================================
  ROS2 Static PIE Demo for Unikraft
===========================================
[INFO] ROS2 rcutils logging initialized successfully!
[INFO] Running main loop (press Ctrl+C to exit)...
[INFO] Tick #1 - System time: 1765379685 seconds
...
[INFO] Demo complete - exiting after 5 iterations
Goodbye from ROS2 Static PIE Demo!
```

## Running on Unikraft

### Option 1: Simple QEMU (Recommended)

```bash
# This will automatically download the Unikraft kernel if needed
make run-simple

# Or directly
./run_qemu_simple.sh
```

### Option 2: Using kraft CLI

```bash
# Install kraft first (if you have internet access)
curl -sSfL https://get.kraftkit.sh | sh
export PATH="$HOME/.local/bin:$PATH"

# Run with kraft
make run

# Or directly
./run_qemu.sh
```

## Verifying the Build

```bash
# Check binary type
file bazel-bin/ros2_node
# Should show: ELF 64-bit LSB pie executable, x86-64, version 1 (GNU/Linux), static-pie linked

# Check size
ls -lh bazel-bin/ros2_node
# Should be around 853K

# Verify static linking
ldd bazel-bin/ros2_node
# Should show: statically linked
```

## Troubleshooting

### Build fails with linker errors
```bash
# Ensure ld.bfd is being used
ls -la /usr/bin/ld*
# If ld.gold exists and causes issues, replace it:
sudo mv /usr/bin/ld.gold /usr/bin/ld.gold.bak
sudo ln -sf /usr/bin/ld.bfd /usr/bin/ld.gold
```

### Dependencies missing
```bash
# Dependencies should be in /tmp/bazel_deps
# If missing, see BUILD_NOTES.md for download instructions
```

### Clean build needed
```bash
bazel clean --expunge
make build
```

## Documentation

- **UNIKRAFT_SETUP.md** - Detailed Unikraft setup and execution instructions
- **BUILD_NOTES.md** - Technical build details, issues, and solutions
- **README.md** - Project overview and general information
- **QUICKSTART.md** - Original quickstart guide

## Next Steps

This demo uses rcutils (basic ROS2 utilities). To extend it to use rclcpp:

1. Download rclcpp and dependencies (see BUILD_NOTES.md)
2. Update WORKSPACE to add the new dependencies
3. Modify main.cpp to use rclcpp APIs
4. Update BUILD.bazel deps

See BUILD_NOTES.md section "Future Work: Adding rclcpp" for detailed instructions.

## Common Commands

```bash
make help          # Show all available targets
make build         # Build the application
make run-native    # Test locally
make run-simple    # Run on Unikraft (simple method)
make info          # Show binary information
make clean         # Clean build artifacts
```

## Support

If you encounter issues:

1. Check the troubleshooting section above
2. Review BUILD_NOTES.md for detailed solutions
3. Verify all prerequisites are installed
4. Try a clean build: `bazel clean --expunge && make build`
