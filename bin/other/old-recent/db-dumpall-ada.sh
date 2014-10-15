for dbname in {geoipdb,hipdb}; do su - service-phgt-0 -c "/opt/postgresql/bin/pg_dump --no-owner --format=c --file=/web/data/backup/ada.${dbname}.pg_dump ${dbname}"; done
