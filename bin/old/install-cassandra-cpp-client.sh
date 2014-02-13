#!/bin/bash

###################################################################

WEBHOME=~nsadmin
source ${WEBHOME}/bin/install-env.sh

###################################################################

mkdir -p ${WORKDIR}


#  -lthriftnb -levent : libthriftnb -> non-blocking, requires libevent
emerge -av libevent

cd /opt/cassandra/interface/
cp /web/files/cassandra/interface/cassandra-v2.thrift /opt/cassandra/interface/cassandra.thrift
thrift -r --gen cpp cassandra.thrift
cd gen-cpp/
cp /web/files/cassandra/interface/cpp/CassandraClient.cpp .
cp /web/files/cassandra/interface/cpp/CassandraClientWrapper.h .
cp /web/files/cassandra/interface/cpp/Makefile .
make clean
make


