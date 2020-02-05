#!/bin/bash

source scripts/vars

echo "> Creating Workdir..."
mkdir -p $WORKDIR

echo "> Switching to Workdir..."
cd $WORKDIR

echo "> Fetching sources..."

color_dim

repos="clearwater-infrastructure clearwater-etcd clearwater-monit astaire chronos crest homestead clearwater-cassandra sprout clearwater-nginx clearwater-net-snmp clearwater-snmp-handlers ellis ralf"

for repo in $repos; do
    git clone --recursive https://github.com/Metaswitch/$repo
done
# needs a special branch
git clone https://github.com/Metaswitch/memcached -b clearwater-debian

color_reset

echo "> Done."
