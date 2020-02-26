#!/bin/bash

source ./scripts/vars

op=$1
namespace=${2:-default}

echo "> Switching to Workdir..."
cd $WORKDIR

echo "> Switching to clearwater-docker/kuberenetes..."
cd clearwater-docker/kubernetes

##### Helper functions

# Run a single file.
runFile() {
	file=$1
	operation=$2
	kubectl -n $namespace $operation -f $file
}

# Apply resources from file.
apply() {
	file=$1
	runFile $file apply
}

# Delete resources from a file.
delete() {
	file=$1
	runFile $file delete
}

group1="etcd"
group2="astaire cassandra chronos"
group3="homestead homestead-prov homer ralf sprout"
group4="bono ellis"

operate_group() {
    operation=$1
    group=$2

    fmt_dim
        for res in $group; do
            $operation resources/$res-depl.yaml
        done
    fmt_reset
}

teardown() {
    echo "> Tearing down deployments - group 4."
    operate_group delete "$group4"

    echo "> Tearing down deployments - group 3."
    operate_group delete "$group3"

    echo "> Tearing down deployments - group 2."
    operate_group delete "$group2"

    echo "> Tearing down deployments - group 1."
    operate_group delete "$group1"

    echo "> Tearing down services..."
    fmt_dim
        for res in resources/*-svc.yaml; do
            kubectl -n $namespace delete -f $res
        done
    fmt_reset
}

setup() {
    echo "> Setting up services..."
    fmt_dim
        for res in resources/*-svc.yaml; do
            kubectl -n $namespace apply -f $res
        done
    fmt_reset

    echo "> Setting up deployments - group 1."
    operate_group apply "$group1"

    sleep 30

    echo "> Setting up deployments - group 2."
    operate_group apply "$group2"

    sleep 60

    echo "> Setting up deployments - group 3."
    operate_group apply "$group3"

    sleep 30

    echo "> Setting up deployments - group 4."
    operate_group apply "$group4"
}

if [ "$op" == "down" ]; then
   teardown
else
   setup
fi
