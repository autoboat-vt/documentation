---
title: Motorboat Autopilot
description: Motorboat autopilot node overview.
---

# <p style="text-align: center;"> Sailboat Autopilot </p>


## **What Is The should_propeller_motor_be_powered Topic?**


This topic basically turns off a [contactor](https://en.wikipedia.org/wiki/Contactor) that denies power to the propeller motor. This is implemented for safety, since we would like to know whether the high voltage system and the propeller motor is live whenever we want to swap out propellers or move the boat. 

#### **Why Does the Autopilot Node Control Whether the Contactor Should be Closed. Can't The Raspberry Pi Pico Directly Receive RC Data and Then Control The Contactor?**

We would like the contactor to be controlled by RC command primarily, but we would also like to support the idea that in the future, we may want the autopilot to complete a route, and then unpower itself so that we can take it out of the water safely without having to manually depower it via RC. Another reason is that the raspberry pi pico code is a little harder to change, and if we wanted to change which toggle the contactor switch/ kill switch would be tied to (or really any of the RC buttons), we could theoretically do that through autopilot parameters and the groundstation. This is ideal, but also not implemented yet. Also, if we must make the decision that the raspberry pi pico must listen to the RC data topic at all, that means that there will be a lot of serial port traffic over the usb port to the raspberry pi pico, since the jetson needs to send the entirety of the RC data struct many many times per second. This may eat up CPU time on both the Jetson and the Pico and make them both less responsive (sort of). The CPU time is kind of a pedantic reason and really we would want to benchmark and see whether this actually makes any meaningful difference.

**TLDR**: this is kinda just how I chose to do it since all of the other RC functions are described in the autopilot and all of the reasons above are retroactive cope



## **How Does The Autopilot Figure Out The Optimal RPM for the Propeller Motor**


We would like the autopilot to slow down on curves because if the boat goes too fast while it is turning, then it may lose balance and tip over/ become unstable. In order to prevent this, sadly we cannot go full throttle at all times and we have to have some code in place to handle slowing down on curves. To do this, we make the desired rpm of the propeller motor based on the desired rudder angle using the following formula, where the min_rpm, max_rpm, and rpm_decay_rate are all autopilot parameters that the user gets to choose from the groundstation.

$$ \text{desired_rpm} = \text{min_rpm} + (\text{max_rpm} - \text{min_rpm}) * e^{-\text{rpm_decay_rate} * \text{rudder_angle}} $$


This formula uses exponential decay between 2 different value, the min rpm and max rpm. Whenever the boat is going straight, the rpm will be very close to max_rpm, and whenever the boat is turned too much, the rpm will go closer to the min_rpm. The decay rate just says how much to slow down as you turn your rudder more and more.


In the future we may also want to make a system where the motorboat autopilot slows down the propeller motor depending on how hot the propeller motor is getting, but curreently we unfortunately don't have a temperature sensor connected to the motor. This will likely change in the near future, and when we get that working, we should probably have some sort of thermal throttling, ie. slowing down the motor when the motor is getting too hot to prevent it from overheating.
