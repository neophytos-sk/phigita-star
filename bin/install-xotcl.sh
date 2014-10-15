#!/bin/bash


###################################################################

WEBHOME=/web
source ${WEBHOME}/bin/install-env.sh

###################################################################


function usage_info {
    echo "USAGE: "
    echo "  $0 prefix alt"
    echo "for example, prefix=/opt/tcl8.6b2, and alt=naviserver-"
}

if [ $# -lt 1 ]; then 
    usage_info
    exit
fi

PREFIX=${1}
ALT=${2}${XOTCL}

echo "PREFIX=$PREFIX ALT=$ALT"


mkdir -p ${WORKDIR}

cd ${WORKDIR}
tar -xzf ${FILEDIR}/xotcl/${XOTCL}.tar.gz
mv ${XOTCL} ${ALT}
cd ${ALT}/unix/
../configure --enable-threads --prefix=${PREFIX} --exec-prefix=${PREFIX} --with-tcl=${PREFIX}/lib
make
make install-aol

