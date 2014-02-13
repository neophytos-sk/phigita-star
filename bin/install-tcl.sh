#!/bin/bash


###################################################################

WEBHOME=~nsadmin
source ${WEBHOME}/bin/install-env.sh

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


cd ${WORKDIR}
tar -xzvf ${FILEDIR}/tcl/${TCL}-src.tar.gz
mv ${TCL} ${ALT}

cd ${WORKDIR}
cd ${ALT}/unix


CFLAGS="" ./configure \
    --enable-threads \
    --prefix=${PREFIX} \
    --without-itcl \
    --without-tdbc

# -DSYSTEM_MALLOC is just for tcl8.5.14
#
make CFLAGS_OPTIMIZE="-DSYSTEM_MALLOC -O3" 

make install

ln -sf ${TCLHOME}/bin/tclsh8.? /usr/bin/tclsh
ln -sf ${TCLHOME}/ /opt/tcl
