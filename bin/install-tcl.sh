#!/bin/bash


###################################################################

source /web/bin/install-env.sh

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

ln -sf ${TCLHOME}/bin/tclsh8.? /usr/bin/tclsh
ln -sf ${TCLHOME}/ /opt/tcl
