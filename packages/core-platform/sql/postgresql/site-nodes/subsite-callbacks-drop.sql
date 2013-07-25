-- /packages/acs-subsite/sql/subsite-group-callbacks-drop.sql

-- Drops the subsite group callbacks data model

-- Copyright (C) 2001 ArsDigita Corporation
-- @author Michael Bryzek (mbryzek@arsdigita.com)
-- @creation-date 2001-02-21

-- $Id: subsite-callbacks-drop.sql,v 1.1.1.1 2002/11/22 09:47:32 nkd Exp $

-- This is free software distributed under the terms of the GNU Public
-- License.  Full text of the license is available from the GNU Project:
-- http://www.fsf.org/copyleft/gpl.html

select drop_package('subsite_callback');
drop table subsite_callbacks;
