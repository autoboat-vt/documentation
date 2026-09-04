---
title: Object Detection
description: Object detection node details.
---

# <p style="text-align: center;"> Object Detection </p>

## Summary

This node detects **buoys** and **boats** on the water and estimates their **bearing (angle)** and **position**.  
Detection is powered by an [Ultralytics **YOLO26** model](https://docs.ultralytics.com/models/yolo26/).
The pipeline is built with [Deepstream](https://docs.nvidia.com/metropolis/deepstream/7.1/text/DS_Overview.html) and [Gstreamer](https://gstreamer.freedesktop.org/).

The node runs on **ROS 2** and publishes:

- **Bearing to target (angle)** — relative to the camera/boat frame.

- **Per-detection metadata** — confidence score, relative x/y of the bounding box, etc.

### What it publishes
- `/object_detection_results_list`
    - Message: `autoboat_msgs/msg/ObjectDetectionResultsList`
    - `detection_results[]`: `{ detector_confidence, tracker_confidence, x_position, y_position, width, height, object_id, class_id, angle_to_object }`
    - `timestamp`
    - `model_name`
    - `yolo_version`
    - `threshold`

### What it subscribes to
- `/cv_parameters`
    - `model_name`. The name of the model to use for inferencing without the file extension (Ex: yolo26s.pt -> yolo26s)
    - `threshold`. The detection threshold for the primary detector

## <p style="text-align: center"> Running the node </p>
Follow the [DeepStream installation instructions](../../getting_started/install_object_detection.md)

```sh
ros2 run object_detection object_detection
```

### <p style="text-align: center"> Optional environment variables </p>
Set these before running the ROS2 node

- `export YOLO_VER=11` or `export YOLO_VER=26`: The default yolo version is 26. Set this to use Yolo11.
- `export INFERENCE=false`: Disables inference.
- `export CAMERA=false`: Disables the camera.

### <p style="text-align: center"> Changing CV parameters while running </p>

See [changing CV and localization parameters](changing_params.md).