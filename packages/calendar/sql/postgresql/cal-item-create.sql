-- Create the cal_item object
--
-- @author Gary Jin (gjin@arsdigita.com)
-- @creation-date Nov 17, 2000
-- @cvs-id $Id: cal-item-create.sql,v 1.10 2002/07/22 21:46:19 ben Exp $
--

-- ported by Lilian Tong (tong@ebt.ee.usyd.edu.au)

---------------------------------------------------------- 
--  cal_item_ojbect 
----------------------------------------------------------

CREATE OR REPLACE FUNCTION inline_0 ()
RETURNS integer AS '
begin
    PERFORM acs_object_type__create_type (
	''cal_item'',		-- object_type
 	''Calendar Item'',	-- pretty_name
	''Calendar Items'',	-- pretty_plural
	''acs_event'',		-- supertype
	''cal_items'',		-- table_name
	''cal_item_id'',	-- id_column
	null,			-- package_name
	''f'',			-- abstract_p
	null,			-- type_extension_table
	null			-- name_method
	);
    return 0;
end;' LANGUAGE 'plpgsql';

SELECT inline_0 (); 

DROP FUNCTION inline_0 ();

CREATE OR REPLACE FUNCTION inline_1 () 
RETURNS integer AS '
begin
    PERFORM acs_attribute__create_attribute (
	''cal_item'',		-- object_type
	''on_which_calendar'',	-- attribute_name
	''integer'',		-- datatype
	''On Which Calendar'',	-- pretty_name
	''On Which Calendars'',	-- pretty_plural
	null,			-- table_name (default)
  	null,			-- column_name (default)
	null,			-- default_value (default)
	1,			-- min_n_values (default)
	1,			-- max_n_values (default)
	null,			-- sort_order (default)
	''type_specific'',	-- storage (default)
 	''f''			-- static_p (default)
 	);
    return 0;
end;' LANGUAGE 'plpgsql';

SELECT inline_1 ();

DROP FUNCTION inline_1 ();


--  -- Each cal_item has the super_type of ACS_EVENTS
--  -- Table cal_items supplies additional information

CREATE TABLE cal_items (
          -- primary key
        cal_item_id	  integer 
			  constraint cal_item_cal_item_id_fk 
                          references acs_events
                          constraint cal_item_cal_item_id_pk 
                          primary key,            
          -- a references to calendar
          -- Each cal_item is owned by one calendar
        on_which_calendar integer
                          constraint cal_item_which_cal_fk
                          references calendars
                          on delete cascade,
        item_type_id            integer,
        constraint cal_items_type_fk
        foreign key (on_which_calendar, item_type_id)
        references cal_item_types(calendar_id, item_type_id)
);

comment on table cal_items is '
        Table cal_items maps the ownership relation between 
        an cal_item_id to calendars. Each cal_item is owned
        by a calendar
';

comment on column cal_items.cal_item_id is '
        Primary Key
';

comment on column cal_items.on_which_calendar is '
        Mapping to calendar. Each cal_item is owned
        by a calendar
';

 
-------------------------------------------------------------
-- create package cal_item
-------------------------------------------------------------

CREATE OR REPLACE FUNCTION cal_item__new (
    integer,	-- cal_item_id		cal_items.cal_item_id%TYPE
    integer,	-- on_which_calendar	calenders.calendar_id%TYPE
    text,	-- name			acs_activities.name%TYPE
    text,	-- description		acs_activities.description%TYPE
    boolean,	-- html_p		acs_activities.html_p%TYPE
    text,	-- status_summary	acs_activities.status_summary%TYPE
    integer,	-- timespan_id		acs_events.timespan_id%TYPE
    integer,	-- activity_id		acs_events.activity_id%TYPE
    integer,	-- recurrence_id	acs_events.recurrence_id%TYPE
    text,	-- object_type		acs_objects.object_type%TYPE
    integer,	-- context_id		acs_objects.context_id%TYPE
    timestamptz,	-- createion_date	acs_objects.creation_date%TYPE
    integer,	-- creation_user	acs_objects.creation_user%TYPE
    text	-- creation_ip		acs_objects.creation_ip%TYPE
)
RETURNS integer AS '
declare
    new__cal_item_id		alias for $1;	-- default null
    new__on_which_calendar	alias for $2;	-- default null
    new__name			alias for $3;	
    new__description		alias for $4;	
    new__html_p		        alias for $5;	-- default null
    new__status_summary		alias for $6;	-- default null
    new__timespan_id		alias for $7;	-- default null
    new__activity_id		alias for $8;	-- default null
    new__recurrence_id		alias for $9;	-- default null
    new__object_type		alias for $10;	-- default "cal_item"
    new__context_id		alias for $11;	-- default null
    new__creation_date		alias for $12;	-- default now()
    new__creation_user		alias for $13;	-- default null
    new__creation_ip		alias for $14;	-- default null
    v_cal_item_id		cal_items.cal_item_id%TYPE;

begin
    v_cal_item_id := acs_event__new(
	new__cal_item_id,	-- event_id
	new__name,		-- name
	new__description,	-- description
        new__html_p,		-- html_p
        new__status_summary,    -- status_summary
	new__timespan_id,	-- timespan_id
	new__activity_id,	-- activity_id
	new__recurrence_id,	-- recurrence_id
	new__object_type,	-- object_type
	new__creation_date,	-- creation_date
	new__creation_user,	-- creation_user
	new__creation_ip,	-- creation_ip
	new__context_id		-- context_id
	);

    insert into cal_items
	(cal_item_id, on_which_calendar)
    values          
	(v_cal_item_id, new__on_which_calendar);

    return v_cal_item_id;

end;' LANGUAGE 'plpgsql';


------------------------------------------------------------
-- the delete operation
------------------------------------------------------------

CREATE OR REPLACE FUNCTION cal_item__delete (
	integer
)
RETURNS integer AS '
declare
    delete__cal_item_id		alias for $1;
begin
	-- Erase the cal_item associated with the id
    delete from 	cal_items
    where		cal_item_id = delete__cal_item_id;
 	
	-- Erase all the priviledges
    delete from 	acs_permissions
    where		object_id = delete__cal_item_id;

    PERFORM acs_event__delete(delete__cal_item_id);

    return 0;

end;' LANGUAGE 'plpgsql';


CREATE OR REPLACE FUNCTION cal_item__delete_all (
	integer
)
RETURNS integer AS '
declare
    delete__recurrence_id		alias for $1;
    v_event                             RECORD;
begin
    for v_event in 
	select event_id from acs_events
        where recurrence_id= delete__recurrence_id
    LOOP
        PERFORM cal_item__delete(v_event.event_id);
    END LOOP;

    PERFORM recurrence__delete(delete__recurrence_id);

    return 0;

end;' LANGUAGE 'plpgsql';


-------------------------------------------------------------
-- the name function
-------------------------------------------------------------

    -- function to return the name of the cal_item
CREATE OR REPLACE FUNCTION cal_item__name (
    integer
)
RETURNS varchar AS '
declare 
    name__cal_item_id	alias for $1;
    v_name	acs_activities.name%TYPE;
begin
    select  name 
    into    v_name
    from    acs_activities
    where   activity_id = 
    (
	select  activity_id
        from    acs_events
        where   event_id = name__cal_item_id
    );
               
    return v_name;

end;' LANGUAGE 'plpgsql';


---------------------------------------------------------------
-- the on_which_calendar function
---------------------------------------------------------------

    -- function to return the calendar that owns the cal_item
CREATE OR REPLACE FUNCTION cal_item__on_which_calendar (
    integer
)
RETURNS integer AS '
declare
    on_which_calendar__cal_item_id	alias for $1;
    v_calendar_id			calendars.calendar_id%TYPE;
begin
    select  on_which_calendar
    into    v_calendar_id
    from    cal_items
    where   cal_item_id = on_which_calendar__cal_item_id;
        
    return  v_calendar_id;

end;' LANGUAGE 'plpgsql';

