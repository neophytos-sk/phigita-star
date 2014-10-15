for dbname in {service-phgt-0,agendadb,echodb,bookdb}; do su - service-phgt-0 -c "/opt/postgresql/bin/pg_dump --no-owner --format=c --file=/web/data/backup/aias.${dbname}.pg_dump ${dbname}"; done
