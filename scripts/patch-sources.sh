#!/bin/bash

source ./scripts/vars

echo "> Switching to Workdir..."
cd $WORKDIR

patches="astaire chronos clearwater-cassandra clearwater-infrastructure crest homestead memcached"

echo "> Applying patches..."

fmt_dim
    for p in $patches; do
        cd ./$p
        echo "Patching $p..."
        git apply ../../patches/components/$p.diff
        cd ..
    done
fmt_reset

echo "> Commiting Memcached changes..."
fmt_underline
    echo "(memcached packaging needs it to have no un-commited changes)"
fmt_reset

fmt_dim
    cd ./memcached
    git add .
    git commit -m "fix compilation issues"
fmt_reset

echo "> Done."
