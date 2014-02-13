#!/bin/bash


###################################################################

WEBHOME=~nsadmin
source ${WEBHOME}/bin/install-env.sh

###################################################################


mkdir -p ${WORKDIR}


cd ${WORKDIR}
tar -xzvf ${FILEDIR}/pgRouting-1.02.tgz
cd pgrouting
cmake -D POSTGRESQL_INCLUDE_DIR=${PGHOME}/include/server/ -D POSTGRESQL_LIBRARIES=${PGHOME}/lib/ .
make
make install
mv /usr/share/postlbs/ ${PGHOME}/share/