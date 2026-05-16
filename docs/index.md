---
title: AutoBoat Documentation
---

# <p style="text-align: center;"> Welcome to the Virginia Tech AutoBoat Documentation!</p>
This documentation is intended to be a comprehensive guide to everything related to the [Virginia Tech AutoBoat software stack](https://github.com/autoboat-vt). Here, you will find guides on how to set up your development environment, how to install all of the necessary dependencies, how to use actually the software, and explanations of how the software works under the hood.

<br>
## *<p style="text-align: center;"> How Do I Get Started? </p>*
The best way to get started is to follow the [Getting Started Guide](getting_started/installing_docker.md). This guide will walk you through setting up your development environment, installing all of the necessary dependencies, and running your first mission with the AutoBoat software stack. It is recommended that you follow this guide in order, as it will ensure that you have everything set up correctly before moving on to more advanced topics.

<br>
## *<p style="text-align: center;"> What Frameworks and Tools Should I Learn? </p>*

!!!NOTE
	**TLDR**: You should absolutely be familiar with ROS2 Humble, Git, and how to use a unix shell before you start working on this codebase. You may also want to learn Docker since it is extremely widely used and may be useful to know, but this is not necessary to work on the codebase.

**Linux/Terminal**: Since this codebase is primarily developed and run on Linux based systems (Ubuntu based specifically), it is important to have a basic understanding of how to use a unix shell. This includes understanding basic commands such as `ls`, `cd`, `cp`, `mv`, `rm`, `mkdir`, `touch`, `nano`/`vim`/`code` (for editing files), and how to run scripts. The more familiar you are with the inner workings of a unix based system, the easier it will be to navigate and understand the codebase. Here are some resources to help you get started:

- [Linux Command Line Basics](https://ubuntu.com/tutorials/command-line-for-beginners#1-overview)
- [Bash Scripting Tutorial](https://linuxconfig.org/bash-scripting-tutorial-for-beginners)

Some people may prefer using Zsh as their shell instead of Bash, which is perfectly fine! Just make sure you understand the basics of whichever shell you choose to use.

<br>

**Git**: This should be fairly self explanatory, but Git and Github are vital if you want to work on any codebase. It helps us all work on the same codebase at the same time and merge together all of our contributions to the code.

Here are the things you should make sure you know how to do before you start working on anything:

- Understand the when and how you would use `git clone`, `git add`, `git commit`, `git push`, `git pull`, and `git fetch`.
- Understand what merging two branches means and how to resolve merge conflicts (preferably in vscode).
- Understand how to reset to a previous commit by using the commands `git reset` and `git reset --hard`.
- Understand how to create new branches and switch between branches.

<br>

**Python**: A large portion of the codebase is written in Python, so it is important to have a basic understanding of the language. This includes understanding basic syntax, data structures (lists, dictionaries, sets, tuples), control flow (if statements, for loops, while loops), functions, classes, and modules. Here are some resources to help you get started:

- [Python Official Tutorial](https://docs.python.org/3/tutorial/index.html)
- [Automate the Boring Stuff with Python](https://automatetheboringstuff.com)

The language is fairly easy to pick up, so even if you are new to programming, you should be able to get up to speed relatively quickly.

<br>

**ROS2**: Our techstack utilizes ROS2 (The Robotics Operating System) at its core. Unlike its name implies, it is not an actual operating system, but rather a middleware wrapper that makes concurrency and communication between sensor, actuators, autopilots, and telemetry super easy! This is the industry standard for projects just like this one so if you ever want to do anything in robotics, then this is the framework to learn! The specific version we are using is ROS2 Humble Hawksbill or ROS2 Humble for short, and the documentation for it can be found right here: [ROS2 Humble Documentation](https://docs.ros.org/en/humble/index.html). Specifically, I would recommend heading to the *Tutorials* and *Concepts* sections as those are the most useful for beginners. In addition, there is a really good video series outlining how to get started and do stuff with ROS in addition to the concepts, which can be found here: [ROS2 Tutorial Series EP1](https://www.youtube.com/watch?v=0aPbWsyENA8).

Here are the things you should make sure you know how to do before you start working on anything:

- Understand what [symlink installing](https://docs.ros.org/en/foxy/Tutorials/Beginner-Client-Libraries/Colcon-Tutorial.html) a ROS2 package is since this is what we use instead of the traditional ROS2 build system. Another good resource can be found here: [symlink install explanation](https://robotics.stackexchange.com/questions/98303/what-is-the-use-of-symlink-install-in-ros2-colcon-build)
- Understand how to create ROS2 Humble packages, nodes, and entrypoints
- Understand what topics and nodes are and how nodes are able to communicate over topics
- Understand how to publish and subscribe to topics in code and through the command line
- Understand what ROS2 timers are and how to create them
- Understand basic ROS2 commands such as `ros2 node list`, `ros2 node info`, `ros2 topic list`, `ros2 topic info`, `ros2 topic echo` etc etc
- Understand how to run ROS2 nodes, what launch files are, and how to use them

<br>

**Docker**: While this isn't much of a framework, it is still an important tool and understanding how it works and the concepts behind it, will make troubleshooting if you ever run into problems a bit easier. Docker is seen pretty much everywhere in software nowadays because its a super streamlined and fast way to create custom virtual machines. It really doesn't matter which part of the software industry you would like to work in in the future, I guarantee you that you will run into docker into some point. So it's better to learn it sooner rather than later! Heres some links to documentation and videos:  
- [Docker Overview](https://docs.docker.com/guides/docker-overview/)  
- [Docker Video Explanation 1](https://www.youtube.com/watch?v=0Rq1aw8ppMk&t=216s)  
- [Docker Video Explanation 2](https://www.youtube.com/watch?v=WoZobj2Ruj0&t=313s)   

It turns out that Docker can be used for more than just deployment though. Relatively recently, Docker introduced full support for something called Docker Development Environments (Or Docker Development Containers), which allows us to do all of our development through a Docker container right inside VSCode! Thats great because getting ROS2 and our entire project working on everyone's computers and operating systems was a nightmare to orchestrate and setup, now everyone can just install Docker and our custom development container and start developing instantly! Additionally, there are plenty of other IDEs that support integration with development containers in case you use something other than VSCode; however, VSCode is what we will focus on in this document's setup instructions.


Here are some nice things to know about Docker before you start developing. These are nice to know but not necessary:

- Understand what containers, images, and devcontainers are
- Understand how to build an image, run an image (create a container), and how to push images to docker hub
- Understand simple commands in a Dockerfile and how to make a Dockerfile


<br>

<br>


For a full dependency breakdown for all of the tecchnologies we use and you should be familiar with before working on a specific subsystem in the codebase, please see below. This does not include pip packages, and if you would like to see the pip packages we require on, please see .devcontainer/required_pip_packages.txt since that will always be up to date by definition.


**All**:

- linux

- bash

- git

- docker (but really only if something goes wrong or if you want to edit the devcontainer)



**Formatters/ Linters**:

- ruff

- biome

- taplo



**CI/CD**:

- python

- c++

- docker

- devcontainer

- chroot

- github actions

- systemctl

- udev rules



**Groundstation**:

- python

- bun/ typescript/ javascript

- pyqt/ pyside

- leaflet

- vite



**Simulation**:

- python

- gazebo



**Autopilot**:

- python

- ros2



**Jetson Driver Development**:

- python

- ros2

- udev rules



**C++ Autopilot/ Drivers**:

- c++

- ros2

- cmake

- nlohmann_json

- cpr

- ros-humble-serial-driver

- udev_lib

- libboost



**Computer Vision**:

- python

- deepstream

- yolo models

- opencv

- librealsense2/ realsense sdk



**Firmware**:

- c++

- microros

- freertos

- raspberry pi pico sdk

- cmake
