# Build file for rcutils (ROS2 C utilities)
# Native Bazel build - bypasses CMake/ament build system

load("@rules_cc//cc:defs.bzl", "cc_library")

# Generate config header
genrule(
    name = "rcutils_config",
    outs = ["include/rcutils/configuration.h"],
    cmd = """
cat > $@ << 'EOF'
#ifndef RCUTILS__CONFIGURATION_H_
#define RCUTILS__CONFIGURATION_H_

#define RCUTILS_VERSION_MAJOR 6
#define RCUTILS_VERSION_MINOR 2
#define RCUTILS_VERSION_PATCH 1
#define RCUTILS_VERSION_STR "6.2.1"

// Enable thread safety
#define RCUTILS_THREAD_LOCAL thread_local

// Visibility macros
#define RCUTILS_PUBLIC __attribute__((visibility("default")))
#define RCUTILS_PUBLIC_TYPE __attribute__((visibility("default")))
#define RCUTILS_LOCAL __attribute__((visibility("hidden")))
#define RCUTILS_IMPORT
#define RCUTILS_EXPORT __attribute__((visibility("default")))

// Platform detection
#if defined(__APPLE__)
#define RCUTILS_HAVE_SETENV 1
#define RCUTILS_HAVE_GETENV 1
#elif defined(__linux__)
#define RCUTILS_HAVE_SETENV 1
#define RCUTILS_HAVE_GETENV 1
#endif

#endif  // RCUTILS__CONFIGURATION_H_
EOF
""",
)

# Generate visibility control header
genrule(
    name = "rcutils_visibility_control",
    outs = ["include/rcutils/visibility_control.h"],
    cmd = """
cat > $@ << 'EOF'
#ifndef RCUTILS__VISIBILITY_CONTROL_H_
#define RCUTILS__VISIBILITY_CONTROL_H_

#if defined(__cplusplus)
extern "C" {
#endif

#if defined(_WIN32)
  #ifdef RCUTILS_BUILDING_DLL
    #define RCUTILS_PUBLIC __declspec(dllexport)
    #define RCUTILS_PUBLIC_TYPE __declspec(dllexport)
  #else
    #define RCUTILS_PUBLIC __declspec(dllimport)
    #define RCUTILS_PUBLIC_TYPE __declspec(dllimport)
  #endif
  #define RCUTILS_LOCAL
#else
  #define RCUTILS_PUBLIC __attribute__((visibility("default")))
  #define RCUTILS_PUBLIC_TYPE __attribute__((visibility("default")))
  #define RCUTILS_LOCAL __attribute__((visibility("hidden")))
#endif

#define RCUTILS_WARN_UNUSED __attribute__((warn_unused_result))

#if defined(__cplusplus)
}
#endif

#endif  // RCUTILS__VISIBILITY_CONTROL_H_
EOF
""",
)

# Generate logging macros header
genrule(
    name = "rcutils_logging_macros",
    outs = ["include/rcutils/logging_macros.h"],
    cmd = """
cat > $@ << 'EOF'
#ifndef RCUTILS__LOGGING_MACROS_H_
#define RCUTILS__LOGGING_MACROS_H_

#include "rcutils/logging.h"

#define RCUTILS_LOG_COND_NAMED(severity, condition_before, condition_after, name, ...) \\
  do { \\
    RCUTILS_LOG_COND_NAMED_ ## severity(condition_before, condition_after, name, __VA_ARGS__); \\
  } while (0)

#define RCUTILS_LOG_DEBUG_NAMED(name, ...) \\
  rcutils_log(NULL, RCUTILS_LOG_SEVERITY_DEBUG, name, __VA_ARGS__)

#define RCUTILS_LOG_INFO_NAMED(name, ...) \\
  rcutils_log(NULL, RCUTILS_LOG_SEVERITY_INFO, name, __VA_ARGS__)

#define RCUTILS_LOG_WARN_NAMED(name, ...) \\
  rcutils_log(NULL, RCUTILS_LOG_SEVERITY_WARN, name, __VA_ARGS__)

#define RCUTILS_LOG_ERROR_NAMED(name, ...) \\
  rcutils_log(NULL, RCUTILS_LOG_SEVERITY_ERROR, name, __VA_ARGS__)

#define RCUTILS_LOG_FATAL_NAMED(name, ...) \\
  rcutils_log(NULL, RCUTILS_LOG_SEVERITY_FATAL, name, __VA_ARGS__)

#define RCUTILS_LOG_DEBUG(...) RCUTILS_LOG_DEBUG_NAMED("", __VA_ARGS__)
#define RCUTILS_LOG_INFO(...) RCUTILS_LOG_INFO_NAMED("", __VA_ARGS__)
#define RCUTILS_LOG_WARN(...) RCUTILS_LOG_WARN_NAMED("", __VA_ARGS__)
#define RCUTILS_LOG_ERROR(...) RCUTILS_LOG_ERROR_NAMED("", __VA_ARGS__)
#define RCUTILS_LOG_FATAL(...) RCUTILS_LOG_FATAL_NAMED("", __VA_ARGS__)

// Expression-based macros
#define RCUTILS_LOG_ERROR_EXPRESSION(expression, ...) \\
  do { \\
    if (expression) { \\
      RCUTILS_LOG_ERROR(__VA_ARGS__); \\
    } \\
  } while (0)

#define RCUTILS_LOG_WARN_EXPRESSION(expression, ...) \\
  do { \\
    if (expression) { \\
      RCUTILS_LOG_WARN(__VA_ARGS__); \\
    } \\
  } while (0)

#define RCUTILS_LOG_INFO_EXPRESSION(expression, ...) \\
  do { \\
    if (expression) { \\
      RCUTILS_LOG_INFO(__VA_ARGS__); \\
    } \\
  } while (0)

#define RCUTILS_LOG_DEBUG_EXPRESSION(expression, ...) \\
  do { \\
    if (expression) { \\
      RCUTILS_LOG_DEBUG(__VA_ARGS__); \\
    } \\
  } while (0)

#endif  // RCUTILS__LOGGING_MACROS_H_
EOF
""",
)

cc_library(
    name = "rcutils",
    srcs = glob(
        ["src/*.c"],
        exclude = [
            "src/time_win32.c",  # Windows only
        ],
    ) + glob(["src/*.h"]),
    hdrs = glob(["include/**/*.h"]) + [
        ":rcutils_config",
        ":rcutils_visibility_control",
        ":rcutils_logging_macros",
    ],
    copts = [
        "-std=c11",
        "-fPIC",
        "-DRCUTILS_BUILDING_DLL",
        "-D_GNU_SOURCE",  # Expose POSIX time functions (clock_gettime, CLOCK_REALTIME, etc.)
    ],
    includes = ["include"],
    linkopts = select({
        "@platforms//os:linux": ["-ldl", "-lpthread", "-lrt"],
        "@platforms//os:macos": ["-ldl", "-lpthread"],
        "//conditions:default": [],
    }),
    visibility = ["//visibility:public"],
)
