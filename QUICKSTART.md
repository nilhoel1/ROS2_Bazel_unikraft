# Quick Start Guide

This guide provides a quick walkthrough for building and running the ROS2 node on Unikraft.

## Step 1: Prerequisites

Ensure you have the required tools installed:

```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install -y bazel g++ qemu-system-x86 wget

# macOS
brew install bazel gcc qemu wget
```

## Step 2: Clone the Repository

```bash
git clone https://github.com/nilhoel1/ROS2_Bazel_unikraft.git
cd ROS2_Bazel_unikraft
```

## Step 3: Build the ROS2 Node

Build the static PIE binary using Bazel:

```bash
bazel build //:ros2_node
```

This will:
- Download all ROS2 dependencies (rclcpp, rmw_zenoh, etc.)
- Compile the node with static linking
- Create a PIE binary at `bazel-bin/ros2_node`

**Note:** The first build may take some time as Bazel downloads and compiles all dependencies.

## Step 4: Verify the Binary

Check that the binary is a static PIE executable:

```bash
file bazel-bin/ros2_node
```

You should see output like:
```
bazel-bin/ros2_node: ELF 64-bit LSB pie executable, x86-64, version 1 (GNU/Linux), statically linked
```

## Step 5: Run on Unikraft

Execute the ROS2 node on Unikraft using QEMU:

```bash
./run_qemu.sh
```

This will:
1. Download the Unikraft app-elfloader kernel (first run only)
2. Launch QEMU with the ROS2 node
3. Display the node's output in the console

You should see output similar to:
```
[  0.000000] Info: [libkvmplat] <setup.c @  232> Unikraft bootstrapping...
...
[INFO] [simple_ros2_node]: Simple ROS2 Node started!
[INFO] [simple_ros2_node]: ROS2 Node initialized with rmw_zenoh (statically linked)
[INFO] [simple_ros2_node]: Running as Static PIE binary for Unikraft
[INFO] [simple_ros2_node]: Hello from ROS2! Count: 1
[INFO] [simple_ros2_node]: Hello from ROS2! Count: 2
...
```

## Step 6: Stop the Node

Press `Ctrl+C` to stop the QEMU VM and exit.

## Next Steps

### Customize the Node

Edit `src/main.cpp` to add your custom ROS2 functionality:

```cpp
// Add publishers
auto publisher = this->create_publisher<std_msgs::msg::String>("topic", 10);

// Add subscribers
auto subscription = this->create_subscription<std_msgs::msg::String>(
    "topic", 10, callback);

// Add services
auto service = this->create_service<example_interfaces::srv::AddTwoInts>(
    "add_two_ints", handle_service);
```

### Change ROS2 Versions

Edit `WORKSPACE` to update dependency versions or add new packages.

### Debug Issues

If you encounter issues:

1. **Build fails**: Check Bazel version (`bazel version`)
2. **QEMU doesn't start**: Verify QEMU installation (`qemu-system-x86_64 --version`)
3. **Node crashes**: Check QEMU output for error messages

### Advanced Configuration

- **Increase memory**: Edit `run_qemu.sh` and change `-m 512M` to `-m 1024M`
- **Enable KVM**: The script automatically tries to use KVM if available
- **Debug build**: Use `bazel build --config=debug //:ros2_node`

## Troubleshooting

### "Bazel not found"

Install Bazel from https://bazel.build/install

### "QEMU not found"

```bash
# Ubuntu/Debian
sudo apt-get install qemu-system-x86

# macOS
brew install qemu
```

### Build is very slow

The first build downloads and compiles all dependencies. Subsequent builds will be much faster due to Bazel's caching.

### Node doesn't produce output

Ensure QEMU is using the correct parameters. Check the `run_qemu.sh` script and verify the `-append` parameter includes the correct path.

## Additional Resources

- [Main README](README.md) - Comprehensive documentation
- [ROS2 Documentation](https://docs.ros.org/)
- [Unikraft Documentation](https://unikraft.org/docs/)
- [Bazel Documentation](https://bazel.build/docs)
