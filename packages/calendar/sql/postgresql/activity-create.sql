-- packages/acs-events/sql/postgresql/activity-create.sql
--
-- @author W. Scott Meeks
-- @author Gary Jin (gjin@arsdigita.com)
--
-- @ported 2001-06-26
--
-- $Id: activity-create.sql,v 1.3 2003/05/17 09:46:57 jeffd Exp $

create function inline_0 ()
returns integer as '
declare 
    attr_id acs_attributes.attribute_id%TYPE; 
begin

    -- Event object     
    PERFORM acs_object_type__create_type ( 
       ''acs_activity'',   -- object_type
       ''Activity'',       -- pretty_name
       ''Activities'',     -- pretty_plural
       ''acs_object'',     -- supertype 
       ''ACS_ACTIVITIES'', -- table_name
       ''ACTIVITY_ID'',    -- id_column
       ''null'',	   -- package_name (default)
       ''f'',		   -- abstract_p (default)
       null,		   -- type_extension_table (default)
       null		   -- name_method (default)
    );

   -- Event attributes
    attr_id := acs_attribute__create_attribute (
       ''acs_activity'',   -- object_type
       ''name'',	   -- attribute_name
       ''string'',	   -- data_type
       ''Name'',	   -- pretty_name
       ''Names'',	   -- pretty_plural
       null,		   -- table_name (default)
       null,		   -- column_name (default)
       null,		   --  default_value (default)
       1,		   -- min_n_values (default)
       1,		   -- max_n_values (default)
       null,		   -- sort_order (default)
       ''type_specific'',  -- storage (default)
       ''f''		   -- static_p (default)
    );

    attr_id := acs_attribute__create_attribute (
       ''acs_activity'',   -- object_type
       ''description'',	   -- attribute_name
       ''string'',	   -- data_type
       ''Description'',	   -- pretty_name
       ''Descriptions'',   -- pretty_plural
       null,		   -- table_name (default)
       null,		   -- column_name (default)
       null,		   --  default_value (default)
       1,		   -- min_n_values (default)
       1,		   -- max_n_values (default)
       null,		   -- sort_order (default)
       ''type_specific'',  -- storage (default)
       ''f''		   -- static_p (default)
    );


    attr_id := acs_attribute__create_attribute (
       ''acs_activity'',   -- object_type
       ''html_p'',	   -- attribute_name
       ''string'',	   -- data_type
       ''HTML?'',	   -- pretty_name
       ''HTML?'',	   -- pretty_plural
       null,		   -- table_name (default)
       null,		   -- column_name (default)
       null,		   --  default_value (default)
       1,		   -- min_n_values (default)
       1,		   -- max_n_values (default)
       null,		   -- sort_order (default)
       ''type_specific'',  -- storage (default)
       ''f''		   -- static_p (default)
    );

    attr_id := acs_attribute__create_attribute (
       ''acs_activity'',   -- object_type
       ''status_summary'', -- attribute_name
       ''string'',	   -- data_type
       ''Status Summary'',  -- pretty_name
       ''Status Summaries'', -- pretty_plural
       null,		   -- table_name (default)
       null,		   -- column_name (default)
       null,		   --  default_value (default)
       1,		   -- min_n_values (default)
       1,		   -- max_n_values (default)
       null,		   -- sort_order (default)
       ''type_specific'',  -- storage (default)
       ''f''		   -- static_p (default)
    );

    return 0;

end;' language 'plpgsql';

select inline_0 ();
drop function inline_0 ();


-- The activities table
create table acs_activities (
    activity_id         integer
                        constraint acs_activities_fk
                        references acs_objects(object_id)
                        on delete cascade
                        constraint acs_activities_pk
                        primary key,
    name                varchar(255) not null,
    description         text,
    -- is the activity description written in html?
    html_p              boolean default 'f',
    status_summary      varchar(255)
);

comment on table acs_activities is '
    Represents what happens during an event
';
        

create table acs_activity_object_map (
    activity_id         integer
                        constraint acs_act_obj_mp_activity_id_fk
                        references acs_activities on delete cascade,
    object_id           integer
                        constraint acs_act_obj_mp_object_id_fk
                        references acs_objects(object_id) on delete cascade,
    constraint acs_act_obj_mp_pk
    primary key(activity_id, object_id)
);

comment on table acs_activity_object_map is '
    Maps between an activity and multiple ACS objects.
';

-- Activity API (all have activity_id as parameter))
--
--	new()
--	delete()
--
--	name()
--      edit (name,description,html_p,status_summary)
-- 
--      object_map (object_id)
--      object_unmap (object_id)


create function acs_activity__new (
       --
       -- Create a new activity
       --
       -- @author W. Scott Meeks
       --
       -- @param activity_id       Id to use for new activity
       -- @param name              Name of the activity 
       -- @param description       Description of the activity
       -- @param html_p            Is the description HTML?
       -- @param status_summary    Additional status note (optional)
       -- @param object_type       'acs_activity'
       -- @param creation_date     default now()
       -- @param creation_user     acs_object param
       -- @param creation_ip       acs_object param
       -- @param context_id        acs_object param
       --
       -- @return The id of the new activity.
       --
       integer,			 -- in acs_activities.activity_id%TYPE
       varchar,			 -- in acs_activities.name%TYPE,
       text,			 -- in acs_activities.description%TYPE
       boolean,			 -- in acs_activities.html_p%TYPE     
       text,			 -- in acs_activities.status_summary%TYPE     
       varchar,			 -- in acs_object_types.object_type%TYPE
       timestamptz,		 -- in acs_objects.creation_date%TYPE
       integer,			 -- in acs_objects.creation_user%TYPE
       varchar,			 -- in acs_objects.creation_ip%TYPE
       integer			 -- in acs_objects.context_id%TYPE
)
returns integer as '		 -- return acs_activities.activity_id%TYPE
declare       
       new__activity_id         alias for $1; -- default null, 
       new__name                alias for $2;
       new__description         alias for $3; -- default null,
       new__html_p              alias for $4; -- default ''f'',
       new__status_summary      alias for $5; -- default null,
       new__object_type         alias for $6; -- default ''acs_activity''
       new__creation_date       alias for $7; -- default now(), 
       new__creation_user       alias for $8; -- default null, 
       new__creation_ip         alias for $9; -- default null, 
       new__context_id          alias for $10; -- default null 
       v_activity_id		  acs_activities.activity_id%TYPE;
begin
       v_activity_id := acs_object__new(
            new__activity_id,	   -- object_id
            new__object_type,	   -- object_type
            new__creation_date,    -- creation_date  
            new__creation_user,    -- creation_user
            new__creation_ip,	   -- creation_ip
            new__context_id	   -- context_id
	    );

       insert into acs_activities
            (activity_id, name, description, html_p, status_summary)
       values
            (v_activity_id, new__name, new__description, new__html_p, new__status_summary);

       return v_activity_id;

end;' language 'plpgsql'; 


create function acs_activity__delete (
       --
       -- Deletes an activity
       --
       -- @author W. Scott Meeks
       --
       -- @param activity_id      Id of activity to delete
       --
       -- @return 0 (procedure dummy)
       --
       integer			-- in acs_activities.activity_id%TYPE 
)
returns integer as '
declare
       delete__activity_id	alias for $1;
begin

       -- Cascade will cause delete from acs_activities 
       -- and acs_activity_object_map

       PERFORM acs_object__delete(delete__activity_id); 

       return 0;

end;' language 'plpgsql';


create function acs_activity__name (
       --
       -- Get name of this activity 
       --
       -- @author gjin@arsdigita.com
       --
       -- @param activity_id
       --
       -- @return Name of activity
       --
       integer		-- acs_activities.activity_id%TYPE
)
returns varchar as '	-- acs_activities.name%TYPE
declare 
       name__activity_id	alias for $1; 
       v_activity_name		acs_activities.name%TYPE;
begin
       select  name
       into    v_activity_name
       from    acs_activities
       where   activity_id = name__activity_id;

       return  v_activity_name;

end;' language 'plpgsql'; 

         
create function acs_activity__edit (
       --
       -- Update the name or description of an activity
       --
       -- @author W. Scott Meeks
       --
       -- @param activity_id activity to update
       -- @param name        optional New name for this activity
       -- @param description optional New description for this activity
       -- @param html_p      optional New value of html_p for this activity
       -- @param status_summary optional New value of status_summary for this activity
       --
       -- @return 0 (procedure dummy)
       --
       integer,		-- acs_activities.activity_id%TYPE, 
       varchar,		-- acs_activities.name%TYPE default null,
       text,		-- acs_activities.description%TYPE default null,
       boolean,		-- acs_activities.html_p%TYPE default null
       text		-- acs_activities.status_summary%TYPE default null,
) returns integer as '
declare
       edit__activity_id   alias for $1;
       edit__name          alias for $2; -- default null,
       edit__description   alias for $3; -- default null,
       edit__html_p        alias for $4; -- default null
       edit__status_summary alias for $5; -- default null
begin

       update acs_activities
       set    name        = coalesce(edit__name, name),
              description = coalesce(edit__description, description),
              html_p      = coalesce(edit__html_p, html_p),
              status_summary = coalesce(edit__status_summary, status_summary)
       where activity_id  = edit__activity_id;

       return 0;

end;' language 'plpgsql';


create function acs_activity__object_map (
       --
       -- Adds an object mapping to an activity
       --
       -- @author W. Scott Meeks
       --
       -- @param activity_id       id of activity to add mapping to
       -- @param object_id         id of object to add mapping for
       --
       -- @return 0 (procedure dummy)
       --
       integer,		-- acs_activities.activity_id%TYPE, 
       integer		-- acs_objects.object_id%TYPE
)
returns integer as '
declare
       object_map__activity_id		alias for $1; 
       object_map__object_id		alias for $2;
begin
       insert into acs_activity_object_map
            (activity_id, object_id)
       values
            (object_map__activity_id, object_map__object_id);

       return 0;

end;' language 'plpgsql';



create function acs_activity__object_unmap (
       --
       -- Removes an object mapping to an activity
       --
       -- @author W. Scott Meeks
       --
       -- @param activity_id       id of activity to add mapping to
       -- @param object_id         id of object to add mapping for
       --
       -- @return 0 (procedure dummy)
       --
       integer,	-- acs_activities.activity_id%TYPE, 
       integer		-- acs_objects.object_id%TYPE
)
returns integer as '
declare
       object_unmap__activity_id	alias for $1; 
       object_unmap__object_id		alias for $2;
begin

       delete from acs_activity_object_map
       where  activity_id = object_unmap__activity_id
       and    object_id   = object_unmap__object_id;

       return 0;

end;' language 'plpgsql';





