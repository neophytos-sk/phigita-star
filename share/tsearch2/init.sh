initdb -D /usr/local/pgsql-dev/data.el_utf8 âlocale=el_GR.utf8
pg_ctl -D /usr/local/pgsql-dev/data.el_utf8 start
createdb test psql test < /usr/local/pgsql-dev/share/contrib/tsearch2.sql
