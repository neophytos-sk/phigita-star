#!/bin/bash

if [ $# -lt 1 ]; then
    echo "Usage: $0 output_filename"
    exit
fi

FILENAME=$1
OPTS="-U postgres -q -t -A -o $FILENAME"

echo "TODO: REMOVE limit"
/opt/postgresql/bin/psql ${OPTS} -c "select ean13,coalesce(to_tsvector(title),'') || coalesce(to_tsvector(description),'') as ts_vector from xo.xo__book order by ean13;" bookdb
#/opt/postgresql/bin/psql ${OPTS} -c "select ean13,ts_vector from xo.xo__book limit 50000;" bookdb
#/opt/postgresql/bin/psql ${OPTS} -c "select ean13,ts_vector from xo.xo__book;" bookdb
