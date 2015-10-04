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

CMD="emerge -av"

mkdir -p ${WORKDIR}

# htmltidy
cd ${WORKDIR}
tar -xjvf ${FILEDIR}/app-text/htmltidy/tidy-html5.tar.bz2
cd tidy-html5/build/cmake
cmake ../../ -DCMAKE_INSTALL_PREFIX=$PREFIX -DCMAKE_C_FLAGS=-fPIC
make install

# unac
# make sure iconv portage package is not installed
emerge --ask -C iconv

#cd ${WORKDIR}
#tar -xjvf ${FILEDIR}/app-text/unac/unac-1.8.0.tar.bz2
#cd unac-1.8.0
# ./autogen.sh
#./configure --enable-threads --prefix=/opt/naviserver/
#make install
# uses patches from the debian project
emerge -av unac

# app-text/libexttextcat-3.2.0
# ACCEPT_KEYWORDS="~amd64" ${CMD} libexttextcat
P="libexttextcat-3.2.0"
cd ${WORKDIR}
tar -xjvf ${FILEDIR}/app-text/${P}.tar.bz2
cd ${P}
./configure --prefix=${PREFIX}
make install
