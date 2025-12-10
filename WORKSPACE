workspace(name = "ros2_bazel_unikraft")

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

# NOTE: This is a demonstration/template WORKSPACE file.
# The SHA256 checksums below are placeholders and must be replaced with actual checksums
# before building. To get the correct checksum, download the archive and run:
#   sha256sum <archive.tar.gz>
# or
#   shasum -a 256 <archive.tar.gz>
# Alternatively, you can temporarily remove the sha256 attribute, let Bazel download
# the file, and it will report the correct checksum in the error message.

# Bazel Features - required by rules_python and rules_cc
http_archive(
    name = "bazel_features",
    sha256 = "07271d0f6b12633777b69020c4cb1eb67b1939c0cf84bb3944dc85cc250c0c01",
    strip_prefix = "bazel_features-1.38.0",
    url = "https://github.com/bazel-contrib/bazel_features/releases/download/v1.38.0/bazel_features-v1.38.0.tar.gz",
)

load("@bazel_features//:deps.bzl", "bazel_features_deps")

bazel_features_deps()

# Bazel Skylib - utilities for Bazel rules
http_archive(
    name = "bazel_skylib",
    sha256 = "66ffd9315665bfaafc96b52278f57c7e2dd09f5ede279ea6d39b2be471e7e3aa",
    urls = [
        "https://github.com/bazelbuild/bazel-skylib/releases/download/1.4.2/bazel-skylib-1.4.2.tar.gz",
    ],
)

# Rules CC - must come before rules_python
http_archive(
    name = "rules_cc",
    sha256 = "bbf1ae2f83305b7053b11e4467d317a7ba3517a12cef608543c1b1c5bf48a4df",
    strip_prefix = "rules_cc-0.0.16",
    url = "https://github.com/bazelbuild/rules_cc/releases/download/0.0.16/rules_cc-0.0.16.tar.gz",
)

# Rules Python
http_archive(
    name = "rules_python",
    sha256 = "9c6e26911a79fbf510a8f06d8eedb40f412023cf7fa6d1461def27116bff022c",
    strip_prefix = "rules_python-1.1.0",
    url = "https://github.com/bazelbuild/rules_python/releases/download/1.1.0/rules_python-1.1.0.tar.gz",
)

load("@rules_python//python:repositories.bzl", "py_repositories")

py_repositories()

# Rules for foreign cc (for CMake-based projects)
http_archive(
    name = "rules_foreign_cc",
    sha256 = "2a4d07cd64b0719b39a7c12218a3e507672b82a97b98c6a89d38565894cf7c51",
    strip_prefix = "rules_foreign_cc-0.9.0",
    url = "https://github.com/bazelbuild/rules_foreign_cc/archive/refs/tags/0.9.0.tar.gz",
)

load("@rules_foreign_cc//foreign_cc:repositories.bzl", "rules_foreign_cc_dependencies")
rules_foreign_cc_dependencies()

# rcutils - ROS2 C utilities
# TODO: Replace sha256 with actual checksum (see note above)
http_archive(
    name = "rcutils",
    build_file = "@//:third_party/rcutils.BUILD",
    strip_prefix = "rcutils-6.2.1",
    urls = [
        "https://github.com/ros2/rcutils/archive/refs/tags/6.2.1.tar.gz",
    ],
    # sha256 = "TODO: Add actual SHA256 checksum",
)

# rcl - ROS2 Client Library
# TODO: Replace sha256 with actual checksum (see note above)
http_archive(
    name = "rcl",
    build_file = "@//:third_party/rcl.BUILD",
    strip_prefix = "rcl-6.0.1",
    urls = [
        "https://github.com/ros2/rcl/archive/refs/tags/6.0.1.tar.gz",
    ],
    # sha256 = "TODO: Add actual SHA256 checksum",
)

# rclcpp - ROS2 C++ Client Library
# TODO: Replace sha256 with actual checksum (see note above)
http_archive(
    name = "rclcpp",
    build_file = "@//:third_party/rclcpp.BUILD",
    strip_prefix = "rclcpp-21.0.0",
    urls = [
        "https://github.com/ros2/rclcpp/archive/refs/tags/21.0.0.tar.gz",
    ],
    # sha256 = "TODO: Add actual SHA256 checksum",
)

# rmw - ROS2 Middleware Interface
# TODO: Replace sha256 with actual checksum (see note above)
http_archive(
    name = "rmw",
    build_file = "@//:third_party/rmw.BUILD",
    strip_prefix = "rmw-7.1.0",
    urls = [
        "https://github.com/ros2/rmw/archive/refs/tags/7.1.0.tar.gz",
    ],
    # sha256 = "TODO: Add actual SHA256 checksum",
)

# rmw_zenoh - Zenoh RMW implementation
# TODO: Replace sha256 with actual checksum (see note above)
http_archive(
    name = "rmw_zenoh",
    build_file = "@//:third_party/rmw_zenoh.BUILD",
    strip_prefix = "rmw_zenoh-0.1.0",
    urls = [
        "https://github.com/ros2/rmw_zenoh/archive/refs/tags/0.1.0.tar.gz",
    ],
    # sha256 = "TODO: Add actual SHA256 checksum",
)

# Zenoh C library
# TODO: Replace sha256 with actual checksum (see note above)
http_archive(
    name = "zenoh_c",
    build_file = "@//:third_party/zenoh_c.BUILD",
    strip_prefix = "zenoh-c-0.10.1-rc",
    urls = [
        "https://github.com/eclipse-zenoh/zenoh-c/archive/refs/tags/0.10.1-rc.tar.gz",
    ],
    # sha256 = "TODO: Add actual SHA256 checksum",
)
