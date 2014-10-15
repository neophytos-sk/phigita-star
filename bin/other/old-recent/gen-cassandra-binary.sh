#!/bin/bash

###################################################################

WEBHOME=~nsadmin
source ${WEBHOME}/bin/install-env.sh

###################################################################




mkdir -p ${WORKDIR}

### Build Binary
cd ${SRCDIR}/cassandra

thrift -r --gen java -o interface interface/cassandra.thrift
cp interface/gen-java/com/facebook/infrastructure/service/* src/com/facebook/infrastructure/service/

ant clean
ant jar
ant binary
cp ${SRCDIR}/cassandra/build/cassandra-0.1.0-bin.tar.gz ${FILEDIR}