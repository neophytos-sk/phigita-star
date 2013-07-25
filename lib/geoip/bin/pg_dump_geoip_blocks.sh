#!/bin/bash

if [ $# -lt 1 ]; then
    echo "Usage: $0 output_filename"
    exit
fi

FILENAME=$1
OPTS="-U postgres -q -t -A -o $FILENAME"

#/opt/postgresql/bin/psql ${OPTS} -c "select start_ip_num, end_ip_num-start_ip_num as end_ip_diff,location_id from blocks;" geoipdb
/opt/postgresql/bin/psql ${OPTS} -c "select start_ip_num, end_ip_num,location_id from blocks;" geoipdb
