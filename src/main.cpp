// ROS2 Static PIE Binary Demo for Unikraft
//
// This is a minimal demonstration of building ROS2-style code as a static PIE binary.
// Full ROS2 (rclcpp) requires extensive dependencies - this demo uses rcutils to show the concept.

#include <rcutils/logging.h>
#include <rcutils/logging_macros.h>
#include <rcutils/error_handling.h>
#include <rcutils/allocator.h>
#include <rcutils/time.h>

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <signal.h>

static volatile int running = 1;

void signal_handler(int sig) {
    (void)sig;
    running = 0;
}

int main(int argc, char** argv) {
    (void)argc;
    (void)argv;

    // Setup signal handler
    signal(SIGINT, signal_handler);
    signal(SIGTERM, signal_handler);

    // Initialize rcutils logging
    rcutils_ret_t ret = rcutils_logging_initialize();
    if (ret != RCUTILS_RET_OK) {
        fprintf(stderr, "Failed to initialize logging: %d\n", ret);
        return 1;
    }

    // Set log level to INFO
    rcutils_logging_set_default_logger_level(RCUTILS_LOG_SEVERITY_INFO);

    printf("===========================================\n");
    printf("  ROS2 Static PIE Demo for Unikraft\n");
    printf("===========================================\n");
    printf("This binary is statically linked as a PIE\n");
    printf("and can run on Unikraft unikernel.\n\n");

    RCUTILS_LOG_INFO("ROS2 rcutils logging initialized successfully!");
    RCUTILS_LOG_INFO("Running main loop (press Ctrl+C to exit)...");

    // Get allocator for demonstration
    rcutils_allocator_t allocator = rcutils_get_default_allocator();

    // Demonstrate memory allocation
    void * ptr = allocator.allocate(1024, allocator.state);
    if (ptr != NULL) {
        RCUTILS_LOG_INFO("Successfully allocated 1024 bytes");
        allocator.deallocate(ptr, allocator.state);
        RCUTILS_LOG_INFO("Memory deallocated");
    }

    int counter = 0;
    while (running) {
        counter++;

        // Get current time
        rcutils_time_point_value_t now;
        ret = rcutils_system_time_now(&now);
        if (ret == RCUTILS_RET_OK) {
            // Convert to seconds
            int64_t seconds = now / 1000000000LL;
            RCUTILS_LOG_INFO("Tick #%d - System time: %lld seconds", counter, (long long)seconds);
        } else {
            RCUTILS_LOG_WARN("Could not get system time");
        }

        // Sleep for 1 second
        sleep(1);

        // Exit after 5 iterations in demo mode
        if (counter >= 5) {
            RCUTILS_LOG_INFO("Demo complete - exiting after 5 iterations");
            break;
        }
    }

    RCUTILS_LOG_INFO("Shutting down...");

    // Cleanup
    ret = rcutils_logging_shutdown();
    if (ret != RCUTILS_RET_OK) {
        fprintf(stderr, "Failed to shutdown logging\n");
    }

    printf("Goodbye from ROS2 Static PIE Demo!\n");
    return 0;
}
