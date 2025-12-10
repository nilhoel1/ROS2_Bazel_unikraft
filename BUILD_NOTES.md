# Build Notes for ROS2 Bazel Unikraft

This document describes the build setup, issues encountered, and solutions implemented.

## Build Environment Setup

### Prerequisites Installed

1. **Bazel 7.4.1** - Downloaded directly from GitHub releases (bypassing bazelisk due to network issues)
2. **QEMU** - Installed via `apt-get install qemu-system-x86`
3. **Build Dependencies** - Downloaded manually to `/tmp/bazel_deps`:
   - bazel_features-1.38.0
   - bazel-skylib-1.4.2  
   - rules_cc-0.0.9
   - rules_python-0.24.0
   - rcutils-6.2.1

### Key Build Issues and Solutions

#### 1. SSL Certificate Issues

**Problem**: Java's SSL certificate validation was failing for GitHub downloads.

**Solution**: 
- Downloaded dependencies manually using `wget --no-check-certificate`
- Used Bazel's `--override_repository` flag to point to local copies
- Added to `.bazelrc.local`:
  ```
  common --override_repository=rules_python=/tmp/bazel_deps/rules_python-0.24.0
  ```

#### 2. Linker Compatibility

**Problem**: The default linker (ld.gold) doesn't support `--no-dynamic-linker` option needed for static-pie.

**Solution**:
- Replaced ld.gold with ld.bfd:
  ```bash
  sudo mv /usr/bin/ld.gold /usr/bin/ld.gold.bak
  sudo ln -sf /usr/bin/ld.bfd /usr/bin/ld.gold
  ```
- Added `--nostart_end_lib` flag to .bazelrc for compatibility with older linkers

#### 3. WORKSPACE Configuration

**Problem**: Original WORKSPACE tried to download all dependencies from network.

**Solution**:
- Modified WORKSPACE to use `local_repository` and `new_local_repository` for all dependencies
- Commented out unused dependencies (rcl, rclcpp, rmw, rmw_zenoh, zenoh_c)
- Only kept rcutils which is actually used by the demo application

## Build Commands

### Standard Build
```bash
bazel build --override_repository=rules_python=/tmp/bazel_deps/rules_python-0.24.0 //:ros2_node
```

### Or using Make
```bash
make build
```

The Makefile automatically includes the override repository flag.

## Binary Characteristics

The resulting binary is:
- **Type**: ELF 64-bit LSB pie executable, x86-64
- **Linking**: static-pie linked (fully statically linked, position independent)
- **Size**: ~853K
- **Dependencies**: None (statically linked)

Verify with:
```bash
file bazel-bin/ros2_node
ldd bazel-bin/ros2_node  # Should show "statically linked"
```

## Testing

### Local Testing
```bash
./bazel-bin/ros2_node
# or
make run-native
```

Expected output:
```
===========================================
  ROS2 Static PIE Demo for Unikraft
===========================================
[INFO] ROS2 rcutils logging initialized successfully!
[INFO] Running main loop (press Ctrl+C to exit)...
[INFO] Successfully allocated 1024 bytes
[INFO] Memory deallocated
[INFO] Tick #1 - System time: ...
...
[INFO] Demo complete - exiting after 5 iterations
```

### Unikraft Testing

Due to network restrictions in the build environment, the Unikraft kernel couldn't be downloaded. However, the scripts are ready:

1. **With kraft CLI** (when available):
   ```bash
   ./run_qemu.sh
   # or
   make run
   ```

2. **Direct QEMU** (when kernel is available):
   ```bash
   ./run_qemu_simple.sh
   # or
   make run-simple
   ```

See `UNIKRAFT_SETUP.md` for detailed instructions.

## Future Work: Adding rclcpp

To extend this demo to use rclcpp instead of just rcutils:

1. **Download rclcpp and dependencies** to `/tmp/bazel_deps`:
   ```bash
   cd /tmp/bazel_deps
   wget --no-check-certificate https://github.com/ros2/rcl/archive/refs/tags/6.0.1.tar.gz
   wget --no-check-certificate https://github.com/ros2/rclcpp/archive/refs/tags/21.0.0.tar.gz
   wget --no-check-certificate https://github.com/ros2/rmw/archive/refs/tags/7.1.0.tar.gz
   tar -xzf 6.0.1.tar.gz
   tar -xzf 21.0.0.tar.gz  
   tar -xzf 7.1.0.tar.gz
   ```

2. **Update WORKSPACE** to uncomment and point to local repositories:
   ```python
   new_local_repository(
       name = "rcl",
       build_file = "@//:third_party/rcl.BUILD",
       path = "/tmp/bazel_deps/rcl-6.0.1",
   )
   
   new_local_repository(
       name = "rclcpp",
       build_file = "@//:third_party/rclcpp.BUILD",
       path = "/tmp/bazel_deps/rclcpp-21.0.0",
   )
   
   new_local_repository(
       name = "rmw",
       build_file = "@//:third_party/rmw.BUILD",
       path = "/tmp/bazel_deps/rmw-7.1.0",
   )
   ```

3. **Update BUILD.bazel** to depend on rclcpp:
   ```python
   cc_binary(
       name = "ros2_node",
       srcs = ["src/main.cpp"],
       deps = [
           "@rclcpp//:rclcpp",
           "@rcl//:rcl",
           "@rmw//:rmw",
       ],
       # ... other options
   )
   ```

4. **Update main.cpp** to use rclcpp APIs instead of rcutils

## Configuration Files

### .bazelrc
- Disables bzlmod (uses WORKSPACE instead)
- Sets C++17 standard
- Enables PIC/PIE
- Disables start_end_lib for compatibility
- Configures release and debug modes

### .bazelrc.local
- Contains environment-specific settings
- Includes repository overrides
- Not committed to git

### .gitignore
- Ignores bazel-* symlinks
- Ignores backup files
- Keeps important config files

## Troubleshooting

### Clean Build
If you encounter caching issues:
```bash
bazel clean --expunge
bazel build --override_repository=rules_python=/tmp/bazel_deps/rules_python-0.24.0 //:ros2_node
```

### Linker Issues
Ensure ld.bfd is being used:
```bash
ls -la /usr/bin/ld*
# ld.gold should point to ld.bfd or not exist
```

### Missing Dependencies
All dependencies should be in `/tmp/bazel_deps`. If missing, download manually with `wget --no-check-certificate`.

## References

- [Bazel Documentation](https://bazel.build/)
- [ROS 2 Documentation](https://docs.ros.org/)
- [Unikraft Documentation](https://unikraft.org/)
- [rcutils GitHub](https://github.com/ros2/rcutils)
