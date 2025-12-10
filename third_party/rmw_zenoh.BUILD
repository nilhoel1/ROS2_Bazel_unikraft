# Build file for rmw_zenoh (Zenoh RMW implementation)
# This is a simplified stub - in production, this would use cmake() from rules_foreign_cc

load("@rules_foreign_cc//foreign_cc:defs.bzl", "cmake")

filegroup(
    name = "all_srcs",
    srcs = glob(["**"]),
)

cmake(
    name = "rmw_zenoh",
    cache_entries = {
        "BUILD_TESTING": "OFF",
        "CMAKE_BUILD_TYPE": "Release",
        "CMAKE_CXX_STANDARD": "17",
    },
    lib_source = ":all_srcs",
    out_static_libs = [
        "librmw_zenoh_cpp.a",
    ],
    deps = [
        "@rmw//:rmw",
        "@rcl//:rcl",
        "@rcutils//:rcutils",
        "@zenoh_c//:zenoh_c",
    ],
    visibility = ["//visibility:public"],
)
