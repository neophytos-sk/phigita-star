#!/bin/bash


###################################################################

WEBHOME=~nsadmin
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
ALT=${2}${TCLCURL}

echo "PREFIX=$PREFIX ALT=$ALT"

mkdir -p ${WORKDIR}

CMD="emerge --noreplace --deep"
USE="threads" ${CMD} curl

### TclCurl
cd ${WORKDIR}
tar -xzvf ${FILEDIR}/tcl-modules/${TCLCURL}.tar.gz
mv ${TCLCURL} ${ALT}
cd ${ALT}

./configure --enable-threads --prefix=${PREFIX} --with-tcl=${PREFIX}/lib/ --with-tclinclude=${PREFIX}/include --includedir=${PREFIX}/include 
make
make install
