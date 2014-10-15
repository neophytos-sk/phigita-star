#!/bin/bash

###################################################################

WEBHOME=~nsadmin
source ${WEBHOME}/bin/install-env.sh

###################################################################

mkdir -p ${WORKDIR}

#./install-thrift.sh
#./install-cassandra.sh

cd ${WORKDIR}
cd ${CASSANDRA}/interface

rm -rf gen-java
thrift -r --gen java cassandra.thrift
cd gen-java
ln -sf /web/files/cassandra/build.xml
ln -sf /web/files/cassandra/com/ibm com/
ln -sf /web/files/cassandra/CassandraClient.java
ant jar
cp CassandraClient.jar /opt/cassandra/lib/
ln -sf /web/files/cassandra/bin/Cassandra-remote /opt/cassandra/bin/
