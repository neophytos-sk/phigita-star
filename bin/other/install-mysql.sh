#!/bin/bash

###################################################################

WEBHOME=/web
source ${WEBHOME}/bin/install-env.sh

###################################################################

mkdir -p ${WORKDIR}

cd ${WORKDIR}
${WEBHOME}/bin/unpack.sh ${FILEDIR}/dev-db/mysql/${MYSQL}.tar.gz
cd ${MYSQL}
cmake -DCMAKE_INSTALL_PREFIX=${MYSQL_HOME} .
make
make install

groupadd mysql
useradd -g mysql mysql

mkdir -p /var/lib/mysql/data
chown -R mysql:mysql /var/lib/mysql