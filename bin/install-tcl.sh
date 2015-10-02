#!/bin/bash


###################################################################

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source ${DIR}/install-env.sh

###################################################################


if [ $# -lt 1 ]; then 
    PREFIX=${TCLHOME}
    ALT=local-${TCL}
else
    PREFIX=${1}
    ALT=${2}${TCL}
fi

echo "PREFIX=$PREFIX ALT=$ALT"


mkdir -p ${WORKDIR}

cd $WORKDIR

tar -xzf ${FILEDIR}/tcl/${TCL}-src.tar.gz -C ${WORKDIR}

mv $TCL $ALT

cd ${ALT}/unix

# generated Makefile compiles all packages by default
rm -rf ../pkgs/{itcl*,sqlite*,tdbc*}

CFLAGS="" ./configure \
    --enable-threads \
    --prefix=${PREFIX} \
    --without-itcl \
    --without-sqlite \
    --without-tdbc \
    --without-tdbcmysql \
    --without-tdbcpostgres \
    --without-tdbcsqlite

# -DSYSTEM_MALLOC is just for tcl8.5.14
#
# make CFLAGS_OPTIMIZE="-DSYSTEM_MALLOC -O3"

make

make install

ln -sf `ls ${PREFIX}/bin/tclsh*` /usr/bin/tclsh
ln -sf ${PREFIX}/ /opt/tcl
