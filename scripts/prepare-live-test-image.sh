#!/bin/bash

source ./scripts/vars

docker_registry_namespace="$1"

if [ "$docker_registry_namespace" == "" ]; then
    echo "Empty docker registry namespace passed in. Refusing to continue."
    exit
fi

echo "> Using image namespace: "
fmt_underline
  echo "$docker_registry_namespace"
fmt_reset

echo "> Switching to Live Test env directory..."
cd livetest_env

echo "> Getting the live-test code..."
fmt_dim
  git clone --recursive https://github.com/Metaswitch/clearwater-live-test
fmt_reset

echo "> Building the live-test image..."
fmt_dim
    docker build -t $NAMESPACE/cw-live-tests-base .
fmt_reset

echo "> Tag and Push the image..."
fmt_dim
    docker tag $NAMESPACE/cw-live-tests-base $docker_registry_namespace/cw-live-tests-base
    docker push $docker_registry_namespace/cw-live-tests-base
fmt_reset

echo "Done."
