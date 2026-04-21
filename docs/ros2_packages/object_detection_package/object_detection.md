# <p style="text-align: center;">Object Detection</p>

## Summary

This node detects **buoys** and **boats** on the water and estimates their **bearing (angle)** and **position**.  
Detection is powered by an [Ultralytics **YOLO26** model](https://docs.ultralytics.com/models/yolo26/).
The pipeline is built with [Deepstream](https://docs.nvidia.com/metropolis/deepstream/7.1/text/DS_Overview.html) and [Gstreamer](https://gstreamer.freedesktop.org/).

The node runs on **ROS 2** and publishes:

- **Bearing to target (angle)** — relative to the camera/boat frame.

- **Triangulated Position** — Absolute position using camera GPS and heading data.

- **Per-detection metadata** — confidence score, relative x/y of the bounding box, etc.

### What it publishes
- `autoboat_msgs/msg/ObjectDetectionResultsList`
    - Topic: `/object_detection_results_list`
    - `detection_results[]`: `{ detector_confidence, tracker_confidence, x_position, y_position, width, height, object_id, class_id, angle_to_object }`
    - `timestamp`
    - `model_name`
    - `yolo_version`
    - `threshold`
- `autoboat_msg/msg/TriangulationResultsList`
    - Topic: `/triangulation_results_list`
    - `triangulation_results[]`: `{ object_id, class_id, label, latitude, longitude }`
    - `iou_threshold`

### What it subscribes to
- `/cv_parameters`
    - `buffer_window_size`. The number of object detections to save for triangulation.
    - `iou_threshold`. If two objects are triangulated to be within this distance in meters, they are assumed to be the same physical object and the older one is dropped.
    - `update_rate`. How often to perform triangulation and publish triangulation results in seconds.
    - `model_name`. The name of the model to use for inferencing without the file extension (Ex: yolo26s.pt -> yolo26s)
    - `threshold`. The detection threshold for the primary detector
- `/heading`
- `/position`


## <p style="text-align: center"> Running the node </p>
Follow the [DeepStream installation instructions](../../getting_started/install_object_detection.md)

```sh
ros2 run object_detection object_detection
```

### <p style="text-align: center"> Optional environment variables </p>
Set these before running the ROS2 node

- `export YOLO_VER=11` or `export YOLO_VER=26`: The default yolo version is 26. Set this to use Yolo11.
- `export INFERENCE=false`: Disables inference and triangulation.
- `export CAMERA=false`: Disables the camera.

### <p style="text-align: center"> Changin CV parameters while running </p>
Open a new terminal and navigate to to the object_detection folder.
```sh
cd /home/ws/src/object_detection/object_detection
```
Run the `publish_cv_params.py` script.
```sh
python publish_cv_params.py [-m MODEL] [-t THRESHOLD] [-b BUFFER_SIZE] [-u UPDATE_RATE] [-i IOU_THRESHOLD]
```
Choose any number of these options.

- `-m`. The model name to switch to. Do not include the file extension (Ex. yolo26s.pt -> yolo26s). The model can be either Yolo11 or Yolo26, as long as it has been previously build into an engine file.
- `-t`. The threshold for the detector. Enter a number in the range (0, 1)
- `-b`. The number of detections to save for triangulation. The default is 300 frames (approximately 10 seconds).
- `-u`. How often to triangulate objects in seconds. Default is every 0.5 seconds.
- `-i`. During triangulation, if two objects are within this distance in meters, they are considered the same object and the older one is disregarded. Default is 10 meters.