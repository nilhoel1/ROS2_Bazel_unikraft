# Build file for rclcpp (ROS2 C++ Client Library)
# This is a simplified stub - in production, this would use cmake() from rules_foreign_cc

load("@rules_foreign_cc//foreign_cc:defs.bzl", "cmake")

filegroup(
    name = "all_srcs",
    srcs = glob(["**"]),
)

cmake(
    name = "rclcpp",
    cache_entries = {
        "BUILD_TESTING": "OFF",
        "CMAKE_BUILD_TYPE": "Release",
        "CMAKE_CXX_STANDARD": "17",
    },
    lib_source = ":all_srcs",
    out_static_libs = ["librclcpp.a"],
    deps = [
        "@rcl//:rcl",
        "@rcutils//:rcutils",
    ],
    visibility = ["//visibility:public"],
)
