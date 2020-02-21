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

#### First fetch the sources from Github
```
./scripts/fetch-component-sources.sh
```
This script requires a ssh based git clone setup to GitHub, to pull the recursive repos.

#### Patch the sources
```
./scripts/patch-sources.sh
```
This uses the patches from the `patches/` folder. Look [here](./patches/README.md) to see details on what the patches do.

#### Setup a build environment

To build and package the components, we need an Ubuntu 14.04 environment with a bunch of dependencies. We'll setup a Docker image to use as the build environment.

```
docker build -t clearwater-guide/build-env ./buildenv
```

#### Build the components

```
./scripts/build-components.sh
```

In this step, we run a build environment container to build the `deb` packages. Specifically, for each component:
1. Run a container based on the build env image.
2. Mount the component source folder as a volume.
3. Run the specific commands to build and package. This varies from component to component.
4. Move the artifacts to a folder in the component source folder so that they are persisted on the host machine.

### Building the images

In this section, we'll build the images needed to run the Clearwater system.

#### Building the base image

All images base on this one. Let's build this first.

```
./scripts/build-base-image.sh
```

#### Build the other images

Build all images:
```
./scripts/build-images.sh
```
Note: all images are tagged under a namespace defined in the `vars` file.

### Deploying

The `clearwater-docker` repository talks about deploying using `docker` or `kuberenetes`.

While the `docker` deployment may work, there are issues with running the tests post that, so we'll cover only
the `kuberenetes` deployment.

The `k8s` deployment includes `helm` charts. While they may work, my own local tests showed that the k8s `deployments` had to be brought up in a specific order for the system to work correctly. Hence, I'll follow a simple `kubectl` based deployment approach.

First, publish the images we have created to your own Docker Registry. The following script tags and pushes
the image as long as you are logged into registry:
```
./scripts/deploy-images.sh <full registry namespace url>
```

Also, at this stage, setup your `k8s` cluster to be able to talk to this docker registry. One way to do that is to setup a secret in `k8s` with this auth details to connect to the registry. Setup such a secret in the cluster namespace that you want to deploy `clearwater` in. Note the name of this secret.

Now, we patch the `k8s` scripts and templates to suit our needs. This includes one customizable option.
Pass a single argument to the script, "updateApiVersion", if you are to work with a k8s cluster of version `1.17` and later. If your `k8s` version is older than that, no argument is needed.
```
./scripts/patch-k8s-files.sh <updateApiVersion|cleanup|"">
```
Note: This script can also take an argument "cleanup". This is used to undo the changes done by the script. So, for instance, if you wanted to change the k8s deployment target after you have already done this step, you can simply run `./scripts/patch-k8s-files.sh cleanup` followed by `./scripts/patch-k8s-files.sh` or `./scripts/patch-k8s-files.sh updateApiVersion` as needed.

Next, let's generate the resource yamls from the templates:
```
cd ./workdir/clearwater-docker/kubernetes
./k8s-gencfg --image_path <path to image registry> --image_tag latest --image_secret <name of k8s secret that allows access to the docker images>
```

The folder `workdir/clearwater-docker/kubernetes/resources` should now be populated with the generated resource yaml files.

One more step. In the namespace that you have setup the secret, create an env-var as follows:
```
kubectl -n <namespace> create configmap env-vars --from-literal=ZONE=<namespace>.svc.cluster.local
```

Let's deploy Clearwater. Finally!!!
```
./scripts/deploy.sh <up|down> <namespace>
```
deploys (or tearsdown) the clearwater system to (from) the provided namespace using other default values configured for kubectl. This script internally just calls kubectl with the resources generated in the previous step in a certain order.

Once this is done, Clearwater will be up and running.

### Testing

Of course, how do we know that Clearwater is functioning correctly, or even running at all. Enter the tests.

We have 2 flavours of tests, the `live-tests` that are single e2e tests that try out different scenarios and the 
`stress-tests` which are a single call scenario tried in large numbers.

#### Live Tests

While the live test code is provided by Metaswitch, the container image is not. So, as before, we pull the code,
and use a custom Dockerfile to build an image with has all the needed components.

Run:
```
./scripts/prepare-live-test-image.sh <full registry namespace url>
```

Deploy the container and run the tests:
```
./scripts/run-live-test.sh <namespace> <path to image_registry> <name of registry secret>
```

The live tests should run and logs will be printed to the terminal. (Note: 43 tests are skipped in the default configuration, it does not mean anything negative.)

#### Stress Tests

Now, let's run the stress tests.

Firstly, we need to load some numbers that'll be used in the tests. Run:
```
./scripts/load-numbers.sh <namespace>
```
Note that this takes some time to run.

Look at this script to understand what's happening under the hood and to customize it. The actual process is inside another script, to be found in `stresstest_env/create-numbers.sh` that is copied inside one a Homestead pod and run locally there.

The astute reader would notice that this is a variant of the official process documented here (https://github.com/Metaswitch/crest/blob/dev/docs/Bulk-Provisioning%20Numbers.md). The reason is that that script does not work out of the box for the container based approach of deploying Clearwater.

Now that the data is loaded, we can run `clearwater-sipp` to run the actual stress tests.

```
./scripts/run-stress-test.sh <namespace> <path to image_registry> <name of registry secret>
```
