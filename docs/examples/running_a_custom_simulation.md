# <p style="text-align: center;"> Running A Custom Simulation </p>


!!!NOTE "NOTE: Do Not Clone the Code into Your Docker Development Environment"
    Make sure you clone this repository outside of the Docker development environment, because Docker gets a little fussy with building Docker images inside of a Docker Container, and I would rather not have to deal with that. If you are on Windows, this means that you should do the rest of the setup steps in WSL.

**See [here](./running_simulation.md) for information on how to run the default simulation.**

You should only care about this installation process if you care about modifying and doing direct development on the gazebo simulation. Following these steps will allow you to modify and test a new simulation environment with modified parameters or code.  

Before we can build a custom simulation, first we need to clone the autoboat_simulation repository.

Open up a terminal in the folder you would like to place the code to build a new simulation in. Next type the following commands:

------

``` sh
git clone https://github.com/autoboat-vt/autoboat_simulation 
cd autoboat_simulation
```

------


Now that you have all of the code on your computer, there is only 1 dependency for working with the simulation and that is docker-buildx. You can install it like this on Windows WSL and Ubuntu:

-----

``` sh
sudo apt install docker-buildx
```

!!!NOTE "mac OS Users"

    If you are on mac OS, you will need to install docker-buildx using the following command:

    ``` sh
    brew install docker-buildx
    ```

    Make sure to follow the instructions that brew gives you after running this command
    to make sure that docker-buildx is properly installed on your system.
-----  


Now, all you have to do to build the simulation now is type in the following command:

-----

``` sh
sudo bash build_sim.sh
```

-----

And thats it! Now automatically, the simulation node will instead use the new, custom simulation instead of the default. The simulation itself is quite poorly documented so if you have any questions about it and how to do certain things, please ask Chris.

If you would like to go back to using the default simulation then all you have to do is delete the simulation docker image and repull the default simulation docker container, the simulation node will pull the default simulation image and build it.
