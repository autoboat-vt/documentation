---
title: AutoBoat Documentation 
---

# <p style="text-align: center"> Installing Docker </p>

!!!NOTE "NOTE: If You Meet Difficulties Installing Docker"
    Ensure that you meet Docker's system requirements listed on their [documentation](https://docs.docker.com/get-docker/), if not then attempt to contact an officer or look through the Docker documentation for what to do if you do not meet the system requirements.

<br>

## <p style="text-align: center"> **Installing Docker on Windows** </p>

In order to install Docker on windows, first we must install WSL (Windows Subsystem in Linux).

Open the command prompt ***with administrator privileges*** and type the following commands:

``` sh
wsl.exe --install -d Ubuntu-22.04
```

``` sh
wsl --set-default Ubuntu-22.04
```

Enter your user info to complete the installation.  

---------

With these steps, this will have installed WSL and Ubuntu 22.04. Docker requires Ubuntu WSL to work on Windows. For more information see the official WSL documentation: [Official WSL Documentation](https://learn.microsoft.com/en-us/windows/wsl/install).

Next, we must install the Docker desktop application and connect it up to WSL.  

---------

The following link contains the download link for Docker desktop on Windows. Follow the download instructions, and when you are done, you should have Docker installed!
[Docker Desktop for Windows Install Page](https://docs.docker.com/desktop/install/windows-install/)

You may run into permission issues with docker, so you need to run the following commands in your WSL terminal to give your non-sudo user access to Docker.

``` sh
sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker
```


<br> 

## <p style="text-align: center;"> **Installing Docker on Ubuntu Linux** </p>

------------------------------------------------------------------------

Please type the following sets of commands in a terminal.

``` sh
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
```

``` sh
# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
```

``` sh
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

``` sh
sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker
```

------------------------------------------------------------------------

<br>

## <p style="text-align: center;"> **Installing Docker on Mac OS** </p>

Docker can be installed standalone from the [website](https://docs.docker.com/desktop/install/mac-install/), but it is recommended to instead install via [Homebrew](https://brew.sh/), the unofficial official package manager for Mac OS. Homebrew is recommended over the standalone installer as it simplifies the installation process and is nice to use.

Please install Homebrew by entering the following command into the terminal

``` sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Now that Homebrew is installed, run the following command to install Docker Desktop

``` sh
brew install --cask docker
```

To verify that the installation was successful, run the following command

``` sh
docker version
```

If the installation succeeded, you should get something along the lines of the following

``` sh
❯ docker version
Client:
 Version:           27.0.3
 API version:       1.46
 Go version:        go1.21.11
 Git commit:        7d4bcd8
 Built:             Fri Jun 28 23:59:41 2024
 OS/Arch:           darwin/arm64
 Context:           desktop-linux
```

<br>  

## <p style="text-align: center;"> **Installing Docker on Other Operating Systems** </p>

Documentation for the rest of the operating systems docker supports can be found here: [Official Docker Installation Instructions for Every OS](https://docs.docker.com/engine/install/).
