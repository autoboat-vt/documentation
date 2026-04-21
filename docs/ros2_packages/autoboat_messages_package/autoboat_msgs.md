# <p style="text-align: center;"> AutoBoat Messages </p>

## **Summary**
This package contains various custom messages types that nodes would need to send to each other! Try to add messages to the custom messages library sparingly as we would like most nodes to only publish/ listen with a message type in the base ros2 messages. [Here is a list of all of the standard messages that I would recommend using](https://github.com/ros2/common_interfaces). This keeps our code easily compatible with other peoples' drivers so we can just drop in other peoples' drivers if we ever need to.

<br>

## **Contains the Following Messages**
**RCData**: A standardized way to send RC Data based on the Radiomaster TX12 buttons. Includes both joysticks and all switches/ buttons

**WaypointList**: A list of NavSatFix objects (https://docs.ros.org/en/noetic/api/sensor_msgs/html/msg/NavSatFix.html) that represents a list of waypoints. These are passed around and then interpretted by the autopilot to figure out how it should move to get to those waypoints.

**VESCControlData**: Contains all of the data that you need to send in order to command the vesc

**VESCTelemetryData**: Telemetry data from the VESC that gives us feedback about how fast the motor is spinning, how much voltage/ current is being used, etc

**ObjectDetectionResult**: Contains a confidence value and an xy position for the object that the computer vision model found

**ObjectDetectionResultsList**: A list of ObjectDetectionResults