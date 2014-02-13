#!/bin/bash

###################################################################

WEBHOME=~nsadmin
source ${WEBHOME}/bin/install-env.sh

###################################################################

mkdir -p ${WORKDIR}

emerge -av scons v8 libpcap

cd ${WORKDIR}
tar -xzvf ${FILEDIR}/mongodb/${MONGODB}.tar.gz
cd ${MONGODB}

mkdir /web/data/mongodb/
scons --usev8 --prefix=${MONGODB_HOME} --full install

