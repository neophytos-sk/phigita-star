#!/bin/bash

###################################################################

WEBHOME=~nsadmin
source ${WEBHOME}/bin/install-env.sh

###################################################################

mkdir -p ${WORKDIR}

emerge maven-bin

cd ${WORKDIR}
tar -xzvf ${FILEDIR}/${MIME4J}-src.tar.gz
cd ${MIME4J}
mvn package
mvn install
cd /opt/
tar -xzvf ${WORKDIR}/${MIME4J}/target/${MIME4J}-bin.tar.gz

