---
title: Changing CV and Localization Parameters
description: How to change CV and Localization Parameters.
---

# <p style="text-align: center;"> Changing CV and Localization Parameters </p>

The script, `publish_cv_params.py`, can change parameters for both the object detection node and the localization node.

## Usage

Open a new terminal and navigate to to the object_detection folder.
```sh
cd /home/ws/ros_packages/object_detection/object_detection
```

Run the `publish_cv_params.py` script. Choose any number of these parameters. It will only adjust parameters if the respective node is running.

```sh
python publish_cv_params.py [-m MODEL] [-t THRESHOLD] [-b BUFFER_SIZE] [-u UPDATE_RATE] [-i IOU_THRESHOLD]
```

For object detection, the parameters will remain changed after restarting. For localization, the parameters are reset to the default values.

### Object Detection Parameters

- `-m`. The model name to switch to. Do not include the file extension (Ex. yolo26s.pt -> yolo26s). The model can be either Yolo11 or Yolo26, as long as it has been previously built into an engine file.
- `-t`. The threshold for the detector. Enter a number in the range (0, 1)

### Localization Parameters

- `-b`. The number of detections to save for triangulation. The default is 300 frames (approximately 10 seconds).
- `-u`. How often to triangulate objects in seconds. Default is every 0.5 seconds.
- `-i`. During localization, if two objects are within this distance in meters, they are considered the same object and the older one is disregarded. Default is 10 meters.