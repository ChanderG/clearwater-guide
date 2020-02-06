# clearwater-guide

The missing guide to running Clearwater.

## What?

[Clearwater](https://www.projectclearwater.org/) is an open source cloud based IMS Core from Metaswitch. Metaswitch has recently archived the project and stoppped active participation. Though all source files are available on Github under the Metaswitch org, the compiled packages and images are no longer accesible and hence the system is not usable out of the box.

This guide is a bunch of scripts and patches to the project that will enable you to get everything working.

## The guide

This guide consists of the following pieces:

1. A set of patches (diff files) to various Clearwater components fixing bugs and errors.
2. A set of scripts to automate the compilation and packaging of the components and building the images.
3. A set of patches to the docker-compose/kubernetes deployment files to allow deployment.

### Building the Components

Earlier, Metaswitch made all the component binaries availabale as `deb` packages (for Ubuntu 14.04) at the url "repo.cw-ngv.com". After the archival, this repository is no longer available and so we have to build these components from source ourselves.

### First fetch the sources from Github
```
./scripts/fetch-component-sources.sh
```
This script requires a ssh based git clone setup to GitHub, to pull the recursive repos.

### Patch the sources
```
./scripts/patch-sources.sh
```
This uses the patches from the `patches/` folder. Look [here](./patches/README.md) to see details on what the patches do.

### Setup a build environment

To build and package the components, we need an Ubuntu 14.04 environment with a bunch of dependencies. We'll setup a Docker image to use as the build environment.

```
docker build -t clearwater-guide/build-env ./buildenv
```

### Build the components

```
./scripts/build-components.sh
```

In this step, we run a build environment container to build the `deb` packages. Specifically, for each component:
1. Run a container based on the build env image.
2. Mount the component source folder as a volume.
3. Run the specific commands to build and package. This varies from component to component.
4. Move the artifacts to a folder in the component source folder so that they are persisted on the host machine.
