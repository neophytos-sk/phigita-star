-- packages/acs-events/sql/postgres/oracle-compat-drop.sql
--
-- Drop functions that ease porting from Postgres to Oracle
--
-- @author jowell@jsabino.com
-- @creation-date 2001-06-26
--
-- $Id: oracle-compat-drop.sql,v 1.2 2003/05/17 09:46:57 jeffd Exp $

drop function dow_to_int(varchar);
drop function next_day(timestamptz,varchar);
drop function add_months(timestamptz,integer);
drop function last_day(timestamptz);
drop function to_interval(integer,varchar);

