#!/bin/bash

WEBHOME=/web
HOSTNAME=`hostname`

LIVEHOST=atlas

if [ "$HOSTNAME" = "atlas" ]; then
    echo "DO NOT RUN ON LIVEHOST=${LIVEHOST}"
    exit
fi

FILE1=/web/data/backup/${LIVEHOST}.service-phgt-0.pg_dump
FILE2=/web/data/backup/${LIVEHOST}.service-phgt-0.pg_dump.bz2
#if [ "$FILE1" -nt "$FILE2" ];then
    echo "copy (scp) db dump file"
    scp -i ${WEBHOME}/files/SSH/XO-${LIVEHOST}/id_dsa root@${LIVEHOST}:$FILE1 /web/servers-data/
#fi
