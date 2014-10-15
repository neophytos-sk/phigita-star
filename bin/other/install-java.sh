#!/bin/bash

###################################################################

WEBHOME=/web
source ${WEBHOME}/bin/install-env.sh

###################################################################

cd /opt
tar -xzvf /web/files/java/javacc-5.0.tar.gz
tar -xzvf /web/files/apache/apache-ant-1.7.1-bin.tar.gz
/web/files/java/jdk-7-ea-bin-b76-linux-i586-12_nov_2009.bin

rm -f jdk
ln -sf /opt/jdk1.7.0 jdk