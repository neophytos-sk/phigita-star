#!/bin/bash


###################################################################

WEBHOME=~nsadmin
source ${WEBHOME}/bin/install-env.sh

###################################################################


mkdir -p ${WORKDIR}

USE="threadsafe" emerge -av =dev-lang/spidermonkey-1.7.0
TCLJSCOMPACT=naviserver-jscompact-2008-11-28
cd ${WORKDIR}
tar -xjvf ${FILEDIR}/${TCLJSCOMPACT}.tar.bz2
cd ${TCLJSCOMPACT}
./make_jscompact
cp libjscompact0.1.so /opt/naviserver/bin/
