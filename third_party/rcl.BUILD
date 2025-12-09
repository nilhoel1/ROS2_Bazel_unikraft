# Build file for rcl (ROS2 Client Library)
# This is a simplified stub - in production, this would use cmake() from rules_foreign_cc

load("@rules_foreign_cc//foreign_cc:defs.bzl", "cmake")

filegroup(
    name = "all_srcs",
    srcs = glob(["**"]),
)

cmake(
    name = "rcl",
    cache_entries = {
        "BUILD_TESTING": "OFF",
        "CMAKE_BUILD_TYPE": "Release",
    },
    lib_source = ":all_srcs",
    out_static_libs = ["librcl.a"],
    deps = [
        "@rcutils//:rcutils",
    ],
    visibility = ["//visibility:public"],
)
