---
title: Localization
description: Localization node details.
---

# <p style="text-align: center;"> Localization </p>

## Summary

This node calculates the real-world positions of objects detected by the object detection node. The node requires current position data to be able to triangulate objects.

### What it publishes

- `/triangulation_results_list`
    - Message: `autoboat_msg/msg/TriangulationResultsList`
    - `triangulation_results[]`: `{ object_id, class_id, label, latitude, longitude }`
    - `iou_threshold`

- `/object_detection_emergency_stop`
    - bool `data`

### What it subscribes to

- `/localization_parameters`
    - `buffer_window_size`. The number of object detections to save for triangulation.
    - `iou_threshold`. If two objects are triangulated to be within this distance in meters, they are assumed to be the same physical object and the older one is dropped.
    - `update_rate`. How often to perform triangulation and publish triangulation results in seconds.
- `/object_detection_results_list`
- `/heading`
- `/position`

## <p style="text-align: center"> Running the node </p>

Follow the [DeepStream installation instructions](../../getting_started/install_object_detection.md)

```sh
ros2 run object_detection localization
```

### <p style="text-align: center"> Changing localization parameters while running </p>

See [changing CV and localization parameters](changing_params.md).