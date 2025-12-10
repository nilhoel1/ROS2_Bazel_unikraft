#!/bin/bash
# Verify build environment and dependencies

# Don't exit on errors - we want to check everything
set +e

echo "=========================================="
echo "Build Environment Verification"
echo "=========================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

check_command() {
    if command -v "$1" &> /dev/null; then
        echo -e "${GREEN}✓${NC} $1 is installed: $($1 --version 2>&1 | head -1)"
        return 0
    else
        echo -e "${RED}✗${NC} $1 is not installed"
        return 1
    fi
}

check_optional_command() {
    if command -v "$1" &> /dev/null; then
        echo -e "${GREEN}✓${NC} $1 is installed: $($1 --version 2>&1 | head -1)"
        return 0
    else
        echo -e "${YELLOW}○${NC} $1 is not installed (optional)"
        return 1
    fi
}

echo "Checking required tools..."
echo ""

all_good=true

# Required tools
if ! check_command "bazel"; then
    echo "  Install: https://bazel.build/install"
    all_good=false
fi

if ! check_command "g++"; then
    echo "  Install: sudo apt-get install g++ (Ubuntu/Debian)"
    all_good=false
fi

echo ""
echo "Checking optional tools for running on Unikraft..."
echo ""

# Optional tools
check_optional_command "qemu-system-x86_64"
if [ $? -ne 0 ]; then
    echo "  Install: sudo apt-get install qemu-system-x86 (Ubuntu/Debian)"
    echo "           brew install qemu (macOS)"
fi

if ! check_optional_command "wget"; then
    check_optional_command "curl"
fi

echo ""
echo "Checking Bazel configuration..."
echo ""

if [ -f ".bazelversion" ]; then
    expected_version=$(cat .bazelversion)
    echo -e "${GREEN}✓${NC} .bazelversion file found: $expected_version"
else
    echo -e "${YELLOW}○${NC} .bazelversion file not found"
fi

if [ -f ".bazelrc" ]; then
    echo -e "${GREEN}✓${NC} .bazelrc configuration found"
else
    echo -e "${RED}✗${NC} .bazelrc configuration not found"
    all_good=false
fi

if [ -f "WORKSPACE" ]; then
    echo -e "${GREEN}✓${NC} WORKSPACE file found"
else
    echo -e "${RED}✗${NC} WORKSPACE file not found"
    all_good=false
fi

if [ -f "BUILD.bazel" ]; then
    echo -e "${GREEN}✓${NC} BUILD.bazel file found"
else
    echo -e "${RED}✗${NC} BUILD.bazel file not found"
    all_good=false
fi

echo ""
echo "Checking source files..."
echo ""

if [ -f "src/main.cpp" ]; then
    echo -e "${GREEN}✓${NC} src/main.cpp found"
else
    echo -e "${RED}✗${NC} src/main.cpp not found"
    all_good=false
fi

echo ""
echo "Checking third_party BUILD files..."
echo ""

build_files=(
    "third_party/rcutils.BUILD"
    "third_party/rcl.BUILD"
    "third_party/rclcpp.BUILD"
    "third_party/rmw.BUILD"
    "third_party/rmw_zenoh.BUILD"
    "third_party/zenoh_c.BUILD"
)

for file in "${build_files[@]}"; do
    if [ -f "$file" ]; then
        echo -e "${GREEN}✓${NC} $file"
    else
        echo -e "${RED}✗${NC} $file not found"
        all_good=false
    fi
done

echo ""
echo "=========================================="
if [ "$all_good" = true ]; then
    echo -e "${GREEN}All required components are present!${NC}"
    echo ""
    echo "You can now build the project with:"
    echo "  bazel build //:ros2_node"
    echo ""
    echo "Or use the Makefile:"
    echo "  make build"
    echo ""
    exit 0
else
    echo -e "${RED}Some required components are missing.${NC}"
    echo "Please fix the issues above before building."
    echo ""
    exit 1
fi
