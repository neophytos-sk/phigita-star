#!/bin/bash

###################################################################

WEBHOME=~nsadmin
source ${WEBHOME}/bin/install-env.sh

###################################################################




mkdir -p ${WORKDIR}

# emerge sun-jdk javacc
# java-config  --list-available-vms
# java-config --set-user-vm
# java-config --set-system-vm
# emerge boost libevent zlib 

cd ${WORKDIR}
tar -xjvf ${FILEDIR}/thrift/${THRIFT}.tar.bz2
#tar -xzvf ${FILEDIR}/${THRIFT}.tar.gz
cd ${THRIFT}
./bootstrap.sh
./configure
make
make install
