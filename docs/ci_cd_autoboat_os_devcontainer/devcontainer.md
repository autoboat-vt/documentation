# <p style="text-align: center;"> Devcontainer </p>

This documentation assumes that you are familiar with what docker containers/ images are and how they work at a basic level. Please see the following resources if you would like to learn more:

- [Docker Overview](https://docs.docker.com/guides/docker-overview/)  
- [Docker Video Explanation 1](https://www.youtube.com/watch?v=0Rq1aw8ppMk&t=216s)  
- [Docker Video Explanation 2](https://www.youtube.com/watch?v=WoZobj2Ruj0&t=313s)   



<br>

The devcontainer is a Docker container that we can develop new software inside of using an IDE like VSCode. The devcontainer standard is a standard that standardises how these IDEs open these Docker containers and what functionality they need to support. The devcontainer standard basically defines how the devcontainer.json file is supposed to be structured and what it can include. Everything that interacts with the devcontainer.json can be found in .devcontainer. You can find more information about the devcontainer standard in the following links: https://containers.dev/implementors/spec/, https://containers.dev/overview, and https://containers.dev/implementors/json_reference/.


<br>

## <p style="text-align: center;"> Why Do We Need A Devcontainer?</p>

Devcontainers allow us to simplify the installation process of our software between the unlimited different configurations, operating systems, package managers, architectures, currently installed packages etc. You simply have to install the devcontainer extension for vscode and build the devcontainer and then thats it! No lengthy installation scripts that must work on any computer regardless of operating system and architecture. Docker also allows us to isolate our software from the rest of your computer, so that everything works regardless of whats on your computer! In addition, isolating this software from the rest of your computer allows us to ensure that if a piece of software works on your computer, it will work on everyone's computer and whatever computer that we are deploying the code onto. The last important thing that devcontainers allow us to do is to is to have a standard set of extensions for our IDE, which allows us to automatically configure things like intellisense without the user needing to spend all day configuring their extensions.


<br>


## <p style="text-align: center;"> What Happens to The Files You Changed in the Devcontainer?</p>

Lets say you just changed a file in the /home/ws folder in the devcontainer. What happens to this file and can your progress get deleted if you close the devcontainer or rebuild it?

Thankfully, via a process called bind mounting in docker, any change that you make inside of the devcontainer in the /home/ws folder will automatically update on your native operating system's filesystem (for linux or macos users) or inside of your WSL filesystem for windows users! This means that you can never "lose your progress" if you rebuild or close the devcontainer! The only thing that you should be familiar with is that once you rebuild the devcontainer, it will delete any packages that you may have installed inside of the devcontainer or any files outside of the /home/ws directory, so just keep that in mind and try to never rebuild the devcontainer unless you are ok with deleting all installed packages. For normal use, you should only "reopen" the devcontainer. 

Bind mounting is a fairly standard and simple process that docker containers support, which allows us to mirror any file changes inside of our docker container to your native operating system's filesystem in the case of linux/macos and WSL in the case of windows. Therefore, no matter what happens to the devcontainer, your changes will be automatically saved where you initially cloned the github repository, so there is no need to worry! You can read more about bind mounting here: https://docs.docker.com/engine/storage/bind-mounts/. 


<br>

## <p style="text-align: center;"> How Are All of the Files in the .devcontainer Folder Structured?</p>

This section will basically just outline all of the files inside of the .devcontainer (which are all of the files that interact with the devcontainer)

Before we go into exactly what each of these files do, we have to make sure that you properly understand some of the vocabulary of docker. A **Host** is the computer that is running the docker container. On linux/ macOS this is your actual computer/ operating system and on windows the host is considered to be your WSL installation. 


**devcontainer.json**:
  This file determines pretty much everything about the devcontainer and most of the other files are simply called by this one. This file specifies all of the vscode extensions that should be installed to the devcontainer, all of the arguments for the "docker run" command, the username of the user inside of the devcontainer, etc. There is an interesting workaround here, with the GPU which is the following line in "runArgs": `"${localEnv:DOCKER_GPU_RUN_ARGS:--env}", "${localEnv:DOCKER_RUNTIME_RUN_ARGS:IGNORE_THIS=hi}"`. All this means is that if DOCKER_GPU_RUN_ARGS and DOCKER_RUNTIME_RUN_ARGS are not set, then we take on the following run argument: `--env IGNORE_THIS=hi` which basically does nothing. If we would like to enable GPUs inside of the devcontainer then we should set the environment variable DOCKER_GPU_RUN_ARGS to --runtime=nvidia and set DOCKER_RUNTIME_RUN_ARGS to --gpus=all.

**postCreateCommand.sh**:
  This command is run on the **Docker Container** right after it starts up and is used for final docker container initialization that requires the mounted filesystem/ github repository. For example, we need to know the exact code of the repository to properly run `colcon build --symlink-install` and build the project and generate the proper symlinks.  

**initializeCommand.sh**:
  This command is run on the **Host** computer before the docker container starts up. This is primarily used right now in order to ensure that whenever you rebuild the devcontainer that you have the most up to date version of the docker image for the devcontainer. Please note that the vscode implementation of the initializeCommand is actually bugged and is different from what the devcontainer standard actually requires; please see the following link for a more thorough explanation: https://github.com/microsoft/vscode-remote-release/issues/9278. 

**host_setup.sh**:
  This command is run by the user on the **HOST** computer by the user once when initially setting up the devcontainer. It ensures that you have the proper packages and environment variables installed on your computer in order to allow the devcontainer to access your display and GPU for the groundstation and computer vision training respectively. This file also does other miscellaneous things such as installing proper udev rules for all of the connected devices that we support.

**host_environment_variables**:
  This is basically a bash script that is run whenever the bashrc or profilerc is run on the host operating system. These consist of any environment variables that the host needs to have to get certain functionality from the devcontainer such as GPU support or devcontainer variants.

**devcontainer_environment_variables**:
  This file is generated by host_setup.sh and is used by the devcontainer.json. All of the environment variables specified in this file are automatically imported into the --env-file argument for running docker containers as seen here: https://stackoverflow.com/questions/68122419/how-do-i-create-a-env-file-in-docker. This file can be used for setting the username visible to the groundstation and setting the display that the groundstation should render to. An example of the contents of this file can be seen below:

```bash
devcontainer_environment_variables

DISPLAY=:0
USER=animated
```

**Dockerfile**:
  This is the dockerfile that describes the docker image that the devcontainer.json uses and describes which packages should be installed into the devcontainer and how. **PLEASE NOTE** if you edit the dockerfile and rebuild the devcontainer, nothing will happen because the docker image that the devcontainer uses is pulled directly from docker hub (https://hub.docker.com/u/vtautoboat), which is the place where the CI/CD pipeline stores the docker images that we create after you push to main or create a new version tag. The issue is that in order to get your custom docker image to show up in docker hub, you would need to first push to main, which defeats the purpose of testing before you push to main. The resolution to this issue is discussed thoroughly in the next section titled "How to Test Custom Docker Images".  

**required_pip_packages.txt**:
  This lists all of the python package requirements that the python ros2 packages and the groundstation require to run properly. The python packages listed in here are automatically installed via the Dockerfile. This is similar to a requirements.txt file if you have ever worked on other python based repositories, but it is slightly renamed to increase clarity.


<br>


## <p style="text-align: center;"> What Are Devcontainer Variants?</p>

Devcontainer variants allow us to have different devcontainers for each of the things people might want to develop on. For example, if you want to develop on computer vision algorithms or if you want to do firmware/ microros development, you might want radically different software installed. Because of that, we actually have multiple devcontainers that we can use as a drop in replacement for the "base" devcontainer. 

The following are the currently available devcontainer variants:

- vtautoboat/development_image
- vtautoboat/development_image_microros
- vtautoboat/development_image_deepstream



## <p style="text-align: center;"> How to Change the Devcontainer Variant You Are Currently Using</p>

In order to switch the devcontainer variant you are currently working with, you have to perform the following steps:

Go to the .devcontainer/host_environment_variables.sh file that should be automatically created from host_setup.sh.

![host_environment_variables](../images/host_environment_variables.png)

Then edit the line that says `export DEVCONTAINER_VARIANT=vtautoboat/development_image` and edit it so that the DEVCONTAINER_VARIANT environment variable contains the name of the devcontainer you want to use. For instance, if you want to use the microros devcontainer, then you should edit the line to be `export DEVCONTAINER_VARIANT=vtautoboat/development_image_microros`. 

Once you have changed this line and saved the file, then close vscode and then go to a WSL terminal or normal linux/ macos terminal thats open at the root of the autoboat_vt repository and then run the following command:

```source ~/.bashrc && code .```

This will refresh your bashrc and open vscode on your autoboat_vt repository. Once vscode opens, please run "Rebuild without Cache and Reopen Container" to rebuild the devcontainer so that it now rebuilds the new devcontainer variant of your choice.

![rebuild_reopen_devcontainer](../images/rebuild_reopen_devcontainer.png)

Now you should be running the devcontainer variant of your choice and you should have everything preinstalled.


<br>


## <p style="text-align: center;"> How to Test Custom Docker Images</p>

If you would like to create and test your own docker images for your individual branch, then you need to do is to build the image so that you have it locally using docker build, push the image to docker hub, and use your custom docker image as a "devcontainer_variant".

You can use the following command to build the docker image. Make sure to run this in the root of the repository and edit the "temp_tag" part with whatever your branch's name is. For example for a branch called motorboat_simulation, you would replace "temp_tag" with "motorboat_simulation". Keep note of what this tag is, we will need it in future commands.

```sh
docker build -t vtautoboat/development_image:temp_tag -f .devcontainer/Dockerfile .
```

Next, go to your browser and go to docker hub and log into docker hub using the autoboat docker hub account. If you do not have the credentials for the autoboat docker hub account, please ask an officer and they should be able to help you. Once you have logged in on your browser, run the following command and follow the given instructions to log into docker hub in your terminal:


```sh
docker login
```

Once you have been successfully logged in, run the following command to push your custom image to docker hub. Remember to replace "temp_tag" with the name of the branch you are working on.

```sh
docker push vtautoboat/development_image:temp_tag
```

Now, your custom docker image should show up as a devcontainer variant! You should be able to edit .devcontainer/host_environment_variables to point to this new devcontainer variant. Next you just have to close vscode, run `source ~/.bashrc && code .`, and then rebuild the devcontainer to open a devcontainer based on your custom docker image. When you are ready to pull request to main, your custom docker image will automatically be used as the default devcontainer that will be installed on everybody's computer. This process is handled automatically via the CI/CD pipeline by building the default devcontainer off of whatever dockerfile is found in the "main" branch of the repository.


<br>


## <p style="text-align: center;"> How Does the Devcontainer Interact with the CI/CD Pipeline?</p>

When a commmit is pushed to main or a new version is created and pushed to the github repository, the CI/CD pipeline will automatically build the vtautoboat/development_image and vtautoboat/development_image_microros docker images and push them to docker hub. There is a trigger on docker hub to update the vtautoboat/development_image_deepstream automatically whenever the vtautoboat/development_image is updated. This is not built on the github action because unfortunately it requires more disk space to build than github actions is willing to give us for free.