#!/bin/bash

source ./scripts/vars

namespace=$1
docker_image_registry=$2
registry_secret=$3

echo "> Switching to stress-test directory..."
cd stresstest_env

echo "> Copying template file..."
fmt_dim
    cp cw-sipp-terminal.templ cw-sipp-terminal.yaml
fmt_reset

echo "> Filling in template variables..."
fmt_dim
    sed -i "s|__docker_image_registry__|$docker_image_registry|g" cw-sipp-terminal.yaml
    sed -i "s|__registry_secret__|$registry_secret|g" cw-sipp-terminal.yaml
fmt_reset

echo "> Removing old instances of the clearwater sipp terminal..."
fmt_dim
    kubectl -n $namespace delete deployment cw-sipp-terminal
fmt_reset

echo "> Deploying the sipp terminal..."
fmt_dim
    kubectl -n $namespace apply -f ./cw-sipp-terminal.yaml
fmt_reset

echo "> Waiting for clearwater-sipp-terminal Pod to startup..."
fmt_dim
    kubectl -n $namespace wait --for condition=ready pod -l service=cw-sipp-terminal
fmt_reset

echo "> Save the terminal pod id..."
fmt_dim
    while : ; do
        pod=$(kubectl -n $namespace get pods | grep cw-sipp-terminal | grep Running | head -n1 | awk '{print $1}')
        echo "Pod id is: $pod"
        if [[ "$pod" != "" ]]; then
            break
        fi
    done
fmt_reset

echo "> Some wait time..."
sleep 90s

echo "> Copy in setup terminal script..."
fmt_dim
    kubectl -n $namespace cp ./setup-terminal.sh $pod:/tmp/setup-terminal.sh
fmt_reset

echo "> Setup the terminal..."
fmt_dim
    kubectl -n $namespace exec $pod bash /tmp/setup-terminal.sh
fmt_reset

echo "> Copy in the scenario file..."
fmt_dim
    kubectl -n $namespace cp ./uac_modified.xml $pod:/usr/share/clearwater/sip-stress/sip-stress.xml
fmt_reset

number=${4:-300}
echo "> Reduce the number of users to $number..."
fmt_dim
    kubectl -n $namespace exec $pod -- sed -i "$((number+2)),$ d" /usr/share/clearwater/sip-stress/users.csv.1
fmt_reset

echo "> Run the stress test..."
fmt_dim
  cmd="echo '>:100:stresstest::' > /dev/null; /etc/init.d/clearwater-sip-stress start || true; sleep 60; /etc/init.d/clearwater-sip-stress stop; echo '<:100:stresstest::' > /dev/null"
  kubectl -n $namespace exec $pod -- bash -c "$cmd"
fmt_reset

echo "> Logs are now available in $pod: /var/log/clearwater-sipp"

echo "> Here is a sampling: "
fmt_dim
  kubectl -n $namespace exec $pod -- bash -c "tail -n40 /var/log/clearwater-sipp/sip-stress.1.out"
fmt_reset

echo "> Done."
