---
title: CI/CD
description: CI/CD pipeline overview.
---

# <p style="text-align: center;"> Continuous Integration/Continous Deployment (CI/CD) </p>

The purpose of the CI/CD pipeline is to automatically perform certain actions when we push changes to the main branch of the repository. Some examples of these actions include:

- Rebuilding binaries for both Intel and Arm CPUs
- Rebuilding the Docker image that the devcontainer uses and pushing that image to Docker hub
- Creating a new Github release which allows people to install Autoboat binaries via the `apt` package manager

All of the files related to the CI/CD pipeline can be found in the `.github` folder.  
If you want to to learn more about CI/CD with Github, please see the below links:
 
- <https://docs.github.com/en/actions>
- <https://docs.docker.com/build/ci/github-actions>

## <p style="text-align: center;">What Does the CI/CD Pipeline Do When We Push Changes to the Main Branch?</p>

| Feature | Pull Request (PR) | Push to `main` | Version Tag (`v*`) |
| :--- | :---: | :---: | :---: |
| **Verify Build** (amd64 / arm64) | ✅ | ✅ | ✅ |
| **Build & Download `.deb` Packages** | ✅ | ✅ | ✅ |
| **Push Images** (Docker Hub / GHCR) | ❌ | ✅ | ✅ |
| **Update Rolling Release** (`latest`) | ❌ | ✅ | ❌ |
| **Create Official Release** | ❌ | ❌ | ✅ |
| **Multi-Arch Manifests** | ❌ | ✅ | ✅ |

## <p style="text-align: center;">File Structure of the `.github` Folder</p>
### <p style="text-align: center;">`workflows` Folder</p>

The files in this folder are used to define the different workflows that should run when certain events happen. Currently it contains the following files:

- `build-and-release.yml`: This file is responsible for:
    - Building each devcontainer variant and pushing those images to Docker Hub
    - Building the Debian packages for both Intel and Arm CPUs and pushing those packages to our `apt` repository
    - Creating a new Github release when we push a new version tag (e.g. `v1.0.0`) to the repository

- `docker-bake.hcl`: This file is responsible for:
    - Defining the different Docker build targets that we want to build when we push changes to the main branch
    - Informing `build-and-release.yml` which Docker images to build and push to Docker Hub when we push changes to the main branch

- `build_ros_packages.sh`: A bash file which:
    - Builds and packs our ROS2 packages into Debian packages
    - Improves the readability of the `build-and-release.yml` file by seperating out the logic for building/packing the ROS2 packages

To learn more about Github workflows, please see the following links:

- <https://docs.github.com/en/actions>
- <https://docs.docker.com/build/ci/github-actions>

#### <p style="text-align: center;">`debian_package_files` Folder</p>

This folder contains all of the files required to construct the Debian packages. This includes:

- Post installation commands (`postinst` files)
- Commands to run when removing the Debian packages (`prerm` and `postrm` files)
- Package requirements and descriptions (template files)

The `postinst`, `prerm`, and `postrm` files are subdivided by the individual Debian package since they each have different post installation and removal commands.

Some tutorials for building Debian packages:

- <https://linuxopsys.com/build-debian-packages>
- <https://blog.heckel.io/2015/10/18/how-to-create-debian-package-and-debian-repository>


## <p style="text-align: center;">What Are the Different Custom Debian Packages that We Build?</p>

!!!NOTE "Additional Information"
    To learn more about the microros agent see: <https://www.yahboom.net/public/upload/upload-html/1706694373/Install%20and%20start%20microros%20agent.html> (scroll all the way down for the example on serial communication).

- `autoboatvt-simulation`: This installs Gazebo and all of the custom ROS2 plugins required to run the simulation.

- `autoboatvt`: This is the base Debian package. It contains:
    - The autopilot code binaries, which are needed to run the autopilot
    - The jetson driver code binaries, which allow us to monitor the metrics provided by `jtop`

- `autoboatvt-microros-agent`: This package contains:
    - The `microros_agent` binaries, which allow ROS nodes to communicate with the firmware running on the Raspberry Pi Pico over serial

- `autoboatvt-firmware-dependencies`: This package contains:
    - Everything needed to develop firmware for the Raspberry Pi Pico, which includes:
        - `pico-sdk`, the official SDK provided by Raspberry Pi for developing firmware for the Raspberry Pi Pico
        - `picotool`, which allows us to flash programs and reboot the Raspberry Pi Pico through the terminal
        - `micro_ros_raspberrypi_pico_sdk`, which allows us to integrate microros with the Raspberry Pi Pico SDK

## <p style="text-align: center;">How Does Installing The Custom Debian Files Work?</p>

The main installation mechanism for the custom Debian packages is simply by placing the binaries inside of `/opt/autoboat`. The `/opt` folder in Linux is generally reserved for installing additional *optional*, cough cough **opt**, software. For reference whenever you install ROS2 on your computer, it also installs to this folder. 

In order for programs on your computer to actually know where the Debian packages they require are installed to, they generally require you to run a "setup" bash script or set an environment variable pointing to the installation location in `/opt/autoboat`. Oftentimes this is done through modifying the `~/.bashrc` file, which is a bash script that is run everytime you open a new terminal. This will automatically run the "setup" bash scripts and set any environment variables for the current terminal session so any program on your computer can seemlessly see the Debian packages you just installed.

For example, if we wanted to install a ROS2 package as a Debian package, we would simply load the Debian package with the "install" folder generated by the `colcon build` command in the ROS2 workspace and then instruct the Debian package to copy the install folder to `/opt/autoboat`. So, when we `sudo apt install` the custom Debian package, it will copy the loaded files to `/opt/autoboat/install`. After this, we simply instruct the Debian package to modify the user's `~/.bashrc` file (usually through a postinst script) by adding the command `source /opt/autoboat/install/setup.bash`. This is a setup command that allows the user's ROS2 installation to see all of the nodes inside of the "install" folder.

A simple library like the Raspberry Pi Pico SDK on the other hand simply requires you to clone the repository and then point to where the repository is located on your computer via an environment variable so CMake can use it to compile your project. While you would follow all of the same steps to load the folder with the preinstalled Raspberry Pi Pico SDK repository, the main difference is simply loading the `~/.bashrc` file with a command to set the `PICO_SDK` variable to `/opt/autoboat/firmware_dependencies/pico-sdk`.

With all of the different things we need to add to the `~/.bashrc` file for different Debian packages, it can get a little bit annoying when it comes time to delete one of the packages (i.e. when someone calls `sudo apt remove` on one of them). To solve this, we only append the following line to the `~/.bashrc` file:

```sh
for f in /etc/profile.d/autoboatvt-*.sh; do [ -f "$f" ] && source "$f"; done
```

This file checks for all bash files that start with the following path: `/etc/profile.d/autoboatvt` and executes each bash file. This allows us to build Debian package specific setup files, such as a separate setup script for all of the `microros_agent` dependencies or all of the `firmware_dependencies`, and when it comes time to delete a specific Debian package you simply just delete the bash file associated with the Debian package and the `~/.bashrc` will automatically stop executing it on startup. For example, the file     `/etc/profile.d/autoboatvt-firmware-dependencies.sh` is associated with the `autoboatvt-firmware-dependencies` Debian package and whenever `autoboatvt-firmware-dependencies` is installed, the bash file is automatically generated. Whenever the Debian package is deleted, then the associated bash file is automatically deleted and is no longer run.
