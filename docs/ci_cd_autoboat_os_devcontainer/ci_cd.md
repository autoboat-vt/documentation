# <p style="text-align: center;"> Continuous Integration/Continous Deployment (CI/CD) </p>

The purpose of the CI/CD pipeline is to automatically perform certain actions when we push changes to the main branch of the repository. Some examples of these actions include:

- Rebuilding binaries for both Intel and Arm CPUs
- Rebuilding the Docker image that the devcontainer uses and pushing that image to Docker hub
- Creating a new Github release which allows people to install Autoboat binaries via the `apt` package manager

All of the files related to the CI/CD pipeline can be found in the `.github` folder.  
If you want to to learn more about CI/CD with Github, please see the below links:
 
- <https://docs.github.com/en/actions>
- <https://docs.docker.com/build/ci/github-actions>

## <p style="text-align: center;"> Summary of What the CI/CD Pipeline Is Trying To Do</p>
### CI/CD Pipeline Summary
| Feature | Pull Request (PR) | Push to `main` | Version Tag (`v*`) |
| :--- | :---: | :---: | :---: |
| **Verify Build** (amd64 / arm64) | ✅ | ✅ | ✅ |
| **Build & Download `.deb` Packages** | ✅ | ✅ | ✅ |
| **Push Images** (Docker Hub / GHCR) | ❌ | ✅ | ✅ |
| **Update Rolling Release** (`latest`) | ❌ | ✅ | ❌ |
| **Create Official Release** | ❌ | ❌ | ✅ |
| **Multi-Arch Manifests** | ❌ | ✅ | ✅ |

## <p style="text-align: center;"> File Structure of the `.github` Folder</p>
### <p style="text-align: center;"> workflows Folder</p>

The files in this folder are used to define the different workflows that should run when certain events happen. Currently it contains two files:

- `build-and-release.yml`: This is the main workflow file that defines the CI/CD pipeline. It contains the logic for:
    - Building each devcontainer variant and pushing those images to Docker hub
    - Building the Debian packages for both Intel and Arm CPUs and pushing those packages to our `apt` repository
    - Creating a new Github release when we push a new version tag (e.g. `v1.0.0`) to the repository

- `docker-bake.hcl`: This file is used to define the different Docker build targets that we want to build when we push changes to the main branch. This file is used by the `build-and-release.yml` workflow file to build the different Docker images that the devcontainer uses and push those images to Docker hub.

- `build_ros_packages.sh`: This file is just a helper script that the `build-and-release.yml` workflow file uses so that we can keep the workflow file as clean as possible. The workflow file is already long enough, and it doesn't need to be longer by inlining bash scripts.


To learn more about Github workflows, please see the following links:

- <https://docs.github.com/en/actions>
- <https://docs.docker.com/build/ci/github-actions>



### <p style="text-align: center;"> workflows/debian_package_files Folder</p>

This folder contains all of the files required to construct the Debian packages. This includes:

- Post installation commands (postinst files)
- Commands to run when removing the Debian packages (prerm and postrm files)
- Package requirements and descriptions (template files)

The postinst and prerm/ postrm are subdivided by the individual debian package since they each have different post installation and removal commands.


Some tutorials for building Debian packages:

- <https://linuxopsys.com/build-debian-packages>
- <https://blog.heckel.io/2015/10/18/how-to-create-debian-package-and-debian-repository>


<br>


## <p style="text-align: center;"> What Are the Different Custom Debian Packages that We Build?</p>

- **autoboatvt**: This is the base debian package that only contains the autopilot and jetson driver code binaries.

- **autoboatvt-microros-agent**: This package contains the microros_agent binaries which allow ROS nodes running on the actual computer (either your computer or the Jetson/ other flight computer) to communicate with the "firmware" running on the raspberry pi pico via serial. To learn more about microros see: https://www.yahboom.net/public/upload/upload-html/1706694373/Install%20and%20start%20microros%20agent.html (scroll all the way down for the example on serial communication).

- **autoboatvt-firmware-dependencies**: This package contains everything needed to start developing on firmware code all packaged into a single debian package! This installs pico-sdk (which is the raspberry pi pico's library), picotool (which allows us to flash programs and reboot the raspberry pi pico through the terminal), and micro_ros_raspberrypi_pico_sdk (which allows us to integrate microros with the raspberry pi pico sdk).

- **autoboatvt-simulation**: This installs gazebo and all of our custom ROS2 plugins required to run our simulation.


<br>


## <p style="text-align: center;"> How Does Installing The Custom Debian Files Work?</p>

The main installation mechanism for the custom debian packages is simply by placing the binaries inside of the folder called /opt/autoboat. The /opt folder in linux is generally reserved for installing additional software onto your operating system which is exactly what we are trying to do! For reference whenever you install ROS2 to your computer, it also installs to this folder. In order for programs on your computer to actually know where the debian packages they require are installed to, they generally require you to run a "setup" bash script or set an environment variable pointing to the installation location in /opt/autoboat. Oftentimes this is done through modifying the ~/.bashrc file, which is a bash script that is run everytime you open a new terminal. This will automatically run the "setup" bash scripts and set any environment variables for the current terminal session so any program on your computer can seemlessly see the debian packages you just installed.

For example, if we wanted to install a ROS2 package as a debian package, we would simply load the debian package with the "install" folder generated by the colcon build command in the ROS2 workspace and then instruct the debian package to copy the install folder to /opt/autoboat. So, when we "sudo apt install" the custom debian package, it will copy the loaded files to /opt/autoboat/install. After this, we simply instruct the debian package to modify the user's ~/.bashrc file (usually through a postinst script) by adding the command "source /opt/autoboat/install/setup.bash". This is a setup command that allows the user's ROS2 installation to see all of the nodes inside of the "install" folder.

A simple library like the raspberry pi pico SDK on the other simply requires you to clone the repository and then point to where the repository is located on your computer via an environment variable so cmake can use it to compile your project. While you would follow all of the same steps to load the folder with the preinstalled raspberry pi pico sdk repository, the main difference is simply loading the ~/.bashrc file with a command to set the PICO_SDK path to /opt/autoboat/firmware_dependencies/pico-sdk.


With all of the different things we need to add to the ~/.bashrc files for different debian packages, it can get a little bit annoying when it comes time to delete one of the packages (ie when someone calls sudo apt remove on one of them). To solve this, we only append the following line to the ~/.bashrc file:

```sh
for f in /etc/profile.d/autoboatvt-*.sh; do [ -f "$f" ] && source "$f"; done
```

This file checks for all bash files that start with the following path: /etc/profile.d/autoboatvt and executes each bash file. This allows us to build debian package specific setup files, such as a separate setup script for all of the microros_agent dependencies or all of the firmware_dependencies, and when it comes time to delete a specific debian package you simply just delete the bash file associated with the debian package and the ~/.bashrc will automatically stop executing it on startup. For example, the file /etc/profile.d/autoboatvt-firmware-dependencies.sh is associated with the autoboatvt-firmware-dependencies debian package and whenever autoboatvt-firmware-dependencies is installed, the bash file is automatically generated. Whenever the debian package is deleted, then the associated bash file is automatically deleted and is no longer run.
