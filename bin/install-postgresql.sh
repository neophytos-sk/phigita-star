#!/bin/bash

###################################################################

WEBHOME=~nsadmin
source ${WEBHOME}/bin/install-env.sh

###################################################################

mkdir -p ${WORKDIR}

### PostgreSQL

COMPILE="y"
if [ -d ${PGHOME} ]; then
    COMPILE=""
    until [ "$COMPILE" == "y" ] || [ "$COMPILE" == "n" ]; do
    echo "${PGHOME} already exists - Recompile (y/n)?"
	read COMPILE
    done
fi

if [ "$COMPILE" == "y" ]; then 
    cd ${WORKDIR}
    tar -xjvf ${FILEDIR}/postgresql/${PGSQL}.tar.bz2
    cd ${PGSQL}
    ./configure --prefix=${PGHOME} --enable-thread-safety
    make install
    cd contrib
    make install
fi

ACTION="i" ;# default action: initdb
if [ -d /var/lib/postgresql/data ]; then
    PG_VERSION=`cat /var/lib/postgresql/data/PG_VERSION`
    ACTION=""
    until [ "$ACTION" = "i" ] || [ "$ACTION" = "m" ] || [ "$ACTION" = "x" ]; do
	echo "current db version is $PG_VERSION - Action (i for initdb, m for migrate, x for nothing)?"
	read ACTION
    done
fi

# initdb
if [ "$ACTION" == "i" ]; then 

    echo "initdb"
    cp ${FILEDIR}/tsearch2_data/* ${PGHOME}/share/tsearch_data/
    mkdir -p /var/lib/postgresql/data
    useradd -d /var/lib/postgresql postgres
    chown postgres /var/lib/postgresql/
    chown postgres /var/lib/postgresql/data
    su - postgres -c "${PGHOME}/bin/initdb -D /var/lib/postgresql/data --locale=el_GR.UTF8"
fi

# migrate
if [ "$ACTION" == "m" ]; then 

    # check free disk space
    # pg_dump all databases
    # mv data dir to data.old
    # initdb
    echo "migrate"

fi

if [ "$COMPILE" == "y" ]; then
    cp ${FILEDIR}/conf.d-postgresql /etc/conf.d/postgresql
    cp ${FILEDIR}/init.d-postgresql /etc/init.d/postgresql
    cat /etc/init.d/postgresql | sed -e "s/usr\/bin/opt\/${PGSQL}\/bin/g" > /etc/init.d/postgresql.new
    mv /etc/init.d/postgresql /web/tmp/init.d-postgresql.old; mv /etc/init.d/postgresql.new /etc/init.d/postgresql
    chmod +x /etc/init.d/postgresql
    cd /opt/
    ln -s ${PGHOME} postgresql
fi