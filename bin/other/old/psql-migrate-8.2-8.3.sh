#!/bin/bash

/opt/postgresql/bin/psql -f /web/files/ts_cfg_greek.sql ${2}
/opt/postgresql/bin/psql -f /opt/postgresql/share/contrib/hstore.sql ${2}
/opt/postgresql/bin/psql -f /opt/postgresql/share/contrib/ltree.sql ${2}
/opt/postgresql/bin/psql -f /opt/postgresql/share/contrib/_int.sql ${2}
/opt/postgresql/bin/psql -f /opt/postgresql/share/contrib/int_aggregate.sql ${2}
/opt/postgresql/bin/psql -f ${1}.schema ${2}
/opt/postgresql/bin/pg_restore --format=c --no-owner --data-only --disable-triggers -d ${2} ${1}
/opt/postgresql/bin/psql -f ${1}.schema.indexes ${2}