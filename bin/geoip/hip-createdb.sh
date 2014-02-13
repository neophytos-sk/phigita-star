#!/bin/bash
/web/bin/createdb hipdb
/web/bin/convert-hip-mysql-to-sql.sh | psql hipdb
/web/bin/hip-generate-index.sh | psql hipdb
