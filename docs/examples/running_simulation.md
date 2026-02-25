# <p style="text-align: center;"> Running the Simulation </p>

## Sailboat Simulation

To run the sailboat simulation, run the following commands in order **after setting up the development container**:


```sh
sudo docker pull vtautoboat/autoboat_simulation:latest
```

This command will pull the simulation docker image, which is where all of the simulation work is actually taking place! **This command only needs to be run once. Once the docker image has been pulled, you shouldn't need to repull**. The command may take a while, but once it is finished, run the following command:

```sh 
ros2 launch /home/ws/src/launch/simulation.launch.py
```

This command will then start the simulation and autopilot. Initially, however they won't do anything because they don't have any waypoint commands, so you will need to launch the ground station to send waypoints. In a separate shell, run these commands:


```sh
cd /home/ws/ground_station
```

``` sh
./run.sh
```

Next, click on "zoom to boat". This should show you where the boat is currently located (likely longitude 0 and latitude 0 since this is the default location)


Now, click somewhere on the map and then click "Send Waypoints". This should cause the boat on screen to start moving and indicates that you have correctly set everything up!  


## Motorboat Simulation

To run the motorboat simulation, run the following command **after setting up the development container**:

```sh
ros2 launch /home/ws/src/launch/motorboat_simulation.launch.py
```

Then, in a separate shell, run the same two commands to launch the groundstation as above.