#!/bin/bash


###################################################################

WEBHOME=/web
source ${WEBHOME}/bin/install-env.sh

###################################################################


function usage_info {
    echo "USAGE: "
    echo "  $0 prefix ?alt? ?extra_flags?"
    echo "for example, prefix=/opt/tcl8.6b2, alt=naviserver-, extra_flags=--with-aolserver=/opt/naviserver-phigita-2012.3-2012-07-16"
}

if [ $# -lt 1 ]; then 
    usage_info
    exit
fi

PREFIX=${1}
ALT=${2}${TDOM}
EXTRA_FLAGS=${3}

echo "PREFIX=$PREFIX ALT=$ALT"


### Install tdom

cd ${WORKDIR}
#tar -xjvf ${FILEDIR}/tcl-modules/tdom-cvs-20071108.tar.bz2
tar -xjvf ${FILEDIR}/tcl-modules/${TDOM}.tar.bz2
mv tdom ${ALT}


cd ${ALT}/unix
../configure --enable-threads --disable-tdomalloc --prefix=${PREFIX} --exec-prefix=${PREFIX} --with-tcl=${PREFIX}/lib $EXTRA
make install
cd ../extensions/tnc
./configure --enable-threads --disable-tdomalloc --prefix=${PREFIX} --exec-prefix=${PREFIX} --with-tcl=${PREFIX}/lib --with-tdom=${PREFIX}/lib $EXTRA
make install
