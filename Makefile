.PHONY: help build clean run test info

# Default target
help:
	@echo "ROS2 Bazel Unikraft - Available targets:"
	@echo ""
	@echo "  make build       - Build the ROS2 node as static PIE binary"
	@echo "  make build-debug - Build with debug symbols"
	@echo "  make run         - Run the node on Unikraft with QEMU"
	@echo "  make info        - Display information about the built binary"
	@echo "  make clean       - Clean build artifacts"
	@echo "  make test        - Run tests (if available)"
	@echo "  make help        - Show this help message"
	@echo ""

# Build the ROS2 node (release mode)
build:
	@echo "Building ROS2 node (release mode)..."
	bazel build --config=release //:ros2_node
	@echo ""
	@echo "Build complete! Binary at: bazel-bin/ros2_node"
	@echo "Run 'make info' to see binary details"
	@echo "Run 'make run' to execute on Unikraft"

# Build with debug symbols
build-debug:
	@echo "Building ROS2 node (debug mode)..."
	bazel build --config=debug //:ros2_node
	@echo ""
	@echo "Build complete! Binary at: bazel-bin/ros2_node"

# Display binary information
info:
	@echo "Binary Information:"
	@echo "===================="
	@if [ -f bazel-bin/ros2_node ]; then \
		file bazel-bin/ros2_node; \
		echo ""; \
		echo "Size: $$(du -h bazel-bin/ros2_node | cut -f1)"; \
		echo ""; \
		echo "Static PIE verification:"; \
		readelf -h bazel-bin/ros2_node | grep -E "Type:|Machine:|Entry point" || echo "readelf not available"; \
	else \
		echo "Binary not found. Run 'make build' first."; \
	fi

# Run on Unikraft
run:
	@if [ ! -f bazel-bin/ros2_node ]; then \
		echo "Error: Binary not found. Run 'make build' first."; \
		exit 1; \
	fi
	@echo "Launching ROS2 node on Unikraft..."
	./run_qemu.sh

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	bazel clean
	@echo "Removing Unikraft directory..."
	rm -rf unikraft/
	@echo "Clean complete!"

# Run tests (placeholder - extend as needed)
test:
	@echo "Running tests..."
	@echo "Note: No tests defined yet. Add test targets to BUILD.bazel"
	# bazel test //...
