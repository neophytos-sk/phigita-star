 /opt/postgresql/bin/pg_restore -U postgres -h localhost --format=c --no-owner --dbname=geoipdb /web/servers-data/ada.geoipdb.pg_dump 
 /opt/postgresql/bin/pg_restore -U postgres -h localhost --format=c --no-owner --dbname=bookdb /web/servers-data/aias.bookdb.pg_dump
 /opt/postgresql/bin/psql -U postgres -h localhost -f /opt/postgresql/share/contrib/postgis.sql agendadb
 /opt/postgresql/bin/pg_restore -U postgres -h localhost --format=c --no-owner --dbname=agendadb /web/servers-data/aias.agendadb.pg_dump