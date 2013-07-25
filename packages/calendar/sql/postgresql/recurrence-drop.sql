-- packages/acs-events/sql/recurrence-drop.sql
--
-- Drop support for temporal recurrences
--
-- $Id: recurrence-drop.sql,v 1.1 2001/07/13 02:51:01 jowells Exp $

-- drop package recurrence;
select drop_package('recurrence');

drop table recurrences;
drop table recurrence_interval_types;

drop sequence recurrence_sequence;
drop view recurrence_seq;
