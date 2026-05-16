---
title: AutoBoat Documentation 
---

# <p style="text-align: center;"> Sailboat Simulation </p>

## **Summary**

The simulation node simulates all of the real world interactions that the boat will undergo without having to put the boat on the water. The simulation essentially takes the place of all of the sensor nodes and the microros nodes and should publish/ subscribe to the same things as those nodes. For more information on how the simulation interacts with everything else, please look at the system diagram for ros nodes for the simulation.


## **How it Works** 


The simulation node is basically a wrapper around the sailboat_gym repository, which can be found here: [Sailboat Gym Github Repository](https://github.com/lucasmrdt/sailboat-gym). This repository basically has a docker container that all of the actual simulations happen in because there is a gazebo simulator for the sailboat inside of the docker container. The sailboat_gym repository then communicates with the docker container and controls the sailboat that exists inside of the docker container. The docker container is based off of the following repository: [USV Sim LSA Github Repository](https://github.com/disaster-robotics-proalertas/usv_sim_lsa), which is the gazebo environment that is run inside of the docker container. We can actually edit the docker container ourselves and have our own custom versions of the simulation, which is what I have set up the following repository for: [Our Sailboat Simulation](https://github.com/autoboat-vt/autoboat_simulation). In this github repository, you can edit the code for the simulation and then rebuild the docker image to be used whenever you use the simulation node. For more information, please look at the *running a custom simulation* documentation. You should also check out the system diagram for the simulation stack as it provides a visual explanation for how all of these pieces of code interact with each other.


The simulation node simply imports the sailboat_gym repository and then ties specific actions to publishers and subscribers. For instance, if you publish a sail and rudder command, then the simulation node will pass that onto the sailboat_gym repository which will correspondingly control the boat in the simulation.
