#!/bin/bash

WEBHOME=/web
HOSTNAME=`hostname`

if [ "$HOSTNAME" == "$LIVEHOST" ]; then
    echo "DO NOT RUN ON ANY OTHER HOST, ONLY FOR development machines (epimetheus,megistias)"
    exit
fi

LIVEHOST=atlas

FILE1=/web/data/backup/${LIVEHOST}.service-phigita.pg_dump
FILE2=/web/data/backup/${LIVEHOST}.service-phigita.pg_dump.bz2
#if [ "$FILE1" -nt "$FILE2" ];then
    echo "copy (scp) db dump file"
    scp -i ${WEBHOME}/files/SSH/XO-${LIVEHOST}/id_dsa root@${LIVEHOST}:$FILE1 /web/servers-data/
    scp -r -i ${WEBHOME}/files/SSH/XO-${LIVEHOST}/id_dsa root@${LIVEHOST}:/web/data/cbt_db/ /web/data/
#fi

PGSQL_STATUS=`/etc/init.d/postgresql status`
if [ $(expr match "$PGSQL_STATUS" ".*status:\s*started.*") -eq 0 ]; then
    echo "start postgresql"
    /etc/init.d/postgresql start
    for i in {1..5}; do
	echo "sleeping... $i"
	sleep 1
    done
fi

#if [ "$FILE1" -nt "$FILE2" ];then
    echo "pg_restore db dump file"
    su - postgres -c "/opt/postgresql/bin/dropdb service-phgt-0;
    /opt/postgresql/bin/createdb service-phgt-0;
    /opt/postgresql/bin/psql -f /opt/postgresql/share/contrib/int_aggregate.sql service-phgt-0;
    /opt/postgresql/bin/pg_restore --no-owner --format=c --dbname=service-phgt-0 /web/servers-data/${LIVEHOST}.service-phigita.pg_dump"
    echo "bzip2 db dump file"
    bzip2 -f "/web/servers-data/${LIVEHOST}.service-phigita.pg_dump"
#fi
