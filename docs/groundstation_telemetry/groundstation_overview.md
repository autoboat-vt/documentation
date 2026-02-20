## Introduction

This document provides an overview of the Ground Station system, detailing its components, functionalities, and how it
integrates with other systems. The Ground Station is a critical part of the overall architecture, enabling communication
with the telemetry server and facilitating the management of boat operations. Link to PyQt documentation:
[PyQt Documentation](https://doc.qt.io/archives/qtforpython-5/contents.html)

## Components Overview

!!! note "**NOTE ABOUT EXCEPTIONS IN THE GROUNDSTATION**"
Exceptions thrown in the groundstation do not behave like exceptions thrown in regular Python code.
The reason for the exception will not be printed to the console and must be handled in order for the
application to continue running. If you have code that you suspect may throw an exception, please enclose it
in a try/except block and handle the exception appropriately (ask Barrett if you are unsure how to handle it).

All data that persists between runs of the Ground Station and its assets are stored in the `app_data` directory.
I have tried to split up the code in the Ground Station into logical components to make it easier to understand and modify.
The Ground Station is divided into the following main components:

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
I decided to places these classes in a seperate file since they don't really feel like widgets, but may be hard to
find in the `constants.py` file if you didn't know they were there. These classes are essential for handling
asynchronous operations and ensuring that the Ground Station can perform tasks without blocking the main application thread.
I highly recommend reading the code in this file to understand how threads are managed and how they interact with the
rest of the application. Online resources on threads and how they work in PyQt may also be helpful if you are trying to
work with the code in this file.

##### state_manager.py

The `state_manager.py` file contains the code that manages the state of key variables in the Ground Station. It is used to
make sure that the state of the Ground Station is consistent across all of the different widgets and components. It also
provides protection against race conditions and makes sure that the state of the Ground Station is not modified in unexpected ways.

##### misc.py

The `misc.py` file contains utility functions that are used throughout the Ground Station codebase.
These functions are not specific to any one component and are used in multiple places throughout the code.
This file is a bit of a catch-all for functions that don't really fit anywhere else, but are still important
for the overall functionality of the Ground Station. If you are looking for a specific function and can't find
it in the code where you think it should be, it may be worth checking the `misc.py` file to see if it is
defined there.

### syntax_highlighters

#### base_highlighter.py

The `base_highlighter.py` file contains the base class for syntax highlighters used in the Ground Station. I wanted to
take the QSyntaxHighlighter class and write some methods that would make it easier to write syntax highlighters for
whatever I needed. The methods in this class are meant to guide the implementation of syntax highlighters so that time is
not wasted trying to understand each individual method in the QSyntaxHighlighter class. The methods in this class are
not meant to be used directly, but rather to be overridden in subclasses that implement specific syntax highlighting
functionality. If you are writing a syntax highlighter for the Ground Station, you should start by subclassing this
class and implementing the methods that are relevant to your use case.

#### json.py

The `json.py` file contains a syntax highlighter specifically designed for JSON files. It extends the base highlighter
class and implements the necessary methods to provide syntax highlighting for JSON syntax. This highlighter is used
to enhance the readability of JSON files within the Ground Station, making it easier to work with configuration
files and other JSON data.

#### console.py

The `console.py` file contains a syntax highlighter for the console output within the Ground Station. This highlighter
is designed to improve the readability of console messages, making it easier to identify important information,
warnings, and errors. It uses the base highlighter class to implement specific highlighting rules for console
output, ensuring that messages are displayed in a clear and organized manner.

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

#### popup_edit.py

This widget is used to create 'windows' that make it easier to modify text in the Ground Station. It takes highligther
(such as one of the syntax highlighters defined in the `syntax_highlighters` directory), some initial text, a tab width,
and font size as arguments and uses a QSignal to return the modified text when the user clicks the "Save" button or
closes the window. This widget is used in the Ground Station to edit buoy data, some data types in the autopilot
parameter editor, and the telemetry data 'limits' that are used to determine when a warning or error should be displayed.

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

This directory contains the code that is used to make displaying the waypoints and buoys on a interactive map possible.
It contains a Go server that is used to manage the transfer of waypoints and buoys between the Python code and the
JavaScript code running in the HTML file in this directory. The Go server exposes a `get` and `set` endpoint that modifies
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
The JavaScript code in this directory uses the [Leaflet](https://leafletjs.com) library
to display the waypoints and buoys on a map.

#### camera_widget

This widget is used to display the camera feed from the boat. It uses a QThread from the `thread_classes.py` file to
fetch the camera feed and then runs some JavaScript code to display the feed in a HTML file. We are using an HTML file
to display the camera feed because of its abibility to natively show base64 encoded images, saving us the trouble of
having to do the decoding ourselves. The widget has buttons that allow you to start and stop the camera feed in order to
save bandwidth and processing power when the camera feed is not needed.

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
