# Unit tests with Catch2

These are the instructions to build the Pico SDK and Catch2 unit tests on Windows.
To set up, run `source /opt/ros/humble/setup.bash` in the devcontainer.
## Building
Run the following in the devcontainer.
### Without Unit Tests
```bash
cmake -B build -S src/microros
cmake --build build
```
Output: `build/pico_microros.uf2`
Upload this to your Pico.

### With Unit Tests
```bash
cmake -B build_unit_tests -S src/microros -DBUILD_UNIT_TESTS=ON
cmake --build build_unit_tests
```

Output: `build_unit_tests/unit_tests`

## Interfacing
In Windows, we need to pass the Pico to WSL. Skip this step on Linux.
Execute `usbipd list` in an elevated PowerShell to get your Pico's BUSID.

The Pico will be the line containing 2e8a. We need to attach the Pico to WSL. 

```
usbipd bind --busid <BUSID>
usbipd attach --wsl --busid <BUSID>
```

Start the MicroROS agent in a new WSL terminal: `docker run -it --rm -v /dev:/dev --privileged --net=host microros/micro-ros-agent:humble serial --dev /dev/<Pico path> -b 115200`

## Running the tests
Run `./build_unit_tests/unit_tests` in the devcontainer

## Adding New Tests

Edit `src/microros/src/unittests.cpp` and add new `TEST_CASE` blocks:

```cpp
TEST_CASE("My new test", "[test][pico]") {
    PicoInterface pico;
    
    // Wait for connection
    std::this_thread::sleep_for(2000ms);
    rclcpp::spin_some(test_node);
    
    // Your test logic here
    
    REQUIRE(true);
}
```

## Executing your tests
`./build_unit_tests/unit_tests`

This will output if your tests passes or not.

## Troubleshooting
Rebuild tests: `cmake --build build_unit_tests` in the devcontainer CLI
Check ROS 2 topic visibility: `ros2 topic list` in the devcontainer
