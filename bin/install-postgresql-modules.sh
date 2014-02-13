#!/bin/bash

###################################################################

WEBHOME=~nsadmin
source ${WEBHOME}/bin/install-env.sh

###################################################################

mkdir -p ${WORKDIR}

### PostgreSQL
cd ${WORKDIR}
cd ${PGSQL}/contrib/tsearch2
make install

cd ${WORKDIR}
cd ${PGSQL}/contrib/ltree
make install


cd ${WORKDIR}
cd ${PGSQL}/contrib/hstore
make install

cd ${WORKDIR}
cd ${PGSQL}/contrib/intarray
make install

cd ${WORKDIR}
cd ${PGSQL}/contrib/intagg
make install

cd ${WORKDIR}
cd ${PGSQL}/contrib/dblink
make install

cd ${WORKDIR}
cd ${PGSQL}/contrib/dict_xsyn
make install

cd ${WORKDIR}
cd ${PGSQL}/contrib/dict_int
make install
