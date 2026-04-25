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
### <p style="text-align: center;"> Workflows Folder</p>

The files in this folder are used to define the different workflows that should run when certain events happen. Currently it contains two files:

- `build-and-release.yml`: This is the main workflow file that defines the CI/CD pipeline. It contains the logic for:
    - Building each devcontainer variant and pushing those images to Docker hub
    - Building the Debian packages for both Intel and Arm CPUs and pushing those packages to our `apt` repository
    - Creating a new Github release when we push a new version tag (e.g. `v1.0.0`) to the repository

- `docker-bake.hcl`: This file is used to define the different Docker build targets that we want to build when we push changes to the main branch. This file is used by the `build-and-release.yml` workflow file to build the different Docker images that the devcontainer uses and push those images to Docker hub.

To learn more about Github workflows, please see the following links:

- <https://docs.github.com/en/actions>
- <https://docs.docker.com/build/ci/github-actions>

### <p style="text-align: center;"> Scripts Folder</p>

This folder simply contains helper scripts that the `build-and-release.yml` workflow file uses so that we can keep the workflow file as clean as possible. The workflow file is already long enough, and it doesn't need to be longer by inlining bash scripts.

### <p style="text-align: center;"> Deb Folder</p>

This folder contains all of the files required to construct the Debian packages. This includes:
- Post installation commands
- Commands to run when removing the Debian packages
- Package requirements and descriptions

Some tutorials for building Debian packages:

- <https://linuxopsys.com/build-debian-packages>
- <https://blog.heckel.io/2015/10/18/how-to-create-debian-package-and-debian-repository>
