#!/bin/bash

###################################################################

WEBHOME=~nsadmin
source ${WEBHOME}/bin/install-env.sh

###################################################################

mkdir -p ${WORKDIR}

cd ${WORKDIR}
tar -xzvf ${FILEDIR}/sci-libs/ta-lib/${TA_LIB}-src.tar.gz
cd ta-lib
./configure --prefix=${NSHOME}
make install

