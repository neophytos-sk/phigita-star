-- creates the calendar object
--
-- @author Gary Jin (gjin@arsdigita.com)
-- @creation-date Nov 17, 2000
-- @cvs-id $Id: calendar-create.sql,v 1.10 2002/08/21 15:28:55 arjun Exp $
--
-- ported by Charles Mok (mok_cl@eelab.usyd.edu.au)

------------------------------------------------------------------
-- calendar system permissions 
------------------------------------------------------------------
 
  -- creating the basic set of permissions for cal_item
  --
  -- 1  create: create an new item 
  -- 2. read: can view the cal_item
  -- 3. write: edit an existing cal_item
  -- 4. delete: can delete the cal_item
  -- 5. invite: can allow other parties to view or edit the cal_item



  select acs_privilege__create_privilege('cal_item_create', 'Add an new item', null); 
  select acs_privilege__create_privilege('cal_item_read',   'view an 
cal_item', null);
  select acs_privilege__create_privilege('cal_item_write',  'Edit an exsiting cal_item', null);
  select acs_privilege__create_privilege('cal_item_delete', 'Delete cal_item', null );
  select acs_privilege__create_privilege('cal_item_invite', 'Allow others to view cal_item', null); 

  select acs_privilege__add_child('create', 'cal_item_create'); 
  select acs_privilege__add_child('read', 'cal_item_read'); 
  select acs_privilege__add_child('write', 'cal_item_write'); 

  select acs_privilege__add_child('delete', 'cal_item_delete'); 
        
  select acs_privilege__create_privilege('calendar_on', 'Implies that a
calendar is selected', null); 
  select acs_privilege__create_privilege('calendar_show', 'Show a calendar', null);

  select acs_privilege__add_child('read', 'calendar_on'); 
  select acs_privilege__add_child('read', 'calendar_show');         
	
  select acs_privilege__create_privilege('calendar_create', 'Create a new
calendar', null);
  select acs_privilege__create_privilege('calendar_read', 'View items on
an exsiting calendar', null);	
  select acs_privilege__create_privilege('calendar_write', 'Edit items of
an exsiting calendar', null);
  select acs_privilege__create_privilege('calendar_delete','Delete an calendar', null);

  select acs_privilege__add_child('create', 'calendar_create');
  select acs_privilege__add_child('read', 'calendar_read');
  select acs_privilege__add_child('write', 'calendar_write');
  select acs_privilege__add_child('delete', 'calendar_delete');

  select acs_privilege__add_child('calendar_create', 'cal_item_create');
  select acs_privilege__add_child('calendar_read', 'cal_item_read');
  select acs_privilege__add_child('calendar_write', 'cal_item_write');
  select acs_privilege__add_child('calendar_delete', 'cal_item_delete');
       
  select acs_privilege__create_privilege('calendar_admin', 'calendar adminstrator', null);
  select acs_privilege__add_child('admin', 'calendar_admin');
  select acs_privilege__add_child('calendar_admin', 'calendar_read');
  select acs_privilege__add_child('calendar_admin', 'calendar_write');
  select acs_privilege__add_child('calendar_admin', 'calendar_delete');
  select acs_privilege__add_child('calendar_admin', 'calendar_create');
  select acs_privilege__add_child('calendar_admin', 'cal_item_invite');

---------------------------------------------------------- 
--  calendar_ojbect 
----------------------------------------------------------- 

CREATE FUNCTION inline_0()
RETURNS integer
AS 'declare
	attr_id acs_attributes.attribute_id%TYPE;
    begin
	PERFORM 
	    acs_object_type__create_type(
		''calendar'',	-- object_type
		''Calendar'',	-- pretty_name
		''Calendar'',	-- pretty_plural
		''acs_object'',	-- supertype
		''calendars'',	-- table_name
		''calendar_id'',-- id_column
		null,		-- package_name
		''f'',		-- abstract_p
		null,		-- type_extension_table
		null		-- name_method
	    );
		
	    attr_id := acs_attribute__create_attribute (
		''calendar'',       -- object_type
	        ''owner_id'',     -- attribute_name
        	''integer'',         -- datatype
	        ''Owner'',        -- pretty_name
        	''Owners'',       -- pretty_plural
	        null,                -- table_name (default)
	        null,                -- column_name (default)
        	null,                -- default_value (default)
	        1,                   -- min_n_values (default)
        	1,                   -- max_n_values (default)
	        null,                -- sort_order (default)
        	''type_specific'',   -- storage (default)
	        ''f''                -- static_p (default)
	    );

	    attr_id := acs_attribute__create_attribute (
		''calendar'',       -- object_type
	        ''private_p'',     -- attribute_name
        	''string'',         -- datatype
	        ''Private Calendar'',        -- pretty_name
        	''Private Calendars'',       -- pretty_plural
	        null,                -- table_name (default)
	        null,                -- column_name (default)
        	null,                -- default_value (default)
	        1,                   -- min_n_values (default)
        	1,                   -- max_n_values (default)
	        null,                -- sort_order (default)
        	''type_specific'',   -- storage (default)
	        ''f''                -- static_p (default)
	    );

	    attr_id := acs_attribute__create_attribute (
		''calendar'',       -- object_type
	        ''calendar_name'',     -- attribute_name
        	''string'',         -- datatype
	        ''Calendar Name'',        -- pretty_name
        	''Calendar Names'',       -- pretty_plural
	        null,                -- table_name (default)
	        null,                -- column_name (default)
        	null,                -- default_value (default)
	        1,                   -- min_n_values (default)
        	1,                   -- max_n_values (default)
	        null,                -- sort_order (default)
        	''type_specific'',   -- storage (default)
	        ''f''                -- static_p (default)
	    );
	    return 0;

    end;' 
LANGUAGE 'plpgsql';

SELECT inline_0();

DROP function inline_0();

--begin
          -- create the calendar object

--        acs_object_type.create_type (
--                supertype       =>      'acs_object',
--                object_type     =>      'calendar',
--                pretty_name     =>      'Calendar',
--                pretty_plural   =>      'Calendars',
--                table_name      =>      'calendars',
--                id_column       =>      'calendar_id'
--        );
--end;
--/
--show errors
 
--declare 
--        attr_id acs_attributes.attribute_id%TYPE; 
--begin
--        attr_id := acs_attribute.create_attribute ( 
--                object_type     =>      'calendar', 
--                attribute_name  =>      'owner_id', 
--                pretty_name     =>      'Owner', 
--                pretty_plural   =>      'Owners', 
--                datatype        =>      'integer' 
--        ); 
--   
--        attr_id := acs_attribute.create_attribute ( 
--                object_type     =>      'calendar', 
--                attribute_name  =>      'private_p', 
--                pretty_name     =>      'Private Calendar', 
--                pretty_plural   =>      'Private Calendars', 
--                datatype        =>      'string' 
--        ); 
--
--        attr_id := acs_attribute.create_attribute ( 
--                object_type     =>      'calendar', 
--                attribute_name  =>      'calendar_name', 
--                pretty_name     =>      'Calendar Name', 
--                pretty_plural   =>      'Calendar Names', 
--               datatype        =>      'string' 
--        ); 
--end;
--/
--show errors


  -- Calendar is a collection of events. Each calendar must
  -- belong to somebody (a party).
create table calendars (
          -- primary key
        calendar_id             integer         
                                constraint calendars_calendar_id_fk 
                                references acs_objects
                                constraint calendars_calendar_id_pk 
                                primary key,
          -- the name of the calendar
        calendar_name           varchar(200),
          -- the individual or party that owns the calendar        
        owner_id                integer
                                constraint calendars_calendar_owner_id_fk 
                                references parties
                                on delete cascade,
          -- keep track of package instances
        package_id              integer
                                constraint calendars_package_id_fk
                                references apm_packages(package_id)
                                on delete cascade,
          -- whether or not the calendar is a private personal calendar or a 
          -- public calendar. 
        private_p               boolean
                                default 'f'
                                constraint calendars_prviate_p_ck 
                                check (private_p in ( 
                                        't',
                                        'f'
                                        )
                                )       
);

comment on table calendars is '
        Table calendars maps the many to many relationship betweens
        calendar and its owners. 
';

comment on column calendars.calendar_id is '
        Primary Key
';

comment on column calendars.calendar_name is '
        the name of the calendar. This would be unique to avoid confusion
';

comment on column calendars.owner_id is '
        the individual or party that owns the calendar
';

comment on column calendars.package_id is '
        keep track of package instances
';


-- Calendar Item Types

create sequence cal_item_type_seq;

create table cal_item_types (
       item_type_id              integer not null
                                 constraint cal_item_type_id_pk
                                 primary key,
       calendar_id               integer not null
                                 constraint cal_item_type_cal_id_fk     
                                 references calendars(calendar_id),
       type                      varchar(100) not null,
       -- this constraint is obvious given that item_type_id
       -- is unique, but it's necessary to allow strong
       -- references to the pair calendar_id, item_type_id (ben)
       constraint cal_item_types_un
       unique (calendar_id, item_type_id)
);

-------------------------------------------------------------
-- Load cal_item_object
-------------------------------------------------------------
--@@cal-item-create
\i cal-item-create.sql
-------------------------------------------------------------
-- create package calendar
-------------------------------------------------------------

select define_function_args ('calendar__new', 'calendar_id,calendar_name,object_type;calendar,owner_id,private_p,package_id,context_id,creation_date,creation_user,creation_ip');

CREATE FUNCTION calendar__new (
       integer,            -- calendar.calendar_id%TYPE
       varchar(200),            -- calendar.calendar_name%TYPE
       varchar,            -- acs_objects.object_type%TYPE
       integer,            -- calendar.owner_id%TYPE
       boolean,            -- calendar.private_p
       integer,            -- calendar.package_id
       integer,            -- acs_objects.context_id%TYPE
       timestamp,          -- acs_objects.creation_date%TYPE
       integer,            -- acs_objects.creation_user%TYPE
       varchar             -- acs_objects.creation_ip%TYPE
)
RETURNS integer 
AS 'declare
	v_calendar_id           calendars.calendar_id%TYPE;
	new__calendar_id	alias for $1;
	new__calendar_name	alias for $2;
	new__object_type	alias for $3;
	new__owner_id		alias for $4;
	new__private_p		alias for $5;
	new__package_id		alias for $6;
	new__context_id		alias for $7;
	new__creation_date	alias for $8;
	new__creation_user	alias for $9;
	new__creation_ip	alias for $10;

    begin
        v_calendar_id := acs_object__new(
		new__calendar_id,
		new__object_type,
		new__creation_date,
		new__creation_user,
		new__creation_ip,
		new__context_id
	);
	
	insert into     calendars
                        (calendar_id, calendar_name, owner_id, package_id, private_p)
	values          (v_calendar_id, new__calendar_name, new__owner_id, new__package_id, new__private_p);
      
	PERFORM acs_permission__grant_permission (
              v_calendar_id,
              new__owner_id,
              ''calendar_admin''
        );


	return v_calendar_id;
    end;'
LANGUAGE 'plpgsql';   

select define_function_args('calendar__delete','calendar_id');

CREATE FUNCTION calendar__delete(
       integer            -- calendar.calendar_id%TYPE
)
RETURNS integer
AS 'declare
	delete__calendar_id		alias for $1;
    begin
	delete from calendars
	where calendar_id = delete__calendar_id;

	-- Delete all privileges associate with this calendar
	
	delete from     acs_permissions 
        where           object_id = delete__calendar_id;

       delete from     acs_permissions
        where           object_id in (
				select  cal_item_id
                                from    cal_items
                                where   on_which_calendar = delete__calendar_id
			);
                         
	PERFORM acs_object__delete(delete__calendar_id);

    return 0;
    end;'
LANGUAGE 'plpgsql';
	
CREATE FUNCTION calendar__name(
	integer
)
RETURNS varchar
AS 'declare
	name__calendar_id		alias for $1;
	v_calendar_name			calendars.calendar_name%TYPE;

    begin
	select	calendar_name
	into	v_calendar_name
	from	calendars
	where	calendar_id = name__calendar_id;

    return  v_calendar_name;
end;'
LANGUAGE 'plpgsql';

CREATE FUNCTION calendar__private_p(
	integer
)
RETURNS varchar
AS 'declare
        v_private_p             boolean;
	private_p__calendar_id	alias for $1;
    begin
	select	private_p
	into	v_private_p
	from	calendars
	where calendar_id = private_p__calendar_id;

	return v_private_p;
end;'
LANGUAGE 'plpgsql';

CREATE FUNCTION calendar__readable_p(
	integer,
	integer
)
RETURNS boolean
AS 'declare
	readable_p__calendar_id		alias for $1;
	readable_p__party_id		alias for $1;
	v_readable_p			boolean;

    begin
	select (case count(*)
		when 1 then true
			else false
		) into v_readable_p
	from    acs_object_party_privilege_map 
                where   party_id = readable_p__party_id
                and     object_id = readable_p__calendar_id 
                and     privilege = ''calendar_read'';
	
	return v_readable_p;
end;'
LANGUAGE 'plpgsql';

CREATE FUNCTION calendar__show_p (
	integer,
	integer
)
RETURNS boolean 
AS 'declare
	show_p__calendar_id	 alias for $1;
	show_p__party_id	 alias for $2;
	v_show_p		 boolean := ''t'';
    begin
	select	(case count(*)
		when 1 then true
		else false
		end)
	into	v_show_p
	from	acs_permissions
	where	grantee_id = show_p__party_id
	and	object_id = show_p__calendar_id
	and	privilege = ''calendar_show'';

	return v_show_p;
	
end;' 
LANGUAGE 'plpgsql';


CREATE FUNCTION calendar__month_name(
	timestamp
)
RETURNS varchar
AS 'declare
	month_name__current_date		alias for $1;
	v_name			varchar;
    begin
	select	to_char(month_name__current_date, ''fmMonth'')
	into		v_name
	from		dual;

	return v_name;

    end;' 
LANGUAGE 'plpgsql';


CREATE FUNCTION calendar__next_month(
	timestamp
)
RETURNS timestamp
AS 'declare
	next_month__current_dates		alias for $1;
	v_date			timestamp;
    begin
	--select	trunc(add_months(to_date(db_sysdate), -1))
        select date_trunc(''day'', current_timestamp + cast(''1 month'' as interval))
        into		v_date
        from		dual;

        return v_date;          
end;'
LANGUAGE 'plpgsql';
          

CREATE FUNCTION calendar__prev_month(
	timestamp
)
RETURNS timestamp
AS 'declare
	prev_month__current_date		alias for $1;
	v_date			date;
begin
--        select	trunc(add_months(to_date(db_sysdate), -1))
          select date_trunc(''day'', current_timestamp - cast(''1 month'' as interval))
        into		v_date
        from		dual;

        return v_date;
end;'
LANGUAGE 'plpgsql';


CREATE FUNCTION calendar__num_day_in_month(
	timestamp
)
RETURNS integer
AS 'declare
	num_day_in_month__current_date		alias for $1;
	v_num			integer;
begin
	select to_char(last_day(current_date), ''DD'')
        into		v_num
        from		dual;

        return v_num;
end;'
LANGUAGE 'plpgsql';


CREATE FUNCTION calendar__first_displayed_date(
	timestamp
)
RETURNS timestamp
AS 'declare
	first_displayed_date__current_date	alias for $1;
	v_date			timestamp;
begin
        select next_day(date_trunc(''Month'', current_date) - 7 , ''SUNDAY'')
	into		v_date
        from		dual;

        return  v_date;
end;'
LANGUAGE 'plpgsql';


CREATE FUNCTION calendar__last_displayed_date(
	timestamp
)
RETURNS timestamp
AS 'declare
	last_displayed_date__current_date	alias for $1;
	v_date			timestamp;
begin
	select next_day(last_day(current_date), ''SATURDAY'')
        into		v_date
        from		dual;

        return v_date;
end;'
LANGUAGE 'plpgsql';
    

--create or replace package calendar
--as
--       function new (
--                calendar_id             in acs_objects.object_id%TYPE           default null,
--               calendar_name           in calendars.calendar_name%TYPE         default null,
--                object_type             in acs_objects.object_type%TYPE         default 'calendar',
--                owner_id                in calendars.owner_id%TYPE              ,
--                private_p               in calendars.private_p%TYPE             default 'f',
--                package_id              in calendars.package_id%TYPE            default null,           
--                context_id              in acs_objects.context_id%TYPE          default null,
--                creation_date           in acs_objects.creation_date%TYPE       default sysdate,
--                creation_user           in acs_objects.creation_user%TYPE       default null,
--                creation_ip             in acs_objects.creation_ip%TYPE         default null
--
--        ) return calendars.calendar_id%TYPE;
-- 
--        procedure delete (
--                calendar_id             in calendars.calendar_id%TYPE
--        );
--
--          -- figures out the name of the calendar       
--        function name (
--                calendar_id             in calendars.calendar_id%TYPE
--        ) return calendars.calendar_name%TYPE;
--
--          -- returns 't' if calendar is private and 'f' if its not
--        function private_p (
--                calendar_id             in calendars.calendar_id%TYPE
--        ) return char;
--
--
--          -- returns 't' if calendar is viewable by the given party
--          -- this implies that the party has calendar_read permission
--          -- on this calendar
--        function readable_p (
--                calendar_id             in calendars.calendar_id%TYPE,
--                party_id                in parties.party_id%TYPE
--        ) return char;
--
--          -- returns 't' if party wants to be able to select 
--          -- this calendar, and return 'f' otherwise. 
--        function show_p (
--                calendar_id             in calendars.calendar_id%TYPE,
--                party_id                in parties.party_id%TYPE
--        ) return char;
--                
--
--          ----------------------------------------------------------------
--          -- Helper functions for calendar generations:
--          --
--          -- These functions are used for assist in calendar 
--          -- generation. Putting them in the PL/SQL level ensures that
--          -- the date date will be the same, and allowing adoptation 
--          -- to a different language much easier and faster.
--          --             
--          -- current month name
--        function month_name (
--                current_date    date
--        ) return char;
--          
--          -- next month
--        function next_month (
--                current_date    date
--        ) return date;
--          
--         -- prev month
--        function prev_month (
--                current_date    date
--        ) return date;
--
--          -- number of days in the month
--        function num_day_in_month (
--                current_date    date
--        ) return integer;
--
--          -- first day to be displayed in a month. 
--        function first_displayed_date (
--                current_date    date
--        ) return date;
--
--          -- last day to be displayed in a month. 
--        function last_displayed_date (
--                current_date    date
--        ) return date;          
--          
--end calendar;
--/
--show errors;
-- 
-- 
--create or replace package body calendar
--as 
--
--        function new (
--                calendar_id             in acs_objects.object_id%TYPE           default null,
--                calendar_name           in calendars.calendar_name%TYPE         default null,
--                object_type             in acs_objects.object_type%TYPE         default 'calendar',
--                owner_id                in calendars.owner_id%TYPE              , 
--                private_p               in calendars.private_p%TYPE             default 'f',
--                package_id              in calendars.package_id%TYPE            default null,
--                context_id              in acs_objects.context_id%TYPE          default null,
--                creation_date           in acs_objects.creation_date%TYPE       default sysdate,
--                creation_user           in acs_objects.creation_user%TYPE       default null,
--                creation_ip             in acs_objects.creation_ip%TYPE         default null
--
--        ) 
--        return calendars.calendar_id%TYPE
--   
--        is
--                v_calendar_id           calendars.calendar_id%TYPE;
--
--        begin
--                v_calendar_id := acs_object.new (
--                        object_id       =>      calendar_id,
--                        object_type     =>      object_type,
--                        creation_date   =>      creation_date,
--                        creation_user   =>      creation_user,
--                        creation_ip     =>      creation_ip,
--                        context_id      =>      context_id
--                );
--        
--                insert into     calendars
--                                (calendar_id, calendar_name, owner_id, package_id, private_p)
--                values          (v_calendar_id, calendar_name, owner_id, package_id, private_p);
--
--
--                 -- each calendar has three default conditions
--                  -- 1. all items are public
--                  -- 2. all items are private
--                  -- 3. no default conditions
--                  -- 
--                  -- calendar being public implies granting permission
--                  -- calendar_read to the group 'the_public' and 'registered users'
--                  --         
--                  -- calendar being private implies granting permission 
--                  -- calendar_read to the owner party/group of the party
--                  --
--                  -- by default, we grant "calendar_admin" to
--                  -- the owner of the calendar
--                acs_permission.grant_permission (
--                        object_id       =>      v_calendar_id,
--                        grantee_id      =>      owner_id,
--                        privilege       =>      'calendar_admin'
--                );
--                
-- 
--                return v_calendar_id;
--        end new;
-- 
--
--
--          -- body for procedure delete
--        procedure delete (
--                calendar_id             in calendars.calendar_id%TYPE
--        )
--        is
--  
--        begin
--                  -- First erase all the item relate to this calendar.
--                delete from     calendars 
--                where           calendar_id = calendar.delete.calendar_id;
-- 
--                  -- Delete all privileges associate with this calendar
--                delete from     acs_permissions 
--                where           object_id = calendar.delete.calendar_id;
--
--                  -- Delete all privilges of the cal_items that's associated 
--                  -- with this calendar
--                delete from     acs_permissions
--                where           object_id in (
--                                        select  cal_item_id
--                                        from    cal_items
--                                        where   on_which_calendar = calendar.delete.calendar_id                                                                                                                                                         
--                                );
--                        
-- 
--                acs_object.delete(calendar_id);
--        end delete;
-- 
--
--
--          -- figures out the name of the calendar       
--        function name (
--                calendar_id             in calendars.calendar_id%TYPE
--        ) 
--        return calendars.calendar_name%TYPE
--
--        is
--                v_calendar_name         calendars.calendar_name%TYPE;
--        begin
--                select  calendar_name
--                into    v_calendar_name
--                from    calendars
--                where   calendar_id = calendar.name.calendar_id;
--
--                return v_calendar_name;
--        end name;
--
--
--
--          -- returns 't' if calendar is private and 'f' if its not
--        function private_p (
--                calendar_id             in calendars.calendar_id%TYPE
--        ) 
--        return char
--
--        is
--                v_private_p             char(1) := 't';
--        begin
--                select  private_p 
--                into    v_private_p
--                from    calendars
--               where   calendar_id = calendar.private_p.calendar_id;
--
--                return v_private_p;
--        end private_p;
--
--
--
--          -- returns 't' if calendar is viewable by the given party
--          -- this implies that the party has calendar_read permission
--          -- on this calendar
--        function readable_p (
--                calendar_id             in calendars.calendar_id%TYPE,
--                party_id                in parties.party_id%TYPE
--        ) 
--        return char
--
--        is      
--                v_readable_p            char(1) := 't';
--        begin
--                select  decode(count(*), 1, 't', 'f') 
--                into    v_readable_p
--                from    acs_object_party_privilege_map 
--                where   party_id = calendar.readable_p.party_id
--                and     object_id = calendar.readable_p.calendar_id 
--               and     privilege = 'calendar_read';
--
--                return  v_readable_p;
--
--        end readable_p;
--
--          -- returns 't' if party wants to be able to select (calendar_show granted)
--          -- this calendar, and .return 'f' otherwise. 
--          --
--          -- this seems to be a problem with the problem that when
--          -- revoking the permissions using acs_permissions.revoke
--          -- data is not removed from table acs_object_party_privilege_map.
--        function show_p (
--                calendar_id             in calendars.calendar_id%TYPE,
--                party_id                in parties.party_id%TYPE
--        ) 
--        return char
--
--        is
--                v_show_p                char(1) := 't';
--        begin
--                select  decode(count(*), 1, 't', 'f') 
--                into    v_show_p
--                from    acs_permissions
--                where   grantee_id = calendar.show_p.party_id
--                and     object_id = calendar.show_p.calendar_id 
--                and     privilege = 'calendar_show';
--
--                return  v_show_p;
--
--        end show_p;
--
--
--          -- Helper functions for calendar generations:
--          --
--          -- These functions are used for assist in calendar 
--          -- generation. Putting them in the PL/SQL level ensures that
--          -- the date date will be the same, and allowing adoptation 
--          -- to a different language much easier and faster.
--          --             
--          -- current month name
--        function month_name (
--                current_date            date
--        ) return char
--          
--        is
--                name    char;
--        begin
--                select  to_char(to_date(calendar.month_name.current_date), 'fmMonth') 
--                        into name
--                from    dual;
--                        
--                return name;
--        end month_name;
--
--        
--          -- next month
--        function next_month (
--                current_date            date
--        ) return date
--
--        is
--                v_date                  date;
--        begin
--                select  trunc(add_months(to_date(sysdate), -1))
--                        into v_date
--                from    dual;
--
--                return v_date;          
--        end next_month;
--          
--
--          -- prev month
--        function prev_month (
--                current_date            date
--        ) return date
--        
--        is
--                v_date                  date;
--        begin
--                select  trunc(add_months(to_date(sysdate), -1))
--                        into v_date
--                from    dual;
--
--                return v_date;
--        end prev_month;
--
--          -- number of days in the month
--        function num_day_in_month (
--                current_date    date
--        ) return integer
--
--        is
--                v_num   integer;
--        begin
--                select  to_char(last_day(to_date(sysdate)), 'DD')
--                        into v_num
--                from    dual;
--
--                return v_num;
--        end num_day_in_month;
--
--          -- first day to be displayed in a month. 
--        function first_displayed_date (
--                current_date    date
--        ) return date
--
--        is
--                v_date          date;
--        begin
--                select  next_day(trunc(to_date(sysdate), 'Month') - 7, 'SUNDAY')
--                        into v_date
--                from    dual;
--
--                return  v_date;
--        end first_displayed_date;
--
--          -- last day to be displayed in a month. 
--        function last_displayed_date (
--                current_date    date
--        ) return date
--
--        is
--                v_date          date;
--        begin
--                select  next_day(last_day(to_date(sysdate)), 'SATURDAY')
--                        into v_date
--                from    dual;
--
--                return v_date;
--        end last_displayed_date;
--         
--end calendar;
--/
--show errors
 


-----------------------------------------------------------------
-- load related sql files
-----------------------------------------------------------------
--\i cal-item-create.sql
-- 
--@@cal-table-create
\i cal-table-create.sql
