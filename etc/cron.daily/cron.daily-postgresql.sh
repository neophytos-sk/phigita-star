#!/bin/sh

USER=nsadmin

su - ${USER} -c '/opt/postgresql/bin/pg_dump --no-owner --format=c --file=/web/data/backup/atlas.service-phigita.pg_dump service-phgt-0'
cp /web/data/backup/atlas.service-phigita.pg_dump /web/tmp/

su - ${USER} -c '/opt/postgresql/bin/vacuumdb --analyze bookdb'
su - ${USER} -c '/opt/postgresql/bin/vacuumdb --analyze --full service-phgt-0'

su - ${USER} -c '/usr/bin/visitors /web/log/access.8001.log* > /web/tmp/visitors.8001.html'
