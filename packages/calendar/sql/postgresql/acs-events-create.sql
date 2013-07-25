-- packages/acs-events/sql/acs-events-create.sql
--
-- @author smeeks@arsdigita.com
-- @creation-date 2000-11-16
-- @cvs-id $Id: acs-events-create.sql,v 1.6 2003/05/17 09:46:57 jeffd Exp $

-- Create the objects and packages for the ACS Events service

\i oracle-compat-create.sql
\i activity-create.sql
\i timespan-create.sql
\i recurrence-create.sql

-- Sequence for event tables that are not subclasses of acs_object
create sequence acs_events_sequence start 1;
create view acs_events_seq as select nextval('acs_events_sequence') as nextval from dual;

create function inline_0 ()
returns integer as '
declare 
    attr_id acs_attributes.attribute_id%TYPE; 
begin

    -- Event object     
    PERFORM acs_object_type__create_type ( 
        ''acs_event'',	-- object_type
        ''ACS Event'',	-- pretty_name
        ''ACS Events'',	-- pretty_plural
        ''acs_object'', -- supertype
        ''ACS_EVENTS'',	-- table_name
        ''EVENT_ID'',	-- id_column
        null,		-- package_name (default)
        ''f'',		-- abstract_p (default)
        null,		-- type_extension_table (default)
        null		-- name_method (default)
    ); 

   -- Event attributes
    attr_id := acs_attribute__create_attribute ( 
        ''acs_event'',       -- object_type
        ''timespan_id'',     -- attribute_name
        ''integer'',	     -- datatype
        ''Timespan'',	     -- pretty_name
        ''Timespans'',	     -- pretty_plural
        null,		     -- table_name (default)
        null,		     -- column_name (default)
        null,		     -- default_value (default)
        1,		     -- min_n_values (default)
        1,		     -- max_n_values (default)
        null,		     -- sort_order (default)
        ''type_specific'',   -- storage (default)
        ''f''		     -- static_p (default)
    );
     attr_id := acs_attribute__create_attribute ( 
        ''acs_event'',       -- object_type
        ''activity_id'',     -- attribute_name
        ''integer'',	     -- datatype
        ''Activity'',	     -- pretty_name
        ''Activities'',	     -- pretty_plural
        null,		     -- table_name (default)
        null,		     -- column_name (default)
        null,		     -- default_value (default)
        1,		     -- min_n_values (default)
        1,		     -- max_n_values (default)
        null,		     -- sort_order (default)
        ''type_specific'',   -- storage (default)
        ''f''		     -- static_p (default)
    );
    attr_id := acs_attribute__create_attribute ( 
        ''acs_event'',       -- object_type
        ''recurrence_id'',   -- attribute_name
        ''integer'',	     -- datatype
        ''Recurrence'',	     -- pretty_name
        ''Recurrences'',     -- pretty_plural
        null,		     -- table_name (default)
        null,		     -- column_name (default)
        null,		     -- default_value (default)
        1,		     -- min_n_values (default)
        1,		     -- max_n_values (default)
        null,		     -- sort_order (default)
        ''type_specific'',   -- storage (default)
        ''f''		     -- static_p (default)
    ); 
    attr_id := acs_attribute__create_attribute ( 
        ''acs_event'',	     -- object_type
        ''name'',	     -- attribute_name
        ''string'',	     -- datatype
        ''Name'',	     -- pretty_name
        ''Names'',	     -- pretty_plural
        null,		     -- table_name (default)
        null,		     -- column_name (default)
        null,		     -- default_value (default)
        1,		     -- min_n_values (default)
        1,		     -- max_n_values (default)
        null,		     -- sort_order (default)
        ''type_specific'',   -- storage (default)
        ''f''		     -- static_p (default)
    ); 
    attr_id := acs_attribute__create_attribute ( 
        ''acs_event'',	     -- object_type
        ''description'',     -- attribute_name
        ''string'',	     -- datatype
        ''Description'',     -- pretty_name
        ''Descriptions'',    -- pretty_plural
        null,		     -- table_name (default)
        null,		     -- column_name (default)
        null,		     -- default_value (default)
        1,		     -- min_n_values (default)
        1,		     -- max_n_values (default)
        null,		     -- sort_order (default)
        ''type_specific'',   -- storage (default)
        ''f''		     -- static_p (default)
    ); 
    attr_id := acs_attribute__create_attribute ( 
        ''acs_event'',	     -- object_type
        ''status_summary'',  -- attribute_name
        ''string'',	     -- datatype
        ''Status Summary'',  -- pretty_name
        ''Status Summaries'', -- pretty_plural
        null,		     -- table_name (default)
        null,		     -- column_name (default)
        null,		     -- default_value (default)
        1,		     -- min_n_values (default)
        1,		     -- max_n_values (default)
        null,		     -- sort_order (default)
        ''type_specific'',   -- storage (default)
        ''f''		     -- static_p (default)
    ); 
    attr_id := acs_attribute__create_attribute ( 
        ''acs_event'',	     -- object_type
        ''html_p'',	     -- attribute_name
        ''string'',	     -- datatype
        ''HTML?'',	     -- pretty_name
        null,		     -- pretty_plural
        null,		     -- table_name (default)
        null,		     -- column_name (default)
        null,		     -- default_value (default)
        1,		     -- min_n_values (default)
        1,		     -- max_n_values (default)
        null,		     -- sort_order (default)
        ''type_specific'',   -- storage (default)
        ''f''		     -- static_p (default)
    ); 
    attr_id := acs_attribute__create_attribute ( 
        ''acs_event'',         -- object_type
        ''related_link_url'',  -- attribute_name
        ''string'',	       -- datatype
        ''Related Link URL'',  -- pretty_name
        ''Related Link URLs'', -- pretty_plural
        null,		       -- table_name (default)
        null,		       -- column_name (default)
        null,		       -- default_value (default)
        1,		       -- min_n_values (default)
        1,		       -- max_n_values (default)
        null,		       -- sort_order (default)
        ''type_specific'',     -- storage (default)
        ''f''		       -- static_p (default)
    ); 
    attr_id := acs_attribute__create_attribute ( 
        ''acs_event'',          -- object_type
        ''related_link_text'',  -- attribute_name
        ''string'',		-- datatype
        ''Related Link Text'',  -- pretty_name
        ''Related Link Texts'', -- pretty_plural
        null,			-- table_name (default)
        null,			-- column_name (default)
        null,			-- default_value (default)
        1,			-- min_n_values (default)
        1,			-- max_n_values (default)
        null,			-- sort_order (default)
        ''type_specific'',	-- storage (default)
        ''f''			-- static_p (default)
    ); 
    attr_id := acs_attribute__create_attribute ( 
        ''acs_event'',		        -- object_type
        ''redirect_to_rel_link_p'',     -- attribute_name
        ''string'',			-- datatype
        ''Redirect to Related Link?'',  -- pretty_name
        null,				-- pretty_plural
        null,				-- table_name (default)
        null,				-- column_name (default)
        null,				-- default_value (default)
        1,				-- min_n_values (default)
        1,				-- max_n_values (default)
        null,				-- sort_order (default)
        ''type_specific'',		-- storage (default)
        ''f''				-- static_p (default)
    ); 

    return 0;

end;' language 'plpgsql';

-- Do the transaction, then clean up
select inline_0 ();
drop function inline_0 ();

-- Events table
create table acs_events (
    event_id            integer
                        constraint acs_events_fk references acs_objects(object_id) on delete cascade
                        constraint acs_events_pk primary key,
    --
    -- Need additional columns for attributes not inherited from activity, e.g.
    -- activity.name = "Bootcamp" and event.name = "December Bootcamp"
    --
    -- The Event API supports methods to retrieve name/description from 
    -- either the event (if defined) or the underlying activity (if not defined)
    --
    -- acs_event__get_name() 
    -- acs_event__get_description()
    -- acs_event__get_html_p()
    -- acs_event__get_status_summary()
    --
    name                varchar(255),
    description         text,
    --
    -- is the event description written in html?
    html_p              boolean,
    status_summary	varchar(255),
    --
    -- The following three columns encapsulate the remaining attributes of an Event: 
    -- the activity that takes place during the event, its timespan (a collection of time 
    -- intervals during which the event occurs), and an optional recurrence specification 
    -- that identifies how events repeat in time.
    --
    activity_id         integer
                        constraint acs_events_activity_id_fk
                        references acs_activities on delete set null,
    --
    -- Can't reference timespans since it doesn't have a primary key
    -- When referencing, need to call timespan.exists_p in case timespan
    -- was deleted out from under event.
    --
    timespan_id         integer,
    recurrence_id       integer
                        constraint acs_events_recurrence_id_fk
                        references recurrences,
    --
    -- a link which points to a page related to the event
    -- this could be either additional detail or a substitution
    -- for the link in some application view, e.g. drill-down from
    -- calendar.
    --
    related_link_url    text,  
    related_link_text   text,
    --
    -- Interpretation of this column is application dependent, but it is
    -- suggested that if this is 't', then related_link_{url|text} should be
    -- used as the link in summary views in an application.  Otherwise, 
    -- related_link_{url|text} should be available in a detail view
    -- of the event.
    redirect_to_rel_link_p  boolean
);



-- This is important to prevent locking on update of master table.
-- See  http://www.arsdigita.com/bboard/q-and-a-fetch-msg.tcl?msg_id=000KOh
create index acs_events_activity_id_ids on acs_events(activity_id);

-- This is useful for looking up instances of an event
create index acs_events_recurrence_id_idx on acs_events(recurrence_id);

comment on table acs_events is '
    A relationship between a time span and an activity.
';

comment on column acs_events.name is '
        The name of the event.
';

comment on column acs_events.description is '
        The description of the event.
';

comment on column acs_events.html_p is '
        Whether or not the description is in HTML.
';

comment on column acs_events.status_summary is '
        Additional information to display along with the name.
';

comment on column acs_events.timespan_id is '
    The time span associated with this event.
';

comment on column acs_events.activity_id is '
    The activity associated with this event.
';

comment on column acs_events.recurrence_id is '
    A description of how this event recurs.  If null, then this event does
    not recur.
';

-- A table to create associations between events and parties
create table acs_event_party_map (
    event_id        integer
                    constraint acs_evnt_party_map_evnt_id_fk
                    references acs_events on delete cascade,
    party_id        integer
                    constraint acs_evnt_party_map_party_id_fk
                    references parties on delete cascade,
    constraint acs_evnt_party_map_pk primary key(event_id, party_id)
);

comment on table acs_event_party_map is '
        Maps a many-to-many relationship between events and parties.
';

-- ACS Event Views

-- This view makes the temporal information easier to access
create view acs_events_dates as
select e.*, 
       start_date, 
       end_date
from   acs_events e,
       timespans s,
       time_intervals t
where  e.timespan_id = s.timespan_id
and    s.interval_id = t.interval_id;

-- Postgres is very strict: we must specify 'comment on view', if not a real table
comment on view acs_events_dates is '
    This view produces a separate row for each time interval in the timespan
    associated with an event.
';

-- This view provides an alternative to the get_name and get_description
-- functions
create view acs_events_activities as
select event_id, 
       coalesce(e.name, a.name) as name,
       coalesce(e.description, a.description) as description,
       coalesce(e.html_p, a.html_p) as html_p,
       coalesce(e.status_summary, a.status_summary) as status_summary,
       e.activity_id,
       timespan_id,
       recurrence_id
from   acs_events e,
       acs_activities a
where  e.activity_id = a.activity_id;

comment on view acs_events_activities is '
    This view pulls the event name and description from the underlying
    activity if necessary.
';

-- These views should make it easier to find recurrences that
-- need to be populated further, e.g. 
--
--     select   recurrence_id
--     from     partially_populated_events p, acs_event_party_map m
--     where    db_populated_until < :current_date
--     and      p.event_id = m.event_id
--     and      party_id   = :party_id
--     group by recurrence_id
--
create view partially_populated_event_ids as
select   min(event_id) as event_id, 
         db_populated_until
from     acs_events e, 
         recurrences r
where    e.recurrence_id = r.recurrence_id
and      (recur_until > db_populated_until or recur_until is null)
group by r.recurrence_id, db_populated_until;

comment on view partially_populated_event_ids is '
    This view returns the first event_id and db_populated_until column
    for any recurrences that have not been completely populated.
';

create view partially_populated_events as
select  e.event_id, 
        timespan_id, 
        activity_id, 
        recurrence_id,
        db_populated_until
from    acs_events e,
        partially_populated_event_ids p
where   e.event_id = p.event_id;

comment on view partially_populated_events is '
    This view returns information about recurring events that have not been
    completely populated (such as indefinitely recurring events.)
';


-- ACS Event API
--
-- Quick reference for the API supported for the Event object.  Note that every procedure
-- takes event_id as the first argument, we're just leave it out for compactness.
-- 
--     new          (...)
--     delete       ()
--
--     get_name        ()
--     get_description ()
--     get_html_p ()
--     get_status_summary ()
--
--     timespan_set (timespan_id)
--     activity_set (activity_id)
--
--     party_map    (party_id)
--     party_unmap  (party_id)
--
--     insert_instances (cutoff_date)
--
--     delete_all       ()
--     delete_all       (recurrence_id)
--
--     shift        (start_offset, end_offset)
--     shift_all    (start_offset, end_offset)
--
--     recurs_p     ()



create function acs_event__new ( 
       --
       -- Creates a new event (20.10.10)
       --
       -- @author W. Scott Meeks
       -- 
       -- @param event_id          id to use for new event
       -- @param name              Name of the new event
       -- @param description       Description of the new event
       -- @param html_p            Is the description HTML?
       -- @param status_summary    Optional additional status line to display
       -- @param timespan_id       initial time interval set
       -- @param activity_id       initial activity
       -- @param recurrence_id     id of recurrence information
       -- @param object_type       'acs_event'
       -- @param creation_date     default now()
       -- @param creation_user     acs_object param
       -- @param creation_ip       acs_object param
       -- @param context_id        acs_object param
       --
       -- @return The id of the new event.
       --
       integer,		-- acs_events.event_id%TYPE,	     
       varchar,		-- acs_events.name%TYPE,		     
       text,		-- acs_events.description%TYPE,	     
       boolean,		-- acs_events.html_p%TYPE,	     
       text,		-- acs_events.status_summary%TYPE,	     
       integer,		-- acs_events.timespan_id%TYPE,	     
       integer,		-- acs_events.activity_id%TYPE,	     
       integer,		-- acs_events.recurrence_id%TYPE,     
       varchar,		-- acs_object_types.object_type%TYPE, 
       timestamptz,	-- acs_objects.creation_date%TYPE,    
       integer,		-- acs_objects.creation_user%TYPE,    
       varchar,		-- acs_objects.creation_ip%TYPE,	     
       integer		-- acs_objects.context_id%TYPE,	     
)
returns integer as '	-- acs_events.event_id%TYPE
declare
       new__event_id        alias for $1;  -- default null, 
       new__name            alias for $2;  -- default null,
       new__description     alias for $3;  -- default null,
       new__html_p          alias for $4; -- default null 
       new__status_summary  alias for $5; -- default null 
       new__timespan_id     alias for $6;  -- default null, 
       new__activity_id     alias for $7;  -- default null, 
       new__recurrence_id   alias for $8;  -- default null, 
       new__object_type     alias for $9;  -- default ''acs_event'', 
       new__creation_date   alias for $10;  -- default now(),
       new__creation_user   alias for $11;  -- default null, 
       new__creation_ip     alias for $12; -- default null, 
       new__context_id      alias for $13; -- default null 
       v_event_id	    acs_events.event_id%TYPE;
begin
       v_event_id := acs_object__new(
            new__event_id,	-- object_id
            new__object_type,	-- object_type
            new__creation_date, -- creation_date
            new__creation_user,	-- creation_user
            new__creation_ip,	-- creation_ip
            new__context_id	-- context_id
	    );
                
       insert into acs_events
            (event_id, name, description, html_p, status_summary, activity_id, timespan_id, recurrence_id)
       values
            (v_event_id, new__name, new__description, new__html_p, new__status_summary, new__activity_id, new__timespan_id,
             new__recurrence_id);

       return v_event_id;

end;' language 'plpgsql';


create function acs_event__delete ( 
       --
       -- Deletes an event (20.10.40)
       -- Also deletes party mappings (via on delete cascade).
       -- If this is the last instance of a recurring event, the recurrence
       -- info is deleted as well
       --
       -- @author W. Scott Meeks
       --
       -- @param event_id id of event to delete
       --
       -- @return 0 (procedure dummy)
       --
       integer		-- acs_events.event_id%TYPE 
) returns integer as '
declare
       delete__event_id	alias for $1;
       v_recurrence_id		acs_events.recurrence_id%TYPE;
begin
       select recurrence_id into v_recurrence_id
       from   acs_events
       where  event_id = delete__event_id;

       -- acs_events and acs_event_party_map deleted via on delete cascade
       PERFORM acs_object__delete(delete__event_id); 

       -- Check for no more instances and delete recurrence if exists
       if not acs_event__instances_exist_p(v_recurrence_id) then 
            PERFORM recurrence__delete(v_recurrence_id);
       end if;

       return 0;

end;' language 'plpgsql';


create function acs_event__delete_all_recurrences (
       --
       -- Deletes all instances of an event with the same (non-null) recurrence_id.  
       --
       -- @author W. Scott Meeks
       --
       -- @param recurrence_id All events with this recurrence_id will be deleted.
       --
       -- @return 0 (procedure dummy)
       --
       integer		-- recurrences.recurrence_id%TYPE default null
)
returns integer as '
declare
       delete_all_recurrences__recurrence_id	alias for $1; -- default null
       rec_event				record;
begin
       if delete_all_recurrences__recurrence_id is not null then
            for rec_event in 
	      select event_id 
	      from acs_events 
	      where  recurrence_id = delete_all_recurrences__recurrence_id
	    loop
                PERFORM acs_event__delete(rec_event.event_id);
            end loop;
       end if;
	
       return 0;

end;' language 'plpgsql';


create function acs_event__delete_all (
       --
       -- Deletes all instances of a recurring event with this event_id
       -- Use acs_event__delete for events with no recurrence
       --  
       --
       -- @author W. Scott Meeks
       --
       -- @param event_id  All events with the same recurrence_id as this one will be deleted.
       --
       -- @return 0 (procedure dummy)
       --
       integer	    -- acs_events.event_id%TYPE	
)
returns integer as '
declare
       delete_all__event_id	alias for $1;
       v_recurrence_id		acs_events.recurrence_id%TYPE;
begin

       select recurrence_id into v_recurrence_id
       from   acs_events
       where  event_id = delete_all__event_id;

       PERFORM acs_event__delete_all_recurrences(v_recurrence_id);

       return 0;

end;' language 'plpgsql';


create function acs_event__get_name (
       --
       -- Returns the name or the name of the activity associated with the event if 
       -- name is null.
       -- Equivalent functionality to get_name provided by acs_event_activity view
       --
       -- @author W. Scott Meeks
       --
       -- @param event_id                      id of event to get name for
       --
       -- @return The name or the name of the activity associated with the event if name is null. 
       --
       integer		-- acs_events.event_id%TYPE 
)
returns varchar as '	-- acs_events.name%TYPE
declare    
       get_name__event_id alias for $1; 
       v_name acs_events.name%TYPE; 
begin

       select coalesce(e.name, a.name) into v_name
       from   acs_events e 
       left join acs_activities a
       on (e.activity_id = a.activity_id)
       where e.event_id = get_name__event_id;

       return v_name;

end;' language 'plpgsql';


create function acs_event__get_description (
       --
       -- Returns the description or the description of the activity associated 
       -- with the event if description is null.
       -- Equivalent functionality to get_description provided by acs_event_activity view
       --
       -- @author W. Scott Meeks
       --
       -- @param event_id                      id of event to get description for
       --
       -- @return The description or the description of the activity associated with the event if description is null. 
       --
       integer	        -- acs_events.event_id%TYPE 
)
returns text as '	-- acs_events.description%TYPE
declare
       get_description__event_id   alias for $1;
       v_description		    acs_events.description%TYPE; 
begin

       select coalesce(e.description, a.description) into v_description
       from   acs_events e
       left join acs_activities a
       on  (e.activity_id = a.activity_id)
       where  e.event_id = get_description__event_id;

       return v_description;

end;' language 'plpgsql';


create function acs_event__get_html_p (
       --
       -- Returns html_p or html_p of the activity associated with the event if 
       -- html_p is null.
       --
       -- @author W. Scott Meeks
       --
       -- @param event_id id of event to get html_p for
       --
       -- @return The html_p or html_p of the activity associated with the event if html_p is null.
       --
       integer		-- acs_events.event_id%TYPE 
)
returns boolean as '	-- acs_events.html_p%TYPE
declare
       get_html_p__event_id    in acs_events.event_id%TYPE 
       v_html_p		acs_events.html_p%TYPE; 
begin
       select coalesce(e.html_p, a.html_p) into v_html_p
       from  acs_events e
       left join acs_activities a
       on (e.activity_id = a.activity_id)
       where e.event_id = get_html_p__event_id

       return v_html_p;

end;' language 'plpgsql';

create function acs_event__get_status_summary (
       --
       -- Returns status_summary or status_summary of the activity associated with the event if 
       -- status_summary is null.
       --
       -- @author W. Scott Meeks
       --
       -- @param event_id id of event to get status_summary for
       --
       -- @return The status_summary or status_summary of the activity associated with the event if status_summary is null.
       --
       integer		-- acs_events.event_id%TYPE 
)
returns boolean as '	-- acs_events.status_summary%TYPE
declare
       get_status_summary__event_id    in acs_events.event_id%TYPE 
       v_status_summary		acs_events.status_summary%TYPE; 
begin
       select coalesce(e.status_summary, a.status_summary) into v_status_summary
       from  acs_events e
       left join acs_activities a
       on (e.activity_id = a.activity_id)
       where e.event_id = get_status_summary__event_id

       return v_status_summary;

end;' language 'plpgsql';


create function acs_event__timespan_set (
       --
       -- Sets the time span for an event (20.10.15)
       --
       -- @author W. Scott Meeks
       --
       -- @param event_id      id of event to update
       -- @param timespan_id   new time interval set
       --
       -- @return 0 (procedure dummy)
       --
       integer,		-- acs_events.event_id%TYPE,
       integer		-- timespans.timespan_id%TYPE
)
returns integer as '
declare
       timespan_set__event_id        alias for $1;
       timespan_set__timespan_id     alias for $2;
begin
       update acs_events
       set    timespan_id = timespan_set__timespan_id
       where  event_id    = timespan_set__event_id;

       return 0;

end;' language 'plpgsql';


create function acs_event__recurrence_timespan_edit (
       integer,
       timestamptz,
       timestamptz
) returns integer as '
DECLARE
        p_event_id                      alias for $1;
        p_start_date                    alias for $2;
        p_end_date                      alias for $3;
        v_timespan                   RECORD;
        v_one_start_date             timestamptz;
        v_one_end_date               timestamptz;
BEGIN
        -- get the initial offsets
        select start_date,
               end_date into v_one_start_date,
               v_one_end_date
        from time_intervals, 
             timespans, 
             acs_events 
        where time_intervals.interval_id = timespans.interval_id
          and timespans.timespan_id = acs_events.timespan_id
          and event_id=p_event_id;

        FOR v_timespan in
            select *
            from time_intervals
            where interval_id in (select interval_id
                                  from timespans 
                                  where timespan_id in (select timespan_id
                                                        from acs_events 
                                                        where recurrence_id = (select recurrence_id 
                                                                               from acs_events where event_id = p_event_id)))
        LOOP
                PERFORM time_interval__edit(v_timespan.interval_id, 
                                            v_timespan.start_date + (p_start_date - v_one_start_date), 
                                            v_timespan.end_date + (p_end_date - v_one_end_date));
        END LOOP;

        return p_event_id;
END;
' language 'plpgsql';

create function acs_event__activity_set (
       --
       -- Sets the activity for an event (20.10.20)
       --
       -- @author W. Scott Meeks
       --
       -- @param event_id      id of event to update
       -- @param timespan_id   new time interval set
       --
       -- @return 0 (procedure dummy)
       --
       integer,		-- acs_events.event_id%TYPE,
       integer	        -- acs_activities.activity_id%TYPE
)
returns integer as '
declare
        activity_set__event_id        alias for $1;
        activity_set__activity_id     alias for $2;
begin
        update acs_events
        set    activity_id = activity_set__activity_id
        where  event_id    = activity_set__event_id;

	return 0;

end;' language 'plpgsql';


create function acs_event__party_map (
       --
       -- Adds a party mapping to an event (20.10.30)
       --
       -- @author W. Scott Meeks
       --
       -- @param event_id event to add mapping to
       -- @param party_id party to add mapping for
       --
       -- @return 0 (procedure dummy)
       --
       integer,		-- acs_events.event_id%TYPE,
       integer		-- parties.party_id%TYPE
)
returns integer as '
declare
       party_map__event_id        alias for $1;
       party_map__party_id        alias for $2;
begin
       insert into acs_event_party_map
            (event_id, party_id)
       values
            (party_map__event_id, party_map__party_id);

       return 0;

end;' language 'plpgsql';


create function acs_event__party_unmap (
       --
       -- Deletes a party mapping from an event (20.10.30)
       --
       -- @author W. Scott Meeks
       --
       -- @param event_id                      id of event to delete mapping from
       -- @param party_id                      id of party to delete mapping for
       --
       -- @return 0 (procedure dummy)
       --
       integer,		-- acs_events.event_id%TYPE,
       integer		-- parties.party_id%TYPE
) 
returns integer as '
declare
       party_unmap__event_id    alias for $1;
       party_unmap__party_id    alias for $2;
begin
       delete from acs_event_party_map
       where  event_id = party_unmap__event_id
       and    party_id = party_unmap__party_id;

       return 0;

end;' language 'plpgsql';


create function acs_event__recurs_p (
       --
       -- Returns true if event recurs, false otherwise (20.50.40)
       --
       -- @author W. Scott Meeks
       --
       -- @param event_id	id of event to check
       --
       -- @return true if event recurs, otherwise false
       --
       integer         -- in acs_events.event_id%TYPE
) 
returns boolean as '
declare
       recurs_p__event_id    alias for $1;
       v_result	      boolean;
begin
       select (case when recurrence_id is null 
	             then false
                     else true 
                end) into v_result
       from   acs_events
       where  event_id = recurs_p__event_id;

       return v_result;

end;' language 'plpgsql';


create function acs_event__instances_exist_p (
       --
       -- Returns true if events with the given recurrence_id exist, false otherwise
       --
       -- @author W. Scott Meeks
       --
       -- @param recurrence_id	id of recurrence to check
       --
       -- @return true if events with the given recurrence_id exist, false otherwise
       --
       integer	        -- acs_events.recurrence_id%TYPE
)
returns boolean as '	
declare
        instances_exist_p__recurrence_id	alias for $1;
        v_result				integer;
begin
        -- Only need to check if any rows exist.
        select count(*) into v_result
        from   dual 
        where exists (select recurrence_id
                      from   acs_events
                      where  recurrence_id = instances_exist_p__recurrence_id);

        if v_result = 0 then
            return false;
        else
            return true;
        end if;

end;' language 'plpgsql';


create function acs_event__get_value (
       --
       -- This function is used internally by insert_instances
       --
       -- JS: The only time this function is used is to get the
       -- JS: EventFutureLimit parameter from APM.  However,
       -- JS: the original acs-events package does not define
       -- JS: the EventFutureLimit parameter, so I had to create
       -- JS: it (in APM).
       --
       -- @author W. Scott Meeks
       --
       -- @param parameter_string Parameter to be extracted from acs-events package
       --
       -- @return  Value of parameter
       --
       varchar	        -- in apm_parameters.parameter_name%TYPE
)
returns varchar as '	-- return apm_parameter_values.attr_value%TYPE
declare
       get_value__parameter_name	alias for $1;
       v_package_id			apm_packages.package_id%TYPE;
begin
       select package_id into v_package_id
       from   apm_packages
       where  package_key = ''acs-events'';

       return apm__get_value(v_package_id, get_value__parameter_name);

end;' language 'plpgsql';

create function acs_event__new_instance (
       --
       -- Create a new instance of an event, with dateoffset from the start_date
       -- and end_date of event identified by event_id. Note that dateoffset
       -- is an interval, not an integer.  This function is used internally by 
       -- insert_instances. Since this function is internal, there is no need 
       -- to overload a function that has an integer for the dateoffset.
       --
       -- @author W. Scott Meeks
       --
       -- @param event_id	Id of event to reference 
       -- @param date_offset    Offset from reference event, in date interval
       --
       -- @return  event_id of new event created.
       -- 
       integer,               -- acs_events.event_id%TYPE,
       interval               
)
returns integer as '	      -- acs_events.event_id%TYPE
declare
       new_instance__event_id    alias for $1;
       new_instance__date_offset alias for $2;
       event_row		  acs_events%ROWTYPE;
       object_row		  acs_objects%ROWTYPE;
       v_event_id		  acs_events.event_id%TYPE;
       v_timespan_id		  acs_events.timespan_id%TYPE;
begin

       -- Get event parameters
       select * into event_row
       from   acs_events
       where  event_id = new_instance__event_id;

       -- Get object parameters                
       select * into object_row
       from   acs_objects
       where  object_id = new_instance__event_id;

       -- We allow non-zero offset, so we copy
       v_timespan_id := timespan__copy(event_row.timespan_id, new_instance__date_offset);

       -- Create a new instance
       v_event_id := acs_event__new(
	    null,                     -- event_id (default)
            event_row.name,           -- name
            event_row.description,    -- description
            event_row.html_p,         -- html_p
            event_row.status_summary, -- status_summary
            v_timespan_id,	      -- timespan_id
            event_row.activity_id,    -- activity_id`
            event_row.recurrence_id,  -- recurrence_id
	    ''acs_event'',	      -- object_type (default)
	    now(),		      -- creation_date (default)
            object_row.creation_user, -- creation_user
            object_row.creation_ip,   -- creation_ip
            object_row.context_id     -- context_id
	    );

      return v_event_id;

end;' language 'plpgsql';



create function acs_event__insert_instances (
       --
       -- This is the key procedure creating recurring events.  This procedure
       -- uses the interval set and recurrence information referenced by the event
       -- to insert additional information to represent the recurrences.   
       -- Events will be added up until the earlier of recur_until and
       -- cutoff_date.  The procedure enforces a hard internal 
       -- limit of adding no more than 10,000 recurrences at once to reduce the 
       -- risk of demolishing the DB because of application bugs.  The date of the
       -- last recurrence added is marked as the db_populated_until date.
       --
       -- The application is responsible for calling this function again if 
       -- necessary to populate to a later date.  
       --
       -- JS: Note that the following Oracle functions do not have any equivalent 
       -- JS: (at least in an obvious way) in Postgres: next_day, add_months, last_day.
       -- JS: Ports of these functions are in oracle-compat-create.sql. 
       -- JS:
       -- JS: To understand the port, it is important to keep in mind the subtle but
       -- JS: important differences in the way Oracle and Postgres do date arithmetic.
       -- JS: Compatibility with Oracle requires that all integers involved in date arithmetic
       -- JS: be converted to Postgres day intervals, hence the typecasting. The typecasting 
       -- JS: function to_interval (also in oracle-compat-create.sql) is simply a convenience 
       -- JS: so that the code will not be littered by escaped quotes.
       -- JS:
       -- JS: NOTE: There seems to be some weirdness going on with recurrence 
       -- JS: when moving from non-DST to DST dates (email me for the gory details).
       -- JS: Not sure if a Postgres bug or feature.
       -- 
       -- @author W. Scott Meeks
       --
       -- @param event_id              The id of the event to recur.  If the 
       --                              event's recurrence_id is null, nothing happens.
       -- @param cutoff_date           Determines how far out to prepopulate the DB.  
       --                              Default is now() plus the value of the
       --                              EventFutureLimit site parameter.
       --
       -- @return 0 (procedure dummy)
       --
       integer,		-- acs_events.event_id%TYPE, 
       timestamptz	-- default null
)
returns integer as '
declare
       insert_instances__event_id      alias for $1;
       insert_instances__cutoff_date   alias for $2;  -- default null
       event_row		       acs_events%ROWTYPE;
       recurrence_row		       recurrences%ROWTYPE;
       v_event_id		       acs_events.event_id%TYPE;
       v_interval_name		       recurrence_interval_types.interval_name%TYPE;
       v_n_intervals		       recurrences.every_nth_interval%TYPE;
       v_days_of_week		       recurrences.days_of_week%TYPE;
       v_last_date_done		       timestamptz;
       v_stop_date		       timestamptz;
       v_start_date		       timestamptz;
       v_event_date		       timestamptz;
       v_diff			       integer;
       v_current_date		       timestamptz;
       v_last_day		       timestamptz;
       v_week_date		       timestamptz;
       v_instance_count		       integer;
       v_days_length		       integer;
       v_days_index		       integer;
       v_day_num		       integer;
       rec_execute		       record;
begin

	-- Get event parameters
        select * into event_row
        from   acs_events
        where  event_id = insert_instances__event_id;

	-- Get recurrence information
        select * into recurrence_row
        from   recurrences
        where  recurrence_id = event_row.recurrence_id;
        

        -- Set cutoff date to stop populating the DB with recurrences
        -- EventFutureLimit is in years. (a parameter of the service)
        if insert_instances__cutoff_date is null then
           v_stop_date := add_months(now(), 12 * to_number(acs_event__get_value(''EventFutureLimit''),''99999''));
        else
           v_stop_date := insert_instances__cutoff_date;
        end if;
        
        -- Events only populated until max(cutoff_date, recur_until)
        -- If recur_until null, then defaults to cutoff_date
        if recurrence_row.recur_until < v_stop_date then
           v_stop_date := recurrence_row.recur_until;
        end if;
        
        -- Figure out the date to start from.
	-- JS: I do not understand why the date must be truncated to the midnight of the event date
        select min(start_date)
        into   v_event_date
        from   acs_events_dates
        where  event_id = insert_instances__event_id;

        if recurrence_row.db_populated_until is null then
           v_start_date := v_event_date;
        else
           v_start_date := recurrence_row.db_populated_until;
        end if;
        
        v_current_date   := v_start_date;
        v_last_date_done := v_start_date;
        v_n_intervals    := recurrence_row.every_nth_interval;
        
        -- Case off of the interval_name to make code easier to read
        select interval_name into v_interval_name
        from   recurrences r, 
               recurrence_interval_types t
        where  recurrence_id   = recurrence_row.recurrence_id
        and    r.interval_type = t.interval_type;
        
        -- Week has to be handled specially.
        -- Start with the beginning of the week containing the start date.
        if v_interval_name = ''week'' 
	then
            v_current_date := next_day(v_current_date - to_interval(7,''days''),''SUNDAY'');
            v_days_of_week := recurrence_row.days_of_week;
            v_days_length  := char_length(v_days_of_week);
        end if;
        
        -- Check count to prevent runaway in case of error
        v_instance_count := 0;

	-- A feature: we only care about the date when populating the database for reccurrence.
        while v_instance_count < 10000 and (date_trunc(''day'',v_last_date_done) <= date_trunc(''day'',v_stop_date))
        loop
            v_instance_count := v_instance_count + 1;
        
            -- Calculate next date based on interval type

	    -- Add next day, skipping every v_n_intervals
	    if v_interval_name = ''day'' 
	    then
                v_current_date := v_current_date + to_interval(v_n_intervals,''days'');
	    end if;
        
	    -- Add a full month, skipping by v_n_intervals months
            if v_interval_name = ''month_by_date'' 
	    then
                v_current_date := add_months(v_current_date, v_n_intervals);
	    end if;

	    -- Add days so that the next date will have the same day of the week,  and week of the month
            if v_interval_name = ''month_by_day'' then
                -- Find last day of month before correct month
                v_last_day := add_months(last_day(v_current_date), v_n_intervals - 1);
                -- Find correct week and go to correct day of week
                v_current_date := next_day(v_last_day + 
				              to_interval(7 * (to_number(to_char(v_current_date,''W''),''99'') - 1),
							  ''days''),
                                            to_char(v_current_date, ''DAY''));
	    end if;

	    -- Add days so that the next date will have the same day of the week on the last week of the month
            if v_interval_name = ''last_of_month'' then
                -- Find last day of correct month
                v_last_day := last_day(add_months(v_current_date, v_n_intervals));
                -- Back up one week and find correct day of week
                v_current_date := next_day(v_last_day - to_interval(7,''days''), to_char(v_current_date, ''DAY''));
	    end if;

	    -- Add a full year (12 months)
            If v_interval_name = ''year'' then
                v_current_date := add_months(v_current_date, 12 * v_n_intervals);
	    end if;

            -- Deal with custom function
            if v_interval_name = ''custom'' then

	        -- JS: Execute a dynamically created query on the fly...
	        FOR rec_execute IN
		EXECUTE ''select '' || recurrence_row.custom_func 
				    || ''('' || quote_literal(v_current_date)
				    || '','' || v_n_intervals || '') as current_date''
		LOOP
		     v_current_date := rec_execute.current_date;
		END LOOP;

            end if;
        
            -- Check to make sure we are not going past Trunc because dates are not integral
            exit when date_trunc(''day'',v_current_date) > date_trunc(''day'',v_stop_date);
        
            -- Have to handle week specially
            if v_interval_name = ''week'' then
                -- loop over days_of_week extracting each day number
                -- add day number and insert
                v_days_index := 1;
                v_week_date  := v_current_date;
                while v_days_index <= v_days_length loop
                    v_day_num   := SUBSTR(v_days_of_week, v_days_index, 1);
                    v_week_date := v_current_date + to_interval(v_day_num,''days'');
                    if date_trunc(''day'',v_week_date) > date_trunc(''day'',v_start_date) 
		       and date_trunc(''day'',v_week_date) <= date_trunc(''day'',v_stop_date) then
                         -- This is where we add the event
                         v_event_id := acs_event__new_instance(
                              insert_instances__event_id,					   -- event_id
                              date_trunc(''day'',v_week_date) - date_trunc(''day'',v_event_date)    -- offset
                         );
                         v_last_date_done := v_week_date;

                     else if date_trunc(''day'',v_week_date) > date_trunc(''day'',v_stop_date) 
		          then
                             -- Gone too far
                             exit;
			  end if;

                     end if;

                     v_days_index := v_days_index + 2;

                 end loop;

                 -- Now move to next week with repeats.
                v_current_date := v_current_date + to_interval(7 * v_n_intervals,''days'');
            else
                -- All other interval types
                -- This is where we add the event
                v_event_id := acs_event__new_instance(
                    insert_instances__event_id,						    -- event_id 
                    date_trunc(''day'',v_current_date) - date_trunc(''day'',v_event_date)   -- offset
                );
                v_last_date_done := v_current_date;
            end if;
        end loop;
        
        update recurrences
        set    db_populated_until = v_last_date_done
        where  recurrence_id      = recurrence_row.recurrence_id;

	return 0;
end;' language 'plpgsql';



create function acs_event__shift (
       --
       -- Shifts the timespan of an event by the given offsets.
       --
       -- @author W. Scott Meeks
       --
       -- @param event_id      Event to shift.
       -- @param start_offset  Adds this date interval to the
       --                      start_dates of the timespan of the event.
       --                      No effect on any null start_date.
       -- @param end_offset    Adds this date interval to the
       --                      end_dates of the timespan of the event.
       --                      No effect on any null end_date.
       --
       -- @return 0 (procedure dummy)
       --
       integer,        -- acs_events.event_id%TYPE default null,
       interval,
       interval       
)
returns integer as '
declare
       shift__event_id      alias for $1; -- default null,
       shift__start_offset  alias for $2; -- default 0,
       shift__end_offset    alias for $3; -- default 0
       rec_events	    record;
begin

--       update acs_events_dates
--       set    start_date = start_date + shift__start_offset,
--             end_date   = end_date + shift__end_offset
--       where  event_id   = shift__event_id;

	  -- Can not update view, so we do it the hard way 
	  -- (as if we make the rule anyways)
	  for rec_events in
	      select t.*
	      from acs_events e, timespans s, time_intervals t
	      where e.event_id   = shift__event_id
	      and   e.timespan_id = s.timespan_id
	      and   s.interval_id = t.interval_id
          loop
	       update time_intervals
	       set    start_date = start_date + shift__start_offset,
		      end_date   = end_date + shift__end_offset
	       where  interval_id = rec_events.interval_id;
	  end loop;

       return 0;

end;' language 'plpgsql';


create function acs_event__shift (
       --
       -- Shifts the timespan of an event by the given offsets.
       --
       -- JS: Overloaded function to make above compatible with Oracle behavior
       -- JS: when an integer (for number of days) is supplied as a parameter.
       --
       --
       -- @param event_id      Event to shift.
       -- @param start_offset  Adds this number of days to the
       --                      start_dates of the timespan of the event.
       --                      No effect on any null start_date.
       -- @param end_offset    Adds this number of days to the
       --                      end_dates of the timespan of the event.
       --                      No effect on any null end_date.
       --
       -- @return 0 (procedure dummy)
       --
       integer,         -- acs_events.event_id%TYPE default null,
       integer,         
       integer          
)
returns integer as '
declare
       shift__event_id        alias for $1; -- default null,
       shift__start_offset    alias for $2; -- default 0,
       shift__end_offset      alias for $3; -- default 0
begin
	
       return acs_event__shift (
	            shift__event_id,
	            to_interval(shift__start_offset,''days''),
	            to_interval(shift__end_offset,''days'')
		    );
				    
end;' language 'plpgsql';


create function acs_event__shift_all (
       --
       -- Shifts the timespan of all instances of a recurring event
       -- by the given offsets.
       --
       -- @author W. Scott Meeks
       --
       -- @param event_id      All events with the same
       --                      recurrence_id as this one will be shifted.
       -- @param start_offset  Adds this date interval to the
       --                      start_dates of the timespan of the event
       --                      instances.  No effect on any null start_date.
       -- @param end_offset    Adds this date interval to the
       --                      end_dates of the timespan of the event
       --                      instances.  No effect on any null end_date.
       --
       -- @return 0 (procedure dummy)
       --
       integer,         -- in acs_events.event_id%TYPE default null,
       interval,       
       interval        
)
returns integer as '
declare
        shift_all__event_id        alias for $1; -- default null,
        shift_all__start_offset    alias for $2; -- default 0,
        shift_all__end_offset      alias for $3; -- default 0
	rec_events		   record;
begin


--        update acs_events_dates
--        set    start_date    = start_date + shift_all__start_offset,
--              end_date      = end_date + shift_all__end_offset
--        where recurrence_id  = (select recurrence_id
--                                from   acs_events
--                                where  event_id = shift_all__event_id);

	-- Can not update views
	for rec_events in
	    select *
	    from acs_events_dates
	    where recurrence_id  = (select recurrence_id
				    from   acs_events
				    where  event_id = shift_all__event_id)
	loop
	
	    PERFORM acs_event__shift(
			rec_events.event_id,
			shift_all__start_offset,	       
			shift_all__end_offset
			);
	end loop;

	return 0;

end;' language 'plpgsql';
--    end shift_all;


create function acs_event__shift_all (
       --
       -- Shifts the timespan of all instances of a recurring event
       -- by the given offsets.
       --
       -- JS: Overloaded function to make above compatible with Oracle behavior
       -- JS: when an integer (for number of days) is supplied as a parameter.
       --
       --
       -- @param event_id      All events with the same
       --                      recurrence_id as this one will be shifted.
       -- @param start_offset  Adds this number of days to the
       --                      start_dates of the timespan of the event
       --                      instances.  No effect on any null start_date.
       -- @param end_offset    Adds this number of days to the
       --                      end_dates of the timespan of the event
       --                      instances.  No effect on any null end_date.
       --
       -- @return 0 (procedure dummy)
       --
       integer,         -- acs_events.event_id%TYPE default null,
       integer,         
       integer          
)
returns integer as '
declare
       shift_all__event_id        alias for $1; -- default null,
       shift_all__start_offset    alias for $2; -- default 0,
       shift_all__end_offset      alias for $3; -- default 0
begin
	
       return acs_event__shift_all (
	            shift_all__event_id,
	            to_interval(shift_all__start_offset,''days''),
	            to_interval(shift_all__end_offset,''days'')
		    );
				    
end;' language 'plpgsql';

