---
title: AutoBoat Documentation 
---

# <p style="text-align: center;"> VESC (Vedder Electric Speed Controller) </p>


## **What is a VESC?**

A VESC is one type of [electric speed controller](https://en.wikipedia.org/wiki/Electronic_speed_control), which regulate the speed and power that goes into our big propeller motor. VESCs are really only used for our motorboats, since motor controllers like these are usually overkill for the smaller motors in our sailboat. The big advantage of using a VESC controller instead of any random ESC controller is that the VESC firmware (which is the main thing that characterizes a VESC controller) provides a standardized way to send and receive complex control messages and telemetry data. It also has a lot of functionality built into the firware to allow for you to change voltage limits, shut-off voltages, PID constant values, encoder configurations, etc etc all from your computer or your phone via bluetooth. You can even change these things on the fly through custom software you can write. This is great! this means that we can write software to communicate with one ESC, and we guaranteed that it will work on another ESC that is running the VESC firmware. We are also assured that we can get a plethora of telemetry data back from a VESC on how much voltage our battery has, how much voltage/ current/ power is going to our motor, how much RPM our motor has, the temperature of our motor, etc.

If it is not obvious yet, VESC is great and we would like to mainly buy VESC compatible ESCs whenever we would like to spec an ESC for a certain motor and desired system power. If you would like to read more about the wonders of VESC, you can do so here: [VESC Tutorial](https://www.youtube.com/watch?v=JVKFrdCgghQ) and [Other VESC Tutorial](https://www.youtube.com/watch?v=QM5_vCy_uWk). If you would like to download VESC Tool which is the software that you can download on your computer or phone to configure and control the VESC without the VESC Node, you can do so here: [VESC Tool Download](https://vesc-project.com/vesc_tool).


## **How Does the VESC Node Work**

The VESC node works by using an open source library called pyvesc, which is a python implementation that allows us to send and receive messages from the VESC over the USB serial port. The original pyvesc github can be found here: [pyvesc github](https://github.com/LiamBindle/PyVESC), and the documentation can be found here: [pyvesc documentation](https://pyvesc.readthedocs.io/en/latest/)

For this project, we may want to modify the pyvesc library slightly to better suit our needs, so we have a modified version of the pyvesc library set up inside of the vesc package folder. Check out the documentation on custom libraries to learn more about how we use custom libraries in our ROS workspace.



The VESC Node simply takes in ROS2 messages for the VESC control struct, and sends that information to the VESC controller whenever it receives the data from the autopilot. Meanwhile, the node also reads telemetry data from the VESC at a set interval and publishes it back out so that any node can listen in on the RPM, power, etc of the motor.

I will go into a little bit of depth in how the VESC control struct works since it isn't completely obvious how it works. The VESC control struct has the following entries:

<br>

string control_type_for_vesc

float32 control_value

<br>


The "control_type_for_vesc" can take on the following values: **"rpm"**, **"duty_cycle"**, or **"current"**. Each of these are different ways to control the propeller motor by telling the VESC what you want the desired RPM to be, telling the VESC what you want the duty cycle (basically voltage to the motor) to be, or telling the VESC what you want the current to the motor to be. The VESC's job is to use the control type and your control values, and get as close to that as possible; for the purposes of this project, how it does that is basically magic. For example, if control_type_for_vesc is "rpm", control_value tells the motor what the desired RPM is.
