# <p style="text-align: center;"> Motorboat Simulation </p>

## **Summary**

This simulation node wraps around a Gazebo Harmonic (a general purpose physics simulator) simulation of a motorboat traveling in a free plane of water. The simulation is currently contained in the `andrews-cool-simulation` branch in github, but at the time of reading this, it may have been pushed to main.

The ros node acts as a translator from ros messages to gazebo messages, which the simulation publishes/subscribes to to control the motorboat. The node sends messages such as rudder angle and thrust, and it receives the boat's position, heading, velocity, true rudder angle, true thrust, etc.

## **How to Run It**

At the moment, the simulation is still on a separate branch in the github. Switch to the `andrews-cool-simulation` branch and rebuild the container. To run the simulation alone, run: 

```sh
cd /home/ws/src/motorboat_sim_testing
gz sim buoyant_cylinder.sdf
```

To run the ros node, run:

```sh
cd /home/ws/src/launch
ros2 launch simtest.launch.py
```

## **How it Works**

The gazebo simulation for the motorboat is contained in `buoyant_cylinder.sdf`. These sdf files are essentially JSON written differently, for which the full sdf spec can be found here: [sdformat specification](https://sdformat.org/spec/). The file is a combination of basic data, the shape, mass, initial position, and inertia of all the elements plus the joints that connect them, and plugins, some of which are built-in to gazebo and some of which we wrote ourselves.

The file starts with various scenery/light/camera/physics parameters, most of which are fairly standard. Some notable built-in plugins here are `gz-sim-user-commands-system`, which allows us to send gazebo commands (which are sent from the ros node) to control the simulation. The `gz-sim-navsat-system` gives the positional data that the autopilot expects. Below, the model `my_ship` is the boat, which is where the real meat of the program is. Here is where every piece of the boat is defined, with all the plugins that allow our boat to move!

First, the boat's parts are mostly life-scale, with the measurements being taken from the most recent boats on hand and the masses being estimated. Notably, the boat's hull is split into four pieces because of the buoyancy plugin, which is described more below. The inertia tensors are calculated manually, either from a formula or solidworks. A description of the inertia tensors can be found [here](https://www.mathworks.com/help/releases/R2021b/physmod/sm/ug/specify-custom-inertia.html#mw_b043ec69-835b-4ca9-8769-af2e6f1b190c) and in the sdformat specification.

Here are the notable built-in plugins:

* `gz-sim-joint-position-controller-system` - This is what controls the rudder
* `gz-sim-odometry-publisher-system` - Publishes position and velocity messages
* `gz-sim-thruster-system` - This is what controls the thruster
* `gz-sim-hydrodynamics-system` - Description below in the **How to Develop** section

Here are our custom plugins:

* `libRudderDynamics.so` - This is our custom LiftDrag plugin. The built-in one is terrible. At some point, this should probably be renamed. In this case, clmax and cdmax refer to the equations of coefficient of lift and coefficient of drag. These coefficients, when plotted vs. angle of attack, form vaguely sinusoidal curves, so find the coefficient of lift vs alpha (aoa) curve for whatever shape/material you're using, then put the max in. For more details, look up more about lift/drag forces.
* `libBuoyancy.so` - So... this one is sad. This plugin is copied from the gazebo built-in where one issue is fixed. In the built-in plugin, there is a note `TODO(arjo):` that mentions that when graded buoyancy is calculated, it assumes the object is upright, so when our boat is leaning to the side slightly when it turns, the buoyancy plugin acts weirdly and the program crashes a lot. We had to download their plugin and fix that one issue, but if someone can make a pull request to the main gazebo gz-sim8 github with the fixed code, that would be great.

## **How to Develop**
The first thing I'd like to mention is to avoid using AI. I know it's easier, but LLMs are *very* bad with gazebosim and the ros gazebo bridge since the documentation is terrible and there are so few examples online that use Gazebo Harmonic.

To develop on the ros node (contained in `simtest.launch.py`), you need to understand ros and python, for which there are tutorials elsewhere in this documentation. To develop on the gazebo sim, you need to understand gazebo harmonic and the format of sdf files. The current simulations are good examples, but the documentation can be found here: [Gazebo Harmonic Tutorials](https://gazebosim.org/docs/harmonic/tutorials/). The list of built in plugins can be found here: [Gazebo 8.10.0 Systems Documentation](https://gazebosim.org/api/sim/8/namespacegz_1_1sim_1_1systems.html). Some of the plugins there have terrible documentation, so you may need to look elsewhere for examples. Notably, the hydrodynamics plugin has a great explanation here: [Gazebo Hydrodynamics Plugin](https://gazebosim.org/api/sim/8/theory_hydrodynamics.html). If you want to know what the inputs to the hydrodynamics plugin mean, I'd recommend checking out *Fossen, Thor I. Guidance and Control of Ocean Vehicles. United Kingdom: Wiley, 1994* as mentioned in the documentation. You can find it in Newman Library or the Ocean Engineering lounge (allegedly).

All gazebo plugins are written in C++, so you will need to be able to at least read C++ to work with them. Additionally, at some point when using the built in plugins, you will need to check the source code. It can be found [here](https://github.com/gazebosim/gz-sim/tree/gz-sim8/src/systems).

As to our custom plugins, they are written in C++ and take the following form:

```sh
plugin_name
├── CMakeLists.txt
├── build
├── include
│   └── PluginName.hh
├── package.xml
└── src
    └── PluginName.cc
```

To rebuild the plugin, you can simply enter the build folder and run `make`. If you altered the CMakeLists.txt, run `cmake ..` in the build folder first.

To create a custom plugin, the documenation can be found here: [Gazebo plugin documentation](https://gazebosim.org/api/sim/8/createsystemplugins.html). Most plugins you will need to make will run at PreUpdate time.

Let's examine RudderDynamics to get an idea of what is necessary in a plugin:

```c++
#include "../include/RudderDynamics.hh"
#include <cmath>

namespace rudder_dynamics
{

/////////////////////////////////////////////////
RudderDynamics::RudderDynamics()
: rho_(1000.1),
  cp_(0, 0, 0),
  forward_(1, 0, 0),
  upward_(0, 0, 1),
  area_(1.0),
  clmax_(1.5),
  cdmax_(1.0)
{
  RCLCPP_INFO(rclcpp::get_logger("RudderDynamics"), "RudderDynamics plugin constructed");
}

/////////////////////////////////////////////////
RudderDynamics::~RudderDynamics() = default;

/////////////////////////////////////////////////
void RudderDynamics::Configure(const gz::sim::Entity &_entity,
                             const std::shared_ptr<const sdf::Element> &_sdf,
                             gz::sim::EntityComponentManager &_ecm,
                             gz::sim::EventManager &)
{
  if (_info.paused)
    return;
```

Every plugin is not required to have its own namespace, it's just the convention we use. The `RCLCPP_INFO(rclcpp::get_logger("RudderDynamics"), ` is how to send logs to the console. The `if (_info.paused)` is very important, as your plugin will keep running when the simulation is paused if it's not there, which will probably break it!

```c++
// Get world linear velocity
auto optVel = links_[0].WorldLinearVelocity(_ecm);
if (!optVel)
return;
gz::math::Vector3d vel = *optVel;

// Get world pose
auto optPose = links_[0].WorldPose(_ecm);
if (!optPose)
return;
gz::math::Pose3d pose = *optPose;
```

Gazebo has its own math plugin, which can be found at the [Gazebo math github](https://github.com/gazebosim/gz-math). The documentation can be found here: [Gazebo math documentation](https://gazebosim.org/api/math/9/).

```c++
/////////////////////////////////////////////////
GZ_ADD_PLUGIN(rudder_dynamics::RudderDynamics,
              gz::sim::System,
              rudder_dynamics::RudderDynamics::ISystemConfigure,
              rudder_dynamics::RudderDynamics::ISystemPreUpdate)

GZ_ADD_PLUGIN_ALIAS(rudder_dynamics::RudderDynamics, "rudder_dynamics::RudderDynamics")
```

The specific methods you put into `GZ_ADD_PLUGIN` depend on which methods you implemented. The .hh files are mostly self explanatory, if you understand C++, you should be alright with those. As for the CMakeLists.txt and package.xml, you'll need some required packages for gazebo, and the package.xml has to be there to run `cmake ..`.