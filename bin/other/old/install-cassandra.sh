#!/bin/bash

###################################################################

WEBHOME=~nsadmin
source ${WEBHOME}/bin/install-env.sh

###################################################################




mkdir -p ${WORKDIR}


### Install 
cd /opt/
rm -rf /opt/cassandra-0.1.0
tar -xzvf ${FILEDIR}/cassandra-0.1.0-bin.tar.gz
rm -f /opt/cassandra
ln -sf /opt/cassandra-0.1.0 /opt/cassandra


chmod +x /opt/cassandra/bin/*



### Conf
cd /opt/cassandra/conf
mv storage-conf.xml storage-conf.xml.orig
ln -sf /web/service-phgt-0/etc/cassandra/conf/storage-conf.xml
mkdir /opt/cassandra/build/
mv /opt/cassandra/cassandra-0.1.0.jar /opt/cassandra/build/

### Thrift Interface
cp /web/files/cassandra/interface/fb303.thrift /opt/cassandra/interface/
cp /web/files/cassandra/interface/reflection_limited.thrift /opt/cassandra/interface/
cp /web/files/cassandra/interface/cassandra-v2.thrift /opt/cassandra/interface/cassandra.thrift


