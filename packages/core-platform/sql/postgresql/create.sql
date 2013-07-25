\i /usr/local/pgsql/share/contrib/_int.sql
\i /usr/local/pgsql/share/contrib/tsearch.sql
\i /usr/local/pgsql/share/contrib/ltree.sql

create schema xo;

\i ltree.sql
\i postgresql.sql
\i lob.sql
--\i acs-logs-create.sql
\i acs-metadata-create.sql
\i acs-objects-create.sql
--\i acs-object-util.sql
\i acs-relationships-create.sql
--\i utilities-create.sql
--\i parties-create.sql
\i parties/create.sql
\i users/create.sql
\i groups/create.sql
-- \i rel-segments-create.sql
-- \i rel-constraints-create.sql
\i permissions/create.sql
-- \i ../../../groups/sql/postgresql/groups-body-create.sql
-- \i rel-segments-body-create.sql
-- \i rel-constraints-body-create.sql

\i security/create.sql
\i site-nodes/create.sql

--\i acs-create.sql
--\i acs-create-2.sql
-- set feedback on

\i mail/create.sql
\i apm/create.sql
\i globalization/create.sql
