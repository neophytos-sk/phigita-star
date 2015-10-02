#!/bin/bash


###################################################################

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source ${DIR}/install-env.sh

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
ALT=${2}${TCLGD}

echo "PREFIX=$PREFIX ALT=$ALT"


mkdir -p ${WORKDIR}


### TclGD
cd ${WORKDIR}
tar -xjvf ${FILEDIR}/tcl.gd/${TCLGD}.tar.bz2
mv ${TCLGD} ${ALT}
cd ${ALT}
autoconf
./configure --enable-threads --prefix=${PREFIX} --with-tcl=${PREFIX}/lib/ --with-tclinclude=${PREFIX}/include --includedir=${PREFIX}/include 
make
make install
