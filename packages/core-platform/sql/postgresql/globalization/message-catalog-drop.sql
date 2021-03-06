--
-- packages/language/sql/language-drop.sql
--
-- @author davis@xarg.net
-- @creation-date 2000-09-10
-- @cvs-id $Id: message-catalog-drop.sql,v 1.2 2002/07/10 11:57:19 jeffd Exp $
--

-- drop the timezone stuff
drop index tz_data_idx2;
drop index tz_data_idx1;
drop table tz_data;
drop function lc_time_utc_to_local;
drop function lc_time_local_to_utc;

-- drop the lang stuff
drop table lang_translation_registry;
drop table lang_translate_columns;
drop table lang_messages;

-- This might fail if the data model includes other multilingual tables
-- that reference ad_locales. Really need to cascade here to ensure
-- it goes away, but that is dangerous.
drop table ad_locales;
