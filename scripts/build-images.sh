#!/bin/bash

source ./scripts/vars

echo "> Switching to clearwater-docker directory..."
cd $WORKDIR/clearwater-docker

echo "> Patch the Dockerfiles..."

images="astaire bono cassandra chronos ellis homer homestead homestead-prov ralf sprout"

sd1=memcached/output-debs/
sd2=astaire/output-debs/
sd3=clearwater-infrastructure/output-debs/
sd4=chronos/output-debs/
sd5=clearwater-net-snmp/output-debs/
sd6=crest/output-debs/
sd7=homestead/output-debs/
sd8=clearwater-cassandra/output-debs/
sd9=sprout/output-debs/
sd10=clearwater-nginx/output-debs/
sd11=clearwater-snmp-handlers/output-debs/
sd12=ellis/output-debs/
sd13=ralf/output-debs/

setup_and_build() {
    image="$1"
    deps="$2"

    cd $image

    echo "> Un-patch $image Dockerfile..."
    fmt_dim
        git checkout Dockerfile
    fmt_reset

    echo "> Patching $image Dockerfile..."
    fmt_dim
        git apply ../../../patches/images/$image.diff
    fmt_reset

    fmt_dim
        DESTDIR="clearwater-debs"
        mkdir -p $DESTDIR
        rm -rf $DESTDIR/*
    fmt_reset

    echo "> Setup packages for image $image..."

    fmt_dim
        for dep in $deps; do
            cp ../../$dep $DESTDIR/
        done
    fmt_reset

    echo "> Building image $image..."

    fmt_dim
        docker build -t $NAMESPACE/$image .
    fmt_reset

    cd -
}

setup_and_build astaire "$sd1/*.deb $sd2/*.deb $sd3/clearwater-tcp-scalability* $sd3/clearwater-memcached*"
setup_and_build chronos "$sd4/*.deb $sd5/*.deb $sd3/clearwater-snmpd*.deb"
setup_and_build cassandra "$sd6/homestead-prov-cassandra* $sd6/homer-cassandra* $sd7/homestead-cassandra* $sd8/clearwater-cassandra*"
setup_and_build bono "$sd9/bono* $sd9/restund* $sd9/sprout-libs* $sd3/clearwater-tcp-scalability* $sd3/clearwater-socket-factory*"
setup_and_build sprout "$sd9/sprout* $sd9/clearwater* $sd3/clearwater-tcp-scalability* $sd3/clearwater-socket-factory* $sd3/clearwater-snmpd* $sd3/clearwater-memcached* $sd10/* $sd11/clearwater-snmp-handler-astaire* $sd1/memcached*.deb $sd4/chronos*.deb $sd2/*"
setup_and_build homestead "$sd7/* $sd10/* $sd3/clearwater-snmpd* $sd3/clearwater-tcp-scalability* $sd3/clearwater-socket-factory* $sd6/homestead* $sd6/crest* $sd8/clearwater-cassandra*"
setup_and_build homestead-prov "$sd6/homestead-prov* $sd6/crest* $sd8/clearwater-cassandra* $sd10/clearwater-nginx* $sd7/homestead-cassandra $sd12/clearwater-prov-tools* $sd3/clearwater-tcp-scalability* $sd3/clearwater-socket-factory*"
setup_and_build homer "$sd6/homer* $sd6/crest* $sd8/clearwater-cassandra* $sd10/clearwater-nginx*"
setup_and_build ralf "$sd13/ralf* $sd3/clearwater-tcp-scalability* $sd3/clearwater-socket-factory* $sd3/clearwater-snmpd* $sd1/memcached* $sd4/chronos* $sd2/* $sd11/clearwater-snmp-handler-astaire*"
setup_and_build ellis "$sd12/ellis* $sd10/clearwater-nginx*"

echo "Done."
