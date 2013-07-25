-- Drop the cal_item object and all related tables, 
-- views, and package
--
-- @author Gary Jin (gjin@arsdigita.com)
-- @creation-date Nov 17, 2000
-- @cvs-id $Id: cal-item-drop.sql,v 1.4 2002/03/08 22:29:24 donb Exp $
--

-- ported by Lilian Tong (tong@ebt.ee.usyd.edu.au)

---------------------------------------------------------- 
--  drop cal_item
----------------------------------------------------------

-- drop functions
drop function cal_item__new (
    integer,
    integer,
    varchar,
    varchar,
    boolean,
    varchar,
    integer,
    integer,
    integer,
    varchar,
    integer,
    timestamp,
    integer,
    varchar
);

drop function cal_item__delete (integer);

drop function cal_item__name (integer);

drop function cal_item__on_which_calendar (integer);

drop table cal_items;
--drop objects
delete from acs_objects where object_type='cal_item';

--drop table
--drop table cal_items;


  -- drop attributes and acs_object_type
begin;
  -- drop attibutes
	select acs_attribute__drop_attribute (
           'cal_item',
           'on_which_calendar'
        );
  
  --drop type
	select acs_object_type__drop_type(
           'cal_item',
           'f'
        );  
end;


--  -- drop attributes and acs_object_type
--begin
--  acs_attribute.drop_attribute ('cal_item','on_which_calendar');
--  acs_object_type.drop_type ('cal_item');
--end;
--/
--show errors
--
--
--  -- drop package         
--drop package cal_item;
--
--
--  -- drop table  
--drop table cal_items;


