#!/bin/bash

###################################################################

WEBHOME=~nsadmin
source ${WEBHOME}/bin/install-env.sh

###################################################################

mkdir -p ${WORKDIR}

cd ${WORKDIR}
tar -xzvf ${FILEDIR}/dev-libs/libxls/${LIBXLS}.tar.gz
cd ${LIBXLS}
./configure --prefix=/opt/naviserver/
make install

