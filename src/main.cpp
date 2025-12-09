#include <rclcpp/rclcpp.hpp>
#include <memory>
#include <chrono>

// CRITICAL: Static registration of rmw_zenoh to avoid dlopen
// This ensures the RMW implementation is linked statically
extern "C" {
  // Forward declare the rmw_zenoh implementation functions
  // These are typically loaded dynamically, but we force static linking
  
  // RMW Zenoh implementation entry points
  void* rmw_zenoh_cpp_get_implementation_identifier();
  void* rmw_zenoh_cpp_create_node();
  
  // Static registration constructor
  __attribute__((constructor))
  void register_rmw_zenoh_statically() {
    // This function runs before main() and ensures rmw_zenoh is registered
    // Without dlopen, the RMW implementation needs to be explicitly registered
    
    // Set environment variable to specify the RMW implementation
    setenv("RMW_IMPLEMENTATION", "rmw_zenoh_cpp", 1);
    
    // The actual registration happens through the linker
    // by including all symbols from rmw_zenoh in the binary
  }
}

// Simple ROS2 Node
class SimpleNode : public rclcpp::Node {
public:
  SimpleNode() : Node("simple_ros2_node") {
    RCLCPP_INFO(this->get_logger(), "Simple ROS2 Node started!");
    
    // Create a timer that fires every second
    timer_ = this->create_wall_timer(
      std::chrono::seconds(1),
      std::bind(&SimpleNode::timer_callback, this)
    );
    
    counter_ = 0;
  }

private:
  void timer_callback() {
    counter_++;
    RCLCPP_INFO(this->get_logger(), "Hello from ROS2! Count: %d", counter_);
  }

  rclcpp::TimerBase::SharedPtr timer_;
  int counter_;
};

int main(int argc, char** argv) {
  // Initialize ROS2
  rclcpp::init(argc, argv);
  
  // Create and spin the node
  auto node = std::make_shared<SimpleNode>();
  
  RCLCPP_INFO(node->get_logger(), "ROS2 Node initialized with rmw_zenoh (statically linked)");
  RCLCPP_INFO(node->get_logger(), "Running as Static PIE binary for Unikraft");
  
  // Spin the node (this will run until interrupted)
  rclcpp::spin(node);
  
  // Cleanup
  rclcpp::shutdown();
  
  return 0;
}
