#!/bin/bash

###################################################################

WEBHOME=~nsadmin
source ${WEBHOME}/bin/install-env.sh

###################################################################

mkdir -p ${WORKDIR}

### PostgreSQL
cd ${WORKDIR}
tar -xzvf ${FILEDIR}/${PGTCL}.tar.gz
cd ${PGTCL}
./configure --enable-threads --with-tcl=/opt/naviserver/lib --with-tcl-include=/opt/naviserver/include --prefix /opt/naviserver/ --with-postgres-include=/opt/postgresql/include/ --with-postgres-lib=/opt/postgresql/lib/
make PKG_CFLAGS="-DHAVE_TCL_NEWDICTOBJ=1"
make install