#!/bin/bash


###################################################################

WEBHOME=~nsadmin
source ${WEBHOME}/bin/install-env.sh

###################################################################

LIBLINEAR=liblinear-1.8
SALLY=sally-0.6.3

mkdir -p ${WORKDIR}


cd ${WORKDIR}
tar -xzvf ${FILEDIR}/sci-libs/liblinear.tar.gz
cd ${LIBLINEAR}
make
tar -xzvf ${FILEDIR}/sci-libs/${SALLY}.tar.gz
cd ${SALLY}
./configure --enable-openmp --enable-libarchive --enable-md5hash
make

