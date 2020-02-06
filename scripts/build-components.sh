#!/bin/bash

source ./scripts/vars

echo "> Switching to Workdir..."
cd $WORKDIR

echo "> Building the components..."

component_idx=1
build() {
    component="$1"
    cmd="$2"

    echo "> Building $component ($component_idx/num)"
    ((component_idx++))

    fmt_dim
        docker run -i --rm -v $PWD/"$component":/cw -w /cw clearwater-guide/build-env bash -c "$cmd; mkdir -p /cw/output-debs; rm -f /cw/output-debs/*; mv /*.deb /cw/output-debs/"
    fmt_reset
}

# build clearwater-infrastructure "make deb"
# build clearwater-etcd "make deb"
# build clearwater-monit "make -f clearwater.mk deb"
# build memcached "rm -rf output-debs; ./config/autorun.sh; git-buildpackage -uc -us --git-ignore-branch"
# build astaire "make deb"
# build chronos "make deb"
# build clearwater-cassandra "make deb"
# build crest "make deb"
# build ellis "make deb"
# build ralf "make deb"
# build homestead "make deb"
# build sprout "make deb"

# NOT WORKING build clearwater-net-snmp "./configure --with-defaults; make"
# NOT DONE build clearwater-snmp-handlers
