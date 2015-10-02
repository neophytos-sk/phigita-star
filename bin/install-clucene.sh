#!/bin/bash


###################################################################

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source ${DIR}/install-env.sh

###################################################################


mkdir -p ${WORKDIR}

cd ${WORKDIR}
tar -xjvf ${FILEDIR}/clucene/${CLUCENE}.tar.bz2
cd ${CLUCENE}/
mkdir phigita
cd phigita
cmake -DCMAKE_BUILD_TYPE:STRING=Release -DCMAKE_INSTALL_PREFIX:PATH=/opt/${CLUCENE} ..
#cmake -DCMAKE_INSTALL_PREFIX:PATH=/opt/${CLUCENE} ..
#make clucene-core

rm -rf /opt/${CLUCENE}
make install

#rm -f /opt/clucene
#ln -sf /opt/${CLUCENE} /opt/clucene

