#!/bin/bash


###################################################################

WEBHOME=~nsadmin
source ${WEBHOME}/bin/install-env.sh

###################################################################



mkdir -p ${WORKDIR}


cd ${WORKDIR}
tar -xzvf ${FILEDIR}/open-vcdiff/${OPEN_VCDIFF}.tar.gz
cd ${OPEN_VCDIFF}
./configure --prefix=/opt/${OPEN_VCDIFF}
make
make install
rm -f /opt/open-vcdiff
ln -sf /opt/${OPEN_VCDIFF} /opt/open-vcdiff