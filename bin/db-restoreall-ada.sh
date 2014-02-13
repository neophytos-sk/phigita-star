su - postgres -c '/opt/postgresql/bin/createuser service-phgt-0'
for dbname in geoipdb; do su - service-phgt-0 -c "/opt/postgresql/bin/createdb ${dbname}; /opt/postgresql/bin/createlang plpgsql ${dbname}; /opt/postgresql/bin/pg_restore --no-owner --format=c --dbname=${dbname} /web/data/backup/ada.${dbname}.pg_dump"; done
su - service-phgt-0 -c '/opt/postgresql/bin/vacuumdb --full --analyze --all'
