#!/bin/bash
/opt/postgresql/bin/pg_restore --format=c --no-owner -f ${1}.schema --disable-triggers --schema-only ${1}
sed -i.orig "s/public.tsvector/tsvector/g" ${1}.schema
sed -i.orig "s/public.gist_tsvector_ops//g" ${1}.schema
