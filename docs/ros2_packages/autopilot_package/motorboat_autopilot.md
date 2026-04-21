# <p style="text-align: center;"> Sailboat Autopilot </p>


## **What is the should_propeller_motor_be_powered topic?**


This topic basically turns off a [contactor](https://en.wikipedia.org/wiki/Contactor) that denies power to the propeller motor. This is implemented for safety, since we would like to know whether the high voltage system and the propeller motor is live whenever we want to swap out propellers or move the boat. 

#### **Why does the Autopilot Node Control Whether the Contactor Should be Closed. Can't the Raspberry Pi Pico Directly Receive RC Data and then Control the Contactor?**

We would like the contactor to be controlled by RC command primarily, but we would also like to support the idea that in the future, we may want the autopilot to complete a route, and then unpower itself so that we can take it out of the water safely without having to manually depower it via RC. Another reason is that the raspberry pi pico code is a little harder to change, and if we wanted to change which toggle the contactor switch/ kill switch would be tied to (or really any of the RC buttons), we could theoretically do that through autopilot parameters and the groundstation. This is ideal, but also not implemented yet. Also, if we must make the decision that the raspberry pi pico must listen to the RC data topic at all, that means that there will be a lot of serial port traffic over the usb port to the raspberry pi pico, since the jetson needs to send the entirety of the RC data struct many many times per second. This may eat up CPU time on both the Jetson and the Pico and make them both less responsive (sort of). The CPU time is kind of a pedantic reason and really we would want to benchmark and see whether this actually makes any meaningful difference.


**TLDR**: this is kinda just how I chose to do it since all of the other RC functions are described in the autopilot and all of the reasons above are retroactive cope