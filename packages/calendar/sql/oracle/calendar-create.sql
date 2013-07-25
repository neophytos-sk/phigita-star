-- creates the calendar object
--
-- @author Gary Jin (gjin@arsdigita.com)
-- @creation-date Nov 17, 2000
-- @cvs-id $Id: calendar-create.sql,v 1.3 2002/03/16 21:06:44 ben Exp $
--

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
begin
        acs_privilege.create_privilege('cal_item_create', 'Add an new item'); 
        acs_privilege.create_privilege('cal_item_read',   'view an cal_item');
        acs_privilege.create_privilege('cal_item_write',  'Edit an exsiting cal_item');
        acs_privilege.create_privilege('cal_item_delete', 'Delete cal_item' );
        acs_privilege.create_privilege('cal_item_invite', 'Allow others to view cal_item'); 

          -- bind the calendar permissions to the golbal names

        acs_privilege.add_child('create', 'cal_item_create'); 
        acs_privilege.add_child('read', 'cal_item_read'); 
        acs_privilege.add_child('write', 'cal_item_write'); 
        acs_privilege.add_child('delete', 'cal_item_delete'); 

end;
/
show errors

  -- creating the addition set of permissions for calendar. 
  -- these are going to be used as status markers for the calendar
  -- 
  -- 1. calendar_on: calendar has been selected
  -- 2. calendar_show: user wants to view events from the calendar
  -- 3. calendar_hide: user does not want to view events from the calendar

begin
        acs_privilege.create_privilege('calendar_on', 'Implies that a calendar is selected'); 
        acs_privilege.create_privilege('calendar_show', 'Show a calendar');

          -- bind the calendar permissions to the golbal names

        acs_privilege.add_child('read', 'calendar_on'); 
        acs_privilege.add_child('read', 'calendar_show');         
end;
/
show errors

  -- creating the basic set of permissions for calendar. 
  --
  -- 1. calendar_create: make a new calendar 
  -- 2. calendar_read: can view all items on an exsiting calendar
  -- 3. calendar_write: can edit all items on an exsiting calendar 
  -- 4. calendar_delete: delete an existing calendar 


begin
        acs_privilege.create_privilege('calendar_create', 'Create a new calendar'); 
        acs_privilege.create_privilege('calendar_read', 'View items on an exsiting calendar');
        acs_privilege.create_privilege('calendar_write', 'Edit items of an exsiting calendar');
        acs_privilege.create_privilege('calendar_delete','Delete an calendar' );


          -- bind the calendar permissions to the golbal names

        acs_privilege.add_child('create', 'calendar_create'); 
        acs_privilege.add_child('read', 'calendar_read'); 
        acs_privilege.add_child('write', 'calendar_write'); 
        acs_privilege.add_child('delete', 'calendar_delete'); 

          -- bind the cal_item permissions to the calendar permissions

          -- When a calendar has the permission of public, 
          -- it implies that all the default permission to magic group 'public'
          -- have the permissions of "calendar_read"
        
          -- When a calendar has the permission of private
          -- it implies that the only group that will have the permission
          -- "calendar_read" would the group that the calendar belong to.

        acs_privilege.add_child('calendar_create', 'cal_item_create'); 
        acs_privilege.add_child('calendar_read', 'cal_item_read'); 
        acs_privilege.add_child('calendar_write', 'cal_item_write'); 
        acs_privilege.add_child('calendar_delete', 'cal_item_delete'); 
        
end;
/
show errors

  -- Assign the four basic permissions to more specific roles and conditions
  --
  -- calendar_admin is assigned by the owner when the calendar
  -- is created. A calendar_admin can grant any combinations 
  -- or read, write, delete and invite to any member of the party
  -- on a cal_item basis or on a calendar basis(all items). 
begin
        acs_privilege.create_privilege('calendar_admin', 'calendar adminstrator');
        acs_privilege.add_child('admin', 'calendar_admin');
        acs_privilege.add_child('calendar_admin', 'calendar_read');
        acs_privilege.add_child('calendar_admin', 'calendar_write');
        acs_privilege.add_child('calendar_admin', 'calendar_delete');
        acs_privilege.add_child('calendar_admin', 'calendar_create');
        acs_privilege.add_child('calendar_admin', 'cal_item_invite');

end;
/
show errors




---------------------------------------------------------- 
--  calendar_ojbect 
----------------------------------------------------------- 
 
begin
          -- create the calendar object

        acs_object_type.create_type (
                supertype       =>      'acs_object',
                object_type     =>      'calendar',
                pretty_name     =>      'Calendar',
                pretty_plural   =>      'Calendars',
                table_name      =>      'calendars',
                id_column       =>      'calendar_id'
        );
end;
/
show errors
 
declare 
        attr_id acs_attributes.attribute_id%TYPE; 
begin
        attr_id := acs_attribute.create_attribute ( 
                object_type     =>      'calendar', 
                attribute_name  =>      'owner_id', 
                pretty_name     =>      'Owner', 
                pretty_plural   =>      'Owners', 
                datatype        =>      'integer' 
        ); 
   
        attr_id := acs_attribute.create_attribute ( 
                object_type     =>      'calendar', 
                attribute_name  =>      'private_p', 
                pretty_name     =>      'Private Calendar', 
                pretty_plural   =>      'Private Calendars', 
                datatype        =>      'string' 
        ); 

        attr_id := acs_attribute.create_attribute ( 
                object_type     =>      'calendar', 
                attribute_name  =>      'calendar_name', 
                pretty_name     =>      'Calendar Name', 
                pretty_plural   =>      'Calendar Names', 
                datatype        =>      'string' 
        ); 
end;
/
show errors


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
        calendar_name           varchar2(200),
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
        private_p               varchar2(1)
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


----------------------------
-- Event Types for Calendars
----------------------------

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
@@cal-item-create

-------------------------------------------------------------
-- create package calendar
-------------------------------------------------------------
 
create or replace package calendar
as
        function new (
                calendar_id             in acs_objects.object_id%TYPE           default null,
                calendar_name           in calendars.calendar_name%TYPE         default null,
                object_type             in acs_objects.object_type%TYPE         default 'calendar',
                owner_id                in calendars.owner_id%TYPE              ,
                private_p               in calendars.private_p%TYPE             default 'f',
                package_id              in calendars.package_id%TYPE            default null,           
                context_id              in acs_objects.context_id%TYPE          default null,
                creation_date           in acs_objects.creation_date%TYPE       default sysdate,
                creation_user           in acs_objects.creation_user%TYPE       default null,
                creation_ip             in acs_objects.creation_ip%TYPE         default null

        ) return calendars.calendar_id%TYPE;
 
        procedure delete (
                calendar_id             in calendars.calendar_id%TYPE
        );

          -- figures out the name of the calendar       
        function name (
                calendar_id             in calendars.calendar_id%TYPE
        ) return calendars.calendar_name%TYPE;

          -- returns 't' if calendar is private and 'f' if its not
        function private_p (
                calendar_id             in calendars.calendar_id%TYPE
        ) return char;


          -- returns 't' if calendar is viewable by the given party
          -- this implies that the party has calendar_read permission
          -- on this calendar
        function readable_p (
                calendar_id             in calendars.calendar_id%TYPE,
                party_id                in parties.party_id%TYPE
        ) return char;

          -- returns 't' if party wants to be able to select 
          -- this calendar, and return 'f' otherwise. 
        function show_p (
                calendar_id             in calendars.calendar_id%TYPE,
                party_id                in parties.party_id%TYPE
        ) return char;
                

          ----------------------------------------------------------------
          -- Helper functions for calendar generations:
          --
          -- These functions are used for assist in calendar 
          -- generation. Putting them in the PL/SQL level ensures that
          -- the date date will be the same, and allowing adoptation 
          -- to a different language much easier and faster.
          --             
          -- current month name
        function month_name (
                current_date    date
        ) return char;
          
          -- next month
        function next_month (
                current_date    date
        ) return date;
          
          -- prev month
        function prev_month (
                current_date    date
        ) return date;

          -- number of days in the month
        function num_day_in_month (
                current_date    date
        ) return integer;

          -- first day to be displayed in a month. 
        function first_displayed_date (
                current_date    date
        ) return date;

          -- last day to be displayed in a month. 
        function last_displayed_date (
                current_date    date
        ) return date;          
          
end calendar;
/
show errors;
 
 
create or replace package body calendar
as 

        function new (
                calendar_id             in acs_objects.object_id%TYPE           default null,
                calendar_name           in calendars.calendar_name%TYPE         default null,
                object_type             in acs_objects.object_type%TYPE         default 'calendar',
                owner_id                in calendars.owner_id%TYPE              , 
                private_p               in calendars.private_p%TYPE             default 'f',
                package_id              in calendars.package_id%TYPE            default null,
                context_id              in acs_objects.context_id%TYPE          default null,
                creation_date           in acs_objects.creation_date%TYPE       default sysdate,
                creation_user           in acs_objects.creation_user%TYPE       default null,
                creation_ip             in acs_objects.creation_ip%TYPE         default null

        ) 
        return calendars.calendar_id%TYPE
   
        is
                v_calendar_id           calendars.calendar_id%TYPE;

        begin
                v_calendar_id := acs_object.new (
                        object_id       =>      calendar_id,
                        object_type     =>      object_type,
                        creation_date   =>      creation_date,
                        creation_user   =>      creation_user,
                        creation_ip     =>      creation_ip,
                        context_id      =>      context_id
                );
        
                insert into     calendars
                                (calendar_id, calendar_name, owner_id, package_id, private_p)
                values          (v_calendar_id, calendar_name, owner_id, package_id, private_p);


                  -- each calendar has three default conditions
                  -- 1. all items are public
                  -- 2. all items are private
                  -- 3. no default conditions
                  -- 
                  -- calendar being public implies granting permission
                  -- calendar_read to the group 'the_public' and 'registered users'
                  --         
                  -- calendar being private implies granting permission 
                  -- calendar_read to the owner party/group of the party
                  --
                  -- by default, we grant "calendar_admin" to
                  -- the owner of the calendar
                acs_permission.grant_permission (
                        object_id       =>      v_calendar_id,
                        grantee_id      =>      owner_id,
                        privilege       =>      'calendar_admin'
                );
                
 
                return v_calendar_id;
        end new;
 


          -- body for procedure delete
        procedure delete (
                calendar_id             in calendars.calendar_id%TYPE
        )
        is
  
        begin
                  -- First erase all the item relate to this calendar.
                delete from     calendars 
                where           calendar_id = calendar.delete.calendar_id;
 
                  -- Delete all privileges associate with this calendar
                delete from     acs_permissions 
                where           object_id = calendar.delete.calendar_id;

                  -- Delete all privilges of the cal_items that's associated 
                  -- with this calendar
                delete from     acs_permissions
                where           object_id in (
                                        select  cal_item_id
                                        from    cal_items
                                        where   on_which_calendar = calendar.delete.calendar_id                                                                                                                                                         
                                );
                        
 
                acs_object.delete(calendar_id);
        end delete;
 


          -- figures out the name of the calendar       
        function name (
                calendar_id             in calendars.calendar_id%TYPE
        ) 
        return calendars.calendar_name%TYPE

        is
                v_calendar_name         calendars.calendar_name%TYPE;
        begin
                select  calendar_name
                into    v_calendar_name
                from    calendars
                where   calendar_id = calendar.name.calendar_id;

                return v_calendar_name;
        end name;



          -- returns 't' if calendar is private and 'f' if its not
        function private_p (
                calendar_id             in calendars.calendar_id%TYPE
        ) 
        return char

        is
                v_private_p             char(1) := 't';
        begin
                select  private_p 
                into    v_private_p
                from    calendars
                where   calendar_id = calendar.private_p.calendar_id;

                return v_private_p;
        end private_p;



          -- returns 't' if calendar is viewable by the given party
          -- this implies that the party has calendar_read permission
          -- on this calendar
        function readable_p (
                calendar_id             in calendars.calendar_id%TYPE,
                party_id                in parties.party_id%TYPE
        ) 
        return char

        is      
                v_readable_p            char(1) := 't';
        begin
                select  decode(count(*), 1, 't', 'f') 
                into    v_readable_p
                from    acs_object_party_privilege_map 
                where   party_id = calendar.readable_p.party_id
                and     object_id = calendar.readable_p.calendar_id 
                and     privilege = 'calendar_read';

                return  v_readable_p;

        end readable_p;

          -- returns 't' if party wants to be able to select (calendar_show granted)
          -- this calendar, and .return 'f' otherwise. 
          --
          -- this seems to be a problem with the problem that when
          -- revoking the permissions using acs_permissions.revoke
          -- data is not removed from table acs_object_party_privilege_map.
        function show_p (
                calendar_id             in calendars.calendar_id%TYPE,
                party_id                in parties.party_id%TYPE
        ) 
        return char

        is
                v_show_p                char(1) := 't';
        begin
                select  decode(count(*), 1, 't', 'f') 
                into    v_show_p
                from    acs_permissions
                where   grantee_id = calendar.show_p.party_id
                and     object_id = calendar.show_p.calendar_id 
                and     privilege = 'calendar_show';

                return  v_show_p;

        end show_p;


          -- Helper functions for calendar generations:
          --
          -- These functions are used for assist in calendar 
          -- generation. Putting them in the PL/SQL level ensures that
          -- the date date will be the same, and allowing adoptation 
          -- to a different language much easier and faster.
          --             
          -- current month name
        function month_name (
                current_date            date
        ) return char
          
        is
                name    char;
        begin
                select  to_char(to_date(calendar.month_name.current_date), 'fmMonth') 
                        into name
                from    dual;
                        
                return name;
        end month_name;

        
          -- next month
        function next_month (
                current_date            date
        ) return date

        is
                v_date                  date;
        begin
                select  trunc(add_months(to_date(sysdate), -1))
                        into v_date
                from    dual;

                return v_date;          
        end next_month;
          

          -- prev month
        function prev_month (
                current_date            date
        ) return date
        
        is
                v_date                  date;
        begin
                select  trunc(add_months(to_date(sysdate), -1))
                        into v_date
                from    dual;

                return v_date;
        end prev_month;

          -- number of days in the month
        function num_day_in_month (
                current_date    date
        ) return integer

        is
                v_num   integer;
        begin
                select  to_char(last_day(to_date(sysdate)), 'DD')
                        into v_num
                from    dual;

                return v_num;
        end num_day_in_month;

          -- first day to be displayed in a month. 
        function first_displayed_date (
                current_date    date
        ) return date

        is
                v_date          date;
        begin
                select  next_day(trunc(to_date(sysdate), 'Month') - 7, 'SUNDAY')
                        into v_date
                from    dual;

                return  v_date;
        end first_displayed_date;

          -- last day to be displayed in a month. 
        function last_displayed_date (
                current_date    date
        ) return date

        is
                v_date          date;
        begin
                select  next_day(last_day(to_date(sysdate)), 'SATURDAY')
                        into v_date
                from    dual;

                return v_date;
        end last_displayed_date;
         
end calendar;
/
show errors
 


-----------------------------------------------------------------
-- load related sql files
-----------------------------------------------------------------
-- 
@@cal-table-create










