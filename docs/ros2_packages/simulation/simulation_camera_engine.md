# <p style="text-align: center;"> Simulation Camera Engine </p>

## **Summary**

This package contains all of the math required to transform position, odometry, and object location data into where on the camera sensor the object lies. This package requires the simulation transform node to be running (since it uses the /position topic which the simulation transform node publishes to) as well as one of the gazebo simulations and it outputs raw object detection results that mimick exactly what the object detection node on the real boat would output.

The main thing that you have to understand to edit this node is perspective projection, since pretty much all of the math just boils down to "given an object's location and the boat's location/ orientation, can the boat's camera see this object. This is exactly the question that perspective projection seeks to answer. If you would like to learn more about perspective projection, a lot of the individual math that is used is linked to in the node's code, but you can also look at the following resource: https://medium.com/@sarcas0705/computer-vision-perspective-projection-a051c7f63d9.
