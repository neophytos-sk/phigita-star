#!/bin/bash


###################################################################

WEBHOME=~nsadmin
source ${WEBHOME}/bin/install-env.sh
PN=openstreetmap
###################################################################


mkdir -p ${WORKDIR}

### PostgreSQL
cd ${WORKDIR}
tar -xjvf ${FILEDIR}/${PN}/${OSM2PGSQL}.tar.bz2
cd ${OSM2PGSQL}

export PATH=/opt/postgresql/bin/:$PATH
make
mkdir -p usr/bin
make install DESTDIR=$PWD
mkdir -p /opt/${PN}/bin
cp usr/bin/* /opt/${PN}/bin
cp default.style /opt/${PN}/