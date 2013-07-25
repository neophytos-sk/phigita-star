-- drop the calendar system
--
-- @author Gary Jin (gjin@arsdigita.com)
-- @creation-date Nov 27, 2000
-- $Id: calendar-drop.sql,v 1.2 2002/08/17 18:21:30 vinodk Exp $


------------------------------------------------
-- Drop the Permissions
------------------------------------------------

delete 	from acs_permissions
where 	privilege in (
		'cal_item_create', 
		'cal_item_read',
        	'cal_item_write', 
		'cal_item_delete',
        	'cal_item_invite'
	);


delete 	from acs_privilege_hierarchy
where 	privilege in (
		'cal_item_create', 
	        'cal_item_read', 
         	'cal_item_write', 
         	'cal_item_delete',       
         	'cal_item_invite'
	);


delete 	from acs_privilege_hierarchy
where 	child_privilege in (
		'cal_item_create', 
	        'cal_item_read', 
         	'cal_item_write', 
         	'cal_item_delete',       
         	'cal_item_invite'
	);


delete 	from acs_privileges
where 	privilege in (
		'cal_item_create', 
	        'cal_item_read', 
         	'cal_item_write', 
         	'cal_item_delete',       
         	'cal_item_invite'
	);



delete 	from acs_permissions
where 	privilege in (
		'calendar_create', 
		'calendar_read',
        	'calendar_write', 
		'calendar_delete',
        	'calendar_admin',
	       	'calendar_on',
	       	'calendar_show'
	);


delete 	from acs_privilege_hierarchy
where 	privilege in (
		'calendar_create', 
	        'calendar_read', 
         	'calendar_write', 
         	'calendar_delete',       
         	'calendar_admin',
	       	'calendar_on',
	       	'calendar_show'
	);


delete 	from acs_privilege_hierarchy
where 	child_privilege in (
		'calendar_create', 
	        'calendar_read', 
         	'calendar_write', 
         	'calendar_delete',       
         	'calendar_admin',
	       	'calendar_on',
	       	'calendar_show'
	);



delete 	from acs_privileges
where 	privilege in (
		'calendar_create', 
	        'calendar_read', 
         	'calendar_write', 
         	'calendar_delete',
         	'calendar_admin',
	       	'calendar_on',
	       	'calendar_show'
	);



------------------------------------------------
-- Drop Support Tables
------------------------------------------------
@@cal-table-drop


------------------------------------------------
-- drop cal_item
------------------------------------------------
@@cal-item-drop


------------------------------------------------
-- Drop Calendar
------------------------------------------------

  -- drop attributes and acs_object_type
begin
  acs_attribute.drop_attribute ('calendar','owner_id');
  acs_attribute.drop_attribute ('calendar','private_p');
  acs_object_type.drop_type ('calendar');
end;
/
show errors


  -- drop package	  
drop package calendar;


  -- drop table  
drop table calendars;











