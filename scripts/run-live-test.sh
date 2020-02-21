#!/bin/bash

source ./scripts/vars

namespace=$1
docker_image_registry=$2
registry_secret=$3

echo "> Switching to live-test directory..."
cd livetest_env

echo "> Copying template file..."
fmt_dim
    cp cw-live-test.templ cw-live-test.yaml
fmt_reset

echo "> Filling in template variables..."
fmt_dim
    sed -i "s|__docker_image_registry__|$docker_image_registry|g" cw-live-test.yaml
    sed -i "s|__namespace__|$namespace|g" cw-live-test.yaml
    sed -i "s|__registry_secret__|$registry_secret|g" cw-live-test.yaml
fmt_reset

echo "> Removing old instances of the test (if any)..."
fmt_dim
    kubectl -n $namespace delete -f ./cw-live-test.yaml
fmt_reset

echo "> Deploying the test (if any)..."
fmt_dim
    kubectl -n $namespace apply -f ./cw-live-test.yaml
fmt_reset

echo "> Waiting for Pod to startup..."
fmt_dim
    kubectl -n $namespace wait --for condition=ready pod -l job-name=cw-live-test
fmt_reset

echo "> Following the logs..."
kubectl -n $namespace logs -f job/cw-live-test
