workspace(name = "ros2_bazel_unikraft")

# NOTE: This WORKSPACE uses local repositories with hardcoded paths in /tmp/bazel_deps
# This is a workaround for SSL certificate issues in the build environment.
# For production use, consider:
#   1. Using environment variables for dependency paths
#   2. Fixing SSL certificates properly
#   3. Using Bazel's remote caching or vendoring
# See BUILD_NOTES.md for details on setting up dependencies.

# Use local repositories to avoid SSL issues
local_repository(
    name = "bazel_features",
    path = "/tmp/bazel_deps/bazel_features-1.38.0",
)

# Bazel Skylib - utilities for Bazel rules (using files from bazel_features extraction)
local_repository(
    name = "bazel_skylib",
    path = "/tmp/bazel_deps",  # Uses the skylib files extracted in bazel_deps
)

# Rules CC
local_repository(
    name = "rules_cc",
    path = "/tmp/bazel_deps/rules_cc-0.0.9",
)

load("@bazel_features//:deps.bzl", "bazel_features_deps")

bazel_features_deps()

# Rules Python - commented out as not needed for this build
# http_archive(
#     name = "rules_python",
#     sha256 = "9c6e26911a79fbf510a8f06d8eedb40f412023cf7fa6d1461def27116bff022c",
#     strip_prefix = "rules_python-1.1.0",
#     url = "https://github.com/bazelbuild/rules_python/releases/download/1.1.0/rules_python-1.1.0.tar.gz",
# )
#
# load("@rules_python//python:repositories.bzl", "py_repositories")
#
# py_repositories()

# Rules for foreign cc (for CMake-based projects) - commented out as not needed
# http_archive(
#     name = "rules_foreign_cc",
#     sha256 = "2a4d07cd64b0719b39a7c12218a3e507672b82a97b98c6a89d38565894cf7c51",
#     strip_prefix = "rules_foreign_cc-0.9.0",
#     url = "https://github.com/bazelbuild/rules_foreign_cc/archive/refs/tags/0.9.0.tar.gz",
# )
#
# load("@rules_foreign_cc//foreign_cc:repositories.bzl", "rules_foreign_cc_dependencies")
# rules_foreign_cc_dependencies()

# rcutils - ROS2 C utilities
new_local_repository(
    name = "rcutils",
    build_file = "@//:third_party/rcutils.BUILD",
    path = "/tmp/bazel_deps/rcutils-6.2.1",
)

# rcl - ROS2 Client Library - Not needed for this minimal demo
# http_archive(
#     name = "rcl",
#     build_file = "@//:third_party/rcl.BUILD",
#     strip_prefix = "rcl-6.0.1",
#     urls = [
#         "https://github.com/ros2/rcl/archive/refs/tags/6.0.1.tar.gz",
#     ],
# )

# rclcpp - ROS2 C++ Client Library - Not needed for this minimal demo
# http_archive(
#     name = "rclcpp",
#     build_file = "@//:third_party/rclcpp.BUILD",
#     strip_prefix = "rclcpp-21.0.0",
#     urls = [
#         "https://github.com/ros2/rclcpp/archive/refs/tags/21.0.0.tar.gz",
#     ],
# )

# rmw - ROS2 Middleware Interface - Not needed for this minimal demo
# http_archive(
#     name = "rmw",
#     build_file = "@//:third_party/rmw.BUILD",
#     strip_prefix = "rmw-7.1.0",
#     urls = [
#         "https://github.com/ros2/rmw/archive/refs/tags/7.1.0.tar.gz",
#     ],
# )

# rmw_zenoh - Zenoh RMW implementation - Not needed for this minimal demo
# http_archive(
#     name = "rmw_zenoh",
#     build_file = "@//:third_party/rmw_zenoh.BUILD",
#     strip_prefix = "rmw_zenoh-0.1.0",
#     urls = [
#         "https://github.com/ros2/rmw_zenoh/archive/refs/tags/0.1.0.tar.gz",
#     ],
# )

# Zenoh C library - Not needed for this minimal demo
# http_archive(
#     name = "zenoh_c",
#     build_file = "@//:third_party/zenoh_c.BUILD",
#     strip_prefix = "zenoh-c-0.10.1-rc",
#     urls = [
#         "https://github.com/eclipse-zenoh/zenoh-c/archive/refs/tags/0.10.1-rc.tar.gz",
#     ],
# )
