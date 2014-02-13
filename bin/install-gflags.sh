#!/bin/bash

###################################################################

WEBHOME=~nsadmin
source ${WEBHOME}/bin/install-env.sh

###################################################################




mkdir -p ${WORKDIR}
cp -R /web/cvs/google-gflags-read-only google-gflags
cd google-gflags
./autogen.sh
./configure && make && make install
