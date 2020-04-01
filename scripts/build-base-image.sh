#!/bin/bash

source ./scripts/vars

echo "> Obtain the clearwater-docker repo..."

fmt_dim
  cd $WORKDIR
  git clone https://github.com/Metaswitch/clearwater-docker
  cd -
fmt_reset

echo "> Patching the base image Dockerfile..."

fmt_dim
  cd $WORKDIR/clearwater-docker
  git apply ../../patches/images/base.diff
  cd -
fmt_reset

echo "> Copying in local packages..."

fmt_dim
  cd $WORKDIR

  SRCDIR1=clearwater-infrastructure/output-debs/
  SRCDIR2=clearwater-etcd/output-debs/
  SRCDIR3=clearwater-monit/output-debs/
  SRCDIR4=clearwater-net-snmp/output-debs/
  SRCDIR5=clearwater-snmp-handlers/output-debs/

  DESTDIR=clearwater-docker/base/clearwater-debs
  mkdir -p $DESTDIR
  rm -rf $DESTDIR/*

  cp $SRCDIR1/clearwater-infrastructure_*.deb $DESTDIR/
  cp $SRCDIR1/clearwater-auto-config-docker_*.deb $DESTDIR/
  cp $SRCDIR1/clearwater-diags-monitor_*.deb $DESTDIR/
  cp $SRCDIR1/clearwater-log-cleanup_*.deb $DESTDIR/
  cp $SRCDIR1/clearwater-snmpd*.deb $DESTDIR/

  cp $SRCDIR2/*.deb $DESTDIR/

  cp $SRCDIR3/*.deb $DESTDIR/

  cp $SRCDIR4/*.deb $DESTDIR/

  # only needed on some nodes: ttps://clearwater.readthedocs.io/en/stable/Clearwater_SNMP_Statistics.html
  # let's blanket install for ease of use
  cp $SRCDIR5/*.deb $DESTDIR/

  cd -
fmt_reset

echo "> Build the image..."

fmt_dim
  cd $WORKDIR/clearwater-docker
  docker build -t clearwater/base base
  cd -
fmt_reset

echo "> Done."
