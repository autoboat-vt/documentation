---
title: Groundstation
description: Groundstation overview and usage.
---

## Introduction

This document provides an overview of the Ground Station system, detailing its components, functionalities, and how it
integrates with other systems. The Ground Station is a critical part of the overall architecture, enabling communication
with the telemetry server and facilitating the management of boat operations. It lives in the
[`autoboat-vt/autoboat_vt`](https://github.com/autoboat-vt/autoboat_vt) repository under `ground_station/`.

The GUI is built on Qt through [`qtpy`](https://qtpy.readthedocs.io/en/stable/) (so it runs on either PySide6 or PyQt
without code changes). **Never import `PyQt5` or `PyQt6` directly - always go through `qtpy`.** Qt/PySide6 docs:
[PySide6 Documentation](https://doc.qt.io/qtforpython-6/index.html)

### Running the Groundstation

From a host with a display (not inside the headless devcontainer):

```bash
cd ground_station
chmod +x run.sh   # first time only
./run.sh
```

`run.sh` starts the Vite map server on `127.0.0.1:5173` and then launches the PyQt app. Prerequisites are
[Python](https://www.python.org/downloads) 3.10+ and [Bun](https://bun.sh) (see `ground_station/README.md`).

## Components Overview

!!! note "**NOTE ABOUT EXCEPTIONS IN THE GROUNDSTATION**"
Exceptions thrown in the groundstation do not behave like exceptions thrown in regular Python code.
The reason for the exception will not be printed to the console and must be handled in order for the
application to continue running. If you have code that you suspect may throw an exception, please enclose it
in a try/except block and handle the exception appropriately (ask Barrett if you are unsure how to handle it).

All data that persists between runs of the Ground Station and its assets are stored in the `app_data` directory.
Persistent UI state lives in `app_data/git_ignore/app_state.json` and is managed by the singleton `StateManager`
(`constants.SM`) in `src/utils/state_manager.py`. I have tried to split up the code in the Ground Station into logical
components to make it easier to understand and modify. The Ground Station is divided into the following main components:

### base components

#### main.py

This file is the main entry point for the Ground Station application. The code in this file is pretty self-explanatory and
will probably only need to be modified if you are adding entirely new functionality to the Ground Station. If you need
to know the specifics of what happens in this file, I recommend reading the code itself.

#### utils

##### constants.py

We will begin with the `constants.py` file, which defines objects that are used throughout the entire codebase.
In addition, this file checks for the presence of configuration files and assets that are essential for the
Ground Station's operation. The code in this file is the first to be run and is run before the actual
application is registered with PyQt. If you have code that will cause the application to crash or not behave correctly
when missing assets, it is best to place that code in this file. Additionally, code in this file cannot access properties
of the application object created by PyQt. **The icons used in the Ground Station are defined in this file, but are not
able to be used until the application is registered with PyQt, which happens in the `main.py` file.**

##### thread_classes.py

The `thread_classes.py` file contains classes that are used to manage threads within the Ground Station application.
I decided to places these classes in a separate file since they don't really feel like widgets, but may be hard to
find in the `constants.py` file if you didn't know they were there. These classes are essential for handling
asynchronous operations and ensuring that the Ground Station can perform tasks without blocking the main application thread.
I highly recommend reading the code in this file to understand how threads are managed and how they interact with the
rest of the application. Online resources on threads and how they work in PyQt may also be helpful if you are trying to
work with the code in this file.

##### state_manager.py

The `state_manager.py` file contains the code that manages the state of key variables in the Ground Station. It is used to
make sure that the state of the Ground Station is consistent across all of the different widgets and components. It also
provides protection against race conditions and makes sure that the state of the Ground Station is not modified in unexpected ways.

##### data_logger.py

The `data_logger.py` file contains classes and functions for logging telemetry data to CSV files. It handles the
formatting and writing of telemetry data, supporting both synchronous and asynchronous logging modes.

##### misc.py

The `misc.py` file contains utility functions that are used throughout the Ground Station codebase.
These functions are not specific to any one component and are used in multiple places throughout the code.
This file is a bit of a catch-all for functions that don't really fit anywhere else, but are still important
for the overall functionality of the Ground Station. If you are looking for a specific function and can't find
it in the code where you think it should be, it may be worth checking the `misc.py` file to see if it is
defined there.

##### popup_edit.py

The `popup_edit.py` file contains the `TextEditWindow` class, which creates a pop-up window for editing text in the
Ground Station. It takes a syntax highlighter (such as one of the highlighters defined in the `syntax_highlighters`
directory), some initial text, a tab width, and a font size as arguments, and uses a Qt signal to return the modified
text when the user clicks the "Save" button or closes the window. It is used in the Ground Station to edit buoy data,
some data types in the autopilot parameter editor, and the telemetry data "limits" that are used to determine when a
warning or error should be displayed.

##### syntax_highlighters

###### base_highlighter.py

The `base_highlighter.py` file contains the base class for syntax highlighters used in the Ground Station. I wanted to
take the QSyntaxHighlighter class and write some methods that would make it easier to write syntax highlighters for
whatever I needed. The methods in this class are meant to guide the implementation of syntax highlighters so that time is
not wasted trying to understand each individual method in the QSyntaxHighlighter class. The methods in this class are
not meant to be used directly, but rather to be overridden in subclasses that implement specific syntax highlighting
functionality. If you are writing a syntax highlighter for the Ground Station, you should start by subclassing this
class and implementing the methods that are relevant to your use case.

###### json.py

The `json.py` file contains a syntax highlighter specifically designed for JSON files. It extends the base highlighter
class and implements the necessary methods to provide syntax highlighting for JSON syntax. This highlighter is used
to enhance the readability of JSON files within the Ground Station, making it easier to work with configuration
files and other JSON data.

###### console.py

The `console.py` file contains a syntax highlighter for the console output within the Ground Station. This highlighter
is designed to improve the readability of console messages, making it easier to identify important information,
warnings, and errors. It uses the base highlighter class to implement specific highlighting rules for console
output, ensuring that messages are displayed in a clear and organized manner.

##### dialog_templates

The `dialog_templates/` directory contains reusable dialog widgets and convenience functions.

###### base_dialog.py

The `base_dialog.py` file contains the `BaseDialog` class - the base class for all dialog widgets in the Ground Station.
It provides:
- Title, message, and optional icon display
- "Remember my decision" checkbox support
- Standard result handling for dialog acceptance/rejection

###### custom_buttons_dialog.py

The `custom_buttons_dialog.py` file contains the `CustomMessageBoxDialog` class and `show_message_box()` function.
It provides custom message dialogs with configurable buttons and optional "remember choice" checkbox.

###### text_input_dialog.py

The `text_input_dialog.py` file contains the `InputDialog` class and `show_input_dialog()` function.
It wraps Qt's `QInputDialog` to provide consistent text, integer, and float input dialogs.

###### coordinate_input_dialog.py

The `coordinate_input_dialog.py` file contains a dialog for manually entering latitude/longitude waypoints as text
instead of clicking on the map. It is opened from the keybind handler when the user presses the "add waypoint by
coordinate" keybind.

##### widget_size_controllers

###### bounded_aspect_widget.py

The `bounded_aspect_widget.py` file contains a widget that maintains a bounded aspect ratio for its child widget.
This is useful for widgets that need to maintain a specific aspect ratio regardless of the parent widget's size.

###### preserve_aspect_widget.py

The `preserve_aspect_widget.py` file contains a widget that preserves the aspect ratio of its child widget while
allowing it to be resized. This is useful for displaying content that should not be distorted when resized.

### widgets

#### groundstation.py

This is the magnum opus of the Ground Station application. It was the first widget I wrote for the Ground Station
and is first widget that you see when you open the application. It serves as the main interface for interacting
with the Ground Station and allows users to add and remove waypoints and buoys, view telemetry data, and shows
popups that that are used to modify the state of the Ground Station. This file also uses some of the classes in the
`thread_classes.py` file to manage asynchronous operations, such as fetching telemetry data and updating the
interface without blocking the main thread. If you are looking to understand how the Ground Station works,
this is a great place to start.

#### instance_handler.py

This widget is used to manage instances of the simulation and the real boat. It provides a way to view info about all
available instances, a way to create and delete instances, and a way to connect to an instance. This widget is loaded before
the `groundstation.py` widget and is used to determine which instance the Ground Station should connect to when it starts up.

#### console_output.py

This widget is used to display the console output of the Ground Station. It uses a QPlainTextEdit to display the
output and the `console.py` syntax highlighter to provide syntax highlighting for the output. It also contains the code
that makes it possible to have the console output displayed in the terminal and in the Ground Station at the same time.
This is done by using a QThread and some redirection of the standard output streams to capture the console output
and display it in the widget.

#### graph_viewer.py

This widget is used to display graphs of telemetry data. It uses the [PyQtGraph](https://www.pyqtgraph.org) library to
create interactive graphs that can display multiple data series at once. The widget also provides functionality to customize
the appearance of the graphs, such as changing colors, adding legends, and adjusting the axes. The graph viewer is an
important tool for visualizing telemetry data and gaining insights into the boat's performance and behavior.

#### map_widget

This directory contains the code that is used to make displaying the waypoints and buoys on an interactive map possible.

##### waypoints_handler.py

This file contains the `WaypointsHandler` class, an HTTP request handler that manages waypoint data. It provides
endpoints to get and set waypoints (latitude/longitude pairs) and handles CORS for cross-origin requests.

##### server.py

This file runs a `ThreadingHTTPServer` on `constants.MAP_SERVER_PORT` that uses `WaypointsHandler` to serve
waypoint data to the JavaScript map frontend.

##### map_options_handler.py

This widget is used to create a window that allows for the editing of map appearance configurations, such as displaying
sailboat debugging symbols. This widget is opened by the button labeled `Map Appearance Config` at the bottom of the Ground Station.

The map widget uses a server to manage the transfer of waypoints and buoys between the Python code and the
JavaScript code running in the HTML file. The server exposes `get` and `set` endpoints that modify
an array containing the latitude and longitude of the waypoints and buoys which takes the form:

```json
[
    [1.0, 1.0],
    [2.0, 2.0],
    [3.0, 3.0],
    ...
]
```

Where latitude is the first element of each array and longitude is the second element.
The TypeScript/JavaScript frontend lives in the `frontend/` subdirectory and is a small [Vite](https://vitejs.dev)
app built with [Leaflet](https://leafletjs.com). The `tsconfig.json` `include` is hard-scoped to that
`frontend/` directory, so do not add map-widget TS files outside of it. The frontend is built/served by Vite
during development (`run.sh` starts it on `127.0.0.1:5173`) and embedded in the PyQt app via a `QWebEngineView`.

The frontend source files are:

| File            | Purpose                                                              |
| --------------- | -------------------------------------------------------------------- |
| `index.html`    | Vite entry HTML that mounts the map.                                 |
| `main.ts`       | App entry: initializes Leaflet, wires up the WebSocket/HTTP polling. |
| `types.ts`      | Shared TypeScript types (waypoints, buoys, boat state, etc.).        |
| `global.d.ts`   | Ambient declarations for assets/Vite-injected globals.               |
| `boat.ts`       | Renders the boat marker and updates its position/heading.            |
| `marker.ts`     | Generic marker helpers (positioning, icons, popups).                 |
| `waypoints.ts`  | Fetches and draws the waypoint polyline from the Python server.      |
| `buoys.ts`      | Fetches and draws buoy markers from the Python server.               |
| `keybinds.ts`   | Frontend-side keyboard handlers (e.g. click-to-add-waypoint).        |
| `svg.ts`        | SVG icons used for boat/buoy markers (e.g. the sailboat debug symbol).|

#### camera_widget

This directory contains the camera feed widget. It has two files: `camera.py` (the Python widget) and
`camera.html` (the HTML used to render the feed).

##### camera.py

The Python widget. It uses a QThread from the `thread_classes.py` file to fetch the camera feed from the boat
and forwards each frame to the HTML view as a base64-encoded image. It exposes buttons to start and stop the
feed so you can save bandwidth and processing power when the camera is not needed.

##### camera.html

The HTML file loaded by a `QWebEngineView` to display the feed. We use an HTML file because it can natively
render base64-encoded images, saving us the trouble of decoding them in Python.

#### autopilot_config_widget

This directory contains the widgets that are used to manage the autopilot parameters and configurations. It contains three files:
`config_editor.py`, `config_manager.py`, and `config_widget.py`.

##### config_widget.py

This widget just serves as a wrapper for the `config_editor.py` and `config_manager.py` widgets. It is used to display both of these widgets in one tab of the Ground Station. It doesn't contain much code itself, but it is used to manage the layout of the editor and manager widgets and make sure they are displayed correctly in the Ground Station.

##### config_editor.py

This widget is used to manage the autopilot parameters of the boat. It provides a way to view and edit the parameters, as well as a way to save and load parameter configurations. It also allows you to send the parameters to the boat and receive the current parameters from the boat. This widget is essential for tuning the autopilot and ensuring that the boat is performing optimally. An example json file containing autopilot parameters can be found at `app_data/autopilot_params/params_default.json`. The parameters in this file are not necessarily the best parameters for the boat, but they should be a good starting point for tuning the autopilot. They take the form:

```json
{
    "param_name": {
        "default": "default value of the parameter",
        "description": "A description of what this parameter does",
    },
    ...
}
```

##### config_manager.py

This widget is used to manage different autopilot configurations, both locally and on the telemetry server. It provides a way to view all available configurations, a way to create and delete configurations, and a way to download configurations from the telemetry server into the `app_data/autopilot_params` directory. This widget is important for keeping track of different parameter configurations and easily switching between them when tuning the autopilot.

#### user_guide.py

This widget displays a user guide overlay with documentation on how to use the Ground Station. It provides
interactive help without leaving the application.

#### keybind_widget

This directory contains the keyboard-shortcut system for the Ground Station. It contains three files:
`__init__.py`, `keybind_manager.py`, and `keybind_widget.py`.

##### keybind_manager.py

The `keybind_manager.py` file contains the `KeybindManager` class, which registers global key sequences
(left-click to add a waypoint, right-click to remove the nearest one, manual coordinate entry, etc.) and
dispatches them to the appropriate handlers. This is where you would register a new keybind.

##### keybind_widget.py

The `keybind_widget.py` file contains a small widget that lists all currently-registered keybinds and their
descriptions, so users can discover what shortcuts are available without reading the code.

#### easter_eggs

This directory contains hidden game widgets that are launched via secret key sequences. They are not part of
the core Ground Station functionality but are fun additions. Each game is in its own subdirectory:

- `pong_widget/` - a Pong clone
- `snake_widget/` - a Snake clone
- `tetris_widget/` - a Tetris clone

Each game subdirectory follows the same two-file pattern:

| File              | Purpose                                                                |
| ----------------- | ---------------------------------------------------------------------- |
| `<game>_game.py`  | The game logic and Qt rendering loop.                               |
| `<game>_audio.py` | Sound effects (synthesized via `QSound`/NumPy, no external assets). |

For example, `pong_widget/` contains `pong_game.py` and `pong_audio.py`, `snake_widget/` contains
`snake_game.py` and `snake_audio.py`, and `tetris_widget/` contains `tetris_game.py` and `tetris_audio.py`.

If you are adding a new easter egg, follow the same subdirectory-per-game pattern (with a `<game>_game.py` and
`<game>_audio.py` file), and register its launch keybind in `keybind_widget/keybind_manager.py`.
