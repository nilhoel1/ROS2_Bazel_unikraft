# ROS2_Bazel_unikraft

Build ROS2 as a statically linked PIE executable using Bazel and deploy on Unikraft.

## Quick Start

```bash
# Verify your environment
./verify_setup.sh

# Build the ROS2 node
make build

# Run on Unikraft (requires QEMU)
make run
```

📖 For detailed instructions, see [QUICKSTART.md](QUICKSTART.md)

## Overview

This repository demonstrates how to build a ROS2 node as a static PIE (Position Independent Executable) binary using Bazel, with rmw_zenoh as the middleware implementation. The resulting binary can be executed on Unikraft, a unikernel operating system.

## Features

- **Static PIE Binary**: Fully statically linked with `-static-pie` for portability
- **ROS2 rclcpp**: Uses the ROS2 C++ client library
- **rmw_zenoh**: Zenoh middleware implementation statically registered (no dlopen)
- **Unikraft Ready**: Can be executed as an initrd on Unikraft using app-elfloader

## Repository Structure

```
.
├── WORKSPACE              # Bazel workspace with ROS2 dependencies
├── BUILD.bazel           # Main build file defining cc_binary
├── .bazelrc              # Bazel configuration for static PIE builds
├── src/
│   └── main.cpp          # Simple ROS2 node with static rmw_zenoh registration
├── third_party/          # Build files for external dependencies
│   ├── rcutils.BUILD
│   ├── rcl.BUILD
│   ├── rclcpp.BUILD
│   ├── rmw.BUILD
│   ├── rmw_zenoh.BUILD
│   └── zenoh_c.BUILD
└── run_qemu.sh          # Script to run the node on Unikraft with QEMU
```

## Prerequisites

- Bazel 6.0 or later
- GCC/G++ with C++17 support
- QEMU (for running on Unikraft): `qemu-system-x86_64`
- wget or curl (for downloading Unikraft kernel)

### Installing Prerequisites

**Ubuntu/Debian:**
```bash
sudo apt-get update
sudo apt-get install -y bazel g++ qemu-system-x86 wget
```

**macOS:**
```bash
brew install bazel gcc qemu wget
```

## Building

Build the ROS2 node as a static PIE binary:

```bash
bazel build //:ros2_node
```

The resulting binary will be at `bazel-bin/ros2_node`.

### Build Configurations

- **Release build (default)**: Optimized with symbols stripped
  ```bash
  bazel build --config=release //:ros2_node
  ```

- **Debug build**: With debug symbols
  ```bash
  bazel build --config=debug //:ros2_node
  ```

## Running on Unikraft

The `run_qemu.sh` script automates running the ROS2 node on Unikraft:

```bash
./run_qemu.sh
```

This script will:
1. Download the Unikraft app-elfloader kernel (if not already present)
2. Verify the ROS2 node binary exists
3. Launch QEMU with the Unikraft kernel and the ROS2 node as initrd
4. Execute the node inside the Unikraft unikernel

### Manual QEMU Execution

You can also run QEMU manually:

```bash
qemu-system-x86_64 \
  -kernel unikraft/elfloader_qemu-x86_64.bin \
  -initrd bazel-bin/ros2_node \
  -append "vfs.fstab=[ \"initrd0:/:extract::ramfs=1:\" ] -- /ros2_node" \
  -nographic \
  -m 512M
```

Press `Ctrl+C` to stop the VM.

## How It Works

### Static PIE Binary

The binary is built with:
- `linkstatic = True`: Static linking of all dependencies
- `linkopts = ["-static-pie"]`: Position Independent Executable with static linking
- `-pthread` and `-lrt`: Required for ROS2 runtime

### Static rmw_zenoh Registration

The key feature is **static registration of rmw_zenoh** to avoid dynamic loading:

```cpp
extern "C" {
  __attribute__((constructor))
  void register_rmw_zenoh_statically() {
    setenv("RMW_IMPLEMENTATION", "rmw_zenoh_cpp", 1);
  }
}
```

This ensures:
- No need for `dlopen()` at runtime
- All RMW symbols are linked directly into the binary
- The middleware is available immediately when the node starts

### Unikraft Execution

Unikraft's app-elfloader:
1. Boots as a minimal unikernel
2. Loads the ROS2 node from initrd
3. Executes it as a static PIE binary
4. Provides minimal Linux-compatible system calls

## Customization

### Modifying the Node

Edit `src/main.cpp` to implement your custom ROS2 functionality:
- Add publishers/subscribers
- Create services/actions
- Implement custom behavior

### Changing Dependencies

Edit `WORKSPACE` to update ROS2 versions or add additional dependencies.

### Build Options

Edit `.bazelrc` to adjust compiler flags, optimization levels, or link options.

## Troubleshooting

### Build Fails

- Ensure Bazel is installed and up to date
- Check that GCC/G++ supports C++17
- Verify network connectivity for downloading dependencies

### QEMU Doesn't Start

- Install QEMU: `sudo apt-get install qemu-system-x86`
- Check that the binary was built successfully
- Ensure sufficient memory is available (512MB required)

### Node Doesn't Execute

- Verify the binary is a valid static PIE: `file bazel-bin/ros2_node`
- Check QEMU output for error messages
- Try increasing memory: edit `run_qemu.sh` and change `-m 512M` to `-m 1024M`

## License

See the LICENSE file for details.

## References

- [ROS2 Documentation](https://docs.ros.org/)
- [Zenoh](https://zenoh.io/)
- [Unikraft](https://unikraft.org/)
- [Bazel](https://bazel.build/)
