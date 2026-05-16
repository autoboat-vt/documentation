---
title: systemctl
---

# <p style="text-align: center;"> What is Systemctl?</p>

Systemctl is essentially a way to schedule scripts to run when a machine starts up, and this is super useful on the Jetson on the actual boat, because it allows us to start up the autopilot ROS nodes without SSH'ing into the Jetson all of the time. Before we started using systemctl, every single time we power cycled the boat, we would have to SSH into the boat and manually run `ros2 launch ......`, but now with systemctl, this command automatically runs for us everytime the boat starts up.



## <p style="text-align: center;"> Some Useful Stuff to Know How to Do in Systemctl</p>

Theres a whole bunch of things that are very useful to know how to do with systemctl processes. For example, how to create a new .service file, how to use `sudo systemctl enable myservice.service` (which enables the service to start on boot), how to use `sudo systemctl start myservice.service` (which starts the service right now), how to use `sudo systemctl stop myservice.service` (which stops the service from running right now), `sudo systemctl disable myservice.service` (which disables the service to start on boot), and `sudo journalctl -u myservice.service` (which shows you the print logs from a specific service).



## <p style="text-align: center;"> Example of a Systemctl File That We Have Used</p>

```bash
[Unit]
After=network-online.target
Description=ROS2 Motorboat Launch at Startup

[Service]
User=autoboat
Group=autoboat
ExecStart=/bin/bash -c 'source /home/autoboat/.bashrc; source /home/autoboat/autoboat_vt/install/setup.bash; sudo /home/autoboat/autoboat_vt/src/microros/dependencies/picotool/build/picotool reboot -f && sleep 1s && sudo chmod 777 /dev/tty* && ros2 launch /home/autoboat/autoboat_vt/src/launch/motorboat.launch.py;'

RemainAfterExit=no
Restart=on-failure
RestartSec=2s


[Install]
WantedBy=default.target
```

This is an example of a service file that we have used in the past to run our ros2 nodes on startup. Here is a step by step explanation of what is going on:

- After=network-online.target is specifying that the service should only start up once we have connected to a network (this is needed in order to send telemetry data).

- Description is just a plain text description of what the service does.

- User and Group are just the user and group that should own the service and run all of the commands in the service.

- ExecStart is the raw bash command that we should run when this service starts up. In our case we would like to source the bashrc and setup.bash (to make sure ros2 is active and it can see all of our custom nodes), then we would like to reboot the raspberry pi pico the jetson is connected to restart the firmware running on it, then wait 1 second for the raspberry pi pico to finish restarting, then finally we will launch the proper launch file to start all of the ros2 nodes. This is just an example of what this command could do, but realistically, you can run any bash command on startup with this.

- RemainAfterExit=no means that if the process started by this service exits, then the service is considered inactive/ dead.

- Restart=on-failure means that if the process started by this service fails, then we should attempt to restart the service to keep it alive. This makes it so that 1 software crash doesn't mean that we have to restart the entire jetson operating system.

- RestartSec=2s just means that if the process started by this service fails, then we would like to restart the software after 2 seconds.

- WantedBy=default.target just means that we should start the process on startup.


<br>

One thing that you may need to do to get the above systemctl file to work is to give the default user full sudo access, since the service is being run by the default user, but we won't be able to enter to "sudo" password. This can be done easily with the following command:

```bash
echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME && chmod 0440 /etc/sudoers.d/$USERNAME
```

This isn't particularly great for security, but I don't particularly care.


<br>

## <p style="text-align: center;"> How Deploy The Example Systemctl File onto a Jetson</p>


The following commands assume that you have the service file on the Jetson as a file called ~/Downloads/motorboat.service.

```bash
sudo mv ~/Downloads/motorboat.service /etc/systemd/system/motorboat.service
sudo systemctl enable motorboat.service
```

Thats it! Now these commands will run every single time the Jetson finishes booting up.

<br>

To test whether or not these commands work, you can run:

```bash 
sudo systemctl start motorboat.service
```

This command will start up the service manually (without needing to restart the Jetson) so you can test whether the commands you put in ExecStart really work properly. To stop this process, you can run the following command:

```bash
sudo systemctl stop motorboat.service
```

<br>

## <p style="text-align: center;"> Extra Resources to Learn More About Systemctl</p>


Making a new systemctl process: https://askubuntu.com/questions/919054/how-do-i-run-a-single-command-at-startup-using-systemd

Using journalctl to check the print logs of a systemctl process: https://www.digitalocean.com/community/tutorials/how-to-use-journalctl-to-view-and-manipulate-systemd-logs 
