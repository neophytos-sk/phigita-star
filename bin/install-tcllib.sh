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
ALT=${2}${TCLLIB}

echo "PREFIX=$PREFIX ALT=$ALT"


### tcllib
cd ${WORKDIR}
tar -xjvf ${FILEDIR}/tcl-modules/${TCLLIB}.tar.bz2
mv ${TCLLIB} ${ALT}
cd ${ALT}

./configure --prefix=${PREFIX} --exec-prefix=${PREFIX}
make install
###cp ${FILEDIR}/mime.tcl-1.5.1 ${PREFIX}/tcl/tcllib1.9/mime/

#cd ${PREFIX}/lib/
#unzip ${FILEDIR}/TclS3.zip -d .
#mv README.txt TclS3/
