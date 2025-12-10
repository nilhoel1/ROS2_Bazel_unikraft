.PHONY: help build clean run test info build-linux

# Default target
help:
	@echo "ROS2 Bazel Unikraft - Available targets:"
	@echo ""
	@echo "  make build       - Build the ROS2 node (native, for testing)"
	@echo "  make build-linux - Build Linux x86_64 static PIE via Docker (for Unikraft)"
	@echo "  make build-debug - Build with debug symbols"
	@echo "  make run         - Run the node on Unikraft with QEMU"
	@echo "  make run-native  - Run the native binary (for testing)"
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

# Build Linux x86_64 static PIE binary via Docker (for Unikraft)
build-linux:
	@echo "Building Linux x86_64 static PIE binary via Docker..."
	@if ! command -v docker &> /dev/null; then \
		echo "Error: Docker is required for cross-compilation."; \
		echo "Please install Docker or build on a Linux machine."; \
		exit 1; \
	fi
	docker build -f Dockerfile.build -t ros2-bazel-unikraft-builder .
	docker create --name ros2-extract ros2-bazel-unikraft-builder
	mkdir -p build-linux
	docker cp ros2-extract:/workspace/bazel-bin/ros2_node build-linux/ros2_node
	docker rm ros2-extract
	@echo ""
	@echo "Build complete! Linux binary at: build-linux/ros2_node"
	@file build-linux/ros2_node

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

# Run on Unikraft (requires Linux binary)
run:
	@echo "Running on Unikraft with QEMU..."
	@if [ -f build-linux/ros2_node ]; then \
		echo "Using Linux binary from build-linux/"; \
	elif [ -f bazel-bin/ros2_node ]; then \
		echo "Warning: Using native binary. For Unikraft, run 'make build-linux' first."; \
	else \
		echo "Error: No binary found. Run 'make build' or 'make build-linux' first."; \
		exit 1; \
	fi
	./run_qemu.sh

# Run the native binary (for local testing, not on Unikraft)
run-native:
	@if [ ! -f bazel-bin/ros2_node ]; then \
		echo "Error: Binary not found. Run 'make build' first."; \
		exit 1; \
	fi
	@echo "Running native binary..."
	./bazel-bin/ros2_node

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	bazel clean
	@echo "Removing Unikraft directories..."
	rm -rf unikraft/ unikraft-app/
	@echo "Removing Docker build output..."
	rm -rf build-linux/
	@echo "Clean complete!"

# Run tests (placeholder - extend as needed)
test:
	@echo "Running tests..."
	@echo "Note: No tests defined yet. Add test targets to BUILD.bazel"
	# bazel test //...
