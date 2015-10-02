#!/bin/bash

###################################################################

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source ${DIR}/install-env.sh

###################################################################

mkdir -p ${WORKDIR}

PN=postgresql

PKGDIR=$FILEDIR/$PN

### PostgreSQL

if [ "$#" = 0 ]; then
  echo "usage: $0 slot ?locale? ?port?"
  echo "slot is the major.minor part of the version, e.g. 8.4"
  echo "default locale is en_US.UTF-8"
  echo "default port is 5432"
  exit
fi

PGSLOT=$1
PGLOCALE=${2:-"en_US.UTF-8"}
PGPORT=${3:-"5432"}

# Location of configuration files
CONF_DIR="/etc/conf.d"
  
# Where the data directory is located/to be created
DATA_DIR="/var/lib/postgresql/${PGSLOT}/data"
    
# Additional options to pass to initdb.
# See 'man initdb' for available options.
PG_INITDB_OPTS="--locale=$PGLOCALE"

PGHOME=/opt/postgresql-${PGSLOT}/

PGUSER=postgres
PGGROUP=postgres


cd ${WORKDIR}
tar -xjf ${PKGDIR}/postgresql-${PGSLOT}.tar.bz2
cd postgresql-${PGSLOT}*

./configure \
	--prefix=${PGHOME} \
	--enable-thread-safety

make install
cd contrib
make install

# initdb
if [ ! -d $DATA_DIR ]; then

    echo "initdb"
    # cp ${FILEDIR}/tsearch2_data/* ${PGHOME}/share/tsearch_data/
    mkdir -p $DATA_DIR

    newgroup $PGGROUP 70
    newuser $PGUSER 70 /bin/bash /var/lib/postgresql $PGGROUP

    chown $PGUSER:$PGGROUP /var/lib/postgresql/
    chown $PGUSER:$PGGROUP $DATA_DIR

    su - $PGUSER -c "${PGHOME}/bin/initdb -D $DATA_DIR $PG_INITDB_OPTS"
fi


cat << EOF > $CONF_DIR/postgresql-$PGSLOT
PGSLOT=$PGSLOT

PGPORT=$PGPORT

# PostgreSQL's Database Directory
PGDATA=/var/lib/postgresql/$PGSLOT/data

# Logfile path: (NOTE: This must be uid/gid owned by the value of $PGUSER!)
PGLOG=/var/lib/postgresql/$PGSLOT/data/postgresql.log

# Run the PostgreSQL user as:
PGUSER=$PGUSER

# Extra options to run postmaster with.
# If you want to enable TCP/IP for PostgreSQL, add -i to the following:
# PGOPTS="-N 1024 -B 2048 -i"
PGOPTS="-p $PGPORT"
EOF

cp ${PKGDIR}/init.d-postgresql /etc/init.d/postgresql-${PGSLOT}

chmod +x /etc/init.d/postgresql-${PGSLOT}

