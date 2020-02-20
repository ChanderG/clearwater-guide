#!/bin/bash

source ./scripts/vars

echo "> Switching to Workdir..."
cd $WORKDIR

echo "> Switching to clearwater-docker/kuberenetes..."
cd clearwater-docker/kubernetes

echo "> Patching template files for v1.17..."
fmt_dim
    git apply ../../../patches/deployment/k8s.diff
fmt_reset

echo "Done."
