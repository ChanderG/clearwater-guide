FROM ubuntu:14.04
MAINTAINER chanderg

RUN rm /etc/apt/sources.list.d/ubuntu-esm-infra-trusty.list
RUN apt-get update

# For the "infrastructure" debs
RUN apt-get install -y python-pip
RUN pip install virtualenv
RUN apt-get install -y build-essential libzmq3-dev libboost-dev
RUN apt-get install -y devscripts fakeroot debhelper

RUN apt-get install -y git
RUN apt-get install -y python python-dev

# Extras for the "management" debs
RUN apt-get install -y libffi-dev

# Extras for "monit" debs
RUN apt-get install -y libtool m4 autotools-dev autoconf bison flex
RUN apt-get install -y libpam0g-dev libssl-dev

# Extras for "snmpd" deb
RUN apt-get install -y libwrap0-dev libperl-dev python-all dh-autoreconf libsensors4-dev libmysqld-dev dh-apport

# For memcached
RUN apt-get install -y git-buildpackage libevent-dev quilt

# For Astaire
RUN apt-get install -y libboost-filesystem-dev libboost-regex-dev libboost-system-dev

# For Chronos
RUN apt-get install -y cmake libsnmp-dev libboost-program-options-dev libcurl4-openssl-dev

# For Crest
RUN apt-get install -y libxml2-dev libxslt1-dev openjdk-7-jdk openjdk-7-jre
# Needs Cassandra
RUN echo "deb http://www.apache.org/dist/cassandra/debian 21x main" | tee -a /etc/apt/sources.list.d/cassandra.sources.list
RUN curl https://www.apache.org/dist/cassandra/KEYS | sudo apt-key add -
RUN apt-get update
RUN apt-get install -y cassandra cassandra-tools

# For Homestead
RUN apt-get install -y libsctp-dev libboost-test-dev libboost-thread-dev config-package-dev

# For Sprout
RUN apt-get install -y libncurses5 libncurses5-dev libboost-locale-dev ruby2.0

# For clearwater-nginx
RUN apt-get install -y nginx

# For clearwater-snmp-handlers
RUN apt-get install -y smitools
