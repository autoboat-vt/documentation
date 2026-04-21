# <p style="text-align: center;"> Continuous Integration/ Continous Deployment (CI/CD) </p>

The purpose of the CI/CD pipeline is to allow us to automatically perform certain actions whenever we push new changes to the main branch of the repository. These can include rebuilding binaries for both intel and arm CPUs, rebuilding the docker image that the devcontainer uses and pushing that docker image to docker hub so other people can easily use it, creating a new "github release" which allows people to install autoboat binaries via the apt package manager, etc etc. All of the files related to the CI/CD pipeline can be found in the .github folder.

If you would like to learn more about CI/CD with github, please take a look at the following resources: https://docs.github.com/en/actions and https://docs.docker.com/build/ci/github-actions/

<br>

## <p style="text-align: center;"> Summary of What the CI/CD Pipeline Is Tring To Do</p>


### CI/CD Pipeline Summary
| Feature | Pull Request (PR) | Push to `main` | Version Tag (`v*`) |
| :--- | :---: | :---: | :---: |
| **Verify Build** (amd64 / arm64) | ✅ | ✅ | ✅ |
| **Build & Download `.deb` Packages** | ✅ | ✅ | ✅ |
| **Push Images** (Docker Hub / GHCR) | ❌ | ✅ | ✅ |
| **Update Rolling Release** (`latest`) | ❌ | ✅ | ❌ |
| **Create Official Release** | ❌ | ❌ | ✅ |
| **Multi-Arch Manifests** | ❌ | ✅ | ✅ |



## <p style="text-align: center;"> File Structure of the .github Folder</p>

### <p style="text-align: center;"> Workflows Folder</p>

This is the main folder that contains most of the information about how to run the CI/CD pipeline. The main file is the build-and-release.yml, which is a standard github actions yaml file that defines each of the different jobs that the CI/CD pipeline must run. For example, this contains all of the logic to automatically build/ push the devcontainer variants, building/ distributing ros2 binaries, and publishing official releases. If you would like to learn more about github actions, how they work, syntax, etc etc then you can find the official documentation here: https://docs.github.com/en/actions.


### <p style="text-align: center;"> Scripts Folder</p>

This folder simply contains helper scripts that the build-and-release.yml workflow file uses so that we can keep the workflow file as clean as possible. The workflow file is already long enough, and it doesn't need to be longer by inlining bash scripts.


### <p style="text-align: center;"> Deb Folder</p>

This folder contains all of the files required to construct the debian packages. This includes post installation commands, commands to run when removing the debian packages, package requirements, and package descriptions. Some tutorials for building debian packages can be found here: https://linuxopsys.com/build-debian-packages and https://blog.heckel.io/2015/10/18/how-to-create-debian-package-and-debian-repository/.