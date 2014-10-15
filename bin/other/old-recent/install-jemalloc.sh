#!/bin/bash


###################################################################

WEBHOME=~nsadmin
source ${WEBHOME}/bin/install-env.sh

###################################################################

if [ $# -eq 0 ]; then 
    PREFIX=/opt/${JEMALLOC}
    ALT=local-${JEMALLOC}
else
    PREFIX=${1}
    ALT=${2}${JEMALLOC}
fi


echo "PREFIX=$PREFIX ALT=$ALT"


mkdir -p ${WORKDIR}

### TCL for NAVISERVER
cd ${WORKDIR}
${WEBHOME}/bin/unpack.sh ${FILEDIR}/dev-libs/jemalloc/${JEMALLOC}.tar.bz2
mv ${JEMALLOC} ${ALT}

cd ${ALT}

./configure --prefix=${PREFIX}
make install

rm -f /opt/jemalloc
ln -sf $PREFIX /opt/jemalloc


echo "To view loaded shared libraries by running processes under linux: cat /proc/<pid>/maps"
