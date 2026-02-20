## Introduction

This document provides an overview of the Telemetry Server API routes, detailing the available endpoints, their functionalities, and how they facilitate communication between the telemetry node and the groundstation. The Telemetry Server API is a critical component of the overall architecture, enabling efficient data exchange and management of boat operations.

**Diagram showing how each component interacts with each other**
![Diagram of Groundstation Telemetry](../images/diagram_of_groundstation_telemetry.png)

## API Routes Overview

The Telemetry Server API is implemented using Python's [Flask](https://flask.palletsprojects.com/en/stable) framework and is hosted on [AWS Lightsail](https://aws.amazon.com/lightsail).

Production URL: `https://vt-autoboat-telemetry.uk`  
Testing URL: `https://vt-autoboat-telemetry.uk:8443`

## Routes

### Autopilot Routes

| Method   | Endpoint                                                                      | Description                                                               |
| -------- | ----------------------------------------------------------------------------- | ------------------------------------------------------------------------- |
| `GET`    | `/autopilot_parameters/test`                                                  | Test route for autopilot parameters.                                      |
| `GET`    | `/autopilot_parameters/get/<int:instance_id>`                                 | Get the current autopilot parameters for a specific instance.             |
| `GET`    | `/autopilot_parameters/get_new/<int:instance_id>`                             | Get the latest autopilot parameters if they haven't been retrieved yet.   |
| `GET`    | `/autopilot_parameters/get_default/<int:instance_id>`                         | Get the default autopilot parameters.                                     |
| `GET`    | `/autopilot_parameters/get_hash/<int:instance_id>`                            | Get the hash of the current autopilot parameters for a specific instance. |
| `GET`    | `/autopilot_parameters/get_config/<config_hash>`                              | Get the autopilot configuration for a specific configuration hash.        |
| `GET`    | `/autopilot_parameters/get_hash_description/<config_hash>`                    | Get the description for a specific configuration hash.                    |
| `GET`    | `/autopilot_parameters/get_all_hashes`                                        | Get all stored autopilot configuration hashes.                            |
| `GET`    | `/autopilot_parameters/get_hash_exists/<config_hash>`                         | Check if a specific configuration hash exists.                            |
| `POST`   | `/autopilot_parameters/set/<int:instance_id>`                                 | Set the autopilot parameters using the request data.                      |
| `POST`   | `/autopilot_parameters/set_default/<int:instance_id>`                         | Set the default autopilot parameters using the request data.              |
| `POST`   | `/autopilot_parameters/set_hash_description/<config_hash>/<description>`      | Set the description for a specific configuration hash.                    |
| `POST`   | `/autopilot_parameters/set_default_from_hash/<int:instance_id>/<config_hash>` | Set the default autopilot parameters using a stored configuration hash.   |
| `POST`   | `/autopilot_parameters/create_config`                                         | Create a new autopilot configuration from the request data.               |
| `DELETE` | `/autopilot_parameters/delete_config/<config_hash>`                           | Delete a stored autopilot configuration hash.                             |

### Boat Status Routes

| Method | Endpoint                                     | Description                                                                          |
| ------ | -------------------------------------------- | ------------------------------------------------------------------------------------ |
| `GET`  | `/boat_status/test`                          | Test route for boat status.                                                          |
| `GET`  | `/boat_status/get/<int:instance_id>`         | Get the current boat status for a specific instance.                                 |
| `GET`  | `/boat_status/get_new/<int:instance_id>`     | Get the latest boat status if it hasn't been retrieved yet.                          |
| `POST` | `/boat_status/set/<int:instance_id>`         | Set the boat status using the request data.                                          |
| `POST` | `/boat_status/set_fast/<int:instance_id>`    | Set the boat status using a list of values corresponding to the boat status mapping. |
| `POST` | `/boat_status/set_mapping/<int:instance_id>` | Set the boat status mapping for an instance.                                         |

### Waypoint Routes

| Method | Endpoint                               | Description                                                  |
| ------ | -------------------------------------- | ------------------------------------------------------------ |
| `GET`  | `/waypoints/test`                      | Test route for waypoints.                                    |
| `GET`  | `/waypoints/get/<int:instance_id>`     | Get the current waypoints for a specific instance.           |
| `GET`  | `/waypoints/get_new/<int:instance_id>` | Get the latest waypoints if they haven't been retrieved yet. |
| `POST` | `/waypoints/set/<int:instance_id>`     | Set the waypoints using the request data.                    |

### Instance Manager Routes

| Method   | Endpoint                                                       | Description                                                   |
| -------- | -------------------------------------------------------------- | ------------------------------------------------------------- |
| `GET`    | `/instance_manager/test`                                       | Test route for instance management.                           |
| `GET`    | `/instance_manager/create`                                     | Create a new telemetry instance.                              |
| `DELETE` | `/instance_manager/delete/<int:instance_id>`                   | Delete a telemetry instance by its ID.                        |
| `DELETE` | `/instance_manager/delete_all`                                 | Delete all telemetry instances.                               |
| `DELETE` | `/instance_manager/clean_instances`                            | Remove all telemetry instances not marked for keeping.        |
| `POST`   | `/instance_manager/set_user/<int:instance_id>/<user_name>`     | Set the user for a telemetry instance.                        |
| `GET`    | `/instance_manager/get_user/<int:instance_id>`                 | Get the user of a telemetry instance.                         |
| `POST`   | `/instance_manager/set_name/<int:instance_id>/<instance_name>` | Set the name of a telemetry instance.                         |
| `GET`    | `/instance_manager/get_name/<int:instance_id>`                 | Get the name of a telemetry instance.                         |
| `GET`    | `/instance_manager/get_id/<instance_name>`                     | Get the ID of a telemetry instance by its name.               |
| `GET`    | `/instance_manager/get_instance_info/<int:instance_id>`        | Get detailed information about a specific telemetry instance. |
| `GET`    | `/instance_manager/get_all_instance_info`                      | Get detailed information about all telemetry instances.       |
| `GET`    | `/instance_manager/get_ids`                                    | Return all telemetry instance IDs.                            |
