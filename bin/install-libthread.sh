#!/bin/bash


###################################################################

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source ${DIR}/install-env.sh

###################################################################


function usage_info {
    echo "USAGE: "
    echo "  $0 prefix alt"
    echo "for example, prefix=/opt/tcl8.6b3, and alt=naviserver-"
}

if [ $# -lt 1 ]; then 
    usage_info
    exit
fi

PREFIX=${1}
ALT=${2}${TCL_THREAD_LIB}

echo "PREFIX=$PREFIX ALT=$ALT"


mkdir -p ${WORKDIR}



### TCL Thread Extension
cd ${WORKDIR}
tar -xzvf ${FILEDIR}/tcl-modules/${TCL_THREAD_LIB}.tar.gz
mv ${TCL_THREAD_LIB} ${ALT}
cd ${ALT}/unix/

../configure \
    --enable-threads \
    --prefix=${PREFIX} \
    --exec-prefix=${PREFIX} \
    --with-aolserver=${PREFIX} \
    --with-naviserver=${PREFIX}

make
make install
