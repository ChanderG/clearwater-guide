#!/bin/bash

source ./scripts/vars

echo "> Patch the Dockerfiles..."

images="astaire bono cassandra chronos ellis homer homestead homestead-prov ralf sprout"

fmt_dim
  cd $WORKDIR/clearwater-docker
  for i in $images; do
      git apply ../../patches/images/$i.diff
  done
  cd -
fmt_reset

echo "Done."
