#!/bin/bash

source ./scripts/vars

cmd="$1"

echo "> Switching to Workdir..."
cd $WORKDIR

echo "> Switching to clearwater-docker/kuberenetes..."
cd clearwater-docker/kubernetes

if [ "$cmd" == "cleanup" ]; then
   echo "> Cleaning up modified files..."
   git checkout k8s-gencfg
   git checkout templates

   echo "Done."
   exit
fi

echo "> Updating k8s-gencfg..."
git apply ../../../patches/deployment/gencfg.diff

if [ "$cmd" == "updateApiVersion" ]; then
    echo "> Patching template files for v1.17..."
    fmt_dim
        git apply ../../../patches/deployment/k8s.diff
    fmt_reset
else
    echo "> Assuming, k8s version < v1.17. Skipping patch of resource files."
fi

echo "> Disabling the liveness and readiness checks..."
fmt_dim
  cd templates
  sed -i '/livenessProbe/,/readinessProbe/{/readinessProbe/ !{d}}' *-depl.tmpl
  sed -i '/readinessProbe/,+2d' *-depl.tmpl
fmt_reset

echo "> Set number of Cassandra replicas to 1..."
fmt_dim
  sed -i '/replicas/{s/3/1/g}' cassandra-depl.tmpl
fmt_reset

echo "Done."
