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

echo "> Tagging and Pushing base image"
fmt_dim
  docker tag clearwater/base $docker_registry_namespace/base
  docker push $docker_registry_namespace/base
fmt_reset

images="astaire bono cassandra chronos ellis homer homestead homestead-prov ralf sprout"

tag_and_push () {
    image="$1"
    echo "> Tagging and Pushing - $image ..."
    fmt_dim
        docker tag $NAMESPACE/$image $docker_registry_namespace/$image
        docker push $docker_registry_namespace/$image
    fmt_reset
}

for i in $images; do
    tag_and_push $i
done

echo "Done."
