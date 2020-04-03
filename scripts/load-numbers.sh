#!/bin/bash

source ./scripts/vars

namespace=$1
if [ "$namespace" == "" ]; then
    echo "No namespace name passed. Refusing to continue."
    exit
fi
echo "> Using namespace: $namespace"

num_numbers=${2:-50000}

echo "> Obtain the Homestead pod name..."
fmt_dim
    pod=$(kubectl -n $namespace get pods | grep "homestead" | head -n1 | awk '{print $1}')
    echo "using the pod name: $pod"
fmt_reset

echo "> Copy in the create script..."
fmt_dim
  kubectl -n $namespace cp ./stresstest_env/create-numbers.sh $pod:/tmp/create-numbers.sh
fmt_reset

echo "> Execute the script..."
fmt_dim
    kubectl -n $namespace exec -i $pod -c homestead /tmp/create-numbers.sh $num_numbers
fmt_reset
